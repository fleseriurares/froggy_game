.386
.model flat, stdcall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;includem biblioteci, si declaram ce functii vrem sa importam
includelib msvcrt.lib
extern exit: proc
extern printf: proc
extern malloc: proc
extern memset: proc

includelib canvas.lib
extern BeginDrawing: proc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;declaram simbolul start ca public - de acolo incepe executia
public start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;sectiunile programului, date, respectiv cod
.data
;aici declaram date
window_title DB "Exemplu proiect desenare",0
area_width EQU 640
area_height EQU 480
area DD 0
nume Db "FROG_0",0

a123 dd 100
b123 dd 300

counter DD 0 ; numara evenimentele de tip timer

;SCORE=TIME*2+COUNTER FOR WIN
;SCORE=COUNTER FOR LOSE

arg1 EQU 8
arg2 EQU 12
arg3 EQU 16
arg4 EQU 20

INIT_X EQU 322
INIT_Y EQU 410

symbol_width EQU 10
symbol_height EQU 20

format db "%s",0
format2 db "%d",0
alert db "!",0
format_bug db " ",0

a dd 322
aux_a dd 322 ;pentru verificare culoare pixel
b dd 410
aux_b dd 410 ;pentru verificare culoare pixeli	
ok dd 400
var1 dd 15

;miscarea masinilor
m1 dd 300
m2 dd 100

red1 dd 500
red2 dd 100
red3 dd 170
red4 dd 100
red5 dd 150

w1 dd 500
w2 dd 300
w3 dd 400

t1 dd 280
t2 dd 328
t3 dd 48
t4 dd 0
t5 dd 630
t6 dd 588

ind_timp dd 0

;miscarea bustenilor
b1_0 dd 10 ;R1
b1_1 dd 58
b2_0 dd 160 ;R2
b2_1 dd 208
b3_0 dd 300 ;R3
b3_1 dd 348
b4_0 dd 450 ;R3
b4_1 dd 498

b12_0 dd 0 ;R1
b12_1 dd 48
b22_0 dd 200 ;R2
b22_1 dd 248
b32_0 dd 400 ;R3
b32_1 dd 448

b13_0 dd 0 ;R1
b13_1 dd 48
b23_0 dd 200 ;R2
b23_1 dd 248
b33_0 dd 400 ;R3
b33_1 dd 448

b14_0 dd 100 ;R1
b14_1 dd 148
b24_0 dd 300 ;R2
b24_1 dd 348
b34_0 dd 500 ;R3
b34_1 dd 548
b44_0 dd 600 ;R3
b44_1 dd 648

;rechini
r1_0 dd 100
r2_0 dd 130
r3_0 dd 390
r4_0 dd 420

r1_1 dd 120
r2_1 dd 150
r3_1 dd 320
r4_1 dd 350


;TRECERE PESTE APA
;pixel aux_a,aux_b


contor_culcus dd 0
lives dd 5
time dd 550
delay dd 10
gameover dd 9
ind_game dd 5
ind_taste dd 1

ind_c1 dd 0
ind_c2 dd 0
ind_c3 dd 0
ind_c4 dd 0
ind_c5 dd 0


include digits.inc
include letters.inc

image_width dd 32
image_height dd 32
include BROASCA_FINAL_ok.inc
include BUSTEAN_DONE.inc
include bustean_final.inc
include carok1.inc
include shark.inc
include car_red2ok.inc
include car_white_rl.inc
include car_white_lr.inc
include truckok.inc
include truck_lr.inc
include red_lrok.inc
include livesok_.inc

.code
; procedura make_text afiseaza o litera sau o cifra la coordonatele date
; arg1 - simbolul de afisat (litera sau cifra)
; arg2 - pointer la vectorul de pixeli
; arg3 - pos_x
; arg4 - pos_y

debug macro format,alert
push offset alert
push offset format
call printf
add esp,8
endm

print macro format,x
push x
push offset format
call printf
add esp,8
endm

vertical_multiple macro x, y,dist, len, color
	local et_loop
	push eax
	push ebx
	push ecx
	mov eax,y
	mov ebx,area_width
	mul ebx
	add eax,x
	shl eax,2
	add eax,area
	mov ecx, len
	et_loop:
	mov dword ptr[eax],color
	add eax, 4*area_width
	loop et_loop
	pop ecx
	pop ebx
	pop eax
endm
line_horizontal macro x, y ,len, color
	local et_loop
	push eax
	push ebx
	push ecx
	
	mov eax,y
	mov ebx,area_width
	mul ebx
	add eax,x
	shl eax,2
	add eax,area
	mov ecx, len
	et_loop:
	mov dword ptr[eax],color
	add eax, 4
	loop et_loop
	pop ecx
	pop ebx
	pop eax
endm

; romb macro x,y,color

; local et_loop
; pusha
; mov edx,1
; mov ecx,10
; et_loop:
; line_horizontal ebx,edx,edx,color
; pusha
; add edx,2
  ; mov ebx,x
  ; dec ebx
  ; mov edx,y
  ; inc edx
  
  ; popa
; loop et_loop
; popa

; endm

paint macro x,y,lungime,latime,color
local et_loop
push ecx
push eax
mov ecx, latime
mov eax,y
et_loop:
line_horizontal x,eax,lungime,color
inc eax
loop et_loop
pop eax
pop ecx
endm

make_text proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1] ; citim simbolul de afisat
	cmp eax, 'A'
	jl make_digit
	cmp eax, 'Z' 
	jg make_digit
	sub eax, 'A'
	lea esi, letters
	jmp draw_text
make_digit:
	cmp eax, '0'
	jl make_space
	cmp eax, '9'
	jg make_space
	sub eax, '0'
	lea esi, digits
	jmp draw_text
make_space:	
	mov eax, 26 ; de la 0 pana la 25 sunt litere, 26 e space
	lea esi, letters
	
draw_text:
	mov ebx, symbol_width
	mul ebx
	mov ebx, symbol_height
	mul ebx
	add esi, eax
	mov ecx, symbol_height
bucla_simbol_linii:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, symbol_height
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, symbol_width
bucla_simbol_coloane:
	cmp byte ptr [esi], 0
	je simbol_pixel_alb
	mov dword ptr [edi], 0
	jmp simbol_pixel_next
simbol_pixel_alb:
	mov dword ptr [edi], 0FFFFFFh
simbol_pixel_next:
	inc esi
	add edi, 4
	loop bucla_simbol_coloane
	pop ecx
	loop bucla_simbol_linii
	popa
	mov esp, ebp
	pop ebp
	ret
make_text endp

; un macro ca sa apelam mai usor desenarea simbolului
make_text_macro macro symbol, drawArea, x, y
	push y
	push x
	push drawArea
	push symbol
	call make_text
	add esp, 16
endm


design_cross macro x,y,color
local et
push eax
mov eax,x
push ecx
mov ecx,30
	paint 15,y,1,14,color
	paint 25,y,1,14,color
	paint 40,y,1,14,color
	paint 55,y,1,14,color
	paint 70,y,1,14,color
	paint 85,y,1,14,color
	paint 100,y,1,14,color
	paint 115,y,1,14,color
	paint 130,y,1,14,color
	paint 145,y,1,14,color
	paint 160,y,1,14,color
	paint 175,y,1,14,color
	paint 190,y,1,14,color
	paint 205,y,1,14,color
	paint 220,y,1,14,color
	paint 235,y,1,14,color
	paint 250,y,1,14,color
	paint 265,y,1,14,color
	pop ecx
	pop eax
	endm

_reset_ macro counter
	local c1,c2,c3,c4,c5,next,next5,fail1,no_water,miscare,lost,fail2,fail3,fail4,save1,save2,save3,cont1,cont2,cont3,cont4,cont5,cont6,cont7,cont8,cont9,cont10,cont11,cont12,cont13
	local cont14,cont15,cont16,cont17,cont18,car1,car2,car3,car4,car5,car6,car7,car8,car9,car10,car11,car12,comp1,comp2,comp3,car_r2,car_r1,save4,tr1,car_w1,carw1,carr2,t_next,t_next1
	push eax
	push ebx
	;colorare fundal principal
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	push 0
	push area
	call memset
	add esp, 12
	paint 0,0,100,480,0
	;colorare apa
	paint 0,40,area_width,200,00ABFFh
	 
	;make_image_macro FROG_0,area,a,b,28,28

	;miscare depasita stanga-dreapta, jos
	
	cmp a,0
	jge comp1
	mov a,640
	comp1:
	
	cmp a,640
	jbe comp2
	mov a,0
	comp2:
	
	cmp b,40
	jg comp30
	mov b,40
	comp30:
	cmp b,440
	jle comp3
	mov b,INIT_Y
	comp3:
	
	paint 0,440,area_width,40,0
	
	;CMP TIME 0 -> JLE GAME OVER
	
	;paint macro x,y,lungime,latime,color
	;colorare culcusuri
	paint 0,40,area_width,18,1DCE00h
	paint 0,58,area_width,1,0
	paint 36,47,63,49,1DCE00h ;c1
	paint 36,97,63,1,0 ; contur
	paint 162,47,63,49,1DCE01h ;c2
	paint 162,97,63,1,0
	paint 288,47,63,49,1DCE02h ;c3
	paint 288,97,63,1,0
	paint 414,47,63,49,1DCE03h ;c4
	paint 414,97,63,1,0
	paint 540,47,63,49,1DCE04h ;c5
	paint 540,97,63,1,0
	;colorare drum
	paint 0,240,area_width,200,0A8ACAEh
	; paint 0,240,area_width,33,0DBDBDBh ;drumul safe de sus(langa apa)
	; paint 0,254,area_width,2,0BDBDBDh ; design trotuar
	;design_cross 15,240,1DCE00h									LA FINAL
	; paint 0,407,area_width,33,0DBDBDBh ;drumul safe de jos(start)
	; paint 0,421,area_width,2,0BDBDBDh ; design trotuar
	;contur:
	; paint 0,240,area_width,1,0
	; paint 0,273,area_width,1,0
	; paint 0,407,area_width,1,0
	
	;make_image_macro car2_ok_0,area,200,300,48,34
	;push offset format_bug
	;call printf
	
	;verificare daca se afla broscuta in apa:
	; mov ebx,b
	; dec ebx
	; pixel a,ebx
	; mov dword ptr[eax],00ABFFh
	 ;cmp dword ptr[eax],00ABFFh
	; jne next
	 ; mov a,320
	 ; mov b,408
	; line_horizontal 100,100,100,0FF0000h
	; next:
	
	
	
	;make_image_macro FROG_0,area, a, b,28,28


	;verificare culcusuri:
	 mov ebx,b
	 dec ebx
	 mov ecx,a
	 mov aux_a,ecx
	 add aux_a,14
	 pixel aux_a,ebx
	 cmp dword ptr[eax],1DCE00h
	 je c1
	 cmp dword ptr[eax],1DCE01h
	 je c2
	 cmp dword ptr[eax],1DCE02h
	 je c3
	 cmp dword ptr[eax],1DCE03h
	 je c4
	 cmp dword ptr[eax],1DCE04h
	 je c5
	jmp next
	  c1:
	   cmp ind_c1,0
	   jne next
	   inc contor_culcus
	   mov ind_c1,1
	   ;make_image_macro FROG_0,area,50,62,32,32
	   ; push offset format_bug
	   ; call printf
	  mov a, INIT_X
	  mov b, INIT_Y
	  jmp next5
	c2:
	   cmp ind_c2,0
	   jne next
	   inc contor_culcus
	   mov ind_c2,1
	   ;make_image_macro FROG_0,area,176,62,32,32
	   ; push offset format_bug
	   ; call printf
	  mov a, INIT_X
	  mov b, INIT_Y
	  jmp next5
	 c3:
	   cmp ind_c3,0
	   jne next
	   inc contor_culcus
	   mov ind_c3,1
	   ;make_image_macro FROG_0,area,302,62,32,32
	   ; push offset format_bug
	   ; call printf
	  mov a, INIT_X
	  mov b, INIT_Y
	  jmp next5
	 
	 c4:
	   cmp ind_c4,0
	   jne next
	   inc contor_culcus
	   mov ind_c4,1
	  ; make_image_macro FROG_0,area,428,62,32,32
	   ; push offset format_bug
	   ; call printf
	  mov a, INIT_X
	  mov b, INIT_Y
	  jmp next5
	  
	  c5:
	   cmp ind_c5,0
	   jne next
	   inc contor_culcus
	   mov ind_c5,1
	  ; make_image_macro FROG_0,area,554,62,32,32
	   ; push offset format_bug
	   ; call printf
	  mov a, INIT_X
	  mov b, INIT_Y
	  jmp next5

	 next:
	 cmp ind_c1,1
	 jne fail1
	 make_image_macro FROG_0,area,50,62,28,28

	 fail1:
	 
	 cmp ind_c2,1
	 jne fail2
	 make_image_macro FROG_0,area,176,62,28,28

	 fail2:
	 
	 cmp ind_c3,1
	 jne fail3
	 make_image_macro FROG_0,area,302,62,28,28

	 fail3:
	 
	 cmp ind_c4,1
	 jne fail4
	 make_image_macro FROG_0,area,428,62,28,28

	 fail4:
	 
	 cmp ind_c5,1
	 jne fail5
	 make_image_macro FROG_0,area,554,62,28,28

	 fail5:
	 
next5:
	
	;miscare car(R3)
	make_image_macro car_white_lr_0,area, w2, 305, 48, 33
	add w2,15
	
	cmp w2,640
	jle carw1
	mov w2,0
	carw1:
	
	
	
	make_image_macro truck_lr_1, area,t3,305,48,34
	make_image_macro truck_lr_0, area,t4,305,48,34
	add t3,15
	add t4,15
	
	cmp t4,640
    jle t_next
	mov t4,0
	mov t3,48
	t_next:
	
	make_image_macro red_lrok_0,area, red5, 305, 48, 32
	add red5,15
		 
	cmp red5,640
	jle car_r12
	mov red5,0
	car_r12:
	
	;miscare car white (R1)
	make_image_macro car_white_lr_0,area, w3, 370, 48, 33
	add w3,8
	
	cmp w3,640
	jle carw2
	mov w3,0
	carw2:
	
	make_image_macro red_lrok_0,area, red3, 370, 48, 32
	add red3,8
	
	cmp red3,640
	jle carr2
	mov red3,0
	carr2:
	
	make_image_macro truck_lr_1, area,t5,372,48,34
	make_image_macro truck_lr_0, area,t6,372,48,34
	add t5,8
	add t6,8
	
	cmp t6,640
    jle t_next1
	mov t6,0
	mov t5,48
	t_next1:
	
	;miscare masina 1
	make_image_macro carok1_0,area, m1, 348, 48, 22
	sub m1,10
	
	cmp m1,0
	jge car1
	mov m1,640
	car1:
	
	make_image_macro carok1_0,area, m2, 348, 48, 22
	sub m2,10
		 
	cmp m2,0
	jge car2
	mov m2,640
	car2:
		 
	;miscare masina 3(red)
	make_image_macro car_red2ok_0,area, red1, 340, 48, 33
	sub red1,10
		 
	cmp red1,0
	jge car_r1
	mov red1,640
	car_r1:
	
	
	
	;miscare masina 4(red) R4
	make_image_macro car_red2ok_0,area, red2, 272, 48, 33
	sub red2,10
		 
	cmp red2,0
	jge car_r2
	mov red2,640
	car_r2:
	
	;truck(R4)
	make_image_macro truck_ok_0,area,t1,270,48,35
	mov eax,t1
	make_image_macro truck_ok_1,area,t2,270,48,35
	sub t1,10
	sub t2,10
	cmp t1,0
	jge tr1
	mov t1,640
	mov t2,688
	tr1:
	
	;white_car (R4)
	make_image_macro car_white,area,w1,270,48,33
	sub w1,10		 
	cmp w1,0
	jge car_w1
	mov w1,640
	car_w1:
	
	
	;trotuar:
	paint 0,240,area_width,33,0DBDBDBh ;drumul safe de sus(langa apa)
	paint 0,254,area_width,2,0BDBDBDh ; design trotuar
	; design_cross 15,240,1DCE00h									
	paint 0,407,area_width,33,0DBDBDBh ;drumul safe de jos(start)
	paint 0,421,area_width,2,0BDBDBDh ; design trotuar
		paint 0,240,area_width,1,0
	paint 0,273,area_width,1,0
	paint 0,407,area_width,1,0
	;VERIFICARE LOSE MASINI
	;YELLOW CAR1
	mov eax,a
	add eax,28
	mov aux_a,eax
	mov ebx,b
	add ebx,16
	mov aux_b,ebx
	pixel aux_a,aux_b
	cmp dword ptr[eax],0fdee21h
	jne save1
	mov a,INIT_X
	mov b,INIT_Y
	dec lives
	save1:
	;YELLOW CAR2
	mov eax,a
	sub eax,1
	mov aux_a,eax
	mov ebx,b
	add ebx,16
	mov aux_b,ebx
	pixel aux_a,aux_b
	cmp dword ptr[eax],0fdee21h
	jne save2
	mov a,INIT_X
	mov b,INIT_Y
	dec lives
	save2:
	mov eax,a
	sub eax,1
	mov aux_a,eax
	mov ebx,b
	add ebx,16
	mov aux_b,ebx
	pixel aux_a,aux_b
	cmp dword ptr[eax],0333333h
	jne save3
	mov a,INIT_X
	mov b,INIT_Y
	dec lives
	save3:
	
	;verificare general
	mov eax,a
	add eax,28
	mov aux_a,eax
	mov ebx,b
	add ebx,1
	mov aux_b,ebx
	pixel aux_a,aux_b
	cmp dword ptr[eax],0A8ACAFh
	jne save4
	mov a,INIT_X
	mov b,INIT_Y
	dec lives
	
save4:	


	
	;I
	;Miscarea bustean 1
	make_image_macro bustean_0,area,b1_0, 108,48,27
	make_image_macro bustean_1,area,b1_1, 104,48,29
	sub b1_0,10
	sub b1_1,10
	
	cmp b1_0,10
	jge cont15
	mov b1_0,640
	mov b1_1,688
	cont15:
	
	; Miscarea bustean 2
	make_image_macro bustean_0,area,b2_0, 108,48,27
	make_image_macro bustean_1,area,b2_1, 104,48,29
	sub b2_0,10
	sub b2_1,10
	
	cmp b2_0,10
	jge cont16
	mov b2_0,640
	mov b2_1,688
	cont16:
	
	; Miscarea bustean 3
	make_image_macro bustean_0,area,b3_0, 108,48,27
	make_image_macro bustean_1,area,b3_1, 104,48,29

	sub b3_0,10
	sub b3_1,10
	
	cmp b3_0,10
	jge cont17
	mov b3_0,640
	mov b3_1,688
	cont17:
	
	; sub b2_2,8
	
	; Miscarea bustean 4
	make_image_macro bustean_0,area,b4_0, 108,48,27
	make_image_macro bustean_1,area,b4_1, 104,48,29
	
	sub b4_0,10
	sub b4_1,10
	
	cmp b4_0,10
	jge cont18
	mov b4_0,640
	mov b4_1,688
	cont18:
	
	;rechin r1
	make_image_macro shark_0,area,r1_0, 104,43,32
	sub r1_0,10
	make_image_macro shark_0,area,r2_0, 120,43,32
	sub r2_0,10
	
	cmp r1_0,10
	jge cont13
	mov r1_0,640
	mov r2_0,670
	cont13:

	make_image_macro shark_0,area,r3_0, 104,43,32
	sub r3_0,10
	make_image_macro shark_0,area,r4_0, 120,43,32
	sub r4_0,10
	
	cmp r3_0,10
	jge cont14
	mov r3_0,640
	mov r4_0,670
	cont14:

	
	;II
	;Miscarea bustean 1_2
	make_image_macro bustean_0,area,b12_0, 143,48,27
	make_image_macro bustean_1,area,b12_1, 139,48,29
	add b12_0,20
	add b12_1,20
	cmp b12_0,640
	jb cont1
	mov b12_0,0
	mov b12_1,48
	cont1:
	;make_image_macro FROG_0, area, a, b,28,28	

	; Miscarea bustean 2_2
	make_image_macro bustean_0,area,b22_0, 143,48,27
	make_image_macro bustean_1,area,b22_1, 139,48,29

	add b22_0,20
	add b22_1,20
	cmp b22_0,640
	jb cont2
	mov b22_0,0
	mov b22_1,48
	cont2:
	; Miscarea bustean 3_2
	make_image_macro bustean_0,area,b32_0, 143,48,27
	make_image_macro bustean_1,area,b32_1, 139,48,29

	add b32_0,20
	add b32_1,20
	
	cmp b32_0,640
	jb cont3
	mov b32_0,0
	mov b32_1,48
	cont3:
	
	;III
	;Miscarea bustean 1_3
	make_image_macro bustean_0,area,b13_0, 175,48,27
	make_image_macro bustean_1,area,b13_1, 171,48,29
	sub b13_0,10
	sub b13_1,10
	
	cmp b13_0,10
	jge cont8
	mov b13_0,640
	mov b13_1,688
	cont8:
	
	;make_image_macro FROG_0, area, a, b,28,28	

	; Miscarea bustean 2_3
	make_image_macro bustean_0,area,b23_0, 175,48,27
	make_image_macro bustean_1,area,b23_1, 171,48,29

	sub b23_0,10
	sub b23_1,10
	
	cmp b23_0,10
	jge cont9
	mov b23_0,640
	mov b23_1,688
	cont9:
	
	; Miscarea bustean 3_3
	make_image_macro bustean_0,area,b33_0, 175,48,27
	make_image_macro bustean_1,area,b33_1, 171,48,29

	sub b33_0,10
	sub b33_1,10
	
	cmp b33_0,10
	jge cont10
	mov b33_0,640
	mov b33_1,688
	cont10:
	
	;rechin r2
	make_image_macro shark_0,area,r1_1, 171,43,32
	sub r1_1,10
	make_image_macro shark_0,area,r2_1, 187,43,32
	sub r2_1,10
	
	cmp r1_1,10
	jge cont11
	mov r1_1,640
	mov r2_1,670
	cont11:
	
	make_image_macro shark_0,area,r3_1, 171,43,32
	sub r3_1,10
	make_image_macro shark_0,area,r4_1, 187,43,32
	sub r4_1,10
	
	cmp r3_1,10
	jge cont12
	mov r3_1,640
	mov r4_1,670
	cont12:
	
	;IV
	;Miscarea bustean 1_4
	make_image_macro bustean_0,area,b14_0, 210,48,27
	make_image_macro bustean_1,area,b14_1, 206,48,29
	add b14_0,18
	add b14_1,18
	cmp b14_0,630
	jb cont4
	mov b14_0,0
	mov b14_1,48
	cont4:
	;make_image_macro FROG_0, area, a, b,28,28	

	; Miscarea bustean 2_4
	make_image_macro bustean_0,area,b24_0, 210,48,27
	make_image_macro bustean_1,area,b24_1, 206,48,29

	add b24_0,18
	add b24_1,18
	cmp b24_0,630
	jb cont5
	mov b24_0,0
	mov b24_1,48
	cont5:
	; Miscarea bustean 3_4
	make_image_macro bustean_0,area,b34_0, 210,48,27
	make_image_macro bustean_1,area,b34_1, 206,48,29

	add b34_0,18
	add b34_1,18
	cmp b34_0,630
	jb cont6
	mov b34_0,0
	mov b34_1,48
	cont6:
	; Miscarea bustean 4_4
	make_image_macro bustean_0,area,b44_0, 210,48,27
	make_image_macro bustean_1,area,b44_1, 206,48,29

	add b44_0,18
	add b44_1,18
	cmp b44_0,630
	jb cont7
	mov b44_0,0
	mov b44_1,48
	cont7:
	
	;make_image_macro FROG_0, area, a, b,28,28
	;verificare apa
	;make_image_macro FROG_0, area, a, b,28,28
	cmp b,240
	jge no_water
	cmp b,100
	jl no_water
	 ;pusha
	 mov ecx,a
	 dec ecx
	 mov aux_a,ecx
	 mov ebx,b
	 add ebx,13
	 mov aux_b,ebx
	 pixel aux_a,aux_b
	 cmp dword ptr[eax],00ABFFh
	 je lost
	 mov ecx,a
	 add ecx,29
	 mov aux_a,ecx
	 mov ebx,b
	 add ebx,13
	 mov aux_b,ebx
	 pixel aux_a,aux_b
	 cmp dword ptr[eax],00ABFFh
	 je lost
	 debug format,alert
	jmp miscare
	
	 lost:;Am sarit in apa/pe rechini

	 mov a,INIT_X
	 mov b,INIT_y
	 dec lives
	 jmp no_water
	 ;popa
	 
	 miscare:
	  cmp b,135
	  jg l1
	  sub a,10
	  cmp a,5
	  jb lost
	  jmp no_water 
	  l1:
	  cmp b,170
	  jg l2
	  add a,20
	  cmp a,635
	  jg lost
	  jmp no_water 
	  l2:
	  cmp b,205
	  jg l3
	  sub a,10
	  cmp a,5
	  jb lost
	  jmp no_water 
	  l3:
	  cmp b,240
	  jg no_water
	  add a,18
	  cmp a,635
	  jg lost
	  jmp no_water 
	 
	no_water:
	
	
	make_image_macro FROG_0, area, a, b,28,28
	
	cmp contor_culcus,5
	jne not_win_yet
	mov ind_game,10
	not_win_yet:
	
	cmp lives,4
	jle a4
	make_image_macro frog_lives_0, area,370,03, 32,32
	a4:
	cmp lives,3
	jle a3
	make_image_macro frog_lives_0, area,330,03, 32,32
	a3:
	cmp lives,2
	jle a2
	make_image_macro frog_lives_0, area,290,03, 32,32
	a2:
	cmp lives,1
	jle a1
	make_image_macro frog_lives_0, area,250,03, 32,32
	a1:
	cmp lives,0
	jle game_over
	make_image_macro frog_lives_0, area,210,03, 32,32
	jmp not_over
	
	
	game_over:
	mov ind_game, 0 
	;paint macro x,y,lungime,latime,color
	; paint 0,0,640,gameover,0
	; cmp gameover,475
	; jge finish
	
	; add gameover,5
	; finish:
	
	not_over:

	 ; cmp contor_culcus,5
	 ; je WIN
	; jmp next1
	 ; WIN:
;margini stanga/dreapta:
	paint 0,0,5,480,0
	paint 635,0,5,480,0
	
	 pop eax
	 pop ebx
	;make_image_macro area, 200, 150

	;line_horizontal 10,10,200,0FF0000h
	
	; mov eax,1
	; mov ecx,10
	; et_loop24:
	; line_horizontal a123,b123,eax,0FF0000h
	; add eax,2
	; dec a123
	; inc b123
	; loop et_loop24
	;paint 100,200, 100,100, 0FF0000h
	
	endm
; functia de desenare - se apeleaza la fiecare click
; sau la fiecare interval de 200ms in care nu s-a dat click
; arg1 - evt (0 - initializare, 1 - click, 2 - s-a scurs intervalul fara click, 3 s-a apasat o tasta)
; arg2 - x
; arg3 - y

make_image_macro macro var,drawArea, x, y, latime, inaltime
 mov image_height,inaltime 
 mov image_width,latime
	push eax
	mov eax,offset [var]
	push y
	push x
	push drawArea
	call make_image
	add esp, 12
	pop eax
endm

pixel macro x,y
push ecx
push edx
push ebx
mov ebx,y
mov edx,0
mov eax,ebx
mov ecx,area_width
mul ecx
add eax,x
shl eax,2
add eax,area
;debug format,alert
lea ebx,dword ptr[eax]
pop ebx
pop edx
pop ecx
endm

draw proc
	push ebp
	mov ebp, esp
	pusha
	;_reset_
	mov eax, [ebp+arg1]
	cmp eax, 1
	jz evt_click
	cmp eax, 2
	jz evt_timer ; nu s-a efectuat click pe nimic
	cmp eax,3
	jz evt_tasta
	;mai jos e codul pt care s-a apasat o tasta
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	push 255
	push area
	call memset
	add esp, 12
	make_image_macro FROG_0,area, a, b,28,28	

	jmp afisare_litere
	
evt_tasta:

	cmp ind_taste,1
	jne final_draw
	mov eax,[ebp+arg2]
	cmp eax, '('
	jz down
	cmp eax,'&'
	jz up
	cmp eax,'%'
	jz left
	cmp eax,"'"
	jz right
	jmp final
	
	;LA OBSTACOLE VOM CALCULA A+JUM;B+JUM
	
	up:
	sub b, 34
	jmp final
	
	down:
	add b, 34
	jmp final
	
	right:
	add a,25
	jmp final
	
	left:
	sub a,25
	jmp final
	
	final:;make_image_macro area, a, b;make_image_macro area, a , b ;PUNEM IMAGINEA LA COORDONATELE a,b
	jmp final_draw
	
evt_click:
	mov eax,[ebp+arg2]
	
;	jmp afisare_litere
	;pos=((y*area_width+x)*4)
evt_timer:
cmp ind_game,0
je nexts
cmp ind_game,10
je nexts
	inc counter
	nexts:
afisare_litere:
	
	; cmp ind_start,1
	; jne final_draw
	_reset_
	;make_image_macro car_red2ok_0,area,200,300,48,40
    ;pixel a,b ;verificare daca suntem pe apa
	; mov dword ptr[eax], 00AcFFh
	; lea ebx,[eax]
	; cmp dword ptr [ebx], 00ABFFh
	; jne next
	; line_horizontal 0,200,50,0FF0000h
	; next:
	
	final2:
	
	;AFISARE TIMP_RAMAS
	
	make_text_macro 'T',area,20,445
	make_text_macro 'I',area,30,445
	make_text_macro 'M',area,40,445
	make_text_macro 'E',area,50,445

	paint 70,450,time,10,5EFF00h ;TIMPUL RAMAS
	cmp time,2
	jge ok10
	mov ind_game,0
	jmp no_delay
	ok10:
	;DELAY
	; inc delay
	; pusha
	; mov edx,0
	; mov eax,delay
	; mov ebx,2
	; div ebx
	; cmp edx,0
	; jne no_delay
	dec time
	no_delay:
	
	;popa
	;AFISARE LEVEL ( CONTOR_CULCUSURI)
	make_text_macro ' ',area,490,10
	make_text_macro 'L',area,500,10
	make_text_macro 'E',area,510,10
	make_text_macro 'V',area,520,10
	make_text_macro 'E',area,530,10
	make_text_macro 'L',area,540,10
	make_text_macro ' ',area,550,10
	make_text_macro ' ',area,570,10
	mov edx, contor_culcus
	add edx, '0'
	make_text_macro edx, area, 560, 10
	
	make_text_macro ' ',area,20,10
	make_text_macro 'S',area,30,10
	make_text_macro 'C',area,40,10
	make_text_macro 'O',area,50,10
	make_text_macro 'R',area,60,10
	make_text_macro 'E',area,70,10
	make_text_macro ' ',area,80,10
	make_text_macro ' ',area,110,10
	;afisam valoarea counter-ului curent (sute, zeci si unitati)
	cmp ind_game,0
	je finish_
	mov ebx, 10
	mov eax, counter
	;cifra unitatilor
	mov edx, 0
	div ebx
	cmp edx, 628
	jne continuare
	;make_image_macro FROG_0,area,a,b,28,28
	continuare:
	add edx, '0'
	make_text_macro edx, area, 110, 10
	;cifra zecilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 100, 10
	;cifra sutelor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 90, 10
	
		make_text_macro 'F',area,10,415
	make_text_macro 'L',area,20,415
	make_text_macro 'E',area,30,415
	make_text_macro 'S',area,40,415
	make_text_macro 'E',area,50,415
	make_text_macro 'R',area,60,415
	make_text_macro 'I',area,70,415
	make_text_macro 'U',area,80,415
	make_text_macro ' ',area,90,415
	make_text_macro 'I',area,100,415
	make_text_macro 'O',area,110,415
	make_text_macro 'A',area,120,415
	make_text_macro 'N',area,130,415
	make_text_macro ' ',area,140,415
	make_text_macro 'R',area,150,415
	make_text_macro 'A',area,160,415
	make_text_macro 'R',area,170,415
	make_text_macro 'E',area,180,415
	make_text_macro 'S',area,190,415
	
	finish_:
	;scriem un mesaj
	cmp ind_game ,0
	jne not_end
	mov ind_taste,0
	paint 0,0,640,gameover,0
	mov a,INIT_X
	mov b,INIT_y
	cmp gameover,470
	jge finish
	add gameover,10
	jmp not_end
	finish:
	
	make_text_macro 'S',area,260,200
	make_text_macro 'C',area,270,200
	make_text_macro 'O',area,280,200
	make_text_macro 'R',area,290,200
	make_text_macro 'E',area,300,200
	make_text_macro ' ',area,310,200
	

	;pusha
	mov ebx, 10
	mov eax, counter
	;cifra unitatilor
	mov edx, 0
	div ebx
	cmp edx, 628
	jne continuare_1
	;make_image_macro FROG_0,area,a,b,28,28
	continuare_1:
	add edx, '0'
	make_text_macro edx, area, 340, 200
	;cifra zecilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 330, 200
	;cifra sutelor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 320, 200
	;popa

	
	make_text_macro 'G',area,260,220
	make_text_macro 'A',area,270,220
	make_text_macro 'M',area,280,220
	make_text_macro 'E',area,290,220
	make_text_macro ' ',area,300,220
	make_text_macro 'O',area,310,220
	make_text_macro 'V',area,320,220
	make_text_macro 'E',area,330,220
	make_text_macro 'R',area,340,220
	make_image_macro frog_lives_0, area,290,260, 32,32
	;make_image_macro frog_lives_0, area,280,260, 32,32

	not_end:
	cmp ind_game ,10
	jne final_draw
	mov ind_taste,0
	cmp ind_timp,1
	je all_done2
	mov ind_timp,1
	 mov eax,time
	 mov ecx,2
	 mul ecx
	;time=time*2
	;SCORE= COUNTER+TIME*2
	; mov eax,time
	 add counter,eax
	 all_done2:
	mov time,550
	paint 0,0,640,gameover,0
	mov a,INIT_X
	mov b,INIT_y
	cmp gameover,470
	jge finish2
	add gameover,10
	jmp final_draw
	finish2:
	
		
	make_text_macro 'S',area,260,180
	make_text_macro 'C',area,270,180
	make_text_macro 'O',area,280,180
	make_text_macro 'R',area,290,180
	make_text_macro 'E',area,300,180
	make_text_macro ' ',area,310,180
	

	;pusha
	mov ebx, 10
	mov eax, counter
	;cifra unitatilor
	mov edx, 0
	div ebx
	cmp edx, 628
	jne continuare_2
	;make_image_macro FROG_0,area,a,b,28,28
	continuare_2:
	add edx, '0'
	make_text_macro edx, area, 340, 180
	;cifra zecilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 330, 180
	;cifra sutelor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 320, 180
	;popa
	
	
	;make_text_macro 'G',area,260,220
	make_text_macro 'Y',area,270,200
	make_text_macro 'O',area,280,200
	make_text_macro 'U',area,290,200
	make_text_macro ' ',area,300,200
	make_text_macro 'W',area,310,200
	make_text_macro 'O',area,320,200
	make_text_macro 'N',area,330,200
	;make_text_macro 'R',area,340,220
	make_image_macro frog_lives_0, area,290,240, 32,32
	;make_image_macro frog_lives_0, area,280,260, 32,32

	;romb 100,100, 0FF0000h
	final_draw:
	popa
	mov esp, ebp
	
	pop ebp
	;debug format, alert
	
	ret
	draw endp


make_image proc ;PROCEDURA PT IMAGINE
	push ebp
	mov ebp, esp
	pusha
	lea esi, [eax]
	
draw_image:
	mov ecx, image_height
loop_draw_lines:
	mov edi, [ebp+arg1] ; pointer to pixel area
	mov eax, [ebp+arg3] ; pointer to coordinate y
	
	add eax, image_height 
	sub eax, ecx ; current line to draw (total - ecx)
	
	mov ebx, area_width
	mul ebx	; get to current line
	
	add eax, [ebp+arg2] ; get to coordinate x in current line
	shl eax, 2 ; multiply by 4 (DWORD per pixel)
	add edi, eax
	
	push ecx
	mov ecx, image_width ; store drawing width for drawing loop
	
loop_draw_columns:

	push eax
	mov eax, dword ptr[esi] 
	mov dword ptr [edi], eax ; take data from variable to canvas
	pop eax
	
	add esi, 4
	add edi, 4 ; next dword (4 Bytes)
	
	loop loop_draw_columns
	
	pop ecx
	loop loop_draw_lines
	popa
	
	mov esp, ebp
	pop ebp
	ret
make_image endp

start:
	;alocam memorie pentru zona de desenat
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	call malloc
	add esp, 4
	mov area, eax
	;apelam functia de desenare a ferestrei
	; typedef void (*DrawFunc)(int evt, int x, int y);
	; void __cdecl BeginDrawing(const char *title, int width, int height, unsigned int *area, DrawFunc draw);
	push offset draw
	push area
	push area_height
	push area_width
	push offset window_title
	call BeginDrawing
	add esp, 20	
	;terminarea programului
	push 0
	call exit
end start
