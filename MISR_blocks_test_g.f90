!----------------------------------------------------
! AUTHOR: Alexandra Jones
! Spring 2009
! This code takes in ASTER mask file, corresponding line
! and sample files and the associated block numbers
! It outputs a file identifying ASTER filename, block #,
! sub-block position, total # of ASTER pixels in that
! sub-block and cloudy pixels in the sub-block.
!----------------------------------------------------

program pixel_count
!=====================================
!    GLOBAL VARIABLES
!=====================================
implicit none
character(len=150)                        :: maskfilename, samplefilename, linefilename
integer(4)                                :: nline, ncol, i, j, ierr, x, y, k
integer(4), allocatable, dimension(:,:)   :: block1_total, block2_total, block1_cloudy, block2_cloudy
integer(4)                                :: blocknum1, blocknum2, offset
integer(4), dimension(1:179)              :: offset_array
integer(8), allocatable, dimension(:,:)   :: mask
integer(8), allocatable, dimension(:,:)   :: sample, line



!nline=4915
!ncol=5569
!======================================
!    Input the files
!======================================
!--------read from brf.in---
print*, "input the aster mask filename, linefilename, samplefilename, block1 and block2 one at a time pressing enter as you go: "
read(*,'(1A)') maskfilename
read(*,'(1A)') linefilename
read(*,'(1A)') samplefilename
read(*,'(I3)') blocknum1
read(*,'(I3)') blocknum2
read(*,'(I4)') nline
read(*,'(I4)') ncol


!PRINT*, blocknum1, blocknum2
!======================================
!  Read in files
!======================================
!open(10, file=trim(maskfilename), action='read', form='binary', &
!      access='direct', recl=ncol*nline*8)
open(10, file=trim(maskfilename),FORM="UNFORMATTED", STATUS="UNKNOWN", ACTION="READ", ACCESS='STREAM')
print*,trim(maskfilename)
maskfilename=TRIM(maskfilename)
allocate(mask(1:ncol,1:nline), stat=ierr)
!IF(allocated(mask))PRINT*, "allocated mask"
read(10) mask
close(10)
print*, mask(1200,670)
print*, mask(670,1200)

open(20, file=trim(samplefilename), FORM="UNFORMATTED", STATUS="UNKNOWN", ACTION="READ", ACCESS='STREAM')
samplefilename=TRIM(samplefilename)
allocate(sample(1:ncol,1:nline), stat=ierr)
!IF(allocated(sample))PRINT*, "allocated sample"
read(20) sample
close(20)


open(30, file=trim(linefilename), FORM="UNFORMATTED", STATUS="UNKNOWN", ACTION="READ", ACCESS='STREAM')
linefilename=TRIM(linefilename)
allocate(line(1:ncol,1:nline), stat=ierr)
!IF(allocated(line))PRINT*, "allocated line"
read(30) line
close (30)

open(40, file='/data/keeling/a/mdevera2/allie_MISR_code/offset.txt')
Do i=1,179
     read(40, 104) offset_array(i)
     104 FORMAT (I4) 
END DO
close(40)
PRINT*, offset_array(1)

!---------------------------
! Body of Code
!--------------------------
k=0

!If ASTER scene is contained within one MISR block
IF (blocknum2 - blocknum1 .eq. 0) THEN
     offset=0
     allocate(block1_total(1:32,1:8))
     allocate(block1_cloudy(1:32,1:8))
     block1_total=0
     block1_cloudy=0
!     IF(allocated(block1_total) .and. allocated(block1_cloudy))PRINT*, "total and cloudy"
     DO i=1, ncol
            DO j=1, nline
                   IF (mask(i,j) .eq. 0)THEN   ! if pixel is no retieval move on to next pixel. it does not count towards the total number of pixels  
                    CYCLE
                   ELSE IF (mask(i,j)==1 .or. mask(i,j)==2)THEN
                       mask(i,j)=1
                   ELSE
                       mask(i,j)=0
                       k = k + 1
                   END IF

!keep track of how many ASTER pixels fall within each block anf how many of those are cloudy each block is 16x16 pixels
                    x=CEILING(sample(i,j)/16.0)
                    y=CEILING(line(i,j)/16.0)
                    block1_total(x,y)=block1_total(x,y) + 1
                    block1_cloudy(x,y)= block1_cloudy(x,y) + mask(i,j)


!                   CALL POPULATE(mask(i,j),line(i,j),sample(i,j),offset,block1_total,block1_cloudy)
                !    PRINT*, block1_total(CEILING((sample(i,j))/16.0),CEILING(line(i,j)/16.0)), block1_cloudy(CEILING((sample(i,j))/16.0),CEILING(line(i,j)/16.0))
            
            END DO
    END DO
    open (80, file="total_count.txt")
    open (90, file="pixel_count.txt")
    DO i=1,32
         DO j=1,8
               IF (block1_total(i,j) > 1307876)THEN  
!                write(90, '(1A, 5I12)') linefilename, blocknum1, i, j, block1_total(i,j), block1_cloudy(i,j)
                write(90, '(5I12)') blocknum1, i, j, block1_total(i,j), block1_cloudy(i,j)
                write(80, '(I12)') block1_total(i,j)
                print*, blocknum1, i, j, block1_total(i,j), block1_cloudy(i,j)
               END IF
         END DO
    END DO
    close(80)
    close(90)


! If ASTER scene straddles 2 MISR blocks
ELSE
    offset=offset_array(blocknum1)
    allocate(block1_total(1:32,1:8))
    allocate(block1_cloudy(1:32,1:8))
    allocate(block2_total(1:32,1:8))
    allocate(block2_cloudy(1:32,1:8))
    block1_total=0
    block1_cloudy=0
    block2_total=0
    block2_cloudy=0
    print*,'two blocks'
    PRINT*, offset
!    IF(allocated(block1_total) .and. allocated(block1_cloudy) .and. allocated(block2_total) .and. allocated(block2_cloudy))PRINT*, "total12 and cloudy12"
    DO i=1, ncol
           DO j=1, nline
                  IF (mask(i,j) .eq. 0)THEN    ! if pixel is no retieval move on to next pixel  
                    CYCLE
                   ELSE IF (mask(i,j)==1 .or. mask(i,j)==2)THEN
                       mask(i,j)=1
                   ELSE
                       mask(i,j)=0
                       k = k + 1
                   END IF
                  IF (line(i,j) <= 128)THEN  ! it is in the upper block (block1)
                    offset=offset_array(blocknum1)
                       IF (offset > 0)THEN   ! the line/sample values are the same relative to the block- so there is no offset
                            offset=0
                       END IF
!PRINT*, mask(i,j), line(i,j),sample(i,j), i, j, offset

                       x=CEILING((sample(i,j)-offset)/16.0)
                       y=CEILING(line(i,j)/16.0)
                       block1_total(x,y)=block1_total(x,y) + 1
                       block1_cloudy(x,y)= block1_cloudy(x,y) + mask(i,j)
                    
!                       CALL POPULATE(mask(i,j),line(i,j),sample(i,j),offset,block1_total,block1_cloudy)
                     ! PRINT*, block1_total(CEILING((sample(i,j))/16.0),CEILING(line(i,j)/16.0)), block1_cloudy(CEILING((sample(i,j))/16.0),CEILING(line(i,j)/16.0)) 
                  ELSE   ! it is in the lower block (block2)
                       line(i,j)=line(i,j)-128
                       offset=offset_array(blocknum1)
                       IF (offset > 0)THEN  ! we want to transform the offset so that we can still use addition to get the proper sample number
                            offset=offset * (-1)
                       ELSE
                            offset=0
                       END IF
!PRINT*, mask(i,j), line(i,j),sample(i,j), i, j, offset
                       x=CEILING((sample(i,j)-offset)/16.0)
                       y=CEILING(line(i,j)/16.0)
                       block2_total(x,y)=block2_total(x,y) + 1
                       block2_cloudy(x,y)= block2_cloudy(x,y) + mask(i,j)

!                       CALL POPULATE(mask(i,j),line(i,j),sample(i,j),offset,block2_total,block2_cloudy)
                     !  PRINT*, block2_total(CEILING((sample(i,j)+offset)/16.0),CEILING((line(i,j)-128)/16.0)), block2_cloudy(CEILING((sample(i,j)+offset)/16.0),CEILING((line(i,j)-128)/16.0))
                  END IF
           END DO
    END DO

    open (80, file="total_count.txt")
    open (90, file="pixel_count.txt")
    DO i=1,32
           DO j=1,8
                 IF (block1_total(i,j) > 1300000)THEN
                   write(80, '(I12)')  block1_total(i,j)
!                  write(90, '(1A, 5I12)') linefilename, blocknum1, i, j, block1_total(i,j), block1_cloudy(i,j)
                   write(90, '(5I12)') blocknum1, i, j, block1_total(i,j), block1_cloudy(i,j)
                 END IF
                 IF (block2_total(i,j) > 1307876)THEN     
                   write(80, '(I12)')  block2_total(i,j)     
!                  write(90, '(1A, 5I12)') linefilename, blocknum2, i, j, block2_total(i,j), block2_cloudy(i,j)
                   write(90, '(5I12)') blocknum2, i, j, block2_total(i,j), block2_cloudy(i,j)
                 END IF
           END DO
   END DO
   close(80)
   close(90)
END IF  

print*, k



!if (allocated(mask))deallocate(mask)
!if (allocated(sample))deallocate(sample)
!if (allocated(line))deallocate(line)
!if (allocated(block1_total))deallocate(block1_total)
!if (allocated(block2_total))deallocate(block2_total)
!if (allocated(block1_cloudy))deallocate(block1_cloudy)
!if (allocated(block2_cloudy))deallocate(block2_cloudy)

END PROGRAM pixel_count




!-----------------------------
!
! SUBROUTINES
!
!-----------------------------
!SUBROUTINE POPULATE(masked,line,sample,offset,tout,cout)
!implicit none
!integer(1), intent(in)                               :: masked
!integer(1)                                           :: mask1
!integer(4)                                           :: sample1,line1


!integer(4), intent(in)                               :: offset
!integer(4), intent(in)                               :: line, sample
!integer(4),dimension(1:32,1:8), intent(out)          :: tout, cout




!sample1=sample+offset

!IF(line > 128)THEN
!line1=line-128
!END IF


!IF (masked==1 .or. masked==2)THEN
!mask1=1
!ELSE
!mask1=0
!END IF


!tout(CEILING(sample1/16.0),CEILING(line1/16.0))=tout(CEILING(sample1/16.0),CEILING(line1/16.0)) + 1
!cout(CEILING(sample1/16.0),CEILING(line1/16.0))= cout(CEILING(sample1/16.0),CEILING(line1/16.0)) + mask1
!PRINT*, tout(CEILING(sample1/16.0),CEILING(line1/16.0)), cout(CEILING(sample1/16.0),CEILING(line1/16.0))
!END SUBROUTINE POPULATE
