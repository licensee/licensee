#ifndef INCLUDE_features_h__
#define INCLUDE_features_h__

/* #undef GIT_DEBUG_POOL */
/* #undef GIT_DEBUG_STRICT_ALLOC */
/* #undef GIT_DEBUG_STRICT_OPEN */

#define GIT_THREADS 1
/* #undef GIT_WIN32_LEAKCHECK */

#define GIT_ARCH_64 1
/* #undef GIT_ARCH_32 */

/* #undef GIT_USE_ICONV */
#define GIT_USE_NSEC 1
#define GIT_USE_STAT_MTIM 1
/* #undef GIT_USE_STAT_MTIMESPEC */
/* #undef GIT_USE_STAT_MTIME_NSEC */
#define GIT_USE_FUTIMENS 1

/* #undef GIT_REGEX_REGCOMP_L */
/* #undef GIT_REGEX_REGCOMP */
/* #undef GIT_REGEX_PCRE */
/* #undef GIT_REGEX_PCRE2 */
#define GIT_REGEX_BUILTIN 1

/* #undef GIT_QSORT_R_BSD */
#define GIT_QSORT_R_GNU
/* #undef GIT_QSORT_S */

/* #undef GIT_SSH */
/* #undef GIT_SSH_MEMORY_CREDENTIALS */

#define GIT_NTLM 1
/* #undef GIT_GSSAPI */
/* #undef GIT_GSSFRAMEWORK */

/* #undef GIT_WINHTTP */
#define GIT_HTTPS 1
#define GIT_OPENSSL 1
/* #undef GIT_OPENSSL_DYNAMIC */
/* #undef GIT_SECURE_TRANSPORT */
/* #undef GIT_MBEDTLS */

#define GIT_SHA1_COLLISIONDETECT 1
/* #undef GIT_SHA1_WIN32 */
/* #undef GIT_SHA1_COMMON_CRYPTO */
/* #undef GIT_SHA1_OPENSSL */
/* #undef GIT_SHA1_MBEDTLS */

#define GIT_RAND_GETENTROPY 1

#endif
