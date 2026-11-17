; Copyright (C) 1994-1995 Apogee Software, Ltd.
; GPL version 2 or later; see rgb.c for retained notice.
; Grounded live-role register allocation refinement of proven owned323 roundtrip.
; Own-C last-function symbolic stand-in; not historical ASM identity.
; Readable counterpart rgb.c; GPL algorithmic relative ROTT RT_UTIL.C.
bits 32
extern _RGB_Lookup
extern VID_GetPalette_
extern RGB_FindBestColor_
extern RGB_FindEGAColors_
global RGB_MakeColorTable_
segment _TEXT public align=4 class=CODE use32
palette_bytes equ 768
red_index equ 768
red_lookup_base equ 772
green_index equ 776
scaled_green equ 780
blue_short equ 784
scaled_red equ 788
red_short equ 792
green_short equ 796
RGB_MakeColorTable_:
    push ebx ; own-C offset 420
    push ecx ; own-C offset 421
    push edx ; own-C offset 422
    push esi ; own-C offset 423
    push edi ; own-C offset 424
    push ebp ; own-C offset 425
    sub esp, 800 ; own-C offset 426
    xor edx, edx ; own-C offset 432
    mov eax, esp ; own-C offset 434
    mov dword [esp + red_index], edx ; own-C offset 436
    call VID_GetPalette_ ; own-C offset 443
    mov eax, dword [esp + red_index] ; own-C offset 448
    shl eax, 2 ; own-C offset 455
    mov dword [esp + red_lookup_base], edx ; own-C offset 458
    mov dword [esp + scaled_red], eax ; own-C offset 465
loop_472:
    xor ebp, ebp ; own-C offset 472
    mov eax, dword [esp + scaled_red] ; own-C offset 474
    mov dword [esp + green_index], ebp ; own-C offset 481
    mov word [esp + red_short], ax ; own-C offset 488
    mov eax, dword [esp + green_index] ; own-C offset 496
    shl eax, 2 ; own-C offset 503
    mov ebp, dword [esp + red_lookup_base] ; own-C offset 506
    mov dword [esp + scaled_green], eax ; own-C offset 513
loop_520:
    mov eax, dword [esp + scaled_green] ; own-C offset 520
    xor esi, esi ; own-C offset 527
    mov word [esp + green_short], ax ; own-C offset 529
    mov eax, esi ; own-C offset 537
    shl eax, 2 ; own-C offset 539
    mov edi, ebp ; own-C offset 542
    mov word [esp + blue_short], ax ; own-C offset 544
loop_552:
    mov ebx, dword [esp + blue_short - 2] ; own-C offset 552
    mov edx, dword [esp + green_short - 2] ; own-C offset 559
    mov eax, dword [esp + red_short - 2] ; own-C offset 566
    mov ecx, esp ; own-C offset 573
    sar ebx, 16 ; own-C offset 575
    sar edx, 16 ; own-C offset 578
    sar eax, 16 ; own-C offset 581
    inc edi ; own-C offset 584
    call RGB_FindBestColor_ ; own-C offset 585
    mov ecx, dword [esp + blue_short] ; own-C offset 590
    inc esi ; own-C offset 597
    add ecx, 4 ; own-C offset 598
    mov byte [_RGB_Lookup + edi - 1], al ; own-C offset 601
    mov word [esp + blue_short], cx ; own-C offset 607
    cmp esi, 64 ; own-C offset 615
    jl loop_552 ; own-C offset 618
    mov ebx, dword [esp + scaled_green] ; own-C offset 620
    mov eax, dword [esp + green_index] ; own-C offset 627
    add ebp, 64 ; own-C offset 634
    add ebx, 4 ; own-C offset 637
    inc eax ; own-C offset 640
    mov dword [esp + scaled_green], ebx ; own-C offset 641
    mov dword [esp + green_index], eax ; own-C offset 648
    cmp eax, 64 ; own-C offset 655
    jl loop_520 ; own-C offset 658
    mov ecx, dword [esp + red_lookup_base] ; own-C offset 664
    mov edx, dword [esp + scaled_red] ; own-C offset 671
    mov esi, dword [esp + red_index] ; own-C offset 678
    add ecx, 4096 ; own-C offset 685
    add edx, 4 ; own-C offset 691
    inc esi ; own-C offset 694
    mov dword [esp + red_lookup_base], ecx ; own-C offset 695
    mov dword [esp + scaled_red], edx ; own-C offset 702
    mov dword [esp + red_index], esi ; own-C offset 709
    cmp esi, 64 ; own-C offset 716
    jl loop_472 ; own-C offset 719
    call RGB_FindEGAColors_ ; own-C offset 725
    add esp, 800 ; own-C offset 730
    pop ebp ; own-C offset 736
    pop edi ; own-C offset 737
    pop esi ; own-C offset 738
    pop edx ; own-C offset 739
    pop ecx ; own-C offset 740
    pop ebx ; own-C offset 741
    ret ; own-C offset 742
