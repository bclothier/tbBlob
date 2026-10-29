/* A header whose dependency is not there (D-057): tbBlob must skip it, say why, and generate
 * everything else. */
#ifndef TBFIXTURE_MISSING_H
#define TBFIXTURE_MISSING_H

#include "tbfixture_no_such_dependency.h"

int tbf_missing_dep(void);

#endif /* TBFIXTURE_MISSING_H */
