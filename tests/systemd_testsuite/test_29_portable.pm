# SUSE's openQA tests
#
# Copyright 2019 SUSE LLC
# SPDX-License-Identifier: FSFAP

# Summary: Run test executed by TEST-29-UDEV-ID_RENAMING from upstream after openSUSE/SUSE patches.
# Maintainer: Sergio Lindo Mansilla <slindomansilla@suse.com>, Thomas Blume <tblume@suse.com>

use base 'systemd_testsuite_test';
use warnings;
use strict;
use testapi;

sub run {
    my ($self) = @_;
    my $test = 'TEST-29-PORTABLE';


    #run test
    my $timeout = 300;
    assert_script_run "NO_BUILD=1 make -C test/$test clean setup run 2> /tmp/testerr.log", $timeout;
}

sub test_flags {
    return {always_rollback => 1};
}


1;
