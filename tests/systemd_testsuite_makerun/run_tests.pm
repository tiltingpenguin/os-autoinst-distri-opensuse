# SUSE's openQA tests
#
# Copyright © 2020 SUSE LLC
#
# Copying and distribution of this file, with or without modification,
# are permitted in any medium without royalty provided the copyright
# notice and this notice are preserved.  This file is offered as-is,
# without any warranty.

# Summary: Prepare systemd and testsuite.
# Maintainer: Sergio Lindo Mansilla <slindomansilla@suse.com>, Thomas Blume <tblume@suse.com>

use base 'systemd_testsuite_test';
use warnings;
use strict;
use testapi;

sub run {
    my ($self) = @_;
    my $timeout = 7200;
    $self->testsuiteinstall;
    $self->testsuiteprepare;

    assert_script_run "export NO_BUILD=1";
    assert_script_run 'cd /usr/lib/systemd/tests';
    assert_script_run 'test/run-integration-tests.sh', $timeout;
}

sub test_flags {
    return {fatal => 1, milestone => 1};
}

1;
