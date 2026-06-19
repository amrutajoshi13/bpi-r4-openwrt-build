L.ui.view.extend({

    title: L.tr('Cloud Configuration'),

    RunUdev: L.rpc.declare({
        object: 'command',
        method: 'exec',
        params: ['command', 'args'],
    }),

    fGetUCISections: L.rpc.declare({
        object: 'uci',
        method: 'get',
        // params: [ 'config', 'type', 'section']  
        params: ['config', 'type']

    }),

    GetUCISections: L.rpc.declare({
        object: 'uci',
        method: 'get',
        params: ['config', 'type'],
        expect: { values: {} }
    }),

    deletekeyfile: L.rpc.declare({
        object: 'rpc-cloudconfig',
        method: 'delete',
        params: ['serverNumber'],
        expect: { output: '' }
    }),

    countcertficates: L.rpc.declare({
        object: 'rpc-cloudconfig',
        method: 'countkeyfiles',
        params: ['serverNumber'],
        expect: { output: '' }
    }),

    countcertficates2: L.rpc.declare({
        object: 'rpc-cloudconfig',
        method: 'countkeyfiles',
        expect: { output: '' }
    }),

    updatecloudconfig: L.rpc.declare({
        object: 'rpc-cloudconfig',
        method: 'configure',
        params: ['application', 'action'],
        expect: { output: '' }
    }),

    updatenmsdisableconfig: L.rpc.declare({
        object: 'rpc-cloudconfig',
        method: 'update',
        params: ['application', 'action'],
        expect: { output: '' }
    }),

    countkeys: L.rpc.declare({
        object: 'rpc-cloudconfig',
        method: 'countkeyfiles',
        expect: { output: '' }
    }),

    TestArchive: L.rpc.declare({
        object: 'rpc-cloudconfig',
        method: 'testarchive',
        params: ['archive', 'serverNumber'],
    }),

    GetUCISections: L.rpc.declare({
        object: 'uci',
        method: 'get',
        params: ['config', 'type'],
        expect: { values: {} }
    }),


    handleArchiveUpload: function () {
        var self = this;
        L.ui.archiveUploadcertstls(
            L.tr('File Upload'),
            L.tr('Select the file and click on "%s" button to proceed.').format(L.tr('Apply')), {
            path: "/root/SenderAppComponent/etc/certs/",
            success: function (info) {
                self.handleArchiveVerify(info);
            }
        }
        );
    },

    handleArchiveVerify: function (info) {
        var self = this;
        var archive = $('[name=filename]').val();

        console.log(archive);
        // if((checksumval == info.checksum) &&(sizeval == info.size)) {
        L.ui.loading(true);
        self.TestArchive(archive, "server1").then(function (TestArchiveOutput) {

            L.ui.dialog(
                L.tr('TestArchive'), [
                $('<p />').text(L.tr('Success')),
                $('<pre />')
                    .addClass('alert-success')
                    .text("file uploaded successfully")
            ], {
                style: 'close',

            }
            );
            L.ui.loading(false);
        });
        //}

    },


    // second server //

    handleArchiveUpload1: function () {
        var self = this;
        L.ui.archiveUploadcertstls2(
            L.tr('File Upload'),
            L.tr('Select the file and click on "%s" button to proceed.').format(L.tr('Apply')), {
            path: "/root/SenderAppComponent/etc/certs2/",
            success: function (info) {
                self.handleArchiveVerify1(info);
            }
        }
        );
    },

    handleArchiveVerify1: function (info) {
        var self = this;
        var archive = $('[name=filename]').val();
        console.log(archive);

        // if((checksumval == info.checksum) &&(sizeval == info.size)) {
        L.ui.loading(true);
        self.TestArchive(archive, "server2").then(function (TestArchiveOutput) {

            L.ui.dialog(
                L.tr('TestArchive'), [
                $('<p />').text(L.tr('Success')),
                $('<pre />')
                    .addClass('alert-success')
                    .text("file uploaded successfully")
            ], {
                style: 'close',

            }
            );
            L.ui.loading(false);
        });
        //}

    },



    execute: function () {
        var self = this;
        var m = new L.cbi.Map('cloudconfig', {
            caption: L.tr('')
        });

        var s = m.section(L.cbi.NamedSection, 'cloudconfig', {
            caption: L.tr('Cloud Configuration')
        });
        var _server_Selected = "";
        var _auth_mode_server_1 = "";
        var _protocol_server_1 = "";
        var _auth_mode_server_2 = "";
        var _protocol_server_2 = "";
        var _enable_mqtt_value = "";
        var _enable_value = "";
        var _enable_mqtt_value2 = "";
        var _enable_value2 = "";
        // var s1 = m.section(L.cbi.NamedSection, 'cloudconfig', {
        //     caption: L.tr('')
        // });


        s.option(L.cbi.InputValue, 'SiteID', {
            caption: L.tr('Site ID'),
        });

        s.option(L.cbi.ListValue, 'server', {
            caption: L.tr('Server'),
            datatype: function (ev) {
                _server_Selected = ev[0];
            }
        }).value("primary", L.tr('Only Primary'))
            .value("both", L.tr('Both - Primary and Secondary'))
            .value("fallback", L.tr('Primary Fallback to Secondary'));


        //s.option(L.cbi.CheckboxValue, 'slaveDataSending', {
            //caption: L.tr('Enable Per Slave Data Sending')
        //})



        /* HTTP */

        s.option(L.cbi.DummyValue, 'server1', {
            caption: L.tr(''),
        }).depends({ 'server': 'primary' })
            .depends({ 'server': 'both' })
            .depends({ 'server': 'fallback' })
            .ucivalue = function () {
                var id = "<h3><b>&nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbspPrimary Server Configuration</b> </h3>";
                return id;
            };


        s.option(L.cbi.ListValue, 'cloudprotocol', {
            caption: L.tr('Cloud / Protocol'),
            datatype: function (ev) {
                console.log(ev);
                _auth_mode_server_1 = ev[0];
                _protocol_server_1 = (_auth_mode_server_1 === 'm') ? '1' : '0';

            }


        }).value("http", L.tr('HTTP'))
            .value("mqtt", L.tr('MQTT'))



        s.option(L.cbi.InputValue, 'HTTPServerURL', {
            caption: L.tr('HTTP URL'),

        }).depends({ 'server': 'primary', 'cloudprotocol': 'http' })
            .depends({ 'server': 'both', 'cloudprotocol': 'http' })
            .depends({ 'server': 'fallback', 'cloudprotocol': 'http' });

        s.option(L.cbi.InputValue, 'HTTPServerPort', {
            caption: L.tr('HTTP Port (Optional)'),
            optional: 'true',
            datatype: 'portrange',
        }).depends({ 'server': 'primary', 'cloudprotocol': 'http' })
            .depends({ 'server': 'both', 'cloudprotocol': 'http' })
            .depends({ 'server': 'fallback', 'cloudprotocol': 'http' });

        s.option(L.cbi.ComboBox, 'contentType', {
            caption: L.tr('Content Type')
        })
            .depends({ 'server': 'both', 'cloudprotocol': 'http' })
            .depends({ 'server': 'primary', 'cloudprotocol': 'http' })
            .depends({ 'server': 'fallback', 'cloudprotocol': 'http' })
            .value("application/json", L.tr("application/json"))
            .value("application/x-www-form-urlencoded", L.tr("application/x-www-form-urlencoded"))
            .value("text/plain; charset=UTF-8", L.tr("text/plain; charset=UTF-8"));


        //s.option(L.cbi.CheckboxValue, 'httpauthenable', {
        //caption: L.tr('Enable Authentication')
        //}).depends({ 'server': 'primary', 'cloudprotocol': 'http' })
        //.depends({ 'server': 'both', 'cloudprotocol': 'http' })
        //.depends({ 'server': 'fallback', 'cloudprotocol': 'http' });


        s.option(L.cbi.ListValue, 'httpauthenable', {
            caption: L.tr('Enable Authentication'),
        }).depends({ 'server': 'primary', 'cloudprotocol': 'http' })
            .depends({ 'server': 'both', 'cloudprotocol': 'http' })
            .depends({ 'server': 'fallback', 'cloudprotocol': 'http' })
            .value("0", L.tr('No Authentication'))
            .value("1", L.tr('Username/Password'))
            .value("2", L.tr('Bearer Token'));




        s.option(L.cbi.InputValue, 'username', {
            caption: L.tr('Username'),
        }).depends({ 'server': 'primary', 'cloudprotocol': 'http', 'httpauthenable': '1' })
            .depends({ 'server': 'both', 'cloudprotocol': 'http', 'httpauthenable': '1' })
            .depends({ 'server': 'fallback', 'cloudprotocol': 'http', 'httpauthenable': '1' });

        s.option(L.cbi.PasswordValue, 'password', {
            caption: L.tr('Password'),
        }).depends({ 'server': 'primary', 'cloudprotocol': 'http', 'httpauthenable': '1' })
            .depends({ 'server': 'both', 'cloudprotocol': 'http', 'httpauthenable': '1' })
            .depends({ 'server': 'fallback', 'cloudprotocol': 'http', 'httpauthenable': '1' });


        s.option(L.cbi.InputValue, 'entertoken', {
            caption: L.tr('Token'),
        }).depends({ 'server': 'primary', 'cloudprotocol': 'http', 'httpauthenable': '2' })
            .depends({ 'server': 'both', 'cloudprotocol': 'http', 'httpauthenable': '2' })
            .depends({ 'server': 'fallback', 'cloudprotocol': 'http', 'httpauthenable': '2' });


        s.option(L.cbi.CheckboxValue, 'serverresponsevalidationenable', {
            caption: L.tr('Enable Server Response Validation')
        }).depends({ 'server': 'primary', 'cloudprotocol': 'http' })
            .depends({ 'server': 'both', 'cloudprotocol': 'http' })
            .depends({ 'server': 'fallback', 'cloudprotocol': 'http' });

        s.option(L.cbi.ComboBox, 'serverresponsestring', {
            caption: L.tr('Server Response'),
        }).depends({ 'server': 'primary', 'cloudprotocol': 'http', 'serverresponsevalidationenable': '1' })
            .depends({ 'server': 'both', 'cloudprotocol': 'http', 'serverresponsevalidationenable': '1' })
            .depends({ 'server': 'fallback', 'cloudprotocol': 'http', 'serverresponsevalidationenable': '1' })
            .value("none", L.tr('--please choose--'))
            .value("Recordid", L.tr('RecordID'));

        s.option(L.cbi.ListValue, 'HTTPMethod', {
            caption: L.tr('Method'),
        }).depends({ 'server': 'primary', 'cloudprotocol': 'http' })
            .depends({ 'server': 'both', 'cloudprotocol': 'http' })
            .depends({ 'server': 'fallback', 'cloudprotocol': 'http' })
            .value("0", L.tr('Post'))
            .value("1", L.tr('Get'));

        s.option(L.cbi.CheckboxValue, 'EnableMQTTCommand', {
            caption: L.tr('Enable mqtt command cloud'),
            datatype: function (ev) {
                console.log(ev);
                _enable_value = ev[1];
                _enable_mqtt_value = (_enable_value === 'n') ? '1' : '0';

            }

        }).depends({ 'server': 'primary', 'cloudprotocol': 'http' })
            .depends({ 'server': 'both', 'cloudprotocol': 'http' })
            .depends({ 'server': 'fallback', 'cloudprotocol': 'http' });



        /* MQTT */


        s.option(L.cbi.InputValue, 'host', {
            caption: L.tr('MQTT Host'),

        }).depends({ 'cloudprotocol': 'http', 'EnableMQTTCommand': '1' })
            .depends({ 'server': 'primary', 'cloudprotocol': 'mqtt' })
            .depends({ 'server': 'both', 'cloudprotocol': 'mqtt' })
            .depends({ 'server': 'fallback', 'cloudprotocol': 'mqtt' });

        s.option(L.cbi.InputValue, 'mqttport', {
            caption: L.tr('MQTT Port'),
            optional: 'true',
            datatype: 'portrange',
        }).depends({ 'cloudprotocol': 'http', 'EnableMQTTCommand': '1' })
            .depends({ 'server': 'primary', 'cloudprotocol': 'mqtt' })
            .depends({ 'server': 'both', 'cloudprotocol': 'mqtt' })
            .depends({ 'server': 'fallback', 'cloudprotocol': 'mqtt' });




        //s.option(L.cbi.CheckboxValue, 'enable_loopforever', {
            //caption: L.tr('Enable LoopForEver')
        //}).depends({ 'cloudprotocol': 'mqtt' })
            //.depends({ 'server': 'primary', 'cloudprotocol': 'mqtt' })
            //.depends({ 'server': 'both', 'cloudprotocol': 'mqtt' })
            //.depends({ 'server': 'fallback', 'cloudprotocol': 'mqtt' });

        s.option(L.cbi.CheckboxValue, 'enable_subcribe_topic', {
            caption: L.tr('Enable Subscribe Topic')
        }).depends({ 'cloudprotocol': 'mqtt' })
            .depends({ 'server': 'primary', 'cloudprotocol': 'mqtt' })
            .depends({ 'server': 'both', 'cloudprotocol': 'mqtt' })
            .depends({ 'server': 'fallback', 'cloudprotocol': 'mqtt' });

        s.option(L.cbi.CheckboxValue, 'enable_clientID', {
            caption: L.tr('Enable ClientId')
        }).depends({ 'cloudprotocol': 'http', 'EnableMQTTCommand': '1' })
            .depends({ 'server': 'primary', 'cloudprotocol': 'mqtt' })
            .depends({ 'server': 'both', 'cloudprotocol': 'mqtt' })
            .depends({ 'server': 'fallback', 'cloudprotocol': 'mqtt' });

        s.option(L.cbi.InputValue, 'ClientID', {
            caption: L.tr('ClientID'),
        }).depends({ 'server': 'primary', 'cloudprotocol': 'mqtt', 'enable_clientID': '1' })
            .depends({ 'server': 'both', 'cloudprotocol': 'mqtt', 'enable_clientID': '1' })
            .depends({ 'server': 'fallback', 'cloudprotocol': 'mqtt', 'enable_clientID': '1' })
            .depends({ 'server': 'primary', 'cloudprotocol': 'http', 'EnableMQTTCommand': '1', 'enable_clientID': '1' })
            .depends({ 'server': 'both', 'cloudprotocol': 'http', 'EnableMQTTCommand': '1', 'enable_clientID': '1' })
            .depends({ 'server': 'fallback', 'cloudprotocol': 'http', 'EnableMQTTCommand': '1', 'enable_clientID': '1' });

     

        s.option(L.cbi.ListValue, 'subqos', {
            caption: L.tr('Subscribe QOS')
        }).depends({ 'cloudprotocol': 'http', 'EnableMQTTCommand': '1' })
            .depends({ 'server': 'primary', 'cloudprotocol': 'mqtt' })
            .depends({ 'server': 'both', 'cloudprotocol': 'mqtt' })
            .depends({ 'server': 'fallback', 'cloudprotocol': 'mqtt' })
            .value("2", L.tr("2"))
            .value("1", L.tr("1"))
            .value("0", L.tr("0"));

        s.option(L.cbi.ListValue, 'qos', {
            caption: L.tr('Publish QOS')
        }).depends({ 'cloudprotocol': 'http', 'EnableMQTTCommand': '1' })
            .depends({ 'server': 'primary', 'cloudprotocol': 'mqtt' })
            .depends({ 'server': 'both', 'cloudprotocol': 'mqtt' })
            .depends({ 'server': 'fallback', 'cloudprotocol': 'mqtt' })
            .value("2", L.tr("2"))
            .value("1", L.tr("1"))
            .value("0", L.tr("0"));




        s.option(L.cbi.ListValue, 'mqttauthmode', {
            caption: L.tr('Authentication Mode'),
            datatype: function (ev) {
                console.log(ev);
                _auth_mode_server_1 = ev[0];
                console.log(_enable_mqtt_value)
                if (_protocol_server_1 === '1' || _enable_mqtt_value === '1') {

                    if (_auth_mode_server_1 === '1' || _auth_mode_server_1 === '0' || _auth_mode_server_1 === '4') {
                        document.getElementById('Certificates_section').style.display = "block";
                        document.getElementById('server_1').style.display = "block";
                    } else if (_auth_mode_server_1 === '2' || _auth_mode_server_1 === '3') {
                        document.getElementById('server_1').style.display = "none";

                    }
                } else if (_protocol_server_2 === '1' && _protocol_server_1 === '0') {
                    document.getElementById('server_1').style.display = "none";
                } else {
                    document.getElementById('Certificates_section').style.display = "none";
                    document.getElementById('server_1').style.display = "none";
                }
            }

        }).depends({ 'cloudprotocol': 'http', 'EnableMQTTCommand': '1' })
            .depends({ 'cloudprotocol': 'mqtt' })
            .value("3", L.tr('No Authentication'))
            .value("2", L.tr('Username/Password'))
            .value("1", L.tr('User Name & Password with CA certificate'))
            .value("0", L.tr('TLS'))
            .value("4", L.tr('User Name & Password with TLS certificate'));


        s.option(L.cbi.InputValue, 'mqttusername', {
            caption: L.tr('Username'),
        }).depends({ 'server': 'primary', 'cloudprotocol': 'mqtt', 'mqttauthmode': '1' })
            .depends({ 'server': 'primary', 'cloudprotocol': 'mqtt', 'mqttauthmode': '4' })
            .depends({ 'server': 'both', 'cloudprotocol': 'mqtt', 'mqttauthmode': '1' })
            .depends({ 'server': 'both', 'cloudprotocol': 'mqtt', 'mqttauthmode': '4' })
            .depends({ 'server': 'primary', 'cloudprotocol': 'mqtt', 'mqttauthmode': '2' })
            .depends({ 'server': 'both', 'cloudprotocol': 'mqtt', 'mqttauthmode': '2' })
            .depends({ 'server': 'fallback', 'cloudprotocol': 'mqtt', 'mqttauthmode': '2' })
            .depends({ 'server': 'fallback', 'cloudprotocol': 'mqtt', 'mqttauthmode': '4' })
            .depends({ 'server': 'fallback', 'cloudprotocol': 'mqtt', 'mqttauthmode': '1' })
            .depends({ 'server': 'primary', 'cloudprotocol': 'http', 'EnableMQTTCommand': '1', 'mqttauthmode': '1' })
            .depends({ 'server': 'primary', 'cloudprotocol': 'http', 'EnableMQTTCommand': '1', 'mqttauthmode': '4' })
            .depends({ 'server': 'both', 'cloudprotocol': 'http', 'EnableMQTTCommand': '1', 'mqttauthmode': '1' })
            .depends({ 'server': 'both', 'cloudprotocol': 'http', 'EnableMQTTCommand': '1', 'mqttauthmode': '4' })
            .depends({ 'server': 'primary', 'cloudprotocol': 'http', 'EnableMQTTCommand': '1', 'mqttauthmode': '2' })
            .depends({ 'server': 'both', 'cloudprotocol': 'http', 'EnableMQTTCommand': '1', 'mqttauthmode': '2' })
            .depends({ 'server': 'fallback', 'cloudprotocol': 'http', 'EnableMQTTCommand': '1', 'mqttauthmode': '2' })
            .depends({ 'server': 'fallback', 'cloudprotocol': 'http', 'EnableMQTTCommand': '1', 'mqttauthmode': '4' })
            .depends({ 'server': 'fallback', 'cloudprotocol': 'http', 'EnableMQTTCommand': '1', 'mqttauthmode': '1' });


        s.option(L.cbi.PasswordValue, 'mqttpassword', {
            caption: L.tr('Password'),
            optional: 'true',
        })
            .depends({ 'server': 'primary', 'cloudprotocol': 'mqtt', 'mqttauthmode': '1' })
            .depends({ 'server': 'both', 'cloudprotocol': 'mqtt', 'mqttauthmode': '1' })
            .depends({ 'server': 'both', 'cloudprotocol': 'mqtt', 'mqttauthmode': '4' })
            .depends({ 'server': 'primary', 'cloudprotocol': 'mqtt', 'mqttauthmode': '4' })
            .depends({ 'server': 'primary', 'cloudprotocol': 'mqtt', 'mqttauthmode': '2' })
            .depends({ 'server': 'both', 'cloudprotocol': 'mqtt', 'mqttauthmode': '2' })
            .depends({ 'server': 'fallback', 'cloudprotocol': 'mqtt', 'mqttauthmode': '4' })
            .depends({ 'server': 'fallback', 'cloudprotocol': 'mqtt', 'mqttauthmode': '2' })
            .depends({ 'server': 'fallback', 'cloudprotocol': 'mqtt', 'mqttauthmode': '1' })
            .depends({ 'server': 'primary', 'cloudprotocol': 'http', 'EnableMQTTCommand': '1', 'mqttauthmode': '1' })
            .depends({ 'server': 'both', 'cloudprotocol': 'http', 'EnableMQTTCommand': '1', 'mqttauthmode': '1' })
            .depends({ 'server': 'both', 'cloudprotocol': 'http', 'EnableMQTTCommand': '1', 'mqttauthmode': '4' })
            .depends({ 'server': 'primary', 'cloudprotocol': 'http', 'EnableMQTTCommand': '1', 'mqttauthmode': '4' })
            .depends({ 'server': 'primary', 'cloudprotocol': 'http', 'EnableMQTTCommand': '1', 'mqttauthmode': '2' })
            .depends({ 'server': 'both', 'cloudprotocol': 'http', 'EnableMQTTCommand': '1', 'mqttauthmode': '2' })
            .depends({ 'server': 'fallback', 'cloudprotocol': 'http', 'EnableMQTTCommand': '1', 'mqttauthmode': '4' })
            .depends({ 'server': 'fallback', 'cloudprotocol': 'http', 'EnableMQTTCommand': '1', 'mqttauthmode': '2' })
            .depends({ 'server': 'fallback', 'cloudprotocol': 'http', 'EnableMQTTCommand': '1', 'mqttauthmode': '1' });

        s.option(L.cbi.CheckboxValue, 'enablepublishoverlan', {
            caption: L.tr('Enable Publish Over LAN')
        }).depends({ 'server': 'primary', 'cloudprotocol': 'mqtt' })
            .depends({ 'server': 'both', 'cloudprotocol': 'mqtt' })
            .depends({ 'server': 'fallback', 'cloudprotocol': 'mqtt' })
            .depends({ 'server': 'primary', 'cloudprotocol': 'http', 'EnableMQTTCommand': '1' })
            .depends({ 'server': 'both', 'cloudprotocol': 'http', 'EnableMQTTCommand': '1' })
            .depends({ 'server': 'fallback', 'cloudprotocol': 'http', 'EnableMQTTCommand': '1' });



        /* Azure */



        s.option(L.cbi.ListValue, 'Selectprotocol', {
            caption: L.tr('Protocol'),

        }).depends({ 'server': 'primary', 'cloudprotocol': 'azure' })
            .depends({ 'server': 'both', 'cloudprotocol': 'azure' })
            .depends({ 'server': 'fallback', 'cloudprotocol': 'azure' })
            .value("MQTT_Protocol", L.tr('MQTT'))
            .value("HTTP_Protocol", L.tr('HTTP'));


        s.option(L.cbi.InputValue, 'connectionstring', {
            caption: L.tr('Connection String'),

        }).depends({ 'server': 'primary', 'cloudprotocol': 'azure' })
            .depends({ 'server': 'both', 'cloudprotocol': 'azure' })
            .depends({ 'server': 'fallback', 'cloudprotocol': 'azure' });




        /* HTTP 2*/

        s.option(L.cbi.DummyValue, 'server2', {
            caption: L.tr(''),
        }).depends({ 'server': 'both' })
            .depends({ 'server': 'fallback' })
            .ucivalue = function () {
                var id = "<h3><b>&nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbspSecondary Server Configuration</b> </h3>";
                return id;
            };



        s.option(L.cbi.ListValue, 'cloudprotocol2', {
            caption: L.tr('Cloud / Protocol'),
            datatype: function (ev) {
                console.log(ev);
                _auth_mode_server_2 = ev[0];
                _protocol_server_2 = (_auth_mode_server_2 === 'm') ? '1' : '0';

            }
        }).depends({ 'server': 'both' })
            .depends({ 'server': 'fallback' })
            .value("http", L.tr('HTTP'))
            .value("mqtt", L.tr('MQTT'))
        //   .value("azure", L.tr('Azure'));




        s.option(L.cbi.InputValue, 'HTTPServerURL2', {
            caption: L.tr('HTTP URL Server 2'),

        }).depends({ 'server': 'both', 'cloudprotocol2': 'http' })
            .depends({ 'server': 'fallback', 'cloudprotocol2': 'http' });

        s.option(L.cbi.InputValue, 'HTTPServerPort2', {
            caption: L.tr('HTTP Port (Optional) 2'),
            optional: 'true',
            datatype: 'portrange',
        }).depends({ 'server': 'both', 'cloudprotocol2': 'http' })
            .depends({ 'server': 'fallback', 'cloudprotocol2': 'http' });

        //s.option(L.cbi.CheckboxValue, 'httpauthenable2', {
        //caption: L.tr('Enable Authentication 2')
        //}).depends({ 'server': 'both', 'cloudprotocol2': 'http' })
        //.depends({ 'server': 'fallback', 'cloudprotocol2': 'http' });


        s.option(L.cbi.ComboBox, 'contentType2', {
            caption: L.tr('Content Type 2')
        })
            .depends({ 'server': 'both', 'cloudprotocol2': 'http' })
            .depends({ 'server': 'fallback', 'cloudprotocol2': 'http' })
            .value("application/json", L.tr("application/json"))
            .value("application/x-www-form-urlencoded", L.tr("application/x-www-form-urlencoded"))
            .value("text/plain; charset=UTF-8", L.tr("text/plain; charset=UTF-8"));



        s.option(L.cbi.ListValue, 'httpauthenable2', {
            caption: L.tr('Enable Authentication 2'),
        }).depends({ 'server': 'both', 'cloudprotocol2': 'http' })
            .depends({ 'server': 'fallback', 'cloudprotocol2': 'http' })
            .value("0", L.tr('No Authentication'))
            .value("1", L.tr('Username/Password'))
            .value("2", L.tr('Bearer Token'));




        s.option(L.cbi.InputValue, 'username2', {
            caption: L.tr('Username 2'),
        })
            .depends({ 'server': 'both', 'cloudprotocol2': 'http', 'httpauthenable2': '1' })
            .depends({ 'server': 'fallback', 'cloudprotocol2': 'http', 'httpauthenable2': '1' });

        s.option(L.cbi.PasswordValue, 'password2', {
            caption: L.tr('Password 2'),
        }).depends({ 'server': 'both', 'cloudprotocol2': 'http', 'httpauthenable2': '1' })
            .depends({ 'server': 'fallback', 'cloudprotocol2': 'http', 'httpauthenable2': '1' });

        s.option(L.cbi.InputValue, 'entertoken2', {
            caption: L.tr('Token 2'),
        }).depends({ 'server': 'both', 'cloudprotocol2': 'http', 'httpauthenable2': '2' })
            .depends({ 'server': 'fallback', 'cloudprotocol2': 'http', 'httpauthenable2': '2' });

        s.option(L.cbi.CheckboxValue, 'serverresponsevalidationenable2', {
            caption: L.tr('Enable Server Response Validation 2')
        }).depends({ 'server': 'both', 'cloudprotocol2': 'http' })
            .depends({ 'server': 'fallback', 'cloudprotocol2': 'http' });

        s.option(L.cbi.ComboBox, 'serverresponsestring2', {
            caption: L.tr('Server Response 2'),
        }).depends({ 'server': 'both', 'cloudprotocol2': 'http', 'serverresponsevalidationenable2': '1' })
            .depends({ 'server': 'fallback', 'cloudprotocol2': 'http', 'serverresponsevalidationenable2': '1' })
            .value("none", L.tr('--please choose--'))
            .value("Recordid", L.tr('RecordID'));

        s.option(L.cbi.ListValue, 'HTTPMethod2', {
            caption: L.tr('Method 2'),
        }).depends({ 'server': 'both', 'cloudprotocol2': 'http' })
            .depends({ 'server': 'fallback', 'cloudprotocol2': 'http' })
            .value("0", L.tr('Post'))
            .value("1", L.tr('Get'));

        s.option( L.cbi.CheckboxValue, 'EnableMQTTCommand2', {
        caption: L.tr('Enable mqtt command cloud'),
        datatype: function (ev) {
                console.log(ev);
                _enable_value2 = ev[1];
                _enable_mqtt_value2 = (_enable_value2 === 'n') ? '1' : '0';

            }
        }).depends({ 'server': 'both', 'cloudprotocol2': 'http' })
        .depends({ 'server': 'fallback', 'cloudprotocol2': 'http' });

        /* MQTT 2*/


        s.option(L.cbi.InputValue, 'host2', {
            caption: L.tr('MQTT Host 2'),

        }).depends({ 'server': 'both', 'cloudprotocol2': 'mqtt' })
            .depends({ 'server': 'fallback', 'cloudprotocol2': 'mqtt' });

        s.option(L.cbi.InputValue, 'mqttport2', {
            caption: L.tr('MQTT Port 2'),
            optional: 'true',
            datatype: 'portrange',
        }).depends({ 'server': 'both', 'cloudprotocol2': 'mqtt' })
            .depends({ 'server': 'fallback', 'cloudprotocol2': 'mqtt' });
            
            
           

        //s.option(L.cbi.CheckboxValue, 'enable_loopforever_1', {
            //caption: L.tr('Enable LoopForEver 2')
        //}).depends({ 'server': 'both', 'cloudprotocol2': 'mqtt' })
            //.depends({ 'server': 'fallback', 'cloudprotocol2': 'mqtt' });
  
        s.option(L.cbi.CheckboxValue, 'enable_subcribe_topic_1', {
            caption: L.tr('Enable Subscribe Topic 2')
        }).depends({ 'server': 'both', 'cloudprotocol2': 'mqtt' })
            .depends({ 'server': 'fallback', 'cloudprotocol2': 'mqtt' });

        s.option(L.cbi.CheckboxValue, 'enable_clientID_1', {
            caption: L.tr('Enable ClientId 2')
        }).depends({ 'server': 'both', 'cloudprotocol2': 'mqtt' })
            .depends({ 'server': 'fallback', 'cloudprotocol2': 'mqtt' });


        s.option(L.cbi.InputValue, 'ClientID_1', {
            caption: L.tr('ClientID 2'),
        }).depends({ 'server': 'both', 'cloudprotocol2': 'mqtt', 'enable_clientID_1': '1' })
            .depends({ 'server': 'fallback', 'cloudprotocol2': 'mqtt', 'enable_clientID_1': '1' });


        s.option(L.cbi.ListValue, 'subqos2', {
            caption: L.tr('Subscribe QOS 2')
        }).depends({ 'server': 'both', 'cloudprotocol2': 'mqtt' })
            .depends({ 'server': 'fallback', 'cloudprotocol2': 'mqtt' })
            .value("2", L.tr("2"))
            .value("1", L.tr("1"))
            .value("0", L.tr("0"));
        s.option(L.cbi.ListValue, 'qos2', {
            caption: L.tr('Publish QOS 2')
        }).depends({ 'server': 'both', 'cloudprotocol2': 'mqtt' })
            .depends({ 'server': 'fallback', 'cloudprotocol2': 'mqtt' })
            .value("2", L.tr("2"))
            .value("1", L.tr("1"))
            .value("0", L.tr("0"));




        // var enableTable2 = "";
        s.option(L.cbi.ListValue, 'mqttauthmode2', {
            caption: L.tr('Authentication Mode 2'),
            datatype: function (ev) {
                console.log(ev);
                _auth_mode_server_2 = ev[0];
                if (_server_Selected === 'p') {
                    document.getElementById('server_2').style.display = "none";

                } else {
                    if (_protocol_server_2 === '1' || _enable_mqtt_value2==='1') {
                        if (_auth_mode_server_2 === '1' || _auth_mode_server_2 === '0' || _auth_mode_server_2 === '4') {
                            document.getElementById('Certificates_section').style.display = "block";
                            document.getElementById('server_2').style.display = "block";
                        } else if (_auth_mode_server_2 === '2' || _auth_mode_server_2 === '3') {
                            document.getElementById('server_2').style.display = "none";
                        }
                    } else if (_protocol_server_1 === '1' && _protocol_server_2 === '0') {
                        document.getElementById('server_2').style.display = "none";
                    } else {
                        document.getElementById('Certificates_section').style.display = "none";
                        document.getElementById('server_2').style.display = "none";
                    }

                }


            }
        }).depends({ 'server': 'both', 'cloudprotocol2': 'mqtt' })
            .depends({ 'server': 'fallback', 'cloudprotocol2': 'mqtt' })      
            //.depends({ 'server': 'both', 'cloudprotocol2': 'http','EnableMQTTCommand2' : '1'})
            //.depends({ 'server': 'fallback', 'cloudprotocol2': 'http','EnableMQTTCommand2' : '1' })
            .value("3", L.tr('No Authentication'))
            .value("2", L.tr('Username/Password'))
            .value("1", L.tr('User Name & Password with CA certificate'))
            .value("0", L.tr('TLS'))
            .value("4", L.tr('User Name & Password with TLS certificate'));

        s.option(L.cbi.InputValue, 'mqttusername2', {
            caption: L.tr('Username 2'),
        }).depends({ 'server': 'both', 'cloudprotocol2': 'mqtt', 'mqttauthmode2': '1' })
            .depends({ 'server': 'both', 'cloudprotocol2': 'mqtt', 'mqttauthmode2': '4' })
            .depends({ 'server': 'both', 'cloudprotocol2': 'mqtt', 'mqttauthmode2': '2' })
            .depends({ 'server': 'fallback', 'cloudprotocol2': 'mqtt', 'mqttauthmode2': '2' })
            .depends({ 'server': 'fallback', 'cloudprotocol2': 'mqtt', 'mqttauthmode2': '4' })
            .depends({ 'server': 'fallback', 'cloudprotocol2': 'mqtt', 'mqttauthmode2': '1' });

        s.option(L.cbi.PasswordValue, 'mqttpassword2', {
            caption: L.tr('Password 2'),
            optional: 'true',
        }).depends({ 'server': 'both', 'cloudprotocol2': 'mqtt', 'mqttauthmode2': '1' })
            .depends({ 'server': 'both', 'cloudprotocol2': 'mqtt', 'mqttauthmode2': '2' })
            .depends({ 'server': 'both', 'cloudprotocol2': 'mqtt', 'mqttauthmode2': '4' })
            .depends({ 'server': 'fallback', 'cloudprotocol2': 'mqtt', 'mqttauthmode2': '4' })
            .depends({ 'server': 'fallback', 'cloudprotocol2': 'mqtt', 'mqttauthmode2': '2' })
            .depends({ 'server': 'fallback', 'cloudprotocol2': 'mqtt', 'mqttauthmode2': '1' });

        s.option(L.cbi.CheckboxValue, 'enablepublishoverlan2', {
            caption: L.tr('Enable Publish Over LAN 2')
        }).depends({ 'server': 'both', 'cloudprotocol2': 'mqtt' })
            .depends({ 'server': 'fallback', 'cloudprotocol2': 'mqtt' });




        /* Azure 2 */


        s.option(L.cbi.ListValue, 'Selectprotocol2', {
            caption: L.tr('Protocol Server 2'),

        }).depends({ 'server': 'both', 'cloudprotocol2': 'azure' })
            .depends({ 'server': 'fallback', 'cloudprotocol2': 'azure' })
            .value("MQTT_Protocol", L.tr('MQTT'))
            .value("HTTP_Protocol", L.tr('HTTP'));


        s.option(L.cbi.InputValue, 'connectionstring2', {
            caption: L.tr('Connection String Server 2'),

        }).depends({ 'server': 'both', 'cloudprotocol2': 'azure' })
            .depends({ 'server': 'fallback', 'cloudprotocol2': 'azure' });



        self.GetUCISections("sourceconfig", "sourceconfig").then(function (rv) {
            for (var key in rv) {
                if (rv.hasOwnProperty(key)) {
                    var obj = rv[key];
                    if (obj.EMeterRS485Line1DataSourceEnable === '1') {
                        enablers485 = true;
                    }

                    if (obj.EMeterRS232Line1DataSourceEnable === '1') {
                        enablers232 = true;
                    }
                    if (obj.AIODataSourceEnable === '1') {
                        enableaio = true;
                    }
                    if (obj.DIODataSourceEnable === '1') {
                        enabledio = true;
                    }
                    if (obj.TEMPERATUREDataSourceEnable === '1') {
                        enabletemperature = true;
                    }
                    if (obj.SNMPDataSourceEnable === '1') {
                        enablesnmp = true;
                    }
                    if (obj.CustomLine1DataSourceEnable === '1') {
                        enablecustom = true;
                    }
                }
            }
        });



        var rs485enable = localStorage.getItem("rs485enable")
        var rs232enable = localStorage.getItem("rs232enable")
        var aioenable = localStorage.getItem("aioenable")
        var dioenable = localStorage.getItem("dioenable")
        var temperatureenable = localStorage.getItem("temperatureenable")
        var snmpenable = localStorage.getItem("snmpenable")
        var customenable = localStorage.getItem("customenable")

        console.log(localStorage.getItem("rs485enable"));
        console.log(localStorage.getItem("rs232enable"));
        console.log(localStorage.getItem("aioenable"));
        console.log(localStorage.getItem("dioenable"));
        console.log(localStorage.getItem("temperatureenable"));
        console.log(localStorage.getItem("snmpenable"));
        console.log(localStorage.getItem("customenable"));



        // Define dependencies for Primary Server with MQTT
        var dependsPrimaryMQTT = { 'server': 'primary', 'cloudprotocol': 'mqtt' };
        var dependsPrimaryBothMQTT = { 'server': 'both', 'cloudprotocol': 'mqtt' };
        var dependsPrimaryFallbackMQTT = { 'server': 'fallback', 'cloudprotocol': 'mqtt' };
        
        // Define dependencies for Primary Server with MQTT and EnableSubscribeTopic is 1
        var dependsPrimarySubscribeMQTT = { 'server': 'primary', 'cloudprotocol': 'mqtt','enable_subcribe_topic':'1' };
        var dependsPrimaryBothSubscribeMQTT = { 'server': 'both', 'cloudprotocol': 'mqtt','enable_subcribe_topic':'1' };
        var dependsPrimaryFallbackSubscribeMQTT = { 'server': 'fallback', 'cloudprotocol': 'mqtt','enable_subcribe_topic':'1' };

        // Define dependencies for Secondary Server with MQTT in both modes
        var dependsSecondaryBothMQTT = { 'server': 'both', 'cloudprotocol2': 'mqtt' };
        var dependsSecondaryFallbackMQTT = { 'server': 'fallback', 'cloudprotocol2': 'mqtt' };
        
        // Define dependencies for Secondary Server with MQTT in both modes and EnableSubscribeTopic is 1
        var dependsSecondaryBothSubscribeMQTT = { 'server': 'both', 'cloudprotocol2': 'mqtt' ,'enable_subcribe_topic_1':'1'};
        var dependsSecondaryFallbackSubscribeMQTT = { 'server': 'fallback', 'cloudprotocol2': 'mqtt','enable_subcribe_topic_1':'1' };

        // Define dependencies for Primary Server with HTTP
        var dependsPrimaryHTTP = { 'server': 'primary', 'cloudprotocol': 'http','EnableMQTTCommand':'1' };
        var dependsPrimaryBothHTTP = { 'server': 'both', 'cloudprotocol': 'http','EnableMQTTCommand':'1'  };
        var dependsPrimaryFallbackHTTP = { 'server': 'fallback', 'cloudprotocol': 'http','EnableMQTTCommand':'1'  };

        // Define dependencies for Secondary Server with HTTP in both modes
        var dependsSecondaryBothHTTP = { 'server': 'both', 'cloudprotocol2': 'http' ,'EnableMQTTCommand2':'1' };
        var dependsSecondaryFallbackHTTP = { 'server': 'fallback', 'cloudprotocol2': 'http' ,'EnableMQTTCommand2':'1' };


        s.option(L.cbi.DummyValue, 'topicConfig', {
            caption: L.tr(''),
        }).depends(dependsPrimaryMQTT)
            .depends(dependsPrimaryBothMQTT)
            .depends(dependsPrimaryFallbackMQTT)
            .depends(dependsSecondaryBothMQTT)
            .depends(dependsSecondaryFallbackMQTT)
            .depends(dependsPrimaryHTTP)
            .depends(dependsPrimaryBothHTTP)
            .depends(dependsPrimaryFallbackHTTP)
            .depends(dependsSecondaryBothHTTP)
            .depends(dependsSecondaryFallbackHTTP)
            .ucivalue = function () {
                var id = "<h3><b>&nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbspTopic Configuration </b> </h3>";
                return id;
            };

        // Configure RS485 Topics
        if (rs485enable === '1') {
            // Primary RS485 Topic
            s.option(L.cbi.InputValue, 'rs485topic', {
                caption: L.tr('Modbus Topic 1 (Optional)'),
                optional: 'true',
                datatype: 'string',
            }).depends(dependsPrimaryMQTT)
                .depends(dependsPrimaryBothMQTT)
                .depends(dependsPrimaryFallbackMQTT)
                 .depends(dependsPrimaryHTTP)
                .depends(dependsPrimaryBothHTTP)
               .depends(dependsPrimaryFallbackHTTP);
                
            

            // Secondary RS485 Topic
            s.option(L.cbi.InputValue, 'rs485topic2', {
                caption: L.tr('Modbus Topic 2 (Optional)'),
                optional: 'true',
                datatype: 'string',
            }).depends(dependsSecondaryBothMQTT)
                .depends(dependsSecondaryFallbackMQTT)
                .depends(dependsSecondaryBothHTTP)
                .depends(dependsSecondaryFallbackHTTP);
        }

        // Configure RS232 Topics
        if (rs232enable === '1') {
            // Primary RS232 Topic
            s.option(L.cbi.InputValue, 'rs232topic', {
                caption: L.tr('RS232 Topic 1 (Optional)'),
                optional: 'true',
                datatype: 'string',
            }).depends(dependsPrimaryMQTT)
                .depends(dependsPrimaryBothMQTT)
                .depends(dependsPrimaryFallbackMQTT)
                .depends(dependsPrimaryHTTP)
                .depends(dependsPrimaryBothHTTP)
               .depends(dependsPrimaryFallbackHTTP);

            // Secondary RS232 Topic
            s.option(L.cbi.InputValue, 'rs232topic2', {
                caption: L.tr('RS232 Topic 2 (Optional)'),
                optional: 'true',
                datatype: 'string',
            }).depends(dependsSecondaryBothMQTT)
                .depends(dependsSecondaryFallbackMQTT)
                .depends(dependsSecondaryBothHTTP)
                .depends(dependsSecondaryFallbackHTTP);
        }

        // Configure AIO Topics
        if (aioenable === '1') {
            // Primary AIO Topic
            s.option(L.cbi.InputValue, 'aiotopic', {
                caption: L.tr('AIO Topic 1 (Optional)'),
                optional: 'true',
                datatype: 'string',
            }).depends(dependsPrimaryMQTT)
                .depends(dependsPrimaryBothMQTT)
                .depends(dependsPrimaryFallbackMQTT)
                .depends(dependsPrimaryHTTP)
                .depends(dependsPrimaryBothHTTP)
                .depends(dependsPrimaryFallbackHTTP);

            // Secondary AIO Topic
            s.option(L.cbi.InputValue, 'aiotopic2', {
                caption: L.tr('AIO Topic 2 (Optional)'),
                optional: 'true',
                datatype: 'string',
            }).depends(dependsSecondaryBothMQTT)
                .depends(dependsSecondaryFallbackMQTT)
                .depends(dependsSecondaryBothHTTP)
                .depends(dependsSecondaryFallbackHTTP);
        }

        // Configure DIO Topics
        if (dioenable === '1') {
            // Primary DIO Topic
            s.option(L.cbi.InputValue, 'diotopic', {
                caption: L.tr('DIO Topic 1 (Optional)'),
                optional: 'true',
                datatype: 'string',
            }).depends(dependsPrimaryMQTT)
                .depends(dependsPrimaryBothMQTT)
                .depends(dependsPrimaryFallbackMQTT)
                .depends(dependsPrimaryHTTP)
                .depends(dependsPrimaryBothHTTP)
                .depends(dependsPrimaryFallbackHTTP);

            // Secondary DIO Topic
            s.option(L.cbi.InputValue, 'diotopic2', {
                caption: L.tr('DIO Topic 2 (Optional)'),
                optional: 'true',
                datatype: 'string',
            }).depends(dependsSecondaryBothMQTT)
                .depends(dependsSecondaryFallbackMQTT)
                .depends(dependsSecondaryBothHTTP)
                .depends(dependsSecondaryFallbackHTTP);
        }
        // Configure SNMP Topics
        // if (snmpenable === '1') {
        if (snmpenable === '1') {
            // Primary SNMP Topic
            s.option(L.cbi.InputValue, 'snmptopic', {
                caption: L.tr('SNMP Topic 1 (Optional)'),
                optional: 'true',
                datatype: 'string',
            }).depends(dependsPrimaryMQTT)
                .depends(dependsPrimaryBothMQTT)
                .depends(dependsPrimaryFallbackMQTT)
                .depends(dependsPrimaryHTTP)
                .depends(dependsPrimaryBothHTTP)
                .depends(dependsPrimaryFallbackHTTP);

            // Secondary SNMP Topic
            s.option(L.cbi.InputValue, 'snmptopic2', {
                caption: L.tr('SNMP Topic 2 (Optional)'),
                optional: 'true',
                datatype: 'string',
            }).depends(dependsSecondaryBothMQTT)
                .depends(dependsSecondaryFallbackMQTT)
                .depends(dependsSecondaryBothHTTP)
                .depends(dependsSecondaryFallbackHTTP);
        }

        // Configure Custom Topics
        //if (customenable === '1') {
        if (customenable === '1') {
            // Primary Custom Topic
            s.option(L.cbi.InputValue, 'customtopic', {
                caption: L.tr('Custom Topic 1 (Optional)'),
                optional: 'true',
                datatype: 'string',
            }).depends(dependsPrimaryMQTT)
                .depends(dependsPrimaryBothMQTT)
                .depends(dependsPrimaryFallbackMQTT)
                .depends(dependsPrimaryHTTP)
                .depends(dependsPrimaryBothHTTP)
                .depends(dependsPrimaryFallbackHTTP);

            // Secondary Custom Topic
            s.option(L.cbi.InputValue, 'customtopic2', {
                caption: L.tr('Custom Topic 2 (Optional)'),
                optional: 'true',
                datatype: 'string',
            }).depends(dependsSecondaryBothMQTT)
                .depends(dependsSecondaryFallbackMQTT)
                .depends(dependsSecondaryBothHTTP)
                .depends(dependsSecondaryFallbackHTTP);
        }


        // Configure Temperature Topics
        if (temperatureenable === '1') {
            // Primary Temperature Topic
            s.option(L.cbi.InputValue, 'temperaturetopic', {
                caption: L.tr('Temperature Topic 1 (Optional)'),
                optional: 'true',
                datatype: 'string',
            }).depends(dependsPrimaryMQTT)
                .depends(dependsPrimaryBothMQTT)
                .depends(dependsPrimaryFallbackMQTT)
                .depends(dependsPrimaryHTTP)
                .depends(dependsPrimaryBothHTTP)
                .depends(dependsPrimaryFallbackHTTP);

            // Secondary Temperature Topic
            s.option(L.cbi.InputValue, 'temperaturetopic2', {
                caption: L.tr('Temperature Topic 2 (Optional)'),
                optional: 'true',
                datatype: 'string',
            }).depends(dependsSecondaryBothMQTT)
                .depends(dependsSecondaryFallbackMQTT)
                .depends(dependsSecondaryBothHTTP)
                .depends(dependsSecondaryFallbackHTTP);
        }


        // Configure Command Request Topics
        s.option(L.cbi.InputValue, 'commandrequesttopic', {
            caption: L.tr('Command Request Topic 1 (Optional)'),
            optional: 'true',
            datatype: 'string',
        }).depends(dependsPrimarySubscribeMQTT)
            .depends(dependsPrimaryBothSubscribeMQTT)
            .depends(dependsPrimaryFallbackSubscribeMQTT)
            .depends(dependsPrimaryHTTP)
            .depends(dependsPrimaryBothHTTP)
            .depends(dependsPrimaryFallbackHTTP);

        s.option(L.cbi.InputValue, 'commandrequesttopic2', {
            caption: L.tr('Command Request Topic 2 (Optional)'),
            optional: 'true',
            datatype: 'string',
        }).depends(dependsSecondaryBothSubscribeMQTT)
            .depends(dependsSecondaryFallbackSubscribeMQTT)
            .depends(dependsSecondaryBothHTTP)
            .depends(dependsSecondaryFallbackHTTP);

        // Configure Command Response Topics
        s.option(L.cbi.InputValue, 'commandresponsetopic', {
            caption: L.tr('Command Response Topic 1 (Optional)'),
            optional: 'true',
            datatype: 'string',
        }).depends(dependsPrimarySubscribeMQTT)
            .depends(dependsPrimaryBothSubscribeMQTT)
            .depends(dependsPrimaryFallbackSubscribeMQTT)
            .depends(dependsPrimaryHTTP)
                .depends(dependsPrimaryBothHTTP)
                .depends(dependsPrimaryFallbackHTTP);

        s.option(L.cbi.InputValue, 'commandresponsetopic2', {
            caption: L.tr('Command Response Topic 2 (Optional)'),
            optional: 'true',
            datatype: 'string',
        }).depends(dependsSecondaryBothSubscribeMQTT)
            .depends(dependsSecondaryFallbackSubscribeMQTT)
            .depends(dependsSecondaryBothHTTP)
                .depends(dependsSecondaryFallbackHTTP);








        $('#btn_upload').off('click').on('click', function () {
            self.countcertficates('server1').then(function (certCount) {
                if (certCount < 1) {
                    // No certificates, allow upload
                    self.handleArchiveUpload();
                } else {
                    // Show error: certificates already exist
                    L.ui.loading(false);
                    L.ui.dialog(
                        L.tr('Upload Certificates Error'), [
                        $('<p />').text(L.tr('Output')),
                        $('<pre />')
                            .addClass('alert alert-danger')
                            .text("Please click on Delete button to delete existing files and then click on upload button")
                    ],
                        {
                            style: 'close',
                            close: function () {
                                location.reload();
                            }
                        }
                    );
                }
            });
        });




        /* Test purpose end */

        $('#btn_delete').click(function () {
            self.GetUCISections("cloudconfig", "cloudconfig").then(function (rv) {
                for (var key in rv) {
                    if (rv.hasOwnProperty(key)) {
                        var obj = rv[key];
                        var enabledelete = obj.enabledelete_1;
                        var cloudprotocol = obj.cloudprotocol
                        var mqttauthmode = obj.mqttauthmode;
                        var EnableMQTTCommand = obj.EnableMQTTCommand;
                        //alert(enabledelete);
                        //alert(cloudprotocol);

                        if ((cloudprotocol == 'mqtt' && enabledelete == '1' && (mqttauthmode == '0' || mqttauthmode == '1' || mqttauthmode == '4')) || (cloudprotocol == 'http' && EnableMQTTCommand == '1' && enabledelete == '1' && (mqttauthmode == '0' || mqttauthmode == '1' || mqttauthmode == '4'))) {
                            self.deletekeyfile("server1").then(function (rv) {
                                //alert(rv);

                                L.ui.loading(false);
                                L.ui.dialog(

                                    L.tr('Delete certificates'), [
                                    $('<p />').text(L.tr('Output')),
                                    $('<pre />')
                                        .addClass('alert alert-info')
                                        .text("certificates Deleted"),
                                ],
                                    {
                                        style: 'close',
                                        close: function () {
                                            location.reload();
                                        }
                                    }
                                );
                            });
                        }
                        else {
                            var ErrorMsg = "Invalid Config";
                            $("#btn_upload").empty().show();
                            $("#btn_upload").append(ErrorMsg);

                            $("#btn_delete").empty().show();
                            $("#btn_delete").append(ErrorMsg);
                        }
                    }
                }
            });
        });



        $('#btn_upload2').off('click').on('click', function () {
            self.countcertficates('server2').then(function (rv) {
                if (rv < '1') {
                    // Directly call the upload function (no need to re-bind the click)
                    self.handleArchiveUpload1();
                } else {
                    L.ui.loading(false);
                    L.ui.dialog(
                        L.tr('Upload Certificates Error'), [
                        $('<p />').text(L.tr('Output')),
                        $('<pre />')
                            .addClass('alert alert-danger')
                            .text("Please click on Delete button to delete existing files and then click on upload button"),
                    ],
                        {
                            style: 'close',
                            close: function () {
                                location.reload();
                            }
                        }
                    );
                }
            });
        });



        /* Test purpose end */

        $('#btn_delete2').click(function () {
            self.GetUCISections("cloudconfig", "cloudconfig").then(function (rv) {
                for (var key in rv) {
                    if (rv.hasOwnProperty(key)) {
                        var obj = rv[key];
                        var enabledelete = obj.enabledelete_2;
                        var cloudprotocol = obj.cloudprotocol
                        var mqttauthmode = obj.mqttauthmode2;
                        var EnableMQTTCommand = obj.EnableMQTTCommand;
                        //alert(enabledelete);
                        //alert(cloudprotocol);

                        if ((cloudprotocol == 'mqtt' && enabledelete == '1' && (mqttauthmode == '0' || mqttauthmode == '1' || mqttauthmode == '4')) || (cloudprotocol == 'http' && EnableMQTTCommand == '1' && enabledelete == '1' && (mqttauthmode == '0' || mqttauthmode == '1' || mqttauthmode == '4'))) {
                            self.deletekeyfile("server2").then(function (rv) {
                                //alert(rv);

                                L.ui.loading(false);
                                L.ui.dialog(

                                    L.tr('Delete certificates'), [
                                    $('<p />').text(L.tr('Output')),
                                    $('<pre />')
                                        .addClass('alert alert-info')
                                        .text("certificates Deleted"),
                                ],
                                    {
                                        style: 'close',
                                        close: function () {
                                            location.reload();
                                        }
                                    }
                                );
                            });
                        }
                        else {
                            var ErrorMsg = "Invalid Config";
                            $("#btn_upload2").empty().show();
                            $("#btn_upload2").append(ErrorMsg);

                            $("#btn_delete2").empty().show();
                            $("#btn_delete2").append(ErrorMsg);
                        }
                    }
                }
            });
        });

        m.insertInto('#map');

    }
});               
