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

/** A callback type of another library (FreeType's FT_Alloc_Func shape): imported as a delegate. */
typedef int (*OUT_HOOK_FN)(void *ctx, int value);

/** An outside struct with a callback field (FT_MemoryRec_'s shape). */
typedef struct OUT_HOOKS {
    OUT_HOOK_FN hook;
    void *ctx;
} OUT_HOOKS;

/** A union of anonymous structs (cairo_path_data_t's shape): each gets a Type named
 * OUT_PATH_DATA_header / OUT_PATH_DATA_point (D-068). */
typedef union OUT_PATH_DATA {
    struct {
        int type;
        int length;
    } header;
    struct {
        double x, y;
    } point;
} OUT_PATH_DATA;

/** Never used by tbfixture: must not be imported. */
typedef struct OUT_UNUSED {
    int never;
} OUT_UNUSED;

#endif /* OUTLIB_H */
