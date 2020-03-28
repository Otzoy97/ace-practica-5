prec macro char1, char2
LOCAL _isPlusMinus1, _isProductDivision1, _isPlusMinus2, _isProductDivision2, _isChar2, _isCmp
    push bx
    xor bx, bx
    cmp char1, '+'
    je _isPlusMinus1
    cmp char1, '-'
    je _isPlusMinus1
    cmp char1, '*'
    je _isProductDivision1
    cmp char1, '/'
    je _isProductDivision1
    _isPlusMinus1:
        mov bl, 1h
        jmp _isChar2
    _isProductDivision1:
        mov bl, 2h
    _isChar2:
        cmp char2, '+'
        je _isPlusMinus2
        cmp char2, '-'
        je _isPlusMinus2
        cmp char2, '*'
        je _isProductDivision2
        cmp char2, '/'
        je _isProductDivision2
    _isPlusMinus2:
        mov bh, 1h
        jmp _isCmp
    _isProductDivision2:
        mov bh, 2h
    _isCmp:
        cmp bl, bh
    pop bx
endm