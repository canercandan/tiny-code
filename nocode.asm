;; @: 0

org 0
	;; IMAGE DOS HEADER START
	db 4Dh,5Ah		;; e_magic

;; +2h

	times 3ah db 0		;; all fields between e_magic and dos_peoffset

;; +3ch

	dd pesig

;; +40h

	;; IMAGE DOS HEADER END

	;; PE HEADER START

	;; IMAGE NT HEADERS START

pesig:
	dd 00004550h	    ;; signature

	;; IMAGE FILE HEADER START (size 14h)

pehdr:
	dw 14ch	 	    ;; machine
	dw 3h		    ;; section number

	times 0ch db 0	    ;; from timedatestamp to number of symbol fields

	dw opthdrsize	    ;; size of optional header
	dw 103h		    ;; characteristics

	;; IMAGE FILE HEADER END

;; +58h

	;; IMAGE OPTIONAL HEADER 32 START (size 60h)

;;;;;;;;;;;;;;;;
;; PARAMETERS ;;
;;;;;;;;;;;;;;;;

filealign equ 1
sectalign equ 1

%define round(n, r) (((n+(r-1))/r)*r)

opthdr:

	dw 10bh	 	  	 ;; magic number

	times 2h db 0		 ;; major and minor linker version
	times 3h dd 0		 ;; from size of code to uninitialized data

	dd 00001000h		 ;; address of entry point
	;;

	times 2h dd 0		 ;; from base of code to data

	dd 00400000h		 ;; image base

	dd 00001000h		 ;; section alignement
	dd 00000200h		 ;; file alignement

	;;
	;;

	times 4h dw 0		 ;; from major os version to minor image version

	dw 4h 	    		 ;; major sub system version

	times 6h db 0		 ;; from minor sub system version to win32 version

	dd 00004000h		 ;; size of image
	dd 00000400h		 ;; size of headers

	;;
	;;

	dd 0			 ;; checksum NOT USED

	dw 2h			 ;; sub system

	times 6h db 0		 ;; from dll characteristics to size of stack reserve

	dd 00001000h		 ;; size of stack commit
	dd 00100000h		 ;; size of heap reserve

	times 2h dd 0		 ;; from size of heap commit to number of rva and sizes

	dd 00000010h		 ;; number of rva and sizes

;; +b8h

	;; DATA DIRECTORIES START (last field of Optional Header) (size 80h)

	;;times 16 dd 0, 0

	times 2h dd 0

	dd 00002014h		;; import table @
	dd 0000003ch		;; import table size

	times 14h dd 0

	dd 00002000h		;; import @ table @
	dd 00000014h		;; import @ table size

	times 6h dd 0

	;; DATA DIRECTORIES END

opthdrsize equ $-opthdr

	;; IMAGE OPTIONAL HEADER 32 END

	;; IMAGE NT HEADERS END

	;; PE HEADER END

;; +138h

	;; IMAGE SECTION HEADER .text START (size 28h)

	db '.text',0,0,0 	;; Name[8]
	dd codesize	 	;; VirtualSize
	dd 00001000h		;; Virtual@
	dd 00000200h		;; SizeOfRawData
	dd 00000200h		;; PointerToRawData
	times 0ch db 0		;; PointerToRelocations to NumberOfLineNumbers
	dd 60000020h 		;; Characteristics

	;; IMAGE SECTION HEADER .text END

;; +160h

	;; IMAGE SECTION HEADER .data START (size 28h)

	db '.data',0,0,0 	;; Name[8]
	dd datasize	 	;; VirtualSize
	dd 00003000h		;; Virtual@
	dd 00000200h		;; SizeOfRawData
	dd 00000400h		;; PointerToRawData
	times 0ch db 0		;; PointerToRelocations to NumberOfLineNumbers
	dd 0c0000040h 		;; Characteristics

	;; IMAGE SECTION HEADER .data END

;; +188h

	;; IMAGE SECTION HEADER .rdata START (size 28h)

	db '.rdata',0,0 	;; Name[8]
	dd rdatasize	 	;; VirtualSize
	dd 00002000h		;; Virtual@
	dd 00000200h		;; SizeOfRawData
	dd 00000600h		;; PointerToRawData
	times 0ch db 0		;; PointerToRelocations to NumberOfLineNumbers
	dd 40000040h 		;; Characteristics

	;; IMAGE SECTION HEADER .rdata END

;; +1b0h

;;

	times 50h db 0	;; jumping to 300h

hdrsize equ $-$$

;; +200h

;;align filealign, db 0

code:

start:

	; dlgTitle2 db "Title", 0
	; dlgMsg2   db "Message", 0

	;; SECTION .text START

	times 5h db 90h		;; replaced getcommandlinea by NOP temporary

	db 6ah,0		;; PUSH 0
	;;push 0

	db 68h,0,30h,40h,0	;; PUSH OFFSET messagebox
	;;db 68h	;; PUSH OFFSET messagebox
	;;dd reltitle
	;;push $-dlgTitle

	db 68h,0ch,30h,40h,0	;; PUSH OFFSET messagebox
	;;push $-dlgMsg

	db 6ah,0		;; PUSH 0
	;;push 00h

	;;db 0e8h,14h,0,0,0	;; CALL MessageBoxA
	db 0e8h,relmsgbox,0,0,0

relmsgbox equ jmptomsgbox-$

	db 6ah,0		;; PUSH 0
	;;push 0

	;;db 0e8h,01h,0,0,0	;; CALL ExitProcess
	db 0e8h,relexit,0,0,0

relexit equ jmptoexit-$

	db 90h			;; replaced INT by NOP

	jmptoexit   db 0ffh,25h,04h,20h,40h,0  ;; JMP DWORD PTR DS: ExitProcess
	times 6h db 90h	 	  ;; replaced getcommandline jmp by nop
	jmptomsgbox db 0ffh,25h,0ch,20h,40h,0  ;; JMP DWORD PTR DS: MessageBoxA

;; +232h

;;

	times 1ceh db 0	;; filling out until @ 400h

codesize equ $-code

	;; SECTION .text END

;; +400h

	;; SECTION .data START

data:

	dlgTitle db 'The Caption',0
	dlgMsg db 'Hello World!'

;; +618h

;;

	times 1e8h db 0		;; filling out until @ 600h

datasize equ $-data

	;; SECTION .data END

;; +600h

	;; SECTION .rdata START

rdata:

	db 72h,20h
	times 2h db 0
	db 64h,20h
	times 6h db 0
	db 92h,20h

;;

	times 06h db 0
	db 50h,20h
	times 0ah db 0
	db 84h,20h
	times 3h db 0
	db 20h
	times 2h db 0
	db 5ch,20h
	times 0ah db 0
	db 0a0h,20h
	times 2h db 0
	db 0ch,20h
	times 16h db 0
	db 72h,20h
	times 2h db 0
	db 64h,20h
	times 6h db 0
	db 92h,20h
	times 6h db 0
	db 9bh,0,45h,78h,69h,74h,50h,72h,6fh,63h,65h,73h
	db 73h,0,0e6h,0,47h,65h,74h,43h,6fh,6dh,6dh,61h,6eh,64h,4ch,69h
	db 6eh,65h,41h,0,6bh,65h,72h,6eh,65h,6ch,33h,32h,2eh,64h,6ch,6ch
	times 2h db 0
	db 0b1h,1h,4dh,65h,73h,73h,61h,67h,65h,42h,6fh,78h,41h,0
	db 75h,73h,65h,72h,33h,32h,2eh,64h,6ch,6ch
	times 6h db 0

;; +4b0h

;;

	times 150h db 0	;; filling out until @ 500h

rdatasize equ $-rdata

	;; SECTION .rdata END

;; +800h

filesize equ $-$$
