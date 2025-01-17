# Copyright (C) 2019 SUSE LLC
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, see <http://www.gnu.org/licenses/>.
#
# Summary: This starts libvirt guests again
# Maintainer: Pavel Dostál <pdostal@suse.cz>

use base "consoletest";
use virt_autotest::common;
use virt_autotest::utils;
use strict;
use warnings;
use testapi;
use utils;

sub run {
    record_info "AUTOSTART ENABLE", "Enable autostart for all guests";
    foreach my $guest (keys %virt_autotest::common::guests) {
        if (script_run("virsh autostart $guest", 30) != 0) {
            record_soft_failure "Cannot enable autostart on $guest guest";
        }
    }

    record_info "LIBVIRTD", "Restart libvirtd and expect all guests to boot up";
    systemctl 'restart libvirtd';


    # Ensure all guests have network connectivity
    foreach my $guest (keys %virt_autotest::common::guests) {
        eval {
            ensure_online($guest);
        } or do {
            my $err = $@;
            record_info("$guest failure: $err");
        }
    }
}

sub test_flags {
    return {fatal => 1, milestone => 1};
}

1;

