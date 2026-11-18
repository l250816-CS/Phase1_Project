[org 0x0100]

jmp start

fillrect:
push bp
mov bp, sp
push es
push ax
push cx
push dx
push di
mov ax, 0xb800
mov es, ax
mov al, 80
mul byte [bp+12]
add ax, [bp+10]
shl ax, 1
mov di, ax
mov ax, [bp+4]
mov dx, [bp+8]
fr_row:
push di
mov cx, [bp+6]
cld
rep stosw
pop di
add di, 160
dec dx
jnz fr_row
pop di
pop dx
pop cx
pop ax
pop es
pop bp
ret 10

printstr:
push bp
mov bp, sp
push es
push ax
push si
push di
mov ax, 0xb800
mov es, ax
mov al, 80
mul byte [bp+10]
add ax, [bp+8]
shl ax, 1
mov di, ax
mov si, [bp+4]
mov ah, [bp+6]
cld
ps_next:
lodsb
cmp al, 0
je ps_done
stosw
jmp ps_next
ps_done:
pop di
pop si
pop ax
pop es
pop bp
ret 8

drawrects:
dr_next:
cmp si, bx
je dr_done
push word [si]
push word [si+2]
push word [si+4]
push word [si+6]
push word [si+8]
call fillrect
add si, 10
jmp dr_next
dr_done:
ret

drawtexts:
dt_next:
cmp si, bx
je dt_done
push word [si]
push word [si+2]
push word [si+4]
push word [si+6]
call printstr
add si, 8
jmp dt_next
dt_done:
ret

start:
mov ax, 3
int 0x10

mov si, background
mov bx, backgroundend
call drawrects

mov bx, 1
roadloop:
mov dx, bx
add dx, 8
mov si, bx
add si, bx
add si, bx
mov di, 40
sub di, si

push dx
push di
mov ax, 1
push ax
mov ax, si
add ax, ax
inc ax
push ax
mov ax, 0x0020
push ax
call fillrect

push dx
push di
mov ax, 1
push ax
push ax
mov ax, 0x0FDB
push ax
call fillrect

mov ax, 40
add ax, si
push dx
push ax
mov ax, 1
push ax
push ax
mov ax, 0x0FDB
push ax
call fillrect

test bx, 1
jz skipdivider

mov ax, 40
sub ax, bx
push dx
push ax
mov ax, 1
push ax
push ax
mov ax, 0x0FDB
push ax
call fillrect

mov ax, 40
add ax, bx
push dx
push ax
mov ax, 1
push ax
push ax
mov ax, 0x0FDB
push ax
call fillrect

skipdivider:
inc bx
cmp bx, 12
je roaddone
jmp roadloop
roaddone:

mov si, foreground
mov bx, foregroundend
call drawrects

mov si, texts
mov bx, textsend
call drawtexts

mov ah, 0
int 0x16

mov ax, 0x4c00
int 0x21

background:
dw 1, 0, 8, 80, 0x3020
dw 9, 0, 11, 80, 0x2020
backgroundend:

foreground:
dw 0, 6, 1, 20, 0x7020
dw 0, 6, 1, 14, 0x2020
dw 10, 2, 4, 3, 0x7020
dw 14, 2, 4, 3, 0x4020
dw 11, 38, 2, 5, 0x4020
dw 11, 39, 1, 3, 0x3020
dw 14, 50, 3, 6, 0x6020
dw 14, 51, 1, 4, 0x3020
dw 12, 30, 2, 4, 0x1020
dw 12, 31, 1, 2, 0x3020
dw 20, 0, 2, 80, 0x6020
dw 22, 0, 3, 80, 0x0020
dw 22, 34, 3, 12, 0x7020
dw 21, 58, 4, 14, 0x7020
dw 22, 60, 2, 10, 0x0020
dw 23, 60, 1, 10, 0x7020
dw 22, 64, 2, 2, 0x4020
foregroundend:

texts:
dw 0, 1, 0x0F, str_time
dw 0, 34, 0x0E, str_dist
dw 0, 58, 0x0E, str_score
dw 9, 1, 0x2F, str_fuel
dw 22, 37, 0x70, str_speed
dw 23, 36, 0x70, str_kmh
textsend:

str_time: db 'TIME', 0
str_dist: db 'DIST: 0125 M', 0
str_score: db 'SCORE: 0040', 0
str_fuel: db 'FUEL', 0
str_speed: db 'SPEED', 0
str_kmh: db '078 KM/H', 0