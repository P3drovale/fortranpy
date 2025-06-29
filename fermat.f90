program potencia
    implicit none
    integer :: n, total, x, y, z

    read(*,*) n
    total = 3

    do while (.true.)  
        do x = 1, total - 2
            do y = 1, total - x - 1
                z = total - x - y
                if (exp(x, n) + exp(y, n) == exp(z, n)) then
                    print *, "hola, mundo"
                end if
            end do
        end do
        total = total + 1
        
        if (total > 100) exit 
    end do
end program potencia

function exp(i, n) result(ans)
    implicit none
    integer, intent(in) :: i, n
    integer :: ans, j

    ans = 1
    do j = 1, n
        ans = ans * i
    end do
end function exp
