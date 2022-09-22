# Copyright SUSE LLC
# SPDX-License-Identifier: GPL-2.0-or-later

# Summary: Deploy SAP Landscape using qe-sap-deployment and network peering with Trento server
# Maintainer: QE-SAP <qe-sap@suse.de>, Michele Pagot <michele.pagot@suse.com>

use strict;
use warnings;
use Mojo::Base 'publiccloud::basetest';
use testapi;
use qesapdeployment 'qesap_upload_logs';
use base 'trento';

sub run {
    my ($self) = @_;
    $self->select_serial_terminal;

    $self->deploy_qesap();

    my $trento_rg = $self->get_resource_group;
    my $cluster_rg = $self->get_qesap_resource_group();
    my $cmd = join(' ',
        '/root/test/00.050-trento_net_peering_tserver-sap_group.sh',
        '-s', $trento_rg,
        '-n', trento::get_vnet($trento_rg),
        '-t', $cluster_rg,
        '-a', trento::get_vnet($cluster_rg));
    record_info('NET PEERING');
    assert_script_run($cmd, 360);
}

sub post_fail_hook {
    my ($self) = shift;
    $self->select_serial_terminal;
    qesap_upload_logs();
    if (!get_var('TRENTO_EXT_DEPLOY_IP')) {
        trento::k8s_logs(qw(web runner));
        $self->az_delete_group;
    }
    $self->destroy_qesap();
    $self->SUPER::post_fail_hook;
}

1;
