/* Own functional consumer of real source TOKENLIB+MACT FILE/UTIL and stock CRT.
 * No SDK objects or substitute SDK definitions are linked. */
#include <stdio.h>
#include <string.h>
#include "types.h"
#include "tokenlib.h"
#define CHECK(x) do { if (!(x)) { printf("FAIL:%d\n",__LINE__); return 1; } } while (0)
int main(void)
{
    char input[]="; heading\n# comment\nsection 17 2.5\n";
    char raw[]="; kept comment\n  line with spaces\n";
    int32 handle,other,number,before;
    double real;
    FILE *file;
    handle=TOKEN_Parse(input,strlen(input),"memory");
    input[0]='X'; /* Parse owns a real copy. */
    CHECK(TOKEN_GetLineNumber(handle)==1);
    CHECK(!TOKEN_TokenAvailable(handle,false));
    CHECK(TOKEN_TokenAvailable(handle,true));
    CHECK(TOKEN_GetLineNumber(handle)==1); /* Availability scans a local cursor. */
    TOKEN_Get(handle,true);CHECK(!strcmp(token,"section"));
    CHECK(TOKEN_GetLineNumber(handle)==3);
    TOKEN_UnGet(handle);TOKEN_Get(handle,false);CHECK(!strcmp(token,"section"));
    TOKEN_GetInteger(handle,&number,false);CHECK(number==17);
    TOKEN_GetDouble(handle,&real,false);CHECK(real==2.5);
    CHECK(!TOKEN_TokenAvailable(handle,false));
    CHECK(!TOKEN_TokenAvailable(handle,true));
    before=TOKEN_GetLineNumber(handle);CHECK(TOKEN_LinesInFile(handle)==1);
    CHECK(TOKEN_GetLineNumber(handle)==before);
    CHECK(!TOKEN_TokenAvailable(handle,true)); /* Record cursor restored. */
    TOKEN_Reset(handle);CHECK(TOKEN_GetLineNumber(handle)==1);
    CHECK(TOKEN_GetSpecific(handle,"17"));
    TOKEN_GetDouble(handle,&real,false);CHECK(real==2.5);
    CHECK(!TOKEN_GetSpecific(handle,"absent"));
    TOKEN_Free(handle);TOKEN_Free(handle); /* Free of empty slot is native no-op. */
    other=TOKEN_Parse(raw,strlen(raw),"raw");CHECK(other==handle);
    CHECK(TOKEN_CommentAvailable(other,false));
    TOKEN_GetRaw(other);CHECK(!strcmp(token,"; kept comment\n"));
    CHECK(!TOKEN_CommentAvailable(other,false));
    CHECK(TOKEN_CommentAvailable(other,true));
    TOKEN_GetRaw(other);CHECK(!strcmp(token,"line with spaces\n"));
    TOKEN_Reset(other);TOKEN_GetLine(other,true);CHECK(!strcmp(token,"line with spaces"));
    CHECK(TOKEN_GetLineNumber(other)==2);
    TOKEN_Free(other);
    file=fopen("TOKEN.TXT","wb");CHECK(file!=NULL);
    CHECK(fputs("123\n",file)>=0);CHECK(fclose(file)==0);
    handle=TOKEN_Load("TOKEN.TXT");TOKEN_GetInteger(handle,&number,true);CHECK(number==123);
    TOKEN_Free(handle);remove("TOKEN.TXT");
    puts("TOKENLIB_OK");
    return 0;
}
