/* A header that needs C++, as cairo-dwrite.h does (D-057): read as C it stops with #error, so
 * tbBlob must skip it, say why, and generate everything else. */
#ifndef TBFIXTURE_CPP_H
#define TBFIXTURE_CPP_H

#ifndef __cplusplus
#error tbfixture_cpp.h requires C++
#endif

int tbf_cpp_only(void);

#endif /* TBFIXTURE_CPP_H */
