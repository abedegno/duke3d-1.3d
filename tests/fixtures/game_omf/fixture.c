#pragma data_seg("CONST", "DATA")
static char fixture_shared[4] = "ABC";
static char fixture_asm_only[4] = "XYZ";
#pragma data_seg()
char *fixture_c(void) { return fixture_shared; }
