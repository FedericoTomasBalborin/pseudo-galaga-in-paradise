.8086
.model small
.stack 100h

.data
    posicion1 dw 20
    posicion2 dw 25,15
    posicion3 dw 15, 5
    posicion4 dw 40

    barra_horizontal_x dw 30                    ;el menu van a ser 2 opciones con una caja para indicar cual es la seleccionada
    barra_horizontal_y dw 1                     ;dibujo las cajas con 2 barras, una vertical y una horizontal, despues las voy a duplicar para hacer el rectangulo
    barra_vertical_y   dw 5
    barra_vertical_x   dw 1

    empezar db "empezar", 24h
    salir db "salir", 24h




.code 
extrn game:proc
    main proc
        mov ax, @data 
        mov ds, ax 

        mov	ax,0003h
    	int	10h		
;..................................................................................................;
        mov ah, 02h                             ;con esto indico la posicion donde poner el cartel
        mov bh, 00h 
        mov dl, 20h
        mov dh, 07h
        int 10h

        xor dx, dx  
        mov ah, 09h
        lea dx, empezar
        int 21h
    
        mov ah, 02h	
        mov bh, 00h 
        mov dl, 20h
        mov dh, 0ah
        int 10h

        mov ah, 09h
        xor dx,dx
        lea dx, salir 
        int 21h    
;..................................................................................................;
        call dibujar_cursor

        cmp dh, 0ah
        je salir_juego

	cmp dh, 07h
	je empezar_juego

        empezar_juego:
	call game

        salir_juego:
	mov ax, 4c00h
	int 21h
    main endp




    dibujar_cursor proc 


        cursor_empezar:
            mov ah, 02h                             ;con esto indico la posicion donde poner el cartel
            mov bh, 00h 
            mov dl, 1eh
            mov dh, 07h

            int 10h
            mov ah, 0ah
            mov bl, 02h
            mov al, 10h
            mov cl, 1
            int 10h

            mov ah, 02h	
            mov dl, 1eh
            mov dh, 0ah
            int 10h

            mov ah, 0ah
            mov bl, 02h
            mov al, 00h
            mov cl, 1
            int 10h

            mov ah, 02h                             
            mov bh, 00h 
            mov dl, 1eh
            mov dh, 07h
            int 10h

            mov ah, 08h
            int 21h
            cmp al, 0dh
            je salir_dibujo
            cmp al, "w"
            je cursor_salir
            cmp al, "s"
            je cursor_salir
            jmp cursor_empezar

        cursor_salir:
            mov ah, 02h 
            mov dl, 1eh
            mov dh, 0ah
            int 10h
            mov ah, 0ah
            mov bl, 02h
            mov al, 10h
            mov cl, 1
            int 10h
            mov ah, 02h                             
            mov dl, 1eh
            mov dh, 07h
            int 10h
            mov ah, 0ah
            mov bl, 02h
            mov al, 00h
            mov cl, 1
            int 10h
            mov ah, 02h	
            mov dl, 1eh
            mov dh, 0ah
            int 10h
            mov ah, 08h
            int 21h
            cmp al, 0dh
            je salir_dibujo
            cmp al, "w"
            je cursor_empezar
            cmp al, "s"
            je cursor_empezar
            jmp cursor_salir

        salir_dibujo:
            ret					;Al retornar, en el dh queda guardada la opcion elegida

    dibujar_cursor endp 

end


