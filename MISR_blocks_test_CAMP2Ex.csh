#! /bin/csh

foreach maskfile(`/bin/ls /data/gdi/c/mdevera2/ASTER_MISR3/masks/good/*.bin`)
        echo $maskfile
        set  IDstring=(`echo $maskfile | cut -d/ -f9- | cut -d_ -f1-5`)
        echo $IDstring
        set  linefile=(`echo /data/gdi/c/mdevera2/ASTER_MISR3/line/*$IDstring*.bin`)
        echo $linefile
        set  samplefile=(`echo /data/gdi/c/mdevera2/ASTER_MISR3/sample/*$IDstring*.bin`)
        echo $samplefile
        set  block1=(`cat /data/gdi/c/mdevera2/ASTER_MISR3/blocks/*$IDstring*.txt | cut -c1-2`)
        echo $block1
        set block2=(`cat /data/gdi/c/mdevera2/ASTER_MISR3/blocks/*$IDstring*.txt | cut -c4-5`)
        echo $block2
        set orbit=(`echo /data/gdi/c/mdevera2/ASTER_MISR3/blocks/*$IDstring*.txt | cut -d/ -f8- | cut -d_ -f1`)
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
      
        mv -f pixel_count.txt /data/gdi/c/mdevera2/ASTER_MISR3/counts/good/${orbit}_${IDstring}_counts.txt
        cat total_count.txt >> /data/gdi/c/mdevera2/ASTER_MISR3/CAMP2Ex_good_counts.txt
end

foreach maskfile(`/bin/ls /data/gdi/c/mdevera2/ASTER_MISR3/masks/sun_glint/okay/*.bin`)
        echo $maskfile
        set  IDstring=(`echo $maskfile | cut -d/ -f10- | cut -d_ -f1-5`)
        echo $IDstring
        set  linefile=(`echo /data/gdi/c/mdevera2/ASTER_MISR3/line/*$IDstring*.bin`)
        echo $linefile
        set  samplefile=(`echo /data/gdi/c/mdevera2/ASTER_MISR3/sample/*$IDstring*.bin`)
        echo $samplefile
        set  block1=(`cat /data/gdi/c/mdevera2/ASTER_MISR3/blocks/*$IDstring*.txt | cut -d' ' -f1`)
        echo $block1
        set block2=(`cat /data/gdi/c/mdevera2/ASTER_MISR3/blocks/*$IDstring*.txt | cut -d' ' -f2`)
        echo $block2
        set orbit=(`echo /data/gdi/c/mdevera2/ASTER_MISR3/blocks/*$IDstring*.txt | cut -d/ -f8- | cut -d_ -f1`)
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
      
        mv -f pixel_count.txt /data/gdi/c/mdevera2/ASTER_MISR3/counts/sun_glint/okay/${orbit}_${IDstring}_counts.txt
        cat total_count.txt >> /data/gdi/c/mdevera2/ASTER_MISR3/CAMP2Ex_sun_glint_okay_counts.txt
end