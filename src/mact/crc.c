/* Reconstructed MACT CRC.c, derived from the pinned original member's
 * instructions and CRC-16/IBM polynomial, not from available original C text.
 * Original MACT authorship/copyright and source license are unresolved.
 * This private reconstruction is not relabelled GPL; no distribution grant.
 *
 * Native ABI evidence: CRC/data arguments and results use 32-bit int register
 * arithmetic; buffer reads are unsigned bytes, length/counter unsigned32.
 * Table elements are signed16. CalculateCRC explicitly zero-extends their
 * values so its zero-seeded result is the usual 16-bit reflected CRC.
 * UpdateCRC retains the original signed table promotion; its low16 bits are
 * the CRC update. Caller-side narrowing/signature spelling is not established.
 * The original complete bodies determine these types and operation ordering.
 */
#include "crctable.h"

int UpdateCRC(int crc, int data)
{
    return (crc >> 8) ^ crc16tab[(crc ^ data) & 255];
}
int CalculateCRC(unsigned char *buffer, unsigned length)
{
    int crc = 0;
    unsigned i;
    for (i = 0; i < length; i++) {
        int index = (crc ^ *buffer++) & 255;
        crc >>= 8;
        crc ^= (unsigned short)crc16tab[index];
    }
    return crc;
}
