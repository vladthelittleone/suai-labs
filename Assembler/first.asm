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
  
  
   var_a  db 0     ; 
   var_b  db 0     ;
   var_d  db 0     ;
   

;‚¢®¤ ¤ ­­ëå ¨ ¢ëç¨á«¥­¨¥ ¢ëà ¦¥­¨ï (d*a)/(a+b)
;‚ë§ë¢ ¥â GOTO_XY, WRITE_STR, READ_STR,
;         CALCULATE, str_to_int, int_to_str 
main proc near 
    ;Žá­®¢­®¥ â¥«® ¯à®£à ¬¬ë 
    push ax
    push dx
                      
    mov  buf[0],5     ; Ž¯à¥¤¥«¨¬ à §¬¥à ¢å®¤­®£® ¡ãä¥à  (4 á¨¬¢®«  + CR)
                      ; ¥ «ì­ë© à §¬¥à ¡ãä¥à  ¯®á«¥ çâ¥­¨ï 1¡+1¡+5¡=7¡   
   
    ; Žç¨áâª  íªà ­  ¢ë¢®¤ áâà®ª¨ § £®«®¢ª  
    call clear_scr  
    lea dx, mess1     ;  ‡ £àã§¨¬  ¤à¥á áâà®ª¨ mess1 ¢ à¥£¨áâ
    call write_str    ;  ˆá¯®«ì§ã¥â int 21h ¤«ï ¢ë¢®¤  áâà®ª¨  § ª.áï $
    call cr
    
     ; à¨£« è¥­¨¥ ª ¢¢®¤ã á¨¬¢®«  € 
    lea dx, mess2     ;  ‡ £àã§ª   ¤à¥á  áâà®ª¨ ¢ Dx = (mov dx,offset mess2)
    call write_str    ;  ‚ë¢®¤ áâà®ª¨    
      
   
    lea dx, buf       ;  ‡ £àã§ª   ¤à¥á  ¡ãä¥à  ¢¢®¤¨¬ëå á¨¬¢®«®¢ ¢ Dx
    ; ¤à¥á ¡ãä¥à  ¢ DS:DX 
    call read_str     ;  —â¥­¨¥ áâà®ª¨ ¢ ¡ãä¥à ¨á¯ int 21h
    call str_to_int   ;  ¥à¥¢®¤ áâà®ª¨ ¢ ç¨á«® ¥§ã«ìâ â ¢ DX   
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




; ‘’ŽŠ€ ¢ DS:DX   
; ¥à¥¢®¤¨â â¥ªáâ®¢ãî áâà®ªã ¢ ç¨á«® á® §­ ª®¬ à §¬¥à®¬ ¡ ©â 
; ¢®§¢à â ¢ DOS ¯à¨ ¯¥à¥¯®«­¥­¨¨ à §àï¤­®© á¥âª¨  ¨ ­¥¤®¯ãáâ¨¬ëå á¨¬¢®« å ¢ 
; áâà®ª¥ (¤®¯ãáâ¨¬ë á¨¬¢®«ë - + 0..9 ¢ ¥áâ¥áâ¢¥­­®¬ ¯®àï¤ª¥ á«¥¤®¢ ­¨ï)
; ‚ë§ë¢ ¥â GOTO_XY, WRITE_STR, 

str_to_int proc near 
   push ax
   push bx
   push cx
   push bp
   push si
   xor  bx,bx  
   xor  cx,cx       ; Ž¡­ã«¨¬ à¥£¨áâà áç¥âç¨ª 
   mov  bp,dx       ; ‡ ­¥á¥¬  ¤à¥á áâà®ª¨ ¢ Bp 
   xor  dx,dx       ; —¥à¥§ íâ®â à¥£¨áâà ¢®§¢à â¨¬ §­ ç¥­¨¥
   mov si,0         ; ‡­ ª ¯® ã¬®«ç ­¨î +  
   mov bl,0         ; à®¬¥¦ãâ®ç­®¥ åà ­¥­¨¥ à¥§ã«ìâ â  
   inc bp           ; ‘¯®§¨æ¨®­¨àã¥¬ ­  ç¨á«® ¯à®ç¨â ­­ëå á¨¬¢®«®¢ 
   mov cl,[bp]      ; ‡ ­¥áª¬ ¢ Cl ç¨á«® ¯à®ç¨â ­­ëå á¨¬¢®«®¢ 
   inc bp           ; ®§¨æ¨®­¨àã¥¬ ¨­¤¥ªá ­  1© á¨¬¢®« ¢ áâà®ª¥
   mov dl,[bp]      ; ®á¬®âà¨¬ 1 á¨¬¢®« (à®¢¥à¨¬ §­ ª «¨ íâ® ?)
   cmp dl,2dh       ; â® '-' ?   
   jne PLUS         ; ¥â íâ® ­¥ '-' (®¯à®¡ã¥¬ ¯à®¢¥à¨âì ­  '+')   
   mov si,1         ; „  íâ® '-' , ‡ ¯®¬­¨¬ §­ ª ç¨á«  
   inc bp           ; ¥à¥©¤¥¬ ª á«¥¤ãîé¥¬ã á¨¬¢®«ã; 
   dec cl           ; “¬¥­ìè¨¬ áç¥âç¨ª ®¡à ¡ âë¢ ¥¬ëå á¨¬¢®«®¢ (ã¦¥ 1 ®¡à ¡®â ­)
   jmp GO
PLUS:   
   cmp dl,2bh        ; â® '+' ? 
   jne GO            ; …’ íâ® ­¥ ¯«îá
   inc bp            ; „  íâ® '+', ¥à¥©¤¥¬ ª á«¥¤ãîé¥¬ã á¨¬¢®«ã;  
   dec cl            ; “¬¥­ìè¨¬ áç¥âç¨ª ®¡à ¡ âë¢ ¥¬ëå á¨¬¢®«®¢ 
GO:
   xor ax,ax         ;  
   xor dx,dx         ;    
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

; ¥à¥¢®¤ áâà®ª¨ ¨ ¢®§¢à â ª à¥âª¨ 
cr  proc near 
  push ax
  push bx
  push cx
  mov  bh,0     
  mov  cx,1
  mov  al,0Dh  ; ¥à¥¢®¤ áâà®ª¨
  mov  ah,0eh  ; à¥¦¨¬ ®â®¡à ¦¥­¨ï TTY ( ¡®â îâ ã¯à ¢«ïîé¨¥ ª®¤ë)
  int 10h
  mov  al,0Ah  ; ‚®§¢à â ª à¥âª¨
  mov  ah,0eh  ; 
  int 10h
  pop cx
  pop bx 
  pop ax
  ret
cr endp 


; Žç¨áâª  ¢á¥£® íªà ­ ,  ­ «®£¨ç­® cls, Int 10h
clear_scr proc near 
   push ax
   push bx
   push cx
   push dx
   xor al,al        ; al:=0 Žç¨áâ¨âì ®ª­®
   xor cx,cx        ; cx:=0 ‚¥àå­¨© «¥¢ë© ã£®« (0,0)
   mov dh,24        ; ¨¦­ïï áâà®ª  íªà ­   24
   mov dl,79        ; à ¢ë© áâ®«¡¥æ íªà ­  79
   mov bh,7         ; ®à¬ «ì­ë¥  âà¨¡ãâë ®ç¨áâª¨
   mov ah,6         ; ¢ë§®¢ äã­ªæ¨¨ scroll_up 
   int 10h
   pop dx
   pop cx
   pop bx
   pop ax
   ret
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

; ‚ë¢®¤¨â áâà®ªã ­  íªà ­ int 21h 
; ‘âà®ª  § £àã¦¥­  DS:DX § ¢¥àè ¥âáï á¨¬¢®«®¬ $  
write_str proc near 
  push ax
  mov ah,09h
  int 21h;  
  pop ax
  ret
write_str endp    


; —¨â ¥â áâà®ªã ¢ ¡ãä¥à, ä®à¬ â ¢å®¤­®£® ¡ãä¥à  ¢ ‘¯à ¢ª¥ ¯® 0Ah int 21h 
; DS:DX 
read_str proc near 
  push ax
  mov al,var_a
  mov ah,0Ah
  int 21h;  
  pop ax
  ret
read_str endp    

dos_exit proc
int 20h 
dos_exit endp 
; ª®­¥æ á¥£¬¥­â  
codesg  ends
; ª®­¥æ ¯à®£à ¬¬ë
end start


    
   
   
   

  
