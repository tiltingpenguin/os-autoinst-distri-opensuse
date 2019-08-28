# SUSE's openQA tests
#
# Copyright © 2019 SUSE LLC
#
# Copying and distribution of this file, with or without modification,
# are permitted in any medium without royalty provided the copyright
# notice and this notice are preserved.  This file is offered as-is,
# without any warranty.

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
    $self->testsuiteprepare('TEST-09-ISSUE-2691');
}

sub run {
    my ($self) = @_;
    #start testsuite to evaluate testsuite stop at shutdown
    type_string 'systemctl start testsuite.service';
    send_key 'ret';
    type_string 'systemctl status testsuite.service';
    send_key 'ret';
    #remove debug logging
    script_run 'sed -i "/GRUB_CMDLINE_LINUX_DEFAULT.*/s/systemd.log_level=debug systemd.journald.forward_to_kmsg log_buf_len=1M printk.devkmsg=on enforcing=0//" /etc/default/grub';
    assert_script_run 'grub2-mkconfig -o /boot/grub2/grub.cfg';
    #this test run needs a reboot
    power_action('reboot', keepconsole => 1, textmode => 1);
    if (check_var('ARCH', 's390x')) {
        $self->wait_boot(in_grub => 1, bootloader_time => 180);
    }
    else {
        wait_still_screen 20;
        #login
        send_key_until_needlematch('text-login', 'ret', 360, 5);
        type_string "root\n";
        assert_screen("password-prompt");
        type_password;
        send_key('ret');
    }
    assert_screen "text-logged-in-root";
    assert_script_run 'cd /var/opt/systemd-tests';
    assert_script_run 'ls -l /shutdown-log.txt';
    assert_script_run './run-tests.sh TEST-09-ISSUE-2691 --run 2>&1 | tee /tmp/testsuite.log', 60;
    assert_screen("systemd-testsuite-test-09-issue-2691");
}

sub test_flags {
    return {always_rollback => 1};
}


1;
