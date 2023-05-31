import pandas as pd

'''col_names = ['block', 'subblock_col', 'subblock_row', 'cloudy', 'total', 'At', 'A17', 'Ae', 'Aedge', 'Ione', 'VAR', 'MEAN', 'ENT', 'orbit', 'date', 'time']

gomex = pd.read_csv("/data/gdi/b/atmos-aljones4/pattern_recog_MISR/output/gomex/training/unfiltered/gomex_totalTS.txt", sep=' ', skipinitialspace='True', names=col_names)
india = pd.read_csv("/data/gdi/b/atmos-aljones4/pattern_recog_MISR/output/india/training/unfiltered/india_totalTS.txt", sep=' ', skipinitialspace='True', names=col_names)
RICOnew = pd.read_csv("/data/gdi/b/atmos-aljones4/pattern_recog_MISR/output/RICOnew/training/unfiltered/RICOnew_totalTS.txt", sep=' ', skipinitialspace='True', names=col_names)
RICOold = pd.read_csv("/data/gdi/b/atmos-aljones4/pattern_recog_MISR/output/RICOold/training/unfiltered/RICOold_totalTS.txt", sep=' ', skipinitialspace='True', names=col_names)

files = [RICOnew, india, gomex, RICOold]

df = pd.concat(files, ignore_index=True)
lessthan99 = df[df['total'] > 1362944]
Ae1 = lessthan99[lessthan99['Ae'] != 1]
Ae0 = Ae1[Ae1['Ae'] != 0]
Ae0 = Ae0.reset_index(drop=True)
#Ae0 = Ae0.astype(str)
#print(Ae0)

Ae0.to_csv('/data/keeling/a/mdevera2/allie_MISR_code/TrainingSet_JPL.csv')


col_names = ['block', 'subblock_col', 'subblock_row', 'cloudy', 'total', 'At', 'A17', 'Ae', 'Aedge', 'Ione', 'VAR', 'MEAN', 'ENT', 'orbit', 'date', 'time']

gomex = pd.read_csv("/data/gdi/c/mdevera2/ASTER_MISR_allie/gomex_totalTS.txt", sep=' ', skipinitialspace='True', names=col_names)
india = pd.read_csv("/data/gdi/c/mdevera2/ASTER_MISR_allie/india_totalTS.txt", sep=' ', skipinitialspace='True', names=col_names)
RICOnew = pd.read_csv("/data/gdi/c/mdevera2/ASTER_MISR_allie/RICOnew_totalTS.txt", sep=' ', skipinitialspace='True', names=col_names)
RICOold = pd.read_csv("/data/gdi/c/mdevera2/ASTER_MISR_allie/RICOold_totalTS.txt", sep=' ', skipinitialspace='True', names=col_names)

files = [RICOnew, india, gomex, RICOold]

df = pd.concat(files, ignore_index=True)
lessthan99 = df[df['total'] > 1362944]
Ae1 = lessthan99[lessthan99['Ae'] != 1]
Ae0 = Ae1[Ae1['Ae'] != 0]
Ae0 = Ae0.reset_index(drop=True)
print(Ae0)

Ae0.to_csv('/data/keeling/a/mdevera2/allie_MISR_code/TrainingSet_JPL_new.csv')'''

'''col_names = ['block', 'subblock_col', 'subblock_row', 'cloudy', 'total', 'At', 'A17', 'Ae', 'Aedge', 'Ione', 'VAR', 'MEAN', 'ENT', 'orbit', 'date', 'time']

good = pd.read_csv("/data/gdi/c/mdevera2/ASTER_MISR3/CAMP2Ex_good_totalTS.txt", delim_whitespace=True, skipinitialspace='True', names=col_names)
sunglint_okay = pd.read_csv("/data/gdi/c/mdevera2/ASTER_MISR3/CAMP2Ex_sunglint_okay_totalTS.txt", delim_whitespace=True, skipinitialspace='True', names=col_names)

files = [good, sunglint_okay]

df = pd.concat(files, ignore_index=True)
lessthan99 = df[df['total'] > 1362944]
Ae1 = lessthan99[lessthan99['Ae'] != 1]
Ae0 = Ae1[Ae1['Ae'] != 0]
Ae0 = Ae0.reset_index(drop=True)
print(Ae0)

Ae0.to_csv('/data/keeling/a/mdevera2/allie_MISR_code/TrainingSet_CAMP2Ex_3.csv')'''

col_names = ['block', 'subblock_col', 'subblock_row', 'cloudy', 'total', 'At', 'A17', 'Ae', 'Aedge', 'Ione', 'VAR', 'MEAN', 'ENT', 'orbit', 'date', 'time']

gomex = pd.read_csv("/data/gdi/c/mdevera2/ASTER_MISR_allie_new_bin4/gomex_totalTS.txt", sep=' ', skipinitialspace='True', names=col_names)
india = pd.read_csv("/data/gdi/c/mdevera2/ASTER_MISR_allie_new_bin4/india_totalTS.txt", sep=' ', skipinitialspace='True', names=col_names)
RICOnew = pd.read_csv("/data/gdi/c/mdevera2/ASTER_MISR_allie_new_bin4/RICOnew_totalTS.txt", sep=' ', skipinitialspace='True', names=col_names)
RICOold = pd.read_csv("/data/gdi/c/mdevera2/ASTER_MISR_allie_new_bin4/RICOold_totalTS.txt", sep=' ', skipinitialspace='True', names=col_names)

files = [RICOnew, india, gomex, RICOold]

df = pd.concat(files, ignore_index=True)
lessthan99 = df[df['total'] > 1362944]
Ae1 = lessthan99[lessthan99['Ae'] != 1]
Ae0 = Ae1[Ae1['Ae'] != 0]
Ae0 = Ae0.reset_index(drop=True)
print(Ae0)

Ae0.to_csv('/data/keeling/a/mdevera2/allie_MISR_code/TrainingSet_JPL_new_thresh_newbin4.csv')