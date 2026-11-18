.intel_syntax noprefix
.code32
.section FIXTURE_ASM,"ax",@progbits
.globl fixture_asm_
.extern __GAME_UNIT_TEXT_fixture_shared
.extern __GAME_UNIT_TEXT_fixture_asm_only
fixture_asm_:
    mov eax, offset __GAME_UNIT_TEXT_fixture_shared
    mov edx, offset __GAME_UNIT_TEXT_fixture_asm_only + 1
    ret
