title FirsLab
;
codesg segment para "code" ; Code segment start. (codesg - segment name, para - segment adress a multiply of 16, "code" - type of segment) 
assume cs:codesg, ds:codesg,  ss:codesg,  es:codesg ; Set functionality of segment. It can be stack, code, etc. In com file one segment - code. 	
                                  
org 100h       ; Program start in the end of PSP, CS eq to segment adress of psp, IP eq to 100h

start:
   jmp main    ; Passing through the data. (in *.COM file 1 segment only for code )
   ; Def data
   buf  db 10 dup(0)  ; Input buffer with 10 bytes size and init with zero. 
   
   errmsg0 db  "Error: conversion to an integer$" ; Reserve message (1 byte per symbol)                  
   errmsg1 db  "Overflow digit grid$"  
   errmsg2 db  "Division by zero$"
   
   mess1 db "Enter the 3 decimal numbers, (d*a)/(a+b)$"
   mess2 db 'A = $'
   mess3 db 'B = $'
   mess4 db 'D = $'
  
  
   var_a  db 0     ; A variable
   var_b  db 0     ; B variable
   var_d  db 0     ; D variable
   
; Data input and calculation (d*a)/(a+b)
; Calls GOTO_XY, WRITE_STR, READ_STR,
;         CALCULATE, str_to_int, int_to_str 
main proc near 
    ; Main program body
    push ax      ; Push values to stack
    push dx
                      
    mov  buf[0],5     ; Size of input buffer (4 symbol + CR)
                      ; Real size after reading is 1b+1b+5b=7b 
                      ; See INT 21 AH = 0Ah function for buffer structure.  
   
    ; Clear screen
    call clear_scr  
    lea dx, mess1     ; Link dx register to mess1 adress. Formaly dx is pointer to mess1.
    call write_str    ; Using int 21h for string output. Need DS:DX = pointer to string ending in "$". 
    call cr
    
     ; Enter symbol A
    lea dx, mess2     ; Put string number to Dx = (mov dx, offset mess2)
    call write_str    ; String output 
      
   
    lea dx, buf       ; Put buffer address to dx. Buffer adress now in DS:DX.
    call read_str     ; Read string to buffer, using int 21h.
    call str_to_int   ; Translate string to integer. Result writed to DX reg.   
    mov var_a,dl   
    
   
    ; à¨£« è¥­¨¥ ª ¢¢®¤ã á¨¬¢®«  B 
    call cr
    lea dx, mess3     ;  ‡ £àã§ª   ¤à¥á  áâà®ª¨ ¢ Dx
    call write_str    ;  ‚ë¢®¤ áâà®ª¨ $   
    
    lea dx, buf       ;  ‡ £àã§ª  ,¡ãä¥à  ¢¢®¤¨¬ëå á¨¬¢®«®¢ ¢ Dx
    ; ¤à¥á ¡ãä¥à  ¢ DS:DX 
    call read_str     ;  —â¥­¨¥ áâà®ª¨ ¢ ¡ãä¥à int 21h
    call str_to_int   ;  ¥§ã«ìâ â ¢ DX   
    mov var_b,dl
   
     ; à¨£« è¥­¨¥ ª ¢¢®¤ã á¨¬¢®«  D 
    call cr 
    lea dx, mess4     ;  ‡ £àã§ª   ¤à¥á  áâà®ª¨ ¢ DS:DX
    call write_str    ;  ‚ë¢®¤ áâà®ª¨ $   
    
    lea dx, buf       ;  ‡ £àã§ª  ,¡ãä¥à  ¢¢®¤¨¬ëå á¨¬¢®«®¢ ¢ Dx
    ; ¤à¥á ¡ãä¥à  ¢ DS:DX 
    call read_str     ;  —â¥­¨¥ áâà®ª¨ ¢ ¡ãä¥à int 21h
    call str_to_int   ;  ¥§ã«ìâ â ¢ DX   
    mov var_d,dl
    call cr    
        
    call calculate; 
    call write_result; 
    call dos_exit           ; ‚ëå®¤ ¢ DOS 
    ;‚®§¢à â ã¯à ¢«¥­¨ï á¨áâ¥¬¥ (¯àë£ ¥¬ ­  int 20h ¢ ­ ç «¥ PSP)
   ret
   ;ª®­¥æ ¯à®æ¥¤ãàë
main endp    


; —¨á«® § £àã¦¥­® ¢ Al   
; ¥à¥¢®¤ —¨á«  ¢ áâà®ªã § £àã¦¥­­ãî ¢ DS:DX
Int_To_Str proc near
  push ax
  push bx 
  push cx
  push dx
  push bp 
  

  xor cx,cx      ; ‘ç¥âç¨ª § ¯¨á ­­ëå ¢ áâ¥ª á¨¬®«®¢   
  mov bp,dx      ; €¤à¥á áâà®ª¨ § ­¥á¥¬ ¢ Bp
  xor dx,dx                    
  mov bl,10      ; ®ª § â¥«ì ‘‘ = 10

  cmp al,0h       
  jg PUSHASCII     
  jz PUSHASCII       
  
  neg al 
  ;mov[bp],2dh            
  inc bp
  
PUSHASCII:
  cbw             ;
  xor ah,ah
  div bl          ; ®á«¥ ¤¥«¥­¨ï ¢  Al æ¥« ï ç áâì, ‚ Ah - ®áâ â®ª
  add ah,30h      ; ®«ãç¨«¨ ASCII á¨¬¢®« æ¨äàë ®áâ âª  ¢  ah
  mov dl,ah        
  push dx         ; ‡ â®«ª­¥¬ ASCII á¨¬¢®« ¢ áâ¥ª
  inc cl          ; “¢¥«¨ç¨¬ áç¥âç¨ª § ¯¨á ­­ëå ¢ áâ¥ª á¨¬¢®«®¢ 
  cmp al,0        ; ®ª  ç áâ­®¥  <> 0
  jnz PUSHASCII   ; ¢ë¯®«­ï¥¬ ¤¥«¥­¨¥ (¯¥à¥¢®¤ ¢ 10 cc)
  
; ‚ëâ®«ª­¥¬ ¢á¥ ASCII ¨§ áâ¥ª  ¢ áâà®ªã
POPASCII:
  pop dx          ; ¢ë¯¨å­¥¬ ASCII ª®¤ ¨§ áâ¥ª  (‚ ®¡à â­®¬ ¯®àï¤ª¥)
  mov [bp],dl     ; ‡ ­¥á¥¬ á¨¬¢®« ¢ áâà®ªã  
  inc bp          ;  
  loop POPASCII   ; 
  
  mov [bp],24h    ; ‡ ¢¥àè îé¨© á¨¬¢®« ¢ áâà®ª¥ $  
  
  pop bp
  pop dx               
  pop cx 
  pop bx
  pop ax
  ret
Int_To_Str endp  


; à®¨§¢®¤¨â ¢ëç¨á«¥­¨¥ (d*a)/(a+b) à¥§ã«ìâ â ¢  Dx
; Dl-ç áâ­®¥ Dh-Žáâ â®ª
calculate proc near
  push ax
  push bx
  push cx
  
  xor ax,ax        
  mov  al,var_a   ; ‡ ­¥á¥¬ ¬­®¦¨â¥«ì ¢ Ax
  imul var_d      ; (a*d)=>Dx (¥§ã«ìâ â ã¬­®¦¥­¨ï á«®¢®)
  ; ‚ Ax ¤¥«¨¬®¥ à §¬¥à á«®¢® () 
  
  ; (a+b)   ®«ãç¨«¨ ¤¥«¨â¥«ì  ¢ Bl
  mov  Bl,var_a   ; 
  add  Bl,var_b   ;
  jo OVERFLOW     ;
  jz DEVIDE_BZ    ;
  
  ; ‚ë¯®«­¨¬ ¤¥«¥­¨¥    (Ax / Bl) 
  call devide     ;     
  
  ; ç áâ­®¥ ¢ Ax, ®áâ â®ª ¢ Dx 
  ; à®¢¥à¨¬ ç áâ­®¥  
  cmp ax,-128  ;
  jl OVERFLOW
  cmp ax,127  ;
  jg OVERFLOW
  
  ; ‘¤¥« ¥¬ ®áâ â®ª ¯®«®¦¨â¥«ì­ë¬  
  cmp dx,0           
  jg FINISH   
  neg dx         
  jmp FINISH
OVERFLOW: 
     call cr 
     lea dx, errmsg1 
     call write_str
     call dos_exit
DEVIDE_BZ:
     call cr
     lea dx, errmsg2 
     call write_str
     call dos_exit
FINISH:  
  mov Dh,Dl   ; ‘®åà ­¨¬ à¥§ã«ìâ â  Dh-®áâ â®ª  (“¦¥ ¡®«ìè¥ 0) 
  mov Dl,Al   ; Dl-ç áâ­®¥
  pop  cx
  pop  bx
  pop  ax
  ret
calculate endp 


; „¥«¥­¨¥ Ax/Bl — áâ­®¥ ¢ Ax Žáâ â®ª ¢ Dx 
devide proc 
push bx
     cwd        ;  áè¨à¨¬ ¤¥«¨¬®¥ ¢ AX ¤® 2£® á«®¢    DX:AX
     push ax 
     mov al,bl 
     cbw        ;  áè¨à¨¬ ¤¥«¨â¥«ì ¤® á«®¢  
     mov bx,ax  ; 
     pop  ax
     ; „¥«¨¬®¥ ¢ DX:AX  „¥«¨â¥«ì ¢ BX 
     idiv bx
     ; — áâ­®¥ ¢ Ax ®áâ â®ª ¢ DX
pop  bx  
ret 
devide endp 
   
   
; ‚ë¢®¤ à¥§ã«ìâ â  ¤¥«¥­¨ï    
write_result proc
push ax
push dx
       call cr                ; ¯¥à¥¢®¤ áâà®ª¨  
       ; ‚ë¢®¤ — áâ­®£®
       xor ax,ax 
       push dx
       mov al,dl;
       lea dx,buf; 
       call int_to_str;
       call write_str;        ;      
       
       call dot               ; 
       
       ; ‚ë¢®¤ ®áâ âª          
       xor ax,ax 
       pop dx
       mov al,dh;
       lea dx,buf; 
       call int_to_str;
       call write_str;        ;      
pop dx 
pop ax       
ret
write_result endp 




; INPUT PARAMTER: String in DS:DX register.
;  
; ¥à¥¢®¤¨â â¥ªáâ®¢ãî áâà®ªã ¢ ç¨á«® á® §­ ª®¬ à §¬¥à®¬ ¡ ©â 
; ¢®§¢à â ¢ DOS ¯à¨ ¯¥à¥¯®«­¥­¨¨ à §àï¤­®© á¥âª¨  ¨ ­¥¤®¯ãáâ¨¬ëå á¨¬¢®« å ¢ 
; áâà®ª¥ (¤®¯ãáâ¨¬ë á¨¬¢®«ë - + 0..9 in the natural order)
; Call GOTO_XY, WRITE_STR, 
;
; Translate string into integer with sign, byte size.
; Return to DOS with grid overflow and entering invalid characters 
; (allowable symbols is '-', '+', 0..9 in the natural order)
; Call GOTO_XY, WRITE_STR, etc.
;

str_to_int proc near 
   push ax
   push bx
   push cx
   push bp
   push si
   xor  bx,bx  
   xor  cx,cx       ; Count register to zero
   mov  bp,dx       ; Adress of string to BP register
   xor  dx,dx       ; DX - return register
   mov si,0         ; Custim sign is '+' 
   mov bl,0         ; Store intermediate result
   inc bp           ; Increment addres and get second element of buffer - number of characters returned with read buffer.
                    ; See read_str proc.
   mov cl,[bp]      ; Move to Cl number of characters in read buffer
   inc bp           ; Increment addres and get first input character
   mov dl,[bp]      ; Get first symbol and check - sign or not?
   cmp dl,2dh       ; It's '-' ? (If dl store 2dh = '-', then ZF = 1)
   jne IS_PLUS      ; It's not '-' (Check for '+')   
   mov si,1         ; It is '-' , set sign of number 
   inc bp           ; Go to next symbol
   dec cl           ; Decrement counter of characters in buffer (1 already compute)
   jmp GO
IS_PLUS:   
   cmp dl,2bh        ; It's '+' ? (If dl store 2bh = '+', then ZF = 1)
   jne GO            ; It isn't '+' (No sign in string. The number is positive.)
   inc bp            ; It is '+', Go to next symbol 
   dec cl            ; Decrement counter of characters in buffer
GO:
   xor ax,ax         ; AX reg. to zero. 
   xor dx,dx         ; DX reg. to zero.   
   mov dl,[bp]       ; ‚ Dl ‘¨¬¢®«ë ¢ë¡¨à ¥¬ë¥ ¨§ áâà®ª¨ 
   inc bp            ; Š á«¥¤ãîé¥¬ã ¡ ©âã áâà®ª¨
   cmp dl,30h        ; à®¢¥à¨¬ ­   dl < '0'
   jl ERROR          ; â® ASCII ª®¤ ¬¥­ìè¥ ç¥¬ '0' (+,- ã¦¥ ¯à®¢¥à¥­ë)          
   cmp dl,39h        ; à®¢¥à¨¬ ­   dl > '9'   
   jg ERROR          ; „ , ­¥ ¬®¦¥â ¡ëâì á¨¬¢®«  ¡®«ìè¥ 9 (®è¨¡ª )        
   sub  dl,30h       ; â® æ¨äà  ®â 0 ¤® 9 => Dl  
   mov al,10         ; ‘®¬­®¦¨â¥«î ¯®«®¦¥­® ¡ëâì ¢ Al
   mul bl            ; ( ˆ§­ ç «ì­® = 0 )
   jo BAIT_OF        ; ¥à¥¯®«­¥­¨¥ à.á¥âª¨ ¡ ©â  
   mov bl,al         ; ‘®åà ­¨¬ ¯à®¬¥¦ãâ®ç­®¥ ¯à®¨§¢¥¤¥­¨¥ 
   add ax,dx         ; ‘«®¦¨¬ ¯à®¬¥¦ ¯à®¨§¢¥¤¥­¨¥ ¨ ®ç¥à¥¤­®© à §àï¤
   cmp ax,128     
   jg BAIT_OF
   mov bl,al         ; ‘®åà ­¨¬ ¯à®¬¥¦ãâ®ç­ë© à¥§ã«ìâ â  
   loop GO           ; €¢â®¬ â¨ç¥áª¨ ã¬¥­ìè ¥â CX ­  1 
   ; Ž¯à¥¤¥«¥­¨¥ §­ ª  ç¨á«   
   cmp si,0          ; ‡­ ª + ?
   jne SET_MINUS     ; ç¨á«® ®âà¨æ â¥«ì­®¥ (­ ¤® ¯¥à¥¢¥áâ¨ ¢ ¤®¯ ª®¤)       
   test bl,80h        ; ¥â  ç¨á«® <127
   jnz BAIT_OF        ; „«ï §­ ª®¢®£® ç¨á«  íâ® ¬­®£® >127
   jmp DONE          ; ‚á¥ ŽŠ + ç¨á«® ¢ ¤¨ ¯ §®­¥ <=127
; 
SET_MINUS:    
    neg  bl          ; ¥à¥¢¥¤¥¬ ç¨á«® ¢ ¤®¯ ª®¤
    test bl,80h      ; —¨á«® ¬¥­ìè¥ -128 
    jz  BAIT_OF      ; „  ®­® ¬¥­ìè¥
    jmp DONE         ; …á«¨ ­¥â ¯¥à¥¯®«­¥­¨ï â® ¢á¥ ŽŠ     
; 
; Ž¡à ¡®âª  ¯¥à¥¯®«­¥­¨ï à §àï¤­®© á¥âª¨ 
BAIT_OF: 
     call cr
     lea dx, errmsg1 
     call write_str
     call dos_exit
     
; Ž¡à ¡®âª  ®è¨¡®ç­ëå á¨¬¢®«®¢ ()  
ERROR: 
     call cr 
     lea dx, errmsg0 
     call write_str
     call dos_exit
DONE:
   xor dx,dx 
   mov dl,bl
   pop si
   pop bp
   pop cx
   pop bx 
   pop ax
   ret
str_to_int endp

; Newline and carriage return with teletype output.     
;
; Function AH = 0Eh params:
;         
; AL = Character, 
; BH = Page Number,
; BL = Color (only in graphic mode)
cr  proc near 
  push ax
  push bx
  push cx
  mov  bh,0     
  mov  cx,1
  mov  al,0Dh  ; Carriage return
  mov  ah,0eh  ; Teletype output (TTY)
  int 10h
  mov  al,0Ah  ; Newline
  mov  ah,0eh  ; Teletype output (TTY) 
  int 10h
  pop cx
  pop bx 
  pop ax
  ret
cr endp 


; Clear screen, same as cls, INT 10h, using AH = 6 function. 
;    
; AH = 6 parameters :
;
; AL = lines to scroll (0 = clear, CH, CL, DH, DL are used),
;
; BH = Background Color and Foreground color. 
; BH = 43h, means that background color is red and foreground color is cyan.
; Refer the BIOS color attributes 
;
; CH = Upper row number, 
; CL = Left column number, 
; DH = Lower row number, 
; DL = Right column number
clear_scr proc near 
   push ax
   push bx
   push cx
   push dx
   xor al,al        ; al:=0 Clear window
   xor cx,cx        ; cx:=0 Top left corner (0,0). CX = CH + CL
   mov dh,24        ; Screen botom row 24
   mov dl,79        ; Right screen column 79
   mov bh,7         ; Normal clear attributes (Color of symbols)
   mov ah,6         ; Call scroll_up function, that scroll window up and add new rows after.
   int 10h
   pop dx
   pop cx
   pop bx
   pop ax
   ret              ; Return from function, to call program. Reset eip/ip.
clear_scr endp    

; ‚ë¢®¤ "."
dot proc near
push ax
push bx
push cx
  mov dl,2eh
  mov ah,02h
  int 21h 
pop cx
pop bx
pop ax
ret 
dot endp

; Write string to standart buffer, int 21h   
;
; AH = 09         
;   
; Parameters:
;
; DS:DX = pointer to string ending in "$"   
;
; returns nothing    
;
; - outputs character string to STDOUT up to "$"
; - backspace is treated as non-destructive
; - if Ctrl-Break is detected, INT 23 is executed
write_str proc near 
  push ax
  mov ah,09h
  int 21h;  
  pop ax
  ret
write_str endp    


; Read string and write it to buffer
;
; AH = 0A 
;
; Parameters: 
;
; DS:DX = pointer to input buffer of the format:
;
; | max | count |  BUFFER (N bytes)
;    |	  |	     `------ input buffer
;    |	  `------------ number of characters returned (byte)
;    `-------------- maximum number of characters to read (byte)
;          
; Last symbol is ODH (CR).     
;
; returns nothing
;
; - since strings can be pre-loaded, it is recommended that the
;   default string be terminated with a CR
; - N bytes of data are read from STDIN into buffer+2
; - max buffer size is 255, minimum buffer size is 1 byte
; - chars up to and including a CR are placed into the buffer
;   beginning at byte 2;	Byte 1 returns the number of chars
;   placed into the buffer  (extended codes take 2 characters)
; - DOS editing keys are active during this call
; - INT 23 is called if Ctrl-Break or Ctrl-C detected
read_str proc near 
  push ax
  mov al,var_a
  mov ah,0Ah
  int 21h;  
  pop ax
  ret
read_str endp    
       
; Program exit
dos_exit proc
int 20h 
dos_exit endp 

; Segment end.
codesg  ends    

; Program end.
end start

