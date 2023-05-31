#! /bin/csh

#SBATCH --job-name=camp2exts
#SBATCH --mem-per-cpu=40gb
#SBATCH --time=48:00:00
#SBATCH --mail-type=BEGIN ##Specify the type of job execution emails you need like beginning, failing or end of job.
#SBATCH --mail-type=FAIL
#SBATCH --mail-type=END
#SBATCH --mail-user=mdevera2@illinois.edu


foreach countsfile(`/bin/ls /data/gdi/c/mdevera2/ASTER_MISR3/counts/good/*_counts.txt`)
	set  IDstring=(`echo $countsfile | cut -d/ -f9- | cut -d_ -f1-5`)
    set  orbit=(`echo $IDstring | cut -d_ -f1`)
    set  date=(`echo $IDstring | cut -d_ -f4| cut -c4-11`)
    set  tt=(`echo $IDstring | cut -d_ -f4 | cut -c12-`)
	echo $date
	echo $orbit
	echo $IDstring
	echo $tt
	
	set  RCCMfilename=(`echo /data/gdi/c/mdevera2/ASTER_MISR3/RCCM_binfiles_70_91/*$orbit*.bin`)
	set  lines=(`wc -l $countsfile | cut -d' ' -f1`)
	echo $RCCMfilename

	set  block1=(`cat /data/gdi/c/mdevera2/ASTER_MISR3/blocks/*$IDstring*.txt | cut -d' ' -f1`)
    set  block2=(`cat /data/gdi/c/mdevera2/ASTER_MISR3/blocks/*$IDstring*.txt | cut -d' ' -f2`)

	echo $RCCMfilename > RCCMbin.in
	echo $countsfile  >> RCCMbin.in
	echo 864          >> RCCMbin.in
	echo 2816         >> RCCMbin.in
	echo 70           >> RCCMbin.in
	echo $lines       >> RCCMbin.in
	echo $orbit       >> RCCMbin.in
    echo $date        >> RCCMbin.in
    echo $tt          >> RCCMbin.in
	echo $block1      >> RCCMbin.in
    echo $block2      >> RCCMbin.in

	/data/keeling/a/mdevera2/allie_MISR_code/RCCM_bin97_noheight.exe < RCCMbin.in
	cat RCCMbin.txt >> /data/gdi/c/mdevera2/ASTER_MISR3/CAMP2Ex_good_totalTS.txt

	mv -f RCCMbin.txt /data/gdi/c/mdevera2/ASTER_MISR3/training_set/good/${IDstring}_TS.txt
	endif
end

foreach countsfile(`/bin/ls /data/gdi/c/mdevera2/ASTER_MISR3/counts/sun_glint/okay/*_counts.txt`)
	set  IDstring=(`echo $countsfile | cut -d/ -f10- | cut -d_ -f1-5`)
    set  orbit=(`echo $IDstring | cut -d_ -f1`)
    set  date=(`echo $IDstring | cut -d_ -f4| cut -c4-11`)
    set  tt=(`echo $IDstring | cut -d_ -f4 | cut -c12-`)
	echo $date
	echo $orbit
	echo $IDstring
	echo $tt
	
	set  RCCMfilename=(`echo /data/gdi/c/mdevera2/ASTER_MISR3/RCCM_binfiles_70_91/*$orbit*.bin`)
	set  lines=(`wc -l $countsfile | cut -d' ' -f1`)
	echo $RCCMfilename

	set  block1=(`cat /data/gdi/c/mdevera2/ASTER_MISR3/blocks/*$IDstring*.txt | cut -d' ' -f1`)
    set  block2=(`cat /data/gdi/c/mdevera2/ASTER_MISR3/blocks/*$IDstring*.txt | cut -d' ' -f2`)

	echo $RCCMfilename > RCCMbin.in
	echo $countsfile  >> RCCMbin.in
	echo 864          >> RCCMbin.in
	echo 2816         >> RCCMbin.in
	echo 70           >> RCCMbin.in
	echo $lines       >> RCCMbin.in
	echo $orbit       >> RCCMbin.in
    echo $date        >> RCCMbin.in
    echo $tt          >> RCCMbin.in
	echo $block1      >> RCCMbin.in
    echo $block2      >> RCCMbin.in

	/data/keeling/a/mdevera2/allie_MISR_code/RCCM_bin97_noheight.exe < RCCMbin.in
	cat RCCMbin.txt >> /data/gdi/c/mdevera2/ASTER_MISR3/CAMP2Ex_sunglint_okay_totalTS.txt

	mv -f RCCMbin.txt /data/gdi/c/mdevera2/ASTER_MISR3/training_set/sun_glint/okay/${IDstring}_TS.txt
	endif
end


	
