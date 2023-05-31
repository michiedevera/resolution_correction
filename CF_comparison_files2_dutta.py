from tkinter import YView
import pandas as pd
import os, glob, sys
from osgeo import gdal, osr
import numpy as np
import MisrToolkit as Mtk
from pyresample import create_area_def
import matplotlib.pyplot as plt
import netCDF4 as nc
import ASTER_cloud_mask_funcs as Acm
from datetime import datetime

def getaster1tgeo(file_name,resolution):
    # print('Processing File: ' + file_name + ' (' + str(k+1) + ' out of ' 
    # + str(len(file_list)) + ')')
    # Read in the file and metadata
    aster = gdal.Open(file_name)
    # aster_sds = aster.GetSubDatasets()
    meta = aster.GetMetadata()
    # Define UL, LR, UTM zone    
    ll = [float(x) for x in meta['LOWERLEFTM'].split(', ')]
    ur = [float(x) for x in meta['UPPERRIGHTM'].split(', ')]
    utm = int(meta['UTMZONENUMBER'])
    # Create UTM zone code numbers    
    #n_s = np.float(meta['NORTHBOUNDINGCOORDINATE'])
    # Define UTM zone based on North or South
    # if n_s < 0:
    #     ur[1] = ur[1] + 10000000
    #     ll[1] = ll[1] + 10000000  
    # Define extent for UTM North zones             
    proj_dict = {'proj': 'utm','zone': utm, 'datum':'WGS84', \
                 'towgs84':'0,0,0','ellps': 'WGS84', 'no_defs':'', 'units': 'm'} 
    area_extent = (ll[1]-7.5,ll[0]-7.5, ur[1]+7.5, ur[0]+7.5)
    area_def = create_area_def('aster', proj_dict, area_extent=area_extent,resolution=resolution,units='m')
    lons, lats = area_def.get_lonlats()
    return lats, lons

def get_modcmask(asterfile, modisfile, modgeofile):
    modis = gdal.Open(modgeofile)
    modis_sds = modis.GetSubDatasets()
    mod_geo = gdal.Open(modis_sds[0][0]).GetMetadata('Geolocation')

    mod_lon = gdal.Open(mod_geo['X_DATASET']).ReadAsArray().astype(np.float64)
    mod_lat = gdal.Open(mod_geo['Y_DATASET']).ReadAsArray().astype(np.float64)
    ast_lats, ast_lons = getaster1tgeo(asterfile, 15)

    x, y = np.where((mod_lat<ast_lats.max()) & (mod_lat>ast_lats.min()) & (mod_lon<ast_lons.max()) & (mod_lon>ast_lons.min()))
    x1 = np.min(x)
    x2 = np.max(x)+4
    y1 = np.min(y)-4
    y2 = np.max(y)+4

    modiscm = gdal.Open(modisfile)
    modis_sds = modiscm.GetSubDatasets()
    mask = gdal.Open(modis_sds[6][0])
    cmask = mask.ReadAsArray().astype(np.uint16)

    binary_repr_v = np.vectorize(np.binary_repr)
    int_mask0 = binary_repr_v(cmask[0] & 1, 1).astype(float)
    int_mask0[int_mask0==0]=np.nan
    int_mask1 = binary_repr_v(cmask[0] >> 1 & 1, 1).astype(float)
    int_mask2 = binary_repr_v(cmask[0] >> 2 & 1, 1).astype(float)
    cloud_mask = (int_mask2 * 2 + int_mask1) * int_mask0
    
    mod_cmask = cloud_mask[x1:x2, y1:y2].copy()
    mod_cmask[cloud_mask[x1:x2, y1:y2] == 1] = 0
    mod_cmask[cloud_mask[x1:x2, y1:y2] == 2] = 3

    cmod_lat = mod_lat[x1:x2, y1:y2].copy()
    cmod_lon = mod_lon[x1:x2, y1:y2].copy()

    return mod_cmask, cmod_lat, cmod_lon

def fillmisrgrid(asterfile, modiscmfile, modgeofile, misrfile, grid, block1, block2, path):
    offset = Mtk.MtkProjParam(misrfile).reloffset
    cmask, cutmod_lat, cutmod_lon = get_modcmask(asterfile, modiscmfile, modgeofile)
    for i in range(cmask.shape[0]):
        for j in range(cmask.shape[1]):
            b, l, s = Mtk.latlon_to_bls(path, 1100, cutmod_lat[i,j], cutmod_lon[i,j])
            l = l + 0.5
            if((block1 != block2) & (b == block2)):
                l = l + 128
            l = int(l)

            s = s + 0.5
            if((block1 != block2) & (b == block1)):
                s = s - offset[block1-1]
            s = int(s)

            if((block1 == block2) & (b != block1)):
                continue

            grid[l,s] = cmask[i,j]

def get_modcf(misrgrid, sblock, srow, scol, b1, b2):
    gblock = misrgrid.copy()
    if (b1 != b2):
        gblock[:128,:] = b1
        gblock[128:,:] = b2
    else:
        gblock[:] = b1
    
    grow = np.arange(misrgrid.shape[0])
    grow = np.kron(grow, np.ones((misrgrid.shape[1],1))).T
    grow = (grow/16).astype(int)

    gcol = np.arange(misrgrid.shape[1])
    gcol = np.kron(gcol, np.ones((misrgrid.shape[0],1)))
    gcol = (gcol/16).astype(int)
    
    combined = np.stack((gblock,grow, gcol, misrgrid), axis=-1)
    cloudy = (combined[:,:,0]==sblock) & (combined[:,:,1]==srow) & (combined[:,:,2]==scol) & (combined[:,:,3]==0)
    num_cloudy = np.count_nonzero(cloudy)
    clear = (combined[:,:,0]==sblock) & (combined[:,:,1]==srow) & (combined[:,:,2]==scol) & (combined[:,:,3]==3)
    num_clear = np.count_nonzero(clear)

    print((num_cloudy+num_clear))
    cf = num_cloudy/(num_cloudy+num_clear)
    return cf


for k in range(4,5):
    out_dir = '/data/gdi/c/mdevera2/dutta_CFs3/'+str(k)+'/'
    if not os.path.exists(out_dir): 
                    os.makedirs(out_dir)

    count_files = glob.glob('/data/gdi/c/mdevera2/ASTER_MISR_dutta2/'+str(k)+'/counts/*.txt')
    astL1T_dir = '/data/gdi/c/mdevera2/dutta_AST_L1T/'+str(k)+'/'

    print(k)

    for file in count_files:
        print(file)
        file_name = file.split('/')[-1].split('_counts')[0]
        print(file_name)
        counts = pd.read_csv(file, names = ['bl', 'subcol', 'subrow', 'totalpixels', 'cloudypixels'], delim_whitespace=True)
        counts['At'] = counts['cloudypixels']/counts['totalpixels']
        orbit = file.split('/')[-1].split('_')[0].zfill(6)
        print(orbit)

        blockfile = '/data/keeling/a/mdevera2/c/ASTER_MISR_dutta2/'+str(k)+'/blocks/'+file_name+'_block.txt'
        with open(blockfile) as f:
            blocks = f.readlines()
        b1 = int(blocks[0].split(' ')[0])
        b2 = int(blocks[0].split(' ')[1])
        print(b1, b2)
        
        '''misr = glob.glob('/data/gdi/c/mdevera2/dutta_MISR_TC_Classifiers/*'+orbit+'*.hdf')[0]
        m = Mtk.MtkFile(misr)
        reg = Mtk.MtkRegion(m.path, b1, b2)

        secf = m.grid('ResolutionCorrectedCloudFractions_17.6_km').field('StandardEstimateCloudFraction[4]').read(reg).data()
        secf_list = []

        prccf = m.grid('ResolutionCorrectedCloudFractions_17.6_km').field('PatternRecognitionCorrectedCloudFraction[4]').read(reg).data()
        prccf_list = []'''

        misr1 = glob.glob('/data/gdi/c/mdevera2/dutta_TS_tests/TS1/*'+orbit+'*.hdf')[0]
        m1 = Mtk.MtkFile(misr1)
        reg = Mtk.MtkRegion(m1.path, b1, b2)

        secf1 = m1.grid('ResolutionCorrectedCloudFractions_17.6_km').field('StandardEstimateCloudFraction[4]').read(reg).data()
        secf1_list = []

        prccf1 = m1.grid('ResolutionCorrectedCloudFractions_17.6_km').field('PatternRecognitionCorrectedCloudFraction[4]').read(reg).data()
        prccf1_list = []

        misr2 = glob.glob('/data/gdi/c/mdevera2/dutta_TS_tests/TS2/*'+orbit+'*.hdf')[0]
        m2 = Mtk.MtkFile(misr2)

        secf2 = m2.grid('ResolutionCorrectedCloudFractions_17.6_km').field('StandardEstimateCloudFraction[4]').read(reg).data()
        secf2_list = []

        prccf2 = m2.grid('ResolutionCorrectedCloudFractions_17.6_km').field('PatternRecognitionCorrectedCloudFraction[4]').read(reg).data()
        prccf2_list = []

        misr3 = glob.glob('/data/gdi/c/mdevera2/dutta_TS_tests/TS3/*'+orbit+'*.hdf')[0]
        m3 = Mtk.MtkFile(misr3)

        secf3 = m3.grid('ResolutionCorrectedCloudFractions_17.6_km').field('StandardEstimateCloudFraction[4]').read(reg).data()
        secf3_list = []

        prccf3 = m3.grid('ResolutionCorrectedCloudFractions_17.6_km').field('PatternRecognitionCorrectedCloudFraction[4]').read(reg).data()
        prccf3_list = []

        misr4 = glob.glob('/data/gdi/c/mdevera2/dutta_TS_tests/TS4/*'+orbit+'*.hdf')[0]
        m4 = Mtk.MtkFile(misr4)

        secf4 = m4.grid('ResolutionCorrectedCloudFractions_17.6_km').field('StandardEstimateCloudFraction[4]').read(reg).data()
        secf4_list = []

        prccf4 = m4.grid('ResolutionCorrectedCloudFractions_17.6_km').field('PatternRecognitionCorrectedCloudFraction[4]').read(reg).data()
        prccf4_list = []

        misr5 = glob.glob('/data/gdi/c/mdevera2/dutta_TS_tests/TS5/*'+orbit+'*.hdf')[0]
        m5 = Mtk.MtkFile(misr5)

        secf5 = m5.grid('ResolutionCorrectedCloudFractions_17.6_km').field('StandardEstimateCloudFraction[4]').read(reg).data()
        secf5_list = []

        prccf5 = m5.grid('ResolutionCorrectedCloudFractions_17.6_km').field('PatternRecognitionCorrectedCloudFraction[4]').read(reg).data()
        prccf5_list = []

        misrgrid = np.empty(shape=secf1.shape)
        misrgrid = np.kron(misrgrid, np.ones((16,16)))
        misrgrid[:] = np.nan

        date = file_name.split('_')[3][3:11]
        print(date)
        mm = date[0:2]
        dd = date[2:4]
        yy = date[4:8]
        print(dd, mm, yy)
        time = file_name.split('_')[3][11:15]
        h = time[0:2]
        mn = str(int(int(time[2:4])/5)*5).zfill(2)
        print(mn)
        aster = astL1T_dir + '/AST' + file_name.split('_AST')[-1] + '.hdf'
        print(aster)
        ast = gdal.Open(aster)
        meta = ast.GetMetadata()
        dated = datetime.strptime(meta['CALENDARDATE'], '%Y%m%d')
        doy = str(dated.timetuple().tm_yday).zfill(3)
        print(doy)
        try:
            modiscm = glob.glob('/data/gdi/d/MOD35/MOD35_L2/'+yy+'/'+doy+'/*'+yy+doy+'.'+h+mn+'*.hdf')[0]
        except:
            modiscm = glob.glob('/data/gdi/c/mdevera2/dutta_MOD35/*'+yy+doy+'.'+h+mn+'*.hdf')[0]
        try:
            modgeo = glob.glob('/data/keeling/a/mdevera2/satellite/TerraDataArchive/MODIS/MOD03/'+yy+'/'+doy+'/*'+yy+doy+'.'+h+mn+'*.hdf')[0]
        except:
            modgeo = glob.glob('/data/gdi/c/mdevera2/dutta_MOD03/*'+yy+doy+'.'+h+mn+'*.hdf')[0]
        print(modiscm)
        print(modgeo)
        modcf_list=[]

        fillmisrgrid(aster, modiscm, modgeo, misr1, misrgrid, b1, b2, m1.path)

        try:
            if (mn=='00'):
                min = '55'
                hr = str(int(h)-1).zfill(2)
            else:
                min = str(int(mn) - 5).zfill(2)
                hr = h
            try:
                modiscm2 = glob.glob('/data/gdi/d/MOD35/MOD35_L2/'+yy+'/'+doy+'/*'+yy+doy+'.'+hr+min+'*.hdf')[0]
            except:
                modiscm2 = glob.glob('/data/gdi/c/mdevera2/dutta_MOD35/*'+yy+doy+'.'+hr+min+'*.hdf')[0]
            try:
                modgeo2 = glob.glob('/data/keeling/a/mdevera2/satellite/TerraDataArchive/MODIS/MOD03/'+yy+'/'+doy+'/*'+yy+doy+'.'+hr+min+'*.hdf')[0]
            except:
                modgeo2 = glob.glob('/data/gdi/c/mdevera2/dutta_MOD03/*'+yy+doy+'.'+hr+min+'*.hdf')[0]
            print('2')
            print(modiscm2)
            print(modgeo2)
            fillmisrgrid(aster, modiscm2, modgeo2, misr1, misrgrid, b1, b2, m1.path)
        except:
            print('no2')

        try:
            if (mn=='55'):
                min = '00'
                hr = str(int(h)+1).zfill(2)
            else:
                min = str(int(mn) + 5).zfill(2)
                hr = h
            try:
                modiscm3 = glob.glob('/data/gdi/d/MOD35/MOD35_L2/'+yy+'/'+doy+'/*'+yy+doy+'.'+hr+min+'*.hdf')[0]
            except:
                modiscm3 = glob.glob('/data/gdi/c/mdevera2/dutta_MOD35/*'+yy+doy+'.'+hr+min+'*.hdf')[0]
            try:
                modgeo3 = glob.glob('/data/keeling/a/mdevera2/satellite/TerraDataArchive/MODIS/MOD03/'+yy+'/'+doy+'/*'+yy+doy+'.'+hr+min+'*.hdf')[0]
            except:
                modgeo3 = glob.glob('/data/gdi/c/mdevera2/dutta_MOD03/*'+yy+doy+'.'+hr+min+'*.hdf')[0]
            print(modiscm3)
            print(modgeo3)
            fillmisrgrid(aster, modiscm3, modgeo3, misr1, misrgrid, b1, b2, m1.path)
        except:
            print('no3')

        for i in range(len(counts)):
            if counts['bl'][i] == b1:
                r = counts['subrow'][i] - 1
                c = counts['subcol'][i] - 1
                print(counts['bl'][i],r,c)
                #secf_list.append(secf[r,c])
                #prccf_list.append(prccf[r,c])
                secf1_list.append(secf1[r,c])
                prccf1_list.append(prccf1[r,c])
                secf2_list.append(secf2[r,c])
                prccf2_list.append(prccf2[r,c])
                secf3_list.append(secf3[r,c])
                prccf3_list.append(prccf3[r,c])
                secf4_list.append(secf4[r,c])
                prccf4_list.append(prccf4[r,c])
                secf5_list.append(secf5[r,c])
                prccf5_list.append(prccf5[r,c])
                modcf = get_modcf(misrgrid, counts['bl'][i], r, c, b1, b2)
                modcf_list.append(modcf)
                
            else:
                r = counts['subrow'][i] - 1 + 8
                c = counts['subcol'][i] - 1
                #secf_list.append(secf[r,c])
                #prccf_list.append(prccf[r,c])
                secf1_list.append(secf1[r,c])
                prccf1_list.append(prccf1[r,c])
                secf2_list.append(secf2[r,c])
                prccf2_list.append(prccf2[r,c])
                secf3_list.append(secf3[r,c])
                prccf3_list.append(prccf3[r,c])
                secf4_list.append(secf4[r,c])
                prccf4_list.append(prccf4[r,c])
                secf5_list.append(secf5[r,c])
                prccf5_list.append(prccf5[r,c])
                modcf = get_modcf(misrgrid, counts['bl'][i], r, c, b1, b2)
                modcf_list.append(modcf)

        #counts['secf']=secf_list
        #counts['prccf']=prccf_list
        counts['mod35cf'] = modcf_list
        counts['secf1']=secf1_list
        counts['prccf1']=prccf1_list
        counts['secf2']=secf2_list
        counts['prccf2']=prccf2_list
        counts['secf3']=secf3_list
        counts['prccf3']=prccf3_list
        counts['secf4']=secf4_list
        counts['prccf4']=prccf4_list
        counts['secf5']=secf5_list
        counts['prccf5']=prccf5_list
        print(counts)

        counts.to_csv(out_dir+'/'+file_name+'.csv', header=None, index=None, float_format='%0.6f')
