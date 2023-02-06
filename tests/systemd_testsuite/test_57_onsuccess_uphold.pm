# SUSE's openQA tests
#
# Copyright 2020 SUSE LLC
# SPDX-License-Identifier: FSFAP

# Summary: Run test executed by TEST-57-ONSUCCESS-UPHOLD from upstream after openSUSE/SUSE patches.
# Maintainer: Sergio Lindo Mansilla <slindomansilla@suse.com>, Thomas Blume <tblume@suse.com>

use base 'systemd_testsuite_test';
use warnings;
use strict;
use testapi;

sub pre_run_hook {
    my ($self) = @_;
    #prepare test
    $self->testsuiteprepare('TEST-57-ONSUCCESS-UPHOLD');
}

sub run {
    #run test
    my $timeout = get_var('SYSTEMD_TEST_DEFAULT_TIMEOUT') || 120;
    assert_script_run 'cd /usr/lib/systemd/tests/integration-tests';
    assert_script_run './run-integration-tests.sh TEST-57-ONSUCCESS-UPHOLD --run 2>&1 | tee /tmp/testsuite.log', $timeout;
    assert_script_run 'grep "PASS: ...TEST-57-ONSUCCESS-UPHOLD" /tmp/testsuite.log';
    script_run './run-integration-tests.sh TEST-57-ONSUCCESS-UPHOLD --clean';
}

sub test_flags {
    return {always_rollback => 1};
}


1;
