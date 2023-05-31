#! /bin/csh

#SBATCH --job-name=dutta_counts
#SBATCH --mem-per-cpu=40gb
#SBATCH --time=48:00:00
#SBATCH --mail-type=BEGIN ##Specify the type of job execution emails you need like beginning, failing or end of job.
#SBATCH --mail-type=FAIL
#SBATCH --mail-type=END
#SBATCH --mail-user=mdevera2@illinois.edu

foreach i ( `seq 1 6` )
foreach maskfile(`/bin/ls /data/gdi/c/mdevera2/ASTER_MISR_dutta/$i/masks/*.bin`)
        echo $maskfile
        #set  IDstring=(`echo $linefile | cut -d/ -f10- | cut -d_ -f1-2`)
        set  IDstring=(`echo $maskfile | cut -d/ -f9- | cut -d_ -f1-5`)
        echo $IDstring
	#set  hdfstring=(`echo $IDstring | cut -d_ -f2`)
        #echo $hdfstring
        set  linefile=(`echo /data/gdi/c/mdevera2/ASTER_MISR_dutta2/$i/line/*$IDstring*.bin`)
        echo $linefile
        set  samplefile=(`echo /data/gdi/c/mdevera2/ASTER_MISR_dutta2/$i/sample/*$IDstring*.bin`)
        echo $samplefile
        set  block1=(`cat /data/gdi/c/mdevera2/ASTER_MISR_dutta2/$i/blocks/*$IDstring*.txt | cut -d' ' -f1`)
        echo $block1
        set block2=(`cat /data/gdi/c/mdevera2/ASTER_MISR_dutta2/$i/blocks/*$IDstring*.txt | cut -d' ' -f2`)
        echo $block2
        set orbit=(`echo /data/gdi/c/mdevera2/ASTER_MISR_dutta2/$i/blocks/*$IDstring*.txt | cut -d/ -f9- | cut -d_ -f1`)
        echo $orbit
        set nline=(`echo $maskfile | cut -d/ -f9- | cut -d_ -f7`)
        echo $nline
        set ncol=(`echo $maskfile | cut -d/ -f9- | cut -d_ -f8 | cut -d. -f1`)
        echo $ncol

        echo $maskfile > MISR_blocks.in
        echo $linefile >> MISR_blocks.in
        echo $samplefile >> MISR_blocks.in
        echo $block1  >> MISR_blocks.in
        echo $block2  >> MISR_blocks.in
        echo $nline  >> MISR_blocks.in
        echo $ncol  >> MISR_blocks.in

        /data/keeling/a/mdevera2/allie_MISR_code/MISR_blocks_test_g.exe < MISR_blocks.in
      
        mv -f pixel_count.txt /data/gdi/c/mdevera2/ASTER_MISR_dutta2/${i}/counts/${orbit}_${IDstring}_counts.txt
        cat total_count.txt >> /data/gdi/c/mdevera2/ASTER_MISR_dutta2/${i}_counts.txt
end
end