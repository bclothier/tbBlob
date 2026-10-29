/**
 * tbfixture_win -- functions whose signatures use types declared outside tbfixture's header folder
 * (D-054, D-058): Windows SDK structs, handles and a COM interface, the C runtime's FILE, and the
 * stand-in library outlib.h (-I tests/fixture-outside). Generated with --also tbfixture_win.h.
 * Implemented in tbfixture_win.c, part of tbfixture.dll.
 */
#ifndef TBFIXTURE_WIN_H
#define TBFIXTURE_WIN_H

#include <windows.h>
#include <objidl.h>
#include <stdio.h>
#include "tbfixture.h"
#include <outlib.h>

#ifdef __cplusplus
extern "C" {
#endif

/** A shape: outside struct (RECT) and handle (HBRUSH) as fields. Known values from tbw_make_shape:
 * bounds {1, 2, 30, 40}, brush NULL, color 0x00FF8000. */
typedef struct TBW_SHAPE {
    RECT bounds;
    HBRUSH brush;
    COLORREF color;
} TBW_SHAPE;

/** lf->lfHeight, or 0 for NULL (an outside struct by pointer). */
TBF_API int tbw_font_height(const LOGFONTW *lf);
/** Fills out: lfHeight -13, lfWeight 700, lfFaceName "Arial". */
TBF_API void tbw_make_font(LOGFONTW *out);
/** The screen's device context (GetDC(NULL)); release it with tbw_release_dc. */
TBF_API HDC tbw_screen_dc(void);
/** GetDeviceCaps(dc, LOGPIXELSX). */
TBF_API int tbw_dc_dpi(HDC dc);
/** ReleaseDC(NULL, dc). */
TBF_API int tbw_release_dc(HDC dc);
/** {a.x + b.x, a.y + b.y}: an outside struct passed and returned by value. */
TBF_API POINT tbw_point_add(POINT a, POINT b);
/** Fills out with the known values above. */
TBF_API void tbw_make_shape(TBW_SHAPE *out);
/** 0 when s has the known values, else the 1-based position of the first wrong one. */
TBF_API int tbw_check_shape(const TBW_SHAPE *s);
/** ftell(f), or -1 for NULL (FILE is pointer-only, C11 7.21.3). */
TBF_API long tbw_file_tell(FILE *f);
/** 1 when s is a working IStream (Stat succeeds), 0 for NULL, -1 when Stat fails. */
TBF_API int tbw_stream_ok(IStream *s);
/** The mode's value (an outside enum by value). */
TBF_API int tbw_mode_value(OUT_MODE mode);
/** A static OUT_REC: id 7, inner {tag 3, weight 2.5} (a pointer typedef to an outside struct). */
TBF_API OUT_RECP tbw_rec_get(void);
/** A new OUT_OPAQUE holding n; free it with tbw_opaque_free. */
TBF_API OUT_OPAQUE *tbw_opaque_new(int n);
/** The n it was made with. */
TBF_API int tbw_opaque_value(const OUT_OPAQUE *o);
/** Frees o (NULL is harmless). */
TBF_API void tbw_opaque_free(OUT_OPAQUE *o);

#ifdef __cplusplus
}
#endif

#endif /* TBFIXTURE_WIN_H */
