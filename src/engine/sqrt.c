// "Build Engine & Tools" Copyright (c) 1993-1997 Ken Silverman
// Ken Silverman's official web site: "http://www.advsys.net/ken"
// See the included license file "BUILDLIC.TXT" for license info.
// This file has been modified from Ken Silverman's original release

/* Reconstructed v1.3D helper. The table is defined by the unfinished engine
 * translation unit; this fragment proves code and its two references only.
 * The older helper normalizes magnitude with BSR and indexes a 2048-word
 * square-root table. The later 4096-word/shlookup algorithm does not match.
 */
extern unsigned short sqrtable[2048];

#pragma aux nsqrtasm = \
    "test eax, eax", \
    "jns nonnegative", \
    "neg eax", \
    "nonnegative: bsr ecx, eax", \
    "cmp cl, 11", \
    "jge over2048", \
    "movzx eax, word ptr sqrtable[eax*2]", \
    "jmp sqrtend", \
    "over2048: sub cl, 9", \
    "and cl, 0xfe", \
    "sar eax, cl", \
    "movzx eax, word ptr sqrtable[eax*2]", \
    "sar cl, 1", \
    "shl eax, cl", \
    "sqrtend: sar eax, 10", \
    parm [eax] modify [eax ebx ecx edx]

int ksqrt(long num)
{
    return(nsqrtasm(num));
}
