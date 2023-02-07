# SUSE's openQA tests
#
# Copyright 2020 SUSE LLC
# SPDX-License-Identifier: FSFAP

# Summary: Prepare systemd and testsuite.
# Maintainer: Sergio Lindo Mansilla <slindomansilla@suse.com>, Thomas Blume <tblume@suse.com>

use Mojo::Base qw(systemd_testsuite_test);
use testapi;
use serial_terminal 'select_serial_terminal';
use utils;
use version_utils qw(is_sle);
use registration qw(add_suseconnect_product);
use base 'systemd_testsuite_test';

sub run {
    my ($self) = @_;
    my $test_opts = {
        NO_BUILD => get_var('SYSTEMD_NO_BUILD', 1),
        TEST_PREFER_NSPAWN => get_var('SYSTEMD_NSPAWN', 1),
        UNIFIED_CGROUP_HIERARCHY => get_var('SYSTEMD_UNIFIED_CGROUP', 'yes')
    };
    my $testdir = '/usr/lib/systemd/tests/integration-tests/';
    my @pkgs = qw(
      lz4
      busybox
      qemu
      dhcp-client
      python3
      plymouth
      binutils
      netcat-openbsd
      cryptsetup
      less
      device-mapper
      strace
      e2fsprogs
      hostname
      net-tools-deprecated
    );

    select_serial_terminal();

    if (is_sle) {
        add_suseconnect_product('sle-module-legacy');
        add_suseconnect_product('sle-module-desktop-applications');
        add_suseconnect_product('sle-module-development-tools');
        my $repo = sprintf('http://download.suse.de/download/ibs/SUSE:/SLE-%s:/GA/standard/',
            get_var('VERSION'));
        zypper_call("ar $repo systemd-tests");
    }

    #prepare test
    $self->testsuiteinstall;
    $self->testsuiteprepare;
}


sub test_flags {
    return {milestone => 1, fatal => 1};
}

1;
