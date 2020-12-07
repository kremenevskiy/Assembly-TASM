.model small
.stack 9fffh

.data 
enter_first_number_msg db 10, 'Enter the first number: ', 10, '$'
enter_second_number_msg db 10, 'Enter the second number: ', 10, '$'
ans_msg db 10, 'Answer: ', 10, '$'
remainder_msg db 'Remainder: ', 10, '$'
newline db 10, '$'

new_line db 10, '$'
first_num dw ?
second_num dw ?
answer dw ?
remainder dw ?
last_symbol db ?

.code
main PROC
    mov ax, @data
    mov ds, ax
    

    ; entering first number
    lea dx, enter_first_number_msg
    call print_str_dx
    call cin
    mov first_num, ax


    ; entering second number
    lea dx, enter_second_number_msg
    call print_str_dx
    call cin
    mov second_num, ax


    ; division first number on second
    mov ax, first_num

    xor dx, dx
    div second_num

    mov answer, ax
    mov remainder, dx

    lea dx, ans_msg
    call print_str_dx

    mov ax, answer
    call print
    lea dx, new_line
    call print_str_dx

    lea dx, remainder_msg
    call print_str_dx
    mov ax, remainder
    call print

    lea dx, new_line
    call print_str_dx

    mov ah, 4ch
    int 21h

    RET
  
main ENDP


; print number from ax register
print PROC

    push ax
    push bx
    push cx
    push dx

    
    
    xor cx, cx
    xor dx, dx

  try_until_not_zero:

    cmp ax, 0
      je equal_zero
    mov bx, 10
    div bx
    push dx
    inc cx

    xor dx, dx
    jmp try_until_not_zero  

  equal_zero:
    cmp cx, 0
    jne extracting_from_stack
      ;print zero
      mov dx, 48
      mov ah, 02h
      int 21h
      
    je exit


   extracting_from_stack:
    pop dx
    add dx, 48
    mov ah, 02h
    int 21h
    loop extracting_from_stack

  exit: 
    pop dx
    pop cx
    pop bx
    pop ax

    RET
print ENDP

; get number and save it in AX register
cin PROC 

    push bx
    push cx
    push dx

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

      cmp last_symbol, 13d
        je stop_entering
      
      cmp last_symbol, 8d
        je backspace_clicked

      ; check num_boundaries 0-9
      cmp last_symbol, 48d
        jc not_number
      cmp last_symbol, 58d
        jnc not_number

       cmp dx, 6553d
        je possible_overflow
       jnc get_number  ; dx overflows
      

      jmp input_successful
      

    not_number:
      jmp get_number


    backspace_clicked:
            cmp cx, 0
              je get_number

            mov ax, dx
            xor dx, dx
            xor bx, bx
            mov bl, 10d
            div bx
            call remove_symbol
            mov dx, ax
            dec cx
            jmp get_number
        


     

    input_successful:
          
          ; check first symbol not zero
          cmp cx, 0
            jne print_num


        check_first_symbol:
            cmp last_symbol, 48d
              je get_number
        
          
       
            


          ; printing last entered symbol
        print_num:
            push dx ; saving dx, because we save number here

            mov dl, last_symbol
            mov ah, 02h
            int 21h

            pop dx


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


    possible_overflow:
      cmp last_symbol, 53d ; compare with 5
        jg get_number

      jmp input_successful


    stop_entering:
    mov ax, dx

    pop dx
    pop cx
    pop bx

    RET
cin ENDP


print_str_dx PROC
    push ax
    push bx
    push cx
    push dx

    mov ah, 09h
    int 21h

    pop dx
    pop cx
    pop bx
    pop ax

    RET
print_str_dx ENDP

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

 end main