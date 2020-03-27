.include stringH.asm
.include fileH.asm
.model small
.386
.stack
.data
.code
main proc
    MOV AX, @DATA
    MOV DS, AX

main endp
end main