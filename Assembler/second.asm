INPUT_BUFFER_SIZE EQU 10
OUTPUT_BUFFER_SIZE EQU 7
POSITION_FOR_IPUTED_VARIABLE_IN_MESSAGE EQU 9
CHAR_VAR_A EQU 'A'
CHAR_VAR_D EQU 'D'
CHAR_VAR_B EQU 'B'
CHAR_ASSIGN EQU '='
CHAR_SPACE EQU ' '
CURRENT_RANK EQU 6 ; Allowable number of digits in current base 10 
CURRENT_BASE EQU 10
COUNT_OF_INPUT_VARIABLES EQU 3

.186               ; Enable 80186 instructions masm directive (For example PUSHA)
S SEGMENT STACK
DW 128 DUP (?)     ; 128 words in stack is uninitialize => 256 bytes uninitialize (for maintaining interrupts)
S ENDS

DATA SEGMENT  
                                                     
; String in format for input. 
;
;   5      4       Vana     
;
; | max | count |  BUFFER (N bytes)
;    |	  |	     `------ input buffer
;    |	  `------------ number of characters returned (byte)
;    `-------------- maximum number of characters to read (byte)    
;
; Last symbol is ODH (CR).  
INPUT_STRING DB INPUT_BUFFER_SIZE, ?, INPUT_BUFFER_SIZE DUP (?) 
OUTPUT_STRING DB OUTPUT_BUFFER_SIZE DUP (0)
RESTART_PROGRAM_STRING DB 2, ?, ?
MYSTR DB 'HELLO WORLD$'
MASSEGE_ABOUT_UNEXPECTED_VARIABLE DB 'This variable name is unexpected$'
MESSAGE_ABOUT_INPUT_FORMAT DB '[space]Name of variable[space]=[space]value$'
MESSAGE_ABOUT_AVAILABLE_VARIABLES DB 'Please, using only those names for variables: (A, B, D)$'
MESSAGE_ABOUT_REPEATABLE_DATA DB 'Variable N is already inputed$'
MESSAGE_INVALID_STRING DB 'Invalid input string, please, retry$'
MESSAGE_OVERFLOW_CALCULATION DB 'There is overflow$'
MESSAGE_DIVISION_BY_ZERO DB 'Division by zero$'
MESSAGE_OVERFLOW_INPUT DB 'There is overflow, retry again$'
MESSAGE_RESTART_PROGRAM DB 'Restart program? (Y/N)$'
MESSAGE_ABOUT_TASK DB 'D*A/(A+B)$'
VARIABLE_BUFFER DB INPUT_BUFFER_SIZE DUP (?)
VARIABLE_A_FLAG DB 0
VARIABLE_B_FLAG DB 0
VARIABLE_D_FLAG DB 0
RESULT_OF_CHECK_INPUT_STATUS DB 0
RESULT_OF_CHECK_SYMBOL_ON_CORRECT DB 0
FLAG_OF_JUMP DB 0
INPUT_FLAG DB 0
SOURCE_BASE DW 10
DATA ENDS

C SEGMENT 
ASSUME SS:S, CS:C, DS:DATA, ES:DATA

RESTART_PROGRAM PROC
PUSH DX
MOV DX, offset MESSAGE_RESTART_PROGRAM
CALL SET_CURSOR_ON_NEXT_LINE
BEGIN_RESTART:CALL WRITE_STRING_ON_DISPLAY
MOV DX, offset RESTART_PROGRAM_STRING
CALL READ_INPUT_DATA
CMP RESTART_PROGRAM_STRING + 2, 'Y'
JNE MAYBE_NO
POP DX
ADD SP, 2
JMP SI
MAYBE_NO: CMP RESTART_PROGRAM_STRING + 2, 'N'
JE EXIT
JMP BEGIN_RESTART
EXIT:
CALL EXIT_PROGRAM
RET
RESTART_PROGRAM ENDP

;âûâîä ñèìâîëà
WRITE_SYMBOL_ON_DISPLAY PROC
;DL êîä ñèì âîëà
PUSH AX
MOV AH, 2
INT 21h
POP AX
RET
WRITE_SYMBOL_ON_DISPLAY ENDP

;îáðàáàòûâàåì ïåðåíîñ (ïåðåïîëíåíèå)
CHECK_OVERFLOW PROC
PUSH DX
JNC ACROSS_CARRY
CMP INPUT_FLAG, 0
JNE INPUT_PROCESSING
MOV DX, offset MESSAGE_OVERFLOW_CALCULATION
CALL SET_CURSOR_ON_NEXT_LINE
CALL WRITE_STRING_ON_DISPLAY
CALL RESTART_PROGRAM
JMP ACROSS_CARRY
INPUT_PROCESSING:
MOV DX, offset MESSAGE_OVERFLOW_INPUT
CALL SET_CURSOR_ON_NEXT_LINE
CALL WRITE_STRING_ON_DISPLAY
;î÷èùàåì àäðåñ âîçâðàòà
POP DX
ADD SP, 2
JMP SI
ACROSS_CARRY:
POP DX
RET 
CHECK_OVERFLOW ENDP
     
; Newline and carriage return.    
;
; Function AH = 02H (Write symbol)
;
; Params:
;         
; DL - pointer to symbol for output.
;
SET_CURSOR_ON_NEXT_LINE PROC
PUSH AX
PUSH DX
MOV DL, 10 ; Newline ASCII code.
MOV AH, 2
INT 21h
MOV DL, 13 ; Carriage ASCII code.
INT 21h
POP DX
POP AX
RET
SET_CURSOR_ON_NEXT_LINE ENDP

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
READ_INPUT_DATA PROC
PUSH AX
MOV AH, 0Ah
INT 21h
POP AX
RET
READ_INPUT_DATA ENDP

; Program exit   
; 
; AH = 4CH
; 
; Parameters:
;
; AL - exit code
;
EXIT_PROGRAM PROC
MOV AL, 0
MOV AH, 4Ch
INT 21h
RET
EXIT_PROGRAM ENDP

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
WRITE_STRING_ON_DISPLAY PROC
PUSH AX
MOV AH, 9
INT 21h
POP AX
RET
WRITE_STRING_ON_DISPLAY ENDP

; Parse input string
;
; Output:
;      
; DL - name of variable
; VARIABLE_BUFFER - store value of varialbe
;
PARSE_INPUT_DATA PROC               

PUSH AX
PUSH CX
PUSH BX 
PUSH SI
MOV FLAG_OF_JUMP, 0
MOV AL, CHAR_SPACE
MOV CL, [INPUT_STRING + 1] ; CL stored size of input string

; Increase counter, because of end symbol

INC CL
MOV BX, CX
LEA DI, INPUT_STRING + 2     

; Check space

CMP CX, 0
JE BREAK_PARSE
CLD            ; DF set to zero. (The direction flag is a flag
               ; that controls the left-to-right (0) or
               ; right-to-left (1) direction of string processing)
REPE SCASB     ; 
               ; REPE - repeat prefix. If cx<>0 or zf<>0 
               ; then call SCASB, else command after SCASB.
               ; Decrement CX reg. on loop.
               ;
               ; SCASB - 
; Parse variable A

MOV DL, CHAR_VAR_A
CMP [DI - 1], DL
JNE PARSE_VARIABLE_B
JMP PARSE_SPECIFIC_VARIABLE
;ïåðåìåííàß B
PARSE_VARIABLE_B:
MOV DL, CHAR_VAR_B
CMP [DI - 1], DL
JNE PARSE_VARIABLE_D
JMP PARSE_SPECIFIC_VARIABLE
;îæèäàåì ïåðåìåííóþ D
PARSE_VARIABLE_D:
MOV DL, CHAR_VAR_D
CMP [DI - 1], DL
JNE UNEXPECTED_VARIABLE_NAME
JMP PARSE_SPECIFIC_VARIABLE
;íà÷èíàåì ïàðñèòü çíà÷åíèå
PARSE_SPECIFIC_VARIABLE:
REPE SCASB
CMP [DI - 1], BYTE PTR CHAR_ASSIGN
JNE BREAK_PARSE
;ïðîâåðêà íà ïîâòîðíûé ââîä îäíîãî è òîãî æå èäåíòèôèêàòîðà
CALL CHECK_INPUT_STATUS_FOR_VARIABLE
CMP RESULT_OF_CHECK_INPUT_STATUS, 1
JE VARIABLE_IS_ALREADY_INPUTED
;èäåì äî ÷èñëà
JCXZ BREAK_PARSE
REPE SCASB
;çàïîìèíàåì íà÷àëî ÷èñëà
LEA BX, [DI - 1]
;Ž†ˆ„€…’‘Ÿ ‚ ŠŽ–… ‘’ŽŠˆ €‘ˆƒ€ ‘ˆŒ‚Ž‹ ‡€‚…˜…ˆŸ 13
MOV AL, 13
REPNE SCASB
;çàïîìèíàåì êîíåö ÷èñëà 
LEA SI, [DI - 1]
SUB SI, BX
MOV CX, SI
;åñëè ÷èñëî ïîðßäêà 1
CMP CX, 0
JNE VARIABLE_RANK_IS_NOT_ONLY_ONE
MOV CX, 1
VARIABLE_RANK_IS_NOT_ONLY_ONE:
;íà÷àëî ÷èñëà
MOV SI, BX
;LEA SI, [BX]
LEA DI, VARIABLE_BUFFER + 1
MOV VARIABLE_BUFFER, CL
REP MOVSB
JMP EXIT_FROM_PARSE
;íåîæèäàåìàß ïåðåìåííàß
UNEXPECTED_VARIABLE_NAME:
CALL SHOW_MESSAGE_ABOUT_UNEXPECTED_VARIABLE
MOV FLAG_OF_JUMP, 1
JMP EXIT_FROM_PARSE
;ïðåðûâàåì ïàðñèíã ïî ïðè÷èíå íå çàäàííîãî ôîðìàòà ââîäèìîé ñòðîêè
BREAK_PARSE:
CALL SHOW_MESSAGE_ABOUT_INVALID_INPUT_STRING
MOV FLAG_OF_JUMP, 1
JMP EXIT_FROM_PARSE
;ýòà ïåðåìåííàß óæå ââåäåíà
VARIABLE_IS_ALREADY_INPUTED:
CALL SHOW_MESSAGE_ABOUT_ALREADY_INPUTED_VARIABLE
MOV FLAG_OF_JUMP, 1
JMP EXIT_FROM_PARSE
;åñëè íàäî ïðîñòî ïðåêðàòèòü ïàðñèíã
EXIT_FROM_PARSE:
POP SI
POP BX
POP CX
POP AX
CMP FLAG_OF_JUMP, 1
JNE FINISHED_PARSE
ADD SP, 2
JMP SI
FINISHED_PARSE:
RET
PARSE_INPUT_DATA ENDP

;âûâîäèì ñîîáùåíèå î íåîæèäàåìîé ïåðåìåííîé
SHOW_MESSAGE_ABOUT_UNEXPECTED_VARIABLE PROC
PUSH DX
MOV DX, offset MASSEGE_ABOUT_UNEXPECTED_VARIABLE
CALL SET_CURSOR_ON_NEXT_LINE
CALL WRITE_STRING_ON_DISPLAY
POP DX
RET
SHOW_MESSAGE_ABOUT_UNEXPECTED_VARIABLE ENDP

;ñîîáùåíèå î íåïðàâèëüíîì ôîðìàòå ââîäà
SHOW_MESSAGE_ABOUT_INVALID_INPUT_STRING PROC
PUSH DX
MOV DX, offset MESSAGE_INVALID_STRING
CALL SET_CURSOR_ON_NEXT_LINE
CALL WRITE_STRING_ON_DISPLAY
POP DX
RET
SHOW_MESSAGE_ABOUT_INVALID_INPUT_STRING ENDP

;âûâåñòè ñîîáùåíèå î òîì, ÷òî ïåðåìåííàß óæå ââåäåíà
SHOW_MESSAGE_ABOUT_ALREADY_INPUTED_VARIABLE PROC
;â ðåãèñòðå dl
PUSH DX
MOV MESSAGE_ABOUT_REPEATABLE_DATA + POSITION_FOR_IPUTED_VARIABLE_IN_MESSAGE, DL
MOV DX, offset MESSAGE_ABOUT_REPEATABLE_DATA
CALL SET_CURSOR_ON_NEXT_LINE
CALL WRITE_STRING_ON_DISPLAY
POP DX
RET
SHOW_MESSAGE_ABOUT_ALREADY_INPUTED_VARIABLE ENDP

;ïðîâåðêà ñèìâîëà íà äîïóñòèìîñòü
CHECK_SYMBOL_ON_CORRECT PROC
;ñèìâîë â ñòåêå
PUSH AX
PUSH BP
MOV RESULT_OF_CHECK_SYMBOL_ON_CORRECT, 0
MOV BP, SP
MOV AX, [BP + 6]
CMP AL, 9 ; >9
JA INVALID
CMP AL, 0; <0
JL INVALID
JMP ACROSS_INVALID_LABEL ;îáõîäèì îáðàáîòêó íåâåðíîãî ñèìâîëà
INVALID:
MOV RESULT_OF_CHECK_SYMBOL_ON_CORRECT, 1
ACROSS_INVALID_LABEL: 
POP BP
POP AX
RET 2
CHECK_SYMBOL_ON_CORRECT ENDP

CONVERT_FROM_SYMBOL_TO_DECIMAL PROC
PUSHA
MOV BX, 0
MOV AX, 0
;çàáèðàåì êîëè÷åñòâî ñèâìîëîâ â áóôåðå
MOV CH, 0
MOV CL, VARIABLE_BUFFER[BX]
INC BX
;ïðåîáðàçóåì êàæäûé ñèìâîë â ïñåâäî ÷èñëî 10 ñ.ñ.
BEGIN:
MOV AL, VARIABLE_BUFFER[BX]
SUB AL, 30h
PUSH AX
CALL CHECK_SYMBOL_ON_CORRECT
CMP RESULT_OF_CHECK_SYMBOL_ON_CORRECT, 1
JNE SYMBOL_IS_CORRECT
;âûâîäèì ñîîáùåíèå î íåêîððåêòíîì ñèìâîëå è ïåðåõîäèì íà ïîâòîð ââîäà
MOV DX, offset MESSAGE_INVALID_STRING
CALL SET_CURSOR_ON_NEXT_LINE
CALL WRITE_STRING_ON_DISPLAY
POPA
ADD SP, 2
JMP SI
;JMP FINISHED_CONVERT
SYMBOL_IS_CORRECT:
MOV VARIABLE_BUFFER[BX], AL
INC BX
LOOP BEGIN
POPA
RET
CONVERT_FROM_SYMBOL_TO_DECIMAL ENDP
 
CONVERT_FROM_DECIMAL_TO_BINARY_VALUE PROC
;ÂÎÇÂÐÀÒ ÏÎËÓ×ÅÍÍÎÃÎ ÇÍÀ×ÅÍÈß Â AX
PUSH CX
PUSH BX
PUSH DX
PUSH DI
;íà÷èíàåì ïåðåâîä
MOV BX, 1
MOV AH, 0
MOV AL, VARIABLE_BUFFER[BX]
MOV DI, 0
MOV CH, 0
MOV CL, VARIABLE_BUFFER
DEC CX
JCXZ ACROSS_CONVERT
START_CONVERT:
ADD DI, AX
CALL CHECK_OVERFLOW
MOV DX, 0
MOV AX, DI
MUL SOURCE_BASE
CALL CHECK_OVERFLOW
MOV DI, AX
INC BX
MOV AL, VARIABLE_BUFFER[BX]
MOV AH, 0
LOOP START_CONVERT
ADD DI, AX
CALL CHECK_OVERFLOW
;äîñòàåì èç ñòåêà çíà÷åíèÿ
;MOV CL, INPUT_STRING + 1
MOV AX, DI
ACROSS_CONVERT:
POP DI
POP DX
POP BX
POP CX
RET
CONVERT_FROM_DECIMAL_TO_BINARY_VALUE ENDP

ASSOCIATE_TO_VALUES_OF_VARIABLES PROC
;AX - çíà÷åíèå
;DX - èìß ïåðåìåííîé
; Ž–…„“€ Ž„€‡“Œ…‚€…’ ˆ‡Œ……ˆ… …ƒˆ‘’Ž‚!!!!
; BX - A
; DI - D
; SI - B
CMP DL, CHAR_VAR_A
JNE ASSOCIATE_WITH_B
MOV BX, AX
JMP FINISHED_ASSOCIATE
ASSOCIATE_WITH_B:
CMP DL, CHAR_VAR_B
JNE ASSOCIATE_WITH_D
MOV SI, AX
ASSOCIATE_WITH_D:
CMP DL, CHAR_VAR_D
JNE FINISHED_ASSOCIATE
MOV DI, AX
FINISHED_ASSOCIATE:
RET
ASSOCIATE_TO_VALUES_OF_VARIABLES ENDP

CALCULATE_TASK PROC
;îæèäàåòñß, ÷òî íà ñòåêå áóäóò ëåæàòü èìåíà ïåðåìåííûõ è èõ çíà÷åíèß
; AX  - ‚Ž‡€™€…Œ›‰ …‡“‹œ’€’
PUSH BP
PUSH BX
PUSH CX
MOV BP, SP
ADD BP, 6
MOV CX, COUNT_OF_INPUT_VARIABLES
;ïåðåïðûãèâàåì àäðåñ âîçâðàòà, BP, BX, CX
START_ASSOCIATION_TO_VALUES_OF_VARIABLES:
ADD BP, 2
MOV DX, [BP]
ADD BP, 2
MOV AX, [BP]
CALL ASSOCIATE_TO_VALUES_OF_VARIABLES
LOOP START_ASSOCIATION_TO_VALUES_OF_VARIABLES
;íà âûõîäå ïîëó÷àåì 
; BX - A
; DI - D
; SI - B
;'D*A/(A+B)$'
;D*A
MOV DX, 0
MOV AX, BX
MUL DI
;(A+B)
ADD BX, SI
CALL CHECK_OVERFLOW
; /
DIV BX
CALL CHECK_OVERFLOW
POP CX
POP BX
POP BP
RET COUNT_OF_INPUT_VARIABLES * 4 ;êîëè÷åñòâî çíà÷åíèé è èìåí
CALCULATE_TASK ENDP

SET_INPUT_STATUS_FOR_VARIABLE PROC
;â dl îæèäàåòñß íàõîæäåíèå èìåíèå ïåðåìåííîé
CMP DL, CHAR_VAR_A
JNE SET_STATUS_VARIABLE_B
MOV VARIABLE_A_FLAG, 1
JMP FINISHED_SET_STATUS
SET_STATUS_VARIABLE_B:
CMP DL, CHAR_VAR_B
JNE SET_STATUS_VARIABLE_D
MOV VARIABLE_B_FLAG, 1
JMP FINISHED_SET_STATUS
SET_STATUS_VARIABLE_D:
CMP DL, CHAR_VAR_D
MOV VARIABLE_D_FLAG, 1
FINISHED_SET_STATUS:
RET
SET_INPUT_STATUS_FOR_VARIABLE ENDP

CHECK_INPUT_STATUS_FOR_VARIABLE PROC
;â dl îæèäàåòñß íàõîæäåíèå èìåíèå ïåðåìåííîé
;îáíóëßåì çíà÷åíèå ôëàãà ïåðåä ïðîâåðêîé
MOV RESULT_OF_CHECK_INPUT_STATUS, 0
CMP DL, CHAR_VAR_A
JNE CHECK_STATUS_VARIABLE_B
CMP VARIABLE_A_FLAG, 1
JNE FINISHED_CHECK_STATUS
JMP SET_RESULT_OF_CHECK_STATUS
CHECK_STATUS_VARIABLE_B:
CMP DL, CHAR_VAR_B
JNE CHECK_STATUS_VARIABLE_D
CMP VARIABLE_B_FLAG, 1
JNE FINISHED_CHECK_STATUS
JMP SET_RESULT_OF_CHECK_STATUS
CHECK_STATUS_VARIABLE_D:
CMP DL, CHAR_VAR_D
CMP VARIABLE_D_FLAG, 1
JNE FINISHED_CHECK_STATUS
SET_RESULT_OF_CHECK_STATUS:
MOV RESULT_OF_CHECK_INPUT_STATUS, 1
FINISHED_CHECK_STATUS:
RET
CHECK_INPUT_STATUS_FOR_VARIABLE ENDP


;äåëèòü êàæäûé ðàç íà 10
GET_SYMBOL_VALUE_FROM_BINARY_TO_OUTPUT_BUFFER PROC
;AX - èñõîäíîå çíà÷åíèå
; çàïèñü ñèìâîëüíîãî ïðåäñòàâëåíèÿ ÷èñëà â áóôåð âûâîäà
PUSH BX
PUSH DX
PUSH CX
PUSH DI
PUSH AX
MOV CX, 0
MOV BX, 10
BEGIN_GET_SYMBOL_VALUE:
MOV DX, 0
INC CX
DIV BX
;ñêëàäûâàåì â ñòåê îñòàòîê
PUSH DX
CMP AX, 0
JNE BEGIN_GET_SYMBOL_VALUE
MOV DI, 0
WRITE_SYMBOL_VALUE_IN_MEMORY:
POP DX
ADD DX, 30h
MOV OUTPUT_STRING[DI], DL
INC DI
LOOP WRITE_SYMBOL_VALUE_IN_MEMORY
MOV OUTPUT_STRING[DI], '$'
POP AX
POP DI
POP CX
POP DX
POP BX
RET
GET_SYMBOL_VALUE_FROM_BINARY_TO_OUTPUT_BUFFER ENDP

REMOVE_INPUTED_SYMBOL_FROM_AVAILABLE PROC
;DL - èìß ïåðåìåííîé
;'Please, using only those names for variables: (A, B, D)$'
;SI - îòêóäà
;DI - êóäà ïèñàòü
PUSH DI
PUSH SI
PUSH AX
CLD
LEA SI, MESSAGE_ABOUT_AVAILABLE_VARIABLES
LEA DI, MESSAGE_ABOUT_AVAILABLE_VARIABLES
;íà÷èíàåì óäàëßòü
START_REMOVE:
LODSB
CMP AL, DL
JNE ACROSS_REMOVE
;ïîñëåäíèé ñèìâîë íàäî óäàëèòü ïî îñîáîìó 
CMP [SI], BYTE PTR ')'
JNE ACROSS_REMOVE_LAST_SYMBOL
SUB DI, 2
JMP START_REMOVE
ACROSS_REMOVE_LAST_SYMBOL:
;óäàëßåì íå ïîñëåäíèé
ADD SI, 2
JMP START_REMOVE
ACROSS_REMOVE:
STOSB
CMP AL, '$'
JNE START_REMOVE
POP AX
POP SI
POP DI
RET
REMOVE_INPUTED_SYMBOL_FROM_AVAILABLE ENDP

; Start of program
START:     

; ################
; Load data segment

MOV SI, DATA
MOV DS, SI ; Can't move to segment reg. constant, thats why use reg. SI.
MOV ES, SI         

; ################

; ################
; Output text for user

MOV INPUT_FLAG, 1
MOV DX, offset MESSAGE_ABOUT_TASK
CALL WRITE_STRING_ON_DISPLAY
CALL SET_CURSOR_ON_NEXT_LINE  
 
MOV DX, offset MESSAGE_ABOUT_INPUT_FORMAT
CALL WRITE_STRING_ON_DISPLAY 
  
; ################
  
START_INPUT_OF_VARIABLES:

MOV CX, COUNT_OF_INPUT_VARIABLES
LEA SI, START_LOOP_OF_INPUT_DATA 

START_LOOP_OF_INPUT_DATA:

CALL SET_CURSOR_ON_NEXT_LINE
MOV DX, offset MESSAGE_ABOUT_AVAILABLE_VARIABLES
CALL WRITE_STRING_ON_DISPLAY
CALL SET_CURSOR_ON_NEXT_LINE  

MOV DX, offset INPUT_STRING
CALL READ_INPUT_DATA
CALL PARSE_INPUT_DATA
CALL CONVERT_FROM_SYMBOL_TO_DECIMAL
CALL SET_INPUT_STATUS_FOR_VARIABLE
CALL CONVERT_FROM_DECIMAL_TO_BINARY_VALUE

; Set to stack variable name and value

PUSH AX
PUSH DX
CALL REMOVE_INPUTED_SYMBOL_FROM_AVAILABLE
LOOP START_LOOP_OF_INPUT_DATA

LEA SI, START_INPUT_OF_VARIABLES
MOV INPUT_FLAG, 0
CALL CALCULATE_TASK
CALL GET_SYMBOL_VALUE_FROM_BINARY_TO_OUTPUT_BUFFER
MOV DX, offset OUTPUT_STRING
CALL SET_CURSOR_ON_NEXT_LINE
CALL WRITE_STRING_ON_DISPLAY

CALL EXIT_PROGRAM
C ENDS
END START
