# SUSE's openQA tests
#
# Copyright 2019-2020 SUSE LLC
# SPDX-License-Identifier: FSFAP

# Summary: Run test executed by TEST-01-BASIC from upstream after openSUSE/SUSE patches.
# Maintainer: Sergio Lindo Mansilla <slindomansilla@suse.com>, Thomas Blume <tblume@suse.com>

use base 'systemd_testsuite_test';
use warnings;
use strict;
use testapi;

sub run {
    #run test
    my $timeout = get_var('SYSTEMD_TEST_DEFAULT_TIMEOUT') || 38000;
    assert_script_run 'cd /usr/lib/systemd/tests/integration-tests';
    assert_script_run 'export NO_BUILD=1 && ./run-integration-tests.sh', $timeout;
}

sub test_flags {
    return {always_rollback => 1};
}


1;
