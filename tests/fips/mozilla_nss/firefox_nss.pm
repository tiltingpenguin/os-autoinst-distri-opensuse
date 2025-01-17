# SUSE's openQA tests - FIPS tests
#
# Copyright © 2016-2020 SUSE LLC
#
# Copying and distribution of this file, with or without modification,
# are permitted in any medium without royalty provided the copyright
# notice and this notice are preserved.  This file is offered as-is,
# without any warranty.

# Case #1560076 - FIPS: Firefox Mozilla NSS

# Summary: FIPS mozilla-nss test for firefox : firefox_nss
# Maintainer: Ben Chou <bchou@suse.com>
# Tag: poo#47018, poo#58079

use base "x11test";
use strict;
use warnings;
use testapi;

sub quit_firefox {
    send_key "alt-f4";
    if (check_screen("firefox-save-and-quit", 10)) {
        send_key "ret";
    }
}

sub run {
    my ($self) = @_;
    select_console 'root-console';

    # Define FIPS password for firefox, and it should be consisted by:
    # - at least 8 characters
    # - at least one upper case
    # - at least one non-alphabet-non-number character (like: @-.=%)
    my $fips_password = 'openqa@SUSE';

    select_console 'x11';
    x11_start_program('firefox https://html5test.opensuse.org', target_match => 'firefox-html-test', match_timeout => 360);

    # Firfox Preferences
    send_key "alt-e";
    wait_still_screen 2;
    send_key "n";
    assert_screen('firefox-preferences');

    # Search "Passwords" section
    type_string "Use a master", timeout => 2;    # Search "Passwords" section
    assert_and_click('firefox-master-password-checkbox');
    assert_screen('firefox-passwd-master_setting');

    type_string $fips_password;
    send_key "tab";
    type_string $fips_password;
    send_key "ret";
    assert_screen "firefox-password-change-succeeded";
    send_key "ret";
    wait_still_screen 3;

    send_key "ctrl-f";
    send_key "ctrl-a";
    type_string "certificates";    # Search "Certificates" section
    send_key "tab";
    wait_still_screen 2;

    send_key "alt-shift-d";        # Device Manager
    assert_screen "firefox-device-manager";

    send_key "alt-shift-f";        # Enable FIPS mode
    assert_screen "firefox-confirm-fips_enabled";
    send_key "esc";                # Quit device manager

    quit_firefox;
    assert_screen "generic-desktop";

    # "start_firefox" will be not used, since the master password is
    # required when firefox launching in FIPS mode
    x11_start_program('firefox --setDefaultBrowser https://html5test.opensuse.org', target_match => 'firefox-fips-password-inputfiled');
    type_string $fips_password;
    send_key "ret";
    assert_screen "firefox-url-loaded";

    # Firfox Preferences
    send_key "alt-e";
    wait_still_screen 2;
    send_key "n";
    assert_screen('firefox-preferences');

    type_string "certificates";    # Search "Certificates" section
    send_key "tab";
    wait_still_screen 2;
    send_key "alt-shift-d";        # Device Manager
    assert_screen "firefox-device-manager";
    assert_screen "firefox-confirm-fips_enabled";

    quit_firefox;
    assert_screen "generic-desktop";
}

1;
