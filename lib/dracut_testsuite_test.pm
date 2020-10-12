# SUSE's openQA tests
#
# Copyright © 2019 SUSE LLC
#
# Copying and distribution of this file, with or without modification,
# are permitted in any medium without royalty provided the copyright
# notice and this notice are preserved.  This file is offered as-is,
# without any warranty.

# Summary: library functions for setting up the tests and uploading logs in error case.
# Maintainer: Thomas Blume <tblume@suse.com>


package dracut_testsuite_test;
use base "opensusebasetest";

use strict;
use warnings;
use known_bugs;
use testapi;
use power_action_utils 'power_action';
use utils 'zypper_call';
use version_utils qw(is_opensuse is_sle is_tumbleweed);
use bootloader_setup qw(change_grub_config grub_mkconfig);

sub testsuiteinstall {
    my ($self) = @_;
    # The isotovideo setting QA_TESTSUITE_REPO is not mandatory.
    # QA_TESTSUITE_REPO is meant to override the default repos with a custom OBS repo to test changes on the test suite package.
    my $qa_testsuite_repo = get_var('QA_TESTSUITE_REPO', '');
    if (!$qa_testsuite_repo) {
        if (is_opensuse()) {
            my $sub_project;
            if (is_tumbleweed()) {
                $sub_project = 'Tumbleweed/openSUSE_Tumbleweed/';
            }
            else {
                (my $version, my $service_pack) = split('\.', get_required_var('VERSION'));
                $sub_project = "Leap:/$version/openSUSE_Leap_$version.$service_pack/";
            }
            $qa_testsuite_repo = 'https://download.opensuse.org/repositories/devel:/openSUSE:/QA:/' . $sub_project;
        }
        else {
            my $version_with_service_pack = get_required_var('VERSION');
            $qa_testsuite_repo = "http://download.suse.de/ibs/QA:/Head/SLE-$version_with_service_pack/";
        }
        die '$qa_testsuite_repo is not set' unless ($qa_testsuite_repo);
    }

    select_console 'root-console';

    if (is_sle('15+') && !main_common::is_updates_tests) {
        # add devel tools repo for SLE15 to install strace
        my $devel_repo = get_required_var('REPO_SLE_MODULE_DEVELOPMENT_TOOLS');
        zypper_call "ar -c $utils::OPENQA_FTP_URL/" . $devel_repo . " devel-repo";
    }

    # install systemd testsuite
    zypper_call "ar $qa_testsuite_repo dracut-testrepo";
    zypper_call '--gpg-auto-import-keys ref';
    # use systemd from the repo of the qa package
    if (get_var('DRACUT_FROM_TESTREPO')) {
        zypper_call 'in --from dracut-testrepo dracut';
        change_grub_config('=.*', '=9', 'GRUB_TIMEOUT');
        grub_mkconfig;
        wait_screen_change { type_string "shutdown -r now\n" };
        if (check_var('ARCH', 's390x')) {
            $self->wait_boot(bootloader_time => 180);
        } else {
            $self->handle_uefi_boot_disk_workaround if (check_var('ARCH', 'aarch64'));
            wait_still_screen 10;
            send_key 'ret';
            wait_serial('Welcome to', 300) || die "System did not boot in 300 seconds.";
        }
        assert_screen('linux-login', 30);
        reset_consoles;
        select_console('root-console');
    }
    zypper_call 'in dracut-qa-testsuite';
}

sub testsuiteprepare {
    my ($self, $testname, $option) = @_;
    #cleanup and prepare next test
    assert_script_run "rm -rf /var/tmp/dracut-test*";
    assert_script_run "clear";
    assert_script_run "cd /usr/lib/dracut/tests";
    assert_script_run "./run-tests.sh $testname --setup 2>&1 | tee /tmp/testsuite.log", 300;

    script_run "clear";
}

sub post_fail_hook {
    my ($self) = @_;
    #upload logs from given testname
    $self->tar_and_upload_log('/usr/lib/dracut/tests/logs',       '/tmp/dracut_testsuite-logs.tar.bz2');
}


1;
