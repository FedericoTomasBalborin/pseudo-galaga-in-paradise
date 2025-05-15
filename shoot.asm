.8086
.model small
.stack 100h

.data 
    body db "O",24h
    tail db "|",24h
    pos_y db 0
    pos_x db 0
    is_shooting db 0

.code 
    public shoot    ;Es la accion de disparar. Posiciona la bala y setea el flag is_shooting en True
        shoot proc
            mov is_shooting, 1
            mov pos_y, 22
            mov al, bl
            add al, 2
            mov pos_x, al
            ret
        shoot endp

    public actshoot ;Es la accion de movimiento, mientras el flag este en True, la bala se movera
        actshoot proc
            cmp is_shooting, 1
            jne no_shooting

            call set_cursor ; Dibujo la cola donde antes estaba la bala, la cola hace que sea más visible el proyectil en movimiento.
            lea dx, tail
            mov ah, 09h
            int 21h

            dec pos_y        ; Mueve la bala
            cmp pos_y, -1
            je stopShooting
            call set_cursor ; Dibuja la bala
            lea dx, body
            int 21h

            mov dl, pos_y   ;Retorna la posicion Y del proyectil
            mov dh, pos_x
            jmp end_shoot

        stopShooting:
            mov is_shooting, 0
        no_shooting:
        end_shoot:
        actshoot endp

    set_cursor PROC
        push dx							
        push bx
        push ax
        xor ax,ax
        xor bx,bx
        xor dx,dx
        mov ah,02
        mov bh,0h
        mov dh,pos_y
        mov dl,pos_x
        int 10h
        pop ax
        pop bx
        pop dx
        ret
    set_cursor endp

end