/* Actual four-register APIs from the separately recovered complete ZONE owner.
 * Original published public ZONE.H is missing; this is an explicitly recovered
 * declaration view, not a fabricated historical header or changed ABI. */
void *Z_Malloc(int32 size, int32 tag, int32 zonenum, void *owner);
void Z_Touch(void *ptr);
void Z_ChangeTag(void *ptr, int32 tag);
