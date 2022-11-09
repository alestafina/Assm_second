.386							; ��������� ��� ������������� ������ �������� ���������� 80386
.MODEL FLAT, STDCALL			; ���������� ������ ������
OPTION CASEMAP: NONE
EXTERN  GetStdHandle@4   : PROC ; ��������� �����������.
EXTERN  WriteConsoleA@20 : PROC ; ����� � �������.
EXTERN  CharToOemA@8     : PROC ; ������ � OEM ���������.
EXTERN  ReadConsoleA@20  : PROC ; ���� � �������.
EXTERN  ExitProcess@4    : PROC ; ������� ������ �� ���������.
EXTERN  lstrlenA@4       : PROC ; ������� ����������� ����� ������.
EXTERN  wsprintfA		 : PROC ; �������������� ���������� � ������


.DATA
	STRin1		DB "Enter the first string: ", 13, 10, 0
	STRin2		DB "Enter the second string: ", 13, 10, 0
	STRout		DB "This characters from the first string are not present in the second string: ", 0
	STRoutErr	DB "String was not entered.", 13, 10, 0
	STRend		DB 13, 10, "Program ended.", 13, 10, 0
	TMP			DB "%d ",0		; ����� ������� � �������� ����
	DIN			DD ?			; ���������� �����
	DOUT		DD ?			; ���������� ������
	LENS		DD ?			; ���������� ��������� ��������
	LENS1		DD ?			; ����� ������ ������
	LENS2		DD ?			; ����� ������ ������
	STR1		DB 200 DUP (?)	; ������ ������
	STR2		DB 200 DUP (?)	; ������ ������
	BUF			DB 200 DUP (?)	; ����� ��� ������ ������ ������
	COUNT		DD ?			; ����� �������

.CODE
MAIN PROC
	; �������� ���������� ����� � DIN
	PUSH -10
	CALL GetStdHandle@4
	MOV DIN, EAX

	; �������� ���������� ������ � DOUT
	PUSH -11
	CALL GetStdHandle@4
	MOV DOUT, EAX

	; ������������� STRin1
	MOV EAX, OFFSET STRin1
	PUSH EAX
	PUSH EAX
	CALL CharToOemA@8
	; ������� ������ �� ����� �������
	PUSH OFFSET STRin1
	CALL lstrlenA@4
	PUSH 0
	PUSH OFFSET LENS
	PUSH EAX
	PUSH OFFSET STRin1
	PUSH DOUT
	CALL WriteConsoleA@20

	; ���� ������ ������
	PUSH 0
	PUSH OFFSET LENS1
	PUSH 200
	PUSH OFFSET STR1
	PUSH DIN
	CALL ReadConsoleA@20

	MOV EAX, OFFSET STRin2
	PUSH EAX
	PUSH EAX
	CALL CharToOemA@8

	PUSH OFFSET STRin2
	CALL lstrlenA@4
	PUSH 0
	PUSH OFFSET LENS
	PUSH EAX
	PUSH OFFSET STRin2
	PUSH DOUT
	CALL WriteConsoleA@20

	PUSH 0
	PUSH OFFSET LENS2
	PUSH 200
	PUSH OFFSET STR2
	PUSH DIN
	CALL ReadConsoleA@20

	SUB LENS1, 2			; ������� ��������� �������
	SUB LENS2, 2

	CMP LENS1, 0			; ��������� ����� �� ������
	JE ZERO
	CMP LENS2, 0
	JE ZERO

	MOV EAX, OFFSET STRout
	PUSH EAX
	PUSH EAX
	CALL CharToOemA@8
	PUSH OFFSET STRout
	CALL lstrlenA@4
	PUSH 0
	PUSH OFFSET LENS
	PUSH EAX
	PUSH OFFSET STRout
	PUSH DOUT
	CALL WriteConsoleA@20

	; ����� ������ ������
	CLD						; ������� ���� �����������, ������������ �� ����������� ������� (DF = 0)
	XOR ESI, ESI			; ������� ��������
	XOR EDI, EDI
	XOR EDX, EDX
	XOR ECX, ECX
	MOV ESI, OFFSET STR1	; �������� ����� ������ ������ � ESI
	MOV ECX, LENS1			; �������� ����� ������ ����� � ECX - �������
	MOV COUNT, 1			; �������� ������� � 1
LP:
	MOV AL, [ESI]			; �������� ����� ������� ������� ������ ������ � AL
	MOV EBX, ECX			; �������� ������� ������ ������ � EBX
	MOV ECX, LENS2			; �������� ����� ������ ������ � ECX - ������� ������������� SCAS
	LEA EDI, OFFSET STR2	; �������� � EDI ����� ������ ������
	REPNE SCAS STR2			; ��������� ������ ���� �� �������� ������ �������
	JE EQUAL

		; ���� �� ��������� ������ ��������, ������� �����
		MOV EDX, COUNT
		PUSH EDX
		PUSH OFFSET TMP
		PUSH OFFSET BUF
		CALL wsprintfA		; ��������� ����� ������� �� ����� � ������
		MOV EAX, OFFSET BUF
		PUSH EAX
		PUSH EAX
		CALL CharToOemA@8
		PUSH OFFSET BUF
		CALL lstrlenA@4
		PUSH 0
		PUSH OFFSET LENS
		PUSH EAX
		PUSH OFFSET BUF
		PUSH DOUT
		CALL WriteConsoleA@20
EQUAL:
		INC ESI				; ��������� �� ��������� ������ ������ ������
		INC COUNT
		MOV ECX, EBX
	LOOP LP

	; ����� ��������� � ���������� ���������
	LEA EAX, STRend
	PUSH EAX						
	PUSH EAX
	CALL CharToOemA@8
	PUSH OFFSET STRend
	CALL lstrlenA@4
	PUSH 0
	PUSH OFFSET LENS
	PUSH EAX
	PUSH OFFSET STRend
	PUSH DOUT
	CALL WriteConsoleA@20

EXIT:
	PUSH 0
	CALL ExitProcess@4

ZERO:
	MOV EAX, OFFSET STRoutErr
	PUSH EAX
	PUSH EAX
	CALL CharToOemA@8
	PUSH OFFSET STRoutErr
	CALL lstrlenA@4
	PUSH 0
	PUSH OFFSET LENS
	PUSH EAX
	PUSH OFFSET STRoutErr
	PUSH DOUT
	CALL WriteConsoleA@20
	JMP EXIT

MAIN ENDP
END MAIN
