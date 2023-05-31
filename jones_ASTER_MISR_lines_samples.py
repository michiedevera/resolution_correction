from osgeo import gdal, osr
import numpy as np
import os, glob, sys, getopt, argparse
import MisrToolkit as Mtk
import pandas as pd
from pyresample import create_area_def

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

def getbls(asterfile, region):
    ast_resolution = 15
    ast_lats, ast_lons = getaster1tgeo(asterfile, 15)
    aster = gdal.Open(asterfile)
    meta = aster.GetMetadata()
    orbit = meta['ORBITNUMBER']
    print(orbit)

    try:
        misrfile = glob.glob('/data/gdi/a/aljones4/MISR_data/'+region+'/*'+orbit+'*.hdf')[0]
    except:
        misrfile = glob.glob('/data/keeling/a/mdevera2/allie_MISR_code/'+region+'_RCCM/*'+orbit+'*.hdf')[0]
    m = Mtk.MtkFile(misrfile)
    path = m.path
    misr_resolution = 1100
    block, line, sample = Mtk.latlon_to_bls(path, misr_resolution, ast_lats.flatten(), ast_lons.flatten())

    title = asterfile.split('/')[-1].split('.hdf')[0]
    blockfile = open(out_dir+'/'+region+'/blocks/'+orbit+'_'+title+'_block.txt','w')
    
    b1 = np.min(block)
    b2 = np.max(block)

    blockfile.write(str(b1)+' ')
    blockfile.write(str(b2))
    blockfile.close()

    line = line + 0.5
    if(b1 != b2):
        block2 = np.where(block==b2)
        line[block2] = line[block2] + 128
    line = line.astype(int) + 1
    linefile = line.reshape(ast_lats.shape[1], ast_lats.shape[0], order='F').T
    linefile.tofile(out_dir+'/'+region+'/line/'+title+'_line.bin')

    sample = sample + 0.5
    sample = sample.astype(int) + 1
    samplefile = sample.reshape(ast_lats.shape[1], ast_lats.shape[0], order='F').T
    samplefile.tofile(out_dir+'/'+region+'/sample/'+title+'_sample.bin')

out_dir = '/data/gdi/c/mdevera2/ASTER_MISR_allie_new_bin3/'
if not os.path.exists(out_dir): 
    os.makedirs(out_dir)

#region = ['gomex', 'india', 'RICOnew', 'RICOold']
#AST_region = ['gomex', 'indian', 'rico/new', 'rico/old']

region = ['RICOold']
AST_region = ['rico/old']

in_dir = '/data/gdi/e/ASTER/'

for i in range(len(AST_region)):
    if not os.path.exists(out_dir+'/'+region[i]+'/blocks/'): 
        os.makedirs(out_dir+'/'+region[i]+'/blocks/')
    if not os.path.exists(out_dir+'/'+region[i]+'/line/'): 
        os.makedirs(out_dir+'/'+region[i]+'/line/')
    if not os.path.exists(out_dir+'/'+region[i]+'/sample/'): 
        os.makedirs(out_dir+'/'+region[i]+'/sample/')

    file_dir = in_dir + AST_region[i]
    print(file_dir)
    asterfiles = glob.glob(file_dir+'/AST_L1T*.hdf')
    for file in asterfiles:
        print(file)
        getbls(file, region[i])
