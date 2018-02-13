
; jQ    label
; jnQ   label
; _bt    x, i
; _btc   x, i
; _btr   x, i
; _bts   x, i
; _not   x
; _or    x, y
; _xor   x
; _xchg  x, y
; _inc   x
; _dec   x
; _shl1  x
; _shr1  x
; _add   x, y
; _sub   x, y
; _mov   x, y
; _movC  x, c
; _int    xx

_int            macro   xx
                push    fs
                push    bp
                mov     bp, 0
                mov     fs, bp
                pushf
                if      xx * 4 le 255
                call    dword ptr fs:[bp + xx*4]
                else
                call    dword ptr fs:[xx*4]
                endif
                pop     bp
                pop     fs
                endm

w               equ     (word ptr 0)

e               = 0
xxx             = 123

jQ              macro   ll
                if      e eq 0
                jc      ll
                else
                jnz     ll
                endif
                endm

jnQ             macro   ll
                if      e eq 0
                jnc     ll
                else
                jz      ll
                endif
                endm

makej           macro
                j       = ((i - xxx) xor xxx + xxx) and 15
                endm

_bt             macro   x, i
        e       = 1 - e
        if      e eq 0
                bt      x, i
        else
                test    x, 1 shl i
        endif
                endm

_btc            macro   x, i
        e       = 1 - e
        if      e eq 0
                btc     x, i
        else
                test    x, 1 shl i
                pushf
                xor     x, 1 shl i
                popf
        endif
                endm

_btr            macro   x, i
        e       = 1 - e
        if      e eq 0
                btr     x, i
        else
                ;test    x, 1 shl i
                ;pushf
                and     x, not (1 shl i)
                ;popf
        endif
                endm

_bts            macro   x, i
        e       = 1 - e
        if      e eq 0
                bts     x, i
        else
                ;test    x, 1 shl i
                ;pushf
                or      x, 1 shl i
                ;popf
        endif
                endm

_not            macro   x
                i       = 0
                rept    16
                makej
                _btc    x, j
                i       = i + 1
                endm
                xxx     = xxx + 1
                endm

_or             macro   x, y
                i       = 0
                rept    16
                local   lll
                makej
                _bt     y, j
                jnQ     lll
                _bts    x, j
lll:            i       = i + 1
                endm
                xxx     = xxx + 1
                endm

_xor            macro   x, y
                i       = 0
                rept    16
                local   lll
                makej
                _bt      y, j
                jnQ     lll
                _btc     x, j
lll:            i       = i + 1
                endm
                xxx     = xxx + 1
                endm

_xchg           macro   x, y
                _xor    x, y
                _xor    y, x
                _xor    x, y
                endm

_mov            macro   x, y
                i       = 0
                rept    16
                local   lll
                makej
                _btr     x, j
                _bt      y, j
                jnQ     lll
                _bts     x, j
lll:            i       = i + 1
                endm
                xxx     = xxx + 1
                endm

_inc__          macro   x, i
                local   ll
                rept    16-i
                _btc     x, i
                jnQ     ll
                i       = i + 1
                endm
ll:             endm

_inc            macro   x
                t       = 0
                _inc__  x, t
                endm

_dec__          macro   x, i
                local   l1
                rept    16-i
                _btc     x, i
                jQ      l1
                i       = i + 1
                endm
l1:             endm

_dec            macro   x
                t       = 0
                _dec__  x, t
                endm

_shl1           macro   x
                i       = 14
                rept    15
                local   l1
                _btr     x, i + 1
                _bt      x, i
                jnQ     l1
                _bts     x, i + 1
l1:             i       = i - 1
                endm
                _btr     x, 0
                endm

_shr1           macro   x
                i       = 1
                rept    15
                local   l1
                _btr     x, i - 1
                _bt      x, i
                jnQ     l1
                _bts     x, i - 1
l1:             i       = i + 1
                endm
                _btr     x, 15
                endm

_add            macro   x, y
                i       = 0
                rept    16
                local   l1
                _bt      y, i
                jnQ     l1
                _btc     x, i
                jnQ     l1
                t       = i + 1
                _inc__  x, t
l1:             i       = i + 1
                endm
                endm

_add            macro   x, y
                i       = 0
                rept    16
                local   l1
                _bt      y, i
                jnQ     l1
                _btc     x, i
                jnQ     l1
                t       = i + 1
                _inc__  x, t
l1:             i       = i + 1
                endm
                endm

_sub            macro   x, y
                i       = 0
                rept    16
                local   l1
                _bt      y, i
                jnQ     l1
                _btc     x, i
                jQ      l1
                t       = i + 1
                _dec__  x, t
l1:             i       = i + 1
                endm
                endm

_movC__         macro   x, c
                i       = 0
                rept    16
                makej
                if      (c shr j and 1) eq 0
                _btr     x, j
                else
                _bts     x, j
                endif
                i       = i + 1
                endm
                xxx     = xxx + 1
                endm

_movC           macro   x, c
                t       = c + 0
                _movC__ x, t
                endm


_stosw          macro
                _mov    (es:[di].w), ax
                _inc    di
                _inc    di
                endm

