L.ui.view.extend({

        RS485GetUCISections: L.rpc.declare({
                object: 'uci',
                method: 'get',
                params: ['config', 'type'],
                expect: { values: {} }
        }),

        RS485CreateUCISection: L.rpc.declare({
                object: 'uci',
                method: 'add',
                params: ['config', 'type', 'name', 'values']
        }),

        RS485CommitUCISection: L.rpc.declare({
                object: 'uci',
                method: 'commit',
                params: ['config']
        }),

        RS485DeleteUCISection: L.rpc.declare({
                object: 'uci',
                method: 'delete',
                params: ['config', 'type', 'section']
        }),

        /////////////////////////// Tunnels /////////////////////////

        updategreconfig: L.rpc.declare({
                object: 'rpc-updateGREConfig',
                method: 'configuregre',
                expect: { output: '' }
        }),

        deletegreconfig: L.rpc.declare({
                object: 'rpc-updateGREConfig',
                method: 'delete',
                expect: { output: '' }
        }),


        updateipipconfig: L.rpc.declare({
                object: 'rpc-updateIPIPConfig',
                method: 'configureipip',
                expect: { output: '' }
        }),

        deleteipipconfig: L.rpc.declare({
                object: 'rpc-updateIPIPConfig',
                method: 'delete',
                expect: { output: '' }
        }),

        /////////////////////////// Tunnels /////////////////////////

        updatefirewallconfig: L.rpc.declare({
                object: 'rpc-updateVPNConfig',
                method: 'configure',
                expect: { output: '' }
        }),
        updatewireguard: L.rpc.declare({
                object: 'rpc-updateVPNConfig',
                method: 'wireguard',
                expect: { output: '' }
        }),
        updatezerotier: L.rpc.declare({
                object: 'rpc-updateVPNConfig',
                method: 'zerotier',
                expect: { output: '' }
        }),
        updatepptpd: L.rpc.declare({
                object: 'rpc-updateVPNConfig',
                method: 'pptp',
                expect: { output: '' }
        }),
        updatexl2tpd: L.rpc.declare({
                object: 'rpc-updateVPNConfig',
                method: 'xl2tpd',
                expect: { output: '' }
        }),
        deletewireguardconfig: L.rpc.declare({
                object: 'rpc-updateVPNConfig',
                params: ['wireguardConfigSectionName', 'Name'],
                method: 'wireguarddelete',
                expect: { output: '' }
        }),
        updateopenvpnconfig: L.rpc.declare({
                object: 'rpc-updateVPNConfig',
                method: 'enableopenvpn',
                expect: { output: '' }
        }),

        deletecertficates: L.rpc.declare({
                object: 'rpc-updateVPNConfig',
                method: 'delete',
                params: ['openvpnConfigSectionName', 'Name'],
                expect: { output: '' }
        }),

        checkcertficates: L.rpc.declare({
                object: 'rpc-updateVPNConfig',
                method: 'countcertfiles',
                params: ['info1', 'Name'],
                expect: { output: '' }
        }),

        generatecertficates: L.rpc.declare({
                object: 'rpc-updateVPNConfig',
                method: 'genearatefiles',
                //params: ['info2','Name'],
                expect: { output: '' }
        }),

        startopenvpnservice: L.rpc.declare({
                object: 'rpc-updateVPNConfig',
                method: 'startopenvpn',
                expect: { output: '' }
        }),

        stopopenvpnservice: L.rpc.declare({
                object: 'rpc-updateVPNConfig',
                method: 'stopopenvpn',
                expect: { output: '' }
        }),
        TestArchive: L.rpc.declare({
                object: 'rpc-updateVPNConfig',
                method: 'testarchive',
                params: ['archive', 'info1'],
        }),

        Openvpncertificatecheck: function (ev) {
                var self = this;
                var self = ev.data.self;
                var openvpnConfigSectionName = ev.data.openvpnConfigSectionName;
                var info1 = openvpnConfigSectionName
                self.checkcertficates(info1).then(function (rv) {

                        if (typeof rv === "string" && rv.length === 0) {

                                self.OpenvpnUpload(info1);
                        }

                        else {
                                L.ui.showAlert(
                                        'error',
                                        'Upload Error',
                                        'To upload a new .ovpn file, first delete the existing one, then click "Add Interface".'
                                );
                        }
                });
        },

        wireguardcertificate: function (ev) {
                var self = this;
                var self = ev.data.self;
                var wireguardConfigSectionName = ev.data.wireguardConfigSectionName;
                var info2 = wireguardConfigSectionName


                self.generatecertficates().then(function (rv) {

                        L.ui.showAlert(
                                'success',
                                'Key Generated',
                                'WireGuard public key generated successfully.'
                        );


                        setTimeout(function () {
                                location.reload(true);
                        }, 1500)


                });


        },

        OpenvpnUpload: function (info1) {
                var self = this;

                L.ui.archiveUploadcerts(

                        L.tr('Archive Upload'),
                        L.tr('Select the archive and click on "%s" button to proceed.').format(L.tr('Apply')), {

                        success: function (info) {
                                self.OpenvpnArchiveVerify(info1);
                        }
                }
                );
        },
        OpenvpnArchiveVerify: function (info1) {
                var self = this;
                var archive = $('[name=filename]').val();

                L.ui.loading(true);
                self.TestArchive(archive, info1).then(function (TestArchiveOutput) {
                        L.ui.dialog(false)
                        L.ui.showAlert(
                                'success',
                                'Certificate Upload',
                                'OpenVPN Certificate uploaded successfully'
                        );


                        // L.ui.dialog(
                        //         L.tr('TestArchive'), [
                        //         $('<p />').text(L.tr('Certificate Upload')),
                        //         $('<pre />')
                        //                 .addClass('alert success')
                        //                 .text("Certificate uploaded successfully")
                        // ], {
                        //         style: 'close',

                        // }
                        // );
                        L.ui.loading(false);
                });
        },

        RS485FormCallback: function () {
                var map = this;
                var RS485ConfigSectionName = map.options.RS485ConfigSection;
                var numericExpression = /^[0-9]+$/;

                map.options.caption = L.tr('IPSEC Configuration → %s').format(RS485ConfigSectionName);


                var s = map.section(L.cbi.NamedSection, RS485ConfigSectionName, {
                        collabsible: true,
                        caption: L.tr(map.options.caption)
                });

                s.option(L.cbi.SubHeadingValue, 'typesettings', {
                        caption: L.tr(''),
                        //  caption: L.tr(a),
                }).depends({ 'ipsecconfig': '1', 'enableipsec': '1' })
                        .ucivalue = function () {
                                return 'IPSEC Type Settings';
                        };

                s.option(L.cbi.ListValue, 'ipsectype', {
                        caption: L.tr('IPSEC'),
                }).depends({ 'ipsecconfig': '1', 'enableipsec': '1' })
                        .value("none", L.tr('Please choose'))
                        .value("sitetositevpn", L.tr('Site to Site VPN'));
                //.value("clienttositevpn", L.tr('Client to site VPN'));    

                s.option(L.cbi.ListValue, 'ipsecrole', {
                        caption: L.tr('IPSEC Role'),
                }).depends({ 'ipsecconfig': '1', 'enableipsec': '1' })
                        .value("none", L.tr('Please choose'))
                        .value("client", L.tr('Client'))
                        .value("server", L.tr('Server'));


                /*=========================================================================================================
            *  Connection Settings
            *  ====================================================================================================  */

                s.option(L.cbi.SubHeadingValue, 'connectionsettings', {
                        caption: L.tr(''),
                        //  caption: L.tr(a),
                }).depends({ 'ipsecconfig': '1', 'enableipsec': '1' })
                        .ucivalue = function () {
                                return 'IPSEC Connection Settings';
                        };

                /*  s.option(L.cbi.InputValue, 'connectionname', {
                    caption: L.tr('Connection Name'),
                 }).depends({'ipsecconfig':'1','enableipsec' : '1'});*/


                s.option(L.cbi.CheckboxValue, 'connectionenable', {
                        caption: L.tr('Connection Enable'),
                        optional: true
                }).depends({ 'ipsecconfig': '1', 'enableipsec': '1' });

                s.option(L.cbi.ListValue, 'connectionprotocol', {
                        caption: L.tr('Connection Protocol'),
                }).depends({ 'ipsecconfig': '1', 'enableipsec': '1' })
                        //.value("none", L.tr('Please choose'))
                        .value("esp", L.tr('ESP'))
                        .value("ah", L.tr('AH'));

                s.option(L.cbi.ListValue, 'connectiontype', {
                        caption: L.tr('Connection type'),
                }).depends({ 'ipsecconfig': '1', 'enableipsec': '1' })
                        //.value("none", L.tr('Please choose'))
                        .value("tunnel", L.tr('Tunnel'))
                        .value("transport", L.tr('Transport'));

                s.option(L.cbi.CheckboxValue, 'splitTunnel', {
                        caption: L.tr('Enable Split Tunnel'),
                        optional: true
                }).depends({ 'ipsecconfig': '1', 'enableipsec': '1' });

                s.option(L.cbi.CheckboxValue, 'lanWifiConnectivity', {
                        caption: L.tr('Bypass Local Network'),
                        optional: true
                }).depends({ 'ipsecconfig': '1', 'enableipsec': '1', 'splitTunnel': '0' });

                s.option(L.cbi.ListValue, 'nooflocalsubnettobypass', {
                        caption: L.tr('Number Of Local Subnet To Bypass'),
                }).depends({ 'ipsecconfig': '1', 'enableipsec': '1', 'splitTunnel': '0', 'lanWifiConnectivity': '1' })
                        .value("none", L.tr('Please choose'))
                        .value("1", L.tr('1'))
                        .value("2", L.tr('2'))
                        .value("3", L.tr('3'))
                        .value("4", L.tr('4'))
                        .value("5", L.tr('5'));

                s.option(L.cbi.InputValue, 'localsubnetip1', {
                        caption: L.tr('Bypass Subnet IP 1'),
                        datatype: 'cidr4',
                }).depends({ 'ipsecconfig': '1', 'enableipsec': '1', 'splitTunnel': '0', 'nooflocalsubnettobypass': '1' })
                        .depends({ 'ipsecconfig': '1', 'enableipsec': '1', 'splitTunnel': '0', 'nooflocalsubnettobypass': '2' })
                        .depends({ 'ipsecconfig': '1', 'enableipsec': '1', 'splitTunnel': '0', 'nooflocalsubnettobypass': '3' })
                        .depends({ 'ipsecconfig': '1', 'enableipsec': '1', 'splitTunnel': '0', 'nooflocalsubnettobypass': '4' })
                        .depends({ 'ipsecconfig': '1', 'enableipsec': '1', 'splitTunnel': '0', 'nooflocalsubnettobypass': '5' });

                s.option(L.cbi.InputValue, 'localsubnetip2', {
                        caption: L.tr('Bypass Subnet IP 2'),
                        datatype: 'cidr4',
                }).depends({ 'ipsecconfig': '1', 'enableipsec': '1', 'splitTunnel': '0', 'nooflocalsubnettobypass': '2' })
                        .depends({ 'ipsecconfig': '1', 'enableipsec': '1', 'splitTunnel': '0', 'nooflocalsubnettobypass': '3' })
                        .depends({ 'ipsecconfig': '1', 'enableipsec': '1', 'splitTunnel': '0', 'nooflocalsubnettobypass': '4' })
                        .depends({ 'ipsecconfig': '1', 'enableipsec': '1', 'splitTunnel': '0', 'nooflocalsubnettobypass': '5' });

                s.option(L.cbi.InputValue, 'localsubnetip3', {
                        caption: L.tr('Bypass Subnet IP 3'),
                        datatype: 'cidr4',
                }).depends({ 'ipsecconfig': '1', 'enableipsec': '1', 'splitTunnel': '0', 'nooflocalsubnettobypass': '3' })
                        .depends({ 'ipsecconfig': '1', 'enableipsec': '1', 'splitTunnel': '0', 'nooflocalsubnettobypass': '4' })
                        .depends({ 'ipsecconfig': '1', 'enableipsec': '1', 'splitTunnel': '0', 'nooflocalsubnettobypass': '5' });

                s.option(L.cbi.InputValue, 'localsubnetip4', {
                        caption: L.tr('Bypass Subnet IP 4'),
                        datatype: 'cidr4',
                }).depends({ 'ipsecconfig': '1', 'enableipsec': '1', 'splitTunnel': '0', 'nooflocalsubnettobypass': '4' })
                        .depends({ 'ipsecconfig': '1', 'enableipsec': '1', 'splitTunnel': '0', 'nooflocalsubnettobypass': '5' });

                s.option(L.cbi.InputValue, 'localsubnetip5', {
                        caption: L.tr('Bypass Subnet IP 5'),
                        datatype: 'cidr4',
                }).depends({ 'ipsecconfig': '1', 'enableipsec': '1', 'splitTunnel': '0', 'nooflocalsubnettobypass': '5' });



                s.option(L.cbi.ListValue, 'connectionmode', {
                        caption: L.tr('Connection Policy'),
                }).depends({ 'ipsecconfig': '1', 'enableipsec': '1' })
                        .value("none", L.tr('Please choose'))
                        .value("route", L.tr('route'))
                        .value("add", L.tr('add'))
                        .value("start", L.tr('start'))
                        .value("trap", L.tr('trap'));

                s.option(L.cbi.InputValue, 'remoteserverIP', {
                        caption: L.tr('Remote Server IP/Domain'),
                        option: true,
                }).depends({ 'ipsecconfig': '1', 'enableipsec': '1', 'ipsecrole': 'client' });

                s.option(L.cbi.InputValue, 'remoteIP', {
                        caption: L.tr('Remote IP/Domain'),
                        option: true,
                }).depends({ 'ipsecconfig': '1', 'enableipsec': '1', 'ipsecrole': 'server' });

                s.option(L.cbi.InputValue, 'localid', {
                        caption: L.tr('Local ID'),
                        optional: true
                }).depends({ 'ipsecconfig': '1', 'enableipsec': '1' });

                s.option(L.cbi.ListValue, 'nooflocalsubnets', {
                        caption: L.tr('No. of local subnets'),
                }).depends({ 'ipsecconfig': '1', 'enableipsec': '1', 'connectiontype': 'tunnel' })
                        .value("none", L.tr('Please choose'))
                        .value("1", L.tr('1'))
                        .value("2", L.tr('2'));

                s.option(L.cbi.InputValue, 'localsubnet1', {
                        caption: L.tr('Local Subnet 1'),
                        placeholder: '8.8.8.8/24 ',
                        datatype: 'cidr4',
                }).depends({ 'ipsecconfig': '1', 'enableipsec': '1', 'nooflocalsubnets': '1', 'connectiontype': 'tunnel' })
                        .depends({ 'ipsecconfig': '1', 'enableipsec': '1', 'nooflocalsubnets': '2', 'connectiontype': 'tunnel' });

                s.option(L.cbi.InputValue, 'localsubnet2', {
                        caption: L.tr('Local Subnet 2'),
                        placeholder: '8.8.8.8/24 ',
                        datatype: 'cidr4',
                }).depends({ 'ipsecconfig': '1', 'enableipsec': '1', 'nooflocalsubnets': '2', 'connectiontype': 'tunnel' });


                s.option(L.cbi.InputValue, 'remoteid', {
                        caption: L.tr('Remote ID'),
                        optional: true

                })
                        .depends({ 'ipsecconfig': '1', 'enableipsec': '1' });

                s.option(L.cbi.ListValue, 'noofremotesubnets', {
                        caption: L.tr('No. of remote subnets'),
                }).depends({ 'ipsecconfig': '1', 'enableipsec': '1', 'splitTunnel': '1', 'connectiontype': 'tunnel' })
                        .value("none", L.tr('Please choose'))
                        .value("1", L.tr('1'))
                        .value("2", L.tr('2'))
                        .value("3", L.tr('3'))
                        .value("4", L.tr('4'))
                        .value("5", L.tr('5'))
                        .value("6", L.tr('6'))
                        .value("7", L.tr('7'))
                        .value("8", L.tr('8'));

                s.option(L.cbi.InputValue, 'remotesubnet1', {
                        caption: L.tr('Remote Subnet 1'),
                        placeholder: '8.8.8.8/24 ',
                        datatype: 'cidr4withexception',
                }).depends({ 'ipsecconfig': '1', 'enableipsec': '1', 'noofremotesubnets': '1', 'splitTunnel': '1', 'connectiontype': 'tunnel' })
                        .depends({ 'ipsecconfig': '1', 'enableipsec': '1', 'noofremotesubnets': '2', 'splitTunnel': '1', 'connectiontype': 'tunnel' })
                        .depends({ 'ipsecconfig': '1', 'enableipsec': '1', 'noofremotesubnets': '3', 'splitTunnel': '1', 'connectiontype': 'tunnel' })
                        .depends({ 'ipsecconfig': '1', 'enableipsec': '1', 'noofremotesubnets': '4', 'splitTunnel': '1', 'connectiontype': 'tunnel' })
                        .depends({ 'ipsecconfig': '1', 'enableipsec': '1', 'noofremotesubnets': '5', 'splitTunnel': '1', 'connectiontype': 'tunnel' })
                        .depends({ 'ipsecconfig': '1', 'enableipsec': '1', 'noofremotesubnets': '6', 'splitTunnel': '1', 'connectiontype': 'tunnel' })
                        .depends({ 'ipsecconfig': '1', 'enableipsec': '1', 'noofremotesubnets': '7', 'splitTunnel': '1', 'connectiontype': 'tunnel' })
                        .depends({ 'ipsecconfig': '1', 'enableipsec': '1', 'noofremotesubnets': '8', 'splitTunnel': '1', 'connectiontype': 'tunnel' });

                s.option(L.cbi.InputValue, 'remotesubnet2', {
                        caption: L.tr('Remote Subnet 2'),
                        placeholder: '8.8.8.8/24 ',
                        datatype: 'cidr4withexception',
                }).depends({ 'ipsecconfig': '1', 'enableipsec': '1', 'noofremotesubnets': '2', 'splitTunnel': '1', 'connectiontype': 'tunnel' })
                        .depends({ 'ipsecconfig': '1', 'enableipsec': '1', 'noofremotesubnets': '3', 'splitTunnel': '1', 'connectiontype': 'tunnel' })
                        .depends({ 'ipsecconfig': '1', 'enableipsec': '1', 'noofremotesubnets': '4', 'splitTunnel': '1', 'connectiontype': 'tunnel' })
                        .depends({ 'ipsecconfig': '1', 'enableipsec': '1', 'noofremotesubnets': '5', 'splitTunnel': '1', 'connectiontype': 'tunnel' })
                        .depends({ 'ipsecconfig': '1', 'enableipsec': '1', 'noofremotesubnets': '6', 'splitTunnel': '1', 'connectiontype': 'tunnel' })
                        .depends({ 'ipsecconfig': '1', 'enableipsec': '1', 'noofremotesubnets': '7', 'splitTunnel': '1', 'connectiontype': 'tunnel' })
                        .depends({ 'ipsecconfig': '1', 'enableipsec': '1', 'noofremotesubnets': '8', 'splitTunnel': '1', 'connectiontype': 'tunnel' });

                s.option(L.cbi.InputValue, 'remotesubnet3', {
                        caption: L.tr('Remote Subnet 3'),
                        placeholder: '8.8.8.8/24 ',
                        datatype: 'cidr4withexception',
                }).depends({ 'ipsecconfig': '1', 'enableipsec': '1', 'noofremotesubnets': '3', 'splitTunnel': '1', 'connectiontype': 'tunnel' })
                        .depends({ 'ipsecconfig': '1', 'enableipsec': '1', 'noofremotesubnets': '4', 'splitTunnel': '1', 'connectiontype': 'tunnel' })
                        .depends({ 'ipsecconfig': '1', 'enableipsec': '1', 'noofremotesubnets': '5', 'splitTunnel': '1', 'connectiontype': 'tunnel' })
                        .depends({ 'ipsecconfig': '1', 'enableipsec': '1', 'noofremotesubnets': '6', 'splitTunnel': '1', 'connectiontype': 'tunnel' })
                        .depends({ 'ipsecconfig': '1', 'enableipsec': '1', 'noofremotesubnets': '7', 'splitTunnel': '1', 'connectiontype': 'tunnel' })
                        .depends({ 'ipsecconfig': '1', 'enableipsec': '1', 'noofremotesubnets': '8', 'splitTunnel': '1', 'connectiontype': 'tunnel' });

                s.option(L.cbi.InputValue, 'remotesubnet4', {
                        caption: L.tr('Remote Subnet 4'),
                        placeholder: '8.8.8.8/24 ',
                        datatype: 'cidr4withexception',
                }).depends({ 'ipsecconfig': '1', 'enableipsec': '1', 'noofremotesubnets': '4', 'splitTunnel': '1', 'connectiontype': 'tunnel' })
                        .depends({ 'ipsecconfig': '1', 'enableipsec': '1', 'noofremotesubnets': '5', 'splitTunnel': '1', 'connectiontype': 'tunnel' })
                        .depends({ 'ipsecconfig': '1', 'enableipsec': '1', 'noofremotesubnets': '6', 'splitTunnel': '1', 'connectiontype': 'tunnel' })
                        .depends({ 'ipsecconfig': '1', 'enableipsec': '1', 'noofremotesubnets': '7', 'splitTunnel': '1', 'connectiontype': 'tunnel' })
                        .depends({ 'ipsecconfig': '1', 'enableipsec': '1', 'noofremotesubnets': '8', 'splitTunnel': '1', 'connectiontype': 'tunnel' });

                s.option(L.cbi.InputValue, 'remotesubnet5', {
                        caption: L.tr('Remote Subnet 5'),
                        placeholder: '8.8.8.8/24 ',
                        datatype: 'cidr4withexception',
                }).depends({ 'ipsecconfig': '1', 'enableipsec': '1', 'noofremotesubnets': '5', 'splitTunnel': '1', 'connectiontype': 'tunnel' })
                        .depends({ 'ipsecconfig': '1', 'enableipsec': '1', 'noofremotesubnets': '6', 'splitTunnel': '1', 'connectiontype': 'tunnel' })
                        .depends({ 'ipsecconfig': '1', 'enableipsec': '1', 'noofremotesubnets': '7', 'splitTunnel': '1', 'connectiontype': 'tunnel' })
                        .depends({ 'ipsecconfig': '1', 'enableipsec': '1', 'noofremotesubnets': '8', 'splitTunnel': '1', 'connectiontype': 'tunnel' });

                s.option(L.cbi.InputValue, 'remotesubnet6', {
                        caption: L.tr('Remote Subnet 6'),
                        placeholder: '8.8.8.8/24 ',
                        datatype: 'cidr4withexception',
                }).depends({ 'ipsecconfig': '1', 'enableipsec': '1', 'noofremotesubnets': '6', 'splitTunnel': '1', 'connectiontype': 'tunnel' })
                        .depends({ 'ipsecconfig': '1', 'enableipsec': '1', 'noofremotesubnets': '7', 'splitTunnel': '1', 'connectiontype': 'tunnel' })
                        .depends({ 'ipsecconfig': '1', 'enableipsec': '1', 'noofremotesubnets': '8', 'splitTunnel': '1', 'connectiontype': 'tunnel' });

                s.option(L.cbi.InputValue, 'remotesubnet7', {
                        caption: L.tr('Remote Subnet 7'),
                        placeholder: '8.8.8.8/24 ',
                        datatype: 'cidr4withexception',
                }).depends({ 'ipsecconfig': '1', 'enableipsec': '1', 'noofremotesubnets': '7', 'splitTunnel': '1', 'connectiontype': 'tunnel' })
                        .depends({ 'ipsecconfig': '1', 'enableipsec': '1', 'noofremotesubnets': '8', 'splitTunnel': '1', 'connectiontype': 'tunnel' });

                s.option(L.cbi.InputValue, 'remotesubnet8', {
                        caption: L.tr('Remote Subnet 8'),
                        placeholder: '8.8.8.8/24 ',
                        datatype: 'cidr4withexception',
                }).depends({ 'ipsecconfig': '1', 'enableipsec': '1', 'noofremotesubnets': '8', 'splitTunnel': '1', 'connectiontype': 'tunnel' });

                s.option(L.cbi.wanInterfaceList, 'interface_list', {
                        caption: L.tr('Interface List (For Load Balancing Only)'),
                        description: L.tr('Select this option only when MWAN3 is in load balancing mode.'),
                        optional: true
                }).depends({ 'ipsecconfig': '1', 'enableipsec': '1' });

                // s.option(L.cbi.InputValue, 'left_ipaddress', {
                //         caption: L.tr('SIM/EWAN5'),
                //         placeholder: '10.1.1.1',               
                //         description: L.tr('This One only work for Loadbalancing mode'),
                //         optional: true
                // }).depends({ 'ipsecconfig': '1', 'enableipsec': '1'});

                s.option(L.cbi.ListValue, 'keyexchange', {
                        caption: L.tr('Keyexchange'),
                }).depends({ 'ipsecconfig': '1', 'enableipsec': '1' })
                        .value("none", L.tr('Please choose'))
                        .value("ikev1", L.tr('ikev1'))
                        .value("ikev2", L.tr('ikev2'));

                s.option(L.cbi.ListValue, 'aggressive', {
                        caption: L.tr('Aggressive'),
                }).depends({ 'ipsecconfig': '1', 'enableipsec': '1', 'keyexchange': 'ikev1' })
                        .value("none", L.tr('Please choose'))
                        .value("yes", L.tr('YES'))
                        .value("no", L.tr("NO"));

                s.option(L.cbi.InputValue, 'ikelifetime', {
                        caption: L.tr('IKE Life Time (In Seconds)'),
                }).depends({ 'ipsecconfig': '1', 'enableipsec': '1' });


                s.option(L.cbi.InputValue, 'lifetime', {
                        caption: L.tr('Life Time (In Seconds)'),
                }).depends({ 'ipsecconfig': '1', 'enableipsec': '1' });

                s.option(L.cbi.CheckboxValue, 'dpddetectionenable', {
                        caption: L.tr('Enable DPD Detection'),
                        optional: true
                }).depends({ 'ipsecconfig': '1', 'enableipsec': '1' });

                s.option(L.cbi.InputValue, 'timeinterval', {
                        caption: L.tr('Time Interval (In Seconds)'),
                }).depends({ 'ipsecconfig': '1', 'enableipsec': '1', 'dpddetectionenable': '1' });

                /* s.option(L.cbi.InputValue, 'timeout', {
                 caption: L.tr('Time Out (In Seconds)'),
                 }).depends({'ipsecconfig':'1','enableipsec' : '1'});*/

                s.option(L.cbi.ListValue, 'action', {
                        caption: L.tr('Action'),
                }).depends({ 'ipsecconfig': '1', 'enableipsec': '1', 'dpddetectionenable': '1' })
                        .value("none", L.tr('Please choose'))
                        .value("restart", L.tr('Restart'))
                        .value("clear", L.tr('Clear'))
                        .value("hold", L.tr('Hold'));

                /*******************************************************************************************************
                * 
                * Authentication
                * 
                * ****************************************************************************************************/

                s.option(L.cbi.ListValue, 'authenticationmethod', {
                        caption: L.tr('Authentication Method'),
                }).depends({ 'ipsecconfig': '1', 'enableipsec': '1' })
                        .value("none", L.tr('Please choose'))
                        .value("psk", L.tr('PSK'));

                s.option(L.cbi.CheckboxValue, 'multiplepsk', {
                        caption: L.tr('Multiple Secrets'),
                        optional: true
                }).depends({ 'ipsecconfig': '1', 'enableipsec': '1', 'authenticationmethod': 'psk' });

                s.option(L.cbi.PasswordValue, 'pskvalue1', {
                        caption: L.tr('From remote'),
                        optional: true
                }).depends({ 'ipsecconfig': '1', 'enableipsec': '1', 'authenticationmethod': 'psk', 'multiplepsk': '1' });


                s.option(L.cbi.PasswordValue, 'pskvalue2', {
                        caption: L.tr('to remote'),
                        optional: true
                }).depends({ 'ipsecconfig': '1', 'enableipsec': '1', 'authenticationmethod': 'psk', 'multiplepsk': '1' });

                s.option(L.cbi.PasswordValue, 'pskvalue', {
                        caption: L.tr('PSK Value'),
                        optional: true
                }).depends({ 'ipsecconfig': '1', 'enableipsec': '1', 'authenticationmethod': 'psk', 'multiplepsk': '0' });

                /***************************************************************************************
                 * Proposal settings Phase I
                 * ************************************************************************************/

                // var a = '\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0' + 'Proposal Settings Phase I';
                s.option(L.cbi.SubHeadingValue, 'proposalsettingphase1', {
                        caption: L.tr(''),
                        //  caption: L.tr(a),
                }).depends({ 'ipsecconfig': '1', 'enableipsec': '1' })
                        .ucivalue = function () {
                                return 'Proposal Settings PHASE - I';
                        };

                s.option(L.cbi.ListValue, 'p1encrypalgorithm', {
                        caption: L.tr('Encryption Phase I'),
                }).depends({ 'ipsecconfig': '1', 'enableipsec': '1' })
                        // .value("none", L.tr('Please choose')) 
                        .value("none", L.tr('Please choose'))
                        .value("aes128", L.tr('AES 128'))
                        .value("aes192", L.tr('AES 192'))
                        .value("aes256", L.tr('AES 256'))
                        .value("3des", L.tr('3DES'));


                s.option(L.cbi.ListValue, 'p1authentication', {
                        caption: L.tr('Authentication Phase I'),
                }).depends({ 'ipsecconfig': '1', 'enableipsec': '1' })
                        // .value("none", L.tr('Please choose')) 
                        .value("none", L.tr('Please choose'))
                        .value("sha1", L.tr('SHA1'))
                        .value("md5", L.tr('MD5'))
                        .value("sha256", L.tr('SHA 256'))
                        .value("sha384", L.tr('SHA 384'))
                        .value("sha512", L.tr('SHA 512'));

                s.option(L.cbi.ListValue, 'p1dhgroup', {
                        caption: L.tr('DH Group'),
                }).depends({ 'ipsecconfig': '1', 'enableipsec': '1' })
                        .value("none", L.tr('Please choose'))
                        .value("modp768", L.tr('MODP768(group1)'))
                        .value("modp1024", L.tr('MODP1024(group2)'))
                        .value("modp1536", L.tr('MODP1536(group5)'))
                        .value("modp2048", L.tr('MODP2048(group14)'))
                        .value("modp3072", L.tr('MODP3072(group15)'))
                        .value("modp4096", L.tr('MODP4096(group16)'));


                /***************************************************************************************
                * Proposal settings Phase II
                * ************************************************************************************/
                s.option(L.cbi.SubHeadingValue, 'proposalsettingphase2', {
                        caption: L.tr(''),
                }).depends({ 'ipsecconfig': '1', 'enableipsec': '1' })
                        .ucivalue = function () {
                                return 'Proposal Settings PHASE - II';
                        };

                s.option(L.cbi.ListValue, 'p2encrypalgorithm', {
                        caption: L.tr('Encryption Phase II'),
                }).depends({ 'ipsecconfig': '1', 'enableipsec': '1', 'connectionprotocol': 'esp' })
                        // .value("none", L.tr('Please choose')) 
                        .value("none", L.tr('Please choose'))
                        .value("aes128", L.tr('AES 128'))
                        .value("aes192", L.tr('AES 192'))
                        .value("aes256", L.tr('AES 256'))
                        .value("3des", L.tr('3DES'));


                s.option(L.cbi.ListValue, 'p2authentication', {
                        caption: L.tr('Authentication Phase II'),
                }).depends({ 'ipsecconfig': '1', 'enableipsec': '1' })
                        // .value("none", L.tr('Please choose')) 
                        .value("none", L.tr('Please choose'))
                        .value("sha1", L.tr('SHA1'))
                        .value("md5", L.tr('MD5'))
                        .value("sha256", L.tr('SHA 256'))
                        .value("sha384", L.tr('SHA 384'))
                        .value("sha512", L.tr('SHA 512'));

                s.option(L.cbi.ListValue, 'p2pfs', {
                        caption: L.tr('PFS Group'),
                }).depends({ 'ipsecconfig': '1', 'enableipsec': '1' })
                        .value("none", L.tr('Please choose'))
                        .value("modp768", L.tr('MODP768(group1)'))
                        .value("modp1024", L.tr('MODP1024(group2)'))
                        .value("modp1536", L.tr('MODP1536(group5)'))
                        .value("modp2048", L.tr('MODP2048(group14)'))
                        .value("modp3072", L.tr('MODP3072(group15)'))
                        .value("modp4096", L.tr('MODP4096(group16)'))
                        .value("close", L.tr('close'));
        },

        RS485ConfigCreateForm: function (mapwidget, RS485ConfigSectionName) {
                var self = this;

                if (!mapwidget)
                        mapwidget = L.cbi.Map;

                var map = new mapwidget('vpnconfig1', {
                        prepare: self.RS485FormCallback,
                        RS485ConfigSection: RS485ConfigSectionName
                });
                return map;
        },
        openvpnConfigCreateForm: function (mapwidget, openvpnConfigSectionName) {
                var self = this;

                if (!mapwidget)
                        mapwidget = L.cbi.Map;

                var map = new mapwidget('openvpn', {
                        prepare: self.openvpnFormCallback,
                        openvpnConfigSection: openvpnConfigSectionName
                });
                return map;
        },
        wireguardConfigCreateForm: function (mapwidget, wireguardConfigSectionName) {
                var self = this;

                if (!mapwidget)
                        mapwidget = L.cbi.Map;

                var map = new mapwidget('wireguard', {
                        prepare: self.wireguardFormCallback,
                        wireguardConfigSection: wireguardConfigSectionName
                });
                return map;
        },
        zerotierConfigCreateForm: function (mapwidget, zerotierConfigSectionName) {
                var self = this;

                if (!mapwidget)
                        mapwidget = L.cbi.Map;

                var map = new mapwidget('zerotier', {
                        prepare: self.zerotierFormCallback,
                        zerotierConfigSection: zerotierConfigSectionName
                });
                return map;
        },
        pptpdConfigCreateForm: function (mapwidget, pptpdConfigSectionName) {
                var self = this;

                if (!mapwidget)
                        mapwidget = L.cbi.Map;

                var map = new mapwidget('pptp_i_config', {
                        prepare: self.pptpdFormCallback,
                        pptpdConfigSection: pptpdConfigSectionName
                });
                return map;
        },
        l2tpConfigCreateForm: function (mapwidget, l2tpConfigSectionName) {
                var self = this;

                if (!mapwidget)
                        mapwidget = L.cbi.Map;

                var map = new mapwidget('L2TP', {
                        prepare: self.l2tpFormCallback,
                        l2tpConfigSection: l2tpConfigSectionName
                });
                return map;
        },

        ////////////////// Tunnels ///////////////////////////////

        GreConfigCreateForm: function (mapwidget, GreConfigSectionName) {
                var self = this;

                if (!mapwidget)
                        mapwidget = L.cbi.Map;

                var map = new mapwidget('greconfig', {
                        prepare: self.GreFormCallback,
                        GreConfigSection: GreConfigSectionName
                });
                return map;
        },

        ipipConfigCreateForm: function (mapwidget, ipipConfigSectionName) {
                var self = this;

                if (!mapwidget)
                        mapwidget = L.cbi.Map;

                var map = new mapwidget('ipipconfig', {
                        prepare: self.ipipFormCallback,
                        ipipConfigSection: ipipConfigSectionName
                });
                return map;
        },

        ///////////////// Tunnels  //////////////////////////////////

        RS485RenderContents: function (rv) {
                var self = this;

                configdata2 = function () {
                        return rv;
                }

                var len = Object.keys(rv).length;
                if (len > 0) {
                        var list = new L.ui.table({
                                columns: [{
                                        caption: L.tr('Name'),
                                        width: '14%',
                                        align: 'left',
                                        format: function (v, n) {
                                                var div = $('<p />').attr('id', 'RS485DeviceEventName_%s'.format(n));
                                                return div.append('<strong>' + v + '</strong>');
                                        }
                                },
                                {
                                        caption: L.tr('Role'),
                                        width: '14%',
                                        align: 'left',
                                        format: function (v, n) {
                                                var div = $('<p />').attr('id', 'RS485DeviceEventName_%s'.format(n));
                                                return div.append(v.toUpperCase());

                                        }
                                },
                                {
                                        caption: L.tr('ProposalPhaseI'),
                                        width: '20%',
                                        align: 'left',
                                        format: function (v, n) {
                                                var div = $('<p />').attr('id', 'RS485DeviceEventName_%s'.format(n));
                                                return div.append(v);

                                        }
                                },
                                {
                                        caption: L.tr('Remote IP/Domain'),
                                        width: '20%',
                                        align: 'left',
                                        format: function (v, n) {
                                                var div = $('<p />').attr('id', 'RS485DeviceEventName_%s'.format(n));
                                                return div.append(v);
                                        }
                                },
                                {
                                        caption: L.tr('ProposalPhaseII'),
                                        width: '20%',
                                        align: 'left',
                                        format: function (v, n) {
                                                var div = $('<p />').attr('id', 'RS485DeviceEventName_%s'.format(n));
                                                return div.append(v);
                                        }
                                },
                                {
                                        caption: L.tr('KeyEx/Aggressive'),
                                        width: '14%',
                                        align: 'center',
                                        format: function (v, n) {
                                                var div = $('<p />').attr('id', 'RS485DeviceEventName_%s'.format(n));
                                                return div.append(v);
                                        }
                                },
                                {
                                        caption: L.tr('Auth'),
                                        width: '14%',
                                        align: 'center',
                                        format: function (v, n) {
                                                var div = $('<p />').attr('id', 'RS485DeviceEventName_%s'.format(n));
                                                return div.append(v);
                                        }
                                },
                                {
                                        caption: L.tr('Status'),
                                        width: '14%',
                                        align: 'center',
                                        format: function (v, n) {
                                                // alert(v);
                                                var div = $('<p />').attr('id', 'RS485DeviceEventName_%s'.format(n));
                                                return div.append(v);
                                        }
                                },
                                {
                                        caption: L.tr('Enable/Disable'),
                                        width: '14%',
                                        align: 'center',
                                        format: function (v, n) {
                                                var div = $('<label />').attr('id', 'openvpnConfig_%s'.format(n)).attr('class', 'switch');
                                                return div.append(`<input type="checkbox" ${v}   id="ipsecforwardingstatusSwitch${n}" onclick="ipsecenablebutton(${n})">
                                        <span class="slider round"></span>`);

                                        }

                                },
                                {
                                        caption: L.tr('Update'),
                                        align: 'center',
                                        format: function (v, n) {
                                                return $('<div />')
                                                        .addClass('btn-group btn-group-sm')
                                                        .append(L.ui.button(L.tr('Edit'), 'primary', L.tr('Configure'))
                                                                .click({ self: self, RS485ConfigSectionName: v }, self.RS485ConfigSectionEdit))
                                                        .append(L.ui.button(L.tr('Delete'), 'danger', L.tr('Delete Event'))
                                                                .click({ self: self, RS485ConfigSectionName: v }, self.RS485ConfigSectionRemove));
                                        }
                                }]
                        });

                        for (var key in rv) {
                                if (rv.hasOwnProperty(key)) {
                                        var obj = rv[key];
                                        //var Remote = obj.remoteserverIP || obj.remoteIP;
                                        // Assign values with fallback for undefined
                                        // Assign values with fallback for undefined
                                        var Remote = (obj.remoteserverIP !== undefined ? obj.remoteserverIP : (obj.remoteIP !== undefined ? obj.remoteIP : '---'));
                                        var Role = (obj.ipsecrole !== undefined ? obj.ipsecrole : '---');
                                        var P1 = (obj.p1encrypalgorithm !== undefined ? obj.p1encrypalgorithm : '---');
                                        var P1A = (obj.p1authentication !== undefined ? obj.p1authentication : '---');
                                        var P1B = (obj.p1dhgroup !== undefined ? obj.p1dhgroup : '---');
                                        var proto = (obj.connectionprotocol);
                                        if (proto == "ah") {
                                                var P2 = '---';
                                        }
                                        else {
                                                var P2 = (obj.p2encrypalgorithm !== undefined ? obj.p2encrypalgorithm : '---');
                                        }
                                        //var P2 = (obj.p2encrypalgorithm !== undefined ? obj.p2encrypalgorithm : '---');
                                        var P2A = (obj.p2authentication !== undefined ? obj.p2authentication : '---');
                                        var P2B = (obj.p2pfs !== undefined ? obj.p2pfs : '---');
                                        var KeyE = (obj.keyexchange !== undefined ? obj.keyexchange : '---');
                                        if (obj.keyexchange == "ikev2") {
                                                keys = '---';  // aggressive not applicable
                                        }
                                        else {
                                                keys = (obj.aggressive !== undefined ? obj.aggressive : '---');
                                        }

                                        //var keys = (obj.aggressive !== undefined ? obj.aggressive : '---');
                                        var Auth = (obj.authenticationmethod !== undefined ? obj.authenticationmethod : '---');
                                        var EstablishedCount = obj.established_count;
                                        var InstalledCount = obj.installed_count;
                                        var Enabled = obj.connectionenable;

                                        var INSC;

                                        if (EstablishedCount == InstalledCount) {

                                                INSC = `<div style="border-radius: 5px;border: 2px solid #90EE90;border-left: 5px solid green;padding: 9px;">
                                        <b>Estd:</b>${EstablishedCount}<br />
                                        <b>Inst:</b>${InstalledCount}<br />
                                      </div>`;
                                        }

                                        if (EstablishedCount > InstalledCount) {
                                                INSC = `<div style="border-radius: 5px;border: 2px solid #ffbc41;border-left: 5px solid #ffbc41;padding: 9px;">
                                        <b>Estd:</b>${EstablishedCount}<br />
                                        <b>Inst:</b>${InstalledCount}<br />
                                    </div>`;


                                        }
                                        if (EstablishedCount == undefined) {
                                                INSC = `<div style="border-radius: 5px;border: 2px solid #FF6B6B;border-left: 5px solid Red;padding: 9px;">
                                        <b>Estd:</b>-<br />
                                        <b>Inst:</b>-<br />
                                     </div>`;
                                        }
                                        if (InstalledCount == undefined) {
                                                INSC = `<div style="border-radius: 5px;border: 2px solid #FF6B6B;border-left: 5px solid Red;padding: 9px;">
                                        <b>Estd:</b>-<br />
                                        <b>Inst:</b>-<br />
                                     </div>`;
                                        }

                                        P1 = "<b>Enc Alg:</b>" + P1 + "<br />" + "<b>Auth:</b>" + P1A + "<br />" + "<b>DHGroup:</b>" + P1B;

                                        P2 = "<b>Enc Alg:</b>" + P2 + "<br />" + "<b>Auth:</b>" + P2A + "<br />" + "<b>PFSGroup:</b>" + P2B;


                                        //P3 = '<div style="text-align:center;"><span>' + KeyE + '</span>/<span>' + keys + '</span></div>';
                                        P3 = '<div style="text-align:center;"><span style="text-transform: uppercase;">' + KeyE + '</span>/<span style="text-transform: uppercase;">' + keys + '</span></div>';

                                        P4 = '<div style="text-align:center;"><span style="text-transform: uppercase;">' + Auth


                                        if (Enabled == "1") {

                                                //INSC= "<b>Inscount:</b>"+ EstablishedCount + "<br />" +"<b>Estcount:</b>"+InstalledCount+ "<br />" 
                                                Enabled = "checked"
                                        }

                                        else {
                                                INSC = `<div style="border-radius: 5px;border: 2px solid #FF6B6B;border-left: 5px solid Red;padding: 9px;">
                                        <b>Estd:</b>-<br />
                                        <b>Inst:</b>-<br />
                                        </div>`;

                                                //INSC= "<b>Inscount:</b>"+ 0 + "<br />" +"<b>Estcount:</b>"+0+ "<br />" 
                                                Enabled = ""
                                        }


                                        list.row([key, Role, P1, Remote, P2, P3, P4, INSC, Enabled, key]);
                                }
                        }
                        $('#section_vpn_ipsec').append(list.render());

                } else {
                        L.ui.showNoConfigMessage("IPSEC", "No-IPSEC-Config");
                }
        },

        openvpnFormCallback: function () {
                var map = this;
                var openvpnConfigSectionName = map.options.openvpnConfigSection;
                var rvdata = configdata();
                let authPassValue;
                for (const key in rvdata) {
                        if (rvdata.hasOwnProperty(key)) {
                                const section = rvdata[key];
                                if (section[".name"] === openvpnConfigSectionName) {
                                        this.authPassValue = section["auth_pass"];
                                        this.Role = section["role1"];
                                        this.Mode = section["mode"];
                                        this.ask_pass = section["ask_pass"];


                                }
                        }
                }




                map.options.caption = L.tr('OpenVPN Configuration Settings → %s').format(openvpnConfigSectionName);
                var s = map.section(L.cbi.NamedSection, openvpnConfigSectionName, {
                        collabsible: true,
                        caption: L.tr(map.options.caption)

                });

                s.option(L.cbi.DummyValue, 'role1', {
                        caption: ('OpenVPN Role')
                });

                s.option(L.cbi.DummyValue, 'sub', {
                        caption: L.tr('Subject Name')
                });

                if (this.Mode == "TAP") {
                        s.option(L.cbi.SubHeadingValue, 'connectionsettings', {
                                caption: L.tr(''),
                                //  caption: L.tr(a),
                        }).ucivalue = function () {
                                return 'Bridge Connection settings For TAP';
                        };

                        s.option(L.cbi.ListValue, 'bridge', {
                                caption: L.tr('Enable/Disable'),

                        }).value("1", L.tr('Enable'))
                                .value("0", L.tr('Disable'));

                        s.option(L.cbi.lanInterfaceList, 'interface', {
                                caption: L.tr('Interface List'),
                        });
                }


                if (this.authPassValue !== "--NA--") {
                        s.option(L.cbi.CheckboxValue, 'enable_authentication', {
                                caption: L.tr('Enable Auth Pass'),
                                optional: true
                        });

                        s.option(L.cbi.InputValue, 'username', {
                                caption: L.tr('Username'),
                                placeholder: "User1",
                                optional: true
                        }).depends({ 'enable_authentication': '1' });
                        s.option(L.cbi.PasswordValue, 'password', {
                                caption: L.tr('Password'),
                                placeholder: "*******",
                                optional: true
                        }).depends({ 'enable_authentication': '1' });

                }
                if (this.ask_pass !== "--NA--") {

                        s.option(L.cbi.CheckboxValue, 'enable_askpass', {
                                caption: L.tr('Enable Ask Pass'),
                                optional: true
                        }).depends({ 'enable_authentication': '1' });

                        s.option(L.cbi.PasswordValue, 'auth_key', {
                                caption: L.tr('Auth Key'),
                                placeholder: "*******",
                                optional: true,
                        }).depends({ 'enable_askpass': '1' });


                }

                if (this.Role !== "CLIENT") {

                        // Peer LAN checkbox
                        s.option(L.cbi.CheckboxValue, 'enable_peer_lan', {
                                caption: L.tr('Enable peer LAN reachability'),
                                optional: true
                        }).depends({ role1: 'SERVER' });

                        // Peer Subject Name dropdown
                        s.option(L.cbi.ListValue, 'iroute_name', {
                                caption: L.tr('Peer Subject Count')
                        }).depends({ role1: 'SERVER', enable_peer_lan: '1' })
                                //.value("none", L.tr('Please choose'))
                                .value("1", L.tr('1'))
                                .value("2", L.tr('2'))
                                .value("3", L.tr('3'))
                                .value("4", L.tr('4'))
                                .value("5", L.tr('5'));

                        function applyDepends(option, startIndex) {
                                for (let j = startIndex; j <= 5; j++) {
                                        option.depends({
                                                role1: 'SERVER',
                                                enable_peer_lan: '1',
                                                iroute_name: String(j)
                                        });
                                }
                        }


                        for (let i = 1; i <= 5; i++) {
                                let nameOpt = s.option(L.cbi.InputValue, `iroute_name${i}`, {
                                        caption: L.tr(`Peer ${i} Subject Name`)
                                });
                                applyDepends(nameOpt, i);

                                let ipOpt = s.option(L.cbi.DynamicList, `iroute_address${i}`, {
                                        caption: L.tr(`Peer ${i} LAN IP Address`),
                                        placeholder: `192.168.${9 + i}.0`,
                                        datatype: 'ip4addr',
                                        optional: true
                                });
                                applyDepends(ipOpt, i);

                                let maskOpt = s.option(L.cbi.InputValue, `iroute_netmask${i}`, {
                                        caption: L.tr(`Peer ${i} LAN Netmask`),
                                        placeholder: '255.255.255.0',
                                        optional: true
                                });
                                applyDepends(maskOpt, i);
                        }

                }

        },
        openvpnRenderContents: function (rv) {
                var self = this;
                configdata = function () {
                        return rv;
                }

                var len = Object.keys(rv).length;
                if (len > 0) {
                        var list = new L.ui.table({
                                columns: [{
                                        caption: L.tr('Tunnel Name'),
                                        width: '20%',
                                        align: 'left',
                                        format: function (v, n) {
                                                var div = $('<p />').attr('id', 'openvpnConfigSectionName_%s'.format(n));
                                                return div.append('<strong>' + v + '</strong>');
                                        }
                                },
                                {
                                        caption: L.tr('Role'),
                                        width: '14%',
                                        align: 'left',
                                        format: function (v, n) {
                                                var div = $('<p />').attr('id', 'openvpnConfig_%s'.format(n));
                                                return div.append(v);
                                        }
                                },
                                {
                                        caption: L.tr('Mode'),
                                        width: '14%',
                                        align: 'left',
                                        format: function (v, n) {
                                                var div = $('<p />').attr('id', 'openvpnConfig_%s'.format(n));
                                                //alert(v);
                                                //alert(n);
                                                if (v === 'p2p') {
                                                        // Skip 'v' for 'p2p' mode
                                                } else {
                                                        return div.append(v);
                                                }
                                        }

                                },
                                {
                                        caption: L.tr('Proto'),
                                        width: '14%',
                                        align: 'left',
                                        format: function (v, n) {
                                                var div = $('<p />').attr('id', 'openvpnConfig_%s'.format(n));
                                                return div.append(v);
                                        }
                                },
                                {
                                        caption: L.tr('Port'),
                                        width: '14%',
                                        align: 'left',
                                        format: function (v, n) {
                                                var div = $('<p />').attr('id', 'openvpnConfig_%s'.format(n));
                                                return div.append(v);
                                        }
                                },
                                {
                                        caption: L.tr('Status'),
                                        width: '14%',
                                        align: 'left',
                                        format: function (v, n) {
                                                // alert(v);
                                                var div = $('<p />').attr('id', 'openvpnConfig_%s'.format(n));
                                                if (v === 'UP') {
                                                        div.css('background-color', '#90EE90'); // Light green for "Up"
                                                        div.css('color', 'white'); // Dark green text color for "Up"
                                                        div.css('width', '50%');
                                                        div.css('text-align', 'center');
                                                } else if (v === 'DOWN') {
                                                        div.css('background-color', '#FF6B6B'); // Light red for "Down"
                                                        div.css('color', 'white'); // Dark red text color for "Down"
                                                        div.css('text-align', 'center');
                                                        div.css('width', '50%');
                                                }
                                                return div.append('<strong>' + v + '</strong>');
                                        }
                                },
                                {
                                        caption: L.tr('Enable/Disable'),
                                        width: '14%',
                                        align: 'center',
                                        format: function (v, n) {
                                                var div = $('<label />').attr('id', 'openvpnConfig_%s'.format(n)).attr('class', 'switch');
                                                return div.append(`<input type="checkbox" ${v}   id="openvpnforwardingstatusSwitch${n}" onclick="openvpnenablebutton(${n})">
                                        <span class="slider round"></span>`);

                                        }

                                },

                                {
                                        caption: L.tr('Update'),
                                        align: 'center',
                                        format: function (v, n) {
                                                return $('<div />')
                                                        .addClass('btn-group btn-group-sm')

                                                        .append(L.ui.button(L.tr('Upload'), 'success', L.tr('Upload Configuration'))
                                                                .click({ self: self, openvpnConfigSectionName: v }, self.Openvpncertificatecheck))

                                                        .append(L.ui.button(L.tr('Edit'), 'primary', L.tr('Edit Configuration'))
                                                                .click({ self: self, openvpnConfigSectionName: v }, self.openvpnConfigSectionEdit))

                                                        .append(L.ui.button(L.tr('Delete'), 'danger', L.tr('Delete Configuration'))
                                                                .click({ self: self, openvpnConfigSectionName: v }, self.openvpnConfigSectionRemove));


                                        }
                                }]
                        });

                        for (var key in rv) {
                                if (rv.hasOwnProperty(key)) {

                                        var obj = rv[key];
                                        var Name = obj.name
                                        var Role = obj.role
                                        var Mode = obj.mode
                                        var Proto = obj.proto
                                        var Port = obj.port
                                        var Status = obj.status
                                        var Enabled = obj.enable
                                        var Address = obj.address

                                        var INV;


                                        if (Status === "UP") {
                                                INV = `<div style="border-radius: 5px;border: 2px solid #90EE90;border-left: 5px solid green;padding-left: 9px;">
                                        <b>Status:</b>${Status}<br />
                                         <b>IPAdd:</b>${Address}<br />
                                                </div>`;
                                        }
                                        else if (Status === "DOWN") {
                                                INV = `<div style="border-radius: 5px;border: 2px solid #FF6B6B;border-left: 5px solid Red;padding-left: 9px;">
                                        <b>Status:Down</b><br />
                                         <b>IPAdd: ---</b><br />
                                         </div>`;
                                        }
                                        if (Status == undefined) {
                                                INV = `<div style="border-radius: 5px;border: 2px solid #FF6B6B;border-left: 5px solid Red;padding-left: 9px;">
                                        <b>Status:Down</b><br />
                                         <b>IPAdd: ---</b><br />
                                         </div>`;
                                        }
                                        if (Enabled == "1") {
                                                Enabled = "checked"
                                        }

                                        else {
                                                INV = `<div style="border-radius: 5px;border: 2px solid #FF6B6B;border-left: 5px solid Red;padding-left: 9px;">
                                        <b>Status:Down</b><br />
                                        <b>IPAdd: ---</b><br />
                                        </div>`;
                                                Enabled = ""
                                        }

                                        if (Mode == 'p2p') {

                                        }
                                        else {

                                                list.row([Name, Role, Mode, Proto, Port, INV, Enabled, key]);

                                        }
                                }
                        }

                        $('#section_vpn_openvpn').append(list.render());

                }
                else {

                        L.ui.showNoConfigMessage("OpenVPN", "No-OpenVPN-Config");

                }




        },


        wireguardFormCallback: function () {
                var map = this;
                var wireguardConfigSectionName = map.options.wireguardConfigSection;
                //var numericExpression = /^[0-9]+$/;


                map.options.caption = L.tr('Wireguard Configuration Settings → %s').format(wireguardConfigSectionName);

                var s = map.section(L.cbi.NamedSection, wireguardConfigSectionName, {
                        collabsible: true,
                        caption: L.tr(map.options.caption),

                });



                s.option(L.cbi.DummyValue, 'role', {
                        caption: L.tr('Wireguard Role'),
                });

                s.option(L.cbi.ListValue, 'master_endpoint', {
                        caption: L.tr('Wireguard Tunnel Over'),
                }).value("none", L.tr('Please choose'))
                        .value("IPV4", L.tr('IPV4'))
                        .value("IPV6", L.tr('IPV6'))
                        .depends({ 'role': 'CLIENT' });

                s.option(L.cbi.CheckboxValue, 'failover', {
                        caption: L.tr('Enable Failover'),
                        optional: true
                }).depends({ 'role': 'CLIENT' });


                s.option(L.cbi.CheckboxValue, 'enable_ipv4', {
                        caption: L.tr('Enable IPV4'),
                        optional: true
                });
                s.option(L.cbi.CheckboxValue, 'enable_ipv6', {
                        caption: L.tr('Enable IPV6'),
                        optional: true
                });

                s.option(L.cbi.InputValue, 'addressesv4', {
                        caption: L.tr('Tunnel IPV4 Address'),
                        placeholder: "10.1.1.1/24",
                        datatype: 'cidr4',
                        optional: true,

                }).depends({ 'enable_ipv4': "1" });

                s.option(L.cbi.CheckboxValue, 'route_allowed_ips', {
                        caption: L.tr('Route Allowed IPs'),
                }).depends({ 'enable_ipv4': "1" });

                s.option(L.cbi.DynamicList, 'Allowedipv4', {
                        caption: L.tr('Allowed Peer IPs IPV4'),
                        placeholder: "10.1.1.1/24",
                        datatype: 'cidr4',
                        optional: true,
                }).depends({ 'route_allowed_ips': '1', 'enable_ipv4': "1" });

                s.option(L.cbi.InputValue, 'listen_port', {
                        caption: L.tr('Listening Port'),
                        placeholder: "51820",
                        datatype: 'uinteger_digit',
                        optional: true,
                });

                s.option(L.cbi.InputValue, 'addressesv6', {
                        caption: L.tr('IP Addresses IPV6'),
                        placeholder: "2001:0db8:85a3:0:0:8a2e:0370:7334/64",
                        datatype: 'cidr6',
                        optional: true,

                }).depends({ 'enable_ipv6': "1" });

                s.option(L.cbi.CheckboxValue, 'enable_allowedipv6', {
                        caption: L.tr('Enable Allowedipv6'),
                }).depends({ 'enable_ipv6': "1" });

                s.option(L.cbi.DynamicList, 'Allowedipv6', {
                        caption: L.tr('Allowed Peer IPs IPV6'),
                        placeholder: "2001:0db8:85a3:0:0:8a2e:0370:7334/64",
                        datatype: 'cidr6',
                        optional: true,

                }).depends({ 'enable_allowedipv6': '1', 'enable_ipv6': "1" });



                s.option(L.cbi.InputValue, 'endpoint_hostipv4', {
                        caption: L.tr('Endpoint Host IPV4'),
                        placeholder: "10.1.1.1",
                        datatype: 'ip4addr',
                        optional: true,

                }).depends({ 'role': 'CLIENT', 'enable_ipv4': "1" });

                s.option(L.cbi.InputValue, 'endpoint_hostipv6', {
                        caption: L.tr('Endpoint Host IPV6'),
                        placeholder: "2001:0db8:85a3:0:0:8a2e:0370:7334",
                        datatype: 'ip6addr',
                        optional: true,

                }).depends({ 'role': 'CLIENT', 'enable_ipv6': "1" });

                s.option(L.cbi.InputValue, 'endpoint_hostport', {
                        caption: L.tr('Endpoint HostPort'),
                        placeholder: "51820",
                        datatype: 'uinteger_digit',
                        optional: true,

                }).depends({ 'role': 'CLIENT' });

                s.option(L.cbi.PasswordValue, 'peers', {
                        caption: L.tr('Peer Publickey'),
                        optional: true
                });

                s.option(L.cbi.CheckboxValue, 'enable_preshared_key', {
                        caption: L.tr('Enable Preshared key'),
                        optional: true
                });

                s.option(L.cbi.PasswordValue, 'preshared_key', {
                        caption: L.tr('Preshared key'),
                        optional: true,
                }).depends({ 'enable_preshared_key': '1' });

                s.option(L.cbi.CheckboxValue, 'defaultroute', {
                        caption: L.tr('Enable Default Route'),
                        description: L.tr('Route all the traffic through wireguard tunnel'),
                        optional: true,
                }).depends({ 'role': 'CLIENT' });

        },

        wireguardRenderContents: function (rv) {
                var self = this;
                configdata1 = function () {
                        return rv;
                }
                var len = Object.keys(rv).length;
                if (len > 0) {
                        var list = new L.ui.table({
                                columns: [{
                                        caption: L.tr('Tunnel Name'),
                                        width: '14%',
                                        align: 'left',
                                        format: function (v, n) {
                                                var div = $('<p />').attr('id', 'wireguardConfigSectionName_%s'.format(n));
                                                return div.append('<strong>' + v + '</strong>');
                                        }
                                },
                                {
                                        caption: L.tr('Role'),
                                        width: '14%',
                                        align: 'center',
                                        format: function (v, n) {
                                                var div = $('<p />').attr('id', 'wireguard_%s'.format(n));
                                                return div.append(v);
                                        }
                                },
                                {
                                        caption: L.tr('Publickey'),
                                        width: '14%',
                                        align: 'center',
                                        format: function (v, n) {
                                                var div = $('<p />').attr('id', 'wireguard_%s'.format(n));
                                                return div.append(v);
                                        }
                                },
                                {
                                        caption: L.tr('Port'),
                                        width: '14%',
                                        align: 'left',
                                        format: function (v, n) {
                                                var div = $('<p />').attr('id', 'wireguard_%s'.format(n));
                                                return div.append(v);
                                        }
                                },
                                {
                                        caption: L.tr('Status'),
                                        width: '14%',
                                        align: 'center',
                                        format: function (v, n) {
                                                var div = $('<p />').attr('id', 'wireguard_%s'.format(n));
                                                if (v === 'UP') {
                                                        div.css('background-color', '#90EE90'); // Light green for "Up"
                                                        div.css('color', 'white'); // Dark green text color for "Up"
                                                        div.css('width', '100%');
                                                        div.css('text-align', 'center');
                                                } else if (v === 'DOWN') {
                                                        div.css('background-color', '#FF6B6B'); // Light red for "Down"
                                                        div.css('color', 'white'); // Dark red text color for "Down"
                                                        div.css('text-align', 'center');
                                                        div.css('width', '100%');
                                                }
                                                return div.append('<strong>' + v + '</strong>');
                                        }
                                },
                                {
                                        caption: L.tr('Enable/Disable'),
                                        width: '14%',
                                        align: 'center',
                                        format: function (v, n) {
                                                var div = $('<label />').attr('id', 'wireguard_%s'.format(n)).attr('class', 'switch');
                                                return div.append(`<input type="checkbox" ${v}   id="wireguardforwardingstatusSwitch${n}" onclick="wireguardenablebutton(${n})">
                                                <span class="slider round"></span>`);

                                        }

                                },
                                {
                                        caption: L.tr('Update'),
                                        align: 'center',
                                        format: function (v, n) {
                                                return $('<div />')
                                                        .addClass('btn-group btn-group-sm')

                                                        .append(L.ui.button(L.tr('Generate'), 'success', L.tr('generate'))
                                                                .click({ self: self, wireguardConfigSectionName: v }, self.wireguardcertificate))

                                                        .append(L.ui.button(L.tr('Edit'), 'primary', L.tr('Configure'))
                                                                .click({ self: self, wireguardConfigSectionName: v }, self.wireguardConfigSectionEdit))
                                                        .append(L.ui.button(L.tr('Delete'), 'danger', L.tr('Delete Event'))
                                                                .click({ self: self, wireguardConfigSectionName: v }, self.wireguardConfigSectionRemove));
                                        }
                                }]
                        });


                        for (var key in rv) {
                                if (rv.hasOwnProperty(key)) {
                                        var obj = rv[key];
                                        var Name = obj.name
                                        var Role = obj.role
                                        var Pub = obj.public_key
                                        var Port = obj.listen_port
                                        var Status = obj.status
                                        var Address = obj.address
                                        var Enabled = obj.disabled

                                        var INV
                                        if (Status === "UP") {
                                                INV = `<div style="border-radius: 5px;border: 2px solid #90EE90;border-left: 5px solid green;padding-left: 9px;text-align: left;">
                                        <b>Status:</b>${Status}<br />
                                         <b>IP Add:</b>${Address}<br />
                                                </div>`;
                                        }
                                        else if (Status === "DOWN") {
                                                INV = `<div style="border-radius: 5px;border: 2px solid #FF6B6B;border-left: 5px solid Red;padding-left: 9px;text-align: left;">
                                        <b>Status:Down</b><br />
                                         <b>IPAdd:---</b><br />
                                         </div>`;
                                        }
                                        if (Status == undefined) {
                                                INV = `<div style="border-radius: 5px;border: 2px solid #FF6B6B;border-left: 5px solid Red;padding-left: 9px;text-align: left;">
                                       <b>Status:Down</b><br />
                                        <b>IPAdd:---</b><br />
                                        </div>`;
                                        }

                                        if (Enabled == "0") {
                                                Enabled = "checked"
                                        }

                                        else {
                                                INV = `<div style="border-radius: 5px;border: 2px solid #FF6B6B;border-left: 5px solid Red;padding-left: 9px;text-align: left;">
                                        <b>Status:Down</b><br />
                                         <b>IPAdd:---</b><br />
                                         </div>`;
                                                Enabled = ""
                                        }

                                        list.row([Name, Role, Pub, Port, INV, Enabled, key]);
                                }
                        }


                        $('#section_vpn_wireguard').append(list.render());

                } else {
                        L.ui.showNoConfigMessage("Wireguard", "No-Wireguard-Config");

                }




        },

        zerotierFormCallback: function () {
                var map = this;
                var zerotierConfigSectionName = map.options.zerotierConfigSection;
                //var numericExpression = /^[0-9]+$/;


                map.options.caption = L.tr('Zerotier Connection Settings → %s').format(zerotierConfigSectionName);



                var s = map.section(L.cbi.NamedSection, zerotierConfigSectionName, {
                        collabsible: true,
                        caption: L.tr(map.options.caption)

                });



                s.option(L.cbi.InputValue, 'join', {
                        caption: L.tr('Network ID'),
                        placeholder: "db64858fed8ad663",
                        optional: true,

                });

                s.option(L.cbi.InputValue, 'port', {
                        caption: L.tr('Listen Port'),
                        placeholder: "9993",
                        datatype: 'uinteger',
                        optional: true,
                });

        },

        zerotierRenderContents: function (rv) {
                var self = this;
                configdata3 = function () {
                        return rv;
                }

                var len = Object.keys(rv).length;
                if (len > 0) {
                        var list = new L.ui.table({
                                columns: [{
                                        caption: L.tr('Tunnel Name'),
                                        //width: '14%',
                                        align: 'left',
                                        format: function (v, n) {
                                                var div = $('<p />').attr('id', 'zerotierConfigSectionName_%s'.format(n));
                                                return div.append('<strong>' + v + '</strong>');
                                        }
                                },
                                {
                                        caption: L.tr('Network ID'),
                                        //width: '14%',
                                        align: 'left',
                                        format: function (v, n) {
                                                var div = $('<p />').attr('id', 'zerotier_%s'.format(n));
                                                return div.append(v);
                                        }
                                },
                                {
                                        caption: L.tr('Port'),
                                        width: '14%',
                                        align: 'left',
                                        format: function (v, n) {
                                                var div = $('<p />').attr('id', 'zerotier_%s'.format(n));
                                                return div.append(v);
                                        }
                                },
                                {
                                        caption: L.tr('Node ID'),
                                        width: '14%',
                                        align: 'left',
                                        format: function (v, n) {
                                                var div = $('<p />').attr('id', 'zerotier_%s'.format(n));
                                                return div.append(v);
                                        }
                                },


                                {
                                        caption: L.tr('Enable/Disable'),
                                        //width: '14%',
                                        align: 'center',
                                        format: function (v, n) {
                                                var div = $('<label />').attr('id', 'zerotier_%s'.format(n)).attr('class', 'switch');
                                                return div.append(`<input type="checkbox" ${v}   id="zerotierforwardingstatusSwitch${n}" onclick="zerotierenablebutton(${n})">
                                                 <span class="slider round"></span>`);

                                        }

                                },
                                {
                                        caption: L.tr('Update'),
                                        align: 'center',
                                        format: function (v, n) {
                                                return $('<div />')
                                                        .addClass('btn-group btn-group-sm')

                                                        .append(L.ui.button(L.tr('Edit'), 'primary', L.tr('Configure'))
                                                                .click({ self: self, zerotierConfigSectionName: v }, self.zerotierConfigSectionEdit))
                                                        .append(L.ui.button(L.tr('Delete'), 'danger', L.tr('Delete Event'))
                                                                .click({ self: self, zerotierConfigSectionName: v }, self.zerotierConfigSectionRemove));
                                        }
                                }]
                        });


                        for (var key in rv) {
                                if (rv.hasOwnProperty(key)) {
                                        var obj = rv[key];
                                        var Name = obj.name
                                        var Join = obj.join
                                        var Port = obj.port
                                        var Nodeid = obj.nodeid
                                        //var Status = obj.status
                                        var Enabled = obj.enabled

                                        if (Enabled == "1") {
                                                Enabled = "checked"
                                        }

                                        else {
                                                Enabled = ""
                                        }

                                        list.row([Name, Join, Port, Nodeid, Enabled, key]);
                                }
                        }

                        $('#section_vpn_zerotier').append(list.render());
                } else {
                        L.ui.showNoConfigMessage('Zerotier', 'No-Zerotier-Config')

                }




        },



        pptpdFormCallback: function () {
                var map = this;
                var pptpdConfigSectionName = map.options.pptpdConfigSection;
                //var numericExpression = /^[0-9]+$/;


                map.options.caption = L.tr('PPTP Connection Settings → %s').format(pptpdConfigSectionName);

                var s = map.section(L.cbi.NamedSection, pptpdConfigSectionName, {
                        collabsible: true,
                        caption: L.tr(map.options.caption)

                });



                s.option(L.cbi.ListValue, 'type', {
                        caption: L.tr('PPTP Role'),
                }).value("SERVER", L.tr('Server'))
                        .value("CLIENT", L.tr('Client'));

                s.option(L.cbi.CheckboxValue, 'defaultroute', {
                        caption: L.tr('Default Route'),
                        optional: true
                }).depends({ 'type': 'CLIENT' });

                s.option(L.cbi.InputValue, 'metric', {
                        caption: L.tr('Metric'),
                }).depends({
                        'defaultroute': '1',
                        'type': 'CLIENT'
                });

                s.option(L.cbi.InputValue, 'localip', {
                        caption: L.tr('Local IP'),
                        placeholder: "192.168.0.1",
                        datatype: 'ip4addr',
                        optional: true,

                }).depends({ 'type': 'SERVER' });



                s.option(L.cbi.InputValue, 'remoteip', {
                        caption: L.tr('Remote IP range'),
                        placeholder: "192.168.0.20-30",
                        optional: true,
                }).depends({ 'type': 'SERVER' });

                s.option(L.cbi.InputValue, 'serverip', {
                        caption: L.tr('Server IP'),
                        placeholder: "192.168.10.1",
                        optional: true,
                }).depends({ 'type': 'CLIENT' });

                //s.option(L.cbi.CheckboxValue, 'checkup_interval', {
                //caption: L.tr('Checkup Interval(in sec)'),
                //optional: true
                //}).depends({ 'type': 'CLIENT' });

                //s.option(L.cbi.InputValue, 'intervaltime', {
                //caption: L.tr('Interval Time'),
                //}).depends({ 
                //'checkup_interval': '1',
                //'type': 'CLIENT'
                //});

                s.option(L.cbi.wanInterfaceList, 'interface', {
                        caption: L.tr('Interface'),
                        optional: true
                }).value("any", "Any")
                        .depends({ 'type': 'CLIENT' });

                s.option(L.cbi.InputValue, 'username', {
                        caption: L.tr('Username'),
                        placeholder: "User1",
                        optional: true,
                }).depends({ 'type': 'SERVER' });

                s.option(L.cbi.PasswordValue, 'password', {
                        caption: L.tr('Password'),
                        placeholder: "*******",
                        optional: true,
                }).depends({ 'type': 'SERVER' });

                s.option(L.cbi.InputValue, 'usernamee', {
                        caption: L.tr('Username'),
                        placeholder: "User",
                        optional: true,
                }).depends({ 'type': 'CLIENT' });

                s.option(L.cbi.PasswordValue, 'passwordd', {
                        caption: L.tr('Password'),
                        placeholder: "*******",
                        optional: true,
                }).depends({ 'type': 'CLIENT' });


                s.option(L.cbi.CheckboxValue, 'mppe_stateless', {
                        caption: L.tr('MPPE Encryption'),
                        optional: true
                }).depends({ 'type': 'CLIENT' });


        },

        pptpdRenderContents: function (rv) {
                var self = this;
                configdata4 = function () {
                        return rv;
                }


                var len = Object.keys(rv).length;
                if (len > 0) {
                        var list = new L.ui.table({
                                columns: [{
                                        caption: L.tr('Tunnel Name'),
                                        //width: '14%',
                                        align: 'left',
                                        format: function (v, n) {
                                                var div = $('<p />').attr('id', 'pptpdSectionName_%s'.format(n));
                                                return div.append('<strong>' + v + '</strong>');
                                        }
                                },
                                {
                                        caption: L.tr('Role'),
                                        //width: '14%',
                                        align: 'left',
                                        format: function (v, n) {
                                                var div = $('<p />').attr('id', 'pptpd_%s'.format(n));
                                                return div.append(v);
                                        }
                                },

                                {
                                        caption: L.tr('Status'),
                                        width: '14%',
                                        align: 'center',
                                        format: function (v, n) {
                                                var div = $('<p />').attr('id', 'pptpd_%s'.format(n));
                                                if (v === 'UP') {
                                                        div.css('background-color', '#90EE90'); // Light green for "Up"
                                                        div.css('color', 'white'); // Dark green text color for "Up"
                                                        div.css('width', '100%');
                                                        div.css('text-align', 'center');
                                                } else if (v === 'DOWN') {
                                                        div.css('background-color', '#FF6B6B'); // Light red for "Down"
                                                        div.css('color', 'white'); // Dark red text color for "Down"
                                                        div.css('text-align', 'center');
                                                        div.css('width', '100%');
                                                }
                                                return div.append('<strong>' + v + '</strong>');
                                        }
                                },

                                {
                                        caption: L.tr('Enable/Disable'),
                                        //width: '14%',
                                        align: 'center',
                                        format: function (v, n) {
                                                var div = $('<label />').attr('id', 'pptpd_%s'.format(n)).attr('class', 'switch');
                                                return div.append(`<input type="checkbox" ${v}   id="pptpdforwardingstatusSwitch${n}" onclick="pptpdenablebutton(${n})">
                                                <span class="slider round"></span>`);

                                        }

                                },
                                {
                                        caption: L.tr('Update'),
                                        align: 'center',
                                        format: function (v, n) {
                                                return $('<div />')
                                                        .addClass('btn-group btn-group-sm')

                                                        .append(L.ui.button(L.tr('Edit'), 'primary', L.tr('Configure'))
                                                                .click({ self: self, pptpdConfigSectionName: v }, self.pptpdConfigSectionEdit))
                                                        .append(L.ui.button(L.tr('Delete'), 'danger', L.tr('Delete Event'))
                                                                .click({ self: self, pptpdConfigSectionName: v }, self.pptpdConfigSectionRemove));
                                        }
                                }]
                        });


                        for (var key in rv) {
                                if (rv.hasOwnProperty(key)) {
                                        var obj = rv[key];
                                        var Name = obj.name
                                        var Role = obj.type
                                        var Status = obj.status
                                        var Address = obj.address
                                        var Enabled = obj.enabled

                                        var INV;


                                        if (Status === "UP") {
                                                INV = `<div style="border-radius: 5px;border: 2px solid #90EE90;border-left: 5px solid green;padding-left: 9px;text-align: left">
                                        <b>Status:</b>${Status}<br />
                                         <b>IPAdd:</b>${Address}<br />
                                                </div>`;
                                        }
                                        else if (Status === "DOWN") {
                                                INV = `<div style="border-radius: 5px;border: 2px solid #FF6B6B;border-left: 5px solid Red;padding-left: 9px;text-align: left">
                                        <b>Status:Down</b><br />
                                         <b>IPAdd: ---</b><br />
                                         </div>`;
                                        }
                                        if (Status == undefined) {
                                                INV = `<div style="border-radius: 5px;border: 2px solid #FF6B6B;border-left: 5px solid Red;padding-left: 9px;text-align: left">
                                        <b>Status:Down</b><br />
                                         <b>IPAdd: ---</b><br />
                                         </div>`;
                                        }


                                        if (Enabled == "1") {
                                                Enabled = "checked"
                                        }

                                        else {
                                                INV = `<div style="border-radius: 5px;border: 2px solid #FF6B6B;border-left: 5px solid Red;padding-left: 9px;text-align: left">
                                        <b>Status:Down</b><br />
                                         <b>IPAdd: ---</b><br />
                                         </div>`;
                                                Enabled = ""
                                        }

                                        list.row([Name, Role, INV, Enabled, key]);
                                }
                        }


                        $('#section_vpn_PPTP').append(list.render());
                } else {

                        L.ui.showNoConfigMessage('PPTP', 'No-PPTP-Config')
                }



        },

        l2tpFormCallback: function () {
                var map = this;
                var l2tpConfigSectionName = map.options.l2tpConfigSection;
                //var numericExpression = /^[0-9]+$/;


                map.options.caption = L.tr('L2TP Connection Settings → %s').format(l2tpConfigSectionName);

                var s = map.section(L.cbi.NamedSection, l2tpConfigSectionName, {
                        collabsible: true,
                        caption: L.tr(map.options.caption)

                });

                s.option(L.cbi.ListValue, 'type', {
                        caption: L.tr('PPTP Role'),
                })
                //.value("server", L.tr('Server'))
                        .value("CLIENT", L.tr('Client'));

                s.option(L.cbi.CheckboxValue, 'defaultroute', {
                        caption: L.tr('Default Route'),
                        optional: true
                }).depends({ 'type': 'CLIENT' });

                s.option(L.cbi.InputValue, 'metric', {
                        caption: L.tr('Metric'),
                }).depends({
                        'defaultroute': '1',
                        'type': 'CLIENT'
                });

                s.option(L.cbi.InputValue, 'localip', {
                        caption: L.tr('Local IP'),
                        placeholder: "192.168.0.1",
                        datatype: 'ip4addr',
                        optional: true,

                }).depends({ 'type': 'server' });



                // s.option(L.cbi.InputValue, 'remoteip', {
                //         caption: L.tr('Remote IP'),
                //         placeholder: "192.168.0.20-30",
                //         optional: true,
                // }).depends({ 'type': 'server' });

                s.option(L.cbi.InputValue, 'start', {
                        caption: L.tr('Start'),
                        placeholder: "192.168.0.20",
                        datatype: 'ip4addr',
                        optional: true,

                }).depends({ 'type': 'server' });
                s.option(L.cbi.InputValue, 'limit', {
                        caption: L.tr('Limit'),
                        placeholder: "192.168.0.30",
                        datatype: 'ip4addr',
                        optional: true,

                }).depends({ 'type': 'server' });


                s.option(L.cbi.InputValue, 'serverip', {
                        caption: L.tr('Server IP'),
                        placeholder: "192.168.10.1",
                        optional: true,
                }).depends({ 'type': 'CLIENT' });

                s.option(L.cbi.CheckboxValue, 'checkup_interval', {
                        caption: L.tr('Checkup Interval(in sec)'),
                        optional: true
                }).depends({ 'type': 'CLIENT' });

                s.option(L.cbi.InputValue, 'intervaltime', {
                        caption: L.tr('Interval Time'),
                }).depends({
                        'checkup_interval': '1',
                        'type': 'CLIENT'
                });


                s.option(L.cbi.wanInterfaceList, 'interface', {
                        caption: L.tr('Interface'),
                        optional: true
                }).value("any", "Any")
                        .depends({ 'type': 'CLIENT' });

                s.option(L.cbi.InputValue, 'username', {
                        caption: L.tr('Username'),
                        placeholder: "User1",
                        optional: true,
                }).depends({ 'type': 'server' });

                s.option(L.cbi.PasswordValue, 'password', {
                        caption: L.tr('Password'),
                        placeholder: "*******",
                        optional: true,
                }).depends({ 'type': 'server' });

                s.option(L.cbi.InputValue, 'usernamee', {
                        caption: L.tr('Username'),
                        placeholder: "User",
                        optional: true,
                }).depends({ 'type': 'CLIENT' });

                s.option(L.cbi.PasswordValue, 'passwordd', {
                        caption: L.tr('Password'),
                        placeholder: "*******",
                        optional: true,
                }).depends({ 'type': 'CLIENT' });


                s.option(L.cbi.CheckboxValue, 'mppe_stateless', {
                        caption: L.tr('MPPE Encryption'),
                        optional: true
                }).depends({ 'type': 'CLIENT' });


        },

        l2tpRenderContents: function (rv) {
                var self = this;
                configdata5 = function () {
                        return rv;
                }
                var len = Object.keys(rv).length;
                if (len > 0) {
                        var list = new L.ui.table({
                                columns: [{
                                        caption: L.tr('Tunnel Name'),
                                        //width: '14%',
                                        align: 'left',
                                        format: function (v, n) {
                                                var div = $('<p />').attr('id', 'l2tpConfigSectionName_%s'.format(n));
                                                return div.append('<strong>' + v + '</strong>');
                                        }
                                },
                                {
                                        caption: L.tr('Role'),
                                        //width: '14%',
                                        align: 'left',
                                        format: function (v, n) {
                                                var div = $('<p />').attr('id', 'l2tp_%s'.format(n));
                                                return div.append(v);
                                        }
                                },
                                {
                                        caption: L.tr('Status'),
                                        width: '14%',
                                        align: 'center',
                                        format: function (v, n) {
                                                var div = $('<p />').attr('id', 'pptpd_%s'.format(n));
                                                if (v === 'UP') {
                                                        div.css('background-color', '#90EE90'); // Light green for "Up"
                                                        div.css('color', 'white'); // Dark green text color for "Up"
                                                        div.css('width', '100%');
                                                        div.css('text-align', 'center');
                                                } else if (v === 'DOWN') {
                                                        div.css('background-color', '#FF6B6B'); // Light red for "Down"
                                                        div.css('color', 'white'); // Dark red text color for "Down"
                                                        div.css('text-align', 'center');
                                                        div.css('width', '100%');
                                                }
                                                return div.append('<strong>' + v + '</strong>');
                                        }
                                },
                                {
                                        caption: L.tr('Enable/Disable'),
                                        //width: '14%',
                                        align: 'center',
                                        format: function (v, n) {
                                                var div = $('<label />').attr('id', 'l2tp_%s'.format(n)).attr('class', 'switch');
                                                return div.append(`<input type="checkbox" ${v}   id="l2tpforwardingstatusSwitch${n}" onclick="l2tpenablebutton(${n})">
                                                <span class="slider round"></span>`);

                                        }

                                },
                                {
                                        caption: L.tr('Update'),
                                        align: 'center',
                                        format: function (v, n) {
                                                return $('<div />')
                                                        .addClass('btn-group btn-group-sm')

                                                        .append(L.ui.button(L.tr('Edit'), 'primary', L.tr('Configure'))
                                                                .click({ self: self, l2tpConfigSectionName: v }, self.l2tpConfigSectionEdit))
                                                        .append(L.ui.button(L.tr('Delete'), 'danger', L.tr('Delete Event'))
                                                                .click({ self: self, l2tpConfigSectionName: v }, self.l2tpConfigSectionRemove));
                                        }
                                }]
                        });


                        for (var key in rv) {
                                if (rv.hasOwnProperty(key)) {
                                        var obj = rv[key];
                                        var Name = obj.name
                                        var Role = obj.type
                                        var Status = obj.status
                                        var Address = obj.address
                                        var Enabled = obj.enabled

                                        var INV;


                                        if (Status === "UP") {
                                                INV = `<div style="border-radius: 5px;border: 2px solid #90EE90;border-left: 5px solid green;padding-left: 9px;text-align: left">
                                        <b>Status:</b>${Status}<br />
                                         <b>IPAdd:</b>${Address}<br />
                                                </div>`;
                                        }
                                        else if (Status === "DOWN") {
                                                INV = `<div style="border-radius: 5px;border: 2px solid #FF6B6B;border-left: 5px solid Red;padding-left: 9px;text-align: left">
                                        <b>Status:Down</b><br />
                                         <b>IPAdd: ---</b><br />
                                         </div>`;
                                        }
                                        if (Status == undefined) {
                                                INV = `<div style="border-radius: 5px;border: 2px solid #FF6B6B;border-left: 5px solid Red;padding-left: 9px;text-align: left">
                                        <b>Status:Down</b><br />
                                         <b>IPAdd: ---</b><br />
                                         </div>`;
                                        }


                                        if (Enabled == "1") {
                                                Enabled = "checked"
                                        }

                                        else {
                                                INV = `<div style="border-radius: 5px;border: 2px solid #FF6B6B;border-left: 5px solid Red;padding-left: 9px;text-align: left">
                                        <b>Status:Down</b><br />
                                         <b>IPAdd: ---</b><br />
                                         </div>`;
                                                Enabled = ""
                                        }

                                        list.row([Name, Role, INV, Enabled, key]);
                                }
                        }


                        $('#section_vpn_L2TP').append(list.render());

                }
                else {

                        L.ui.showNoConfigMessage('L2TP', 'No-L2TP-Config')

                }


        },


        //////////////////////////// Tunnels /////////////////////////////////

        GreFormCallback: function () {
                var map = this;
                var GreConfigSectionName = map.options.GreConfigSection;
                var numericExpression = /^[0-9]+$/;


                map.options.caption = L.tr('GRE Tunnel Settings → %s').format(GreConfigSectionName);

                var s = map.section(L.cbi.NamedSection, GreConfigSectionName, {
                        collabsible: true,
                        caption: L.tr(map.options.caption)
                });


                s.option(L.cbi.DummyValue, 'tunnelname', {
                        caption: L.tr('Tunnel name'),
                        datatype: 'rt_alphanumeric',
                });

                s.option(L.cbi.ListValue, 'modes', {
                        caption: L.tr('GRE Tunnel Over'),
                }).value("none", L.tr('Please choose'))
                        .value("IPV4", L.tr('IPv4'))
                        .value("IPV6", L.tr('IPv6'));


                // Subheading for IPv4
                s.option(L.cbi.SubHeadingValue, 'subnameipv4', {
                        caption: L.tr('')
                })
                        .depends({ 'modes': 'IPV4' })
                        .ucivalue = function () {
                                return 'IPv4 Settings';
                        };

                // Subheading for IPv6
                s.option(L.cbi.SubHeadingValue, 'subnameipv6', {
                        caption: L.tr('')
                })
                        .depends({ 'modes': 'IPV6' })
                        .ucivalue = function () {
                                return 'IPv6 Settings';
                        };



                s.option(L.cbi.InputValue, 'localexternalIP', {
                        caption: L.tr('Local Public IPv4'),
                        placeholder: '192.168.6.1',
                        datatype: 'ip4addr',
                }).depends({ 'modes': 'IPV4' });


                s.option(L.cbi.InputValue, 'remoteexternalIP', {
                        caption: L.tr('Remote Public IPv4'),
                        placeholder: '192.168.0.1',
                        datatype: 'ip4addr',
                }).depends({ 'modes': 'IPV4' });

                s.option(L.cbi.InputValue, 'localtunnelIP', {
                        caption: L.tr('Local tunnel IPv4'),
                        placeholder: '10.1.1.12',
                        datatype: 'ip4addr',
                }).depends({ 'modes': 'IPV4' });

                s.option(L.cbi.InputValue, 'peertunnelIP', {
                        caption: L.tr('Remote tunnel IPv4'),
                        placeholder: '10.1.1.2',
                        datatype: 'ip4addr',
                }).depends({ 'modes': 'IPV4' });

                s.option(L.cbi.InputValue, 'localnetmask', {
                        caption: L.tr('Local tunnel net mask IPv4'),
                        placeholder: '255.255.255.0',
                        datatype: 'ip4addr',
                }).depends({ 'modes': 'IPV4' });


                s.option(L.cbi.InputValue, 'remoteip', {
                        caption: L.tr('Remote Local Subnet IPv4'),
                        placeholder: '192.168.10.0/24',
                        datatype: 'cidr4',
                }).depends({ 'modes': 'IPV4' });


                ///////////IPV6////////////////////////////////////
                s.option(L.cbi.InputValue, 'localexternalIPv6', {
                        caption: L.tr('Local Public IPv6'),
                        placeholder: '2001:0db8:85a3:0:0:8a2e:0370:7334',
                        datatype: 'ip6addr',
                }).depends({ 'modes': 'IPV6' });


                s.option(L.cbi.InputValue, 'remoteexternalIPv6', {
                        caption: L.tr('Remote Public IPv6'),
                        placeholder: '2001:0db8:85a3:0:0:8a2e:0370:7334',
                        datatype: 'ip6addr',
                }).depends({ 'modes': 'IPV6' });

                s.option(L.cbi.InputValue, 'localtunnelIPv6', {
                        caption: L.tr('Local tunnel IPv6'),
                        placeholder: 'fd00::1/64',
                        datatype: 'cidr6',
                }).depends({ 'modes': 'IPV6' });

                s.option(L.cbi.InputValue, 'peertunnelIPv6', {
                        caption: L.tr('Remote tunnel IPv6'),
                        placeholder: 'fd00::2',
                        datatype: 'ip6addr',
                }).depends({ 'modes': 'IPV6' });

                // s.option(L.cbi.InputValue, 'localnetmask', {
                //         caption: L.tr('Local tunnel net mask'),
                //         placeholder: '255.255.255.0',
                //         datatype: 'ip4addr',
                // }).depends({ 'modes': 'IPV6' });


                s.option(L.cbi.InputValue, 'remoteipv6', {
                        caption: L.tr('Remote Local Subnet IPv6'),
                        placeholder: '2001:0db8:85a3:0:0:8a2e:0370:7334/64',
                        datatype: 'cidr6',
                }).depends({ 'modes': 'IPV6' });

                ///////////////////////////////////////////////////////////

                s.option(L.cbi.CheckboxValue, 'enabletun', {
                        caption: L.tr('Enable Tunnel Link'),
                });


                s.option(L.cbi.InterfaceList_ra, 'interfacetype', {
                        caption: L.tr('Interface type'),
                        optional: true
                }).depends({ 'enabletun': '1' });


                s.option(L.cbi.InputValue, 'mtu', {
                        caption: L.tr('MTU'),
                        placeholder: '1476',
                        datatype: 'max(1476)',
                });

                s.option(L.cbi.InputValue, 'ttl', {
                        caption: L.tr('TTL'),
                        placeholder: '64',
                        datatype: 'range(1,255)',
                });

                s.option(L.cbi.InputValue, 'tunnelkey', {
                        caption: L.tr('Tunnel key'),
                        placeholder: '0-4245967295',
                        datatype: 'uinteger',
                });

                s.option(L.cbi.CheckboxValue, 'enablekeepalive', {
                        caption: L.tr('Enable keep alive'),
                        optional: true
                });

                s.option(L.cbi.InputValue, 'aliveinterval', {
                        caption: L.tr('Keep alive interval'),
                        placeholder: '10',
                }).depends({ 'enablekeepalive': '1' });

        },

        GreRenderContents: function (rv) {
                var self = this;
                var len = Object.keys(rv).length;
                if (len > 0) {
                        var list = new L.ui.table({
                                columns: [{
                                        caption: L.tr('Sl No'),
                                        //width: '14%',
                                        align: 'left',
                                        format: function (v, n) {
                                                var div = $('<p />').attr('id', 'GreDeviceSerialNo_%s'.format(n));
                                                var serialNo = n + 1;
                                                return div.append(serialNo);
                                        }
                                },
                                {
                                        caption: L.tr('Tunnel Name'),
                                        //width: '14%',
                                        align: 'left',
                                        format: function (v, n) {
                                                var div = $('<p />').attr('id', 'GreDeviceEventName_%s'.format(n));
                                                return div.append(v);
                                        }
                                },
                                {
                                        caption: L.tr('Local Public IP'),
                                        //width: '14%',
                                        align: 'left',
                                        format: function (v, n) {
                                                var div = $('<p />').attr('id', 'GreDeviceEventName_%s'.format(n));
                                                return div.append(v);
                                        }
                                },
                                {
                                        caption: L.tr('Remote Public IP'),
                                        //width: '14%',
                                        align: 'left',
                                        format: function (v, n) {
                                                var div = $('<p />').attr('id', 'GreDeviceEventName_%s'.format(n));
                                                return div.append(v);
                                        }
                                },
                                {
                                        caption: L.tr('Remote Tunnel IP'),
                                        //width: '14%',
                                        align: 'left',
                                        format: function (v, n) {
                                                var div = $('<p />').attr('id', 'GreDeviceEventName_%s'.format(n));
                                                return div.append(v);
                                        }
                                },
                                {
                                        caption: L.tr('Remote Local Subnet'),
                                        //width: '14%',
                                        align: 'left',
                                        format: function (v, n) {
                                                var div = $('<p />').attr('id', 'GreDeviceEventName_%s'.format(n));
                                                return div.append(v);
                                        }
                                },
                                {
                                        caption: L.tr('Status'),
                                        //width: '14%',
                                        align: 'left',
                                        format: function (v, n) {
                                                var div = $('<p />').attr('id', 'GreDeviceEventName_%s'.format(n));
                                                // if (v === 'UP') {
                                                //         div.css('background-color', '#90EE90'); // Light green for "Up"
                                                //         div.css('color', 'white'); // Dark green text color for "Up"
                                                //         div.css('width', '50%');
                                                //         div.css('text-align', 'center');
                                                // } else if (v === 'DOWN') {
                                                //         div.css('background-color', '#FF6B6B'); // Light red for "Down"
                                                //         div.css('color', 'white'); // Dark red text color for "Down"
                                                //         div.css('text-align', 'center');
                                                //         div.css('width', '50%');
                                                // }
                                                return div.append('<strong>' + v + '</strong>');
                                        }
                                },
                                {
                                        caption: L.tr('Update'),
                                        //width: '14%',
                                        align: 'center',
                                        format: function (v, n) {
                                                return $('<div />')
                                                        .addClass('btn-group btn-group-sm')
                                                        .append(L.ui.button(L.tr('Edit'), 'primary', L.tr('Configure'))
                                                                .click({ self: self, GreConfigSectionName: v }, self.GreConfigSectionEdit))
                                                        .append(L.ui.button(L.tr('Delete'), 'danger', L.tr('Delete Event'))
                                                                .click({ self: self, GreConfigSectionName: v }, self.GreConfigSectionRemove));

                                        }
                                }]
                        });

                        for (var key in rv) {
                                if (rv.hasOwnProperty(key)) {
                                        var obj = rv[key];
                                        var Tunnel = obj.tunnelname
                                        var localwan = (obj.localexternalIP !== undefined ? obj.localexternalIP : '---');
                                        var remotewan = (obj.remoteexternalIP !== undefined ? obj.remoteexternalIP : '---');
                                        var remotetunnel = (obj.peertunnelIP !== undefined ? obj.peertunnelIP : '---');
                                        var remotesubnet = (obj.remoteip !== undefined ? obj.remoteip : '---');
                                        var Modes = (obj.modes !== undefined ? obj.modes : '---');
                                        var localwanIPV6 = (obj.localexternalIPv6 !== undefined ? obj.localexternalIPv6 : '---');
                                        var remotewanIPV6 = (obj.remoteexternalIPv6 !== undefined ? obj.remoteexternalIPv6 : '---');
                                        var remotetunnelIPV6 = (obj.peertunnelIPv6 !== undefined ? obj.peertunnelIPv6 : '---');
                                        var remotesubnetIPV6 = (obj.remoteipv6 !== undefined ? obj.remoteipv6 : '---');
                                        var Status = obj.status;

                                        var INV;
                                        var INV1;
                                        var INV2 = `<div style="border-radius: 5px; border: 2px solid #FF6B6B; border-left: 7px solid red; padding-left: 9px; width: 74px;">
                                        <b>DOWN</b><br /></div>`;

                                        if (Status === "UP") {
                                                INV = `<div style="border-radius: 5px; border: 2px solid #90EE90; border-left: 7px solid green; padding-left: 17px; width: 74px;">   
                                        <b>UP</b><br /></div>`;
                                                INV1 = INV;
                                        }

                                        else if (Status === "DOWN") {
                                                INV = `<div style="border-radius: 5px; border: 2px solid #FF6B6B; border-left: 7px solid red; padding-left: 9px; width: 74px;">
                                        <b>DOWN</b><br /></div>`;
                                                INV1 = INV;
                                        }

                                        if (Modes === "---") {
                                                list.row([key, Tunnel, localwan, remotewan, remotetunnel, remotesubnet, INV2, key]);
                                        }
                                        if (Modes === "IPV6") {
                                                list.row([key, Tunnel, localwanIPV6, remotewanIPV6, remotetunnelIPV6, remotesubnetIPV6, INV1, key]);
                                        }
                                        if (Modes === "IPV4") {
                                                list.row([key, Tunnel, localwan, remotewan, remotetunnel, remotesubnet, INV, key]);
                                        }

                                }
                        }

                        $('#section_vpn_gre').append(list.render());

                } else {
                        L.ui.showNoConfigMessage('GRE Tunnel', 'No-GRE-Config')
                }

        },

        ipipFormCallback: function () {
                var map = this;
                var ipipConfigSectionName = map.options.ipipConfigSection;
                var numericExpression = /^[0-9]+$/;


                map.options.caption = L.tr('IPIP Tunnel Settings → %s').format(ipipConfigSectionName);


                var s1 = map.section(L.cbi.NamedSection, ipipConfigSectionName, {
                        collabsible: true,
                        caption: L.tr(map.options.caption)
                });

                // s1.option(L.cbi.DummyValue, 'typesettings', {
                //         caption: L.tr(''),
                // })
                //         .ucivalue = function () {
                //                 var id = "<h5><b>&nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbspIPIPTunnel Configuration </b> </h3>";
                //                 return id;
                //         };

                s1.option(L.cbi.DummyValue, 'tunnelname', {
                        caption: L.tr('Tunnel name'),
                        datatype: 'rt_alphanumeric',
                });

                s1.option(L.cbi.InputValue, 'localexternalIP', {
                        caption: L.tr('Local external IP'),
                        placeholder: '192.168.6.1',
                        datatype: 'ip4addr',
                }).depends({ 'tempenableipip': '1' });

                s1.option(L.cbi.InputValue, 'remoteexternalIP', {
                        caption: L.tr('Remote external IP'),
                        placeholder: '192.168.0.1',
                        datatype: 'ip4addr',
                });

                s1.option(L.cbi.InputValue, 'localtunnelIP', {
                        caption: L.tr('Local tunnel IP'),
                        placeholder: '10.1.1.12',
                        datatype: 'ip4addr',
                });

                s1.option(L.cbi.InputValue, 'peertunnelIP', {
                        caption: L.tr('Peer tunnel IP'),
                        placeholder: '10.1.1.2',
                        datatype: 'ip4addr',
                });

                s1.option(L.cbi.InputValue, 'localnetmask', {
                        caption: L.tr('Local tunnel net mask'),
                        placeholder: '255.255.255.0',
                        datatype: 'ip4addr',
                });

                s1.option(L.cbi.InputValue, 'remoteip', {
                        caption: L.tr('Remote IP'),
                        placeholder: '192.168.10.0/24',
                        datatype: 'cidr4',
                });

                s1.option(L.cbi.CheckboxValue, 'enabletun', {
                        caption: L.tr('Enable Tunnel Link'),
                });
                s1.option(L.cbi.wanInterfaceList, 'interfacetype', {
                        caption: L.tr('Interface type'),
                        optional: true
                }).depends({ 'enabletun': '1' });

                s1.option(L.cbi.InputValue, 'mtu', {
                        caption: L.tr('MTU'),
                        placeholder: '1476',
                        datatype: 'max(1476)',
                });

                s1.option(L.cbi.InputValue, 'ttl', {
                        caption: L.tr('TTL'),
                        placeholder: '64',
                        datatype: 'range(1,255)',
                });


                s1.option(L.cbi.InputValue, 'tunnelkey', {
                        caption: L.tr('Tunnel key'),
                        optional: true,
                        placeholder: '0-4245967295',
                        datatype: 'uinteger',
                });

                s1.option(L.cbi.CheckboxValue, 'enablekeepalive', {
                        caption: L.tr('Enable keep alive'),
                        optional: true
                });

                s1.option(L.cbi.InputValue, 'aliveinterval', {
                        caption: L.tr('Keep alive interval'),
                        placeholder: '10',
                }).depends({ 'enablekeepalive': '1' });

        },

        IPIPRenderContents: function (rv) {
                var self = this;
                var len = Object.keys(rv).length;
                if (len > 0) {
                        var list2 = new L.ui.table({
                                columns: [{
                                        caption: L.tr('Sl No'),
                                        align: 'left',
                                        format: function (v, n) {
                                                var div = $('<p />').attr('id', 'ipipDeviceSerialNo_%s'.format(n));
                                                var serialNo = n + 1;
                                                return div.append(serialNo);
                                        }
                                },
                                {
                                        caption: L.tr(' Tunnel Name'),
                                        width: '30%',
                                        align: 'left',
                                        format: function (v, n) {
                                                var div = $('<p />').attr('id', 'ipipDeviceEventName_%s'.format(n));
                                                return div.append('<strong>' + v + '</strong>');
                                        }
                                },
                                {
                                        caption: L.tr('Update'),
                                        align: 'left',
                                        format: function (v, n) {
                                                return $('<div />')
                                                        .addClass('btn-group btn-group-sm')
                                                        .append(L.ui.button(L.tr('Edit'), 'primary', L.tr('Configure'))
                                                                .click({ self: self, ipipConfigSectionName: v }, self.ipipConfigSectionEdit))
                                                        .append(L.ui.button(L.tr('Delete'), 'danger', L.tr('Delete Event'))
                                                                .click({ self: self, ipipConfigSectionName: v }, self.ipipConfigSectionRemove));

                                        }
                                }]
                        });

                        for (var key in rv) {
                                if (rv.hasOwnProperty(key)) {
                                        var obj = rv[key];
                                        list2.row([key, key, key]);
                                }
                        }

                        $('#section_vpn_ipip').append(list2.render());
                } else {
                        L.ui.showNoConfigMessage('IPIP Tunnel', 'No-IPIP-Config')

                }


        },

        //////////////////////////// Tunnels /////////////////////////////////

        RS485ConfigSectionAdd: function () {
                var self = this;
                var RS485ConfigSectionName = $('#field_NewEvent_name').val();
                var sensorSectionOptions = { name: RS485ConfigSectionName, connectionenable: 1, EEnable: 0, splitTunnel: 1 };

                this.RS485GetUCISections("vpnconfig1", "vpnconfig1").then(function (rv) {

                        var keys = Object.keys(rv);
                        var keysLength = keys.length;

                        if (keysLength >= 5) {
                                L.ui.showAlert(
                                        'warning',
                                        'Limit Reached',
                                        'You can configure up to 5 IPSEC connections only.'
                                );

                        }
                        else {

                                self.RS485CreateUCISection("vpnconfig1", "vpnconfig1", RS485ConfigSectionName, sensorSectionOptions).then(function (rv) {
                                        if (rv) {
                                                if (rv.section) {
                                                        self.RS485CommitUCISection("vpnconfig1").then(function (res) {

                                                                if (res != 0) {
                                                                        alert("Error:New Event Configuration");
                                                                }
                                                                else {
                                                                        location.reload();
                                                                }
                                                        });
                                                };
                                        };
                                });
                        }
                });
        },


        openvpnConfigSectionAdd: function () {
                debugger
                var self = this;

                var openvpnConfigSectionName = $('#field_firewall_rule_NewRule_name').val();
                var openvpnConfigSectionrole = $('#field_openvpn_Role').val();


                var openvpnConfigSection = { name: openvpnConfigSectionName, enable: '1', bridge: '0', role1: openvpnConfigSectionrole };


                this.RS485GetUCISections("openvpn", "openvpn1", openvpnConfigSection).then(function (rv) {
                        var keys = Object.keys(rv);

                        var keysLength = keys.length;
                        if (keysLength >= 10) {
                                L.ui.showAlert(
                                        'warning',
                                        'Limit Reached',
                                        'You can configure up to 10 OpenVPN connections only.'
                                );
                        }
                        else {
                                self.RS485CreateUCISection("openvpn", "openvpn1", openvpnConfigSectionName, openvpnConfigSection).then(function (rv) {
                                        if (rv) {
                                                if (rv.section) {
                                                        self.RS485CommitUCISection("openvpn").then(function (res) {
                                                                if (res != 0) {
                                                                        alert("Error:New Event Configuration");
                                                                }
                                                                else {
                                                                        location.reload();
                                                                }
                                                        });
                                                };
                                        };
                                });
                        }
                });
        },

        wireguardConfigSectionAdd: function () {
                debugger
                var self = this;

                var wireguardConfigSectionName = $('#field_wireguard_Name').val();
                var wireguardConfigSectionRole = $('#field_wireguard_Role').val();

                var wireguardConfigSection = {
                        name: wireguardConfigSectionName,
                        role: wireguardConfigSectionRole,
                        disabled: '0',
                        proto: "wireguard"
                };

                this.RS485GetUCISections("wireguard", "wireguard", wireguardConfigSection).then(function (rv) {
                        var keys = Object.keys(rv);
                        var keysLength = keys.length;
                        var serverCount = 0;

                        keys.forEach(function (key) {
                                if (rv[key].role === 'SERVER') {
                                        serverCount++;
                                }
                        });

                        var maxConnections = 0;
                        if (wireguardConfigSectionRole === 'SERVER') {
                                maxConnections = 5 - serverCount; // Maximum 5 connections in total
                        } else if (wireguardConfigSectionRole === 'CLIENT') {
                                maxConnections = 5;
                        }

                        if (keysLength >= maxConnections) {
                                L.ui.showAlert(
                                        'warning',
                                        'Limit Reached',
                                        `You can configure up to ${maxConnections} Wireguard connections only.`
                                );

                        } else {
                                self.RS485CreateUCISection("wireguard", "wireguard", wireguardConfigSectionName, wireguardConfigSection).then(function (rv) {
                                        if (rv && rv.section) {
                                                self.RS485CommitUCISection("wireguard").then(function (res) {
                                                        if (res != 0) {
                                                                alert("Error: New Event Configuration");
                                                        } else {
                                                                location.reload();
                                                        }
                                                });
                                        }
                                });
                        }
                });
        },

        zerotierConfigSectionAdd: function () {
                debugger
                var self = this;

                var zerotierConfigSectionName = $('#field_firewall_rule2').val();

                var zerotierConfigSection = { name: zerotierConfigSectionName, enabled: '1' };

                this.RS485GetUCISections("zerotier", "zerotier", zerotierConfigSection).then(function (rv) {
                        var keys = Object.keys(rv);

                        var keysLength = keys.length;
                        if (keysLength >= 5) {
                                L.ui.showAlert(
                                        'warning',
                                        'Limit Reached',
                                        `You can configure up to 5 Zerotier connections only.`
                                );
                        }
                        else {
                                self.RS485CreateUCISection("zerotier", "zerotier", zerotierConfigSectionName, zerotierConfigSection).then(function (rv) {
                                        if (rv) {
                                                if (rv.section) {
                                                        self.RS485CommitUCISection("zerotier").then(function (res) {
                                                                if (res != 0) {
                                                                        alert("Error:New Event Configuration");
                                                                }
                                                                else {
                                                                        location.reload();
                                                                }
                                                        });
                                                };
                                        };
                                });
                        }
                });
        },


        pptpdConfigSectionAdd: function () {
                debugger
                var self = this;
                var pptpdConfigSectionName = $('#field_PPTPD_rule_name').val();
                var pptpdConfigSectionRole = $('#field_PPTPD_rule_Role').val();

                var pptpdConfigSection = {
                        name: pptpdConfigSectionName,
                        type: pptpdConfigSectionRole,
                        enabled: '1'
                };

                this.RS485GetUCISections("pptp_i_config", "service", pptpdConfigSection).then(function (rv) {
                        var keys = Object.keys(rv);
                        var keysLength = keys.length;
                        var serverCount = 0;

                        keys.forEach(function (key) {
                                if (rv[key].type === 'SERVER') {
                                        serverCount++;
                                }
                        });

                        if (pptpdConfigSectionRole === 'SERVER' && serverCount >= 1) {

                                L.ui.showAlert(
                                        'warning',
                                        'Limit Reached',
                                        'You can configure up to "One" PPTP SERVER  connections only.'
                                );
                                return; // Stop further execution
                        }

                        var maxConnections = 0;
                        if (pptpdConfigSectionRole === 'SERVER') {
                                maxConnections = 5 - serverCount; // Maximum 5 connections in total
                        } else if (pptpdConfigSectionRole === 'CLIENT') {
                                maxConnections = 5;
                                pptpdConfigSection['proto'] = "pptp";
                                pptpdConfigSection['keepalive'] = "30 60";
                                pptpdConfigSection['defaultroute'] = "0";
                        }

                        if (keysLength >= maxConnections) {


                                L.ui.showAlert(
                                        'warning',
                                        'Limit Reached',
                                        `You can configure up to ${maxConnections} PPTP connections only.`
                                );

                        } else {
                                self.RS485CreateUCISection("pptp_i_config", "service", pptpdConfigSectionName, pptpdConfigSection).then(function (rv) {
                                        if (rv && rv.section) {
                                                self.RS485CommitUCISection("pptp_i_config").then(function (res) {
                                                        if (res != 0) {
                                                                alert("Error: New Event Configuration");
                                                        } else {
                                                                location.reload();
                                                        }
                                                });
                                        }
                                });
                        }
                });
        },

        l2tpConfigSectionAdd: function () {
                debugger
                var self = this;
                var l2tpConfigSectionName = $('#field_L2TP_rule_name').val();
                var l2tpConfigSectionRole = $('#field_L2TP_rule_Role').val();

                var l2tpConfigSection = {
                        name: l2tpConfigSectionName,
                        type: l2tpConfigSectionRole,
                        enabled: '1'
                };

                this.RS485GetUCISections("L2TP", "servicel2tp", l2tpConfigSection).then(function (rv) {
                        var keys = Object.keys(rv);
                        var keysLength = keys.length;
                        var serverCount = 0;

                        keys.forEach(function (key) {
                                if (rv[key].type === 'SERVER') {
                                        serverCount++;
                                }
                        });

                        if (l2tpConfigSectionRole === 'SERVER' && serverCount >= 1) {

                                L.ui.showAlert(
                                        'warning',
                                        'Limit Reached',
                                        'You can configure up to "One" L2TP SERVER  connections only.'
                                );
                                return; // Stop further execution
                        }

                        var maxConnections = 0;
                        if (l2tpConfigSectionRole === 'SERVER') {
                                maxConnections = 1;
                        } else if (l2tpConfigSectionRole === 'CLIENT') {
                                maxConnections = 10;
                                l2tpConfigSection['proto'] = "l2tp";
                                l2tpConfigSection['keepalive'] = "30 60";
                        }

                        if (keysLength >= maxConnections) {

                                L.ui.showAlert(
                                        'warning',
                                        'Limit Reached',
                                        `You can configure up to ${maxConnections} L2TP connections only.`
                                );

                        } else {
                                self.RS485CreateUCISection("L2TP", "servicel2tp", l2tpConfigSectionName, l2tpConfigSection).then(function (rv) {
                                        if (rv && rv.section) {
                                                self.RS485CommitUCISection("L2TP").then(function (res) {
                                                        if (res != 0) {
                                                                alert("Error: New Event Configuration");
                                                        } else {
                                                                location.reload();
                                                        }
                                                });
                                        }
                                });
                        }
                });
        },

        GreConfigSectionAdd: function () {
                debugger
                var self = this;
                var GreConfigSectionName = $('#field_NewEvent_name_gre').val();
                var GreConfigSection = { tunnelname: GreConfigSectionName };

                this.RS485GetUCISections("greconfig", "greconfig", GreConfigSectionName, GreConfigSection).then(function (rv) {
                        var keys = Object.keys(rv);
                        var keysLength = keys.length;
                        if (keysLength >= 5) {
                                L.ui.showAlert(
                                        'warning',
                                        'Limit Reached',
                                        'You can configure up to 5 GRE connections only.'
                                );

                        }
                        else {
                                self.RS485CreateUCISection("greconfig", "greconfig", GreConfigSectionName, GreConfigSection).then(function (rv) {
                                        if (rv) {
                                                if (rv.section) {
                                                        self.RS485CommitUCISection("greconfig").then(function (res) {
                                                                if (res != 0) {
                                                                        alert("Error:New Event Configuration");
                                                                }
                                                                else {
                                                                        document.cookie = "LastActiveTab=TabIP";
                                                                        document.cookie = "LastAction=add";
                                                                        location.reload();
                                                                }
                                                        });
                                                };
                                        };
                                });
                        }
                });
        },

        ipipConfigSectionAdd: function () {
                var self = this;
                var ipipConfigSectionName = $('#field_NewEvent_name_ipip').val();
                var ipipConfigSection = { tunnelname: ipipConfigSectionName };
                this.RS485GetUCISections("ipipconfig", "ipipconfig", ipipConfigSectionName, ipipConfigSection).then(function (rv) {
                        var keys = Object.keys(rv);
                        var keysLength = keys.length;
                        if (keysLength >= 5) {

                                L.ui.showAlert(
                                        'warning',
                                        'Limit Reached',
                                        'You can configure up to 5 IPIP connections only.'
                                );

                        }
                        else {
                                self.RS485CreateUCISection("ipipconfig", "ipipconfig", ipipConfigSectionName, ipipConfigSection).then(function (rv) {
                                        if (rv) {
                                                if (rv.section) {
                                                        self.RS485CommitUCISection("ipipconfig").then(function (res) {
                                                                if (res != 0) {
                                                                        alert("Error:New Event Configuration");
                                                                }
                                                                else {
                                                                        document.cookie = "LastActiveTab=TabIPa";
                                                                        document.cookie = "LastAction=add";
                                                                        location.reload();
                                                                }
                                                        });
                                                };
                                        };
                                });
                        }
                });
        },

        RS485ConfigSectionRemove: function (ev) {
                var self = ev.data.self;
                var RS485ConfigSectionName = ev.data.RS485ConfigSectionName;
                var infoIpsec = `${RS485ConfigSectionName} IPSEC`
                L.ui.confirmDelete(ev, infoIpsec, function (res) {
                        if (res === 1) {
                                self.RS485DeleteUCISection("vpnconfig1", "vpnconfig1", RS485ConfigSectionName).then(function (rv) {
                                        if (rv == 0) {
                                                self.RS485CommitUCISection("vpnconfig1").then(function (res) {
                                                        if (res != 0) {
                                                                alert("Error: Delete Configuration");
                                                        }
                                                        else {
                                                                setTimeout(function () {
                                                                        location.reload();
                                                                }, 1500);

                                                        }
                                                });
                                        };
                                });

                        }
                })
        },

        openvpnConfigSectionRemove: function (ev) {

                var self = ev.data.self;
                var openvpnConfigSectionName = ev.data.openvpnConfigSectionName;
                var infoOpenVPN = `both the certificate and configuration for ${openvpnConfigSectionName}`

                L.ui.confirmDelete(ev, infoOpenVPN, function (res) {
                        if (res === 1) {
                                self.deletecertficates(openvpnConfigSectionName).then(function () {
                                });
                                self.RS485DeleteUCISection("openvpn", "openvpn1", openvpnConfigSectionName).then(function (rv) {
                                        if (rv == 0) {
                                                self.RS485CommitUCISection("openvpn").then(function (res) {
                                                        if (res != 0) {
                                                                alert("Error: Delete Configuration");
                                                        }
                                                        else {
                                                                setTimeout(function () {
                                                                        location.reload();
                                                                }, 1500);
                                                        }
                                                });
                                        };
                                });
                        }
                });

        },

        wireguardConfigSectionRemove: function (ev) {
                var self = ev.data.self;
                var wireguardConfigSectionName = ev.data.wireguardConfigSectionName;
                var infoWireguard = `${wireguardConfigSectionName} Wireguard`

                L.ui.confirmDelete(ev, infoWireguard, function (res) {
                        if (res === 1) {
                                self.deletewireguardconfig(wireguardConfigSectionName).then(function () {

                                        self.RS485DeleteUCISection("wireguard", "wireguard", wireguardConfigSectionName).then(function (rv) {
                                                if (rv == 0) {
                                                        self.RS485CommitUCISection("wireguard").then(function (res) {
                                                                if (res != 0) {
                                                                        alert("Error: Delete Configuration");
                                                                }
                                                                else {
                                                                        setTimeout(function () {
                                                                                location.reload();
                                                                        }, 1500)

                                                                }
                                                        });
                                                };
                                        });
                                });

                        }
                });


        },
        zerotierConfigSectionRemove: function (ev) {
                var self = ev.data.self;
                var zerotierConfigSectionName = ev.data.zerotierConfigSectionName;
                var infozerotier = `${zerotierConfigSectionName} Zerotier`
                L.ui.confirmDelete(ev, infozerotier, function (res) {
                        if (res === 1) {
                                self.RS485DeleteUCISection("zerotier", "zerotier", zerotierConfigSectionName).then(function (rv) {
                                        if (rv == 0) {
                                                self.RS485CommitUCISection("zerotier").then(function (res) {
                                                        if (res != 0) {
                                                                alert("Error: Delete Configuration");
                                                        }
                                                        else {
                                                                setTimeout(function () {
                                                                        location.reload();
                                                                }, 1500)

                                                        }
                                                });
                                        };
                                });
                        }
                })


        },

        pptpdConfigSectionRemove: function (ev) {
                var self = ev.data.self;
                var pptpdConfigSectionName = ev.data.pptpdConfigSectionName;
                var infopptp = `${pptpdConfigSectionName} PPTP`

                L.ui.confirmDelete(ev, infopptp, function (res) {
                        if (res === 1) {
                                self.RS485DeleteUCISection("pptp_i_config", "service", pptpdConfigSectionName).then(function (rv) {
                                        if (rv == 0) {
                                                self.RS485CommitUCISection("pptp_i_config").then(function (res) {
                                                        if (res != 0) {
                                                                alert("Error: Delete Configuration");
                                                        }
                                                        else {
                                                                setTimeout(function () {
                                                                        location.reload();
                                                                }, 1500)

                                                        }
                                                });
                                        };
                                });
                        }
                })




        },

        l2tpConfigSectionRemove: function (ev) {
                var self = ev.data.self;
                var l2tpConfigSectionName = ev.data.l2tpConfigSectionName;
                var infoL2tp = `${l2tpConfigSectionName} L2TP`
                L.ui.confirmDelete(ev, infoL2tp, function (res) {
                        if (res === 1) {
                                self.RS485DeleteUCISection("L2TP", "servicel2tp", l2tpConfigSectionName).then(function (rv) {
                                        if (rv == 0) {
                                                self.RS485CommitUCISection("L2TP").then(function (res) {
                                                        if (res != 0) {
                                                                alert("Error: Delete Configuration");
                                                        }
                                                        else {
                                                                setTimeout(function () {
                                                                        location.reload();
                                                                }, 1500)
                                                        }
                                                });
                                        };
                                });

                        }
                });



        },

        GreConfigSectionRemove: function (ev) {
                var self = ev.data.self;
                var GreConfigSectionName = ev.data.GreConfigSectionName;
                var infoGre = `${GreConfigSectionName} GRE`
                L.ui.confirmDelete(ev, infoGre, function (res) {
                        if (res === 1) {
                                self.deletegreconfig('delete').then(function (rv) {
                                        self.RS485DeleteUCISection("greconfig", "greconfig", GreConfigSectionName).then(function (rv) {
                                                if (rv == 0) {
                                                        self.RS485CommitUCISection("greconfig").then(function (res) {
                                                                if (res != 0) {
                                                                        alert("Error: Delete Configuration");
                                                                }
                                                                else {
                                                                        document.cookie = "LastActiveTab=TabIP";
                                                                        document.cookie = "LastAction=delete";
                                                                        setTimeout(function () {
                                                                                location.reload();
                                                                        }, 1500)
                                                                }
                                                        });
                                                };
                                        });
                                });
                        }
                });

        },

        ipipConfigSectionRemove: function (ev) {
                var self = ev.data.self;
                var ipipConfigSectionName = ev.data.ipipConfigSectionName;
                var infoipip = `${ipipConfigSectionName} IPIP`
                L.ui.confirmDelete(ev, infoipip, function (res) {
                        if (res === 1) {
                                self.deleteipipconfig('delete').then(function (rv) {
                                        self.RS485DeleteUCISection("ipipconfig", "ipipconfig", ipipConfigSectionName).then(function (rv) {
                                                if (rv == 0) {
                                                        self.RS485CommitUCISection("ipipconfig").then(function (res) {
                                                                if (res != 0) {
                                                                        alert("Error: Delete Configuration");
                                                                }
                                                                else {
                                                                        document.cookie = "LastActiveTab=TabIPa";
                                                                        document.cookie = "LastAction=delete";
                                                                        setTimeout(function () {
                                                                                location.reload();
                                                                        }, 1500)
                                                                }
                                                        });
                                                };
                                        });
                                });

                        }
                })

        },



        RS485ConfigSectionEdit: function (ev) {
                var self = ev.data.self;
                var RS485ConfigSectionName = ev.data.RS485ConfigSectionName;
                return self.RS485ConfigCreateForm(L.cbi.Modal, RS485ConfigSectionName).show();
        },

        openvpnConfigSectionEdit: function (ev) {
                var self = ev.data.self;
                var openvpnConfigSectionName = ev.data.openvpnConfigSectionName;

                return self.openvpnConfigCreateForm(L.cbi.Modal, openvpnConfigSectionName).show();
        },

        wireguardConfigSectionEdit: function (ev) {
                var self = ev.data.self;
                var wireguardConfigSectionName = ev.data.wireguardConfigSectionName;
                return self.wireguardConfigCreateForm(L.cbi.Modal, wireguardConfigSectionName).show();
        },
        zerotierConfigSectionEdit: function (ev) {
                var self = ev.data.self;
                var zerotierConfigSectionName = ev.data.zerotierConfigSectionName;
                return self.zerotierConfigCreateForm(L.cbi.Modal, zerotierConfigSectionName).show();
        },
        pptpdConfigSectionEdit: function (ev) {
                var self = ev.data.self;
                var pptpdConfigSectionName = ev.data.pptpdConfigSectionName;
                return self.pptpdConfigCreateForm(L.cbi.Modal, pptpdConfigSectionName).show();
        },
        l2tpConfigSectionEdit: function (ev) {
                var self = ev.data.self;
                var l2tpConfigSectionName = ev.data.l2tpConfigSectionName;
                return self.l2tpConfigCreateForm(L.cbi.Modal, l2tpConfigSectionName).show();
        },

        GreConfigSectionEdit: function (ev) {
                var self = ev.data.self;
                var GreConfigSectionName = ev.data.GreConfigSectionName;
                return self.GreConfigCreateForm(L.cbi.Modal, GreConfigSectionName).show();
        },


        ipipConfigSectionEdit: function (ev) {
                var self = ev.data.self;
                var ipipConfigSectionName = ev.data.ipipConfigSectionName;
                return self.ipipConfigCreateForm(L.cbi.Modal, ipipConfigSectionName).show();
        },


        execute: function () {

                var self = this;
                L.ui.createNote(
                        null,
                        'MPPE encryption settings need to be the same across all simultaneously enabled connections.',
                        { type: 'muted', variant: 'inline', appendTo: '#PPTP-Note' }
                );
                L.ui.createNote(
                        'NOTE',
                        'To apply changes immediately, please click the Update button in the respective VPN tab. Otherwise, reboot the board after making your changes.',
                        { type: 'warn', variant: 'inline', appendTo: '#Update-VPN-Note' }
                );


                var m = new L.cbi.Map('vpnconfig1', {
                });

                var s = m.section(L.cbi.NamedSection, 'general', {
                        caption: L.tr('General Configurations')
                });


                s.option(L.cbi.CheckboxValue, 'enableipsecgeneral', {
                        caption: L.tr('Enable IPSEC'),
                        optional: true
                });

                s.option(L.cbi.CheckboxValue, 'enableopenvpngeneral', {
                        caption: L.tr('Enable Openvpn'),
                        optional: true
                });

                s.option(L.cbi.CheckboxValue, 'enablewireguardgeneral', {
                        caption: L.tr('Enable Wireguard'),
                        optional: true
                });
                s.option(L.cbi.CheckboxValue, 'enablezerotiergeneral', {
                        caption: L.tr('Enable Zerotier'),
                        optional: true
                });
                s.option(L.cbi.CheckboxValue, 'enablepptpgeneral', {
                        caption: L.tr('Enable PPTP'),
                        optional: true
                });

                s.option(L.cbi.CheckboxValue, 'enableL2TPgeneral', {
                        caption: L.tr('Enable L2TP'),
                        optional: true
                });

                s.option(L.cbi.CheckboxValue, 'enablegre', {
                        caption: L.tr('Enable GRE Tunnel'),
                        optional: true
                });

                s.option(L.cbi.CheckboxValue, 'enableipip', {
                        caption: L.tr('Enable IPIP Tunnel'),
                        optional: true
                });




                m.insertInto('#section_vpn_general');

                var m1 = new L.cbi.Map('vpnconfig1', {
                });

                var s1 = m1.section(L.cbi.NamedSection, 'pptp', {
                        caption: L.tr('PPTP Configurations')
                });
                //openvpn
                $('#AddNewconnectionopenvpn').click(function () {
                        self.openvpnConfigSectionAdd();
                });
                self.RS485GetUCISections("openvpn", "openvpn1").then(function (rv) {
                        //alert("print2");
                        //alert(rv);
                        self.openvpnRenderContents(rv);
                });

                //wireguard
                $('#AddNewconnectionwireguard').click(function () {
                        self.wireguardConfigSectionAdd();
                });
                self.RS485GetUCISections("wireguard", "wireguard").then(function (rv) {
                        self.wireguardRenderContents(rv);
                });

                //zerotier
                $('#AddNewconnectionzerotier').click(function () {
                        self.zerotierConfigSectionAdd();
                });
                self.RS485GetUCISections("zerotier", "zerotier").then(function (rv) {
                        self.zerotierRenderContents(rv);
                });

                //PPTPD
                $('#AddNewconnectionpptpd').click(function () {
                        self.pptpdConfigSectionAdd();
                });
                self.RS485GetUCISections("pptp_i_config", "service").then(function (rv) {
                        self.pptpdRenderContents(rv);
                });

                //L2TP
                $('#AddNewconnectionl2tp').click(function () {
                        self.l2tpConfigSectionAdd();
                });
                self.RS485GetUCISections("L2TP", "servicel2tp").then(function (rv) {
                        self.l2tpRenderContents(rv);
                });

                ////////////////////// Tunnels ?//////////////////////////

                $('#AddNewconnectiongre').click(function () {
                        self.GreConfigSectionAdd();
                });
                self.RS485GetUCISections("greconfig", "greconfig").then(function (rv) {
                        self.GreRenderContents(rv);
                });

                //ipip
                $('#AddNewconnectionipip').click(function () {
                        self.ipipConfigSectionAdd();
                });
                self.RS485GetUCISections("ipipconfig", "ipipconfig").then(function (rv) {
                        self.IPIPRenderContents(rv);
                });

                ////////////////////// Tunnels ?//////////////////////////

                //PPTP

                s1.option(L.cbi.InputValue, 'pptpserver', {
                        caption: L.tr('Server'),
                }).depends({ 'enablepptp': '1' });

                s1.option(L.cbi.InputValue, 'pptpuser', {
                        caption: L.tr('User'),
                }).depends({ 'enablepptp': '1' });

                s1.option(L.cbi.PasswordValue, 'pptppassword', {
                        caption: L.tr('Password'),
                        optional: true
                }).depends({ 'enablepptp': '1' });

                m1.insertInto('#section_pptp');

                var self = this;
                $('#AddNewconnectionipsec').click(function () {
                        self.RS485ConfigSectionAdd();
                });
                //  self.RS485GetUCISections("vpnconfig1","RS485Config").then(function(rv) {
                self.RS485GetUCISections("vpnconfig1", "vpnconfig1").then(function (rv) {
                        self.RS485RenderContents(rv);
                });

                ///////////////////////////UpdateButton//////////////////////////////////////////////////////////////// 

                update = function (e) {
                        var nameofrpcdfile = ""
                        //var names
                        if (e == "ipsec") {
                                //alert("Update IPSEC")
                                nameofrpcdfile = "updatefirewallconfig"
                        }
                        else if (e == "openvpn") {
                                //alert("Update OPENVPN")
                                nameofrpcdfile = "startopenvpnservice"
                        }
                        else if (e == "wireguard") {
                                //alert("Update Wireguard")
                                nameofrpcdfile = "updatewireguard"
                        }
                        else if (e == "zerotier") {
                                //alert("Update Zerotire")
                                nameofrpcdfile = "updatezerotier"
                        }
                        else if (e == "pptpd") {
                                //alert("Update PPTPD")
                                nameofrpcdfile = "updatepptpd"
                        }
                        else if (e == "L2TP") {
                                //alert("Update xl2tpd")
                                nameofrpcdfile = "updatexl2tpd"
                        }
                        else if (e == "greconfig") {
                                //alert("Update xl2tpd")
                                nameofrpcdfile = "updategreconfig"
                        }
                        else if (e == "ipipconfig") {
                                //alert("Update xl2tpd")
                                nameofrpcdfile = "updateipipconfig"
                        }
                        L.ui.loading(true);
                        self[nameofrpcdfile]('configure').then(function (rv) {
                                L.ui.loading(false);
                                if (e == "L2TP") {
                                        L.ui.showAlert(
                                                'success',
                                                'Update Complete',
                                                'L2TP Configurations Updated successfully'
                                        );
                                } else {
                                        L.ui.showAlert(
                                                'success',
                                                'Update Complete',
                                                rv + 'd successfully'
                                        );
                                }




                                setTimeout(function () {
                                        location.reload();
                                }, 1500);
                        });
                }


                /////////////////////////////////////////Enable&DisableButton/////////////////////////////////////////////////////////////

                wireguardenablebutton = function (n) {
                        var checkbox = $("#wireguardforwardingstatusSwitch" + n)[0].checked
                        var faileditdata = configdata1();
                        var failName = Object.keys(faileditdata)[n]
                        var failsensorSectionOptions = { disabled: "0" };
                        if (checkbox) {
                                document.getElementById("wireguardforwardingstatusSwitch" + n).checked = true;
                                failsensorSectionOptions = { disabled: "0" };
                        }
                        else {
                                document.getElementById("wireguardforwardingstatusSwitch" + n).checked = false;
                                failsensorSectionOptions = { disabled: "1" };
                        }
                        self.RS485CreateUCISection("wireguard", "wireguard", failName, failsensorSectionOptions).then(function (rv) {
                                if (rv) {
                                        if (rv.section) {
                                                self.RS485CommitUCISection("wireguard").then(function (res) {
                                                        if (res != 0) {
                                                                alert("Error:New Event Configuration");
                                                        }
                                                        else {
                                                                location.reload();
                                                        }
                                                });
                                        };
                                };
                        });
                }


                zerotierenablebutton = function (n) {
                        var checkbox = $("#zerotierforwardingstatusSwitch" + n)[0].checked
                        var faileditdata = configdata3();
                        var failName = Object.keys(faileditdata)[n]
                        var failsensorSectionOptions = { enabled: "0" };
                        if (checkbox) {
                                document.getElementById("zerotierforwardingstatusSwitch" + n).checked = true;
                                failsensorSectionOptions = { enabled: "1" };
                        }
                        else {
                                document.getElementById("zerotierforwardingstatusSwitch" + n).checked = false;
                                failsensorSectionOptions = { enabled: "0" };
                        }
                        self.RS485CreateUCISection("zerotier", "zerotier", failName, failsensorSectionOptions).then(function (rv) {
                                if (rv) {
                                        if (rv.section) {
                                                self.RS485CommitUCISection("zerotier").then(function (res) {
                                                        if (res != 0) {
                                                                alert("Error:New Event Configuration");
                                                        }
                                                        else {
                                                                location.reload();
                                                        }
                                                });
                                        };
                                };
                        });
                }

                pptpdenablebutton = function (n) {
                        var checkbox = $("#pptpdforwardingstatusSwitch" + n)[0].checked
                        var faileditdata = configdata4();
                        var failName = Object.keys(faileditdata)[n]
                        var failsensorSectionOptions = { enabled: "0" };
                        if (checkbox) {
                                document.getElementById("pptpdforwardingstatusSwitch" + n).checked = true;
                                failsensorSectionOptions = { enabled: "1" };
                        }
                        else {
                                document.getElementById("pptpdforwardingstatusSwitch" + n).checked = false;
                                failsensorSectionOptions = { enabled: "0" };
                        }
                        self.RS485CreateUCISection("pptp_i_config", "service", failName, failsensorSectionOptions).then(function (rv) {
                                if (rv) {
                                        if (rv.section) {
                                                self.RS485CommitUCISection("pptp_i_config").then(function (res) {
                                                        if (res != 0) {
                                                                alert("Error:New Event Configuration");
                                                        }
                                                        else {
                                                                location.reload();
                                                        }
                                                });
                                        };
                                };
                        });
                }


                l2tpenablebutton = function (n) {
                        var checkbox = $("#l2tpforwardingstatusSwitch" + n)[0].checked
                        var faileditdata = configdata5();
                        var failName = Object.keys(faileditdata)[n]
                        var failsensorSectionOptions = { enabled: "0" };
                        if (checkbox) {
                                document.getElementById("l2tpforwardingstatusSwitch" + n).checked = true;
                                failsensorSectionOptions = { enabled: "1" };
                        }
                        else {
                                document.getElementById("l2tpforwardingstatusSwitch" + n).checked = false;
                                failsensorSectionOptions = { enabled: "0" };
                        }
                        self.RS485CreateUCISection("L2TP", "servicel2tp", failName, failsensorSectionOptions).then(function (rv) {
                                if (rv) {
                                        if (rv.section) {
                                                self.RS485CommitUCISection("L2TP").then(function (res) {
                                                        if (res != 0) {
                                                                alert("Error:New Event Configuration");
                                                        }
                                                        else {
                                                                location.reload();
                                                        }
                                                });
                                        };
                                };
                        });
                }


                ipsecenablebutton = function (n) {
                        var checkbox = $("#ipsecforwardingstatusSwitch" + n)[0].checked
                        var ipsecdata = configdata2();
                        var ipsecName = Object.keys(ipsecdata)[n]
                        var ipsecsensorSectionOptions = { connectionenable: "0" };
                        if (checkbox) {
                                document.getElementById("ipsecforwardingstatusSwitch" + n).checked = true;
                                ipsecsensorSectionOptions = { connectionenable: "1" };
                        }
                        else {
                                document.getElementById("ipsecforwardingstatusSwitch" + n).checked = false;
                                ipsecsensorSectionOptions = { connectionenable: "0" };
                        }
                        self.RS485CreateUCISection("vpnconfig1", "vpnconfig1", ipsecName, ipsecsensorSectionOptions).then(function (rv) {
                                if (rv) {
                                        if (rv.section) {
                                                self.RS485CommitUCISection("vpnconfig1").then(function (res) {
                                                        if (res != 0) {
                                                                alert("Error:New Event Configuration");
                                                        }
                                                        else {
                                                                location.reload();
                                                        }
                                                });
                                        };
                                };
                        });
                }

                openvpnenablebutton = function (n) {
                        var checkbox = $("#openvpnforwardingstatusSwitch" + n)[0].checked
                        var porteditdata = configdata();

                        var portName = Object.keys(porteditdata)[n]

                        var sensorSectionOptions = { enable: "0" };
                        if (checkbox) {
                                document.getElementById("openvpnforwardingstatusSwitch" + n).checked = true;
                                sensorSectionOptions = { enable: "1" };

                        }
                        else {
                                document.getElementById("openvpnforwardingstatusSwitch" + n).checked = false;
                                sensorSectionOptions = { enable: "0" };

                        }
                        self.RS485CreateUCISection("openvpn", "openvpn1", portName, sensorSectionOptions).then(function (rv) {
                                if (rv) {
                                        if (rv.section) {
                                                self.RS485CommitUCISection("openvpn").then(function (res) {
                                                        if (res != 0) {
                                                                alert("Error:New Event Configuration");
                                                        }
                                                        else {
                                                                location.reload();
                                                        }
                                                });
                                        };
                                };
                        });
                }



        }


});




