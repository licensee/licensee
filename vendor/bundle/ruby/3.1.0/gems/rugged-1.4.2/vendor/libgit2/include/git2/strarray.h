/*
 * Copyright (C) the libgit2 contributors. All rights reserved.
 *
 * This file is part of libgit2, distributed under the GNU GPL v2 with
 * a Linking Exception. For full terms see the included COPYING file.
 */
#ifndef INCLUDE_git_strarray_h__
#define INCLUDE_git_strarray_h__

#include "common.h"

/**
 * @file git2/strarray.h
 * @brief Git string array routines
 * @defgroup git_strarray Git string array routines
 * @ingroup Git
 * @{
 */
GIT_BEGIN_DECL

/** Array of strings */
typedef struct git_strarray {
	char **strings;
	size_t count;
} git_strarray;

/**
 * Free the strings contained in a string array.  This method should
 * be called on `git_strarray` objects that were provided by the
 * library.  Not doing so, will result in a memory leak.
 *
 * This does not free the `git_strarray` itself, since the library will
 * never allocate that object directly itself.
 *
 * @param array The git_strarray that contains strings to free
 */
GIT_EXTERN(void) git_strarray_dispose(git_strarray *array);

/**
 * Copy a string array object from source to target.
 *
 * Note: target is overwritten and hence should be empty, otherwise its
 * contents are leaked.  Call git_strarray_free() if necessary.
 *
 * @param tgt target
 * @param src source
 * @return 0 on success, < 0 on allocation failure
 */
GIT_EXTERN(int) git_strarray_copy(git_strarray *tgt, const git_strarray *src);


/** @} */
GIT_END_DECL

#endif

