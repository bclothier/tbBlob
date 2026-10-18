# What the runtime harnesses prove (and what they don't)

tbBlob generates bindings mechanically: every C construct of the same *kind* (say, "pointer to a
struct as a parameter") becomes the same tB form. So the question that matters is not "was every
function called?" but **"was every kind of binding exercised at least once, on both
architectures?"** Two harnesses answer it together:

- **tbfixture harness** (`tests\harness-fixture\`) — a synthetic C library built to contain every
  construct once. It checks values in both directions (C checks what tB sent, tB checks what C
  returned) and compares tB's struct layout with what MSVC compiled. See
  `tests\harness-fixture\COVERAGE.md` for its own breakdown.
- **libgit2 harness** (`tests\harness-libgit2\`, this folder) — the real library (1.9.1) through the
  same generated bindings: does it hold up on a real, large API with real ownership rules? 99 checks
  on win32 and win64.

Snapshot for task 12c (tB BETA 983, MSVC 14.44, libgit2 1.9.1 from vcpkg). The bindings are generated
from `git2.h` **plus every `git2/sys/*.h`** (`--also`, D-033; `-D ssize_t=intptr_t` because
`sys/stream.h` needs it on MSVC, D-032). That covers 951 of the 953 functions `git2.dll` exports; the
other 2 are in no public header. Counts below come from those bindings.

## How much of libgit2 is called

| | Generated | Called by the harness |
|---|---|---|
| Functions | 960 | 52 (~5%) |
| Types (structs) | 108 | 9 used directly (`git_oid`, `git_signature`, `git_time`, `git_error`, `git_strarray`, `git_diff_options`, `git_diff_delta`, `git_clone_options` with its nested checkout/fetch/remote-callback options, `git_indexer_progress`), plus every Type checked by the layout check |
| Enums | 91 | constants from a few (`GIT_ITEROVER`, `GIT_ENOTFOUND`, `GIT_EEXISTS`, `GIT_ERROR_INVALID`, `GIT_SORT_TOPOLOGICAL`, `GIT_DELTA_*`, `GIT_CLONE_NO_LOCAL`, `GIT_OPT_*`) |
| Callback delegates | 164 (89 of them from the `sys` backend/transport/filter structs) | 3 (`git_reference_foreach_name_cb`, `git_checkout_progress_cb`, `git_indexer_progress_cb`) |
| Layout | all 108 Types | **all** sizes and offsets checked against CastXML on both architectures |

The 52 functions cover a full local workflow (init, stage, commit, revwalk, branch, diff), reading
a repository made by git.exe, error reporting (including the `sys` functions `git_error_set_str` and
`git_error_clear`), global options, and a `file://` clone with progress callbacks.

## Coverage by kind of binding

✔ = exercised at run time on win32 and win64 · — = the construct does not occur there ·
✘ = occurs but is not exercised. "libgit2 count" = generated functions with that kind of parameter or return.

### Parameters

| Kind (C → tB) | tbfixture | libgit2 count | libgit2 harness |
|---|---|---|---|
| Scalar by value: 8/16/32-bit, unsigned as signed bit pattern (`int`, `unsigned`, `char`, `_Bool`, `wchar_t` → `Long`/`Integer`/`Byte`) | ✔ every C scalar type | 145 | ✔ 8 |
| 64-bit by value (`long long`, `int64_t`, typedefs such as `git_time_t`) | ✔ | 3 | ✔ (`git_signature_new` time) |
| `float` / `double` by value | ✔ | 0 | — |
| `size_t` / `intptr_t` / `void*` / `char*` → `ByVal LongPtr` | ✔ | 378 | ✔ 14 |
| Pointer to scalar, in/out (`int*` → `ByRef Long`) | ✔ | 19 | ✔ (`git_libgit2_version`) |
| Pointer to struct (`T*` → `ByRef T`) | ✔ incl. nested structs, arrays in structs | 367 | ✔ 14 |
| NULL for a pointer-to-struct parameter (`ByVal vbNullPtr`) | ✔ | (any of the 367) | ✔ (`git_clone`, `git_diff_tree_to_tree` options) |
| A pointer obtained elsewhere passed to a `ByRef T` parameter (`ByVal ptr`) | — | (any of the 367) | ✔ (`git_signature*` from `git_signature_new`) |
| Opaque handle in (`git_repository*` → `ByVal git_repository`) | ✔ | 708 | ✔ 35 |
| Opaque handle out (`git_repository**` → `ByRef git_repository`) | ✔ | 160 | ✔ 12 |
| One opaque alias where another is declared (`git_object` → `git_commit`) | — | common in libgit2 | ✔ |
| Array of handles (`const git_commit *parents[]` → `ByRef git_commit`, pass element 0) | — | few | ✔ (`git_commit_create`) |
| Pointer-to-pointer out (`char**`, `T**` of a non-opaque struct → `ByRef LongPtr`) | ✔ (`char**`) | 80 | ✔ 1 (`git_signature**`) |
| Fixed array parameter (`int v[4]` → first element `ByRef`) | ✔ | — | — |
| UTF-8 strings in (`const char*` from `ToUtf8`) incl. non-ASCII | ✔ | (most `char*`) | ✔ non-ASCII paths, names |
| UTF-16 strings in (`const wchar_t*` → `StrPtr`) | ✔ | 0 | — |
| Enum by value | ✔ | 47 | ✘ (enum *constants* are passed as plain values, e.g. `git_revwalk_sorting`) |
| Enum via an `Alias` of the enum type (D-025) | ✔ | few | ✘ |
| Pointer to enum, out (`git_xxx_t*` → `ByRef enum`) | ✘ **gap** | 6 | ✘ |
| Struct by value (`T v` → `ByVal T`), 4/8/16/24 bytes | ✔ | 0 | — |
| Variadic `...` (`ByVal ParamArray As Any()`), int/long long/double/pointer, `ByVal` variable rule (D-006) | ✔ | 3 | ✔ (`git_libgit2_opts`, value and pointer forms) |
| `va_list` (`ByRef ParamArray`) | ✔ | 0 | — |
| Callback as a parameter (delegate) | ✔ cdecl | 42 | ✔ 1 (`git_reference_foreach_name`) |
| Keyword-named parameters (`type`, `end`, `to`, `step`…) | ✔ | some | compile only |

### Returns

| Kind | tbfixture | libgit2 count | libgit2 harness |
|---|---|---|---|
| Every C scalar type (incl. unsigned top-bit values, `_Bool`, `wchar_t`) | ✔ | many (`int` error codes everywhere) | ✔ |
| 64-bit | ✔ | 1 | ✔ (`git_commit_time`) |
| `float` / `double` | ✔ | 0 | — |
| Pointer (`const char*`, `const T*`) → `LongPtr`, read with `FromUtf8` / `CType(Of T)` | ✔ | 132 | ✔ 7 (`git_error_last`, `git_commit_author`, `git_diff_get_delta`…) |
| Opaque handle returned directly | ✔ (`tbf_same_get`) | 22 | ✘ |
| Enum | ✔ | 16 | ✘ |
| Struct by value, 4/8/16/24 bytes | ✔ | 0 | — |
| Nothing (`void` → `Sub`) | ✔ | 69 | ✔ 11 (the `*_free` functions, `git_error_clear`) |

### Callbacks

| Kind | tbfixture | libgit2 harness |
|---|---|---|
| cdecl delegate passed as a parameter | ✔ | ✔ |
| cdecl delegate stored in a struct field (options structs) | ✔ | ✔ (`checkout_opts.progress_cb`, `fetch_opts.callbacks.transfer_progress`) |
| Delegate nested two structs deep | — | ✔ (`git_clone_options` → `fetch_opts` → `callbacks`) |
| Delegate synthesized for an unnamed function-pointer field | ✔ | — |
| stdcall callback | ✔ | — (libgit2 has none) |
| Callback receiving a struct pointer (`ByRef T`) / a `char*` / a payload | ✔ | ✔ all three |
| A non-zero return from the callback stops the C loop and is passed back | ✔ | ✔ |
| A delegate declared through a typedef-of-a-callback-typedef (D-024) | compile only | compile only |
| Callback invoked on a thread the library created | ✔ group 18 (D-045, D-046): runs correctly; shared state needs synchronising, COM needs `CoInitializeEx`, errors must be handled inside | ✘ (the operations tested call back on the calling thread) |

### Types and layout

| Kind | tbfixture | libgit2 harness |
|---|---|---|
| Natural alignment of every field, nested structs, fixed arrays | ✔ against MSVC's own `offsetof` table | ✔ against CastXML, all 108 Types |
| `#pragma pack` → `[PackingAlignment(n)]` | ✔ | — (none in libgit2) |
| Unions (storage + accessors, D-018), standalone, nested, anonymous | ✔ read and written from both sides | — (none in libgit2) |
| Bitfields (storage only, D-018) | ✔ storage value | compile and layout only (2 in libgit2) |
| `__declspec(align(n))` | reported as unsupported (by design) | — |
| Pointer-sized fields differing per architecture | ✔ | ✔ |

### Calling conventions and loading

| Kind | tbfixture | libgit2 harness |
|---|---|---|
| cdecl exports | ✔ | ✔ (all of libgit2) |
| x86 stdcall export, decorated `_name@N` → `#If Win64` + `Alias` (D-026) | ✔ | — (none in libgit2) |
| x86 stdcall export undecorated by a `.def` | ✔ | — |
| Renamed function bound with `Alias` (name collision) | — | ✔ (`git_revparse_single_`) |
| The generated loader (D-027): DLL plus dependencies from one folder, both architectures | ✔ `Load(folder)` | ✔ `LoadFile(path)` + `zlib1.dll` from the same folder |
| Memory the library allocates and the caller frees: a returned `char*` + free function, a `git_buf`-style struct + dispose | ✔ group 19, with an allocation counter that returns to zero | ✔ `git_repository_discover` into a `git_buf`, read through `ptr`/`size`, `git_buf_dispose` (libgit2 leaves `ptr` at an internal empty string, not NULL) |
| A header function the DLL does not export: NOTE in the code, listed in the report (D-031) | ✔ calling it raises an error | listed: 9 (`git_blame_file_from_buffer`, `git_diff_patchid_init_options`, and 7 `sys` functions for features this vcpkg build leaves out) |

### Constants

| Kind | tbfixture | libgit2 harness |
|---|---|---|
| Integer, hex, octal, char, string, expression, enum-based macros; top-bit values as bit patterns | ✔ every form | a few used |
| `INT64_MIN` and similar extremes (D-028) | unit test | compiles |
| Constants whose value differs between x86 and x64 → `#If Win64` pairs, also when the difference comes only through a reference (D-030) | ✔ value and type per architecture | ✔ (`SIZE_MAX`, `INTPTR_MAX`, `PTRDIFF_MIN`) |

## Known gaps

Nothing in this list was seen to fail. These are things nothing exercises yet. In rough order of risk:

1. **libgit2 callbacks on its own worker threads.** The tbfixture harness proves twinBASIC callbacks
   run correctly on threads a library creates (D-045). The libgit2 operations tested here all call
   back on the calling thread, so no libgit2 callback is exercised on one of its own threads. The
   guidance for such callbacks is in `docs\USAGE.md` ("Callbacks on the library's own threads").
2. **Pointer-to-enum out-parameters**, and **enum by value into libgit2.** The generated forms are the
   same ones proven elsewhere (a `ByRef` enum is a `ByRef Long`; enums by value pass in tbfixture), so
   the risk is low. Still, no runtime check in libgit2 covers them.
3. **Network transports and credential callbacks** (https, ssh): out of scope for local tests.
4. **Leaks in libgit2** aren't measured. Free functions are called, but nothing checks that libgit2's
   memory is returned. (tbfixture counts its allocations and checks they return to zero, group 19.)

## Re-running

`powershell -ExecutionPolicy Bypass -File tests\run-all.ps1` runs both harnesses on both
architectures. If tbBlob was rebuilt, it regenerates their bindings first, and a harness only needs
recompiling in the IDE when the generated code actually changed (D-029). Each run's per-check results
are in `results\results-<arch>.txt` in each harness folder.
