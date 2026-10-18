# What the tbfixture harness proves (and what it doesn't)

`tbfixture` (`tests\fixture-c\`) is a small C library written for this project. It holds **every C
construct tbBlob is expected to handle, at least once**, with known values documented in
`tbfixture.h`. tbBlob generates bindings for it, and this harness calls them from tB on **win32 and
win64**. Because tbBlob generates mechanically (each kind of C construct always becomes the same tB
form), a construct that works here works wherever it appears in a real library. The libgit2
harness checks that claim against a real API; see `tests\harness-libgit2\COVERAGE.md`.

## How it checks

- **Both directions.** Functions that *receive* data check every value and return 0, or the
  1-based position of the first wrong value. So C confirms what tB sent, and a failure names the
  field. Functions that *produce* data return the documented values, and tB checks them. Most
  constructs are tested both ways, for example a struct filled by C and read in tB, and a struct
  filled in tB and checked by C.
- **Layout against the compiler.** `tbf_layout_table()` returns MSVC's own `sizeof`/`offsetof` for
  every struct and field. The harness compares each row with tB's actual `LenB`/`VarPtr` offsets,
  through the generated `TbLayout` function, and also runs the generated `LayoutMismatches()`
  check, which uses CastXML's expectations.
- **Every export.** Every function in `tbfixture.h` and `tbfixture_sys.h` is called at least once (78 exported, plus
  `tbf_not_exported`, which is declared but deliberately not in the DLL: calling it must raise an
  error, not crash).
- **The C side is tested separately.** `test_tbfixture.c` (202 checks, x86 and x64) proves the C
  library itself, so a harness failure points at the binding, not at the fixture.
- **One error does not stop the run.** Each check group runs under its own error handler, and every
  check is a line in `results\results-<arch>.txt`.

## Coverage by check group

| # | Group | What it proves |
|---|---|---|
| 0 | Loading | The generated `tbfixture_Loader.Load(folder)` picks `win32\` or `win64\`; a missing folder raises an error naming the paths tried; `IsLoaded`, `LoadFile`; the loaded module is this architecture's DLL; `Lib "tbfixture.dll"` binds to it |
| 1 | Layout | Generated expectations match, and tB = MSVC for every row of `tbf_layout_table()`; the over-aligned `TBF_ALIGNED` has no tB layout and is in the report |
| 2 | Scalars as arguments and fields | Every C scalar type (`char`, `signed`/`unsigned char`, `short`, `int`, `long`, `long long` and their unsigned forms, `float`, `double`, `_Bool`, `size_t`, `intptr_t`, `wchar_t`) passed by value (17 arguments in one call) and as struct fields filled by C and by tB; unsigned values with the top bit set as signed bit patterns |
| 3 | Scalar returns | Each of those types as a return value |
| 4 | Pointers | `int*` in/out; array by first element; fixed array parameter `int[4]`; `void*` NULL and non-NULL; struct pointer out; NULL for a `ByRef` struct parameter (`ByVal vbNullPtr`); returned `const T*` read with `RtlMoveMemory` |
| 5 | Strings | UTF-8 in (`const char*`, non-ASCII) and out (static string), UTF-16 in (`StrPtr`) and out, `char**` out-parameter |
| 6 | Opaque handles | Create through a `T**` out-parameter, use, free; free of NULL; a typedef name that differs from the struct name; a same-name typedef (`typedef struct X X`) returned directly from a function; a declared-but-not-exported function raises an error (D-031) |
| 7 | Structs by value | 4, 8, 16 and 24-byte structs passed **and returned** by value (the ABI cases that differ between x86 and x64) |
| 8 | Nested structs and arrays | Struct fields that are structs, `char[8]` and `double[3]` arrays; C-filled and tB-filled |
| 9 | Callbacks | cdecl callback as a parameter; cdecl, stdcall and synthesized (unnamed function-pointer field) delegates stored in a struct; context/payload pointers; a non-zero return stops the C loop; NULL callbacks skipped by C; x86 stdcall export bound as decorated `_name@N` and as undecorated (`.def`) |
| 10 | Unions | Standalone, inside a struct and anonymous unions (storage plus accessors, D-018): written by C and read by tB, written by tB and checked by C; byte-level accessor over a `double` |
| 11 | Bitfields, packing, alignment | Bitfield storage word read and written; `#pragma pack(1)` and `pack(2)` structs both ways; over-aligned struct passed (only its first field read) |
| 12 | Variadic and `va_list` | `...` with literals, a `ByVal` variable (D-006), and mixed `int` / `long long` / `double` / `char*`; `va_list` as `ByRef ParamArray` |
| 13 | Enums | Negative, zero and positive values; a top-bit value; enum as argument and as return |
| 14 | Constants from macros | Decimal, hex, octal, unsigned, `LL`, top-bit and all-bits values, shift and arithmetic expressions, negative, references to other macros, char and escaped char, string with escapes, values from enum members; constants whose value differs by architecture (`#If Win64` pairs, D-030), including one that differs only through a chain of references |
| 15 | Type aliases | Scalar typedef as return and field; struct and enum typedefs and type-naming macros passed where the original type is declared (D-025) |
| 16 | Naming | Renamed enum values (collisions with a function and a struct), a struct named like an enum value, tB keywords as field and parameter names |
| 17 | Extra header (`--also`, D-033) | A function declared only in `tbfixture_sys.h`, which `tbfixture.h` does not include (as `git2/sys/*.h` are not included by `git2.h`) |
| 19 | Memory the library allocates and the caller frees | A returned `char*` read through its pointer and freed with the library's free function (`tbf_free`, NULL harmless); a `git_buf`-shaped struct filled by the library, read through `ptr`/`size`/`reserved`, disposed and zeroed (dispose twice harmless); an outstanding-allocation counter returns to its starting value, so nothing leaks |
| 18 | Callbacks on the library's threads (D-045, D-046) | A cdecl callback invoked from threads the library creates: return value, context, module variable, on a different OS thread from `Main`; a `String`, a `New Collection` and a handled error there; a stop value crossing threads; 4 × 10,000 concurrent calls with an exact atomic count (an unsynchronised counter is reported and can lose updates); `CreateObject` failing without COM on that thread and working after `CoInitializeEx`. The unhandled-error case is not run: it blocks on a modal run-time error box (D-046; SPIKE-10 records it) |

## In the fixture but only compiled, not run

- `tbf_visit_alias_cb` (a typedef of a callback typedef, D-024), and `tbf_unnamed_cb`,
  `tbf_mixed_cb`, `tbf_macro_cb` (callback parameter names). They exist to check generation and
  parameter-name recovery, which unit tests cover. They are never invoked.
- Macros that must be skipped (`TBF_INIT`, `TBF_TWICE`, the `TBF_CYCLE_*` pair, `TBF_X86_ONLY`).
  The unit tests and the generated report check them; there is nothing to run.

## Not in the fixture (gaps)

These C constructs don't appear in `tbfixture.h`, so nothing here proves them. Where the libgit2
harness covers one, it says so.

1. **Pointer-to-enum out-parameters** (`MY_ENUM *out`).
2. **Multi-dimensional array fields** (`int m[2][3]`). The generator supports them; the fixture has
   none.
3. **Arrays of structs**: as a field (`TBF_POINT pts[4]`) or as a pointer-plus-count parameter.
   libgit2 covers a pointer-plus-count of strings (`git_strarray`).
4. **Unions containing structs, and structs nested inside unions**; **anonymous structs**.
5. **Callbacks that take or return a struct by value**, and **floats in a variadic call** (C
   promotes them to `double`).
6. **Other calling conventions**: `__fastcall`, `__vectorcall`, `__thiscall` (C++ only, out of
   scope).
7. **Function pointers returned from a function.**
8. **Flexible array members** (`char data[]` at the end of a struct).
9. **Long-lived library thread pools**, and a library thread exiting while twinBASIC objects created
   on it are still alive. Group 18 uses short-lived threads that are created and joined per call.

Gaps 1–3 use generated forms already proven elsewhere (a `ByRef` of a `Long`, arrays of a proven
element type), so the risk is low. Gap 5 is the one most likely to surprise.

## Re-running

`powershell -ExecutionPolicy Bypass -File tests\run-all.ps1` builds the fixture DLLs, runs the C
tests, and runs this harness on both architectures. If tbBlob was rebuilt, it regenerates the
bindings first, and the harness only needs recompiling in the IDE when the generated code changed
(D-029).
