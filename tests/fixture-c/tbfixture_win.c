/* tbfixture_win: see tbfixture_win.h. Built into tbfixture.dll with tbfixture.c. */
#define TBF_BUILDING
#include <stdlib.h>
#include "tbfixture_win.h"

struct OUT_OPAQUE {
    int n;
};

TBF_API int tbw_font_height(const LOGFONTW *lf)
{
    return lf ? lf->lfHeight : 0;
}

TBF_API void tbw_make_font(LOGFONTW *out)
{
    ZeroMemory(out, sizeof *out);
    out->lfHeight = -13;
    out->lfWeight = FW_BOLD;
    lstrcpyW(out->lfFaceName, L"Arial");
}

TBF_API HDC tbw_screen_dc(void)
{
    return GetDC(NULL);
}

TBF_API int tbw_dc_dpi(HDC dc)
{
    return GetDeviceCaps(dc, LOGPIXELSX);
}

TBF_API int tbw_release_dc(HDC dc)
{
    return ReleaseDC(NULL, dc);
}

TBF_API POINT tbw_point_add(POINT a, POINT b)
{
    POINT r;
    r.x = a.x + b.x;
    r.y = a.y + b.y;
    return r;
}

TBF_API void tbw_make_shape(TBW_SHAPE *out)
{
    out->bounds.left = 1;
    out->bounds.top = 2;
    out->bounds.right = 30;
    out->bounds.bottom = 40;
    out->brush = NULL;
    out->color = 0x00FF8000;
}

TBF_API int tbw_check_shape(const TBW_SHAPE *s)
{
    if (s->bounds.left != 1) return 1;
    if (s->bounds.top != 2) return 2;
    if (s->bounds.right != 30) return 3;
    if (s->bounds.bottom != 40) return 4;
    if (s->brush != NULL) return 5;
    if (s->color != 0x00FF8000) return 6;
    return 0;
}

TBF_API long tbw_file_tell(FILE *f)
{
    return f ? ftell(f) : -1;
}

TBF_API int tbw_stream_ok(IStream *s)
{
    STATSTG st;
    if (!s) return 0;
    if (FAILED(s->lpVtbl->Stat(s, &st, STATFLAG_NONAME))) return -1;
    return 1;
}

TBF_API int tbw_mode_value(OUT_MODE mode)
{
    return (int)mode;
}

static OUT_REC g_rec = { 7, { 3, 2.5 } };

TBF_API OUT_RECP tbw_rec_get(void)
{
    return &g_rec;
}

TBF_API OUT_OPAQUE *tbw_opaque_new(int n)
{
    OUT_OPAQUE *o = (OUT_OPAQUE *)malloc(sizeof *o);
    if (o) o->n = n;
    return o;
}

TBF_API int tbw_opaque_value(const OUT_OPAQUE *o)
{
    return o ? o->n : 0;
}

TBF_API void tbw_opaque_free(OUT_OPAQUE *o)
{
    free(o);
}
