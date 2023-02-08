# SUSE's openQA tests
#
# Copyright 2020 SUSE LLC
# SPDX-License-Identifier: FSFAP

# Summary: Run test executed by TEST-36-NUMAPOLICY from upstream after openSUSE/SUSE patches.
# Maintainer: Sergio Lindo Mansilla <slindomansilla@suse.com>, Thomas Blume <tblume@suse.com>

use base 'systemd_testsuite_test';
use warnings;
use strict;
use testapi;

sub pre_run_hook {
    my ($self) = @_;
    #prepare test
    $self->testsuiteprepare('TEST-36-NUMAPOLICY');
}

sub run {
    #run test
    my $timeout = 1200;
    assert_script_run 'cd /usr/lib/systemd/tests/integration-tests';
    assert_script_run 'export NO_BUILD=1 && make -C TEST-36-NUMAPOLICY run 2>&1 | tee /tmp/testsuite.log', $timeout;
    assert_script_run 'grep "TEST-36-NUMAPOLICY RUN: .* \[OK\]" /tmp/testsuite.log';
    script_run 'export NO_BUILD=1 && make -C TEST-36-NUMAPOLICY clean';
}

sub test_flags {
    return {always_rollback => 1};
}


1;
