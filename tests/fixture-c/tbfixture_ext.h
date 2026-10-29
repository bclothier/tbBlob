/**
 * tbfixture_ext -- a second DLL of the same library (D-053). Its functions are declared here,
 * exported by tbfixture_ext.dll, and use tbfixture.h's types: tbBlob must bind each function to
 * the DLL whose export table has it.
 */
#ifndef TBFIXTURE_EXT_H
#define TBFIXTURE_EXT_H

#include "tbfixture.h"

#ifdef TBX_BUILDING
#define TBX_API __declspec(dllexport)
#else
#define TBX_API __declspec(dllimport)
#endif

#ifdef __cplusplus
extern "C" {
#endif

/** Multiplies both coordinates of p by k (NULL is ignored). */
TBX_API void tbx_scale_point(TBF_POINT *p, int k);
/** The extension's version: 2. */
TBX_API int tbx_version(void);
/** Declared but deliberately not defined, so tbfixture_ext.dll does not export it (tbBlob must skip it). */
TBX_API int tbx_not_built(void);

#ifdef __cplusplus
}
#endif

#endif /* TBFIXTURE_EXT_H */
