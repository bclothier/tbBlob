/**
 * tbfixture's "sys" header: deliberately NOT included by tbfixture.h, the way libgit2's
 * git2/sys/*.h are not included by git2.h. tbBlob only sees it when given --also (task 12c).
 */
#ifndef TBFIXTURE_SYS_H
#define TBFIXTURE_SYS_H

#include "tbfixture.h"

#ifdef __cplusplus
extern "C" {
#endif

/** Returns 42. Reachable from tB only when the bindings were generated with --also tbfixture_sys.h. */
TBF_API int tbf_sys_answer(void);

#ifdef __cplusplus
}
#endif

#endif /* TBFIXTURE_SYS_H */
