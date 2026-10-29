/* tbfixture_ext.dll: see tbfixture_ext.h. */
#define TBX_BUILDING
#include "tbfixture_ext.h"

TBX_API void tbx_scale_point(TBF_POINT *p, int k)
{
    if (p) {
        p->x *= k;
        p->y *= k;
    }
}

TBX_API int tbx_version(void)
{
    return 2;
}

/* Exported, but declared in no header: tbBlob lists it under "Exported but not declared". */
__declspec(dllexport) int tbx_hidden(void);
__declspec(dllexport) int tbx_hidden(void)
{
    return 42;
}
