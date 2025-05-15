.8086
.model small
.stack 100h

.data
	spritebase		db	"|-^-|",24h	;Sprite cuando el personaje esta quieto
	spriterght		db	"/-^-/",24h	;Sprite cuando el personaje se mueve a la derecha
	spriteleft		db	"\-^-\",24h	;Sprite cuando el personaje se mueve a la izquierda
	spritesmll		db	"|^|",24h	;Sprite cuando el personaje achica su hitbox
	pos_x			db	30			;La posicion donde se encuentra el personaje
	pos_y			db	22			;La posicion donde se encuentra el personaje
	shoot_allow		db	0			;Si vale 1, la nave puede to_shoot
	pos_x_bullet	db	0
	pos_y_bullet	db	0
	exit			db	0			;Si vale 0, no pasa nada, si vale 1 va a cerrar el programa
	times			db	0			;
	current_lives	dw	10			;La cantidad de vidas del personaje
	Vida_Monstruos	db	1,1,1,1,1,1	;La vida de los 6 enemigos
	vict_message	db	"Lo lograste. Ganaste. Felicitaciones",24h
	esc_message		db	"No terminaste. Saliste. Buena suerte",24h
	defeated_enemies db 0

.code
public game
extrn shoot:proc	;Funcion para to_shoot
extrn actshoot:proc
extrn MONSTER1:proc	;Funcion de los enemigos
extrn MONSTER2:proc
extrn MONSTER3:proc
extrn MONSTER4:proc
extrn MONSTER5:proc
extrn MONSTER6:proc
extrn MONSTER7:proc
extrn MONSTER8:proc
extrn MONSTER9:proc
extrn MONSTER10:proc
extrn vidas:proc	;Funcion para la representacion grafica de las vidas
;---------------------------------------------------------------------------------------------------------------------------------------------------------------;
;---------------------------------------------------------------------------------------------------------------------------------------------------------------;
game proc
	mov ax, @data
	mov ds, ax
	call black_screen	;Pone la pantalla en blanco (negro)
	mov	dx, offset spritebase
	call set_cursor	;La posicion en la que va a estar la nave

	game_loop:
		cmp exit, 1					;Salir manualmente del juego
		je to_exit_game
		cmp defeated_enemies, 6		;Si se llega a eliminar a todos los enemigos, se obtiene el final bueno
		je to_victory_screen
		mov ah, 2ch					;Funcion de la interrupcion para sacar el tiempo
		int	21h

		cmp dl, times
		je	game_loop
		mov	times, dl
		call black_screen
		
		mov al,1
		mov ax, current_lives
		mov cx, ax				;La funcion vidas recibe la cantidad de vidas por el cx
		call vidas				;Cuando no haya mas vidas, imprime un mensaje de game over

		xor ch,ch				;Esto de aca es un loop.................................................................;
	recall_monsters:			;Realiza mas llamadas cuando menos enemigos haya para hacer que se muevan mas rapido
		call monsters_set
		inc ch
		cmp ch, defeated_enemies
		jle recall_monsters	;.......................................................................................;
		mov	al,0

	call playable_character
	push dx
	call actshoot
	mov pos_y_bullet, dl
	pop dx

	jmp	game_loop
	to_victory_screen:
		call show_goodend
		jmp	fin
	to_exit_game:
		call show_midend
	fin:
		mov ax,4c00h
	int 21h
game endp
;---------------------------------------------------------------------------------------------------------------------------------------------------------------;
;---------------------------------------------------------------------------------------------------------------------------------------------------------------;

;---------------------------------------------------------------------------------------------------------------------------------------------------------------;
;-------------------------------------------------------Funciones para la nave del jugador----------------------------------------------------------------------;
playable_character proc						;La nave jugable
		call character_controls
		call set_cursor
		cmp	shoot_allow, 1
		je	to_shoot
		jmp	exit_playable_character_body
	to_shoot:
		dec shoot_allow
		mov	al,pos_x
		mov	bl,al				;La funcion shoot necesita que en el bl se encuentre la posicion de la nave
		call	shoot
		mov	al,bl
		mov	pos_x_bullet, al
		exit_playable_character_body:
	ret
playable_character endp


character_controls proc
	mov	ah,01h
	int	16h					;Detecta si se toca una tecla en el teclado
	jz	default				;Si no detecta ninguna tecla, sale de la funcion

	mov	ah,00h
	int	16h					;Lee la tecla que se preciono

	cmp al,'a'				;Comparacion con cada tecla, "a"=Izquierda. "d"=Derecha. "s"=Achicarse. "w"=to_shoot. Esc=Salir del programa
	je left
	cmp al,'d'
	je right
	cmp al,'s'
	je shrink
	cmp al,'w'
	je shooting_action
	cmp al,1bh
	je salir

    default: 						;Si no coincide con ninguna tecla, envia el sprite por default
		mov dx,offset spritebase
    back:
	ret

    left:						;se fija si la nave se encuentra en uno de los bordes de la pantalla y cambia el sprite
		cmp pos_x,5
		je default
		dec pos_x
		mov dx,offset spriteleft
		jmp back

    right:						;se fija si la nave se encuentra en uno de los bordes de la pantalla y cambia el sprite
		cmp	pos_x,70
		je	default
		inc	pos_x
		mov	dx,offset spriterght
		jmp	back

    shrink:						;cambia el sprite nomas
		mov	dx,offset spritesmll
		jmp	back

    shooting_action:
		inc	shoot_allow
		jmp	default

    salir:
		inc	exit
		jmp	default
character_controls endp

set_cursor proc				;Imprime la nave en pantalla segun su posicion
	push ax
	push bx
	push dx

	xor ax, ax
	xor bx, bx
	xor dx, dx				;Pone todos los registros en 0
	mov ah, 02				;Funcion de la int 10h para poner el cursor en cualquier parte de la pantalla
	mov dh, pos_y				;La "Altura" a la que se encuentra la nave, por default, esta fija en la posicion 23
	mov dl, pos_x			;La posicion de la nave en este momento
	int 10h 
	pop dx	 				;Devuelve del stack el dx, donde esta el offset del sprite
	pop bx
	mov ah, 09h				;ah,09h sirve tanto para la int 10h como para la 21h
	mov cx, 05h				;El rango de seleccion (Es el tamaño de las naves)
	mov bx, current_lives	;Escoge un color
	mov bh, 00h
	int 10h 				;La funcion es para darle color a los enemigos
	int 21h 				;Imprime el sprite correspondiente

	pop	ax
	ret
set_cursor endp
;-------------------------------------------------------Funciones para la nave del jugador-----------------------------------------------------------------------;
;----------------------------------------------------------------------------------------------------------------------------------------------------------------;
monsters_set PROC 					;Todos los monstruos/enemigos devuelven su posicion, en el dh se encuentra su posicion en el eje Y y en dl su posicion en el eje x
	mov bx, offset Vida_Monstruos
	push bx
	Monstruo1:
	cmp	Vida_Monstruos[0],0			;Si la vida esta en 0, se salta la llamada de este Enemigo y pasa al siguiente
	je	Monstruo2
	call	MONSTER1				;Se fija si el Enemigo toco al personaje jugable. Usa dh y dl para definir la posicion del enemigo.
	call	is_character_hurt		;El numero que identifica al enemigo dentro de la variable Vida_Monstruos.
	mov	si,0						;Usando las coordenadas del eje x, se fija si la bala toco o no al cuerpo del enemigo. Si lo hizo, se le resta 1 a su vida.
	call	is_enemy_hurt			;Eso se repite con cada enemigo en pantalla

	Monstruo2:
	cmp	Vida_Monstruos[1],0
	je	Monstruo3
	call	MONSTER2
	call	is_character_hurt
	mov	si,1
	call	is_enemy_hurt

	Monstruo3:
	cmp	Vida_Monstruos[2],0
	je	Monstruo4
	call	MONSTER3
	call	is_character_hurt
	mov	si,2
	call	is_enemy_hurt

	Monstruo4:
	cmp	Vida_Monstruos[3],0
	je	Monstruo5
	call	MONSTER4
	call	is_character_hurt
	mov	si,3
	call	is_enemy_hurt

	Monstruo5:
	cmp	Vida_Monstruos[4],0
	je	Monstruo6
	call	MONSTER5
	call	is_character_hurt
	mov	si,4
	call	is_enemy_hurt

	Monstruo6:
	cmp	Vida_Monstruos[5],0
	je	Salir_Monstruos
	call	MONSTER6
	call	is_character_hurt
	mov	si,5
	call	is_enemy_hurt
	Salir_Monstruos:
	call MONSTER7
	call is_character_hurt
	call MONSTER8
	call is_character_hurt
	call MONSTER9
	call is_character_hurt
	call MONSTER10
	call is_character_hurt
	
	pop bx
	RET
monsters_set ENDP
;----------------------------------------------------------------------------------------------------------------------------------------------------------------;
black_screen proc		;Borra todo lo que esta en la pantalla
	mov	ax,0003h
	int	10h
	ret
black_screen endp
;-------------------------------------------------------------Funciones para colisiones--------------------------------------------------------------------------;
is_character_hurt proc
	push dx				;dx incluye las posiciones del enemigo
	push ax				;ax guardara las posiciones del jugable
	mov	ah,pos_y
	mov al,pos_x
	cmp	dh,ah			;Compara las posiciones de ambos dos
	jne	to_is_character_hurt_exit
	add	al,5
	cmp	al,dl			;Compara las posiciones de ambos dos. Para la posicion en X, tiene en cuenta la hitbox completa que ocupa 5 posiciones
	jle	to_is_character_hurt_exit
	sub	al,5
	cmp	al,dl
	jge	to_is_character_hurt_exit

	;Si todas las condiciones se validan, se decrementara una de las vidas del personaje y lo posiciona en x = 30
	dec	current_lives
	mov	al, 30
	mov	pos_x, al
	to_is_character_hurt_exit:
		pop	ax
		pop	dx
	ret
is_character_hurt endp

is_enemy_hurt proc
	push bp
	push ax
	push bx
	push cx
	push dx
	mov	bp, sp
	mov	bx, ss:[bp+4]

	mov ch, pos_y_bullet
	mov cl, pos_x_bullet
	cmp ch, dh
	jne to_is_enemy_hurt_exit

	sub dl, 2
	cmp cl, dl
	jl to_is_enemy_hurt_exit
	add dl, 5
	cmp cl, dl
	jae	to_is_enemy_hurt_exit
	;Si llega aca, se le baja la vida e incrementa el numero de enemigos eliminados
	dec	BYTE PTR [BX][si]
	inc defeated_enemies
	to_is_enemy_hurt_exit:
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	pop	bp
	RET
is_enemy_hurt endp
;-------------------------------------------------------------Mensajes para cuando acaba el juego----------------------------------------------------------------;
show_goodend proc
	mov	ax,0003h
	int	10h
	xor	ax,ax
	xor	bx,bx
	xor	dx,dx
	mov	ah,02
	mov	dh,10
	mov	dl,20
	int	10h

	mov	ah,09h
	mov	dx,offset vict_message
	int	21h

	mov	ah,08h
	int	21h
	RET
show_goodend endp

show_midend proc
	mov	ax,0003h
	int	10h
	xor	ax,ax
	xor	bx,bx
	xor	dx,dx
	mov	ah,02
	mov	dh,10
	mov	dl,20
	int	10h

	mov	ah,09h
	mov	dx,offset esc_message
	int	21h

	mov	ah,08h
	int	21h
	RET
show_midend endp

end