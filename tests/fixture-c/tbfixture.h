/**
 * tbfixture -- a synthetic C library for tbBlob's tests (PRD section 4.6, req. 39-44).
 *
 * Every construct tbBlob must handle appears here at least once. Functions that receive data
 * check it and return 0 when every value is the documented one, else the 1-based position of
 * the first wrong value (argument or field). Functions that produce data produce the
 * documented values ("known values" below). Nothing here depends on anything but the C runtime.
 */
#ifndef TBFIXTURE_H
#define TBFIXTURE_H

#include <stddef.h>
#include <stdint.h>
#include <stdarg.h>


#ifdef TBF_BUILDING
#define TBF_API __declspec(dllexport)
#else
#define TBF_API __declspec(dllimport)
#endif

/* Functions exported through tbfixture.def instead of __declspec(dllexport), as the Windows API
 * does: on x86 their __stdcall exports are undecorated. */
#ifdef TBF_BUILDING
#define TBF_DEF_API
#else
#define TBF_DEF_API __declspec(dllimport)
#endif

#ifdef __cplusplus
extern "C" {
#endif

/* ===================================================================== macros */

#define TBF_VERSION_MAJOR 1                 /* plain integer */
#define TBF_HEX 0x7F                        /* hex */
#define TBF_OCTAL 017                       /* octal = 15 */
#define TBF_UNSIGNED 42u                    /* suffix u */
#define TBF_LONGLONG 1234567890123LL        /* suffix LL, needs 64 bits */
#define TBF_TOPBIT 0x80000000u              /* top bit of 32 */
#define TBF_ALLBITS 0xFFFFFFFFu             /* all 32 bits */
#define TBF_SHIFT (1u << 31)                /* expression = 0x80000000 */
#define TBF_EXPR (TBF_VERSION_MAJOR * 2 + 1)  /* expression = 3 */
#define TBF_NEG (-5)                        /* negative */
#define TBF_REF TBF_HEX                     /* reference to another macro = 0x7F */
#define TBF_CHAR ';'                        /* char literal */
#define TBF_CHAR_ESC '\n'                   /* escaped char literal = 10 */
#define TBF_STRING "tb\"fixture\""          /* string literal with escapes */
#define TBF_INIT { 1, 2 }                   /* initializer: must be skipped */
#define TBF_TWICE(x) ((x) * 2)              /* function-like: must be skipped */
#define TBF_CYCLE_A TBF_CYCLE_B             /* cyclic reference: must be skipped */
#define TBF_CYCLE_B TBF_CYCLE_A

/* Macros whose value depends on the architecture (task 12a): tbBlob must evaluate both dumps. */
#ifdef _WIN64
#define TBF_ARCH_BITS 64                    /* different body per architecture */
#else
#define TBF_ARCH_BITS 32
#define TBF_X86_ONLY 1                      /* defined on x86 only: must be skipped */
#endif
#define TBF_SIZE_MAX SIZE_MAX               /* same body, different value (through SIZE_MAX) */
#define TBF_SIZE_MAX_ALIAS TBF_SIZE_MAX     /* different only through a chain of references */

/* ===================================================================== scalars */

/**
 * All C scalar types as fields.
 * Known values (tbf_fill_scalars / tbf_check_scalars_struct):
 * c='A', sc=-2, uc=200, s=-30000, us=60000, i=-2000000000, ui=4000000000,
 * l=-123456789, ul=3000000000, ll=-1234567890123456789, ull=18000000000000000000,
 * f=1.5, d=-2.25, b=1, z=123456, ip=-7, wc=0x3A9 (Greek capital omega).
 */
typedef struct TBF_SCALARS {
    char c;
    signed char sc;
    unsigned char uc;
    short s;
    unsigned short us;
    int i;
    unsigned int ui;
    long l;
    unsigned long ul;
    long long ll;
    unsigned long long ull;
    float f;
    double d;
    _Bool b;
    size_t z;
    intptr_t ip;
    wchar_t wc;
} TBF_SCALARS;

/** Checks each argument against the known values of TBF_SCALARS, in field order. */
TBF_API int tbf_check_scalars(char c, signed char sc, unsigned char uc, short s, unsigned short us,
                              int i, unsigned int ui, long l, unsigned long ul, long long ll,
                              unsigned long long ull, float f, double d, _Bool b, size_t z,
                              intptr_t ip, wchar_t wc);
/** Fills *out with the known values. */
TBF_API void tbf_fill_scalars(TBF_SCALARS *out);
/** Checks *in against the known values. */
TBF_API int tbf_check_scalars_struct(const TBF_SCALARS *in);

/* Scalar returns: each returns the known value of the matching TBF_SCALARS field. */
TBF_API char tbf_ret_char(void);
TBF_API signed char tbf_ret_schar(void);
TBF_API unsigned char tbf_ret_uchar(void);
TBF_API short tbf_ret_short(void);
TBF_API unsigned short tbf_ret_ushort(void);
TBF_API int tbf_ret_int(void);
TBF_API unsigned int tbf_ret_uint(void);
TBF_API long tbf_ret_long(void);
TBF_API unsigned long tbf_ret_ulong(void);
TBF_API long long tbf_ret_llong(void);
TBF_API unsigned long long tbf_ret_ullong(void);
TBF_API float tbf_ret_float(void);
TBF_API double tbf_ret_double(void);
TBF_API _Bool tbf_ret_bool(void);
TBF_API size_t tbf_ret_size(void);
TBF_API intptr_t tbf_ret_intptr(void);
TBF_API wchar_t tbf_ret_wchar(void);

/* ===================================================================== pointers */

/** A point. */
typedef struct TBF_POINT {
    int x; /**< horizontal */
    int y; /**< vertical */
} TBF_POINT;

/** Adds 1 to *value and returns the new value (scalar pointer, in and out). */
TBF_API int tbf_inc_int(int *value);
/** Sum of values[0..count-1] (pointer to the first element of an array). */
TBF_API int tbf_sum_ints(const int *values, size_t count);
/** Sum of a fixed array parameter, which C passes as a pointer. */
TBF_API int tbf_sum_four(const int values[4]);
/** Byte length of a NUL-terminated UTF-8 string. */
TBF_API size_t tbf_utf8_len(const char *text);
/** Returns 0 when text is the UTF-8 encoding of "héllo ✓" (e-acute, check mark). */
TBF_API int tbf_check_utf8(const char *text);
/** A static UTF-8 string: "héllo ✓" (e-acute, check mark). */
TBF_API const char *tbf_hello_utf8(void);
/** Returns 0 when text is the UTF-16 string L"héllo ✓". */
TBF_API int tbf_check_wide(const wchar_t *text);
/** A static UTF-16 string: L"héllo ✓". */
TBF_API const wchar_t *tbf_hello_wide(void);
/** 1 when p is NULL, else 0. */
TBF_API int tbf_is_null(const void *p);
/** Sets *out to a static UTF-8 string "out" and returns 0 (char** out-parameter). */
TBF_API int tbf_out_string(const char **out);
/** Sets *out to {3, 4} and returns 0 (struct pointer out). */
TBF_API int tbf_fill_point(TBF_POINT *out);
/** -1 when p is NULL, else p->x + p->y. */
TBF_API int tbf_point_sum_or_null(const TBF_POINT *p);
/** A pointer to a static point {5, 6}. */
TBF_API const TBF_POINT *tbf_static_point(void);

/* ===================================================================== opaque handles */

/** An opaque handle whose typedef name differs from its struct name. */
typedef struct tbf_handle_impl TBF_HANDLE;

/** Creates a handle holding value in *out; returns 0. */
TBF_API int tbf_handle_new(TBF_HANDLE **out, int value);
/** The value a handle holds. */
TBF_API int tbf_handle_value(const TBF_HANDLE *handle);
/** Frees a handle; NULL is ignored. */
TBF_API void tbf_handle_free(TBF_HANDLE *handle);

/** An opaque handle declared with the same name as its struct (libgit2's style). */
typedef struct tbf_same tbf_same;

/** A handle returned directly (not through an out-parameter): a static, never NULL. */
TBF_API tbf_same *tbf_same_get(void);
/** 0 when h is the handle tbf_same_get returns, else 1. */
TBF_API int tbf_same_check(const tbf_same *h);

/** Declared but deliberately not defined, so the DLL does not export it (tbBlob must say so). */
TBF_API int tbf_not_exported(void);

/** A struct named through its typedef here and defined further down without a comment (git_transport's pattern). */
typedef struct tbf_late tbf_late;
/** Returns l->value. */
TBF_API int tbf_late_value(const tbf_late *l);

/* ===================================================================== structs by value */

/** 4 bytes. Known values: a=-3, b=4. */
typedef struct TBF_S4 { short a; short b; } TBF_S4;
/** 8 bytes. Known values: a=-5, b=6. */
typedef struct TBF_S8 { int a; int b; } TBF_S8;
/** 16 bytes. Known values: a=7.5, b=-8. */
typedef struct TBF_S16 { double a; long long b; } TBF_S16;
/** 24 bytes. Known values: a=9, b=-10.25, c='z'. */
typedef struct TBF_S24 { int a; double b; char c; } TBF_S24;

TBF_API int tbf_check_s4(TBF_S4 v);
TBF_API int tbf_check_s8(TBF_S8 v);
TBF_API int tbf_check_s16(TBF_S16 v);
TBF_API int tbf_check_s24(TBF_S24 v);
TBF_API TBF_S4 tbf_make_s4(void);
TBF_API TBF_S8 tbf_make_s8(void);
TBF_API TBF_S16 tbf_make_s16(void);
TBF_API TBF_S24 tbf_make_s24(void);

/* ===================================================================== nested, arrays, callbacks */

/**
 * Nested structs and fixed arrays.
 * Known values (tbf_make_rect / tbf_check_rect): tl={1,2}, br={30,40},
 * name="rect" (NUL-padded to 8), weights={0.5, 1.5, 2.5}.
 */
typedef struct TBF_RECT {
    TBF_POINT tl;
    TBF_POINT br;
    char name[8];
    double weights[3];
} TBF_RECT;

TBF_API void tbf_make_rect(TBF_RECT *out);
TBF_API int tbf_check_rect(const TBF_RECT *in);

/** cdecl callback: called with a point and the caller's context. */
typedef int (*tbf_visit_cb)(const TBF_POINT *point, void *context);
/** A typedef of a callback typedef (libgit2's deprecated.h has these). */
typedef tbf_visit_cb tbf_visit_alias_cb;

/** stdcall callback: called with a value and the caller's context. */
typedef int (__stdcall *tbf_visit_std_cb)(int value, void *context);

/** Callbacks in a struct, one of them an unnamed function-pointer field. */
typedef struct TBF_CALLBACKS {
    unsigned int version;
    tbf_visit_cb visit;
    tbf_visit_std_cb visit_std;
    void (*notify)(int code, void *context);
    void *context;
} TBF_CALLBACKS;

/**
 * Calls visit with {1,2} then {3,4}, visit_std with 7, notify with 99, all with
 * callbacks->context. Returns the sum of what visit and visit_std returned.
 * NULL callbacks are skipped.
 */
TBF_API int tbf_run_callbacks(const TBF_CALLBACKS *callbacks);
/**
 * Calls callback for {1,1}, {2,2}, {3,3} in turn, stopping at the first non-zero return,
 * which it returns; 0 when all returned 0.
 */
TBF_API int tbf_foreach_point(tbf_visit_cb callback, void *context);
/* Callback types for parameter-name recovery (CastXML drops function-type parameter names). */
typedef void (*tbf_unnamed_cb)(int, char *);          /* no names: arg1, arg2, nothing lost */
typedef int (*tbf_mixed_cb)(int count, double);       /* count, arg2 */
#define TBF_PARAM(type, name) type name
typedef int (*tbf_macro_cb)(TBF_PARAM(int, first), TBF_PARAM(int, second)); /* cannot be parsed: reported */

/** A stdcall export: a + b. On x86 it is exported decorated, as _tbf_std_add@8. */
TBF_API int __stdcall tbf_std_add(int a, int b);
/** A stdcall export: a - b. tbfixture.def exports it undecorated on x86, as tbf_std_sub. */
TBF_DEF_API int __stdcall tbf_std_sub(int a, int b);

/* ===================================================================== unions */

/** A standalone union (8 bytes). */
typedef union TBF_VALUE {
    int i;
    double d;
    unsigned char bytes[8];
} TBF_VALUE;

/** A union inside a struct. tag 1: value.i = 42; tag 2: value.d = 2.5. */
typedef struct TBF_TAGGED {
    int tag;
    TBF_VALUE value;
} TBF_TAGGED;

/** An anonymous union inside a struct. kind 1: as_int = 77; kind 2: as_float = 0.25. */
typedef struct TBF_ANON {
    int kind;
    union {
        int as_int;
        float as_float;
    };
} TBF_ANON;

TBF_API void tbf_make_tagged(TBF_TAGGED *out, int tag);
TBF_API int tbf_check_tagged(const TBF_TAGGED *in);
TBF_API void tbf_make_anon(TBF_ANON *out, int kind);
TBF_API int tbf_check_anon(const TBF_ANON *in);

/* ===================================================================== bitfields, packing, alignment */

/** Bitfields. Known values: a=1, b=5, c=9, after=-1. */
typedef struct TBF_FLAGS {
    unsigned int a : 1;
    unsigned int b : 3;
    unsigned int c : 4;
    int after;
} TBF_FLAGS;

TBF_API void tbf_make_flags(TBF_FLAGS *out);
TBF_API int tbf_check_flags(const TBF_FLAGS *in);

#pragma pack(push, 1)
/** Packed to 1 (7 bytes). Known values: c='p', i=0x11223344, s=-2. */
typedef struct TBF_PACKED1 {
    char c;
    int i;
    short s;
} TBF_PACKED1;
#pragma pack(pop)

#pragma pack(push, 2)
/** Packed to 2 (14 bytes). Known values: c='q', i=-0x11223344, d=6.5. */
typedef struct TBF_PACKED2 {
    char c;
    int i;
    double d;
} TBF_PACKED2;
#pragma pack(pop)

TBF_API void tbf_make_packed1(TBF_PACKED1 *out);
TBF_API int tbf_check_packed1(const TBF_PACKED1 *in);
TBF_API void tbf_make_packed2(TBF_PACKED2 *out);
TBF_API int tbf_check_packed2(const TBF_PACKED2 *in);

/** Over-aligned to 16 (tB cannot express this; tbBlob must report it). x is returned. */
typedef struct __declspec(align(16)) TBF_ALIGNED {
    int x;
} TBF_ALIGNED;

TBF_API int tbf_aligned_x(const TBF_ALIGNED *in);

/* ===================================================================== variadic */

/** Sum of count int arguments. */
TBF_API int tbf_sum_variadic(int count, ...);
/**
 * Sum of the arguments described by types, one letter each: 'i' int, 'l' long long,
 * 'd' double, 's' const char* (adds its byte length).
 */
TBF_API double tbf_sum_mixed(const char *types, ...);
/** Sum of count int arguments taken from a va_list. */
TBF_API int tbf_vsum(int count, va_list args);

/* ===================================================================== enums */

/** Colors. */
typedef enum TBF_COLOR {
    TBF_RED = -1,   /**< negative value */
    TBF_GREEN = 0,  /* plain trailing comment */
    TBF_BLUE = 5
} TBF_COLOR;

/** Flags with the top bit set. */
typedef enum TBF_BIGFLAGS {
    TBF_FLAG_LOW = 1,
    TBF_FLAG_HIGH = (int)0x80000000u
} TBF_BIGFLAGS;

/* Macros whose values come from enum values (tbBlob must evaluate them using the enums). */
#define TBF_COLOR_BLUE_NEXT (TBF_BLUE + 1)            /* 6 */
#define TBF_COLOR_RED_ALIAS TBF_RED                   /* -1 */
#define TBF_FLAGS_ALL (TBF_FLAG_LOW | TBF_FLAG_HIGH)  /* 0x80000001 */

/** (int)color. */
TBF_API int tbf_color_value(TBF_COLOR color);
/** TBF_BLUE. */
TBF_API TBF_COLOR tbf_ret_color(void);
/** Returns 0 when flags == (TBF_FLAG_LOW | TBF_FLAG_HIGH). */
TBF_API int tbf_check_bigflags(TBF_BIGFLAGS flags);

/* ===================================================================== type aliases (task 10a) */

/* A typedef of a scalar, of a struct and of an enum under new names, and macros naming types. */
typedef uint64_t tbf_size64_t;
typedef TBF_POINT tbf_point_alias;
typedef TBF_COLOR tbf_color_alias;
#define TBF_POINT_MACRO_ALIAS TBF_POINT
#define TBF_COLOR_MACRO_ALIAS TBF_COLOR

/** A struct with a field of a scalar typedef. Known value: total = 1234567890123. */
typedef struct TBF_SIZED {
    tbf_size64_t total;
} TBF_SIZED;

/** Returns 1234567890123 as a tbf_size64_t. */
TBF_API tbf_size64_t tbf_ret_size64(void);
/** Returns 0 when in->total is 1234567890123. */
TBF_API int tbf_check_sized(const TBF_SIZED *in);

/* ===================================================================== naming */

/** Modes; TBF_OPEN collides (ignoring case) with tbf_open, TBF_CLOSED with tbf_closed. */
typedef enum TBF_MODE {
    TBF_OPEN = 1,
    TBF_CLOSED = 2
} TBF_MODE;

/** Collides with the enum value TBF_OPEN; returns TBF_OPEN. */
TBF_API int tbf_open(void);

/** A struct whose name collides with the enum value TBF_CLOSED. */
typedef struct tbf_closed {
    int code;
} tbf_closed;

TBF_API int tbf_closed_code(const tbf_closed *in);

/**
 * Field names that are twinBASIC keywords. Known values: 1, 2, 3, ... in field order.
 * A doc line ending in an underscore looks like a tB line continuation: some_name_
 */
typedef struct TBF_KEYWORDS {
    int type;
    int local;
    int end;
    int next;
    int option;
    int object;
    int string;
    int date;
} TBF_KEYWORDS;

TBF_API void tbf_make_keywords(TBF_KEYWORDS *out);
TBF_API int tbf_check_keywords(const TBF_KEYWORDS *in);
/** Parameter names that are twinBASIC keywords. Returns 0 when they are 1, 2, 3, 4, 5, 6. */
TBF_API int tbf_keyword_params(int type, int end, int option, int object, int to, int step);

struct tbf_late {
    int value;
};

/* ===================================================================== threads (task 18) */

/** Callback for the thread functions: called with the caller's context and a number. */
typedef int (*tbf_thread_cb)(void *context, int n);

/** Calls callback(context, n) once on a thread this library creates, waits for it, and returns
    what the callback returned; -1 when the thread could not be created. */
TBF_API int tbf_call_on_thread(tbf_thread_cb callback, void *context, int n);
/** Starts `threads` threads at once (at most 8); each calls callback(context, its index) `calls`
    times. Returns 0, or -1 when a thread could not be created. */
TBF_API int tbf_call_on_threads(tbf_thread_cb callback, void *context, int threads, int calls);
/** On one worker thread, calls callback(context, i) for i = 1..count, stopping at the first
    non-zero result, which it returns; 0 when every call returned 0. */
TBF_API int tbf_foreach_on_thread(tbf_thread_cb callback, void *context, int count);
/** The OS thread id of the most recent worker thread. */
TBF_API unsigned long tbf_last_thread_id(void);
/** Atomically adds 1 to *value and returns the new value (for callbacks that share a counter). */
TBF_API long tbf_atomic_inc(volatile long *value);

/* ===================================================================== library-allocated memory (task 19) */

/** Returns a newly allocated, NUL-terminated copy of text with ASCII letters in upper case, or NULL
    for NULL. The caller frees it with tbf_free. */
TBF_API char *tbf_strdup_upper(const char *text);
/** Frees memory this library allocated; NULL is ignored. */
TBF_API void tbf_free(void *p);

/** A buffer the library fills and the caller disposes, shaped like libgit2's git_buf. */
typedef struct tbf_buf {
    char *ptr;       /**< the data, NUL-terminated; NULL when empty */
    size_t reserved; /**< bytes allocated */
    size_t size;     /**< bytes used, without the NUL */
} tbf_buf;

/** Fills *out with `count` repetitions of "ab" (NUL-terminated, size 2 * count); returns 0, or -1
    when count is negative. Dispose of it with tbf_buf_dispose. */
TBF_API int tbf_buf_fill(tbf_buf *out, int count);
/** Frees buf->ptr and zeroes the struct; a zeroed buffer is fine. */
TBF_API void tbf_buf_dispose(tbf_buf *buf);
/** How many allocations made by tbf_strdup_upper and tbf_buf_fill are not yet freed. */
TBF_API int tbf_alloc_count(void);

/* ===================================================================== layout table */

/** One row of the layout table: field NULL means the row is sizeof(record). */
typedef struct TBF_LAYOUT_ENTRY {
    const char *record;
    const char *field;
    size_t value;
} TBF_LAYOUT_ENTRY;

/**
 * sizeof and offsetof for every struct and field above (bitfield members excluded),
 * as compiled by MSVC. *count receives the number of rows.
 */
TBF_API const TBF_LAYOUT_ENTRY *tbf_layout_table(size_t *count);

#ifdef __cplusplus
}
#endif

#endif /* TBFIXTURE_H */
