#!/bin/ksh -p
# SPDX-License-Identifier: CDDL-1.0

. $STF_SUITE/include/libtest.shlib
. $STF_SUITE/tests/functional/channel_program/channel_common.kshlib

verify_runnable "global"

BOOKMARK_COUNT=${BOOKMARK_COUNT:-1000}
DATASET="$TESTPOOL/$TESTFS/bookmark_destroy_channel"
SNAPSHOT="$DATASET@snapshot"

function cleanup
{
	destroy_dataset "$DATASET" "-R"
}
log_onexit cleanup

log_assert "Delete many bookmarks from a channel program."
log_must zfs create "$DATASET"
log_must zfs snapshot "$SNAPSHOT"
for ((index = 0; index < BOOKMARK_COUNT; index++)); do
	log_must zfs bookmark "$SNAPSHOT" "$DATASET#bookmark_$index"
done

SECONDS=0
log_must_program_sync "$TESTPOOL" - "$DATASET" "$BOOKMARK_COUNT" <<'EOF'
args = ...
argv = args["argv"]
dataset = argv[1]
expected = tonumber(argv[2])
count = 0
for bookmark in zfs.list.bookmarks(dataset) do
    assert(zfs.sync.destroy(bookmark) == 0)
    count = count + 1
end
assert(count == expected)
EOF
elapsed=$SECONDS
log_note "Channel program bookmark deletion: ${elapsed}s (${BOOKMARK_COUNT} bookmarks)"

log_pass "Deleted $BOOKMARK_COUNT bookmarks through a channel program."