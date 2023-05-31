import pandas as pd
import os, glob, sys
from osgeo import gdal, osr
import numpy as np
from pyresample import create_area_def
import matplotlib.pyplot as plt
import netCDF4 as nc
import ASTER_cloud_mask_funcs as Acm
import statistics

all_meanAt = []
all_meansecf = []
all_meanmodcf = []
all_meanprccf1 = []
all_meanprccf2 = []
all_meanprccf3 = []
all_meanprccf4 = []
all_meanprccf5 = []

all_stdAt = []
all_stdsecf = []
all_stdmodcf = []
all_stdprccf1 = []
all_stdprccf2 = []
all_stdprccf3 = []
all_stdprccf4 = []
all_stdprccf5 = []

reg = [1, 2, 4, 6, 3, 5]
#reg = [1, 2, 4, 3]

for i in reg:
    cf_files = glob.glob('/data/gdi/c/mdevera2/dutta_CFs3/'+str(i)+'/*.csv')

    print(len(cf_files))

    li=[]

    for file in cf_files:
        print(file)
        counts = pd.read_csv(file, names = ['block', 'subblock_col', 'subblock_row', 'total', 'cloudy', 'At', 'mod35cf', 'Ae1', 'prccf1', 'Ae2', 'prccf2', 'Ae3', 'prccf3', 'Ae4', 'prccf4', 'Ae5', 'prccf5'])
        li.append(counts)

    all = pd.concat(li, axis=0, ignore_index=True)

    lessthan99 = all[all['total'] > 1362944]
    #Ae1 = lessthan99[lessthan99['Ae1'] != 1]
    #Ae0 = Ae1[Ae1['Ae1'] != 0]
    final = lessthan99
    #final = Ae0[Ae0['At'] != 0]
    #final[final<0] = np.nan
    #final = final.dropna().reset_index(drop=True)
    print(final)
    print(final['At'])

    mean_At = np.mean(final['At'])
    mean_secf = np.mean(final['Ae1'])
    mean_modcf = np.mean(final['mod35cf'])
    mean_prccf1 = np.nanmean(final['prccf1'])
    mean_prccf2 = np.nanmean(final['prccf2'])
    mean_prccf3 = np.nanmean(final['prccf3'])
    mean_prccf4 = np.nanmean(final['prccf4'])
    mean_prccf5 = np.nanmean(final['prccf5'])

    all_meanAt.append(mean_At)
    all_meansecf.append(mean_secf)
    all_meanmodcf.append(mean_modcf)
    all_meanprccf1.append(mean_prccf1)
    all_meanprccf2.append(mean_prccf2)
    all_meanprccf3.append(mean_prccf3)
    all_meanprccf4.append(mean_prccf4)
    all_meanprccf5.append(mean_prccf5)

    std_At = np.std(final['At'])
    std_secf = np.std(final['Ae1'])
    std_modcf = np.std(final['mod35cf'])
    std_prccf1 = np.nanstd(final['prccf1'])
    std_prccf2 = np.nanstd(final['prccf2'])
    std_prccf3 = np.nanstd(final['prccf3'])
    std_prccf4 = np.nanstd(final['prccf4'])
    std_prccf5 = np.nanstd(final['prccf5'])

    all_stdAt.append(std_At)
    all_stdsecf.append(std_secf)
    all_stdmodcf.append(std_modcf)
    all_stdprccf1.append(std_prccf1)
    all_stdprccf2.append(std_prccf2)
    all_stdprccf3.append(std_prccf3)
    all_stdprccf4.append(std_prccf4)
    all_stdprccf5.append(std_prccf5)

    print(mean_At, mean_secf, mean_modcf, mean_prccf1, mean_prccf2, mean_prccf3, mean_prccf4, mean_prccf5)
    print(std_At, std_secf, std_modcf, std_prccf1, std_prccf2, std_prccf3, std_prccf4, std_prccf5)
    print(statistics.stdev(final['At']), statistics.stdev(final['Ae1']), statistics.stdev(final['mod35cf']), 
    statistics.stdev(final['prccf1']), statistics.stdev(final['prccf2']), statistics.stdev(final['prccf3']), statistics.stdev(final['prccf4']), statistics.stdev(final['prccf5']))

regions = [str(i) for i in reg]
X_axis_land = np.arange(4)
X_axis_ocean = np.arange(4)

#colors = ['blue', 'red', 'orange', 'purple', 'cyan', 'yellow', 'green']
#handles = [plt.Rectangle((0,0),1,1, color=colors[label]) for label in labels]

fig,ax=plt.subplots(1,2, figsize=(11,4))
ax[0].bar(X_axis_land, all_meanAt[0:4], 0.1, label = 'ASTER', color='blue')
ax[0].bar(X_axis_land+0.1, all_meanprccf1[0:4], 0.1, label = 'RCCF_TS1', color='red')
#plt.bar(X_axis+0.1*2, all_meanprccf2, 0.1, label = 'PRCCF_TS2', color='purple')
#plt.bar(X_axis+0.1*3, all_meanprccf3, 0.1, label = 'PRCCF_TS3', color='cyan')
ax[0].bar(X_axis_land+0.1*2, all_meanprccf4[0:4], 0.1, label = 'RCCF_TS4', color='pink')
ax[0].bar(X_axis_land+0.1*3, all_meanprccf5[0:4], 0.1, label = 'RCCF_TS5', color='sienna')
ax[0].bar(X_axis_land+0.1*4, all_meansecf[0:4], 0.1, label = 'SECF', color='yellow')
ax[0].bar(X_axis_land+0.1*5, all_meanmodcf[0:4], 0.1, label = 'MOD35 CF', color='green')
ax[0].set_xlim(-0.25,4-0.25)
ax[0].set_ylim(0,0.6)
ax[0].set_xticks(X_axis_land+0.25, regions[0:4])
ax[0].set_title('Land Regions')
ax[0].set_ylabel('Mean Cloud Fraction')

ax[1].bar(X_axis_ocean, [np.nan, all_meanAt[4], all_meanAt[5], np.nan], 0.1, label = 'ASTER', color='blue')
ax[1].bar(X_axis_ocean+0.1, [np.nan, all_meanprccf1[4], all_meanprccf1[5], np.nan], 0.1, label = 'RCCF_TS1', color='red')
#plt.bar(X_axis+0.1*2, all_meanprccf2, 0.1, label = 'PRCCF_TS2', color='purple')
#plt.bar(X_axis+0.1*3, all_meanprccf3, 0.1, label = 'PRCCF_TS3', color='cyan')
ax[1].bar(X_axis_ocean+0.1*2, [np.nan, all_meanprccf4[4], all_meanprccf4[5], np.nan], 0.1, label = 'RCCF_TS4', color='pink')
ax[1].bar(X_axis_ocean+0.1*3, [np.nan, all_meanprccf5[4], all_meanprccf5[5], np.nan], 0.1, label = 'RCCF_TS5', color='sienna')
ax[1].bar(X_axis_ocean+0.1*4, [np.nan, all_meansecf[4], all_meansecf[5], np.nan], 0.1, label = 'SECF', color='yellow')
ax[1].bar(X_axis_ocean+0.1*5, [np.nan ,all_meanmodcf[4], all_meanmodcf[5], np.nan], 0.1, label = 'MOD35 CF', color='green')
ax[1].set_xlim(-0.25,4-0.25)
ax[1].set_ylim(0,0.6)
xticks = ax[1].xaxis.get_major_ticks()
xticks[0].set_visible(False)
xticks[3].set_visible(False)
ax[1].set_xticks(X_axis_ocean+0.25, [None, regions[4], regions[5], None])
ax[1].set_title('Oceanic Regions')
ax[1].set_ylabel('Mean Cloud Fraction')
ax[1].legend(loc='upper center', bbox_to_anchor=(-0.1, 1.25), ncol=6, frameon=True)
plt.savefig('/data/keeling/a/mdevera2/dutta_scenes/CF_comparison_dutta4_rccf_sep.png', dpi=300, bbox_inches='tight')

'''diff = final['prccf'] - final['At']
bins = np.arange(-1.0,1.1,0.1)
print(np.mean(diff))
print(np.min(diff))
print(np.max(diff))

fig,ax=plt.subplots()
plt.hist(diff, bins=bins)
#plt.legend()
plt.savefig('/data/keeling/a/mdevera2/macrost/CF_comparison_diff.png', dpi=300)'''
