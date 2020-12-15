.model small

.stack 9fffh

.data
s db 103 dup ('$')
length_s dw ?
length_s_2 dw ?
l dw 1

newline db 10, 13, '$'


.code 

main PROC
    mov ax, @data
    mov ds, ax
    mov es, ax ; copy data segment to es

    xor cx, cx ; setting cx for counting length of s
    mov di, offset s
    cld
    cycle_get_char: ; read symbol and move it do variable s

        mov ah, 01h
        int 21h
        cmp al, 13
            je end_cycle_get_char
        cmp al, 10
            je end_cycle_get_char
        
        STOSB
        inc cx
        jmp cycle_get_char
    

    end_cycle_get_char:

        mov length_s, cx ; save length of s

        ; move s from es to ds
        mov di, offset s
        mov si, offset s

        copy:
            mov dl, [di]
            cmp dl, '$'
                je algorithm ; start doing logical task
            mov [si], dl
            inc si
            inc di
            jmp copy


    algorithm: ; algo to find period of s
        

        ; get length/2 to length_s_2
        xor dx, dx
        mov ax, length_s
        mov bx, 2d
        div bx
        mov length_s_2, ax

        mov ax, length_s
   
    start:
        
        mov bx, 1
        mov l, bx

        mov si, offset s

        xor cx, cx ; indicates to the verifiable symbol -> moves to right
        inc cx 
        xor bx, bx ; bx indicates to the period of string 

        mov si, offset s


        main_loop:
            cmp cx, length_s
                je quit
            
            push ax
            mov ax, l
            cmp ax, length_s_2
                pop ax
                jg expand_l
            
            ; check if length is divided to l (period)
            push ax
            push bx
            push dx

            xor dx, dx 
            mov bx, l
            mov ax, length_s
            div bx

            cmp dx, 0
                pop dx
                pop bx
                pop ax
                xor bx, bx
                je for_loop ; checked

            inc l
            inc cx
            jmp main_loop
            

            for_loop:   
                cmp bx, l
                    jge end_for_loop
                
                mov si, offset s
                add si, bx
                mov dx, [si] ; storing left symbol

                mov si, offset s
                add si, cx
                mov ax, [si] ; stotring right symbol

                cmp al, dl
                    je continue
            

                break:
                    cmp bx, 0
                        je cx_not_overflows

                    sub cx, bx

                    cx_not_overflows:

                    inc cx
                    mov l, cx

                    inc bx
                    jmp end_for_loop
                    

                continue:
                    inc bx
                    inc cx
                    jmp for_loop


            end_for_loop:
                jmp main_loop



        expand_l:
            mov ax, length_s
            mov l, ax
            jmp quit
        

        quit:

            mov ax, l
            call print        

    return_main:
        mov ah, 4ch
        int 21h
main ENDP


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


print_str_dx PROC C
    uses ax, dx
    mov ah, 09h
    int 21h

    RET
print_str_dx ENDP



end main