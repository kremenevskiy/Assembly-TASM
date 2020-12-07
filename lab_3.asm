.model small

.stack 9fffh

.data
    minus_entered dw 0h ; variable for store is minus entered

    enter_first_number_msg db 10, 'Enter the first number: ', 10, '$'
    enter_second_number_msg db 10, 'Enter the second number: ', 10, '$'
    ans_msg db 10, 'Answer: ', 10, '$'
    remainder_msg db 'Remainder: ', 10, '$'
    newline db 10, '$'
    zero_exception_msg db 9, 'Division by ZERO EXCEPTION', 10, '$'
    exeption_32768_1 db, 10, 9, 'Cannnot divide -32768 on -1!', 10, 9, 'Reason: 32768 in answer - overflow', 10, '$'
    error_msg db 10, 10, 9, 'ERROR', 10, '$'
    

    new_line db 10, '$'
    first_num dw ?
    second_num dw ?
    answer dw ?
    remainder dw ?
    last_symbol db ?

.code
.386

main PROC
    mov ax, @data
    mov ds, ax


    start:

        ; entering first number
        lea dx, enter_first_number_msg
        call print_str_dx
        call get_number_ax
        mov first_num, ax

        ; entering second number
        lea dx, enter_second_number_msg
        call print_str_dx
        call get_number_ax
        mov second_num, ax

        cmp second_num, 0 ; check 2nd number equal to zero
            je divide_zero_exception


        cmp first_num, -32768 ; handling overflow
            jne skip_overflow_exception
        cmp second_num, -1
            jmp overflow_exception


        skip_overflow_exception:

        ; division first number on second
        mov ax, first_num

        xor dx, dx
        mov bx, second_num
        cwd ; extend ax register to dx register
        idiv bx

        mov answer, ax
        mov remainder, dx

        lea dx, ans_msg
        call print_str_dx

        mov ax, answer
        call print_number_ax
        lea dx, new_line
        call print_str_dx

        lea dx, remainder_msg
        call print_str_dx
        mov ax, remainder
        call print_number_ax

        lea dx, new_line
        call print_str_dx


    return: 
        mov ax, 4c00h
        int 21h

    divide_zero_exception:
        mov ah, 09h
        lea dx, error_msg
        int 21h
        lea dx, zero_exception_msg
        int 21h
        lea dx, new_line
        int 21h

        mov first_num, 0
        mov second_num, 0

        jmp start

    overflow_exception:
        lea dx, error_msg
        call print_str_dx

        lea dx, exeption_32768_1
        call print_str_dx

        mov first_num, 0
        mov second_num, 0
        jmp start
    
main ENDP


get_number_ax PROC 

    push bx
    push cx
    push dx

    mov minus_entered, 0h ; reset minus variable
    xor ax, ax
    xor dx, dx
    xor cx, cx
    xor bx, bx

    get_number:
        mov ah, 08h
        int 21h
        mov last_symbol, al
        jmp proccessing_number

    proccessing_number:
        xor ah, ah

        cmp last_symbol, 13d ; ascii code for 'enter'
            je carriage_return_clicked
        
        cmp last_symbol, 2dh ; ascii code for '-'
            je minus_was_entered
      
        cmp last_symbol, 8d ; ascii code for backspace
            je backspace_clicked


        ; check num for 0-9
        check_1:
            cmp last_symbol, 48d ; compare with 0
                jc not_digit
            cmp last_symbol, 58d ; compare with 9
                jnc not_digit


        check_2:
            cmp dx, 3276d
                je possible_overflow
            jnc get_number  ; dx overflows
      
            jmp input_successful
    
    possible_overflow:
        cmp minus_entered, 2dh
            je possible_overflow_signed ; go if we have signed number

        ; check last sybmol in unsigned number
        cmp last_symbol, 55d ; compare with '7'
            jg get_number

        jmp input_successful


        possible_overflow_signed:
            cmp last_symbol, 56d ; compare with '8'
                jg get_number

            jmp input_successful

    not_digit:
        jmp get_number


    carriage_return_clicked:
        cmp cx, 0
            je get_number
        jmp return_get_number_ax

    backspace_clicked:
        cmp cx, 0
          je check_minus_first

        mov ax, dx
        xor dx, dx
        xor bx, bx
        mov bl, 10d
        div bx
        call remove_symbol
        mov dx, ax
        dec cx
        jmp get_number

        check_minus_first:
            cmp minus_entered, 2dh
                jne get_number

            push ax

            mov ax, 0h
            mov minus_entered, ax ; change store variabe for minus back to 0
            call remove_symbol

            pop ax

            jmp get_number


    minus_was_entered:
        push ax
        push dx
        
        cmp cx, 0 ; quit if minus not first symbol in number
            jne get_number

        mov ax, minus_entered
        cmp ax, 0h
            je minus_entered_1st_time
                   
        pop dx
        pop ax
        jmp get_number

    minus_entered_1st_time:
        
        mov ax, 2dh
        mov minus_entered, ax
        
        mov dl, 2dh
        mov ah, 02h
        int 21h

        pop dx
        pop ax

        jmp get_number
        

    input_successful:
        ; handling condition when entering '0' after '-'
        cmp cx, 0
            jne skip_minus_zero_check
        cmp minus_entered, 2dh
            jne skip_minus_zero_check
        cmp last_symbol, 48d
            je get_number

        ; check first symbol not zero
        skip_minus_zero_check:
        cmp cx, 1
            jne print_num

        check_zero:
            cmp dx, 0
                jne print_num
            jmp get_number


        ; printing last entered symbol
        print_num:
            push dx ; saving dx with number here

            mov dl, last_symbol
            mov ah, 02h
            int 21h

            pop dx

        logic:
            inc cx      
            mov ax, dx
            xor bx, bx
            mov bl, 10d
            mul bx          
            mov dx, ax
            xor ax, ax
            mov al, last_symbol
            sub al, '0'
            add dx, ax
          
            jmp get_number

    
    return_get_number_ax:
        cmp minus_entered, 2dh ; check is number is negative
            jne number_not_negative
    
        neg dx ; invert number from negative
        mov minus_entered, 0h ; reset minus variable

        
        number_not_negative:
            mov ax, dx

        pop dx
        pop cx
        pop bx

        RET
get_number_ax ENDP


remove_symbol PROC C near
    uses ax, bx, cx, dx
  
    mov dl, 8d
    mov ah, 02h
    int 21h

    mov dl, 32
    int 21h

    mov dl, 8d
    int 21h
    
    RET
remove_symbol ENDP


;   print_number_ax number from ax register
print_number_ax PROC C
    uses bx, cx, dx
    
    xor cx, cx
    xor dx, dx

    test ax, 1000000000000000b
    js print_minus

    cycle_ax_not_zero:
        cmp ax, 0
            je ax_equal_zero
        mov bx, 10
        div bx
        push dx
        inc cx
        xor dx, dx
        jmp cycle_ax_not_zero

    ax_equal_zero:
        cmp cx, 0
            jne extracting_from_stack
        
        mov dx, 48 ; if cx = 0, ax = 0
        mov ah, 02h
        int 21h
        jmp return_print


    extracting_from_stack:
        pop dx
        add dx, 48
        mov ah, 02h
        int 21h
        loop extracting_from_stack

    jmp return_print
    
    print_minus:
        push ax
        push dx
        

        mov dx, 002dh ; ascii code for '-'
        mov ah, 02h
        int 21h

        pop dx
        pop ax

        neg ax ; make number positive
        jmp cycle_ax_not_zero

    return_print: 
        RET

print_number_ax ENDP


print_str_dx PROC C
    uses ax, bx, cx, dx
    
    mov ah, 09h
    int 21h

    RET
print_str_dx ENDP


end main
