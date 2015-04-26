title FirsLab
; Code segment start. (codesg - segment name, para - segment adress a multiply of 16, "code" - type of segment) 
codesg segment para "code" 
; Set functionality of segment. It can be stack, code, etc. In com file one segment - code. 	
assume cs:codesg, ds:codesg,  ss:codesg,  es:codesg 
; Program start in the end of PSP, CS eq to segment adress of psp, IP eq to 100h
org 100h

start:
   jmp main    ; Passing through the data. (in *.COM file 1 segment only for code )
   ; Def data
   buf  db 10 dup(0)  ; Input buffer with 10 bytes size and init with zero. 
   
   errmsg0 db  "Error: conversion to an integer$" ; Reserve message (1 byte per symbol)                  
   errmsg1 db  "Overflow digit grid$"  
   errmsg2 db  "Division by zero$"
   
   mess1 db "Enter the 3 decimal numbers, D*2/(A+B)$"
   mess2 db 'A = $'
   mess3 db 'B = $'
   mess5 db 'D = $'
  
  
   var_a  db 0     ; A variable
   var_b  db 0     ; B variable    
   var_d  db 0     ; D variable
   
; Data input and calculation D*2/(A+B)
; Calls goto_xy, write_str, read_str, calculate, str_to_int, int_to_str 
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
    call enter_number ; Integer result in DL reg.
    mov var_a,dl   
    
   
    ; Enter symbol B
    lea dx, mess3     ; Put string number to Dx = (mov dx, offset mess2)
    call enter_number ; Integer result in DL reg.   
    mov var_b,dl
         
    ; Enter symbol D
    lea dx, mess5     ; Put string number to Dx = (mov dx, offset mess2)
    call enter_number ; Integer result in DL reg.
    mov var_d,dl  
    
    call cr    
        
    call calculate; 
    call write_result; 
    call dos_exit           ; Exit in DOS
    ; Return controll to system (Move to int 20h in start of PSP)
   ret
   ; Procedure end
main endp    
   
; Number enter procedure.
; Result conatins in DL reg.
enter_number proc near  
    call cr
    call write_str    ; String output    
    
    lea dx, buf       ; Put buffer address to dx. Buffer adress now in DS:DX.
    call read_str     ; Read string to buffer, using int 21h.
    call str_to_int   ; Translate string to integer. Result writed to DX reg. 
enter_number endp 

; Parameters:
; AL - number that must be converted to string.   
; DS:DX - pointer to string.
int_to_str proc near
  push ax
  push bx 
  push cx
  push dx
  push bp 
  

  xor cx,cx      ; Symbol counter
  mov bp,dx      ; String adress move to BP
  xor dx,dx      ; Clear dx             
  mov bl,10      ; Base = 10

  cmp al,0h           
  jg PUSH_ASCII  ; AL gretter then 0  
  jz PUSH_ASCII  ; AL equal to 0   
  
  neg al 
  ;mov[bp],2dh            
  inc bp

; Convert integer to ASCII code and push it to stack. 
; ###################################### 

PUSH_ASCII:
  cbw             ; Extension of the AX to double word DX:AX
  xor ah,ah       ; Clear AH, nothing there. Store in AH modulo
  div bl          ; Division on 10
                  ; After division in AL integer part, in AH - modulo
  add ah,30h      ; Get ASCII symbol of number integer partr, and save in AH reg.
  mov dl,ah       ; Move to DL
  push dx         ; Push ASCII symbol in stack
  inc cl          ; Increase stack symbol counter (See loop in POP_ASCII)
  cmp al,0        ; While integer part <> 0
  jnz PUSH_ASCII  ; Execute division (transmit to base 10)
  
; ######################################
  
; Pop ASCII symbols from stack to buffer      
; ###################################### 

POP_ASCII:
  pop dx          ; Pop ASCII code from stack (in reverse)
  mov [bp],dl     ; Move symbol to buffer (BP reg. pointer to buffer)
  inc bp          ; Inrement adress 
  loop POP_ASCII  ; While CX <> 0. 
  mov [bp],24h    ; Set end symbol  - $

; ######################################
  
  pop bp
  pop dx               
  pop cx 
  pop bx
  pop ax
  ret
int_to_str endp  


; Calculate D*2/(A+B). Result to reg DX.   
;
; Result
; DL - quotient
; Dh - modulo
;
calculate proc near
  push ax
  push bx
  push cx
  
  ; MULTIPLY (D*2)
  ;##############################  
  
  xor ax,ax       ; Clear AX reg. 
  mov  al,2       ; Set multiplyer in AL reg.
  imul var_d      ; IMUL command is multiply with sign. 
                  ; D*2 => AX reg.
   
  ;##############################  
  
  ; SUMMARIZE (A+B)
  ;##############################    
  
  mov  bl,var_a   ; Move A to BL reg. 
  add  bl,var_b   ; Add to BL variable B. (A + B) 
  jo OVERFLOW     ; Check for overflow  
  jz DIVISION_BZ  ; Divider can't by zero
    
  ;############################## 
      
  ; DIVISION AX reg. (D*2) / BL reg. (A+B) 
  ;##############################  
   
  call division    
  
  ;##############################   
  
  ; AX - quotient
  ; DX - modulo   
  
  ; Check quotient. 
  cmp ax,-128 
  jl OVERFLOW ; Less then -128
  
  cmp ax,127  
  jg OVERFLOW ; Gretter then 127
  
  ; Set modulo positive
  cmp dx,0           
  jg FINISH  ; If modulo positive, then move to FINISH   
  neg dx     ; Change sign to '+'        
  jmp FINISH ; Move to FINISH

; Grid overflow error.  
OVERFLOW: 
     call cr 
     lea dx, errmsg1 
     call write_str
     call dos_exit  
    
; Division by zero error. 
DIVISION_BZ:
     call cr
     lea dx, errmsg2 
     call write_str
     call dos_exit   
     
FINISH:  
  mov dh,dl   ; Save to DH modulo
  mov dl,al   ; Save to DL quotient
  pop  cx
  pop  bx
  pop  ax
  ret
calculate endp 


; DIVISION AX / BL.
; AX - quotient
; DX - modulo
division proc near 
push bx     
     ; Extension of the dividend to double word DX:AX
     cwd     
    
     ; Extend the divider to word    
     push ax 
     mov al,bl 
     cbw       
     mov bx,ax  
     pop  ax    
     
     ; Dividend in DX:AX.  Divider in BX reg. 
     idiv bx
pop  bx  
ret 
division endp 
   
   
; Write result to console  
write_result proc
push ax
push dx
       call cr                ; Newline   
       
       ; WRITE QUOTIENT
       ; ##############   
       
       xor ax,ax 
       push dx 
       mov al,dl              ; Move quotient to AL reg.
       lea dx,buf             ; Set pointer to buffer.
       call int_to_str
       call write_str         
       
       ; ##############   
       
       call dot               ; Write dot
       
       ; WRITE MODULO
       ; ##############    
          
       xor ax,ax 
       pop dx
       mov al,dh;             ; Move modulo to AL reg.
       lea dx,buf;            ; Set pointer to buffer.
       call int_to_str;
       call write_str;  
       
       ; ##############          
pop dx 
pop ax       
ret
write_result endp 




; INPUT PARAMTER: String in DS:DX register. 
; (Numbers in string must be byte types, else have overflow)
;  
; Translate string into integer with sign, byte size.
; Return to DOS with grid overflow and entering invalid characters 
; (allowable symbols is '-', '+', 0..9 in the natural order)
; Call GOTO_XY, WRITE_STR, etc.  
; 
; Result returns in DX reg.
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
   
   ; GET SIGN PART  
   ;##############################   
   
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
   
   ;##############################
      
   jmp GO 
   
IS_PLUS:   
   cmp dl,2bh        ; It's '+' ? (If dl store 2bh = '+', then ZF = 1)
   jne GO            ; It isn't '+' (No sign in string. The number is positive.)
   inc bp            ; It is '+', Go to next symbol 
   dec cl            ; Decrement counter of characters in buffer
GO:
   xor ax,ax         ; AX reg. to zero 
   xor dx,dx         ; DX reg. to zero - return register  
   
   ; CHECK FOR UNSUPPORTED SYMBOLS
   ;##############################    
   
   mov dl,[bp]       ; Move symbols form string to DL reg
   inc bp            ; Increment addres and get next character of string
   cmp dl,30h        ; Check  dl < '0' - 30h
   jl  ERROR         ; This ASCII less then '0' (+,- already checked)          
   cmp dl,39h        ; Check  dl > '9'   
   jg  ERROR         ; This ASCII more then 9' (ERROR)        
   sub dl,30h        ; Convert number character to integer and (code of character - 30h = number),
                     ; save to Dl reg 
                      
   ;##############################
     
     
   ; FORM INTEGER FROM STRING  
   ; 
   ; Multiply intermediate result on 10, because of all 
   ; demical numbers can represent as M = Mn*10n-1 + Mn-1*10n-2 + … + M2*10 + M1.  
   ;  
   ; Also checking overflow, because input numbers must be byte type!
   ;############################## 
                      
   mov al,10          ; Multiplier in Al, because operand is byte type. Result store in AX reg
   mul bl             ; Multiplier ( Firstly BL = 0 )
   jo OVERFLOW_ERROR  ; Execute lable, if have overflow
   add ax,dx          ; Summarize intermediate result and next discharge
   cmp ax,128         ; 10000000 = 128
   jg OVERFLOW_ERROR  ; Call OVERFLOW label, if AX value more then 128
   mov bl,al          ; Save intermediate result
   loop GO            ; Automaticly  decreases CX on 1 
                      ; determine number sign
   cmp si,0           ; Is '+' ?
   jne SET_MINUS      ; It's '-', negative number (need translate into additional code)       
   test bl,80h        ; Number is less then 127? (80h = 128)
                      ; TEST is equivalent of cmp command, but more faster    
                      ; TEST instruction performs a bitwise AND on two operands 
                      ; TEST example:
                      ; 00001001 AND 10000000 = 0000000 - zero  
                      ; 11111111 AND 10000000 = 1000000 - not zero
   jnz OVERFLOW_ERROR ; Execute lable OVERFLOW, because BL reg. value > 127. (TEST result not zero) 
   
   ;##############################  
   
   jmp DONE            ; Ok, BL value < 127
; 
SET_MINUS:    
    neg  bl            ; Translate into additional code
    test bl,80h        ; Number is less then -128 (-128 in add. code is 110000000)
                       ; TEST example:  
                       ; -129 = 10000001 01111110 01111111 101111111
                       ; 110000000 AND 10000000 = 10000000 - not zero
                       ; 101111111 (-129) AND 10000000 = 000000000 - zero
    jz  OVERFLOW_ERROR ; Number is less then -128 (TEST result is zero)
    jmp DONE           ; Ok, BL value > -128. No overflow.    
; 
; Grid overflow error.
OVERFLOW_ERROR: 
     call cr
     lea dx, errmsg1 
     call write_str
     call dos_exit
     
; Not supported symols error.
ERROR: 
     call cr 
     lea dx, errmsg0 
     call write_str
     call dos_exit
DONE:
   xor dx,dx 
   mov dl,bl ; Store result in DL reg.
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

; Function AH = 02 of INT 21H (Display Output)
;
; Parameter:
;
; DL = character to output
; 
; returns nothing
;
; - outputs character to STDOUT
; - backspace is treated as non-destructive cursor left
; - if Ctrl-Break is detected, INT 23 is executed
;
; "." Output
dot proc near
push ax
push bx
push cx
  mov dl,2eh ; '.' output
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

