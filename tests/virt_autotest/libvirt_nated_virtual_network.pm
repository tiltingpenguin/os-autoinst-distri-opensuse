# SUSE's openQA tests
#
# Copyright (C) 2019-2020 SUSE LLC
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

# Summary: NAT based virtual network test:
#    - Define NAT based virtual network
#    - Confirm NAT based virtual network
#    - Destroy NAT based virtual network
# Maintainer: Leon Guo <xguo@suse.com>

use base "virt_feature_test_base";
use virt_utils;
use set_config_as_glue;
use virt_autotest::virtual_network_utils;
use virt_autotest::utils;
use strict;
use warnings;
use testapi;
use utils;
use version_utils 'is_sle';

sub run_test {
    my ($self) = @_;

    #Download libvirt host bridge virtual network configuration file
    my $vnet_nated_cfg_name = "vnet_nated.xml";
    virt_autotest::virtual_network_utils::download_network_cfg($vnet_nated_cfg_name);

    die "The default(NAT BASED NETWORK) virtual network does not exist" if (script_run('virsh net-list --all | grep default') != 0);

    #Create NAT BASED NETWORK
    assert_script_run("virsh net-create vnet_nated.xml");
    save_screenshot;
    upload_logs "vnet_nated.xml";
    assert_script_run("rm -rf vnet_nated.xml");

    my ($mac, $model, $affecter, $exclusive);
    my $gate = '192.168.128.1';
    foreach my $guest (keys %virt_autotest::common::guests) {
        record_info "$guest", "NAT BASED NETWORK for $guest";

        if (is_sle('=11-sp4') && is_xen_host) {
            $affecter  = "--persistent";
            $exclusive = "bridge --live --persistent";
        } else {
            $affecter  = "";
            $exclusive = "network --current";
        }

        $mac   = '00:16:3e:32:' . (int(rand(89)) + 10) . ':' . (int(rand(89)) + 10);
        $model = (is_xen_host) ? 'netfront' : 'virtio';

        #Check guest loaded kernel module before attach interface to guest system
        check_guest_module("$guest", module => "acpiphp");
        assert_script_run("virsh attach-interface $guest network vnet_nated --model $model --mac $mac --live $affecter", 60);

        my $net = is_sle('=11-sp4') ? 'br123' : 'vnet_nated';
        test_network_interface($guest, mac => $mac, gate => $gate, net => $net);

        assert_script_run("virsh detach-interface $guest --mac $mac $exclusive");
    }

    #Destroy NAT BASED NETWORK
    assert_script_run("virsh net-destroy vnet_nated");
    save_screenshot;
}

sub post_fail_hook {
    my ($self) = @_;

    #Upload debug log
    virt_autotest::virtual_network_utils::upload_debug_log();

    #Restart libvirtd service
    virt_autotest::virtual_network_utils::restart_libvirtd();

    #Destroy created virtual networks
    virt_autotest::virtual_network_utils::destroy_vir_network();

    #Restore default(NATed Network)
    virt_autotest::virtual_network_utils::restore_libvirt_default();

    #Restore br123 for virt_autotest
    virt_autotest::virtual_network_utils::restore_standalone();

    #Restore Guest systems
    virt_autotest::virtual_network_utils::restore_guests();
}

1;
