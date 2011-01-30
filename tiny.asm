; tiny.asm

BITS 32

;
; MZ header
;
; The only two fields that matter are e_magic and e_lfanew

; mzhdr:
;     dw "MZ"                       ; e_magic
;     dw 0                          ; e_cblp UNUSED
;     dw 0                          ; e_cp UNUSED
;     dw 0                          ; e_crlc UNUSED
;     dw 0                          ; e_cparhdr UNUSED
;     dw 0                          ; e_minalloc UNUSED
;     dw 0                          ; e_maxalloc UNUSED
;     dw 0                          ; e_ss UNUSED
;     dw 0                          ; e_sp UNUSED
;     dw 0                          ; e_csum UNUSED
;     dw 0                          ; e_ip UNUSED
;     dw 0                          ; e_cs UNUSED
;     dw 0                          ; e_lsarlc UNUSED
;     dw 0                          ; e_ovno UNUSED
;     times 4 dw 0                  ; e_res UNUSED
;     dw 0                          ; e_oemid UNUSED
;     dw 0                          ; e_oeminfo UNUSED
;     times 10 dw 0                 ; e_res2 UNUSED
;     dd pesig                      ; e_lfanew

org 0
	;; IMAGE DOS HEADER START
	db 4Dh,5Ah		;; e_magic

;; +2h

	times 3ah db 0		;; all fields between e_magic and dos_peoffset

;; +3ch

	dd pesig

;
; PE signature
;

pesig:
    dd "PE"

;
; PE header
;

pehdr:
	dw 14ch	 	    ;; machine
	dw 1h		    ;; section number

	times 0ch db 0	    ;; from timedatestamp to number of symbol fields

	dw opthdrsize	    ;; size of optional header
	dw 103h		    ;; characteristics


    ; dw 0x014C                     ; Machine (Intel 386)
    ; dw 1                          ; NumberOfSections
    ; dd 0x4545BE5D                 ; TimeDateStamp UNUSED
    ; dd 0                          ; PointerToSymbolTable UNUSED
    ; dd 0                          ; NumberOfSymbols UNUSED
    ; dw opthdrsize                 ; SizeOfOptionalHeader
    ; dw 0x103                      ; Characteristics (no relocations, executable, 32 bit
    ;)

;
; PE optional header
;

filealign equ 1
sectalign equ 1

%define round(n, r) (((n+(r-1))/r)*r)

opthdr:


	dw 10bh	 	  	 ;; magic number

	times 2h db 0		 ;; major and minor linker version

	dd round(codesize, filealign)

	times 2h dd 0		 ;; from size of code to uninitialized data

	;; dd 00000200h		 ;; size of code
	;; dd 00000400h			 ;; size of initialized data
	;; dd 0			 ;; size of uninitialized data

	dd start		 ;; address of entry point

	dd code
	dd round(filesize, sectalign)

	;;times 2h dd 0		 ;; from base of code to data

	dd 00400000h		 ;; image base
	dd sectalign		 ;; section alignement
	dd filealign		 ;; file alignement

	times 4h dw 0		 ;; from major os version to minor image version

	dw 4h 	    		 ;; major sub system version

	times 6h db 0		 ;; from minor sub system version to win32 version

	dd round(filesize, sectalign)		 ;; size of image
	dd round(hdrsize, filealign)		 ;; size of headers

	dd 0			 ;; checksum NOT USED

	dw 2h			 ;; sub system

	times 6h db 0		 ;; from dll characteristics to size of stack reserve

	dd 00001000h		 ;; size of stack commit
	dd 00100000h		 ;; size of heap reserve

	times 2h dd 0		 ;; from size of heap commit to loader flags

	dd 00000010h		 ;; number of rva and sizes


    ; dw 0x10B                      ; Magic (PE32)
    ; db 8                          ; MajorLinkerVersion UNUSED
    ; db 0                          ; MinorLinkerVersion UNUSED
    ; dd round(codesize, filealign) ; SizeOfCode UNUSED
    ; dd 0                          ; SizeOfInitializedData UNUSED
    ; dd 0                          ; SizeOfUninitializedData UNUSED
    ; dd start                      ; AddressOfEntryPoint
    ; dd code                       ; BaseOfCode UNUSED
    ; dd round(filesize, sectalign) ; BaseOfData UNUSED
    ; dd 0x400000                   ; ImageBase
    ; dd sectalign                  ; SectionAlignment
    ; dd filealign                  ; FileAlignment
    ; dw 4                          ; MajorOperatingSystemVersion UNUSED
    ; dw 0                          ; MinorOperatingSystemVersion UNUSED
    ; dw 0                          ; MajorImageVersion UNUSED
    ; dw 0                          ; MinorImageVersion UNUSED
    ; dw 4                          ; MajorSubsystemVersion
    ; dw 0                          ; MinorSubsystemVersion UNUSED
    ; dd 0                          ; Win32VersionValue UNUSED
    ; dd round(filesize, sectalign) ; SizeOfImage
    ; dd round(hdrsize, filealign)  ; SizeOfHeaders
    ; dd 0                          ; CheckSum UNUSED
    ; dw 2                          ; Subsystem (Win32 GUI)
    ; dw 0x400                      ; DllCharacteristics UNUSED
    ; dd 0x100000                   ; SizeOfStackReserve UNUSED
    ; dd 0x1000                     ; SizeOfStackCommit
    ; dd 0x100000                   ; SizeOfHeapReserve
    ; dd 0x1000                     ; SizeOfHeapCommit UNUSED
    ; dd 0                          ; LoaderFlags UNUSED
    ; dd 16                         ; NumberOfRvaAndSizes UNUSED

;
; Data directories
;

    ; times 16 dd 0, 0

	times 2h dd 0

	dd 00002014h		;; import table @
	dd 0000003ch		;; import table size

	times 14h dd 0

	dd 00002000h		;; import @ table @
	dd 00000014h		;; import @ table size

	times 6h dd 0


opthdrsize equ $ - opthdr

;
; PE code section
;

    db ".text", 0, 0, 0           ; Name
    dd codesize                   ; VirtualSize
    dd round(hdrsize, sectalign)  ; VirtualAddress
    dd round(codesize, filealign) ; SizeOfRawData
    dd code                       ; PointerToRawData
    dd 0                          ; PointerToRelocations UNUSED
    dd 0                          ; PointerToLinenumbers UNUSED
    dw 0                          ; NumberOfRelocations UNUSED
    dw 0                          ; NumberOfLinenumbers UNUSED
    dd 0x60000020                 ; Characteristics (code, execute, read) UNUSED

hdrsize equ $ - $$

;
; PE code section data
;

align filealign, db 0

code:

; Entry point

start:
    push byte 42
    pop eax
    ret

codesize equ $ - code

filesize equ $ - $$
