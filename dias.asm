; Proyecto de arquitectura de computadores
;
;	-Desarrollador: José Gustavo González
; 	-Carnet: 201269684
;	
;
; ---------------------------------------------------------------------------------------------------------------------------
; Este proyecto trata de buscar mediante el ingreso de datos de un usuario de una fecha en especifico con formato
; dd/mm/aaaa, el día de la semana en que se celebró dicho día, además el programa indica si el año de la fecha 
; indicada es un año bisiesto o no.
; ---------------------------------------------------------------------------------------------------------------------------

; La siguiente parte de código son tags para hacer más legible el código
	sys_exit 	equ 	1
	sys_read 	equ 	3
	sys_write 	equ 	4
	sys_close 	equ 	6
	stdin 		equ		0
	stdout 		equ 	1
	
	
; La siguiente parte de código son datos no inicializados
section .bss
	
	inputLen equ 100		;buffer almacenador el string original del usuaro 
	input resb inputLen		;largo de este buffer
	
	aLen equ 10				; a = (14 - Mes) / 12
	a resb aLen				;aca almacenaremos la variable "a" de la funcion 

	yLen equ 10				; y = Año - a
	y resb yLen				;aca almacenaremos la variable "y" de la funcion 
	
	mLen equ 10				; m = Mes + 12 * a - 2
	m resb mLen				;aca almacenaremos la variable "y" de la funcion 
	
	dLen equ 10				; Respuesta final
	d resb dLen				;aca almacenaremos la respuesta 
	
	dia resb 32				; reservo espacio para las variales dia, mes y year (año)
	mes resb 32
	year resb 128
	

; La siguiente parte de código son datos inicializados
section .data

;todas los siguientes datos son prints para el usurio
solicitarFecha: db "Ingrese la fecha por favor: ",10		
lenSolicitarFecha: equ $-solicitarFecha						

sunday: db 	"D        OOO     M         M   I   N     N     GGGG       OOO",10,"D D     O   O    M M     M M   I   N N   N    G          O   O",10,"D  D   O     O   M  M   M  M   I   N  N  N   G    GGG   O     O",10,"D D     O   O    M   M M   M   I   N   N N    G     G    O   O",10,"D        OOO     M    M    M   I   N     N     GGGGG      OOO",10
lenSunday: equ $-sunday		

monday: db "L       U       U   N     N   EEEEEE    SSSSSS",10,"L       U       U   N N   N   E        S",10,"L       U       U   N  N  N   EEE       SSSSS",10,"L        U     U    N   N N   E              S",10,"LLLLL     UUUUU     N     N   EEEEEE   SSSSSS",10					
lenMonday: equ $-monday

tuesday: db "M         M    AAAAA    RRRRR    TTTTTTT   EEEEEE    SSSSSSS",10,"M M     M M   A     A   R    R      T      E        S",10,"M  M   M  M   AAAAAAA   RRRRR       T      EEE       SSSSSS",10,"M   M M   M   A     A   R   R       T      E               S",10,"M    M    M   A     A   R    R      T      EEEEEE   SSSSSSS",10
lenTuesday: equ $-tuesday

wendnesday: db "M         M   I   EEEEEE   RRRRR      CCCCCC     OOO     L	  EEEEEE    SSSSSSS",10,"M M     M M   I   E        R    R    C          O   O 	 L	  E        S",10,"M  M   M  M   I   EEEE     RRRRR    C          O     O   L   	  EEE       SSSSSS",10,"M   M M   M   I   E        R   R     C          O   O 	 L	  E               S",10,"M    M    M   I   EEEEEE   R    R     CCCCCC     OOO 	 LLLLLL   EEEEEE   SSSSSSS",10
lenWendnesday: equ $-wendnesday

thursday: db "  JJJJJ   U	  U	EEEEEE   V       V   EEEEEE    SSSSSSS",10,"      J	  U	  U	E         V  	V    E        S",10,"J     J	  U	 U	EEE        V   V     EEE       SSSSSS",10," J    J	   U	U 	E           V V      E               S",10,"  JJJ	    UUUU	EEEEEE       V	     EEEEEE   SSSSSSS",10
lenThursday: equ $-thursday

friday: db "V        V   I   EEEEEE   RRRRR    N	 N   EEEEEE    SSSSSSS",10, " V  	V    I   E        R    R   N N	 N   E        S",10,"  V    V     I   EEE      RRRRR	   N  N	 N   EEE       SSSSSS",10,"   V  V      I   E        R   R	   N   N N   E               S",10,"     V	     I   EEEEEE   R    R   N	 N   EEEEEE   SSSSSSS",10
lenFriday: equ $-friday

saturday: db " SSSSSSS    AAAAA    BBBBB     AAAAA    D          OOOO",10,"S          A     A   B    B   A     A   D  D      O    O",10," SSSSSS    AAAAAAA   BBBBB    AAAAAAA   D    D   O      O",10,"       S   A     A   B    B   A     A   D  D      O    O",10,"SSSSSSS    A     A   BBBBB    A     A   D          OOOO",10
lenSaturday: equ $-saturday

es_bisiesto: db "El año es bisiesto",10,10,10
len_es_bisiesto: equ $-es_bisiesto

es_no_bisiesto: db "El año NO es bisiesto",10,10,10
len_es_no_bisiesto: equ $-es_no_bisiesto
;finalizan los prints de usuario

; La siguiente parte de código son las instrucciones
section .text
; inicio del codigo del programa
	global _start 
	
_start:
	nop								; mantiene feliz al gbd
	
	mov edx, lenSolicitarFecha		;muevo al edx el largo del mensaje
	mov ecx, solicitarFecha			;muevo al ecx el puntero del mesaje
	call DisplayText				;llamo a la rutina que me despliega en pantalla
	
	mov edx, inputLen				;muevo al edx el largo del mensaje
	mov ecx, input					;muevo al ecx el puntero del mesaje
	call ReadText					;llamo a la rutina que me genera un CIN
	mov ecx, eax					; muevo al ecx la cantidad de digitos leidos
	dec ecx							; decremento el ecx
	mov byte[input+ecx],0h			;muevo al ultimo bit un null 
	mov ecx, 0						;muevo al ecx un cero que me servira de contador de digitos

ciclo:								;ciclo que lee los dias del input
	xor eax, eax					;limpio el eax
	mov al, byte[input+ecx]			;muevo a la parte baja el primer byte del mesaje
	inc ecx							;incremento el contador
	cmp al, 20h						;comparo el byte actual con un espacio en blanco
	jne ciclo						;si no es igual sigo con el ciclo
	push ecx						;si es igual guardo el contador
	dec ecx							;decremento el contador para saber la cantidad de digitos
	lea esi, [input]				;ubico un puntero al esi para convertirlo a integer
	call string_to_int				;llamo a la funcio q me tranforma un string a integer
	mov [dia], ebx					;muevo al buffer el dia (integer)
	pop ecx							;recupero el contador
	
ciclo2:								;ciclo que lee los meses del input
	xor eax, eax					;limpio el eax
	mov al, byte[input+ecx]			;muevo a la parte baja el primer byte del mesaje
	inc ecx							;incremento el contador
	cmp al, 20h						;comparo el byte actual con un espacio en blanco
	jne ciclo2						;si no es igual sigo con el ciclo
	mov ecx, 2						;muevo 2 al ecx q seran la cantidad de digitos a convertir
	lea esi, [input+3]				;ubico un puntero al esi para convertirlo a integer (mes)
	call string_to_int				;llamo a la funcio q me tranforma un string a integer
	mov [mes], ebx					;muevo al buffer el mes (integer)
	mov ecx, 6						;fijo el contador a los años (string)
	mov edx, 0						;coloco un segundo contador para la cantidad de digitos
	
ciclo3:								;ciclo que lee los años del input
	xor eax, eax					;limpio el eax
	mov al, byte[input+ecx]			;muevo a la parte baja el primer byte del mesaje
	inc ecx							;incremento el contador
	inc edx							;incremento el 2do contador
	cmp al, 0h						;comparo el byte actual con un nulo
	jne ciclo3						;si no es igual sigo con el ciclo
	dec edx							;decremento para saber la cantidad de digitos exacta 
	mov ecx, edx					;fijo los digitos a leer
	lea esi, [input+6]				;muevo al buffer el año (integer)
	call string_to_int				;llamo a la funcio q me tranforma un string a integer
	mov [year], eax					;muevo al buffer el año (integer)
	;////////////////////////////////////////////////////////////////////////////////////////////////////////
	;determinar si es bisiesto
	;Un año es bisiesto si es divisible entre 4, excepto si es divisible entre 100 pero no entre 400.
bisiesto:
	xor ecx, ecx					;limpo el ecx
	mov eax, [year]					;muevo al eax el año
	mov ebx, 4						;muevo al ebx un 4
	xor edx, edx					;limpio el edx (debe estarlo, ya q div eax, ebx deja en el edx el modulo eax, ebx)
	div ebx							;realizo la division
	cmp edx, 0						;comparo el modulo con cero
	jne bisiesto_false				;si no es igual dejo de buscar y digo q el año no es bisiesto
	
	mov eax, [year]					;muevo al eax el año
	mov ebx, 100					;muevo al ebx un 4
	xor edx, edx					;limpio el edx (debe estarlo, ya q div eax, ebx deja en el edx el modulo eax, ebx)
	div ebx							;realizo la division
	cmp edx, 0						;comparo el modulo con cero
	jne bisiesto_true				;si es igual ya no busco mas y digo q es año bisiesto
	
	mov eax, [year]					;muevo al eax el año
	mov ebx, 400					;muevo al ebx un 400
	xor edx, edx					;limpio el edx (debe estarlo, ya q div eax, ebx deja en el edx el modulo eax, ebx)
	div ebx							;realizo la division
	cmp edx, 0						;comparo el modulo con cero
	je bisiesto_true				; si es igual entonces con certeza digo q el año es bisiesto
	jmp bisiesto_false				;si no es igual entonces el año no es bisiesto
	
;funcion q imprime si el año es bisiesto
bisiesto_true:						
	mov ecx, es_bisiesto
	mov edx, len_es_bisiesto
	call DisplayText
	jmp find_a

;funcion q imprime si el año NO es bisiesto
bisiesto_false:
	mov ecx, es_no_bisiesto
	mov edx, len_es_no_bisiesto
	call DisplayText
;////////////////////////////////////////////////////////////////////////////////////////////////////////
	
find_a:  ;a = (14 - Mes) / 12
	mov eax, 14						;muevo al eax un 14
	sub eax, [mes]					;le resto el mes
	cmp eax,12						;comparo con 12
	jb .esCero						;si es menor a 12 a=0
	mov eax, 1						;muevo un 1 al eax
	mov [a],eax						;a pasa a ser 1
	jmp find_y						;brinco de una a buscar y
.esCero:
	mov eax, 0						;muevo un 0 al eax
	mov [a],eax						;a pasa a ser 0
	
	
find_y: ;y = Año - a
	mov ebx, [a]					;paso el a al ebx
	mov eax, [year]					;paso el año al eax
	sub eax,ebx						;aplico la resta
	mov [y],eax						; el resultado se le settea a y

find_m: ;m = Mes + 12 * a - 2
	mov eax, [mes]					;paso el mes al eax
	dec eax							;decremento el eax
	dec eax							;este paso se repite
	mov ebx, [a]					;muevo al ebx el a
	cmp ebx, 0						;comparo si a es 0 para no hacer multiplicaciones
	je .cero						;si es cero no hay q sumar
	add eax, 12						;sumo el 12*a =12 (no hay q multilpicar)
	mov [m],eax						;settero el m
	jmp find_d						;paso al siguiente paso
.cero:
	mov [m],eax						;setteo el m
		
find_d: 							;d = (día + y + y/4 - y/100 + y/400 + (31*m)/12) mod 7
	mov eax, [dia]					;paso al eax el dia
	mov ebx, [y]					;paso al ebx y
	add eax, ebx 					;(día + y)
	push eax						;salvo la suma
	mov eax, [y]					;paso al eax y
	mov ebx, 4						;paso al ebx un 4
	xor edx, edx					;limpio el edx ya q vamoa a hacer una division
	div ebx  						;(y/4)
	pop ebx							;recupero la suma
	add eax, ebx  					;(día + y) + y/4
	push eax						;salvo la resta
	mov eax, [y]					;paso al eax el y
	mov ebx, 100					;paso al ebx un 100
	xor edx, edx					;limpio el edx ya q vamoa a hacer una division
	div ebx 						;y/100
	mov ebx, eax					;muevo al ebx el resultado
	pop eax							;recupero la suma
	sub eax, ebx 					;(día + y + y/4 )- y/100
	push eax						;salvo la resta
	mov eax, [y]					;muevo al eax el y
	mov ebx, 400					;muevo al ebx 400
	xor edx, edx					;limpio el edx ya q vamoa a hacer una division
	div ebx 						;(y/100)
	pop ebx							;recupero la resta
	add eax, ebx  					;(día + y + y/4 - y/100) + y/400
	push eax   						;salvo la suma
	mov eax, [m]					;muevo al eax el m
	mov ebx, 31						;paso al ebx 31
	mul ebx							;(31*m)
	mov ebx, 12						;muevo al ebx 12
	xor edx, edx					;limpio el edx ya q vamoa a hacer una division
	div ebx							;(31*m)/12)
	pop ebx							;recupero la suma
	add eax, ebx  					;(día + y + y/4 - y/100 + y/400 )+ (31*m)/12
	mov ebx, 7						;paso al ebx un 7
	xor edx, edx					;limpio el edx ya q vamoa a hacer una division
	div ebx							;aplico la division
	mov eax, edx					;salvo en el eax el resultado el modulo 7

;en esta parte se despliega en forma de switch case casa caso e imprime el dia correspondiente
;a este diccionario. [d]={ 0:dom , 1:lun, 2:mar, 3:mie, 4:jue, 5:vie, 6:sab}
revisar_dia:
	cmp eax, 0
	je domingo
	cmp eax, 1
	je lunes
	cmp eax, 2
	je martes
	cmp eax, 3
	je miercoles
	cmp eax, 4
	je jueves
	cmp eax, 5
	je viernes
	jmp sabado

;en esta parte se despliega en forma de switch case casa caso e imprime el dia correspondiente
;a este diccionario. [d]={ 0:dom , 1:lun, 2:mar, 3:mie, 4:jue, 5:vie, 6:sab}
domingo:	
	mov ecx, sunday
	mov edx, lenSunday
	call DisplayText
	jmp Cerrar
lunes:
	mov ecx, monday
	mov edx, lenMonday
	call DisplayText
	jmp Cerrar
martes:
	mov ecx, tuesday
	mov edx, lenTuesday
	call DisplayText
	jmp Cerrar
miercoles:
	mov ecx, wendnesday
	mov edx, lenWendnesday
	call DisplayText
	jmp Cerrar
jueves:
	mov ecx, thursday
	mov edx, lenThursday
	call DisplayText
	jmp Cerrar
viernes:
	mov ecx, friday
	mov edx, lenFriday
	call DisplayText
	jmp Cerrar
sabado:
	mov ecx, saturday
	mov edx, lenSaturday
	call DisplayText
	jmp Cerrar

				
; La siguiente subrutina llama el kernel y muetra un mensaje en pantalla.
; desplega algo en la salida estándar. debe "setearse" lo siguiente:
; ecx: el puntero al mensaje a desplegar
; edx: el largo del mensaje a desplegar
; modifica los registros eax y ebx.
DisplayText:
    mov     eax, sys_write
    mov     ebx, stdout
    int     80h 
    ret

; lee algo de la entrada estándar.debe "setearse" lo siguiente:
; ecx: el puntero al buffer donde se almacenará
; edx: el largo del mensaje a leer
ReadText:
    mov ebx, stdin
    mov eax, sys_read
    int 80H
    ret
   
;/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////   
;http://stackoverflow.com/questions/19309749/nasm-assembly-convert-input-to-integer
;Input:
; EAX = integer value to convert
; ESI = pointer to buffer to store the string in (must have room for at least 10 bytes)
; Output:
; EAX = pointer to the first character of the generated string
int_to_string:
	push esi
	add esi,9
	mov byte [esi],0
	mov ebx,10         
.next_digit:
	xor edx,edx         ; Clear edx prior to dividing edx:eax by ebx
	div ebx             ; eax /= 10
	add dl,'0'          ; Convert the remainder to ASCII 
	dec esi             ; store characters in reverse order
	mov [esi],dl
	test eax,eax            
	jnz .next_digit     ; Repeat until eax==0
	mov eax,esi
	pop esi
	ret
	
; Input:
; ESI = pointer to the string to convert
; ECX = number of digits in the string (must be > 0)
; Output:
; EAX = integer value
string_to_int:
  xor ebx,ebx    ; clear ebx
.next_digit:
  movzx eax,byte[esi]
  inc esi
  sub al,'0'    ; convert from ASCII to number
  imul ebx,10
  add ebx,eax   ; ebx = ebx*10 + eax
  loop .next_digit  ; while (--ecx)
  mov eax,ebx
  ret
;//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
; La siguiente subrutina cierra el programa
Cerrar:
	mov eax, sys_exit				;muevo la variabla sys_close al eax
	int 80h							;llamo a la interrupcion de kernel
