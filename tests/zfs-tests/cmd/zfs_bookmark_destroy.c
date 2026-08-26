// SPDX-License-Identifier: CDDL-1.0
/*
 * Delete bookmark names read one per line from stdin using the libzfs-core
 * batch API.
 */

#include <err.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/nvpair.h>
#include <sys/fs/zfs.h>

#include <libzfs_core.h>

int
main(void)
{
	char line[ZFS_MAX_DATASET_NAME_LEN];
	nvlist_t *bookmarks = fnvlist_alloc();

	while (fgets(line, sizeof (line), stdin) != NULL) {
		size_t length = strlen(line);
		if (length > 0 && line[length - 1] == '\n')
			line[length - 1] = '\0';
		if (line[0] != '\0')
			fnvlist_add_boolean(bookmarks, line);
	}

	if (ferror(stdin))
		err(EXIT_FAILURE, "reading bookmark names");

	(void) libzfs_core_init();
	nvlist_t *errors = NULL;
	int error = lzc_destroy_bookmarks(bookmarks, &errors);
	if (error != 0) {
		fnvlist_free(errors);
		fnvlist_free(bookmarks);
		libzfs_core_fini();
		errno = error;
		err(EXIT_FAILURE, "lzc_destroy_bookmarks");
	}
	if (errors != NULL && fnvlist_num_pairs(errors) != 0) {
		fnvlist_free(errors);
		fnvlist_free(bookmarks);
		libzfs_core_fini();
		errx(EXIT_FAILURE, "lzc_destroy_bookmarks returned errors");
	}

	fnvlist_free(errors);
	fnvlist_free(bookmarks);
	libzfs_core_fini();
	return (EXIT_SUCCESS);
}