/* test_tbfixture.c -- calls every tbfixture export with the documented values (and with one
 * deliberately wrong value where the export checks its input) and checks the layout table
 * against sizeof/offsetof compiled here. Prints PASS/FAIL lines; exit code = number of failures. */
#include <stdio.h>
#include <string.h>
#include <wchar.h>
#include <windows.h>
#include "tbfixture.h"
#include "tbfixture_sys.h"

static int g_failures, g_passes;

#define CHECK(name, cond) check_(name, (cond), #cond)
static void check_(const char *name, int ok, const char *expr)
{
    if (ok) { g_passes++; return; }
    g_failures++;
    printf("FAIL %s: %s\n", name, expr);
}

static const TBF_SCALARS KNOWN = {
    'A', -2, 200, -30000, 60000, -2000000000, 4000000000u, -123456789L, 3000000000uL,
    -1234567890123456789LL, 18000000000000000000uLL, 1.5f, -2.25, 1, 123456, -7, 0x3A9
};

/* ---- scalars ---------------------------------------------------------------- */
static void test_scalars(void)
{
    TBF_SCALARS s;
    const TBF_SCALARS *k = &KNOWN;
    CHECK("check_scalars known", tbf_check_scalars(k->c, k->sc, k->uc, k->s, k->us, k->i, k->ui, k->l, k->ul,
                                                   k->ll, k->ull, k->f, k->d, k->b, k->z, k->ip, k->wc) == 0);
    CHECK("check_scalars wrong ip -> 16", tbf_check_scalars(k->c, k->sc, k->uc, k->s, k->us, k->i, k->ui, k->l, k->ul,
                                                            k->ll, k->ull, k->f, k->d, k->b, k->z, 8, k->wc) == 16);
    CHECK("check_scalars wrong ull -> 11", tbf_check_scalars(k->c, k->sc, k->uc, k->s, k->us, k->i, k->ui, k->l, k->ul,
                                                             k->ll, 1, k->f, k->d, k->b, k->z, k->ip, k->wc) == 11);
    memset(&s, 0, sizeof s);
    tbf_fill_scalars(&s);
    CHECK("fill_scalars", s.c == k->c && s.sc == k->sc && s.uc == k->uc && s.s == k->s && s.us == k->us &&
                          s.i == k->i && s.ui == k->ui && s.l == k->l && s.ul == k->ul && s.ll == k->ll &&
                          s.ull == k->ull && s.f == k->f && s.d == k->d && s.b == k->b && s.z == k->z &&
                          s.ip == k->ip && s.wc == k->wc);
    CHECK("check_scalars_struct known", tbf_check_scalars_struct(k) == 0);
    s = KNOWN;
    s.ul = 1;
    CHECK("check_scalars_struct wrong ul -> 9", tbf_check_scalars_struct(&s) == 9);

    CHECK("ret_char", tbf_ret_char() == k->c);
    CHECK("ret_schar", tbf_ret_schar() == k->sc);
    CHECK("ret_uchar", tbf_ret_uchar() == k->uc);
    CHECK("ret_short", tbf_ret_short() == k->s);
    CHECK("ret_ushort", tbf_ret_ushort() == k->us);
    CHECK("ret_int", tbf_ret_int() == k->i);
    CHECK("ret_uint", tbf_ret_uint() == k->ui);
    CHECK("ret_long", tbf_ret_long() == k->l);
    CHECK("ret_ulong", tbf_ret_ulong() == k->ul);
    CHECK("ret_llong", tbf_ret_llong() == k->ll);
    CHECK("ret_ullong", tbf_ret_ullong() == k->ull);
    CHECK("ret_float", tbf_ret_float() == k->f);
    CHECK("ret_double", tbf_ret_double() == k->d);
    CHECK("ret_bool", tbf_ret_bool() == k->b);
    CHECK("ret_size", tbf_ret_size() == k->z);
    CHECK("ret_intptr", tbf_ret_intptr() == k->ip);
    CHECK("ret_wchar", tbf_ret_wchar() == k->wc);
}

/* ---- pointers and handles ----------------------------------------------------- */
static const char HELLO8[] = "h\xC3\xA9llo \xE2\x9C\x93";
static const wchar_t HELLO16[] = L"héllo ✓";

static void test_pointers(void)
{
    int v = 5, arr[4] = { 1, 2, 3, 4 };
    const char *out = NULL;
    TBF_POINT p = { 0, 0 }, q = { 1, 2 };
    const TBF_POINT *sp;
    TBF_HANDLE *h = NULL;

    CHECK("inc_int returns", tbf_inc_int(&v) == 6);
    CHECK("inc_int writes", v == 6);
    CHECK("sum_ints", tbf_sum_ints(arr, 3) == 6);
    CHECK("sum_four", tbf_sum_four(arr) == 10);
    CHECK("utf8_len", tbf_utf8_len(HELLO8) == 10);
    CHECK("check_utf8 known", tbf_check_utf8(HELLO8) == 0);
    CHECK("check_utf8 wrong", tbf_check_utf8("hello") != 0);
    CHECK("hello_utf8", strcmp(tbf_hello_utf8(), HELLO8) == 0);
    CHECK("check_wide known", tbf_check_wide(HELLO16) == 0);
    CHECK("check_wide wrong", tbf_check_wide(L"hello") != 0);
    CHECK("hello_wide", wcscmp(tbf_hello_wide(), HELLO16) == 0);
    CHECK("is_null NULL", tbf_is_null(NULL) == 1);
    CHECK("is_null not", tbf_is_null(&v) == 0);
    CHECK("out_string returns", tbf_out_string(&out) == 0);
    CHECK("out_string writes", out != NULL && strcmp(out, "out") == 0);
    CHECK("fill_point returns", tbf_fill_point(&p) == 0);
    CHECK("fill_point writes", p.x == 3 && p.y == 4);
    CHECK("point_sum_or_null NULL", tbf_point_sum_or_null(NULL) == -1);
    CHECK("point_sum_or_null", tbf_point_sum_or_null(&q) == 3);
    sp = tbf_static_point();
    CHECK("static_point", sp != NULL && sp->x == 5 && sp->y == 6);

    CHECK("handle_new returns", tbf_handle_new(&h, 42) == 0);
    CHECK("handle_new writes", h != NULL);
    if (h) CHECK("handle_value", tbf_handle_value(h) == 42);
    tbf_handle_free(h);
    tbf_handle_free(NULL);
}

/* ---- structs by value ----------------------------------------------------------- */
static void test_byvalue(void)
{
    TBF_S4 s4 = { -3, 4 }, s4w = { -3, 5 };
    TBF_S8 s8 = { -5, 6 }, s8w = { 0, 6 };
    TBF_S16 s16 = { 7.5, -8 }, s16w = { 7.5, 8 };
    TBF_S24 s24 = { 9, -10.25, 'z' }, s24w = { 9, -10.25, 'y' };
    TBF_S4 m4 = tbf_make_s4();
    TBF_S8 m8 = tbf_make_s8();
    TBF_S16 m16 = tbf_make_s16();
    TBF_S24 m24 = tbf_make_s24();
    CHECK("check_s4", tbf_check_s4(s4) == 0);
    CHECK("check_s4 wrong b -> 2", tbf_check_s4(s4w) == 2);
    CHECK("check_s8", tbf_check_s8(s8) == 0);
    CHECK("check_s8 wrong a -> 1", tbf_check_s8(s8w) == 1);
    CHECK("check_s16", tbf_check_s16(s16) == 0);
    CHECK("check_s16 wrong b -> 2", tbf_check_s16(s16w) == 2);
    CHECK("check_s24", tbf_check_s24(s24) == 0);
    CHECK("check_s24 wrong c -> 3", tbf_check_s24(s24w) == 3);
    CHECK("make_s4", m4.a == -3 && m4.b == 4);
    CHECK("make_s8", m8.a == -5 && m8.b == 6);
    CHECK("make_s16", m16.a == 7.5 && m16.b == -8);
    CHECK("make_s24", m24.a == 9 && m24.b == -10.25 && m24.c == 'z');
}

/* ---- nested, arrays, callbacks ----------------------------------------------------- */
typedef struct { void *context_seen[4]; int notify_code; int visits; } CB_STATE;
static CB_STATE g_cb;

static int visit_cb(const TBF_POINT *pt, void *ctx) { g_cb.context_seen[g_cb.visits++ & 1] = ctx; return pt->x * 10 + pt->y; }
static int __stdcall visit_std_cb(int value, void *ctx) { g_cb.context_seen[2] = ctx; return value * 100; }
static void notify_cb(int code, void *ctx) { g_cb.context_seen[3] = ctx; g_cb.notify_code = code; }

static int g_foreach_calls, g_foreach_stop_at;
static int foreach_cb(const TBF_POINT *pt, void *ctx)
{
    (void)ctx;
    g_foreach_calls++;
    return (g_foreach_stop_at && pt->x == g_foreach_stop_at) ? 5 : 0;
}

static void test_nested_and_callbacks(void)
{
    TBF_RECT r, k = { { 1, 2 }, { 30, 40 }, "rect", { 0.5, 1.5, 2.5 } };
    TBF_CALLBACKS cb, none;
    int marker;

    memset(&r, 0, sizeof r);
    tbf_make_rect(&r);
    CHECK("make_rect", memcmp(&r, &k, sizeof r) == 0);
    CHECK("check_rect known", tbf_check_rect(&k) == 0);
    r = k;
    r.weights[2] = 9;
    CHECK("check_rect wrong weights -> 4", tbf_check_rect(&r) == 4);

    memset(&g_cb, 0, sizeof g_cb);
    cb.version = 1;
    cb.visit = visit_cb;
    cb.visit_std = visit_std_cb;
    cb.notify = notify_cb;
    cb.context = &marker;
    CHECK("run_callbacks sum 12+34+700", tbf_run_callbacks(&cb) == 746);
    CHECK("run_callbacks visit twice", g_cb.visits == 2);
    CHECK("run_callbacks notify code", g_cb.notify_code == 99);
    CHECK("run_callbacks contexts", g_cb.context_seen[0] == &marker && g_cb.context_seen[1] == &marker &&
                                    g_cb.context_seen[2] == &marker && g_cb.context_seen[3] == &marker);
    memset(&none, 0, sizeof none);
    CHECK("run_callbacks all NULL", tbf_run_callbacks(&none) == 0);

    g_foreach_calls = 0; g_foreach_stop_at = 0;
    CHECK("foreach_point all", tbf_foreach_point(foreach_cb, NULL) == 0 && g_foreach_calls == 3);
    g_foreach_calls = 0; g_foreach_stop_at = 2;
    CHECK("foreach_point stops", tbf_foreach_point(foreach_cb, NULL) == 5 && g_foreach_calls == 2);
    CHECK("std_add", tbf_std_add(2, 3) == 5);
    CHECK("std_sub", tbf_std_sub(5, 3) == 2);
    CHECK("same_get", tbf_same_get() != NULL);
    CHECK("sys_answer", tbf_sys_answer() == 42);
    {
        tbf_late late = { 7 };
        CHECK("late_value", tbf_late_value(&late) == 7);
    }
    CHECK("same_check", tbf_same_check(tbf_same_get()) == 0 && tbf_same_check(NULL) == 1);
}

/* ---- unions, bitfields, packing, alignment ----------------------------------------------------- */
static void test_layout_kinds(void)
{
    TBF_TAGGED t;
    TBF_ANON a;
    TBF_FLAGS f;
    TBF_PACKED1 p1;
    TBF_PACKED2 p2;
    TBF_ALIGNED al;

    memset(&t, 0, sizeof t);
    tbf_make_tagged(&t, 1);
    CHECK("make_tagged 1", t.tag == 1 && t.value.i == 42);
    CHECK("check_tagged 1", tbf_check_tagged(&t) == 0);
    tbf_make_tagged(&t, 2);
    CHECK("make_tagged 2", t.tag == 2 && t.value.d == 2.5);
    CHECK("check_tagged 2", tbf_check_tagged(&t) == 0);
    t.value.d = 1;
    CHECK("check_tagged wrong -> 2", tbf_check_tagged(&t) == 2);

    memset(&a, 0, sizeof a);
    tbf_make_anon(&a, 1);
    CHECK("make_anon 1", a.kind == 1 && a.as_int == 77);
    CHECK("check_anon 1", tbf_check_anon(&a) == 0);
    tbf_make_anon(&a, 2);
    CHECK("make_anon 2", a.kind == 2 && a.as_float == 0.25f);
    CHECK("check_anon 2", tbf_check_anon(&a) == 0);

    memset(&f, 0, sizeof f);
    tbf_make_flags(&f);
    CHECK("make_flags", f.a == 1 && f.b == 5 && f.c == 9 && f.after == -1);
    CHECK("check_flags", tbf_check_flags(&f) == 0);
    f.c = 3;
    CHECK("check_flags wrong c -> 3", tbf_check_flags(&f) == 3);

    CHECK("sizeof PACKED1 7", sizeof(TBF_PACKED1) == 7);
    memset(&p1, 0, sizeof p1);
    tbf_make_packed1(&p1);
    CHECK("make_packed1", p1.c == 'p' && p1.i == 0x11223344 && p1.s == -2);
    CHECK("check_packed1", tbf_check_packed1(&p1) == 0);
    CHECK("sizeof PACKED2 14", sizeof(TBF_PACKED2) == 14);
    memset(&p2, 0, sizeof p2);
    tbf_make_packed2(&p2);
    CHECK("make_packed2", p2.c == 'q' && p2.i == -0x11223344 && p2.d == 6.5);
    CHECK("check_packed2", tbf_check_packed2(&p2) == 0);

    CHECK("sizeof ALIGNED 16", sizeof(TBF_ALIGNED) == 16);
    al.x = 5;
    CHECK("aligned_x", tbf_aligned_x(&al) == 5);
}

/* ---- variadic ---------------------------------------------------------------------------------- */
static int call_vsum(int count, ...)
{
    int r;
    va_list args;
    va_start(args, count);
    r = tbf_vsum(count, args);
    va_end(args);
    return r;
}

static void test_variadic(void)
{
    CHECK("sum_variadic 3", tbf_sum_variadic(3, 1, 2, 3) == 6);
    CHECK("sum_variadic 0", tbf_sum_variadic(0) == 0);
    CHECK("sum_mixed ilds", tbf_sum_mixed("ilds", 1, 2LL, 0.5, "abc") == 6.5);
    CHECK("sum_mixed big long long", tbf_sum_mixed("l", 1234567890123LL) == 1234567890123.0);
    CHECK("vsum", call_vsum(4, 10, 20, 30, 40) == 100);
}

/* ---- enums and naming ---------------------------------------------------------------------- */
static void test_type_aliases(void)
{
    TBF_SIZED s;
    tbf_point_alias p = { 1, 2 };
    tbf_color_alias c = TBF_BLUE;
    s.total = 1234567890123ull;
    CHECK("ret_size64", tbf_ret_size64() == 1234567890123ull);
    CHECK("check_sized", tbf_check_sized(&s) == 0);
    s.total = 1;
    CHECK("check_sized wrong -> 1", tbf_check_sized(&s) == 1);
    CHECK("point alias is TBF_POINT", tbf_point_sum_or_null(&p) == 3);
    CHECK("color alias is TBF_COLOR", tbf_color_value(c) == 5);
}

static void test_enums_and_naming(void)
{
    TBF_KEYWORDS kw, kk = { 1, 2, 3, 4, 5, 6, 7, 8 };
    tbf_closed c = { 7 };

    CHECK("color_value red", tbf_color_value(TBF_RED) == -1);
    CHECK("ret_color", tbf_ret_color() == TBF_BLUE);
    CHECK("bigflags high value", (int)TBF_FLAG_HIGH == (int)0x80000000u);
    CHECK("check_bigflags", tbf_check_bigflags((TBF_BIGFLAGS)(TBF_FLAG_LOW | TBF_FLAG_HIGH)) == 0);
    CHECK("check_bigflags wrong", tbf_check_bigflags(TBF_FLAG_LOW) != 0);
    CHECK("open", tbf_open() == TBF_OPEN);
    CHECK("closed_code", tbf_closed_code(&c) == 7);
    memset(&kw, 0, sizeof kw);
    tbf_make_keywords(&kw);
    CHECK("make_keywords", memcmp(&kw, &kk, sizeof kw) == 0);
    CHECK("check_keywords", tbf_check_keywords(&kk) == 0);
    kk.date = 0;
    CHECK("check_keywords wrong date -> 8", tbf_check_keywords(&kk) == 8);
    CHECK("keyword_params", tbf_keyword_params(1, 2, 3, 4, 5, 6) == 0);
    CHECK("keyword_params wrong to -> 5", tbf_keyword_params(1, 2, 3, 4, 0, 6) == 5);
}

/* ---- layout table -------------------------------------------------------------------------------- */
#define LAYOUT_ROWS(S, E) \
    S(TBF_SCALARS) E(TBF_SCALARS, c) E(TBF_SCALARS, sc) E(TBF_SCALARS, uc) E(TBF_SCALARS, s) E(TBF_SCALARS, us) \
    E(TBF_SCALARS, i) E(TBF_SCALARS, ui) E(TBF_SCALARS, l) E(TBF_SCALARS, ul) E(TBF_SCALARS, ll) E(TBF_SCALARS, ull) \
    E(TBF_SCALARS, f) E(TBF_SCALARS, d) E(TBF_SCALARS, b) E(TBF_SCALARS, z) E(TBF_SCALARS, ip) E(TBF_SCALARS, wc) \
    S(TBF_POINT) E(TBF_POINT, x) E(TBF_POINT, y) \
    S(TBF_S4) E(TBF_S4, a) E(TBF_S4, b) S(TBF_S8) E(TBF_S8, a) E(TBF_S8, b) \
    S(TBF_S16) E(TBF_S16, a) E(TBF_S16, b) S(TBF_S24) E(TBF_S24, a) E(TBF_S24, b) E(TBF_S24, c) \
    S(TBF_RECT) E(TBF_RECT, tl) E(TBF_RECT, br) E(TBF_RECT, name) E(TBF_RECT, weights) \
    S(TBF_CALLBACKS) E(TBF_CALLBACKS, version) E(TBF_CALLBACKS, visit) E(TBF_CALLBACKS, visit_std) \
    E(TBF_CALLBACKS, notify) E(TBF_CALLBACKS, context) \
    S(TBF_VALUE) E(TBF_VALUE, i) E(TBF_VALUE, d) E(TBF_VALUE, bytes) \
    S(TBF_TAGGED) E(TBF_TAGGED, tag) E(TBF_TAGGED, value) \
    S(TBF_ANON) E(TBF_ANON, kind) E(TBF_ANON, as_int) E(TBF_ANON, as_float) \
    S(TBF_FLAGS) E(TBF_FLAGS, after) \
    S(TBF_PACKED1) E(TBF_PACKED1, c) E(TBF_PACKED1, i) E(TBF_PACKED1, s) \
    S(TBF_PACKED2) E(TBF_PACKED2, c) E(TBF_PACKED2, i) E(TBF_PACKED2, d) \
    S(TBF_ALIGNED) E(TBF_ALIGNED, x) \
    S(TBF_SIZED) E(TBF_SIZED, total) \
    S(tbf_closed) E(tbf_closed, code) \
    S(tbf_late) E(tbf_late, value) \
    S(tbf_buf) E(tbf_buf, ptr) E(tbf_buf, reserved) E(tbf_buf, size) \
    S(TBF_KEYWORDS) E(TBF_KEYWORDS, type) E(TBF_KEYWORDS, local) E(TBF_KEYWORDS, end) E(TBF_KEYWORDS, next) \
    E(TBF_KEYWORDS, option) E(TBF_KEYWORDS, object) E(TBF_KEYWORDS, string) E(TBF_KEYWORDS, date) \
    S(TBF_LAYOUT_ENTRY) E(TBF_LAYOUT_ENTRY, record) E(TBF_LAYOUT_ENTRY, field) E(TBF_LAYOUT_ENTRY, value)

#define ROW_S(rec) { #rec, NULL, sizeof(rec) },
#define ROW_E(rec, fld) { #rec, #fld, offsetof(rec, fld) },
static const TBF_LAYOUT_ENTRY EXPECTED[] = { LAYOUT_ROWS(ROW_S, ROW_E) };

/* ---- threads (task 18) ---- */
static volatile long g_thread_calls;
static unsigned long g_cb_tid;
static int cb_double(void *context, int n) { (void)context; g_cb_tid = GetCurrentThreadId(); return n * 2 + 1; }
static int cb_stop_at_3(void *context, int n) { (void)context; return n == 3 ? 33 : 0; }
static int cb_count(void *context, int n) { (void)n; tbf_atomic_inc((volatile long *)context); return 0; }

static void test_threads(void)
{
    volatile long counter = 0;
    CHECK("call_on_thread result", tbf_call_on_thread(cb_double, NULL, 20) == 41);
    CHECK("call_on_thread ran on another thread", g_cb_tid != 0 && g_cb_tid != GetCurrentThreadId() && g_cb_tid == tbf_last_thread_id());
    CHECK("foreach_on_thread stops at the first non-zero", tbf_foreach_on_thread(cb_stop_at_3, NULL, 10) == 33);
    CHECK("foreach_on_thread all zero", tbf_foreach_on_thread(cb_stop_at_3, NULL, 2) == 0);
    CHECK("call_on_threads 4 x 10000", tbf_call_on_threads(cb_count, (void *)&counter, 4, 10000) == 0 && counter == 40000);
    CHECK("atomic_inc returns the new value", tbf_atomic_inc(&counter) == 40001);
    g_thread_calls = 0;
}

/* ---- library-allocated memory (task 19) ---- */
static void test_memory(void)
{
    int before = tbf_alloc_count();
    char *s = tbf_strdup_upper("h\xc3\xa9llo-1");
    tbf_buf b = { 0 };
    CHECK("strdup_upper copies, ASCII upper-cased", s != NULL && strcmp(s, "H\xc3\xa9LLO-1") == 0);
    CHECK("one allocation outstanding", tbf_alloc_count() == before + 1);
    tbf_free(s);
    tbf_free(NULL);
    CHECK("freed", tbf_alloc_count() == before);
    CHECK("strdup_upper(NULL)", tbf_strdup_upper(NULL) == NULL);
    CHECK("buf_fill", tbf_buf_fill(&b, 3) == 0 && b.size == 6 && b.reserved == 7 && strcmp(b.ptr, "ababab") == 0);
    CHECK("buf allocation outstanding", tbf_alloc_count() == before + 1);
    tbf_buf_dispose(&b);
    CHECK("buf_dispose zeroes", b.ptr == NULL && b.size == 0 && b.reserved == 0 && tbf_alloc_count() == before);
    tbf_buf_dispose(&b);
    CHECK("dispose of a zeroed buffer is harmless", tbf_alloc_count() == before);
    CHECK("buf_fill rejects a negative count", tbf_buf_fill(&b, -1) == -1);
}

static void test_layout_table(void)
{
    size_t n = 0, i, j;
    const TBF_LAYOUT_ENTRY *t = tbf_layout_table(&n);
    size_t want = sizeof EXPECTED / sizeof EXPECTED[0];
    CHECK("layout table not NULL", t != NULL);
    CHECK("layout table row count", n == want);
    if (!t) return;
    for (i = 0; i < want; i++) {
        const TBF_LAYOUT_ENTRY *e = &EXPECTED[i];
        int found = 0;
        for (j = 0; j < n; j++) {
            int same_field = (e->field == NULL && t[j].field == NULL) ||
                             (e->field && t[j].field && strcmp(e->field, t[j].field) == 0);
            if (strcmp(e->record, t[j].record) == 0 && same_field) {
                found = 1;
                if (t[j].value != e->value) {
                    printf("FAIL layout %s.%s: table %zu, compiled %zu\n", e->record, e->field ? e->field : "(size)", t[j].value, e->value);
                    g_failures++;
                } else {
                    g_passes++;
                }
            }
        }
        if (!found) {
            printf("FAIL layout %s.%s: missing from table\n", e->record, e->field ? e->field : "(size)");
            g_failures++;
        }
    }
}

int main(void)
{
    test_scalars();
    test_pointers();
    test_byvalue();
    test_nested_and_callbacks();
    test_layout_kinds();
    test_variadic();
    test_enums_and_naming();
    test_type_aliases();
    test_layout_table();
    test_threads();
    test_memory();
    printf("%d passed, %d failed (%s)\n", g_passes, g_failures, sizeof(void *) == 8 ? "x64" : "x86");
    return g_failures;
}
