/*
 * outlib -- a stand-in for another library's headers (D-054): it lives outside tbfixture's header
 * folder, so tbBlob must import the types tbfixture_win.h uses from it ("outside types") instead of
 * leaving their names dangling. Header only: tbfixture_win.c implements what needs code.
 */
#ifndef OUTLIB_H
#define OUTLIB_H

/** An outside enum. */
typedef enum OUT_MODE {
    OUT_MODE_FAST = 1,
    OUT_MODE_SAFE = 2
} OUT_MODE;

/** An outside struct only ever embedded in another (imported because OUT_REC needs it). */
typedef struct OUT_INNER {
    short tag;
    double weight;
} OUT_INNER;

/** An outside struct reached through a pointer typedef (FT_Face's shape). */
typedef struct OUT_REC {
    int id;
    OUT_INNER inner;
} OUT_REC;
typedef OUT_REC *OUT_RECP;

/** An outside incomplete struct: only ever a pointer. */
typedef struct OUT_OPAQUE OUT_OPAQUE;

/** Never used by tbfixture: must not be imported. */
typedef struct OUT_UNUSED {
    int never;
} OUT_UNUSED;

#endif /* OUTLIB_H */
