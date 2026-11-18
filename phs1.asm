[org 0x0100]

jmp start

fillrect:
push bp
mov bp, sp
push es
push ax
push bx
push cx
push dx
push di
mov ax, 0xa000
mov es, ax
mov ax, [bp+10]
mov bx, 320
mul bx
add ax, [bp+12]
mov di, ax
mov al, [bp+4]
mov dx, [bp+6]
fr_row:
push di
mov cx, [bp+8]
cld
rep stosb
pop di
add di, 320
dec dx
jnz fr_row
pop di
pop dx
pop cx
pop bx
pop ax
pop es
pop bp
ret 10

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
mov si, texts
dt_next:
cmp si, textsend
je dt_done
mov dh, [si]
mov dl, [si+2]
mov bl, [si+4]
mov bp, [si+6]
mov cx, [si+8]
push si
push es
push ds
pop es
mov ax, 0x1301
mov bh, 0
int 0x10
pop es
pop si
add si, 10
jmp dt_next
dt_done:
ret

road:
mov word [row], 85
road_next:
mov ax, [row]
sub ax, 85
mov [dy], ax
mov bx, 43
mul bx
mov cl, 5
shr ax, cl
mov bx, 139
sub bx, ax
mov [lx], bx
mov ax, 321
sub ax, bx
mov [rx], ax
mov ax, [dy]
mov cl, 5
shr ax, cl
add ax, 2
mov [t], ax
mov ax, [rx]
sub ax, [lx]
mov [w], ax

push word [lx]
push word [row]
push word [w]
mov ax, 1
push ax
mov ax, 25
push ax
call fillrect

push word [lx]
push word [row]
push word [t]
mov ax, 1
push ax
mov ax, 15
push ax
call fillrect

mov ax, [rx]
sub ax, [t]
push ax
push word [row]
push word [t]
mov ax, 1
push ax
mov ax, 15
push ax
call fillrect

mov si, dashes
dash_chk:
cmp si, dashesend
je road_skip
mov ax, [dy]
cmp ax, [si]
jb dash_next
cmp ax, [si+2]
ja dash_next
jmp dash_draw
dash_next:
add si, 4
jmp dash_chk

dash_draw:
mov ax, [w]
mov bx, 21
mul bx
mov cl, 6
shr ax, cl
add ax, [lx]
push ax
push word [row]
mov ax, [t]
dec ax
push ax
mov ax, 1
push ax
mov ax, 15
push ax
call fillrect

mov ax, [w]
mov bx, 43
mul bx
mov cl, 6
shr ax, cl
add ax, [lx]
push ax
push word [row]
mov ax, [t]
dec ax
push ax
mov ax, 1
push ax
mov ax, 15
push ax
call fillrect

road_skip:
inc word [row]
cmp word [row], 177
jne road_next
ret

bonnet:
xor bx, bx
bon_next:
mov ax, bx
cmp ax, 170
jae bon_pos
mov ax, 170
sub ax, bx
jmp bon_sq
bon_pos:
sub ax, 170
bon_sq:
mul ax
mov cl, 11
shr ax, cl
add ax, 149
mov si, ax
mov dx, si
mov ax, si
push dx
mov dx, 320
mul dx
pop dx
add ax, bx
mov di, ax
bon_col:
mov al, 42
mov cx, si
add cx, 2
cmp dx, cx
jae bon_nohl
mov al, 43
bon_nohl:
cmp dx, 173
jb bon_nosh
mov al, 6
bon_nosh:
mov [es:di], al
add di, 320
inc dx
cmp dx, 177
jne bon_col
inc bx
cmp bx, 320
jne bon_next
ret

wheel:
mov word [row], 120
wh_row:
mov bx, 257
wh_col:
mov ax, bx
cmp ax, 298
jae wh_a
mov ax, 298
sub ax, bx
jmp wh_b
wh_a:
sub ax, 298
wh_b:
mul ax
mov cx, ax
mov ax, [row]
cmp ax, 161
jae wh_c
mov ax, 161
sub ax, [row]
jmp wh_d
wh_c:
sub ax, 161
wh_d:
mul ax
add cx, ax
cmp cx, 1681
ja wh_skip
mov ax, [row]
mov dx, 320
mul dx
add ax, bx
mov di, ax
cmp cx, 1089
jae wh_black
cmp cx, 961
jae wh_rim
cmp cx, 144
ja wh_skip
cmp cx, 64
jbe wh_hub1
mov al, 8
jmp wh_put
wh_hub1:
mov al, 7
jmp wh_put
wh_rim:
mov al, 8
jmp wh_put
wh_black:
mov al, 0
wh_put:
mov [es:di], al
wh_skip:
inc bx
cmp bx, 320
jne wh_col
inc word [row]
cmp word [row], 200
jne wh_row
ret

start:
mov ax, 0x0013
int 0x10
mov ax, 0xa000
mov es, ax

mov si, shapes1
mov bx, shapes1end
call drawrects

call road

mov si, shapes2
mov bx, shapes2end
call drawrects

call bonnet

mov si, shapes3
mov bx, shapes3end
call drawrects

call wheel
call drawtexts

mov ah, 0
int 0x16

mov ax, 0x0003
int 0x10
mov ax, 0x4c00
int 0x21

shapes1:
dw 0, 0, 320, 85, 77
dw 0, 85, 320, 92, 2
dw 10, 20, 4, 1, 0
dw 9, 21, 6, 56, 0
dw 9, 77, 6, 63, 41
dw 10, 140, 4, 1, 41
shapes1end:

shapes2:
dw 127, 116, 33, 3, 20
dw 133, 95, 15, 2, 9
dw 135, 97, 19, 5, 1
dw 138, 98, 7, 1, 8
dw 129, 102, 29, 10, 9
dw 130, 112, 27, 3, 1
dw 139, 107, 10, 4, 15
dw 131, 104, 6, 4, 12
dw 151, 104, 6, 4, 12
dw 132, 105, 3, 1, 14
dw 152, 105, 3, 1, 14
dw 131, 114, 6, 3, 0
dw 152, 114, 6, 3, 0
dw 174, 102, 15, 1, 20
dw 177, 90, 9, 1, 3
dw 176, 91, 11, 3, 17
dw 173, 94, 17, 5, 3
dw 174, 95, 3, 2, 12
dw 186, 95, 3, 2, 12
dw 174, 99, 15, 1, 8
dw 174, 100, 3, 2, 0
dw 186, 100, 3, 2, 0
shapes2end:

shapes3:
dw 0, 177, 320, 23, 17
dw 0, 177, 320, 1, 19
dw 100, 179, 54, 2, 15
dw 98, 181, 58, 19, 15
dw 102, 181, 50, 2, 0
dw 100, 183, 54, 16, 0
dw 111, 183, 8, 2, 14
dw 111, 190, 8, 2, 14
dw 111, 183, 2, 5, 14
dw 111, 187, 2, 5, 14
dw 117, 183, 2, 5, 14
dw 117, 187, 2, 5, 14
dw 123, 183, 8, 2, 14
dw 129, 183, 2, 5, 14
dw 129, 187, 2, 5, 14
dw 135, 183, 8, 2, 14
dw 135, 186, 8, 2, 14
dw 135, 190, 8, 2, 14
dw 135, 183, 2, 5, 14
dw 135, 187, 2, 5, 14
dw 141, 183, 2, 5, 14
dw 141, 187, 2, 5, 14
dw 173, 184, 60, 8, 15
dw 175, 186, 56, 4, 0
dw 175, 186, 28, 4, 10
dw 175, 186, 28, 1, 26
dw 175, 192, 1, 2, 15
dw 203, 192, 1, 2, 15
dw 231, 192, 1, 2, 15
shapes3end:

dashes:
dw 0, 5
dw 10, 17
dw 24, 35
dw 44, 59
dw 72, 90
dashesend:

texts:
dw 2, 0, 15, str_time, 4
dw 1, 5, 15, str_dist, 17
dw 2, 5, 14, str_score, 10
dw 24, 14, 15, str_kmh, 4
dw 22, 21, 15, str_fuel, 4
dw 24, 21, 15, str_e, 1
dw 24, 28, 15, str_f, 1
textsend:

str_time: db 'Time'
str_dist: db 'DIST 420 / 1080 m'
str_score: db 'SCORE 4793'
str_kmh: db 'km/h'
str_fuel: db 'FUEL'
str_e: db 'E'
str_f: db 'F'

row: dw 0
dy: dw 0
lx: dw 0
rx: dw 0
t: dw 0
w: dw 0