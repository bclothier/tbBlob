# 1 "{REPO}\\tests\\fixture-c\\tbfixture.h"
# 1 "<built-in>" 1
# 1 "<built-in>" 3
# 22 "<built-in>" 3
# 1 "<command line>" 1
# 1 "<built-in>" 2
# 1 "{REPO}\\tests\\fixture-c\\tbfixture.h" 2
# 12 "{REPO}\\tests\\fixture-c\\tbfixture.h"
# 1 "C:/Program Files (x86)/Windows Kits/10/include/10.0.26100.0/ucrt\\stddef.h" 1 3
# 12 "C:/Program Files (x86)/Windows Kits/10/include/10.0.26100.0/ucrt\\stddef.h" 3
# 1 "C:/Program Files (x86)/Windows Kits/10/include/10.0.26100.0/ucrt\\corecrt.h" 1 3
# 10 "C:/Program Files (x86)/Windows Kits/10/include/10.0.26100.0/ucrt\\corecrt.h" 3
# 1 "C:/Program Files/Microsoft Visual Studio/2022/Enterprise/VC/Tools/MSVC/14.44.35207/include\\vcruntime.h" 1 3
# 57 "C:/Program Files/Microsoft Visual Studio/2022/Enterprise/VC/Tools/MSVC/14.44.35207/include\\vcruntime.h" 3
# 1 "C:/Program Files/Microsoft Visual Studio/2022/Enterprise/VC/Tools/MSVC/14.44.35207/include\\sal.h" 1 3
# 2974 "C:/Program Files/Microsoft Visual Studio/2022/Enterprise/VC/Tools/MSVC/14.44.35207/include\\sal.h" 3
# 1 "C:/Program Files/Microsoft Visual Studio/2022/Enterprise/VC/Tools/MSVC/14.44.35207/include\\concurrencysal.h" 1 3
# 2975 "C:/Program Files/Microsoft Visual Studio/2022/Enterprise/VC/Tools/MSVC/14.44.35207/include\\sal.h" 2 3
# 58 "C:/Program Files/Microsoft Visual Studio/2022/Enterprise/VC/Tools/MSVC/14.44.35207/include\\vcruntime.h" 2 3
# 1 "C:/Program Files/Microsoft Visual Studio/2022/Enterprise/VC/Tools/MSVC/14.44.35207/include\\vadefs.h" 1 3
# 15 "C:/Program Files/Microsoft Visual Studio/2022/Enterprise/VC/Tools/MSVC/14.44.35207/include\\vadefs.h" 3
#pragma pack(push, 8)
# 47 "C:/Program Files/Microsoft Visual Studio/2022/Enterprise/VC/Tools/MSVC/14.44.35207/include\\vadefs.h" 3
#pragma warning(push)
#pragma warning(disable: 4514 4820)
# 61 "C:/Program Files/Microsoft Visual Studio/2022/Enterprise/VC/Tools/MSVC/14.44.35207/include\\vadefs.h" 3
        typedef unsigned __int64 uintptr_t;
# 72 "C:/Program Files/Microsoft Visual Studio/2022/Enterprise/VC/Tools/MSVC/14.44.35207/include\\vadefs.h" 3
        typedef char* va_list;
# 155 "C:/Program Files/Microsoft Visual Studio/2022/Enterprise/VC/Tools/MSVC/14.44.35207/include\\vadefs.h" 3
    void __cdecl __va_start(va_list* , ...);
# 207 "C:/Program Files/Microsoft Visual Studio/2022/Enterprise/VC/Tools/MSVC/14.44.35207/include\\vadefs.h" 3
#pragma warning(pop)
#pragma pack(pop)
# 59 "C:/Program Files/Microsoft Visual Studio/2022/Enterprise/VC/Tools/MSVC/14.44.35207/include\\vcruntime.h" 2 3

#pragma warning(push)
#pragma warning(disable: 4514 4820)
# 96 "C:/Program Files/Microsoft Visual Studio/2022/Enterprise/VC/Tools/MSVC/14.44.35207/include\\vcruntime.h" 3
#pragma pack(push, 8)
# 188 "C:/Program Files/Microsoft Visual Studio/2022/Enterprise/VC/Tools/MSVC/14.44.35207/include\\vcruntime.h" 3
    typedef unsigned __int64 size_t;
    typedef __int64 ptrdiff_t;
    typedef __int64 intptr_t;
# 204 "C:/Program Files/Microsoft Visual Studio/2022/Enterprise/VC/Tools/MSVC/14.44.35207/include\\vcruntime.h" 3
    typedef _Bool __vcrt_bool;
# 223 "C:/Program Files/Microsoft Visual Studio/2022/Enterprise/VC/Tools/MSVC/14.44.35207/include\\vcruntime.h" 3
    typedef unsigned short wchar_t;
# 390 "C:/Program Files/Microsoft Visual Studio/2022/Enterprise/VC/Tools/MSVC/14.44.35207/include\\vcruntime.h" 3
    void __cdecl __security_init_cookie(void);
# 399 "C:/Program Files/Microsoft Visual Studio/2022/Enterprise/VC/Tools/MSVC/14.44.35207/include\\vcruntime.h" 3
        void __cdecl __security_check_cookie( uintptr_t _StackCookie);
        __declspec(noreturn) void __cdecl __report_gsfailure( uintptr_t _StackCookie);



extern uintptr_t __security_cookie;







#pragma pack(pop)

#pragma warning(pop)
# 11 "C:/Program Files (x86)/Windows Kits/10/include/10.0.26100.0/ucrt\\corecrt.h" 2 3
# 121 "C:/Program Files (x86)/Windows Kits/10/include/10.0.26100.0/ucrt\\corecrt.h" 3
#pragma warning(push)
#pragma warning(disable: 4324 4514 4574 4710 4793 4820 4995 4996 28719 28726 28727)


#pragma pack(push, 8)
# 274 "C:/Program Files (x86)/Windows Kits/10/include/10.0.26100.0/ucrt\\corecrt.h" 3
    typedef _Bool __crt_bool;
# 371 "C:/Program Files (x86)/Windows Kits/10/include/10.0.26100.0/ucrt\\corecrt.h" 3
             void __cdecl _invalid_parameter_noinfo(void);
         __declspec(noreturn) void __cdecl _invalid_parameter_noinfo_noreturn(void);

__declspec(noreturn)
         void __cdecl _invoke_watson(
               wchar_t const* _Expression,
               wchar_t const* _FunctionName,
               wchar_t const* _FileName,
               unsigned int _LineNo,
               uintptr_t _Reserved);
# 604 "C:/Program Files (x86)/Windows Kits/10/include/10.0.26100.0/ucrt\\corecrt.h" 3
typedef int errno_t;
typedef unsigned short wint_t;
typedef unsigned short wctype_t;
typedef long __time32_t;
typedef __int64 __time64_t;

typedef struct __crt_locale_data_public
{
      unsigned short const* _locale_pctype;
                        int _locale_mb_cur_max;
               unsigned int _locale_lc_codepage;
} __crt_locale_data_public;

typedef struct __crt_locale_pointers
{
    struct __crt_locale_data* locinfo;
    struct __crt_multibyte_data* mbcinfo;
} __crt_locale_pointers;

typedef __crt_locale_pointers* _locale_t;

typedef struct _Mbstatet
{
    unsigned long _Wchar;
    unsigned short _Byte, _State;
} _Mbstatet;

typedef _Mbstatet mbstate_t;
# 645 "C:/Program Files (x86)/Windows Kits/10/include/10.0.26100.0/ucrt\\corecrt.h" 3
        typedef __time64_t time_t;
# 655 "C:/Program Files (x86)/Windows Kits/10/include/10.0.26100.0/ucrt\\corecrt.h" 3
    typedef size_t rsize_t;
# 2072 "C:/Program Files (x86)/Windows Kits/10/include/10.0.26100.0/ucrt\\corecrt.h" 3
#pragma pack(pop)


#pragma warning(pop)
# 13 "C:/Program Files (x86)/Windows Kits/10/include/10.0.26100.0/ucrt\\stddef.h" 2 3

#pragma warning(push)
#pragma warning(disable: 4324 4514 4574 4710 4793 4820 4995 4996 28719 28726 28727)


#pragma pack(push, 8)
# 35 "C:/Program Files (x86)/Windows Kits/10/include/10.0.26100.0/ucrt\\stddef.h" 3
             int* __cdecl _errno(void);


             errno_t __cdecl _set_errno( int _Value);
             errno_t __cdecl _get_errno( int* _Value);
# 55 "C:/Program Files (x86)/Windows Kits/10/include/10.0.26100.0/ucrt\\stddef.h" 3
         extern unsigned long __cdecl __threadid(void);

         extern uintptr_t __cdecl __threadhandle(void);



#pragma pack(pop)

#pragma warning(pop)
# 13 "{REPO}\\tests\\fixture-c\\tbfixture.h" 2
# 1 "C:/Program Files/Microsoft Visual Studio/2022/Enterprise/VC/Tools/MSVC/14.44.35207/include\\stdint.h" 1 3
# 15 "C:/Program Files/Microsoft Visual Studio/2022/Enterprise/VC/Tools/MSVC/14.44.35207/include\\stdint.h" 3
#pragma warning(push)
#pragma warning(disable: 4514 4820)

typedef signed char int8_t;
typedef short int16_t;
typedef int int32_t;
typedef long long int64_t;
typedef unsigned char uint8_t;
typedef unsigned short uint16_t;
typedef unsigned int uint32_t;
typedef unsigned long long uint64_t;

typedef signed char int_least8_t;
typedef short int_least16_t;
typedef int int_least32_t;
typedef long long int_least64_t;
typedef unsigned char uint_least8_t;
typedef unsigned short uint_least16_t;
typedef unsigned int uint_least32_t;
typedef unsigned long long uint_least64_t;

typedef signed char int_fast8_t;
typedef int int_fast16_t;
typedef int int_fast32_t;
typedef long long int_fast64_t;
typedef unsigned char uint_fast8_t;
typedef unsigned int uint_fast16_t;
typedef unsigned int uint_fast32_t;
typedef unsigned long long uint_fast64_t;

typedef long long intmax_t;
typedef unsigned long long uintmax_t;
# 136 "C:/Program Files/Microsoft Visual Studio/2022/Enterprise/VC/Tools/MSVC/14.44.35207/include\\stdint.h" 3
#pragma warning(pop)
# 14 "{REPO}\\tests\\fixture-c\\tbfixture.h" 2
# 1 "C:/Program Files/Microsoft Visual Studio/2022/Enterprise/VC/Tools/MSVC/14.44.35207/include\\stdarg.h" 1 3
# 13 "C:/Program Files/Microsoft Visual Studio/2022/Enterprise/VC/Tools/MSVC/14.44.35207/include\\stdarg.h" 3
#pragma warning(push)
#pragma warning(disable: 4514 4820)

#pragma pack(push, 8)
# 27 "C:/Program Files/Microsoft Visual Studio/2022/Enterprise/VC/Tools/MSVC/14.44.35207/include\\stdarg.h" 3
#pragma pack(pop)

#pragma warning(pop)
# 15 "{REPO}\\tests\\fixture-c\\tbfixture.h" 2
# 75 "{REPO}\\tests\\fixture-c\\tbfixture.h"
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


__declspec(dllimport) int tbf_check_scalars(char c, signed char sc, unsigned char uc, short s, unsigned short us,
                              int i, unsigned int ui, long l, unsigned long ul, long long ll,
                              unsigned long long ull, float f, double d, _Bool b, size_t z,
                              intptr_t ip, wchar_t wc);

__declspec(dllimport) void tbf_fill_scalars(TBF_SCALARS *out);

__declspec(dllimport) int tbf_check_scalars_struct(const TBF_SCALARS *in);


__declspec(dllimport) char tbf_ret_char(void);
__declspec(dllimport) signed char tbf_ret_schar(void);
__declspec(dllimport) unsigned char tbf_ret_uchar(void);
__declspec(dllimport) short tbf_ret_short(void);
__declspec(dllimport) unsigned short tbf_ret_ushort(void);
__declspec(dllimport) int tbf_ret_int(void);
__declspec(dllimport) unsigned int tbf_ret_uint(void);
__declspec(dllimport) long tbf_ret_long(void);
__declspec(dllimport) unsigned long tbf_ret_ulong(void);
__declspec(dllimport) long long tbf_ret_llong(void);
__declspec(dllimport) unsigned long long tbf_ret_ullong(void);
__declspec(dllimport) float tbf_ret_float(void);
__declspec(dllimport) double tbf_ret_double(void);
__declspec(dllimport) _Bool tbf_ret_bool(void);
__declspec(dllimport) size_t tbf_ret_size(void);
__declspec(dllimport) intptr_t tbf_ret_intptr(void);
__declspec(dllimport) wchar_t tbf_ret_wchar(void);




typedef struct TBF_POINT {
    int x;
    int y;
} TBF_POINT;


__declspec(dllimport) int tbf_inc_int(int *value);

__declspec(dllimport) int tbf_sum_ints(const int *values, size_t count);

__declspec(dllimport) int tbf_sum_four(const int values[4]);

__declspec(dllimport) size_t tbf_utf8_len(const char *text);

__declspec(dllimport) int tbf_check_utf8(const char *text);

__declspec(dllimport) const char *tbf_hello_utf8(void);

__declspec(dllimport) int tbf_check_wide(const wchar_t *text);

__declspec(dllimport) const wchar_t *tbf_hello_wide(void);

__declspec(dllimport) int tbf_is_null(const void *p);

__declspec(dllimport) int tbf_out_string(const char **out);

__declspec(dllimport) int tbf_fill_point(TBF_POINT *out);

__declspec(dllimport) int tbf_point_sum_or_null(const TBF_POINT *p);

__declspec(dllimport) const TBF_POINT *tbf_static_point(void);




typedef struct tbf_handle_impl TBF_HANDLE;


__declspec(dllimport) int tbf_handle_new(TBF_HANDLE **out, int value);

__declspec(dllimport) int tbf_handle_value(const TBF_HANDLE *handle);

__declspec(dllimport) void tbf_handle_free(TBF_HANDLE *handle);


typedef struct tbf_same tbf_same;


__declspec(dllimport) tbf_same *tbf_same_get(void);

__declspec(dllimport) int tbf_same_check(const tbf_same *h);


__declspec(dllimport) int tbf_not_exported(void);


typedef struct tbf_late tbf_late;

__declspec(dllimport) int tbf_late_value(const tbf_late *l);




typedef struct TBF_S4 { short a; short b; } TBF_S4;

typedef struct TBF_S8 { int a; int b; } TBF_S8;

typedef struct TBF_S16 { double a; long long b; } TBF_S16;

typedef struct TBF_S24 { int a; double b; char c; } TBF_S24;

__declspec(dllimport) int tbf_check_s4(TBF_S4 v);
__declspec(dllimport) int tbf_check_s8(TBF_S8 v);
__declspec(dllimport) int tbf_check_s16(TBF_S16 v);
__declspec(dllimport) int tbf_check_s24(TBF_S24 v);
__declspec(dllimport) TBF_S4 tbf_make_s4(void);
__declspec(dllimport) TBF_S8 tbf_make_s8(void);
__declspec(dllimport) TBF_S16 tbf_make_s16(void);
__declspec(dllimport) TBF_S24 tbf_make_s24(void);
# 214 "{REPO}\\tests\\fixture-c\\tbfixture.h"
typedef struct TBF_RECT {
    TBF_POINT tl;
    TBF_POINT br;
    char name[8];
    double weights[3];
} TBF_RECT;

__declspec(dllimport) void tbf_make_rect(TBF_RECT *out);
__declspec(dllimport) int tbf_check_rect(const TBF_RECT *in);


typedef int (*tbf_visit_cb)(const TBF_POINT *point, void *context);

typedef tbf_visit_cb tbf_visit_alias_cb;


typedef int (__stdcall *tbf_visit_std_cb)(int value, void *context);


typedef struct TBF_CALLBACKS {
    unsigned int version;
    tbf_visit_cb visit;
    tbf_visit_std_cb visit_std;
    void (*notify)(int code, void *context);
    void *context;
} TBF_CALLBACKS;






__declspec(dllimport) int tbf_run_callbacks(const TBF_CALLBACKS *callbacks);




__declspec(dllimport) int tbf_foreach_point(tbf_visit_cb callback, void *context);

typedef void (*tbf_unnamed_cb)(int, char *);
typedef int (*tbf_mixed_cb)(int count, double);

typedef int (*tbf_macro_cb)(int first, int second);


typedef int (*tbf_annotated_cb)( void *state, void *buffer,
         int size, int *written);

typedef void (*tbf_type_only_cb)(const TBF_POINT *, struct TBF_CALLBACKS *, double);


__declspec(dllimport) int __stdcall tbf_std_add(int a, int b);

__declspec(dllimport) int __stdcall tbf_std_sub(int a, int b);




typedef union TBF_VALUE {
    int i;
    double d;
    unsigned char bytes[8];
} TBF_VALUE;


typedef struct TBF_TAGGED {
    int tag;
    TBF_VALUE value;
} TBF_TAGGED;


typedef struct TBF_ANON {
    int kind;
    union {
        int as_int;
        float as_float;
    };
} TBF_ANON;

__declspec(dllimport) void tbf_make_tagged(TBF_TAGGED *out, int tag);
__declspec(dllimport) int tbf_check_tagged(const TBF_TAGGED *in);
__declspec(dllimport) void tbf_make_anon(TBF_ANON *out, int kind);
__declspec(dllimport) int tbf_check_anon(const TBF_ANON *in);




typedef struct TBF_FLAGS {
    unsigned int a : 1;
    unsigned int b : 3;
    unsigned int c : 4;
    int after;
} TBF_FLAGS;

__declspec(dllimport) void tbf_make_flags(TBF_FLAGS *out);
__declspec(dllimport) int tbf_check_flags(const TBF_FLAGS *in);

#pragma pack(push, 1)

typedef struct TBF_PACKED1 {
    char c;
    int i;
    short s;
} TBF_PACKED1;
#pragma pack(pop)

#pragma pack(push, 2)

typedef struct TBF_PACKED2 {
    char c;
    int i;
    double d;
} TBF_PACKED2;
#pragma pack(pop)

__declspec(dllimport) void tbf_make_packed1(TBF_PACKED1 *out);
__declspec(dllimport) int tbf_check_packed1(const TBF_PACKED1 *in);
__declspec(dllimport) void tbf_make_packed2(TBF_PACKED2 *out);
__declspec(dllimport) int tbf_check_packed2(const TBF_PACKED2 *in);


typedef struct __declspec(align(16)) TBF_ALIGNED {
    int x;
} TBF_ALIGNED;

__declspec(dllimport) int tbf_aligned_x(const TBF_ALIGNED *in);




__declspec(dllimport) int tbf_sum_variadic(int count, ...);




__declspec(dllimport) double tbf_sum_mixed(const char *types, ...);

__declspec(dllimport) int tbf_vsum(int count, va_list args);




typedef enum TBF_COLOR {
    TBF_RED = -1,
    TBF_GREEN = 0,
    TBF_BLUE = 5
} TBF_COLOR;


typedef enum TBF_BIGFLAGS {
    TBF_FLAG_LOW = 1,
    TBF_FLAG_HIGH = (int)0x80000000u
} TBF_BIGFLAGS;







__declspec(dllimport) int tbf_color_value(TBF_COLOR color);

__declspec(dllimport) TBF_COLOR tbf_ret_color(void);

__declspec(dllimport) int tbf_check_bigflags(TBF_BIGFLAGS flags);




typedef uint64_t tbf_size64_t;
typedef TBF_POINT tbf_point_alias;
typedef TBF_COLOR tbf_color_alias;




typedef struct TBF_SIZED {
    tbf_size64_t total;
} TBF_SIZED;


__declspec(dllimport) tbf_size64_t tbf_ret_size64(void);

__declspec(dllimport) int tbf_check_sized(const TBF_SIZED *in);




typedef enum TBF_MODE {
    TBF_OPEN = 1,
    TBF_CLOSED = 2
} TBF_MODE;


__declspec(dllimport) int tbf_open(void);


typedef struct tbf_closed {
    int code;
} tbf_closed;

__declspec(dllimport) int tbf_closed_code(const tbf_closed *in);





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

__declspec(dllimport) void tbf_make_keywords(TBF_KEYWORDS *out);
__declspec(dllimport) int tbf_check_keywords(const TBF_KEYWORDS *in);

__declspec(dllimport) int tbf_keyword_params(int type, int end, int option, int object, int to, int step);

struct tbf_late {
    int value;
};




typedef int (*tbf_thread_cb)(void *context, int n);



__declspec(dllimport) int tbf_call_on_thread(tbf_thread_cb callback, void *context, int n);


__declspec(dllimport) int tbf_call_on_threads(tbf_thread_cb callback, void *context, int threads, int calls);


__declspec(dllimport) int tbf_foreach_on_thread(tbf_thread_cb callback, void *context, int count);

__declspec(dllimport) unsigned long tbf_last_thread_id(void);

__declspec(dllimport) long tbf_atomic_inc(volatile long *value);





__declspec(dllimport) char *tbf_strdup_upper(const char *text);

__declspec(dllimport) void tbf_free(void *p);


typedef struct tbf_buf {
    char *ptr;
    size_t reserved;
    size_t size;
} tbf_buf;



__declspec(dllimport) int tbf_buf_fill(tbf_buf *out, int count);

__declspec(dllimport) void tbf_buf_dispose(tbf_buf *buf);

__declspec(dllimport) int tbf_alloc_count(void);




typedef struct TBF_LAYOUT_ENTRY {
    const char *record;
    const char *field;
    size_t value;
} TBF_LAYOUT_ENTRY;





__declspec(dllimport) const TBF_LAYOUT_ENTRY *tbf_layout_table(size_t *count);
