!AUTHOR: Alexandra Jones
!
!This code develops the training set used for the reimplimentation of
!Larry's 1997 pattern recognition technique for improving cloud fraction
! This particular version creates the training set of RCCM data
! will not work propoerly near poles or anywhere offset between blocks is positive
!
!Spring 2009
!------------------------

program masktraining
implicit none
character(len=150)                        :: RCCMfilename,  countsfilename
integer(4)                                :: nline, ncol, ierr,RCCMcol, RCCMrow,i, lines, block, subblock_col, subblock_row, total, cloudy, RCCMstart, graylevels, glitterflag
integer(1), allocatable, dimension(:,:)   :: mask, subblock, submask
real(8), allocatable, dimension(:,:)      :: HGLCM, VGLCM
integer(4)                                :: tallycld, tallyclr,ints,orbit, date, time
integer(2)                                ::subblock_height
real(8)                                   :: At, Ae, Aedge, A17, Ione,VAR,MEAN,ENT
integer(4), dimension(1:179)              :: offset_array
integer(4)                                :: blocknum1, blocknum2, blocknum, offset

!=======================================
!    Input the files
!======================================
!-------read from .in file-----------
print*, "input the RCCM filename followed by the counts file, the dimensions of the MISR file (cols then rows), the starting adn ending blocks of the RCCMfile,  and finally the number of lines in the counts file: "
read(*,'(1A)') RCCMfilename
read(*,'(1A)') countsfilename
read(*,'(I4)') RCCMcol
read(*,'(I4)') RCCMrow
read(*,'(I4)') RCCMstart
read(*,'(I4)') lines
read(*,'(I)') orbit
read(*,'(I)') date
read(*,'(I)') time
read(*,'(I3)') blocknum1
read(*,'(I3)') blocknum2

!======================================
!  Read in files
!======================================
open(10, file=trim(RCCMfilename), action='read', form='binary', &
      access='direct', recl=RCCMcol*RCCMrow*1)
RCCMfilename=TRIM(RCCMfilename)
allocate(mask(1:RCCMcol,1:RCCMrow), stat=ierr)
!IF(allocated(mask))PRINT*, "allocated mask"
read(10,rec=1) mask
close(10)

open(40, file='/data/keeling/a/mdevera2/allie_MISR_code/offset.txt')
Do i=1,179
     read (40, FMT=104) (offset_array(i))
    104 FORMAT (I4)
END DO
close(40)

open(20, file=trim(countsfilename))
open(90, file='RCCMbin.txt')

!IF (blocknum2 - blocknum1 .eq. 0) THEN
!     blocknum = blocknum1
!else
!     blocknum = blocknum2
!END IF


DO i=1, lines
     read(20, '(5I12)') block, subblock_col, subblock_row, total, cloudy
At=cloudy*1.0/total
If(At==0)THEN
     CYCLE
END IF 
PRINT*, RCCMstart, block, RCCMrow, RCCMcol, subblock_col, subblock_row, total, cloudy

allocate(subblock(1:18,1:18))

IF (blocknum2 - blocknum1 .eq. 0) THEN
     CALL create_subblock(RCCMrow,RCCMcol,subblock_col,subblock_row,RCCMstart,block,offset_array,mask,subblock)
ELSE 
     IF (block==blocknum1) THEN
          offset=offset_array(blocknum1)
          IF (offset > 0)THEN   ! the line/sample values are the same relative to the block- so there is no offset
               offset=0
          END IF
          PRINT*, offset
          CALL create_subblock(RCCMrow,RCCMcol,subblock_col+(offset/16),subblock_row,RCCMstart,block,offset_array,mask,subblock)
     ELSE
          offset=offset_array(blocknum1)
          IF (offset > 0)THEN  ! we want to transform the offset so that we can still use addition to get the proper sample number
               offset=offset * (-1)
          ELSE
               offset=0
          END IF
          PRINT*, offset
          CALL create_subblock(RCCMrow,RCCMcol,subblock_col+(offset/16),subblock_row,RCCMstart,block,offset_array,mask,subblock)
     END IF
END IF
PRINT*, 'subblock'
allocate(submask(1:18,1:18))
CALL relabel_mask(subblock,tallycld, tallyclr,submask)
deallocate(subblock)

PRINT*, 'relabel'

Ae=tallycld*1.0/(tallycld+tallyclr)
IF(Ae==0)THEN
     deallocate(submask)
     CYCLE
END IF
PRINT*, Ae

CALL find_int(submask,ints)
Aedge=(tallycld-ints)*1.0/(tallycld+tallyclr)
A17=(ints*1.0/(tallycld+tallyclr)) + (1+(15/1100)**2) * Aedge/2.0

CALL calc_FirstMoment(submask,Ione)

graylevels=2
allocate(HGLCM(1:graylevels,1:graylevels))
allocate(VGLCM(1:graylevels,1:graylevels))
CALL create_GLCMS(submask,graylevels,HGLCM,VGLCM)

CALL calc_GLDS(HGLCM,VGLCM,graylevels,VAR,MEAN,ENT)

write(90, '( 5I12, 8F12.6, 3I10)') block, subblock_col, subblock_row, cloudy, total, At, A17, Ae, Aedge, Ione, VAR, MEAN, ENT, orbit, date, time

PRINT*, block, subblock_col, subblock_row, cloudy, total, At, A17, Ae, Aedge, Ione, VAR, MEAN, ENT, orbit, date, time
PRINT*, 'done'
deallocate(submask)
deallocate (HGLCM)
deallocate(VGLCM)
END DO
close(20)
close(90)
END PROGRAM masktraining

!============================
!    SUBROUTINES
!============================

SUBROUTINE create_subblock(totalrow,totalcol,subcol,subrow,topblock,focus_block,offsets,input,output)
implicit none
integer(4), intent(in)                                                    :: totalrow, totalcol, subcol, subrow, topblock, focus_block
integer(1), dimension(1:totalcol,1:totalrow), intent(in)                :: input
integer(4), dimension(1:179), intent(in)                                 :: offsets
integer(1), dimension(1:18,1:18), intent(out)                            :: output
integer(4)                                                                :: totaloffset, endcol, endrow



totaloffset=sum(offsets(topblock:(focus_block-1)))
endcol=totalcol-((32-subcol)*16)+totaloffset
endrow=((focus_block-topblock)*128)+(subrow*16)
!PRINT*, totalcol,totalrow,totaloffset, endcol, endrow
output(1:18,1:18)=input(endcol-16:endcol+1,endrow-16:endrow+1)

END SUBROUTINE create_subblock

SUBROUTINE relabel_mask(input1,cloud,clear,output_mask)
implicit none
integer(1), dimension(1:18,1:18), intent(in)                            :: input1
integer(1), dimension(1:18,1:18), intent(out)                           :: output_mask
integer(4),                        intent(out)                           :: cloud, clear
integer(4)                                                               :: I,J


output_mask=0
cloud=0
clear=0

DO j=1, 18
         DO i=1,18
                

                IF (input1(i,j)==1 .or. input1(i,j)==2) THEN 
                    output_mask(i,j)=1
                     IF (i==1 .or. i==18 .or. j==1 .or. j==18)CYCLE 
                    cloud=cloud+1
                ELSE IF (input1(i,j)==3 .or. input1(i,j)==4) THEN 
                    output_mask(i,j)=0
                     IF (i==1 .or. i==18 .or. j==1 .or. j==18)CYCLE
                    clear=clear+1
                ELSE
                    output_mask(i,j)=9
                END IF
         END DO
         
END DO
END SUBROUTINE relabel_mask

SUBROUTINE find_int(input,tallyint)
implicit none
integer(1), dimension(1:18,1:18), intent(in)                            :: input
integer(4),                       intent(out)                            :: tallyint
integer(4)                                                               :: I,J

tallyint=0

DO J=2, 17
         DO I=2, 17
                 IF (input(I,J)==1 .and. input(I-1,J-1)==1 .and.  input(I,J-1)==1 .and.  input(I+1,J-1)==1 .and.  input(I-1,J)==1 .and.  input(I+1,J)==1 .and.  input(I-1,J+1)==1 .and.  input(I,J+1)==1 .and.  input(I+1,J+1)==1)THEN
                           tallyint=tallyint+1
                 END IF
         END DO
END DO
END SUBROUTINE find_int

SUBROUTINE calc_FirstMoment(input,Iout)
implicit none
integer(1),   dimension(1:18,1:18), intent(in)                             :: input
real(8),                                                      intent(out)  :: Iout
integer(4)                                                :: i,j
integer(8)                                                :: Mone,Mzero,Mten,Mtwo,Mtwenty,Uzero
real(8)                                                   :: xbar,ybar,Utwo,Utwenty,Ntwo,Ntwenty

Mzero=0
Mone=0
Mtwo=0
Mten=0
Mtwenty=0

!!!!!!!!!calculate raw moments!!!!!!!!!!!!
DO i=2, 17
         DO j=2, 17
                  Mzero=Mzero+input(i,j)
                  Mone=Mone+(j-1)*input(i,j)
                  Mtwo=Mtwo+input(i,j)*(j-1)**2
                  Mten=Mten+(i-1)*input(i,j)
                  Mtwenty=Mtwenty+input(i,j)*(i-1)**2
         END DO
END DO
xbar=Mten*1.0/Mzero
ybar=Mone*1.0/Mzero

!!!!!!!!!calculate central moments!!!!!!!!
Uzero=Mzero*1.0
Utwo=Mtwo-(ybar*Mone*1.0)
Utwenty=Mtwenty-(xbar*Mten*1.0)

!!!!!!!!calculate scale invariant moments!!!!!
Ntwo=Utwo/(Uzero)**2
Ntwenty=Utwenty/(Uzero)**2

!!!!!!!calculate first moment!!!!!!!
Iout=Ntwo+Ntwenty

END SUBROUTINE calc_FirstMoment

SUBROUTINE create_GLCMS(input,gl,Hout,Vout)
implicit none
integer*4,                                                    intent(in)   :: gl
integer(1),   dimension(1:18,1:18), intent(in)                             :: input
real   (8),   dimension(1:gl,1:gl),                           intent(out)  :: Hout, Vout
integer*4                                                                  :: i,j

Hout=0
Vout=0

DO i=2, 17
          DO j=2,17
                   IF (j/=17)THEN
                        Hout(input(i,j)+1,input(i,j+1)+1)= Hout(input(i,j)+1,input(i,j+1)+1)+1
                   END IF
                   IF (i/=17) THEN
                        Vout(input(i,j)+1,input(i+1,j)+1)= Vout(input(i,j)+1,input(i+1,j)+1)+1
                   END IF
          END DO
END DO

!!!!!!normalize matrices!!!!!!!!
DO i=1, gl
   DO j=1, gl
      Hout(i,j)=Hout(i,j)/((16-1)*16)
      Vout(i,j)=Vout(i,j)/((16-1)*16)
   END DO
END DO

END SUBROUTINE create_GLCMS



SUBROUTINE calc_GLDS(Hin,Vin,gl,VAR,MEAN,ENT)
implicit none
integer*4,                                   intent(in)  :: gl
real(8),               dimension(1:gl,1:gl), intent(in)  :: Hin, Vin
real(8),                                    intent(out)  :: VAR,MEAN,ENT
integer*4                                                :: i,j,n
real(8)                                                  :: HVAR,VVAR,HMEAN,VMEAN,HENT,VENT

HVAR=0.0
HMEAN=0.0
HENT=0.0
VVAR=0.0
VMEAN=0.0
VENT=0.0

DO i=1, gl
   DO j=1, gl
       HVAR=HVAR+(Hin(i,j))**2
       VVAR=VVAR+(Vin(i,j))**2

     IF (Hin(i,j)/=0) THEN
       HENT=HENT+Hin(i,j)*log(Hin(i,j))
     END IF
     IF (Vin(i,j)/=0) THEN
       VENT=VENT+Vin(i,j)*log(Vin(i,j))
     END IF

       n=(i-j)**2
       HMEAN=HMEAN+n*Hin(i,j)
       VMEAN=VMEAN+n*Vin(i,j)
   END DO
END DO

HENT=-1.0*HENT
VENT=-1.0*VENT

VAR=(VVAR+HVAR)/2
MEAN=(VMEAN+HMEAN)/2
ENT=(HENT+VENT)/2
END SUBROUTINE calc_GLDS
