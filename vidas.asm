.8086
.model small
.stack 100h

.data
    cartel db "GAMEOVER",  0dh, 0ah,24h
.code

public vidas

vidas proc
; RECIBE CX COMO PARAMETRO QUE SERIA LA CANTIDAD DE VIDAS (CANT DE NAVES A PRINTEAR )
; PARA ESTO TENDRIAMOS QUE USAR UN CONTADOR Q SEA DEC EN LUGAR DE INC, CX ARRANCARIA EN 3 PONELE
; Y CUANDO EL DISPARO/ENEMIGO TOCA A LA NAVE DEC CX Y ASI.
    push ax
    push bx
    push dx


    ; mov ax, 0003h        
    ; int 10h	

    ;mov cx, 3    ; cantidad de naves EN REALIDAD RECIBE CL POR PARAMETRO, ESTO ES DE PRUEBA NOMAS

    cmp cx, 00h
    je gameover

    mov dl, 4fh             ;asigno valor de columna, aca le asigno dos columnas mas de las que en realidad son para poder hacer generalizable el sub 2h

print:
    sub dl, 02h
    call printNave

loop print

    mov dh, 02h
    mov dl, 00h
    call asignoCursor

    mov ah, 09h
    mov al, " "
    mov bh, 0h
    mov bl, 0eh
    mov cx, 01h
    int 10h

    jmp fin

gameover:
    mov ax, 0003h        
    int 10h
	xor	ax,ax
	xor	bx,bx
	xor	dx,dx
	mov	ah,02
	mov	dh,10
	mov	dl,32
	int	10h

    mov ah, 9
    mov dx, offset cartel
    int 21h

    mov ah,08h
    int 21h
    mov ax, 0003h        
    int 10h
    mov ax,4c00h
    int 21h

fin:

    pop dx
    pop bx
    pop ax

    ret
vidas endp



printNave proc 

    push ax             
    push bx
    push cx

    mov dh, 1h               ;asigno valor de fila 
    ;mov dl, 4ch             ;asigno valor de columna
    
    call asignoCursor

    mov ah, 09h             ; imprimo el caracter
    mov al, "|"
    mov bh, 0h
    mov bl, 0eh
    mov cx, 01h
    int 10h 

    dec dl                  ;acomodo parametro

    call asignoCursor

    mov ah, 09h
    mov al, "-"
    mov bh, 0h
    mov bl, 0eh
    mov cx, 01h
    int 10h

    dec dl  
    
    call asignoCursor

    mov ah, 09h
    mov al, "^"
    mov bh, 0h
    mov bl, 0eh
    mov cx, 01h
    int 10h

    dec dl  
    
    call asignoCursor

    mov ah, 09h
    mov al, "-"
    mov bh, 0h
    mov bl, 0eh
    mov cx, 01h
    int 10h

    dec dl  
    
    call asignoCursor

    mov ah, 09h
    mov al, "|"
    mov bh, 0h
    mov bl, 0eh
    mov cx, 01h
    int 10h

    pop cx
    pop bx
    pop ax

ret
printNave endp



asignoCursor proc

;esta funcion recibe parametros por registro (dl y dh) 

    push ax
    push bx
        
    mov ah, 02h
    mov bh, 0h 
    int 10h

    pop bx
    pop ax

ret
asignoCursor endp


end