; This line is a comment.

%include "win32n.inc"

extern MessageBoxA
import MessageBoxA user32.dll
extern ExitProcess
import ExitProcess kernel32.dll
segment .data USE32

title db "hello",0
message db "hello world",0

segment .bss USE32

var1 resb 32

segment .code USE32

..start:

push dword MB_OK
push dword title
push dword message
push dword 0
call [MessageBoxA]

push dword 0
call [ExitProcess]
