# Pseudo Galaga

Breve descripción
------------------

`pseudo-galaga-in-paradise` es un juego tipo Galaga programado en ensamblador 8086 (sintaxis MASM/TASM). Corre en ambiente DOS y muestra naves jugables y enemigos en pantalla de texto usando las interrupciones BIOS/INT 21h e INT 10h.

Desarrolladores
---------------------------------
* Federico Balborin
* Santino Casasco
* Axel Silva Pazos
* Victoria Baldi

Preparar un entorno con VirtualBox
---------------------------------

- Requisitos en el host: `VirtualBox` instalado y una imagen ISO de FreeDOS (por ejemplo https://www.freedos.org/download/).
- Crear una máquina virtual nueva (tipo "Other/Legacy" o "DOS") con estos ajustes recomendados: 16–64 MB RAM, 1 CPU, modo de vídeo por defecto.
- Adjuntar la ISO de FreeDOS como unidad óptica y arrancar la VM.
- Para copiar los archivos al invitado puede crear una imagen ISO con los archivos del proyecto desde el host y montarla en la VM, o configurar una carpeta compartida si instala Guest Additions compatibles. La forma más sencilla: crear un ISO con los archivos `.asm` y montarlo como CD-ROM en la VM.

Ensamblado y ejecución (en FreeDOS dentro de la VM)
--------------------------------------------------

1. Instale un ensamblador compatible (por ejemplo TASM o MASM) y el linker (`tlink`/`link`) en el entorno DOS.
2. Copie los archivos fuente al sistema DOS (por CD-ROM, floppy o carpeta compartida).
3. Desde el prompt DOS, en el directorio con los `.asm` ejecute (ejemplo con TASM/TLINK):

```
tasm *.asm
tlink *.obj
```

Esto generará el ejecutable (por ejemplo `menu.exe` si `menu.asm` contiene el `main`). Ejecutarlo con:

```
menu
```

Si usa MASM, los comandos equivalentes son `masm` + `link`.

Controles
--------

- `a`: mover nave a la izquierda
- `d`: mover nave a la derecha
- `s`: reducir tamaño del sprite (achicar hitbox)
- `w`: disparar
- `Esc`: salir del juego

Notas técnicas
---------------

- El proyecto está escrito para la arquitectura 8086 y utiliza llamadas a interrupciones BIOS/DOS (INT 10h / INT 21h).
- El ensamblador esperado es compatible con la sintaxis MASM/TASM (directivas `.model`, `.stack`, `proc`/`endp`).
- Para editar o compilar desde un sistema moderno sin VM, considere usar `DOSBox` o herramientas cross-assembler, pero la forma soportada por el código es en un entorno DOS real o emulado.

Archivos principales
-------------------

- `chara.asm`: lógica del personaje jugable, control y loop principal.
- `enemy.asm`: comportamiento y dibujo de enemigos.
- `shoot.asm`: lógica de disparos y proyectiles.
- `menu.asm`: menú principal y entrada al juego.
- `vidas.asm`: representación gráfica de vidas y gestión de game over.