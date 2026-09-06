#!/bin/ksh -p
# SPDX-License-Identifier: CDDL-1.0
#
# This file and the contents of this file are supplied under the terms of
# the Common Development and Distribution License (the "License"). You may
# not use this file except in compliance with the License.
#
# You can obtain a copy of the License at
# http://opensource.org/licenses/CDDL-1.0. See the License for the
# specific language governing permissions and limitations under the License.
#

. $STF_SUITE/include/libtest.shlib
. $STF_SUITE/tests/functional/cli_root/zfs_destroy/zfs_destroy.cfg

verify_runnable "both"

typeset ds1=$TESTPOOL/destroy_multi_arg_1
typeset ds2=$TESTPOOL/destroy_multi_arg_2

function cleanup
{
	datasetexists $ds1 && destroy_dataset $ds1
	datasetexists $ds2 && destroy_dataset $ds2
}

log_assert "Verify 'zfs destroy' destroys multiple command-line arguments."
log_onexit cleanup

log_must zfs create $ds1
log_must zfs create $ds2
log_must zfs destroy $ds1 $ds2

datasetexists $ds1 && log_fail "$ds1 was not destroyed"
datasetexists $ds2 && log_fail "$ds2 was not destroyed"

log_pass "'zfs destroy' destroys multiple command-line arguments."