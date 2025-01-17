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
# Summary: Prepare the dom0 metrics environment
# Maintainer: Pavel Dostál <pdostal@suse.cz>

use base "consoletest";
use virt_autotest::common;
use strict;
use warnings;
use testapi;
use utils;

sub run {
    select_console 'root-console';
    opensusebasetest::select_serial_terminal();

    zypper_call '-t in vhostmd';

    foreach my $guest (keys %virt_autotest::common::guests) {
        record_info "$guest", "Install vm-dump-metrics on xl-$guest";
        script_retry "ssh root\@$guest 'zypper -n in vm-dump-metrics'", delay => 30, retry => 6;
    }
}

sub test_flags {
    return {fatal => 1, milestone => 0};
}

1;

