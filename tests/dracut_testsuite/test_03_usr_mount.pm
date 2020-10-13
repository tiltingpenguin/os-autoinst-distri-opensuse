# SUSE's openQA tests
#
# Copyright © 2019-2020 SUSE LLC
#
# Copying and distribution of this file, with or without modification,
# are permitted in any medium without royalty provided the copyright
# notice and this notice are preserved.  This file is offered as-is,
# without any warranty.

# Summary: Run test executed by TEST-03-USR-MOUNT from upstream after openSUSE/SUSE patches.
# Maintainer: Sergio Lindo Mansilla <slindomansilla@suse.com>, Thomas Blume <tblume@suse.com>

use base 'dracut_testsuite_test';
use warnings;
use strict;
use testapi;

sub pre_run_hook {
    my ($self) = @_;
    #prepare test
    $self->testsuiteprepare('TEST-03-USR-MOUNT');
}

sub run {
    #run test
    my $timeout = get_var('DRACUT_TEST_DEFAULT_TIMEOUT') || 120;
    assert_script_run 'cd /usr/lib/dracut/tests';
    assert_script_run './run-tests.sh TEST-03-USR-MOUNT --run 2>&1 | tee /tmp/testsuite.log', $timeout;
    assert_script_run 'grep "PASS: ...TEST-03-USR-MOUNT" /tmp/testsuite.log';
}

sub test_flags {
    return {always_rollback => 1};
}


1;
