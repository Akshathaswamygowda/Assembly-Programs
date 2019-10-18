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
.stack 100h
.data
prompt DB "Enter the number:",'$'
Answer DB "The factorial is: ",'$'
.code
 MAIN PROC
 MOV AX, @data
 MOV DS, AX
 PUSH BP
 MOV BP,SP
 SUB SP, 4
 ;Ask the user to enter the number
 _PutStr prompt
 CALL GetDec
 MOV WORD PTR[BP-2], AX
 PUSH AX
 CALL FACT
 MOV WORD PTR[BP-4], AX
 ;to display the factorial number
  _PutStr Answer
  MOV AX,WORD PTR[BP-4]
 CALL PutDec
 MOV AH,4CH
 int 21H
 MAIN ENDP
 
FACT PROC
PUSH BP
MOV BP, SP
CMP WORD PTR[BP+4],1
JE RETURN1
MOV AX, WORD PTR[BP+4]
DEC AX
PUSH AX
CALL FACT
IMUL WORD PTR[BP+4]
POP BP
RET 2
RETURN1:
    MOV AX, 1
    POP BP
    RET 2
FACT ENDP 


 .DATA
M32768  db  '-32768$'
    .CODE
   
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
    .DATA
Sign    DB  ?
    .CODE
    
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