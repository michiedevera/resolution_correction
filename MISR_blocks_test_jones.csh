#! /bin/csh

#SBATCH --job-name=allie_counts
#SBATCH --mem-per-cpu=40gb
#SBATCH --time=48:00:00
#SBATCH --mail-type=BEGIN ##Specify the type of job execution emails you need like beginning, failing or end of job.
#SBATCH --mail-type=FAIL
#SBATCH --mail-type=END
#SBATCH --mail-user=mdevera2@illinois.edu


foreach maskfile(`/bin/ls /data/gdi/c/mdevera2/ASTER_MISR_allie_new_bin4/gomex/masks/*.bin`)
        echo $maskfile
        set  IDstring=(`echo $maskfile | cut -d/ -f9- | cut -d_ -f1-5`)
        echo $IDstring
        set  linefile=(`echo /data/gdi/c/mdevera2/ASTER_MISR_allie_new_bin4/gomex/line/*$IDstring*.bin`)
        echo $linefile
        set  samplefile=(`echo /data/gdi/c/mdevera2/ASTER_MISR_allie_new_bin4/gomex/sample/*$IDstring*.bin`)
        echo $samplefile
        set  block1=(`cat /data/gdi/c/mdevera2/ASTER_MISR_allie_new_bin4/gomex/blocks/*$IDstring*.txt |cut -d' ' -f1`)
        echo $block1
        set block2=(`cat /data/gdi/c/mdevera2/ASTER_MISR_allie_new_bin4/gomex/blocks/*$IDstring*.txt | cut -d' ' -f2`)
        echo $block2
        set orbit=(`echo /data/gdi/c/mdevera2/ASTER_MISR_allie_new_bin4/gomex/blocks/*$IDstring*.txt | cut -d/ -f9- | cut -d_ -f1`)
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
      
        mv -f pixel_count.txt /data/gdi/c/mdevera2/ASTER_MISR_allie_new_bin4/gomex/counts/${orbit}_${IDstring}_counts.txt
        cat total_count.txt >> /data/gdi/c/mdevera2/ASTER_MISR_allie_new_bin4/gomex_counts.txt
end


foreach maskfile(`/bin/ls /data/gdi/c/mdevera2/ASTER_MISR_allie_new_bin4/RICOold/masks/*.bin`)
        echo $maskfile
        set  IDstring=(`echo $maskfile | cut -d/ -f9- | cut -d_ -f1-5`)
        echo $IDstring
        set  linefile=(`echo /data/gdi/c/mdevera2/ASTER_MISR_allie_new_bin4/RICOold/line/*$IDstring*.bin`)
        echo $linefile
        set  samplefile=(`echo /data/gdi/c/mdevera2/ASTER_MISR_allie_new_bin4/RICOold/sample/*$IDstring*.bin`)
        echo $samplefile
        set  block1=(`cat /data/gdi/c/mdevera2/ASTER_MISR_allie_new_bin4/RICOold/blocks/*$IDstring*.txt | cut -d' ' -f1`)
        echo $block1
        set block2=(`cat /data/gdi/c/mdevera2/ASTER_MISR_allie_new_bin4/RICOold/blocks/*$IDstring*.txt | cut -d' ' -f2`)
        echo $block2
        set orbit=(`echo /data/gdi/c/mdevera2/ASTER_MISR_allie_new_bin4/RICOold/blocks/*$IDstring*.txt | cut -d/ -f9- | cut -d_ -f1`)
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
      
        mv -f pixel_count.txt /data/gdi/c/mdevera2/ASTER_MISR_allie_new_bin4/RICOold/counts/${orbit}_${IDstring}_counts.txt
        cat total_count.txt >> /data/gdi/c/mdevera2/ASTER_MISR_allie_new_bin4/RICOold_counts.txt
end

foreach maskfile(`/bin/ls /data/gdi/c/mdevera2/ASTER_MISR_allie_new_bin4/RICOnew/masks/*.bin`)
        echo $maskfile
        set  IDstring=(`echo $maskfile | cut -d/ -f9- | cut -d_ -f1-5`)
        echo $IDstring
        set  linefile=(`echo /data/gdi/c/mdevera2/ASTER_MISR_allie_new_bin4/RICOnew/line/*$IDstring*.bin`)
        echo $linefile
        set  samplefile=(`echo /data/gdi/c/mdevera2/ASTER_MISR_allie_new_bin4/RICOnew/sample/*$IDstring*.bin`)
        echo $samplefile
        set  block1=(`cat /data/gdi/c/mdevera2/ASTER_MISR_allie_new_bin4/RICOnew/blocks/*$IDstring*.txt | cut -d' ' -f1`)
        echo $block1
        set block2=(`cat /data/gdi/c/mdevera2/ASTER_MISR_allie_new_bin4/RICOnew/blocks/*$IDstring*.txt | cut -d' ' -f2`)
        echo $block2
        set orbit=(`echo /data/gdi/c/mdevera2/ASTER_MISR_allie_new_bin4/RICOnew/blocks/*$IDstring*.txt | cut -d/ -f9- | cut -d_ -f1`)
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
      
        mv -f pixel_count.txt /data/gdi/c/mdevera2/ASTER_MISR_allie_new_bin4/RICOnew/counts/${orbit}_${IDstring}_counts.txt
        cat total_count.txt >> /data/gdi/c/mdevera2/ASTER_MISR_allie_new_bin4/RICOnew_counts.txt
end

foreach maskfile(`/bin/ls /data/gdi/c/mdevera2/ASTER_MISR_allie_new_bin4/india/masks/*.bin`)
        echo $maskfile
        set  IDstring=(`echo $maskfile | cut -d/ -f9- | cut -d_ -f1-5`)
        echo $IDstring
        set  linefile=(`echo /data/gdi/c/mdevera2/ASTER_MISR_allie_new_bin4/india/line/*$IDstring*.bin`)
        echo $linefile
        set  samplefile=(`echo /data/gdi/c/mdevera2/ASTER_MISR_allie_new_bin4/india/sample/*$IDstring*.bin`)
        echo $samplefile
        set  block1=(`cat /data/gdi/c/mdevera2/ASTER_MISR_allie_new_bin4/india/blocks/*$IDstring*.txt | cut -d' ' -f1`)
        echo $block1
        set block2=(`cat /data/gdi/c/mdevera2/ASTER_MISR_allie_new_bin4/india/blocks/*$IDstring*.txt | cut -d' ' -f2`)
        echo $block2
        set orbit=(`echo /data/gdi/c/mdevera2/ASTER_MISR_allie_new_bin4/india/blocks/*$IDstring*.txt | cut -d/ -f9- | cut -d_ -f1`)
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
      
        mv -f pixel_count.txt /data/gdi/c/mdevera2/ASTER_MISR_allie_new_bin4/india/counts/${orbit}_${IDstring}_counts.txt
        cat total_count.txt >> /data/gdi/c/mdevera2/ASTER_MISR_allie_new_bin4/india_counts.txt
end