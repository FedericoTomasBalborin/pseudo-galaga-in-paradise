.8086
.model small
.stack 100h

.data
	design	db	"<\|/>",24h	;enemy design
	pos_y1	db	5			;for each enemy, I have an y and x saved
	pos_x1	db	10

	pos_y2	db	10
	pos_x2	db	10

	pos_y3	db	15
	pos_x3	db	10

	pos_y4	db	15
	pos_x4	db	1

	pos_y5	db	10
	pos_x5	db	25

	pos_y6	db	5
	pos_x6	db	25

	pos_y7	db	114
	pos_x7	db	31

	pos_y8	db	13
	pos_x8	db	31

	pos_y9	db	13
	pos_x9	db	31

	pos_y10	db	13
	pos_x10	db	31

	flip_1  db 0	;It is the direction towards where it is moving, if it is 0 it'll move to the left, 1 it'll go right.
	flip_2  db 1	;flip_ and down_ are shared between the enemies, so if one flips the others will do so too, making their movements harder
	
	down_1	db 0	;It is a flag that indicates the enemy is moving down.  0 it stays on its current row, if it is 1 it descends a row
	down_2	db 1	;Usually when it flips it'll set the down_ to 0.

.code
PUBLIC	MONSTER1
PUBLIC	MONSTER2
PUBLIC	MONSTER3
PUBLIC	MONSTER4
PUBLIC	MONSTER5
PUBLIC	MONSTER6
PUBLIC	MONSTER7
PUBLIC	MONSTER8
PUBLIC	MONSTER9
PUBLIC	MONSTER10

MONSTER	macro	pos_y,pos_x,flip,Bajar, id		;Una macros generadora de monstruos, no pude hacer que funcionase por stack
	push	ax							;Y por eso se ve con tantos MOVs
	push	bx							;En el AL estaran los pos_x
	push	cx							;En el AH estaran los flip
	push	dx							;En el CL estaran los Bajar
									;En el CH estaran los pos_y
	MOV	AL,pos_x						;En el BX estara  el  offset con el diseño del enemigo
	MOV	AH,flip
	MOV	CL,bajar
	call	Rotar_Monstruo
	MOV	pos_x,AL
	MOV	flip,AH
	MOV	bajar,CL
	
	MOV	CL,BAJAR
	MOV	CH,pos_y
	mov dh, id
	call bajar_Monstruo
	MOV	bajar,CL
	MOV	pos_y,CH
	
	MOV	AL,pos_x
	MOV	AH, flip
	call	Mover_Monstruo
	MOV	pos_x,AL
	MOV	flip, AH

	call	Posicionar_Monstruo

	MOV	DX,OFFSET design
	PUSH	DX
	mov 	bl, id
	call	Colocar_Monstruo
	POP	DX

	pop	dx
	pop	cx
	pop	bx
	pop	ax
endm

;****************************************************************************************************************************************************************;
;**********************************************Las llamadas para Naves Enemigas**********************************************************************************;
MONSTER1 proc
	MONSTER pos_y1,pos_x1, flip_1,down_1,2
	mov	dh,pos_y1
	mov	dl,pos_x1
	add	dl,2
	ret
MONSTER1 endp								;Quitando el ret, hace que se ejecute por adelantado el proc siguiente, lo que hace que se
									;Vuelva mas "rapido" el Enemigo siguiente
MONSTER2 proc
	MONSTER	pos_y2,pos_x2,flip_2,down_2,4
	mov	dh,pos_y2
	mov	dl,pos_x2
	add	dl,2
	ret
MONSTER2 endp

MONSTER3 proc
	MONSTER	pos_y3,pos_x3,flip_2,down_2,4
	mov	dh,pos_y3
	mov	dl,pos_x3
	add	dl,2
	ret
MONSTER3 endp

MONSTER4 proc
	MONSTER	pos_y4,pos_x4,flip_1,down_2,3
	mov	dh,pos_y4
	mov	dl,pos_x4
	add	dl,2
	ret
MONSTER4 endp

MONSTER5 proc
	MONSTER pos_y5,pos_x5,flip_1,down_1,2
	mov	dh,pos_y5
	mov	dl,pos_x5
	add	dl,2
	ret
MONSTER5 endp

MONSTER6 proC
	MONSTER pos_y6,pos_x6,flip_2,down_1,3
	mov	dh,pos_y6
	mov	dl,pos_x6
	add	dl,2
	ret

MONSTER6 endp

MONSTER7 proC
	MONSTER pos_y7,pos_x7,flip_2,down_1,14
	mov	dh,pos_y7
	mov	dl,pos_x7
	add	dl,2
	ret
MONSTER7 endp

MONSTER8 proC
	MONSTER pos_y8,pos_x8,flip_2,down_2,14
	mov	dh,pos_y8
	mov	dl,pos_x8
	add	dl,2
	ret
MONSTER8 endp


MONSTER9 proC
	MONSTER pos_y9,pos_x9,flip_1,down_1,14
	mov	dh,pos_y9
	mov	dl,pos_x9
	add	dl,2
	ret
MONSTER9 endp


MONSTER10 proC
	MONSTER pos_y10,pos_x10,flip_1,down_2,14
	mov	dh,pos_y10
	mov	dl,pos_x10
	add	dl,2
	ret
MONSTER10 endp

;****************************************************************************************************************************************************************;
;*******************************************************Funciones para las naves enemigas************************************************************************;
Rotar_Monstruo	proc
	cmp	al,70					;Se fija si la posicion de la nave es 0 o 70 (Los bordes de la pantalla)
	je 	Rotar1
	cmp	al,1
	je	Rotar2
	Salir_Rotar:
	ret
	Rotar1:
	mov	AH,01					;Si toca un borde, cambia la variable flip para que cambie la direccion de la nave
	mov	CL,1					;Ademas, cambia la variable Bajar
	jmp	SALIR_ROTAR
	Rotar2:
	mov	AH,0
	mov	CL,1
	jmp	SALIR_ROTAR
Rotar_Monstruo endp

bajar_Monstruo proc
	cmp	CL, 1					;Si la variable Bajar es igual a 1 (es decir, reboto con un borde), incrementa una posicion a pos_y
	jne	CAIDA_DIAGONAL_MONSTRUO			;Si no es igual a 1, sale de la funcion
	inc	CH
	mov	CL, 0					;Ademas vuelve a poner bajar en 0
	CAIDA_DIAGONAL_MONSTRUO:
	cmp	ch, dh				;Hace que el pos_x de las naves sea mas erratico
	jle	WARP_MONSTRUO
	mov	CL, 1
	WARP_MONSTRUO:
	cmp	ch, 24					;Si la nave baja demasiado (25 es la posicion del borde inferior de la pantalla) hace un "warp"
	jne	SALIDA_DEFINITIVA			;
	mov	ch, 1					;Y coloca la nave de nuevo en la parte superior de la pantalla
	SALIDA_DEFINITIVA:
	ret
bajar_Monstruo endp

Mover_Monstruo proc
	cmp	AH,1					;Si flip es igual a 1, la nave se movera a la izquierda
	je	Retroceder				;
	inc	AL					;Si no, se movera a la derecha
	SALIR_MOVERMONSTRUO:
	ret
	Retroceder:
	dec	AL
	jmp	SALIR_MOVERMONSTRUO
Mover_Monstruo endp

Posicionar_Monstruo PROC				;Pone el cursor en posicion
	push	ax
	push	bx
	push	dx

	mov	ah,02					;La funcion 02h de int 10h necesita:
	xor	bx,bx					;>El bx en 0
	mov	dh,CH					;>La posicion vertical   en el 	dh
	mov	dl,AL					;>La posicion horizontal en el	dl
	int	10h

	pop dx
	pop bx
	pop ax
	ret
Posicionar_Monstruo endp



Colocar_Monstruo proc
	push  bp
	mov  bp,sp
	push  ax
	push  bx
	push  cx
	push dx

	mov	ah,09h		;ah,09h sirve tanto para la int 10h como para la 21h
	mov	cx,05h		;El rango de seleccion (Es el tamaño de las naves)
	add	bl,0Ah		;La funcion es para darle color a los 
	int	10h

	mov	dx,ss:[bp+4]	;Recibe del stack el offset con el sprite del enemigo
	int	21h		;Lo imprime en pantalla

	pop dx
	pop	cx
	pop	bx
	pop	ax
	pop	bp
	ret
Colocar_Monstruo endp
;*******************************************************Funciones para las naves enemigas***********************************************************************;
;***************************************************************************************************************************************************************;
end