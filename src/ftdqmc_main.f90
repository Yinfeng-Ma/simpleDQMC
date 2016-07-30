program ftdqmc_main
  use mod_global
  use matrix_tmp
  use ftdqmc_core
  implicit none

  ! local
  integer :: nbc, nsw
  real(dp) :: start_time, end_time, time1, time2

  call cpu_time(start_time)

  open( unit=fout, file='ftdqmc.out', status='unknown' )

  main_obs(:) = czero

  call ftdqmc_initial

  call make_tables
  call sli

  call ftdqmc_initial_print
 
  ! prepare for the DQMC
  call salph
  call inconfc
  call sthop
  


  call allocate_matrix_tmp
  call allocate_core
  call allocate_obs

  max_wrap_error = 0.d0

  call ftdqmc_sweep_start

  write(fout,'(a)') ' ftdqmc_sweep_start done '

  ! warnup
  if( lwarnup ) then
      ! set nwarnup
      nwarnup = ltrot+120
      if(rhub.le.0.d0) nwarnup = 0
      write(fout,'(a,i8)') ' nwarnup = ', nwarnup
      do nsw = 1, nwarnup
          call ftdqmc_sweep(.false.)
      end do
      write(fout,'(a)') ' warmup done '
  end if

  call cpu_time(time1)
  do nbc =  1, nbin

      call obser_init

      do nsw = 1, nsweep

          call ftdqmc_sweep(.true.)

      end do

      call preq  ! output data to bins
      if(ltau) call prtau

      if( nbc .eq. 1 )  then
          call cpu_time(time2)
          n_outconf_pace = nint( dble( 3600 * 12 ) / ( time2-time1 ) )
          if( n_outconf_pace .lt. 1 ) n_outconf_pace = 1
          write(fout,'(a,e16.8,a)') ' time for 1 bin: ', time2-time1, ' s'
          write(fout,'(a,i12)') ' n_out_conf_pace = ', n_outconf_pace
      end if

      if( n_outconf_pace .lt. nbin/3 ) then
          if( mod(nbc,n_outconf_pace) .eq. 0 ) then
              call outconfc
          end if
      else if( mod( nbc, max(nbin/3,1) ) .eq. 0 ) then
          call outconfc
      end if

      write( fout, '(i5,a,i5,a)' ) nbc, '  /', nbin, '   finished '

  end do

  write(fout, '(a,e16.8)') ' max_wrap_error = ', max_wrap_error

  call outconfc

  if(lupdateu)  write(fout,'(a,e16.8)') ' >>> accep_u  = ', dble(main_obs(1))/aimag(main_obs(1))


  call deallocate_core
  call deallocate_matrix_tmp

  call deallocate_tables

  call cpu_time(end_time)
  write(fout,*)
  write(fout,'(a,f10.2,a)') ' >>> Total time spent:', end_time-start_time, 's'
  write(fout,*)
  write(fout,'(a)') ' The simulation done !!! '
  write(fout,*)
  write(fout,'(a)') '        o         o    '
  write(fout,'(a)') '       o o       o o   '
  write(fout,'(a)') '       o o       o o   '
  write(fout,'(a)') '        o         o    '
  write(fout,'(a)') '       o o       o o   '
  write(fout,'(a)') '       o o       o o   '
  write(fout,'(a)') '        o         o    '

  close(fout)

end program ftdqmc_main
