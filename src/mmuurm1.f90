subroutine mmuurm1(a_up, a_dn, ntau )

! perform exp(-s*alpha_u*Diag(S_tau) * A

  use mod_global
  use matrix_tmp
  implicit none


  !arguments:
  real(dp), dimension(ndim,ndim), intent(inout) :: a_up
  real(dp), dimension(ndim,ndim), intent(inout) :: a_dn
  integer, intent(in) :: ntau

  !local
  integer :: nl, i

  do nl= 1, ndim
     do i = 1, ndim
        a_up(i,nl) =  a_up(i,nl) / xsigma_u_up( nsigl_u(i,ntau))
        a_dn(i,nl) =  a_dn(i,nl) / xsigma_u_dn( nsigl_u(i,ntau))
     enddo
  enddo

end subroutine mmuurm1
