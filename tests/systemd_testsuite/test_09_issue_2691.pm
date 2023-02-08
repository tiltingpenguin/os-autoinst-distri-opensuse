# SUSE's openQA tests
#
# Copyright 2019-2020 SUSE LLC
# SPDX-License-Identifier: FSFAP

# Summary: Run test executed by TEST-09-ISSUE-2691 from upstream after openSUSE/SUSE patches.
# Maintainer: Sergio Lindo Mansilla <slindomansilla@suse.com>, Thomas Blume <tblume@suse.com>

use base 'systemd_testsuite_test';
use warnings;
use strict;
use testapi;
use power_action_utils 'power_action';

sub pre_run_hook {
    my ($self) = @_;
    #prepare test
    $self->testsuiteprepare('TEST-09-ISSUE-2691', 'needreboot');
}

sub run {
    #run test
    my $timeout = 300;
    assert_script_run 'cd /usr/lib/systemd/tests/integration-tests';
    assert_script_run 'export NO_BUILD=1 && make -C TEST-09-ISSUE-2691 run 2>&1 | tee /tmp/testsuite.log', $timeout;
    assert_script_run 'grep "TEST-09-ISSUE-2691 RUN: .* \[OK\]" /tmp/testsuite.log';
}

sub test_flags {
    return {always_rollback => 1};
}


1;
