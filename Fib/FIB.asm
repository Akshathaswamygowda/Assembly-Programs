_PutStr MACRO   TheString
        MOV     DX, OFFSET TheString
        MOV     AH, 09H
        INT     21H
        ENDM
_GetCh  MACRO   
        mov     ah, 01h
        int     21h
        ENDM        
_PutCh  MACRO C
        mov     dl, C
        mov     ah, 02h
        int     21h
        ENDM
.model small
.stack  100h
.data
Banner  DB  "CECS 524 Function Solver", 13, 10, '$'
Prompt  DB  "Enter a number:$"
Answer  DB  " Fib of $"
Answer2 DB  " is $"
.code
MAIN    PROC
    MOV     AX, @DATA
    MOV     DS, AX
    PUSH    BP          ;stack frame for MAIN
    MOV     BP, SP
    SUB     SP, 6  
   _PutStr Banner
   _PutStr prompt
    CALL    GetDec
    MOV     [BP-2], AX  ;save n
    PUSH    AX
    CALL    Fib
    MOV     [BP-4], AX  ;factorial 
    
    _PutStr Answer
    MOV     AX, [BP-2]
    CALL    PutDec
    _PutStr Answer2
    MOV     AX, [BP-4]
    CALL    PutDec
    
    MOV     AH, 4CH
    INT     21H
    
MAIN    ENDP

;Fib proc
    ;push BP
    ;MOV BP, SP
    ;CMP WORD PTR[BP+4], 1
    ;JE RETURN1
    ;CMP WORD PTR[BP+4], 0
    ;JE RETURN0
    ;MOV AX, WORD PTR[BP+4]
    ;CMP AX, 2
    ;JLE RETURN1
    ;DEC AX
    ;PUSH AX
    ;CALL Fib
    ;LOOP1:
    ;CMP WORD PTR[BP+4], 2
    ;JLE RETURN1
    ;DEC WORD PTR[BP+4]
    ;LOOP LOOP1
    ;ADD AX, WORD PTR[BP+4] 
    ;POP BP
    ;RET 2                            
    
      
;MOV DX, WORD PTR[BP+4]
;MOV CX,1H
;MOV BX,0H  
;Mov AX, BX
 ;Loop1:
 ;ADD AX,CX
 ;MOV BX, CX
 ;MOV CX, AX
 ;DEC DX
 ;JNZ Loop1
    
Fib Proc
    
PUSH BP
MOV BP,SP
CMP WORD PTR[BP+4], 1
JE RETURN1
CMP WORD PTR[BP+4], 0
JE RETURN0  
CMP WORD PTR[BP+4],2
JE RETURN1
MOV CX, WORD PTR[BP+4]
MOV DX,1H
MOV AX,0H 
;Mov AX, BX
Loop1:
ADD AX,DX
MOV BX,AX
MOV AX,DX
MOV DX,BX   
LOOP Loop1 
POP BP
RET 2 

 
RETURN1:
    MOV     AX, 1
    POP     BP
    RET     2 
RETURN0:
    MOV AX,0
    POP BP
    RET 2
    
Fib ENDP
    
    
    
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;IGNORE EVERYTHING BELOW HERE BUT LEAVE IT IN  

M32768  db  '-32768$'
    
    
PutDec  PROC
    push    ax
    push    bx
    push    cx
    push    dx
    cmp ax, -32768 ;    -32768 is a special case as there
    jne TryNeg ;      is no representation of +32768
    _PutStr M32768
    jmp Done
TryNeg:
    cmp ax, 0 ;     If number is negative ...
    jge NotNeg
    mov bx, ax ;      save from it from _PutCh
    neg bx ;          make it positive and...
    _PutCh  '-' ;         display a '-' character
    mov ax, bx ;    To prepare for PushDigs
NotNeg:
    mov cx, 0 ;     Initialize digit count
    mov bx, 10 ;    Base of displayed number
PushDigs:
    sub dx, dx ;    Convert ax to unsigned double-word
    div bx
    add dl, '0' ;   Compute the Ascii digit...
    push    dx ;        ...push it (can push words only)...
    inc cx ;        ...and count it
    cmp ax, 0   ;   Don't display leading zeroes
    jne PushDigs
;
PopDigs:    ;       Loop to display the digits
    pop dx ;          (in reverse of the order computed)
    _PutCh  dl
    loop    PopDigs
Done:
    pop dx ;    Restore registers
    pop cx
    pop bx
    pop ax
    ret
PutDec  ENDP
    
Sign    DB  ?
    
    
GetDec  PROC
    push    bx ;        Don't need to save ax, but bx, cx, ...
    push    cx ;        ...dx must be saved and restored
    push    dx
    mov bx, 0 ;     accumulated NumberValue in bx := 0
    mov cx, 10
    mov Sign, '+' ; Guess that sign will be '+'
    _GetCh  ;       Read character ==> al
    cmp al, '-' ;   Is first character a minus sign?
    jne AfterRead
    mov Sign, '-' ;   yes
ReadLoop:
    _GetCh
AfterRead:
    cmp al, '0' ;   Is character a digit?
    jl  Done2 ;        No
    cmp al, '9'
    jg  Done2 ;        No
    sub al, '0' ;     Yes, cvt to DigitValue and extend to a
    mov ah, 0 ;        word (so we can add it to NumberValue)
    xchg    ax, bx ;    Save DigitValue
        ;          and set up NumberValue for mul
    mul cx ;        NumberValue * 10 ...
    add ax, bx ;      + DigitValue ...
    mov bx, ax ;      ==> NumberValue
    jmp ReadLoop
    Done2:
    cmp al, 13 ;    If last character read was a RETURN...
    jne NoLF
    _PutCh 10 ;     ...echo a matching line feed
NoLF:
    cmp Sign, '-'
    jne Positive
    neg bx ;        Final result is in bx
Positive:
    mov ax, bx ;    Returned value --> ax
    pop dx ;        restore registers
    pop cx
    pop bx
    ret
GetDec  ENDP
END MAIN   

