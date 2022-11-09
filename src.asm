.386							; Директива для использования набора операций процессора 80386
.MODEL FLAT, STDCALL			; Определяем модель памяти
OPTION CASEMAP: NONE
EXTERN  GetStdHandle@4   : PROC ; Получение дескриптора.
EXTERN  WriteConsoleA@20 : PROC ; Вывод в консоль.
EXTERN  CharToOemA@8     : PROC ; Строку в OEM кодировку.
EXTERN  ReadConsoleA@20  : PROC ; Ввод с консоли.
EXTERN  ExitProcess@4    : PROC ; Функция выхода из программы.
EXTERN  lstrlenA@4       : PROC ; Функция определения длины строки.
EXTERN  wsprintfA		 : PROC ; Преобразование переменной в символ


.DATA
	STRin1		DB "Enter the first string: ", 13, 10, 0
	STRin2		DB "Enter the second string: ", 13, 10, 0
	STRout		DB "This characters from the first string are not present in the second string: ", 0
	STRoutErr	DB "String was not entered.", 13, 10, 0
	STRend		DB 13, 10, "Program ended.", 13, 10, 0
	TMP			DB "%d ",0		; Номер символа в строчном виде
	DIN			DD ?			; Дескриптор ввода
	DOUT		DD ?			; Дескриптор вЫвода
	LENS		DD ?			; Количество выведеных символов
	LENS1		DD ?			; Длина первой строки
	LENS2		DD ?			; Длина второй строки
	STR1		DB 200 DUP (?)	; Первая строка
	STR2		DB 200 DUP (?)	; Вторая строка
	BUF			DB 200 DUP (?)	; Буфер для вывода номера сивола
	COUNT		DD ?			; Номер символа

.CODE
MAIN PROC
	; Помещаем дескриптор ввода в DIN
	PUSH -10
	CALL GetStdHandle@4
	MOV DIN, EAX

	; Помещаем дескриптор вывода в DOUT
	PUSH -11
	CALL GetStdHandle@4
	MOV DOUT, EAX

	; Перекодировка STRin1
	MOV EAX, OFFSET STRin1
	PUSH EAX
	PUSH EAX
	CALL CharToOemA@8
	; Выводим строку на экран консоли
	PUSH OFFSET STRin1
	CALL lstrlenA@4
	PUSH 0
	PUSH OFFSET LENS
	PUSH EAX
	PUSH OFFSET STRin1
	PUSH DOUT
	CALL WriteConsoleA@20

	; Ввод первой строки
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

	SUB LENS1, 2			; Удаляем служебные символы
	SUB LENS2, 2

	CMP LENS1, 0			; Проверяем ввели ли строки
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

	; Обход первой строки
	CLD						; Очищаем флаг направления, обрабатываем по возрастанию адресов (DF = 0)
	XOR ESI, ESI			; Очищаем регистры
	XOR EDI, EDI
	XOR EDX, EDX
	XOR ECX, ECX
	MOV ESI, OFFSET STR1	; Помещаем адрес первой строки в ESI
	MOV ECX, LENS1			; Помещаем длину первой сроки в ECX - счетчик
	MOV COUNT, 1			; Нумеруем символы с 1
LP:
	MOV AL, [ESI]			; Помещаем адрес первого символа первой строки в AL
	MOV EBX, ECX			; Помещаем счетчик первой строки в EBX
	MOV ECX, LENS2			; Помещаем длину второй строки в ECX - счетчик использования SCAS
	LEA EDI, OFFSET STR2	; Помещаем в EDI адрес второй строки
	REPNE SCAS STR2			; Сканируем строку пока не встретим равные символы
	JE EQUAL

		; Если не встретили равных символов, выводин номер
		MOV EDX, COUNT
		PUSH EDX
		PUSH OFFSET TMP
		PUSH OFFSET BUF
		CALL wsprintfA		; Переводим номер символа из числа в строку
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
		INC ESI				; Переходим на следующий символ первой строки
		INC COUNT
		MOV ECX, EBX
	LOOP LP

	; Вывод сообщения о завершении программы
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
