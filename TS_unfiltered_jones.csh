#! /bin/csh

#SBATCH --job-name=alliets
#SBATCH --mem-per-cpu=40gb
#SBATCH --time=48:00:00
#SBATCH --mail-type=BEGIN ##Specify the type of job execution emails you need like beginning, failing or end of job.
#SBATCH --mail-type=FAIL
#SBATCH --mail-type=END
#SBATCH --mail-user=mdevera2@illinois.edu

foreach countsfile(`/bin/ls /data/gdi/c/mdevera2/ASTER_MISR_allie_new_bin3/RICOold/counts/*_counts.txt`)
	set  IDstring=(`echo $countsfile | cut -d/ -f9- | cut -d_ -f1-5`)
    set  orbit=(`echo $IDstring | cut -d_ -f1`)
    set  date=(`echo $IDstring | cut -d_ -f4| cut -c4-11`)
    set  tt=(`echo $IDstring | cut -d_ -f4 | cut -c12-`)
	echo $date
	echo $orbit
	echo $IDstring
	echo $tt
	
	if (`grep -c ${date}${tt}  /data/gdi/b/atmos-aljones4/pattern_recog_MISR/output/old_4_included_masks.txt` > 0)then
	set  RCCMfilename=(`echo /data/gdi/c/mdevera2/RICOold/*$orbit*.bin`)
	set  lines=(`wc -l $countsfile | cut -d' ' -f1`)
	echo $RCCMfilename

	set  block1=(`cat /data/gdi/c/mdevera2/ASTER_MISR_allie_new_bin3/RICOold/blocks/*$IDstring*.txt | cut -d' ' -f1`)
    set  block2=(`cat /data/gdi/c/mdevera2/ASTER_MISR_allie_new_bin3/RICOold/blocks/*$IDstring*.txt | cut -d' ' -f2`)

	echo $RCCMfilename > RCCMbin.in
	echo $countsfile  >> RCCMbin.in
	echo 656          >> RCCMbin.in
	echo 1280         >> RCCMbin.in
	echo 72           >> RCCMbin.in
	echo $lines       >> RCCMbin.in
	echo $orbit       >> RCCMbin.in
    echo $date        >> RCCMbin.in
    echo $tt          >> RCCMbin.in
	echo $block1      >> RCCMbin.in
    echo $block2      >> RCCMbin.in

	/data/keeling/a/mdevera2/allie_MISR_code/RCCM_bin97_noheight.exe < RCCMbin.in
	cat RCCMbin.txt >> /data/gdi/c/mdevera2/ASTER_MISR_allie_new_bin4/RICOold_totalTS.txt

	mv -f RCCMbin.txt /data/gdi/c/mdevera2/ASTER_MISR_allie_new_bin4/RICOold/training_set/${IDstring}_TS.txt
	endif
end

foreach countsfile(`/bin/ls /data/gdi/c/mdevera2/ASTER_MISR_allie_new_bin3/RICOnew/counts/*_counts.txt`)
	set  IDstring=(`echo $countsfile | cut -d/ -f9- | cut -d_ -f1-5`)
    set  orbit=(`echo $IDstring | cut -d_ -f1`)
    set  date=(`echo $IDstring | cut -d_ -f4| cut -c4-11`)
    set  tt=(`echo $IDstring | cut -d_ -f4 | cut -c12-`)
	echo $date
	echo $orbit
	echo $IDstring
	echo $tt
	
	if (`grep -c ${date}${tt}  /data/gdi/b/atmos-aljones4/pattern_recog_MISR/output/new_4_included_masks.txt` || `grep -ch ${date}${tt}  /data/gdi/b/atmos-aljones4/pattern_recog_MISR/output/new_5_included_masks.txt` || `grep -ch ${date}${tt}  /data/gdi/b/atmos-aljones4/pattern_recog_MISR/output/new_6_included_masks.txt` > 0)then
	set  RCCMfilename=(`echo /data/gdi/b/atmos-aljones4/pattern_recog_MISR/input/binfiles/RICOnew/*$orbit*.bin`)
	set  lines=(`wc -l $countsfile | cut -d' ' -f1`)
	echo $RCCMfilename

	set  block1=(`cat /data/gdi/c/mdevera2/ASTER_MISR_allie_new_bin3/RICOnew/blocks/*$IDstring*.txt | cut -d' ' -f1`)
    set  block2=(`cat /data/gdi/c/mdevera2/ASTER_MISR_allie_new_bin3/RICOnew/blocks/*$IDstring*.txt | cut -d' ' -f2`)

	echo $RCCMfilename > RCCMbin.in
	echo $countsfile  >> RCCMbin.in
	echo 656          >> RCCMbin.in
	echo 1280         >> RCCMbin.in
	echo 74           >> RCCMbin.in
	echo $lines       >> RCCMbin.in
	echo $orbit       >> RCCMbin.in
    echo $date        >> RCCMbin.in
    echo $tt          >> RCCMbin.in
	echo $block1      >> RCCMbin.in
    echo $block2      >> RCCMbin.in

	/data/keeling/a/mdevera2/allie_MISR_code/RCCM_bin97_noheight.exe < RCCMbin.in
	cat RCCMbin.txt >> /data/gdi/c/mdevera2/ASTER_MISR_allie_new_bin4/RICOnew_totalTS.txt

	mv -f RCCMbin.txt /data/gdi/c/mdevera2/ASTER_MISR_allie_new_bin4/RICOnew/training_set/${IDstring}_TS.txt
	endif
end

foreach countsfile(`/bin/ls /data/gdi/c/mdevera2/ASTER_MISR_allie_new_bin3/india/counts/*_counts.txt`)
	set  IDstring=(`echo $countsfile | cut -d/ -f9- | cut -d_ -f1-5`)
    set  orbit=(`echo $IDstring | cut -d_ -f1`)
    set  date=(`echo $IDstring | cut -d_ -f4| cut -c4-11`)
    set  tt=(`echo $IDstring | cut -d_ -f4 | cut -c12-`)
	echo $date
	echo $orbit
	echo $IDstring
	echo $tt
	
	if ( `grep -ch ${date}${tt}  /data/gdi/b/atmos-aljones4/pattern_recog_MISR/output/india_4_included_masks.txt` || `grep -ch ${date}${tt}  /data/gdi/b/atmos-aljones4/pattern_recog_MISR/output/india_5_included_masks.txt`  || `grep -ch ${date}${tt}  /data/gdi/b/atmos-aljones4/pattern_recog_MISR/output/india_6_included_masks.txt`  > 0 )then
	set  RCCMfilename=(`echo /data/gdi/b/atmos-aljones4/pattern_recog_MISR/input/binfiles/india/*$orbit*.bin`)
	set  lines=(`wc -l $countsfile | cut -d' ' -f1`)
	echo $RCCMfilename

	set  block1=(`cat /data/gdi/c/mdevera2/ASTER_MISR_allie_new_bin3/india/blocks/*$IDstring*.txt | cut -d' ' -f1`)
    set  block2=(`cat /data/gdi/c/mdevera2/ASTER_MISR_allie_new_bin3/india/blocks/*$IDstring*.txt | cut -d' ' -f2`)

	echo $RCCMfilename > RCCMbin.in
	echo $countsfile  >> RCCMbin.in
	echo 768          >> RCCMbin.in
	echo 2048         >> RCCMbin.in
	echo 80           >> RCCMbin.in
	echo $lines       >> RCCMbin.in
	echo $orbit       >> RCCMbin.in
    echo $date        >> RCCMbin.in
    echo $tt          >> RCCMbin.in
	echo $block1      >> RCCMbin.in
    echo $block2      >> RCCMbin.in

	/data/keeling/a/mdevera2/allie_MISR_code/RCCM_bin97_noheight.exe < RCCMbin.in
	cat RCCMbin.txt >> /data/gdi/c/mdevera2/ASTER_MISR_allie_new_bin4/india_totalTS.txt

	mv -f RCCMbin.txt /data/gdi/c/mdevera2/ASTER_MISR_allie_new_bin4/india/training_set/${IDstring}_TS.txt
	endif
end

foreach countsfile(`/bin/ls /data/gdi/c/mdevera2/ASTER_MISR_allie_new_bin3/gomex/counts/*_counts.txt`)
	set  IDstring=(`echo $countsfile | cut -d/ -f9- | cut -d_ -f1-5`)
    set  orbit=(`echo $IDstring | cut -d_ -f1`)
    set  date=(`echo $IDstring | cut -d_ -f4| cut -c4-11`)
    set  tt=(`echo $IDstring | cut -d_ -f4 | cut -c12-`)
	echo $date
	echo $orbit
	echo $IDstring
	echo $tt
	
	if (`grep -ch ${date}${tt}  /data/gdi/b/atmos-aljones4/pattern_recog_MISR/output/gomex_4_included_masks.txt` || `grep -ch ${date}${tt}  /data/gdi/b/atmos-aljones4/pattern_recog_MISR/output/gomex_5_included_masks.txt` || `grep -ch ${date}${tt}  /data/gdi/b/atmos-aljones4/pattern_recog_MISR/output/gomex_6_included_masks.txt`> 0)then
	set  RCCMfilename=(`echo /data/gdi/b/atmos-aljones4/pattern_recog_MISR/input/binfiles/gomex/*$orbit*.bin`)
	set  lines=(`wc -l $countsfile | cut -d' ' -f1`)
	echo $RCCMfilename

	set  block1=(`cat /data/gdi/c/mdevera2/ASTER_MISR_allie_new_bin3/gomex/blocks/*$IDstring*.txt | cut -d' ' -f1`)
    set  block2=(`cat /data/gdi/c/mdevera2/ASTER_MISR_allie_new_bin3/gomex/blocks/*$IDstring*.txt | cut -d' ' -f2`)

	echo $RCCMfilename > RCCMbin.in
	echo $countsfile  >> RCCMbin.in
	echo 640          >> RCCMbin.in
	echo 1152         >> RCCMbin.in
	echo 63           >> RCCMbin.in
	echo $lines       >> RCCMbin.in
	echo $orbit       >> RCCMbin.in
    echo $date        >> RCCMbin.in
    echo $tt          >> RCCMbin.in
	echo $block1      >> RCCMbin.in
    echo $block2      >> RCCMbin.in

	/data/keeling/a/mdevera2/allie_MISR_code/RCCM_bin97_noheight.exe < RCCMbin.in
	cat RCCMbin.txt >> /data/gdi/c/mdevera2/ASTER_MISR_allie_new_bin4/gomex_totalTS.txt

	mv -f RCCMbin.txt /data/gdi/c/mdevera2/ASTER_MISR_allie_new_bin4/gomex/training_set/${IDstring}_TS.txt
	endif
end

