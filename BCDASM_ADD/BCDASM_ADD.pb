


PrototypeC.l AddBCD(dst,src1,src2)

s1=AllocateMemory(100)
s2=AllocateMemory(100)
d=AllocateMemory(100)

AddBCD.AddBCD = ?AddBCDString

PokeS(s1,"0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000123",-1, #PB_Ascii)
PokeS(s2,"0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000339",-1, #PB_Ascii)
AddBCD(d,s1,s2)
Debug PeekS(d,-1, #PB_Ascii)

End

AddBCDString:
!StringErgebnis EQU [EBP+8]
!StringA EQU [EBP+12]
!StringB EQU [EBP+16]
!ENTER 0,0

!MOV ESI, StringA
!MOV EBX, StringB
!MOV EDI, StringErgebnis

!ADD ESI,99
!ADD EBX,99
!ADD EDI,99

!XOR EAX,EAX
!XOR EDX,EDX

!MOV ECX, 100
;!MOV DH, '0' ; wird nicht benötigt
!Numbers:
!SUB AH, AH
!MOV AL, [ESI] ; Zeichen von StringA
!MOV DL, [EBX] ; Zeichen von StringB

!ADD AL, DH ; vorheriger Übertrag addieren (am Anfang 0)
!AAA
!OR AX, 3030H

!MOV DH, AH ; Übertrag sichern
!XOR AH, AH

!ADD AL, DL 
!AAA
!OR AX, 3030H

!MOV byte[EDI], AL ; Zeichen im Ergebnisstring speichern

!MOV AL, AH ; Beide Überträge zusammenaddieren
!XOR AH, AH
!ADD AL, DH
!AAA
!OR AL, 30H
!MOV DH, AL

!DEC ESI
!DEC EBX
!DEC EDI
!Loop Numbers

!LEAVE
!RET
