#!/bin/ksh -p
# SPDX-License-Identifier: CDDL-1.0

. $STF_SUITE/include/libtest.shlib

verify_runnable "global"

BOOKMARK_COUNT=${BOOKMARK_COUNT:-1000}
DATASET="$TESTPOOL/$TESTFS/bookmark_destroy_capi"
SNAPSHOT="$DATASET@snapshot"
DESTROY_HELPER="$STF_SUITE/bin/zfs_bookmark_destroy"

function cleanup
{
	destroy_dataset "$DATASET" "-R"
}
log_onexit cleanup

log_assert "Delete many bookmarks in one libzfs-core API call."
log_must zfs create "$DATASET"
log_must zfs snapshot "$SNAPSHOT"
for ((index = 0; index < BOOKMARK_COUNT; index++)); do
	log_must zfs bookmark "$SNAPSHOT" "$DATASET#bookmark_$index"
done

SECONDS=0
for ((index = 0; index < BOOKMARK_COUNT; index++)); do
	print "$DATASET#bookmark_$index"
done | log_must "$DESTROY_HELPER"
elapsed=$SECONDS
log_note "C API bookmark deletion: ${elapsed}s (${BOOKMARK_COUNT} bookmarks)"

log_pass "Deleted $BOOKMARK_COUNT bookmarks through the ZFS C API."