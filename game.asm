TITLE Number Crush Game 
;**********************************************************************************************
;*		   Computer Organization & Assembly Language Fall 2021 Final Project				  
;*														FAST_NUCES									  
;**********************************************************************************************

INCLUDE Irvine32.inc

;::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::;
;:::::::::::::::<< prototypes of parameterized procedures >>:::::::::::::::::::;
;::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::;
drawBoard PROTO, Board:PTR DWORD
takeInput PROTO , Board:PTR DWORD
swapCell PROTO ,  Board:  PTR DWORD, row1:DWORD, col2:DWORD, row2:DWORD, col2:DWORD
checkBombs PROTO, Board :  PTR DWORD
checkCombo PROTO, Board:PTR DWORD
removeInitialCombos PROTO, Board: PTR DWORD
checkRowCombination PROTO, Board:PTR DWORD
checkColCombination PROTO, Board:PTR DWORD
dropNumbers PROTO, Board: PTR DWORD
dropNum PROTO, Board:PTR DWORD
colorNum PROTO , num:DWORD
colorNum1 PROTO , num:DWORD
convertNumBytetoString PROto, num:BYTE, strnum: PTR BYTE
saveinFile PROTO, levelScore:BYTE, _score:DWORD


.data
;Board vars
board1 DWORD 100 DUP(0) ;level1 board
board2 DWORD 100 DUP(0) ;level2 board
board3 DWORD 100 DUP(0)	;level3 board

;cells vars
rowSize DWORD 40 ;10 rows*4 bytes = 40 
colSize DWORD 4
row DWORD 0
column DWORD 0
isLevel3Board DWORD 0
; welcome screen strings
prmpt0 BYTE  "*******************************", 0dh, 0ah, 0
prmpt1 BYTE "By: ",0
prmpt2 BYTE "Zainab Shehzadi 20F-1085",0
prmpt3 BYTE "Ushna Yaqoob 20F-0209",0
prmpt4 BYTE "Urvah Mubashir 19F-0405",0dh, 0ah,0
prompt0 BYTE "****Welcome to Number Crush****",  0dh, 0ah,0
prompt8 BYTE "Enter your name: ", 0

;end game screen string
prmpt5 BYTE "END GAME", 0


;cells input strings
prompt1 BYTE "Enter Cell#01's row to swap: ",0
prompt2 BYTE "Enter Cell#01's column to swap: ",0
prompt3 BYTE "Enter Cell#02's row to swap: ",0
prompt4 BYTE "Enter Cell#02's column to swap: ",0


;MACROS
displayString MACRO address
	mov edx, address 
	call writeString ;display the string pointed by the 'address'
ENDM

setColor MACRO foreground, background

	mov  eax, foreground+(background*16)
    call SetTextColor ;set text color with the given foreground and background

ENDM
SPACE macro
	mov eax,32
	call writeChar ;prints a single space 
endm

;cell adjacent vars
prompt6 BYTE "The cells are NOT adjacent", 0
isAdjacent DWORD 0

;score vars
score DWORD 0
occurances DWORD 0

;drawString vars
prompt9 BYTE "Name: ", 0
playerName BYTE 40 DUP (0)

prompt10 BYTE "Score: ", 0

prompt11 BYTE "Moves: ", 0
movesLeft DWORD 15

prompt12 BYTE "Level ", 0
levelNo DWORD 1

explosionStr BYTE "<< Explosion >>", 0
crushingStr BYTE "<< Crushing >>", 0

CurrentLevl DWORD 1

;swapCell vars
isSwapPossible DWORD 0
isRowCrush DWORD 0
isColCrush DWORD 0
isColAdjacent DWORD 0
isRowAdjacent DWORD 0
prompt14 BYTE "Restricted Area.", 0
isBombCrushed DWORD 0
matches DWORD 0


matchingRow DWORD 0
matchingCol DWORD 0
swapBackR DWORD 0
swapBackC DWORD 0


;file handling vars
filename BYTE "Scores.txt", 0 
fileHandle HANDLE  ?
bytesWritten DWORD ?  ; number of bytes written
newLine BYTE 0dh, 0ah
l1Str BYTE "Level1: ", 0 
l2Str BYTE "Level2: ", 0 
l3Str BYTE "Level3: ", 0 
hSPrompt BYTE "Highest Score: ", 0 
highestScore BYTE 0
highestScoreStr BYTE 4 DUP(' ')
l1Score BYTE 0
l2Score BYTE 0
l3Score BYTE 0
l1ScoreStr BYTE 4 DUP(' ')
l2ScoreStr BYTE 4 DUP(' ')
l3ScoreStr BYTE 4 DUP(' ')

.code
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::;
;:::::::::::::::::::::::::::<< MAIN	>>::::::::::::::::::::::::::::::::;							 
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::;
main PROC
	call welcomeScrn ;display welcome screen and get player's name 
	jmp Level2
	; start with level one 
	start: 
		;:::::::::::::::::::::::::::<< LEVEL1 >>::::::::::::::::::::::::::::::::;							 
		Level1:
			call populateBoard
				invoke removeInitialCombos, ADDR board1

			Level1Loop:
				call clrscr
				invoke checkCombo, ADDR board1
				invoke dropNumbers, ADDR board1
				call drawString
				invoke drawBoard, ADDR board1
				invoke takeInput, ADDR board1

				dec movesLeft
				cmp movesLeft, 0
				jne Level1Loop
				;else initialize level two 
				mov eax,  score
				mov l1Score, al
				mov score, 0

		mov movesLeft, 15
		;:::::::::::::::::::::::::::<< LEVEL2 >>::::::::::::::::::::::::::::::::;							 
		Level2:;initialize level 2
			mov levelNo, 2
			call populateBoardLevel2
				invoke removeInitialCombos, ADDR board2
			
			Level2Loop: 
				call clrscr
				invoke checkCombo, ADDR board2
				invoke dropNumbers, ADDR board2
				call drawString
				call drawBoard2
				invoke takeInput, ADDR board2
				
				dec movesLeft
				cmp movesLeft, 0
				jne Level2Loop
				;else initialze level 3
				mov eax,  score
				mov l2Score, al
				mov score, 0
		;:::::::::::::::::::::::::::<< LEVEL3 >>::::::::::::::::::::::::::::::::;							 
		Level3:;initialize level 3
		mov movesLeft, 2
		;mov movesLeft, 2
			mov levelNo, 3
			call populateBoardLevel3
			invoke removeInitialCombos, ADDR board3
			
			Level3Loop:
				call clrscr
				invoke checkCombo, ADDR board2
				invoke dropNumbers, ADDR board3
				call drawString
				call drawBoard3
				invoke takeInput, ADDR board3

				dec movesLeft
				cmp movesLeft, 0
				jne  Level3Loop
				;else exit the game 
				mov eax,  score
				mov l3Score, al
				

		exitGame:;end game 
		call saveScores ; save scores in the file 
		call endGame

	exit
main ENDP


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;<< populateBoard >>;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Populate board for level one 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
populateBoard PROC USES ebx esi eax ecx

		mov ebx, 0 ;row index
		mov esi, 0 ;col index
		mov ecx, 10 

		L1:;row loop 
			push ecx
			mov esi, 0
			mov ecx, 10

			L2:;column loop 
				mov eax, 6 ;range 0-5
				call randomRange
				inc eax  ; range 1-6

				cmp eax, 6
				je B
				mov board1[ebx+esi], eax
				jmp incr
				B:;initialize current cell with a Bomb 'B'
				mov board1[ebx+esi], 66
				incr:
				add esi, type board1
			loop L2

			add ebx, 40 ;
			pop ecx
		loop L1
		

	ret
populateBoard ENDP



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;| drawBoard3 |;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; display the level 3 board on the screen
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


drawBoard3 PROC USES eax  ebx ecx esi
		mov ebx, 0
		mov esi, 0
		mov ecx, 10

		mov row, 0
		mov column, 0
		mov isLevel3Board, 1

		setColor white, gray ; change color  wuth foreground = white and background = gray

		mov dl, 4 ; change coordinates ot 4,3
		mov dh, 3
		call gotoxy

		L1: ;row loop 
				push ecx
				mov esi, 0
				mov ecx, 10
				SPACE  ; print a single space 

				L2:;column loop 
					setColor white, gray

					mov eax, board3[ebx + esi]
					invoke colorNum1, eax ;print eax
					
					setColor black, gray

					incr:
					SPACE
					mov eax, '|'
					call writeChar
					SPACE
					add esi, type  board3
				loop L2

				push edx
				mov ecx, 10

				add dh,1 ; got one row forward 
				mov dl, 4
				call gotoxy

				setColor black, gray

				L3:;another loop for printing the '-'
					mov eax, '-'
					call writeChar
					mov eax, '-'
					call writeChar
					mov eax, '-'
					call writeChar
					mov eax, '-'
					call writeChar
				loop L3

				pop edx

				SPACE

				mov dl, 4
				add dh, 2 ;got two rows forward 
				call gotoxy
			
			
				add ebx, 40
				pop ecx
				dec ecx
				cmp ecx, 0
		jne L1

		setColor white, black ;set color back to default 

	ret
drawBoard3 ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;| populateBoardLevel2 |;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; populate board for level 2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



populateBoardLevel2 PROC USES ebx esi ecx eax
	
	mov esi, 0
	mov ebx, 0
	mov ecx, 10
	mov row, 0
	call randomize

	outerLoop: ;row loop 
		mov esi, 0
		mov column, 0
		innerLoop: ;column loop 
		
			checkRow:
				cmp row, 2 ; checkfor row 0,1,2
				jbe checkRestrictedCol
				cmp row, 7 ;check for row 7, 8, 9
				jae checkRestrictedCol

				cmp row, 4 ;if row is 4
				je checkAllowedCol
				cmp row, 5 ; if row is 5
				je checkAllowedCol

				jmp generateRand

			checkRestrictedCol:
				cmp column, 2 ; is col < 0,1,2?
				jbe blankCell
				cmp column, 7 ; is col > ,7,8, 9?
				jae blankCell
				jmp generateRand


			checkAllowedCol:
				cmp column, 2
				jbe generateRand
				cmp column,7
				jae generateRand
			blankCell: ;restricted area of level 2 is initialized with -1
				mov board2[ebx+esi], -1

				jmp incr

			generateRand:
				mov eax, 5 ; random numbers from 0 to 4
				call randomRange 
				inc eax ; range: 1-5
				cmp eax, 5
				jne assign
				mov board2[ebx+ESI], 66 ; Bomb 
				jmp incr

			assign:; assign numbers from 1-4
				mov board2[ebx+esi], eax

			incr:
				add esi, 4
				inc column
				cmp column , 10
			jb innerLoop

		add ebx, 40
		inc row
		cmp row, 10
		jb outerLoop

ret
populateBoardLevel2 ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;| populateBoardLevel3 |;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; populate board for level 3
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

populateBoardLevel3 PROC USES ebx esi eax ecx

		mov ebx, 0
		mov esi, 0
		mov row, 0
		mov column, 0
		call randomize
		mov ecx, 10

		L1: ;row loop 
			push ecx
			mov esi, 0
			mov ecx, 10
			L2:;column loop 

				mov eax, 7
				call randomRange ; generate a  random number in the range 0-6
				inc eax
				cmp eax, 6
				je Bomb
				cmp eax,  7
				je X
				mov board3[ebx+esi*type board3], eax
				jmp incr
				Bomb:
				mov board3[ebx+esi*type board3], 66;B
				jmp incr
				X:
				mov board3[ebx+esi*type board3], 88;X
				jmp incr
				incr:
				inc esi

			loop L2

			add ebx, 40
			pop ecx
		loop L1

	setColor white, black

	ret
populateBoardLevel3 ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;| drawBoard2 |;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; display board of level 2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


drawBoard2 PROC USES ebx esi eax ecx
	local r:dword, col:dword
	;local variables r= row , col= column

	mov esi, 0
	mov ebx, 0
	mov ecx, 10
	mov r, 0
	
	draw2:;row loop 
		push ecx
		mov esi, 0
		mov ecx, 10
		SPACE
		innerDraw2:;column loop 
				cmp r, 3
				je dispCell
				cmp r, 6
				je dispCell
				cmp r, 2 ; row == 0, 1, 2?
				jbe checkCornerCol
				cmp r, 7 ; row == 7,8,9?
				jae checkCornerCol
				jmp checkCenterCol

			checkCornerCol: ; check column 0,1,2 or 7,8,9
				cmp esi, 2
				jbe dispNothing
				cmp esi, 7
				jae dispNothing
				jmp dispCell

			checkCenterCol:;for 4, 5 rows which are empty from the middle 
				cmp esi, 2
				jbe dispCell
				cmp esi, 7
				jae dispCell
				jmp dispNothing


			dispCell:
				mov eax, board2[ebx+esi*type board2]
				invoke colorNum, eax ;display eax
			
				jmp incr
			dispNothing:
				SPACE
				incr:
					SPACE 
					SPACE 
			inc esi
		loop innerDraw2

		call crlf
		add ebx, 40
		inc r
		pop ecx
		cmp r, 10
	jb draw2

	ret
drawBoard2 ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;| swapCell |;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; swaps cells, keeps track of restricted area when swapping, Deals with bombs
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
swapCell PROC USES ebx esi eax edx, Board:PTR DWORD , row1:DWORD, col1:DWORD, row2:DWORD, col2:DWORD
	LOCAL val1:DWORD, val2:DWORD, smallerRow:DWORD, smallerCol:DWORD, restrict2 :DWORD, restrict3:dword

	 mov restrict2, 1 ; for restricted area of level 2
	 mov restrict3, 1 ;for restricted area of level 3

	cmp levelNo, 3
	jne smallRow


	restric3: ;if any cell has X in it don't swap, since X represents 'Blocker'
		mov ecx, 'X'

		;for row1-col1
		mov ebx, Board
		mov eax, row1
		mul rowSize
		add ebx, eax
		mov esi, col1

		cmp [ebx+esi*type Board], ecx
		je next

		;for row1-col2
		mov esi, col2
		cmp [ebx+esi*type Board], ecx
		je next

		;for row2-col1
		mov ebx, Board
		mov eax, row2
		mul rowSize
		add ebx, eax
		mov esi, col1

		cmp [ebx+esi*type Board], ecx
		je next
		;for row2-col2
		mov esi, col2
		cmp [ebx+esi*type Board], ecx
		je next

		mov restrict3, 0 ;no cell contains X so make restrict3 false

	;checking for smaller row and column
	smallRow:
			mov eax, row1
			cmp eax, row2
			jnb r2Small
			mov smallerRow, eax
			jmp smallCol
		
			r2Small:
				mov eax, row2
				mov smallerRow, eax

	smallCol:
			mov eax, col1
			cmp eax, col2
			jnb c2Small
			mov smallerCol, eax
			jmp restric2
			c2Small:
				mov eax, col2
				mov smallerCol, eax

	restric2: ;check for restricted area for level 2
		cmp levelNo, 2
		jne savePrevValue
		cmp smallerRow, 2 
		jbe checkCornerCol
		cmp smallerRow, 7
		jae checkCornerCol
		cmp smallerRow, 4
		je checkCenterCol
		cmp smallerRow, 5
		je checkCenterCol
		jmp savePrevValue

	checkCornerCol:
		cmp smallerCol, 2
		jbe next
		cmp smallerCol, 7
		jae next

	checkCenterCol: ;col == 3-6?
		cmp smallerCol, 2
		jbe savePrevValue
		cmp smallerCol, 7


	savePrevValue:
				;make both restrict2 and 3 false since we're not in the restricted zone anymore
				mov restrict2, 0
				mov restrict3, 0

				;check is cells  row adjacent
				cmp isRowAdjacent, 1
				je rowAdjacent
				cmp isColAdjacent, 1
				je colAdjacent
				jmp next

				rowAdjacent:
					;for row1-col1
					mov ebx, Board
					mov eax, row1
					mul rowSize
					add ebx, eax 

					mov esi, col1
					mov eax, [ebx+esi*type Board]
					mov val1,eax ; val1 = value in cell row1-col1
				
			
					;for row1-col2
					mov esi, col2
					mov eax, [ebx+esi*type board]
					mov val2,eax ; val2 = value in cell row1-col2

					jmp checkBomb ; now check for Bombs

				colAdjacent:
					;for row1-col1
					mov ebx, Board
					mov eax, row1 
					mul rowSize
					add ebx, eax

					mov esi, col1
					mov eax, [ebx+esi*type Board]
					mov val1,eax ; val1 = value in cell row1-col1
				
					mov ebx, Board
					mov eax, row2
					mul rowSize
					add ebx, eax
			
					mov eax, [ebx+esi*type Board]
					mov val2,eax; val2 = value in cell row2-col1

				

	checkBomb:
		;checking if either of the values are 'B'/bomb
		cmp val1, 'B'
		je checkVal2

		cmp val2, 'B'
		je checkVal1
		
		jmp swap ; if both of the cells are not bombs

		checkVal2:
			cmp val2, 'B'
			je bothBomb

			mov eax, val2 ; val2 is not a bomb , eax = number to be crushed from the board
			INVOKE checkBombs, Board ; explode all the eax's from the board

			jmp checkForCombos ;check for combos now 

		checkVal1:
			mov eax, val1 ; val1 is not a bomb , eax - number to be crushed from the  board
			INVOKE checkBombs, Board
			jmp checkForCombos
			
			bothBomb:; if both cells are bombs then crush the whole board and populate it again
				call populateBoard
				jmp next

	swap: ;for swapping cell values
		cmp isRowAdjacent, 1
		jne swapColVals

	swapRowVals: ; swapping row values 
		;row1-col1
		mov ebx, Board
		mov eax, row1
		mul rowSize
		add ebx, eax

		mov esi, col1
		mov eax, val2
		mov [ebx+esi*type board], eax
		
		;row1-col2
		mov esi, col2
		mov eax, val1
		mov [ebx+esi*type board], eax
		jmp checkForCombos

	swapColVals:
		;row1-col1
		mov ebx, Board
		mov eax, row1
		mul rowSize
		add ebx,eax 

		mov esi, col1
		mov eax, val2
		mov [ebx+esi*type board], eax 

		;row2-col1
		mov ebx, Board
		mov eax, row2
		mul rowSize
		add ebx, eax

		mov eax, val1
		mov [ebx+esi*type board], eax

	checkForCombos:
		invoke checkCombo, Board ;check for combos and then crush them 
	;	mov  eax, matches
		;add score, eax
		

		jmp next

		mov eax, smallerRow
		mov row, eax
		mov eax, smallerCol
		mov column, eax

		mov isRowCrush, 0
		mov isColCrush, 0
		
		mov ebx, Board
		mov eax, smallerRow
		mul rowSize
		add ebx, eax

		mov eax, smallerCol
		mul colSize
		mov esi, eax

		mov eax, smallerRow
		mov matchingRow, eax

		mov eax, smallerCol
		mov matchingCol, eax

		mov swapBackR, 0
		mov swapBackC, 0


		jmp next

	swapBackRow:
	
		mov ebx, Board
		mov eax, row1
		mul rowSize
		add ebx, eax

		mov esi, col1


		mov eax, val1
		mov [ebx+esi*type board], eax
		
		mov esi, col2

		mov eax, val2
		mov [ebx+esi*type board], eax
		jmp next


	swapBackCol:
		mov ebx, Board
		mov eax, row1
		mul rowSize
		add ebx, eax

		mov esi, col1

		mov eax, val1
		mov [ebx+esi*type board], eax

		mov ebx, Board
		mov eax, row2
		mul rowSize
		add ebx, eax

		mov eax, val2
		mov [ebx+esi*type board], eax


	next:

	;Modify scores earned by explosion of bombs
	mov eax, occurances
	add score, eax

	;reset value for next move
	mov occurances, 0

	;disply explosion and crushing string if they happened
	call crushing
	call Explosion

	;reset values for the next move
	mov isRowCrush, 0
	mov isColCrush, 0
	mov isBombCrushed, 0

	;display appropriate message for restricted area
	cmp restrict2, 1
	je displayRestrict
	cmp restrict3, 1
	je displayRestrict
	ret 

	displayRestrict: 
	setColor white, Red
	call clrscr

	displayString offset prompt14 ;'Restricted Area' string

	mov eax, 1000 
	call delay;delay for 1 sec

	setColor white, black
	call clrscr

	ret
swapCell ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;| checkBombs |;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; for checking and removing the bombs 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
checkBombs PROC USES ebx esi eax edx ecx, Board: PTR DWORD
	;eax = number to crush from the whole board
	mov isBombCrushed, 1

	mov occurances,0
	mov row, 0
	mov column, 0

	mov esi, 0
	mov ebx,  Board
	mov ecx, 10
	
	checkB: ;row loop
		push ecx
		mov esi, 0
		mov ecx, 10
		innerCheckB:;column loop 

			cmp [ebx+esi], eax
			jne incr
			mov edx, 0 ; eax found, crush it 
			mov [ebx+ESI],edx
			inc occurances ;and increase occurances of eax found
			;if explosion occurs in the bottom rows i.e., 7,8,9 more scores will be added to the total scores i.e., 2 times the total ocuurances from the bottom rows
			cmp row, 7
			jb incr
			inc occurances
			incr:
				add esi, type board
		loop innerCheckB

		add ebx, 40
		pop ecx
	loop checkB

	ret
checkBombs ENDP


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;| removeInitialCombos |;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; for removing the initial combos from the board
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

removeInitialCombos PROC USES ebx esi, Board: PTR DWORD

	INVOKE checkCombo, Board
	mov score, 0
	ret
removeInitialCombos ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;| checkCombo |;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; for checking and removing the combos from the board
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

checkCombo PROC USES esi ebx, Board:PTR DWORD

	mov ebx, Board
	mov esi, 0
	mov ecx, 10

	mov row, 0
	mov column, 0

	L1:;row loop
		push ecx
		mov column, 0
		mov esi, 0
		mov ecx, 10

			L2:;column loop
				; don't check for bombs and  X(blockers) since we have seaprate functions for cdealing with them 
				mov eax, 'B'
				cmp [ebx+esi], eax
				je continue
				mov eax, 'X'
				cmp [ebx+ESI], eax
				je continue

				;check for row-wise and column-wise combinations in the board
				invoke checkRowCombination, Board
				invoke checkColCombination, Board

				continue:
					inc column
					add esi, type Board ;goto next column
			loop L2;end inner loop

		add ebx, 40 ;goto next row 
		inc row
		pop ecx
	loop L1

	ret
checkCombo ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;| checkRowCombination |;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; for checking and removing the combos from the row from the board
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


checkRowCombination PROC USES esi ebx ecx eax edx, Board:PTR DWORD

		;mov matches, 0

		cmp column, 0 ;if(column >= 0 && column < 8)
		jnae endFunc 
		cmp column, 8
		jnb endFunc

		push column ;reserve column

		cmp levelNo, 2 ;for checking restricted area of level 2 before before checking for combinations 
		jne checkMatches

		cmp row, 2 ; row ==  0,1,2 ?
		jbe checkCornerCol
		cmp row, 7 ;row == 7,8,9?
		jae checkCornerCol
		cmp row, 3
		je checkMatches
		cmp row, 6
		je checkMatches
		
		jmp checkCenterCol


		checkCornerCol:
			cmp column, 2
			jbe cont ;restricted region, don't check for combinations 
			cmp column, 7
			jae cont ;restricted region, don't check for combinations 
			jmp checkMatches

		checkCenterCol:
			cmp column, 2 ;columns 0,1,2 of row 4 or 5
			jbe checkMatches
			cmp column, 7 ;columns 7,8,9 of row 4 or 5
			jae checkMatches 

			jmp cont ; if row is 4 or 5 and the columns are 3,4,5, 6, that's the restricted region don't check it 

			
			checkMatches:
			;check for 3 matches first 
			mov eax, [ebx+esi]
			add esi, type board
			mov ecx, [ebx+esi]
			add esi, type board
			mov edx, [ebx+esi]

			mov matches, 0
		

		cmp eax, ecx ;if( eax == ecx && ecx == edx) 
		jne cont1
		cmp ecx, edx
		jne cont1

			add matches, 3 ;if 3 matches found

			push eax ;reserve eax
			;crush all the three matches found 
			mov eax, 0
			mov [ebx+esi], eax

			sub esi, type board

			mov [ebx+esi], eax

			sub esi, type board

			mov [ebx+esi], eax

			
			pop eax
			mov isRowCrush, 1
		
		cont1:
		add column , 2 ;go forward
		add esi, type board
		add esi, type board

		;checking for further matches for the same value for which we found 3 matcches
		beginwhile:  ;while( matches >= 3  && column < 8)
			cmp matches, 3 
			jnae cont			
			cmp column, 9 
			jnb cont

			add esi, type board
			mov eax, [ebx+ESI]

			cmp ecx, edx     ;if( ecx == edx && eax == edx)
			jne cont
			cmp eax, edx
			jne cont

			add matches, 1
			push eax
			mov eax, 0
			mov [ebx+esi], eax
			pop eax


			cont2:
			inc column
			jmp beginwhile
		


		cont:
		pop column
		mov eax, matches
		add score, eax
		endFunc:
		ret
checkRowCombination ENDP


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;| checkColCombination |;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; for checking and removing the combos from the column from the board
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



checkColCombination PROC USES esi ebx ecx eax edx, Board:PTR DWORD

	mov matches, 0

	cmp row, 0 ;if( row >= 0 && row < 8)
	jnae endFunc
	cmp row, 8
	jnb endFunc

		push row ; reserve row

		cmp levelNo, 2; so that we can first check for restricted region of level 2
		jne checkMatches

		cmp row, 2 ; row == 0,1,2?
		jbe checkCornerCol
		cmp row, 7 ; row == 7,8,9?
		jae checkCornerCol
		cmp row, 4
		je checkCenterCol
		cmp row, 5
		je checkCenterCol
		jmp checkMatches

		checkCornerCol:
			cmp column, 2 ; restricted region, don't check for combos 
			jbe cont
			cmp column, 7 ; restricted region, don't check for combos
			jae cont
			jmp checkMatches

		checkCenterCol:
			cmp column, 2
			jbe checkMatches
			cmp column, 7
			jae checkMatches
			jmp cont

		checkMatches:
			;check for 3 matches first
			mov eax, [ebx+ esi]
			add ebx, 40 ; goto next row
			mov ecx, [ebx+esi]
			add ebx, 40
			mov edx, [ebx+esi]

			cmp eax, ecx ;if( eax == ecx && ecx == edx)
			jne cont1
			cmp ecx, edx
			jne cont1

			;if 3 matches found
			add matches, 3

			push eax
			;if 3 matches found, crush them all 
			mov eax, 0
			mov [ebx+esi], eax
			sub ebx, 40
			mov [ebx +esi], eax
			sub ebx, 40
			mov [ebx+esi], eax
			pop eax
			mov isColCrush, 1

		cont1:
			add row, 3
			add ebx, 80 ; go two rows forward

		beginWhile:;while( matches >= 3 && row < 8 )
				cmp matches, 3
				jnae cont
				cmp row, 9
				jnb cont

				add ebx, 40 
				mov eax, [ebx+esi]

				cmp eax, edx;if(eax == edx && ecx == edx)
				jne cont
				cmp ecx, edx
				jne cont

				inc matches
				push eax
				mov eax, 0
				mov [ebx + esi], eax
				pop eax

				cont2:
				inc row
				jmp beginWhile

		
		cont:
		pop row
		mov eax, matches
		add score, eax

	endFunc:
	ret
checkColCombination ENDP


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;| takeInput |;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  takes input of rows and columns of the cell from the user, checks if they're adjacent 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

takeInput PROC USES eax , Board:PTR DWORD
	LOCAL row_1:DWORD, col_1:DWORD, row_2:DWORD, col_2:DWORD

	;assuming that the user will always input distinct rows and cols and from 0-9

	call crlf
	SPACE
	displayString offset prompt1 ;row-1

	call readDec
	mov row_1, eax

	SPACE
	displayString offset prompt2;col-1

	call readDec
	mov col_1, eax

	SPACE
	displayString offset prompt3 ;row-2

	call readDec
	mov row_2, eax

	SPACE
	displayString offset prompt4 ;col-2

	call readDec
	mov col_2, eax


	;indexing will start from 0

	mov isAdjacent, 0
	mov isRowAdjacent, 0
	mov isColAdjacent,0

	;assuming that the user will always enter cell# from 0-9
	
	mov eax, row_2


	;adjacent/row adjacent?
		mov eax, row_2
		cmp row_1, eax
		jne colAdj
		mov isRowAdjacent, 1
		mov eax, col_1
		inc eax
		cmp col_2, eax
		je isAdj
		mov eax, col_1
		dec eax
		cmp col_2, eax
		je isAdj												
	
	;checks for adjacent/col-adjacent
	colAdj:					                                                       
		mov eax, col_2			                                                       
		cmp col_1, eax			                                                       
		jne continue			                                                       
		mov isColAdjacent, 1	                                                       
		mov eax, row_1			                                                       
		inc eax					                                                       
		cmp row_2, eax			                                                       
		je isAdj				                                                       
		mov eax, row_1			                                                       
		dec eax					                                                       
		cmp row_2, eax			                                                       
		je isAdj				                                                       
		jmp continue

	isAdj:
		mov isAdjacent, 1

	continue: ;if cells are adjacent swap them 
		cmp isAdjacent, 1
		jne notAdj
		INVOKE swapCell, Board,  row_1, col_1, row_2, col_2
		jmp cont

	notAdj: ;if cells are not adjacent, display appropriate message
		setColor black, yellow 
		call crlf
		displayString offset prompt6

		mov eax, 1000 ;delay for 1 sec
		call delay

		setColor white,black
		
	cont:
	exitFun:
	call crlf
	ret
takeInput ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;| drawString |;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  draws the player's name, score and moves left on the top, displays level number as well
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


drawString PROC

	;setColor white, black ;set color
	;call clrscr


	SPACE
	setColor Green,black
	displayString offset prompt9 ; Name

	setColor magenta, black
	displayString offset playerName ;display name

	SPACE 
	SPACE 

	setColor green, black
	displayString offset prompt10 ; Score

	setColor magenta, black
	mov eax, score
	call writeDec ;display score

	SPACE 
	SPACE 

	setColor green, black
	displayString offset prompt11 ; Moves

	setColor magenta, black
	mov eax , movesLeft
	call writeDec ;display moves left

	mov dl, 60
	mov dh, 10
	call gotoxy

	setColor black, yellow
	displayString offset prompt12 ; Level


	mov eax, levelNo
	call writeDec ;display level No
	SPACE


	setColor white,black
	mov dl, 0
	mov dh, 2
	call gotoxy
	ret
drawString ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;| dropNumbers |;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; for filling the spots that were exploded/ crushed before by drpping numbers 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

dropNumbers PROC , Board: PTR DWORD
	
	mov esi,0
	mov ebx, Board
	mov ecx, 10
	mov row, 0

	check0: ;row loop 
		push ecx
		mov esi, 0
		mov ecx, 10
			innerCheck0: ;col loop 
				mov eax, 0 ; if 0 encountered, drop numbers
				cmp [ebx+ESI], eax	
				jne incr

				INVOKE dropNum, Board

				incr:
				add esi, type board
			loop innerCheck0

		add ebx, 40
		inc row
		pop ecx
	loop check0

	ret
dropNumbers ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;| dropNum |;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; dropNumbers helper function. It checks for each row and also accounts restricted area for both level2 and level3
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

dropNum PROC USES ebx esi eax edx, Board:PTR DWORD
	push row

	drop:
		cmp row, 0 ; if top row, fill the cell
		je fillCell

		mov eax, -1 ;level2 restricted area
		mov edx, ebx
		sub edx, 40

		cmp [edx+esi], eax ;if above area is restricted 
		je fillCell

		mov eax, 'X' ; if above is a blocker
		cmp [edx+esi], eax
		je isXAtTop

		dropCell: 

					mov eax, [ebx+esi]; eax = 0
					push ebx
					sub ebx, 40
					mov edx, [ebx+esi] ; edx = value in the row above 
					pop ebx

					mov [ebx+esi], edx ; swap both values
					push ebx
					sub ebx, 40
					mov [ebx+ESI], eax
					pop ebx
					
					dec row
					sub ebx, 40
					jmp drop

		isXAtTop: ;if above cell has X, skip that cell
					mov eax, row
					dec eax
					cmp eax, 0
					je fillCell

					mov eax, [ebx+esi]
					push ebx
					sub ebx, 80 ; skip the X above and move up
					mov edx, [ebx+esi]
					pop ebx

					mov [ebx+esi],  edx
					push ebx
					sub ebx, 80
					mov [ebx+esi], eax
					pop ebx
					sub row, 2
					sub ebx, 80
					jmp drop


		fillCell:
				mov eax, 5 ;0-4
				call randomRange 
				inc eax ;1-5
				mov [ebx+esi], eax

	endFunc:
	pop row
	ret
dropNum ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;| welcomeScrn |;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; displays the welcome message and group members name 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

welcomeScrn PROC USES eax edx 
	
	
	setColor Red, black
	call clrscr

	
	mov dl, 35 ;column
	mov dh, 7; row 
	call gotoxy


	push edx
	displayString offset prmpt0 ;stars
	pop edx

	setColor yellow, black

	mov dl, 35 ;column
	mov dh, 8; row 
	call gotoxy

	push edx
	displayString offset prompt0 ; welcome
	pop edx


	setColor red, black

	mov dl, 35 ;column
	mov dh, 9; row 
	call gotoxy

	push edx
	displayString offset prmpt0; stars
	pop edx

	setColor blue , black

	mov dl, 35
	mov dh, 13
	call gotoxy

	push edx
	displayString offset prmpt1 ;by
	pop edx

	setColor cyan , black

	mov dl, 35
	mov dh, 14
	call gotoxy

	push edx
	displayString offset prmpt2 ;name1
	pop edx

	setColor magenta , black

	mov dl, 35
	mov dh, 15
	call gotoxy

	push edx
	displayString offset prmpt3 ;name2
	pop edx

	setColor lightCyan , black

	mov dl, 35
	mov dh, 16
	call gotoxy

	push edx
	displayString offset prmpt4 ;name3
	pop edx

	call crlf
	call crlf
	setColor lightGreen, black
	call waitMsg

	call clrscr

	mov dl, 35
	mov dh, 10
	call gotoxy

	displayString offset prompt8 ;get player name 
	mov edx, offset playerName
	mov ecx, sizeof playerName
	call readString
	

	call Clrscr 
	mov dl, 0
	mov dh, 0
	call gotoxy
	setColor white, black
	ret
welcomeScrn ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;| drawBoard |;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; for displaying the board of level 1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

drawBoard PROC USES eax  ebx ecx esi, Board:PTR DWORD

		mov ebx, Board
		mov esi, 0
		mov row, 0
		mov column, 0
		mov ecx, 10

		L1:;row loop
			push ecx
			mov esi, 0
			mov ecx, 10

			SPACE
				L2:;column loop
					mov eax, [ebx + esi * type Board]

					invoke colorNum, eax ;display eax
					incr:
					SPACE
					SPACE
					inc esi
				loop L2
			call crlf
			
			add ebx, 40
			pop ecx
		loop L1
		ret
drawBoard ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;| colorNum |;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; for displaying numbers with diffenet colors on the board
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

colorNum PROC , num:DWORD
	LOCAL color:dword 
	pushad
	
	one:
	cmp num, 1
	jne two

	setColor cyan, black
	mov eax, num
	call writeDec
	jmp exitFun

	two:
	cmp num, 2
	jne three

	setColor blue, black
	mov eax, num
	call writeDec
	jmp exitFun


	three:
	cmp num, 3
	jne four

	setColor yellow, black
	mov eax, num
	call writeDec
	jmp exitFun

	four:
	cmp num, 4
	jne five

	setColor green, black
	mov eax, num
	call writeDec
	jmp exitFun

	five:
	cmp num, 5
	jne Bomb

	setColor magenta, black
	mov eax, num
	call writeDec
	jmp exitFun

	Bomb:
	cmp num, 66
	jne X

	setColor lightRed, black
	mov eax, num
	call writeChar
	jmp exitFun

	X:
	cmp num, 88
	jne _space

	setColor red, black
	mov eax, num
	call writeChar
	jmp exitFun

	_space:
		SPACE

	exitFun:
	setColor white, black
	popad
	ret
colorNum ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;| colorNum1 |;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; for displaying numbers with diffenet colors on the board of level 3 since it needs a change in its look
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;





colorNum1 PROC , num:DWORD
	LOCAL color:dword 
	pushad
	
	one:
	cmp num, 1
	jne two

	setColor cyan, gray
	mov eax, num
	call writeDec
	jmp exitFun

	two:
	cmp num, 2
	jne three

	setColor blue, gray
	mov eax, num
	call writeDec
	jmp exitFun


	three:
	cmp num, 3
	jne four

	setColor yellow, gray
	mov eax, num
	call writeDec
	jmp exitFun

	four:
	cmp num, 4
	jne five

	setColor black, gray
	mov eax, num
	call writeDec
	jmp exitFun

	five:
	cmp num, 5
	jne Bomb

	setColor magenta, gray
	mov eax, num
	call writeDec
	jmp exitFun

	Bomb:
	cmp num, 66
	jne X

	setColor brown, gray
	mov eax, num
	call writeChar
	jmp exitFun

	X:
	cmp num, 88
	jne _space

	setColor red, gray
	mov eax, num
	call writeChar
	jmp exitFun

	_space:
		SPACE

	exitFun:
	setColor white, gray
	popad
	ret
colorNum1 ENDP


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;| saveScores |;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; for saving scores in the file 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

saveScores PROC
	
	;open existing file for both reading and writing
	invoke createFile , ADDR filename, generic_write + generic_read, do_not_share, null, OPEN_EXISTING, file_attribute_normal, 0
	mov fileHandle, eax

	; Move the file pointer to the end of the file
	INVOKE SetFilePointer,  fileHandle,0,0,FILE_END	

	 ; Append text to the file
	INVOKE WriteFile, fileHandle, ADDR playerName, lengthof playerName,  ADDR bytesWritten, 0

	INVOKE WriteFile, fileHandle, ADDR newLine, lengthof newLine,  ADDR bytesWritten, 0 ;write newline to the file

	;write level1 score
	INVOKE WriteFile, fileHandle, ADDR l1Str, lengthof l1Str,  ADDR bytesWritten, 0
	invoke convertNumBytetoString, l1Score, ADDR l1ScoreStr
	INVOKE WriteFile, fileHandle, ADDR l1ScoreStr, lengthof l1ScoreStr,  ADDR bytesWritten, 0

	INVOKE WriteFile, fileHandle, ADDR newLine, lengthof newLine,  ADDR bytesWritten, 0

	;write level1 score
	INVOKE WriteFile, fileHandle, ADDR l2Str, lengthof l2Str,  ADDR bytesWritten, 0
	invoke convertNumBytetoString, l2Score, ADDR l2ScoreStr
	INVOKE WriteFile, fileHandle, ADDR l2ScoreStr, lengthof l2ScoreStr,  ADDR bytesWritten, 0

	INVOKE WriteFile, fileHandle, ADDR newLine, lengthof newLine,  ADDR bytesWritten, 0

	;write level1 score
	INVOKE WriteFile, fileHandle, ADDR l3Str, lengthof l3Str,  ADDR bytesWritten, 0
	invoke convertNumBytetoString, l3Score, ADDR l3ScoreStr
	INVOKE WriteFile, fileHandle, ADDR l3ScoreStr, lengthof l3ScoreStr,  ADDR bytesWritten, 0

	INVOKE WriteFile, fileHandle, ADDR newLine, lengthof newLine,  ADDR bytesWritten, 0

	
	
	;compute highest score from the three levels
	mov al, l1Score
	cmp al, l2Score 
	ja	l1bigThanl2  
	mov al, l3Score 
	cmp l2Score, al			
	ja l2Big
	
	   
	l1bigThanl2:
		cmp  al, l3Score
		ja l1Big
		mov al, l3Score
		cmp al , l2Score
		ja l3Big

	l1Big:
		mov al, l1Score
		mov highestScore,  al
		jmp cont
	l2Big:
		mov al, l2Score
		mov highestScore, al
		jmp cont
	l3Big:
		mov al, l3Score
		mov highestScore, al

	cont:
		;write highest score to the file 
		INVOKE WriteFile, filehandle, ADDR hSPrompt, lengthof hSPrompt, ADDR bytesWritten, 0
		INVOKE convertNumBytetoString, highestScore, ADDR highestScoreStr
		INVOKE WriteFile, filehandle, ADDR highestScoreStr, lengthof highestScoreStr, ADDR bytesWritten, 0 


	close:;clos the file
		INVOKE WriteFile, filehandle, ADDR newline, lengthof newline, ADDR bytesWritten, 0 ;write newline to file
		INVOKE CloseHandle, fileHandle ;close file

	ret
saveScores ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;| convertNumBytetoString |;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; for converting the number to string for writing them in the file 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


convertNumBytetoString PROC, num:BYTE, strnum: PTR BYTE
	
	mov eax, 0
	mov al, num

	cmp eax, 0 ; if num is zero, terminate
	je terminate

	mov bl, 10 ;divisor
	mov esi, strnum
	add esi, 3

	LC1:
		div bl ;get the last digit
		add ah, 30H  
		mov [esi], ah
		dec esi
		mov ah, 0
		cmp eax, 0
		je terminate
		cmp eax, 10
		jl done
	loop LC1

	done:
		add al, 30H
		mov [esi], al
	terminate:
	ret
convertNumBytetoString ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;<< crushing >>;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; displays the string 'Crushing' when combinations are crushed
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


crushing PROC

	cmp isRowCrush, 1
	jne checkCol
	jmp displayCrush

	checkCol:
	cmp isColCrush, 1
	jne exitFun
	

	displayCrush:
	mov dl, 60 ; col
	mov dh, 11 ;row
	call gotoxy

	setColor black, yellow
	displayString offset crushingStr ; crushing string

	mov eax, 1000 ; delay for 1 sec
	call delay
		
	SPACE
	;call clrscr

	setColor white,black
	mov dl, 0 ;col
	mov dh, 2 ;row
	call gotoxy

	exitFun:
	ret
crushing ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;<< Explosion >>;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; displays the string "Explosion" when an explosion occurs
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Explosion PROC

	cmp isBombCrushed, 1
	jne exitFun

	displayExplosion:
	mov dl, 60 ; col
	mov dh, 13 ;row
	call gotoxy

	setColor black, yellow
	displayString offset explosionStr ; crushing string

	mov eax, 1000 ; delay for 1 sec
	call delay
		
	SPACE
	;call clrscr

	setColor white,black
	mov dl, 0 ;col
	mov dh, 2 ;row
	call gotoxy

	exitFun:
	ret
Explosion ENDP



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;<< endGame >>;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; displays end message when the game ends
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

endGame PROC
	call clrscr
	setColor lightGreen, black
	call clrscr

	
	mov dl, 35 ;column
	mov dh, 7; row 
	call gotoxy


	push edx
	displayString offset prmpt0 ;stars
	pop edx

	setColor yellow, black

	mov dl, 46 ;column
	mov dh, 10; row 
	call gotoxy

	push edx
	displayString offset prmpt5 ; end game 
	pop edx


	setColor lightGreen, black

	mov dl, 35 ;column
	mov dh, 13; row 
	call gotoxy

	push edx
	displayString offset prmpt0; stars
	pop edx

	setColor white, black
	ret
endGame ENDP
END main
