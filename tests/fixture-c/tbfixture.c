/* tbfixture.c -- the synthetic C library for tbBlob's tests. See tbfixture.h for the known
 * values. Check functions return 0, or the 1-based position of the first wrong value. */
#define TBF_BUILDING
#include <stdlib.h>
#include <string.h>
#include <wchar.h>
#include <windows.h>
#include "tbfixture.h"
#include "tbfixture_sys.h"

#define WRONG_AT(pos, cond) do { if (!(cond)) return (pos); } while (0)

/* ===================================================================== scalars */

static const TBF_SCALARS KNOWN = {
    'A', -2, 200, -30000, 60000, -2000000000, 4000000000u, -123456789L, 3000000000uL,
    -1234567890123456789LL, 18000000000000000000uLL, 1.5f, -2.25, 1, 123456, -7, 0x3A9
};

TBF_API int tbf_check_scalars(char c, signed char sc, unsigned char uc, short s, unsigned short us,
                              int i, unsigned int ui, long l, unsigned long ul, long long ll,
                              unsigned long long ull, float f, double d, _Bool b, size_t z,
                              intptr_t ip, wchar_t wc)
{
    TBF_SCALARS v;
    v.c = c; v.sc = sc; v.uc = uc; v.s = s; v.us = us; v.i = i; v.ui = ui; v.l = l; v.ul = ul;
    v.ll = ll; v.ull = ull; v.f = f; v.d = d; v.b = b; v.z = z; v.ip = ip; v.wc = wc;
    return tbf_check_scalars_struct(&v);
}

TBF_API void tbf_fill_scalars(TBF_SCALARS *out) { *out = KNOWN; }

TBF_API int tbf_check_scalars_struct(const TBF_SCALARS *in)
{
    WRONG_AT(1, in->c == KNOWN.c);
    WRONG_AT(2, in->sc == KNOWN.sc);
    WRONG_AT(3, in->uc == KNOWN.uc);
    WRONG_AT(4, in->s == KNOWN.s);
    WRONG_AT(5, in->us == KNOWN.us);
    WRONG_AT(6, in->i == KNOWN.i);
    WRONG_AT(7, in->ui == KNOWN.ui);
    WRONG_AT(8, in->l == KNOWN.l);
    WRONG_AT(9, in->ul == KNOWN.ul);
    WRONG_AT(10, in->ll == KNOWN.ll);
    WRONG_AT(11, in->ull == KNOWN.ull);
    WRONG_AT(12, in->f == KNOWN.f);
    WRONG_AT(13, in->d == KNOWN.d);
    WRONG_AT(14, in->b == KNOWN.b);
    WRONG_AT(15, in->z == KNOWN.z);
    WRONG_AT(16, in->ip == KNOWN.ip);
    WRONG_AT(17, in->wc == KNOWN.wc);
    return 0;
}

TBF_API char tbf_ret_char(void) { return KNOWN.c; }
TBF_API signed char tbf_ret_schar(void) { return KNOWN.sc; }
TBF_API unsigned char tbf_ret_uchar(void) { return KNOWN.uc; }
TBF_API short tbf_ret_short(void) { return KNOWN.s; }
TBF_API unsigned short tbf_ret_ushort(void) { return KNOWN.us; }
TBF_API int tbf_ret_int(void) { return KNOWN.i; }
TBF_API unsigned int tbf_ret_uint(void) { return KNOWN.ui; }
TBF_API long tbf_ret_long(void) { return KNOWN.l; }
TBF_API unsigned long tbf_ret_ulong(void) { return KNOWN.ul; }
TBF_API long long tbf_ret_llong(void) { return KNOWN.ll; }
TBF_API unsigned long long tbf_ret_ullong(void) { return KNOWN.ull; }
TBF_API float tbf_ret_float(void) { return KNOWN.f; }
TBF_API double tbf_ret_double(void) { return KNOWN.d; }
TBF_API _Bool tbf_ret_bool(void) { return KNOWN.b; }
TBF_API size_t tbf_ret_size(void) { return KNOWN.z; }
TBF_API intptr_t tbf_ret_intptr(void) { return KNOWN.ip; }
TBF_API wchar_t tbf_ret_wchar(void) { return KNOWN.wc; }

/* ===================================================================== pointers */

static const char HELLO8[] = "h\xC3\xA9llo \xE2\x9C\x93";
static const wchar_t HELLO16[] = L"héllo ✓";
static const TBF_POINT STATIC_POINT = { 5, 6 };

TBF_API int tbf_inc_int(int *value) { return ++*value; }

TBF_API int tbf_sum_ints(const int *values, size_t count)
{
    int sum = 0;
    size_t i;
    for (i = 0; i < count; i++) sum += values[i];
    return sum;
}

TBF_API int tbf_sum_four(const int values[4]) { return values[0] + values[1] + values[2] + values[3]; }
TBF_API size_t tbf_utf8_len(const char *text) { return strlen(text); }
TBF_API int tbf_check_utf8(const char *text) { return strcmp(text, HELLO8) == 0 ? 0 : 1; }
TBF_API const char *tbf_hello_utf8(void) { return HELLO8; }
TBF_API int tbf_check_wide(const wchar_t *text) { return wcscmp(text, HELLO16) == 0 ? 0 : 1; }
TBF_API const wchar_t *tbf_hello_wide(void) { return HELLO16; }
TBF_API int tbf_is_null(const void *p) { return p == NULL ? 1 : 0; }

TBF_API int tbf_out_string(const char **out)
{
    *out = "out";
    return 0;
}

TBF_API int tbf_fill_point(TBF_POINT *out)
{
    out->x = 3;
    out->y = 4;
    return 0;
}

TBF_API int tbf_point_sum_or_null(const TBF_POINT *p) { return p == NULL ? -1 : p->x + p->y; }
TBF_API const TBF_POINT *tbf_static_point(void) { return &STATIC_POINT; }

/* ===================================================================== opaque handles */

struct tbf_handle_impl { int value; };

TBF_API int tbf_handle_new(TBF_HANDLE **out, int value)
{
    TBF_HANDLE *h = (TBF_HANDLE *)malloc(sizeof *h);
    if (h == NULL) return -1;
    h->value = value;
    *out = h;
    return 0;
}

TBF_API int tbf_handle_value(const TBF_HANDLE *handle) { return handle->value; }
TBF_API void tbf_handle_free(TBF_HANDLE *handle) { free(handle); }

/* ===================================================================== structs by value */

TBF_API int tbf_check_s4(TBF_S4 v) { WRONG_AT(1, v.a == -3); WRONG_AT(2, v.b == 4); return 0; }
TBF_API int tbf_check_s8(TBF_S8 v) { WRONG_AT(1, v.a == -5); WRONG_AT(2, v.b == 6); return 0; }
TBF_API int tbf_check_s16(TBF_S16 v) { WRONG_AT(1, v.a == 7.5); WRONG_AT(2, v.b == -8); return 0; }
TBF_API int tbf_check_s24(TBF_S24 v) { WRONG_AT(1, v.a == 9); WRONG_AT(2, v.b == -10.25); WRONG_AT(3, v.c == 'z'); return 0; }
TBF_API TBF_S4 tbf_make_s4(void) { TBF_S4 r = { -3, 4 }; return r; }
TBF_API TBF_S8 tbf_make_s8(void) { TBF_S8 r = { -5, 6 }; return r; }
TBF_API TBF_S16 tbf_make_s16(void) { TBF_S16 r = { 7.5, -8 }; return r; }
TBF_API TBF_S24 tbf_make_s24(void) { TBF_S24 r = { 9, -10.25, 'z' }; return r; }

/* ===================================================================== nested, arrays, callbacks */

static const TBF_RECT KNOWN_RECT = { { 1, 2 }, { 30, 40 }, "rect", { 0.5, 1.5, 2.5 } };

TBF_API void tbf_make_rect(TBF_RECT *out) { *out = KNOWN_RECT; }

TBF_API int tbf_check_rect(const TBF_RECT *in)
{
    WRONG_AT(1, in->tl.x == 1 && in->tl.y == 2);
    WRONG_AT(2, in->br.x == 30 && in->br.y == 40);
    WRONG_AT(3, memcmp(in->name, KNOWN_RECT.name, sizeof in->name) == 0);
    WRONG_AT(4, in->weights[0] == 0.5 && in->weights[1] == 1.5 && in->weights[2] == 2.5);
    return 0;
}

TBF_API int tbf_run_callbacks(const TBF_CALLBACKS *callbacks)
{
    int sum = 0;
    TBF_POINT a = { 1, 2 }, b = { 3, 4 };
    if (callbacks->visit) {
        sum += callbacks->visit(&a, callbacks->context);
        sum += callbacks->visit(&b, callbacks->context);
    }
    if (callbacks->visit_std) sum += callbacks->visit_std(7, callbacks->context);
    if (callbacks->notify) callbacks->notify(99, callbacks->context);
    return sum;
}

TBF_API int tbf_foreach_point(tbf_visit_cb callback, void *context)
{
    int i, r;
    for (i = 1; i <= 3; i++) {
        TBF_POINT p;
        p.x = i;
        p.y = i;
        r = callback(&p, context);
        if (r != 0) return r;
    }
    return 0;
}

struct tbf_same { int unused; };
static struct tbf_same SAME = { 0 };
TBF_API tbf_same *tbf_same_get(void) { return &SAME; }
TBF_API int tbf_same_check(const tbf_same *h) { return h == &SAME ? 0 : 1; }
/* tbf_not_exported is deliberately not defined (see tbfixture.h). */
TBF_API int tbf_sys_answer(void) { return 42; }
TBF_API int tbf_late_value(const tbf_late *l) { return l->value; }

TBF_API int __stdcall tbf_std_add(int a, int b) { return a + b; }
TBF_DEF_API int __stdcall tbf_std_sub(int a, int b) { return a - b; }

/* ===================================================================== unions */

TBF_API void tbf_make_tagged(TBF_TAGGED *out, int tag)
{
    memset(out, 0, sizeof *out);
    out->tag = tag;
    if (tag == 1) out->value.i = 42;
    if (tag == 2) out->value.d = 2.5;
}

TBF_API int tbf_check_tagged(const TBF_TAGGED *in)
{
    if (in->tag == 1) { WRONG_AT(2, in->value.i == 42); return 0; }
    if (in->tag == 2) { WRONG_AT(2, in->value.d == 2.5); return 0; }
    return 1;
}

TBF_API void tbf_make_anon(TBF_ANON *out, int kind)
{
    memset(out, 0, sizeof *out);
    out->kind = kind;
    if (kind == 1) out->as_int = 77;
    if (kind == 2) out->as_float = 0.25f;
}

TBF_API int tbf_check_anon(const TBF_ANON *in)
{
    if (in->kind == 1) { WRONG_AT(2, in->as_int == 77); return 0; }
    if (in->kind == 2) { WRONG_AT(2, in->as_float == 0.25f); return 0; }
    return 1;
}

/* ===================================================================== bitfields, packing, alignment */

TBF_API void tbf_make_flags(TBF_FLAGS *out)
{
    memset(out, 0, sizeof *out);
    out->a = 1;
    out->b = 5;
    out->c = 9;
    out->after = -1;
}

TBF_API int tbf_check_flags(const TBF_FLAGS *in)
{
    WRONG_AT(1, in->a == 1);
    WRONG_AT(2, in->b == 5);
    WRONG_AT(3, in->c == 9);
    WRONG_AT(4, in->after == -1);
    return 0;
}

TBF_API void tbf_make_packed1(TBF_PACKED1 *out) { out->c = 'p'; out->i = 0x11223344; out->s = -2; }
TBF_API int tbf_check_packed1(const TBF_PACKED1 *in)
{
    WRONG_AT(1, in->c == 'p');
    WRONG_AT(2, in->i == 0x11223344);
    WRONG_AT(3, in->s == -2);
    return 0;
}

TBF_API void tbf_make_packed2(TBF_PACKED2 *out) { out->c = 'q'; out->i = -0x11223344; out->d = 6.5; }
TBF_API int tbf_check_packed2(const TBF_PACKED2 *in)
{
    WRONG_AT(1, in->c == 'q');
    WRONG_AT(2, in->i == -0x11223344);
    WRONG_AT(3, in->d == 6.5);
    return 0;
}

TBF_API int tbf_aligned_x(const TBF_ALIGNED *in) { return in->x; }

/* ===================================================================== variadic */

TBF_API int tbf_sum_variadic(int count, ...)
{
    int r;
    va_list args;
    va_start(args, count);
    r = tbf_vsum(count, args);
    va_end(args);
    return r;
}

TBF_API double tbf_sum_mixed(const char *types, ...)
{
    double sum = 0;
    va_list args;
    va_start(args, types);
    for (; *types; types++) {
        switch (*types) {
        case 'i': sum += va_arg(args, int); break;
        case 'l': sum += (double)va_arg(args, long long); break;
        case 'd': sum += va_arg(args, double); break;
        case 's': sum += (double)strlen(va_arg(args, const char *)); break;
        default: break;
        }
    }
    va_end(args);
    return sum;
}

TBF_API int tbf_vsum(int count, va_list args)
{
    int sum = 0, i;
    for (i = 0; i < count; i++) sum += va_arg(args, int);
    return sum;
}

/* ===================================================================== enums */

TBF_API int tbf_color_value(TBF_COLOR color) { return (int)color; }
TBF_API TBF_COLOR tbf_ret_color(void) { return TBF_BLUE; }
TBF_API int tbf_check_bigflags(TBF_BIGFLAGS flags)
{
    return (int)flags == (int)(TBF_FLAG_LOW | TBF_FLAG_HIGH) ? 0 : 1;
}

/* ===================================================================== type aliases */

TBF_API tbf_size64_t tbf_ret_size64(void) { return 1234567890123ull; }
TBF_API int tbf_check_sized(const TBF_SIZED *in) { WRONG_AT(1, in->total == 1234567890123ull); return 0; }

/* ===================================================================== naming */

TBF_API int tbf_open(void) { return TBF_OPEN; }
TBF_API int tbf_closed_code(const tbf_closed *in) { return in->code; }

TBF_API void tbf_make_keywords(TBF_KEYWORDS *out)
{
    out->type = 1; out->local = 2; out->end = 3; out->next = 4;
    out->option = 5; out->object = 6; out->string = 7; out->date = 8;
}

TBF_API int tbf_check_keywords(const TBF_KEYWORDS *in)
{
    WRONG_AT(1, in->type == 1);
    WRONG_AT(2, in->local == 2);
    WRONG_AT(3, in->end == 3);
    WRONG_AT(4, in->next == 4);
    WRONG_AT(5, in->option == 5);
    WRONG_AT(6, in->object == 6);
    WRONG_AT(7, in->string == 7);
    WRONG_AT(8, in->date == 8);
    return 0;
}

TBF_API int tbf_keyword_params(int type, int end, int option, int object, int to, int step)
{
    WRONG_AT(1, type == 1);
    WRONG_AT(2, end == 2);
    WRONG_AT(3, option == 3);
    WRONG_AT(4, object == 4);
    WRONG_AT(5, to == 5);
    WRONG_AT(6, step == 6);
    return 0;
}

/* ===================================================================== threads (task 18) */

typedef struct { tbf_thread_cb cb; void *context; int n; int calls; int stop_on_nonzero; int result; } tbf_job;

static volatile DWORD g_last_tid;

static DWORD WINAPI tbf_worker(LPVOID p)
{
    tbf_job *job = (tbf_job *)p;
    int i, r = 0;
    g_last_tid = GetCurrentThreadId();
    if (job->stop_on_nonzero) {
        for (i = 1; i <= job->calls; i++) {
            r = job->cb(job->context, i);
            if (r != 0) break;
        }
    } else {
        for (i = 0; i < job->calls; i++) r = job->cb(job->context, job->n);
    }
    job->result = r;
    return 0;
}

static int tbf_run_one(tbf_job *job)
{
    HANDLE h = CreateThread(NULL, 0, tbf_worker, job, 0, NULL);
    if (!h) return -1;
    WaitForSingleObject(h, INFINITE);
    CloseHandle(h);
    return job->result;
}

TBF_API int tbf_call_on_thread(tbf_thread_cb callback, void *context, int n)
{
    tbf_job job = { callback, context, n, 1, 0, 0 };
    return tbf_run_one(&job);
}

TBF_API int tbf_foreach_on_thread(tbf_thread_cb callback, void *context, int count)
{
    tbf_job job = { callback, context, 0, count, 1, 0 };
    return tbf_run_one(&job);
}

TBF_API int tbf_call_on_threads(tbf_thread_cb callback, void *context, int threads, int calls)
{
    tbf_job jobs[8];
    HANDLE hs[8];
    int i, made = 0;
    if (threads > 8) threads = 8;
    for (i = 0; i < threads; i++) {
        jobs[i].cb = callback; jobs[i].context = context; jobs[i].n = i; jobs[i].calls = calls;
        jobs[i].stop_on_nonzero = 0; jobs[i].result = 0;
        hs[i] = CreateThread(NULL, 0, tbf_worker, &jobs[i], 0, NULL);
        if (!hs[i]) break;
        made++;
    }
    if (made > 0) WaitForMultipleObjects((DWORD)made, hs, TRUE, INFINITE);
    for (i = 0; i < made; i++) CloseHandle(hs[i]);
    return made == threads ? 0 : -1;
}

TBF_API unsigned long tbf_last_thread_id(void) { return g_last_tid; }

TBF_API long tbf_atomic_inc(volatile long *value) { return InterlockedIncrement(value); }

/* ===================================================================== library-allocated memory (task 19) */

static volatile long g_allocs;

TBF_API char *tbf_strdup_upper(const char *text)
{
    size_t n, i;
    char *r;
    if (!text) return NULL;
    n = strlen(text);
    r = (char *)malloc(n + 1);
    if (!r) return NULL;
    for (i = 0; i <= n; i++) r[i] = (text[i] >= 'a' && text[i] <= 'z') ? (char)(text[i] - 'a' + 'A') : text[i];
    InterlockedIncrement(&g_allocs);
    return r;
}

TBF_API void tbf_free(void *p)
{
    if (!p) return;
    free(p);
    InterlockedDecrement(&g_allocs);
}

TBF_API int tbf_buf_fill(tbf_buf *out, int count)
{
    int i;
    if (!out || count < 0) return -1;
    out->size = (size_t)count * 2;
    out->reserved = out->size + 1;
    out->ptr = (char *)malloc(out->reserved);
    if (!out->ptr) { out->size = out->reserved = 0; return -1; }
    for (i = 0; i < count; i++) { out->ptr[2 * i] = 'a'; out->ptr[2 * i + 1] = 'b'; }
    out->ptr[out->size] = '\0';
    InterlockedIncrement(&g_allocs);
    return 0;
}

TBF_API void tbf_buf_dispose(tbf_buf *buf)
{
    if (!buf) return;
    if (buf->ptr) { free(buf->ptr); InterlockedDecrement(&g_allocs); }
    buf->ptr = NULL;
    buf->reserved = 0;
    buf->size = 0;
}

TBF_API int tbf_alloc_count(void) { return (int)g_allocs; }

/* ===================================================================== layout table */

#define S(rec) { #rec, NULL, sizeof(rec) },
#define E(rec, fld) { #rec, #fld, offsetof(rec, fld) },

static const TBF_LAYOUT_ENTRY LAYOUT[] = {
    S(TBF_SCALARS) E(TBF_SCALARS, c) E(TBF_SCALARS, sc) E(TBF_SCALARS, uc) E(TBF_SCALARS, s)
    E(TBF_SCALARS, us) E(TBF_SCALARS, i) E(TBF_SCALARS, ui) E(TBF_SCALARS, l) E(TBF_SCALARS, ul)
    E(TBF_SCALARS, ll) E(TBF_SCALARS, ull) E(TBF_SCALARS, f) E(TBF_SCALARS, d) E(TBF_SCALARS, b)
    E(TBF_SCALARS, z) E(TBF_SCALARS, ip) E(TBF_SCALARS, wc)
    S(TBF_POINT) E(TBF_POINT, x) E(TBF_POINT, y)
    S(TBF_S4) E(TBF_S4, a) E(TBF_S4, b)
    S(TBF_S8) E(TBF_S8, a) E(TBF_S8, b)
    S(TBF_S16) E(TBF_S16, a) E(TBF_S16, b)
    S(TBF_S24) E(TBF_S24, a) E(TBF_S24, b) E(TBF_S24, c)
    S(TBF_RECT) E(TBF_RECT, tl) E(TBF_RECT, br) E(TBF_RECT, name) E(TBF_RECT, weights)
    S(TBF_CALLBACKS) E(TBF_CALLBACKS, version) E(TBF_CALLBACKS, visit) E(TBF_CALLBACKS, visit_std)
    E(TBF_CALLBACKS, notify) E(TBF_CALLBACKS, context)
    S(TBF_VALUE) E(TBF_VALUE, i) E(TBF_VALUE, d) E(TBF_VALUE, bytes)
    S(TBF_TAGGED) E(TBF_TAGGED, tag) E(TBF_TAGGED, value)
    S(TBF_ANON) E(TBF_ANON, kind) E(TBF_ANON, as_int) E(TBF_ANON, as_float)
    S(TBF_FLAGS) E(TBF_FLAGS, after)
    S(TBF_PACKED1) E(TBF_PACKED1, c) E(TBF_PACKED1, i) E(TBF_PACKED1, s)
    S(TBF_PACKED2) E(TBF_PACKED2, c) E(TBF_PACKED2, i) E(TBF_PACKED2, d)
    S(TBF_ALIGNED) E(TBF_ALIGNED, x)
    S(TBF_SIZED) E(TBF_SIZED, total)
    S(tbf_closed) E(tbf_closed, code)
    S(tbf_late) E(tbf_late, value)
    S(tbf_buf) E(tbf_buf, ptr) E(tbf_buf, reserved) E(tbf_buf, size)
    S(TBF_KEYWORDS) E(TBF_KEYWORDS, type) E(TBF_KEYWORDS, local) E(TBF_KEYWORDS, end)
    E(TBF_KEYWORDS, next) E(TBF_KEYWORDS, option) E(TBF_KEYWORDS, object) E(TBF_KEYWORDS, string)
    E(TBF_KEYWORDS, date)
    S(TBF_LAYOUT_ENTRY) E(TBF_LAYOUT_ENTRY, record) E(TBF_LAYOUT_ENTRY, field) E(TBF_LAYOUT_ENTRY, value)
};

TBF_API const TBF_LAYOUT_ENTRY *tbf_layout_table(size_t *count)
{
    *count = sizeof LAYOUT / sizeof LAYOUT[0];
    return LAYOUT;
}
