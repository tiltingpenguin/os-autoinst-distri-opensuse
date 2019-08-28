# SUSE's openQA tests
#
# Copyright © 2019 SUSE LLC
#
# Copying and distribution of this file, with or without modification,
# are permitted in any medium without royalty provided the copyright
# notice and this notice are preserved.  This file is offered as-is,
# without any warranty.

# Summary: Run test executed by TEST-01-BASIC from upstream after openSUSE/SUSE patches.
# Maintainer: Sergio Lindo Mansilla <slindomansilla@suse.com>, Thomas Blume <tblume@suse.com>

use base 'systemd_testsuite_test';
use warnings;
use strict;
use testapi;

sub run {
    my ($self) = @_;
    $self->testsuiteinstall;

    #run binary tests
    assert_script_run 'cd /var/opt/systemd-tests';
    assert_script_run './run-tests.sh 2>&1 | tee /tmp/testsuite.log', 600;
    wait_still_screen;
    type_string "shutdown -r now\n";
    if (check_var('ARCH', 's390x')) {
        $self->wait_boot(bootloader_time => 180);
    }
    else {
        wait_serial('Welcome to SUSE Linux', 300) || die "System did not boot in 300 seconds.";
    }
    wait_still_screen 10;
    assert_screen('linux-login', 30);
    reset_consoles;
    select_console('root-console');
}

sub test_flags {
    return {fatal => 1, milestone => 1};
}


1;
