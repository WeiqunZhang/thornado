MODULE InputOutputModuleAMReX

  ! --- AMReX Modules ---

  USE ISO_C_BINDING
  USE amrex_fort_module,      ONLY: &
    AR => amrex_real, &
    amrex_spacedim
  USE amrex_plotfile_module,  ONLY: &
    amrex_write_plotfile
  USE amrex_string_module,    ONLY: &
    amrex_string, &
    amrex_string_build
  USE amrex_box_module,       ONLY: &
    amrex_box
  USE amrex_boxarray_module,  ONLY: &
    amrex_boxarray,       &
    amrex_boxarray_build, &
    amrex_boxarray_destroy
  USE amrex_distromap_module, ONLY: &
    amrex_distromap,       &
    amrex_distromap_build, &
    amrex_distromap_destroy
  USE amrex_multifab_module,  ONLY: &
    amrex_multifab,         &
    amrex_multifab_build,   &
    amrex_multifab_destroy, &
    amrex_mfiter,           &
    amrex_mfiter_build,     &
    amrex_mfiter_destroy
  USE amrex_geometry_module,  ONLY: &
    amrex_geometry,       &
    amrex_geometry_build, &
    amrex_geometry_destroy
  USE amrex_amrcore_module,   ONLY: &
    amrex_get_amrcore, &
    amrex_ref_ratio
  USE amrex_parallel_module,  ONLY: &
    amrex_parallel_ioprocessor

  ! --- thornado Modules ---

  USE ProgramHeaderModule,     ONLY: &
    nDOFX
  USE ReferenceElementModuleX, ONLY: &
    WeightsX_q
  USE GeometryFieldsModule,    ONLY: &
    ShortNamesGF, &
    nGF,          &
    iGF_Phi_N,    &
    iGF_h_1,      &
    iGF_h_2,      &
    iGF_h_3,      &
    iGF_Gm_dd_11, &
    iGF_Gm_dd_22, &
    iGF_Gm_dd_33, &
    iGF_SqrtGm,   &
    iGF_Alpha,    &
    iGF_Beta_1,   &
    iGF_Beta_2,   &
    iGF_Beta_3,   &
    iGF_Psi
  USE FluidFieldsModule,       ONLY: &
    ShortNamesCF, &
    nCF,          &
    iCF_D,        &
    iCF_S1,       &
    iCF_S2,       &
    iCF_S3,       &
    iCF_E,        &
    iCF_Ne,       &
    ShortNamesPF, &
    nPF,          &
    iPF_D,        &
    iPF_V1,       &
    iPF_V2,       &
    iPF_V3,       &
    iPF_E,        &
    iPF_Ne,       &
    ShortNamesAF, &
    nAF,          &
    iAF_P,        &
    iAF_T,        &
    iAF_Ye,       &
    iAF_S,        &
    iAF_E,        &
    iAF_Me,       &
    iAF_Mp,       &
    iAF_Mn,       &
    iAF_Xp,       &
    iAF_Xn,       &
    iAF_Xa,       &
    iAF_Xh,       &
    iAF_Gm,       &
    iAF_Cs,       &
    ShortNamesDF, &
    nDF,          &
    iDF_Sh,       &
    iDF_T1,       &
    iDF_T2,       &
    iDF_T3,       &
    iDF_E
  USE UnitsModule,             ONLY: &
    Joule,  &
    Kelvin, &
    UnitsDisplay

  ! --- Local Modules ---
  USE MyAmrModule,        ONLY: &
    nLevels,          &
    MaxGridSizeX,     &
    PlotFileBaseName, &
    nX
  USE MyAmrDataModule,    ONLY: &
    MF_uGF, &
    MF_uCF, &
    MF_uPF, &
    MF_uAF, &
    MF_uDF
  USE MF_UtilitiesModule, ONLY: &
    AMReX2thornado, &
    ShowVariableFromMultiFab

  IMPLICIT NONE
  PRIVATE

  REAL(AR), PARAMETER :: One = 1.0_AR

  PUBLIC :: ReadCheckpointFile
  PUBLIC :: WriteFieldsAMReX_Checkpoint
  PUBLIC :: WriteFieldsAMReX_PlotFile

  INTERFACE

    SUBROUTINE WriteFieldsAMReX_Checkpoint &
                 ( StepNo, nLevels, dt, time, t_wrt, pBA, &
                   pMF_uGF, pMF_uCF ) BIND(c)
       IMPORT
       IMPLICIT NONE
       INTEGER(c_int), INTENT(in) :: StepNo(*)
       INTEGER(c_int), VALUE      :: nLevels
       REAL(AR),       INTENT(in) :: dt(*), time(*), t_wrt
       TYPE(c_ptr),    INTENT(in) :: pBA(*)
       TYPE(c_ptr),    INTENT(in) :: pMF_uGF(*)
       TYPE(c_ptr),    INTENT(in) :: pMF_uCF(*)
    END SUBROUTINE WriteFieldsAMReX_Checkpoint

    SUBROUTINE ReadHeaderAndBoxArrayData &
                 ( FinestLevel, StepNo, dt, time, t_wrt, &
                   pBA, pDM, iChkFile ) BIND(c)
      IMPORT
      IMPLICIT NONE
      INTEGER(c_int), INTENT(out) :: FinestLevel
      INTEGER(c_int), INTENT(out) :: StepNo(*)
      REAL(AR),       INTENT(out) :: dt(*), time(*), t_wrt
      TYPE(c_ptr),    INTENT(out) :: pBA(*), pDM(*)
      INTEGER(c_int), VALUE       :: iChkFile
    END SUBROUTINE ReadHeaderAndBoxArrayData

    SUBROUTINE ReadMultiFabData( FinestLevel, pMF, iMF, iChkFile ) BIND(c)
      IMPORT
      IMPLICIT NONE
      INTEGER(c_int), VALUE       :: FinestLevel
      TYPE(c_ptr),    INTENT(out) :: pMF(*)
      INTEGER(c_int), VALUE       :: iMF
      INTEGER(c_int), VALUE       :: iChkFile
    END SUBROUTINE ReadMultiFabData

    SUBROUTINE amrex_fi_set_boxarray( iLevel, pBA, amrcore ) BIND(c)
      IMPORT
      IMPLICIT NONE
      TYPE(c_ptr),    VALUE :: pBA
      INTEGER(c_int), VALUE :: iLevel
      TYPE(c_ptr),    VALUE :: amrcore
    END SUBROUTINE amrex_fi_set_boxarray

    SUBROUTINE amrex_fi_set_distromap  (lev, pdm, amrcore) BIND(c)
      IMPORT
      IMPLICIT NONE
      TYPE(c_ptr),    VALUE :: pdm
      INTEGER(c_int), VALUE :: lev
      TYPE(c_ptr),    VALUE :: amrcore
    END SUBROUTINE amrex_fi_set_distromap

    SUBROUTINE amrex_fi_clone_boxarray (bao, bai) BIND(c)
      IMPORT
      IMPLICIT NONE
      TYPE(c_ptr)        :: bao
      TYPE(c_ptr), VALUE :: bai
    END SUBROUTINE amrex_fi_clone_boxarray

    SUBROUTINE amrex_fi_set_finest_level (lev, amrcore) BIND(c)
      IMPORT
      IMPLICIT NONE
      INTEGER(c_int), VALUE :: lev
      TYPE(c_ptr),    VALUE :: amrcore
    END SUBROUTINE amrex_fi_set_finest_level

  END INTERFACE


CONTAINS


  SUBROUTINE ReadCheckpointFile( iChkFile )

    USE MyAmrModule

    IMPLICIT NONE

    INTEGER, INTENT(in) :: iChkFile

    INTEGER         :: iLevel, FinestLevel
    TYPE(c_ptr)     :: pBA(0:nLevels-1)
    TYPE(c_ptr)     :: pDM(0:nLevels-1)
    TYPE(c_ptr)     :: pGF(0:nLevels-1)
    TYPE(c_ptr)     :: pCF(0:nLevels-1)
    TYPE(c_ptr)     :: amrcore
    TYPE(amrex_box) :: BX

    amrcore = amrex_get_amrcore()

    BX = amrex_box( [ 1, 1, 1 ], [ nX(1), nX(2), nX(3) ] )

    ALLOCATE( DM  (0:nLevels-1) )
    ALLOCATE( GEOM(0:nLevels-1) )
    ALLOCATE( BA  (0:nLevels-1) )

    DO iLevel = 0, nLevels-1

      CALL amrex_boxarray_build ( BA(iLevel), BX )

      CALL BA(iLevel) % maxSize( MaxGridSizeX )

      CALL amrex_geometry_build( GEOM(iLevel), BX )

      CALL amrex_distromap_build( DM(iLevel), BA(iLevel) )

    END DO

    pBA(0:nLevels-1) = BA(0:nLevels-1) % P
    pDM(0:nLevels-1) = DM(0:nLevels-1) % P

    FinestLevel = nLevels-1

    CALL ReadHeaderAndBoxArrayData &
           ( FinestLevel, StepNo, dt, t, t_wrt, pBA, pDM, iChkFile )

    DO iLevel = 0, nLevels-1

      BA(iLevel) = pBA(iLevel)
      DM(iLevel) = pDM(iLevel)

    END DO

    DO iLevel = 0, nLevels-1

      CALL amrex_fi_set_boxarray ( iLevel, BA(iLevel) % P, amrcore )
      CALL amrex_fi_set_distromap( iLevel, DM(iLevel) % P, amrcore )

    END DO

    DO iLevel = 0, nLevels-1

      CALL amrex_multifab_build &
             ( MF_uGF(iLevel), BA(iLevel), DM(iLevel), nDOFX * nGF, swX(1) )

      CALL amrex_multifab_build &
             ( MF_uCF(iLevel), BA(iLevel), DM(iLevel), nDOFX * nCF, swX(1) )

      CALL amrex_multifab_build &
             ( MF_uPF(iLevel), BA(iLevel), DM(iLevel), nDOFX * nPF, swX(1) )
      CALL MF_uPF(iLevel) % SetVal( 0.0_AR )

      CALL amrex_multifab_build &
             ( MF_uAF(iLevel), BA(iLevel), DM(iLevel), nDOFX * nAF, swX(1) )
      CALL MF_uAF(iLevel) % SetVal( 0.0_AR )

      CALL amrex_multifab_build &
             ( MF_uDF(iLevel), BA(iLevel), DM(iLevel), nDOFX * nDF, swX(1) )
      CALL MF_uDF(iLevel) % SetVal( 0.0_AR )

    END DO

    pGF(0:nLevels-1) = MF_uGF(0:nLevels-1) % P
    pCF(0:nLevels-1) = MF_uCF(0:nLevels-1) % P

    CALL ReadMultiFabData( nLevels-1, pGF, 0, iChkFile )
    CALL ReadMultiFabData( nLevels-1, pCF, 1, iChkFile )

    DO iLevel = 0, nLevels-1

      CALL MF_uGF(iLevel) % Fill_Boundary( GEOM(iLevel) )
      CALL MF_uCF(iLevel) % Fill_Boundary( GEOM(iLevel) )

    END DO

    CALL amrex_fi_set_finest_level( nLevels-1, amrcore )

  END SUBROUTINE ReadCheckpointFile


  SUBROUTINE WriteFieldsAMReX_PlotFile &
    ( Time, StepNo, MF_uGF_Option, MF_uCF_Option, MF_uPF_Option, &
      MF_uAF_Option, MF_uDF_Option )

    REAL(AR),             INTENT(in)           :: Time
    INTEGER,              INTENT(in)           :: StepNo(0:nLevels-1)
    TYPE(amrex_multifab), INTENT(in), OPTIONAL :: MF_uGF_Option(0:nLevels-1)
    TYPE(amrex_multifab), INTENT(in), OPTIONAL :: MF_uCF_Option(0:nLevels-1)
    TYPE(amrex_multifab), INTENT(in), OPTIONAL :: MF_uPF_Option(0:nLevels-1)
    TYPE(amrex_multifab), INTENT(in), OPTIONAL :: MF_uAF_Option(0:nLevels-1)
    TYPE(amrex_multifab), INTENT(in), OPTIONAL :: MF_uDF_Option(0:nLevels-1)

    CHARACTER(08)                   :: NumberString
    CHARACTER(64)                   :: PlotFileName
    LOGICAL                         :: WriteGF
    LOGICAL                         :: WriteFF_C, WriteFF_P, &
                                       WriteFF_A, WriteFF_D
    INTEGER                         :: iComp, iOS, iLevel, nF, iOS_CPP(3)
    TYPE(amrex_mfiter)              :: MFI
    TYPE(amrex_box)                 :: BX
    TYPE(amrex_multifab)            :: MF_PF(0:nLevels-1)
    TYPE(amrex_geometry)            :: GEOM (0:nLevels-1)
    TYPE(amrex_boxarray)            :: BA   (0:nLevels-1)
    TYPE(amrex_distromap)           :: DM   (0:nLevels-1)
    TYPE(amrex_string), ALLOCATABLE :: VarNames(:)

    ! --- Offset for C++ indexing ---
    iOS_CPP = 1
    IF     ( amrex_spacedim .EQ. 1 )THEN
      iOS_CPP(2) = 0
      iOS_CPP(3) = 0
    ELSE IF( amrex_spacedim .EQ. 2 )THEN
      iOS_CPP(3) = 0
    END IF

    BX = amrex_box( [ 0, 0, 0 ], [ nX(1)-1, nX(2)-1, nX(3)-1 ] )

    DO iLevel = 0, nLevels-1
      CALL amrex_boxarray_build( BA(iLevel), BX )
    END DO

    DO iLevel = 0, nLevels-1
      CALL BA(iLevel) % maxSize( MaxGridSizeX )
    END DO

    DO iLevel = 0, nLevels-1
      CALL amrex_geometry_build ( GEOM(iLevel), BX )
      CALL amrex_distromap_build( DM  (iLevel), BA(iLevel) )
    END DO

    nF = 0
    WriteGF   = .FALSE.
    IF( PRESENT( MF_uGF_Option ) )THEN
      WriteGF   = .TRUE.
      nF = nF + nGF
    END IF

    WriteFF_C = .FALSE.
    IF( PRESENT( MF_uCF_Option ) )THEN
      WriteFF_C = .TRUE.
      nF = nF + nCF
    END IF

    WriteFF_P = .FALSE.
    IF( PRESENT( MF_uPF_Option ) )THEN
      WriteFF_P = .TRUE.
      nF = nF + nPF
    END IF

    WriteFF_A = .FALSE.
    IF( PRESENT( MF_uAF_Option ) )THEN
      WriteFF_A = .TRUE.
      nF = nF + nAF
    END IF

    WriteFF_D = .FALSE.
    IF( PRESENT( MF_uDF_Option ) )THEN
      WriteFF_D = .TRUE.
      nF = nF + nDF
    END IF

    IF( amrex_parallel_ioprocessor() )THEN

      WRITE(*,*)
      WRITE(*,'(A6,A,I8.8)') '', 'Writing PlotFile: ', StepNo

    END IF

    IF( nLevels-1 .EQ. 0 )THEN
      WRITE(NumberString,'(I8.8)') StepNo(:)
    ELSE
      WRITE(NumberString,'(I8.8)') StepNo(0)
    END IF

    PlotFileName = TRIM( PlotFileBaseName ) // '_' // NumberString

    ALLOCATE( VarNames(nF) )

    iOS = 0
    IF( WriteGF )THEN
      DO iComp = 1, nGF
        CALL amrex_string_build &
               ( VarNames( iComp + iOS ), TRIM( ShortNamesGF(iComp) ) )
      END DO
      iOS = iOS + nGF
    END IF

    IF( WriteFF_C )THEN
      DO iComp = 1, nCF
        CALL amrex_string_build &
               ( VarNames( iComp + iOS ), TRIM( ShortNamesCF(iComp) ) )
      END DO
      iOS = iOS + nCF
    END IF

    IF( WriteFF_P )THEN
      DO iComp = 1, nPF
        CALL amrex_string_build &
               ( VarNames( iComp + iOS ), TRIM( ShortNamesPF(iComp) ) )
      END DO
      iOS = iOS + nPF
    END IF

    IF( WriteFF_A )THEN
      DO iComp = 1, nAF
        CALL amrex_string_build &
               ( VarNames( iComp + iOS ), TRIM( ShortNamesAF(iComp) ) )
      END DO
      iOS = iOS + nAF
    END IF

    IF( WriteFF_D )THEN
      DO iComp = 1, nDF
        CALL amrex_string_build &
               ( VarNames( iComp + iOS ), TRIM( ShortNamesDF(iComp) ) )
      END DO
      iOS = iOS + nDF
    END IF


    DO iLevel = 0, nLevels-1

      CALL amrex_multifab_build &
             ( MF_PF(iLevel), BA(iLevel), DM(iLevel), nF, 0 )
      CALL MF_PF(iLevel) % setVal( 0.0d0 )

      CALL amrex_mfiter_build( MFI, MF_PF(iLevel), tiling = .TRUE. )

      iOS = 0

      IF( WriteGF   )THEN
        CALL MF_ComputeCellAverage &
          ( nGF, MF_uGF_Option(iLevel), MF_PF(iLevel), iOS, iOS_CPP, 'GF' )
        iOS = iOS + nGF
      END IF

      IF( WriteFF_C )THEN
        CALL MF_ComputeCellAverage &
          ( nCF, MF_uCF_Option(iLevel), MF_PF(iLevel), iOS, iOS_CPP, 'CF' )
        iOS = iOS + nCF
      END IF

      IF( WriteFF_P )THEN
        CALL MF_ComputeCellAverage &
          ( nPF, MF_uPF_Option(iLevel), MF_PF(iLevel), iOS, iOS_CPP, 'PF' )
        iOS = iOS + nPF
      END IF

      IF( WriteFF_A )THEN
        CALL MF_ComputeCellAverage &
          ( nAF, MF_uAF_Option(iLevel), MF_PF(iLevel), iOS, iOS_CPP, 'AF' )
        iOS = iOS + nAF
      END IF

      IF( WriteFF_D )THEN
        CALL MF_ComputeCellAverage &
          ( nDF, MF_uDF_Option(iLevel), MF_PF(iLevel), iOS, iOS_CPP, 'DF' )
        iOS = iOS + nDF
      END IF

    END DO ! End of loop over levels

    CALL amrex_write_plotfile &
           ( PlotFileName, nLevels, MF_PF, VarNames, &
             GEOM, Time / UnitsDisplay % TimeUnit, StepNo, amrex_ref_ratio )

    DO iLevel = 0, nLevels-1
      CALL amrex_multifab_destroy ( MF_PF(iLevel) )
      CALL amrex_distromap_destroy( DM   (iLevel) )
      CALL amrex_geometry_destroy ( GEOM (iLevel) )
      CALL amrex_boxarray_destroy ( BA   (iLevel) )
    END DO

    DEALLOCATE( VarNames )

  END SUBROUTINE WriteFieldsAMReX_PlotFile


  SUBROUTINE MF_ComputeCellAverage( nComp, MF, MF_A, iOS, iOS_CPP, Field )

    INTEGER,              INTENT(in)    :: nComp, iOS, iOS_CPP(3)
    TYPE(amrex_multifab), INTENT(in)    :: MF
    TYPE(amrex_multifab), INTENT(inout) :: MF_A
    CHARACTER(2),         INTENT(in)    :: Field

    INTEGER                       :: iX1, iX2, iX3, iComp
    INTEGER                       :: lo(4), hi(4)
    REAL(AR)                      :: u_K(nDOFX,nComp)
    TYPE(amrex_box)               :: BX
    TYPE(amrex_mfiter)            :: MFI
    REAL(AR), CONTIGUOUS, POINTER :: u  (:,:,:,:)
    REAL(AR), CONTIGUOUS, POINTER :: u_A(:,:,:,:)

    CALL amrex_mfiter_build( MFI, MF, tiling = .TRUE. )

    DO WHILE( MFI % next() )

      u   => MF   % DataPtr( MFI )
      u_A => MF_A % DataPtr( MFI )

      BX = MFI % tilebox()

      lo = LBOUND( u ); hi = UBOUND( u )

      DO iX3 = BX % lo(3), BX % hi(3)
      DO iX2 = BX % lo(2), BX % hi(2)
      DO iX1 = BX % lo(1), BX % hi(1)

        u_K(1:nDOFX,1:nComp) &
          = RESHAPE( u(iX1,iX2,iX3,lo(4):hi(4)), [ nDOFX, nComp ] )

        ! --- Compute cell-average ---
        DO iComp = 1, nComp

          u_A(iX1-iOS_CPP(1),iX2-iOS_CPP(2),iX3-iOS_CPP(3),iComp+iOS) &
            = DOT_PRODUCT( WeightsX_q(:), u_K(:,iComp) )

        END DO

      END DO
      END DO
      END DO

      CALL ConvertUnits( nComp, iOS, u_A, Field )

    END DO

    CALL amrex_mfiter_destroy( MFI )

  END SUBROUTINE MF_ComputeCellAverage


  SUBROUTINE ConvertUnits( nComp, iOS, u_A, Field )

    INTEGER,      INTENT(in)    :: nComp, iOS
    REAL(AR),     INTENT(inout) :: u_A(:,:,:,:)
    CHARACTER(2), INTENT(in)    :: Field

    INTEGER  :: iComp
    REAL(AR) :: unitsGF(nGF), unitsCF(nCF), unitsPF(nPF), &
                unitsAF(nAF), unitsDF(nDF)

    CALL SetUnitsFields( unitsGF, unitsCF, unitsPF, unitsAF, unitsDF )

    IF     ( Field .EQ. 'GF' )THEN

      DO iComp = 1, nComp
        u_A(:,:,:,iComp+iOS) = u_A(:,:,:,iComp+iOS) / unitsGF(iComp)
      END DO

    ELSE IF( Field .EQ. 'CF' )THEN

      DO iComp = 1, nComp
        u_A(:,:,:,iComp+iOS) = u_A(:,:,:,iComp+iOS) / unitsCF(iComp)
      END DO

    ELSE IF( Field .EQ. 'PF' )THEN

      DO iComp = 1, nComp
        u_A(:,:,:,iComp+iOS) = u_A(:,:,:,iComp+iOS) / unitsPF(iComp)
      END DO

    ELSE IF( Field .EQ. 'AF' )THEN

      DO iComp = 1, nComp
        u_A(:,:,:,iComp+iOS) = u_A(:,:,:,iComp+iOS) / unitsAF(iComp)
      END DO

    ELSE IF( Field .EQ. 'DF' )THEN

      DO iComp = 1, nComp
        u_A(:,:,:,iComp+iOS) = u_A(:,:,:,iComp+iOS) / unitsDF(iComp)
      END DO

    ELSE

      RETURN

    END IF

  END SUBROUTINE ConvertUnits


  SUBROUTINE SetUnitsFields( unitsGF, unitsCF, unitsPF, unitsAF, unitsDF )

    REAL(AR), INTENT(out) :: unitsGF(nGF)
    REAL(AR), INTENT(out) :: unitsCF(nCF)
    REAL(AR), INTENT(out) :: unitsPF(nPF)
    REAL(AR), INTENT(out) :: unitsAF(nAF)
    REAL(AR), INTENT(out) :: unitsDF(nDF)

    ! --- Geometry ---

    unitsGF(iGF_Phi_N)    &
      = UnitsDisplay % EnergyDensityUnit / UnitsDisplay % MassDensityUnit
    unitsGF(iGF_h_1)      &
      = One
    unitsGF(iGF_h_2)      &
      = One
    unitsGF(iGF_h_3)      &
      = One
    unitsGF(iGF_Gm_dd_11) &
      = One
    unitsGF(iGF_Gm_dd_22) &
      = One
    unitsGF(iGF_Gm_dd_33) &
      = One
    unitsGF(iGF_SqrtGm)   &
      = One
    unitsGF(iGF_Alpha)    &
      = One
    unitsGF(iGF_Beta_1)   &
      = UnitsDisplay % VelocityUnit
    unitsGF(iGF_Beta_2)   &
      = UnitsDisplay % VelocityUnit
    unitsGF(iGF_Beta_3)   &
      = UnitsDisplay % VelocityUnit
    unitsGF(iGF_Psi)      &
      = One

    ! --- Conserved ---

    unitsCF(iCF_D)  &
      = UnitsDisplay % MassDensityUnit
    unitsCF(iCF_S1) &
      = UnitsDisplay % MomentumDensityUnit
    unitsCF(iCF_S2) &
      = UnitsDisplay % MomentumDensityUnit
    unitsCF(iCF_S3) &
      = UnitsDisplay % MomentumDensityUnit
    unitsCF(iCF_E)  &
      = UnitsDisplay % EnergyDensityUnit
    unitsCF(iCF_Ne) &
      = UnitsDisplay % ParticleDensityUnit

    ! --- Primitive ---

    unitsPF(iPF_D)  &
      = UnitsDisplay % MassDensityUnit
    unitsPF(iPF_V1) &
      = UnitsDisplay % VelocityUnit
    unitsPF(iPF_V2) &
      = UnitsDisplay % VelocityUnit
    unitsPF(iPF_V3) &
      = UnitsDisplay % VelocityUnit
    unitsPF(iPF_E)  &
      = UnitsDisplay % EnergyDensityUnit
    unitsPF(iPF_Ne) &
      = UnitsDisplay % ParticleDensityUnit

    ! --- Auxiliary ---

    unitsAF(iAF_P)  &
      = UnitsDisplay % PressureUnit
    unitsAF(iAF_T)  &
      = UnitsDisplay % TemperatureUnit
    unitsAF(iAF_Ye) &
      = One
    unitsAF(iAF_S)  &
      = Joule / Kelvin
    unitsAF(iAF_E)  &
      = UnitsDisplay % EnergyDensityUnit / UnitsDisplay % MassDensityUnit
    unitsAF(iAF_Me) &
      = UnitsDisplay % EnergyUnit
    unitsAF(iAF_Mp) &
      = UnitsDisplay % EnergyUnit
    unitsAF(iAF_Mn) &
      = UnitsDisplay % EnergyUnit
    unitsAF(iAF_Xp) &
      = One
    unitsAF(iAF_Xn) &
      = One
    unitsAF(iAF_Xa) &
      = One
    unitsAF(iAF_Xh) &
      = One
    unitsAF(iAF_Gm) &
      = One
    unitsAF(iAF_Cs) &
      = UnitsDisplay % VelocityUnit

    ! --- Diagnostic ---

    unitsDF(iDF_Sh) &
      = One
    unitsDF(iDF_T1) &
      = One
    unitsDF(iDF_T2) &
      = One
    unitsDF(iDF_T3) &
      = One
    unitsDF(iDF_E) &
      = UnitsDisplay % EnergyDensityUnit / UnitsDisplay % MassDensityUnit

  END SUBROUTINE SetUnitsFields


END MODULE InputOutputModuleAMReX
