.model small

.data 
a dw 2
b dw 5
c dw 34
d dw 42


.stack 100h

.code
 
 main:

 mov AX, @data
 mov DS, AX

 mov AX, a
 XOR AX, c
 mov BX, b
 OR BX, d

 CMP AX, BX
    JZ equal_1
        mov AX, a
        AND AX, b
        mov BX, a
        ADD BX, c

        CMP AX, BX
            JZ equal_2
                mov AX, a
                add AX, b
                add AX, c
                add AX, d

                JMP back

    equal_1:
        mov AX, a
        AND AX, b
        ADD AX, c
        ADD AX, d
        JMP back
    
            equal_2:
                mov AX, a
                OR AX, b
                OR AX, c
                OR AX, d

                JMP back


 back:
    CALL OutInt

 mov AX, 4c00h
 int 21h

 OutInt PROC
    XOR CX, CX
    mov BX, 10

    lab1:
        XOR DX, DX
        DIV BX
        push dx
        inc cx
        test ax, ax

        jnz lab1
    
    mov ah, 02h

    lab2:
        pop dx
        add dl, '0'
        int 21h

    loop lab2

    ret

OutInt endp
 
 end main