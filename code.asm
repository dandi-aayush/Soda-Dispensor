.MODEL TINY 
.DATA
    COINS	DB	3,2,1	;NUMBER OF COINS REQUIRED FOR EACH VOLUME OF DRINK
    COINS_HEX	DB	09H,05H,03H	;HEX VALUES FOR THE ABOVE
    AMOUNT	DB	5,100,100		;ASSUMING INITIAL QUANTITIES TO BE 5mL, 100mL, 100mL RESPECTIVELY FOR COLA,LIME AND MANGO
    ;SETTING VARIABLES FOR PORTS
    PORT1A	EQU	00H
    PORT1B	EQU	02H
    PORT1C	EQU 04H
    CREG1	EQU 06H
    PORT2A	EQU 10H
    PORT2B	EQU 12H
    PORT2C	EQU 14H
    CREG2	EQU 16H
    PORT3A	EQU 20H
    PORT3B	EQU 22H
    PORT3C	EQU 24H
    CREG3	EQU 26H
    PORT4A	EQU 30H
    PORT4B	EQU 32H
    PORT4C	EQU 34H
    CREG4	EQU 36H
.CODE
.STARTUP

	MOV AL,99H
	OUT 06H,AL
	MOV AL,99H
	OUT CREG2,AL
	MOV AL,90H                  ;INITIALIZING ALL THE OUTPUT PORTS
	OUT CREG3,AL
	MOV AL,80H
	OUT CREG4,AL
;____________________________________________________
X31:

	CALL ZERO_SET

;____________________________________________________
;CHECKING INITIAL AMOUNT FOR ALL DRINKS, LIGHTING UP LED CORRESPONDING TO DRINKS WITH INITIAL AMOUNT ZERO
	MOV AL,00H
    MOV BL,00H
    CMP BL,AMOUNT
    JNZ X24
    OR AL,01H
    OUT PORT4B,AL

X24:
    CMP BL,AMOUNT+1
    JNZ X25
    OR AL,02H
    OUT PORT4B,AL

X25:
    CMP BL,AMOUNT+2
    JNZ X1
    OR AL,04H
    OUT PORT4B,AL
;____________________________________________________
;CHECKING THE VALUE AT ALL 3 PORTS SIAMENTANIOUSLY, LOOKING FOR WHICH COLD DRINK IS ORDERED
X1:	
   IN AL,PORT1A
   CMP AL,00H
   MOV CL,01H
   JNZ X2
   IN AL,PORT2A
   CMP AL,00H
   MOV CL,02H
   JNZ X3
   IN AL,PORT3A
   CMP AL,00H
   MOV CL,03H
   JNZ X4
   JMP X1
;____________________________________________________
;LIGHTING THE LED CORRESPONDING TO THE DRINK ORDERED
X2:
   MOV AL,01H
   OUT PORT1B,AL
   JMP X5
X3:
   MOV AL,01H
   OUT PORT2B,AL
   JMP X5
X4:
   MOV AL,01H
   OUT PORT3B,AL
   JMP X5
;____________________________________________________
;TAKING INPUTS FOR THE VOLUME OF THE SELECTED DRINK: SMALL/MEDIUM/LARGE, IN AN INFINITE LOOP
X5:
   IN AL,PORT1A
   MOV CH,AL
   CMP AL,02H
   JZ X6
   CMP AL,04H
   JZ X6
   CMP AL,08H
   JZ X6
   IN AL,PORT2A
   MOV CH,AL
   CMP AL,02H
   JZ X7
   CMP AL,04H
   JZ X7
   CMP AL,08H
   JZ X7
   IN AL,PORT3A
   MOV CH,AL
   CMP AL,02H
   JZ X8
   CMP AL,04H
   JZ X8
   CMP AL,08H
   JZ X8
   JMP X5
;____________________________________________________
;LIGHTING THE LED CORRESPONDING TO THE VOLUME DESIRED
X6:
    OR AL,01H
    OUT PORT1B,AL
    JMP X9
X7:
    OR AL,01H
    OUT PORT2B,AL
    JMP X9
X8:
    OR AL,01H
    OUT PORT3B,AL
    JMP X9
;____________________________________________________
;[SI] REPRESENTS THE NO OF COINS REQUIRED FOR EACH TYPE OF DRINK
X9:
    LEA SI,COINS
    LEA DI,COINS_HEX
    DEC SI
    DEC DI
    MOV DX,00H  
X10:
    INC SI
    INC DI
    CMP [DI],AL
    JNZ X10
;____________________________________________________
;TAKING THE COINS INPUT UNTIL AS DISPENSE IS PRESSED
X11:
    IN AL,PORT1C
    MOV AH,AL
    IN AL,PORT2C
    CMP AH,00H
    JZ X12                   
    INC DX
    CALL DELAY_025SEC
	
X12:
    CMP AL,00H
    JZ X11
;____________________________________________________
;EXECUTION IS GOING TO END HERE IF COINS ENTERED ARE DIFFERENT FROM WHAT IS EXPECTED THEN
;THE ERROR LED IS LIT FOR 2 SECONDS AND THE PROCESS RESTARTS
    CMP DL,[SI]
    JZ X13
    MOV AL,01H
    OUT PORT3C,AL
    CALL DELAY_1SEC
    CALL DELAY_1SEC
    CALL ZERO_SET
    JMP X23
;____________________________________________________
;CHECKING FOR WHICH TYPE WAS CHOSEN
X13:
    CMP CL,01H
    JZ X14
    CMP CL,02H               
    JZ X15
    CMP CL,03H
    JZ X16
;____________________________________________________FOR COLA____________________________________________________
;CHECKING FOR WHICH SIZE WAS CHOSEN AND GLOWING THE CORRESPONDING LED OF COLD DRINK FOR 1,2 OR 3 SECONDS FOR SMALL
;MEDIUM AND LARGE RESPECTIVELY AND DECREASING AMOUNT BY 1,2,3 ML RESPECTIVELY
;CHECKING IF THE DESIRED AMOUNT IS PRESENT
X14:
    CMP CH,02H		
    JNZ X17		;ELSE SMALL
    MOV AL,AMOUNT    
    SUB AL,1
    CMP AL,00
    JL X100
    MOV AL,01H
    OUT PORT4A,AL
    CALL DELAY_1SEC
    SUB AMOUNT,1
    CALL ZERO_SET
    JMP X23
X17:
    CMP CH,04H
    JNZ X18		;ELSE MEDIUM
    MOV AL,AMOUNT    
    SUB AL,2
    CMP AL,00
    JL X100
    MOV AL,01H
    OUT PORT4A,AL
    CALL DELAY_1SEC
    CALL DELAY_1SEC
    SUB AMOUNT,2
    CALL ZERO_SET                         
    JMP X23
X18:
    MOV AL,AMOUNT    
    SUB AL,3
    CMP AL,00
    JL X100
    MOV AL,01H
    OUT PORT4A,AL
    CALL DELAY_1SEC
    CALL DELAY_1SEC
    CALL DELAY_1SEC
    SUB AMOUNT,3
    CALL ZERO_SET
    JMP X23
;____________________________________________________FOR LIME____________________________________________________
;SAME AS ABOVE EXCEPT THAT THE UPPER WAS FOR COLA, THIS IS FOR LIME
X15:
    CMP CH,02H
    JNZ X19  	;else small
    MOV AL,AMOUNT+1    
    SUB AL,1
    CMP AL,00
    JL X101
    MOV AL,02H
    OUT PORT4A,AL
    CALL DELAY_1SEC
    SUB AMOUNT+1,1
    CALL ZERO_SET
    JMP X23
X19:
	
    CMP CH,04H
    JNZ X20			;else medium
    MOV AL,AMOUNT+1    
    SUB AL,2
    CMP AL,00
    JL X101
    MOV AL,02H
    OUT PORT4A,AL
    CALL DELAY_1SEC
    CALL DELAY_1SEC
    SUB AMOUNT+1,2
    CALL ZERO_SET
    JMP X23
	
X20:
    MOV AL,AMOUNT+1    
    SUB AL,3
    CMP AL,00
    JL X101
    MOV AL,02H
    OUT PORT4A,AL
    CALL DELAY_1SEC
    CALL DELAY_1SEC
    CALL DELAY_1SEC
    SUB AMOUNT+1,3
    CALL ZERO_SET
    JMP X23
;____________________________________________________FOR MANGO____________________________________________________
;SAME AS ABOVE 2 BUT FOR MANGO
X16:
    MOV AL,04H
    OUT PORT4A,AL
    CMP CH,02H
    JNZ X21			;else small
    MOV AL,AMOUNT+2    
    SUB AL,1
    CMP AL,00
    JL X102
    MOV AL,04H
    OUT PORT4A,AL
    CALL DELAY_1SEC
    SUB AMOUNT+2,1
    CALL ZERO_SET
    JMP X23
	
X21:
    CMP CH,04H
    JNZ X22			;else medium
    MOV AL,AMOUNT+2    
    SUB AL,2
    CMP AL,00
    JL X102
    MOV AL,04H
    OUT PORT4A,AL
    CALL DELAY_1SEC
    CALL DELAY_1SEC
    SUB AMOUNT+2,2
    CALL ZERO_SET
    JMP X23
	
X22:
    MOV AL,AMOUNT+2    
    SUB AL,3
    CMP AL,00
    JL X102
    MOV AL,04H
    OUT PORT4A,AL
    CALL DELAY_1SEC
    CALL DELAY_1SEC
    CALL DELAY_1SEC
    SUB AMOUNT+2,3
    CALL ZERO_SET
    JMP X23
;________________________________________________________________________________________________________  
X100:  
    MOV AL,01H
    OUT PORT3C,AL
    CALL DELAY_1SEC 
    MOV AL,01H
    OUT PORT4B,AL
    CALL DELAY_1SEC
    CALL DELAY_1SEC
    JMP x23

X101:  
    MOV AL,01H
    OUT PORT3C,AL
    CALL DELAY_1SEC 
    MOV AL,02H          
    OUT PORT4B,AL
    CALL DELAY_1SEC
    CALL DELAY_1SEC
    JMP x23
	
X102:  
    MOV AL,01H
    OUT PORT3C,AL
    CALL DELAY_1SEC 
    MOV AL,04H
    OUT PORT4B,AL
    CALL DELAY_1SEC
    CALL DELAY_1SEC
    JMP x23	
	
X23: 
    JMP X31

.EXIT

DELAY_1SEC PROC NEAR
    MOV BX,0FFFFH 
    X30:NOP
    DEC BX 
    JNZ X30
    MOV BX,0FFFFH
    X40:NOP
    DEC BX 
    JNZ X40
    MOV BX,0FFFFH
    X41:NOP
    DEC BX 
    JNZ X41
    MOV BX,0FFFFH
    X42:NOP
    DEC BX 
    JNZ X42
    RET
DELAY_1SEC ENDP

DELAY_025SEC PROC NEAR
    MOV BX,0FFFFH 
    X30:NOP
    DEC BX 
    JNZ X30
    RET
DELAY_025SEC ENDP

ZERO_SET PROC NEAR
    MOV AL,00
    OUT PORT1B,AL
    MOV AL,00
    OUT PORT2B,AL
    MOV AL,00
    OUT PORT3B,AL
    MOV AL,00
    OUT PORT3C,AL
    MOV AL,00
    OUT PORT4B,AL
    MOV AL,00
    OUT PORT4A,AL
    RET
ZERO_SET ENDP   
END