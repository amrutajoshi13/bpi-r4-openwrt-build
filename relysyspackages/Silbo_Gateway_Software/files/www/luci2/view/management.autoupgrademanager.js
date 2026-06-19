L.ui.view.extend({

    // title: L.tr('Software Upgrade'),

    fGetUCISections: L.rpc.declare({
        object: 'uci',
        method: 'get',
        params: ['config', 'type', 'section'],
    }),

    updateinterfaceconfig: L.rpc.declare({
        object: 'rpc-autoupgrade',
        method: 'configure',
        params: ['application', 'action'],
        expect: { output: '' }
    }),


    applicationmanagerupgrade: L.rpc.declare({
        object: 'rpc-applicationmanager',
        method: 'UpgradeApp',
        params: ['application', 'action'],
        expect: { output: '' }
    }),


    TestArchive: L.rpc.declare({
        object: 'rpc-applicationmanager',
        method: 'testarchive',
        params: ['archive'],
    }),

    GetUCISections: L.rpc.declare({
        object: 'uci',
        method: 'get',
        params: ['config', 'type'],
        expect: { values: {} }
    }),

    InstalledVersion: L.rpc.declare({
        object: 'rpc-upgradeversioninfo',
        method: 'installedversion',
    }),


    handleArchiveUpload: function () {
        var self = this;
        L.ui.archiveUpload(
            L.tr('Archive Upload'),
            L.tr('Select the archive and click on "%s" button to proceed.').format(L.tr('Apply')), {
            success: function (info) {
                self.handleArchiveVerify(info);
            }
        }
        );
    },

    handleArchiveVerify: function (info) {
        var self = this;
        var checksumval = $('#checksum').val();
        var sizeval = $('#size').val();
        var archive = $('[name=filename]').val();

        if ((checksumval == info.checksum) && (sizeval == info.size)) {
            L.ui.loading(true);
            self.TestArchive(archive).then(function (TestArchiveOutput) {
                L.ui.loading(false);
                L.ui.dialog(
                    L.tr('TestArchive'), [
                    $('<p />').text(L.tr('Success')),
                    $('<pre />')
                        .addClass('alert-success')
                        .text("file uploaded successfully")
                ]
                );
                L.ui.loading(true);
                self.applicationmanagerupgrade('ReAPapps', 'upgrade').then(function (rv) {
                    L.ui.loading(false);
                    L.ui.dialog(
                        L.tr('Upgrade Status'), [
                        $('<p />').text(L.tr('Status')),
                        $('<pre />')
                            .addClass('alert-success')
                            .text(rv)
                    ], {
                        style: 'close',
                        close: function () {
                            location.reload();
                        }
                    }
                    );
                });
            });
        }
        else {
            if ((checksumval != info.checksum) && (sizeval != info.size)) {
                RPCErrorMsg = "Archive checksum and size verification failed";
            }
            else if (checksumval != info.checksum) {
                RPCErrorMsg = "Archive Checksum verification failed";
            }
            else if (sizeval != info.size) {
                RPCErrorMsg = "Archive size verification failed";
            }

            L.ui.dialog(
                L.tr('verification failed'), [
                $('<p />').text(L.tr('Please enter the valid checksum and size!')),
                $('<pre />')
                    .addClass('alert-danger')
                    .text(RPCErrorMsg),
            ], {
                style: 'close',
                close: function () {
                    location.reload();
                }
            }
            );
        }

    },

    InstalledPkgsRenderContents: function (rv) {
        //alert(rv);
        var self = this;
        // var heading = $('<h3/>', {
        //     text: 'Installed Package:'
        // });

        var list = new L.ui.table({
            columns: [
                {
                    caption: L.tr('Package'),
                    width: '50%',
                    align: 'left',
                    format: function (v, n) {
                        var div = $('<p />').attr('id', 'packageName_%s'.format(n));
                        return div.append(v);
                    }
                }, {
                    caption: L.tr('Version'),
                    align: 'left',
                    width: '50%',
                    format: function (v, n) {
                        var div = $('<small />').attr('id', 'package_date_%s'.format(n));
                        return div.append(v);
                    }
                }
            ]
        });

        var firmwareversion = rv['FirmwareVersion'];
        FirmwareReleasedVersion = firmwareversion.ReleasedVersion;
        //alert(FirmwareReleasedVersion);

        var ipkversion = rv['IPKVersion'];
        IPKReleasedVersion = ipkversion.ReleasedVersion;
        //alert(IPKReleasedVersion);


        list.row([' Application', rv['FirmwareVersion']]);
        list.row([' Build', rv['IPKVersion']]);

        // list.row([' Application',  1.01]);
        //  list.row([' IPK',   1.01]);


        $('#packageInfo')
            // .append(heading)
            .append(list.render());
    },

    execute: function () {
        var self = this;

        L.ui.createNote(
            'NOTE',
            'Enter the checksum and file size, then click Upgrade to upload the TAR file and start the upgrade process.',
            { type: 'warn', variant: 'inline', appendTo: '#Update-Note-upgrade' }
        );

        var m = new L.cbi.Map('UpgradeManagerGeneric', {
        });

        var s = m.section(L.cbi.NamedSection, 'global', {
            caption: L.tr('Auto-Upgrade Configurations')
        });

        s.tab({
            id: 'clientconfig',
            caption: L.tr('Client and Server Settings')
        });

        s.taboption('clientconfig', L.cbi.CheckboxValue, 'enable', {
            caption: L.tr('Enable Auto Upgrade')
        });

        s.taboption('clientconfig', L.cbi.CheckboxValue, 'authentication', {
            caption: L.tr('Authentication')
        }).depends('enable');

        s.taboption('clientconfig', L.cbi.InputValue, 'user', {
            caption: L.tr('user name')
        }).depends(['enable', 'authentication']);

        s.taboption('clientconfig', L.cbi.PasswordValue, 'password', {
            caption: L.tr('password')
        }).depends(['enable', 'authentication']);

        s.taboption('clientconfig', L.cbi.InputValue, 'url', {
            caption: L.tr('server address')
        }).depends('enable');

        s.taboption('clientconfig', L.cbi.InputValue, 'connectiontimeout', {
            caption: L.tr('connectiontimeout'),
            datatype: 'uinteger'
        }).depends('enable');

        s.taboption('clientconfig', L.cbi.InputValue, 'operationtimeout', {
            caption: L.tr('operationtimeout'),
            datatype: 'uinteger'
        }).depends('enable');

        s.tab({
            id: 'autoupgradeinterval',
            caption: L.tr('AutoUpgrade Interval')
        });

        var MinuteVal = s.taboption('autoupgradeinterval', L.cbi.DynamicList, 'Minutes', {
            caption: L.tr('Minutes'),
            optional: true,
            listlimit: 60,
            listcustom: false
        }).depends('enable')
            .value('', L.tr('-- Please choose --'))
            .value('*', L.tr('All'));

        MinuteVal.load = function (sid) {
            var minutes = [];
            for (var i = 0; i < 60; i++)
                minutes.push(i);
            minutes.sort();
            for (var i = 0; i < minutes.length; i++)
                MinuteVal.value(i);
        };

        var HourVal = s.taboption('autoupgradeinterval', L.cbi.DynamicList, 'Hours', {
            caption: L.tr('Hours'),
            optional: true,
            listlimit: 24,
            listcustom: false,
        }).depends('enable')
            .value('', L.tr('-- Please choose --'))
            .value('*', L.tr('All'));

        HourVal.load = function (sid) {
            var hours = [];
            for (var i = 0; i < 24; i++)
                hours.push(i);
            hours.sort();
            for (var i = 0; i < hours.length; i++)
                HourVal.value(i);
        };

        var DaysVal = s.taboption('autoupgradeinterval', L.cbi.DynamicList, 'DayOfMonth', {
            caption: L.tr('Day Of Month'),
            optional: true,
            listlimit: 31,
            listcustom: false
        }).depends('enable')
            .value('', L.tr('-- Please choose --'))
            .value('*', L.tr('All'));

        DaysVal.load = function (sid) {
            var days = [];
            for (var i = 1; i <= 31; i++)
                days.push(i);
            days.sort();
            for (var i = 1; i <= days.length; i++)
                DaysVal.value(i);
        };

        s.taboption('autoupgradeinterval', L.cbi.DynamicList, 'Month', {
            caption: L.tr('Month'),
            optional: true,
            listlimit: 12,
            listcustom: false
        }).depends('enable')
            .value('*', L.tr('All'))
            .value('1', L.tr('January'))
            .value('2', L.tr('February'))
            .value('3', L.tr('March'))
            .value('4', L.tr('April'))
            .value('5', L.tr('May'))
            .value('6', L.tr('June'))
            .value('7', L.tr('July'))
            .value('8', L.tr('August'))
            .value('9', L.tr('September'))
            .value('10', L.tr('October'))
            .value('11', L.tr('November'))
            .value('12', L.tr('December'));

        s.taboption('autoupgradeinterval', L.cbi.DynamicList, 'DayOfWeek', {
            caption: L.tr('Day Of Week'),
            optional: true,
            listlimit: 12,
            listcustom: false
        }).depends('enable')
            .value('*', L.tr('All'))
            .value('0', L.tr('Sunday'))
            .value('1', L.tr('Monday'))
            .value('2', L.tr('Tuesday'))
            .value('3', L.tr('Wednesday'))
            .value('4', L.tr('Thursday'))
            .value('5', L.tr('Friday'))
            .value('6', L.tr('Saturday'));

        m.insertInto('#map');

        self.InstalledVersion().then(function (rv) {
            self.InstalledPkgsRenderContents(rv);
        });

        // self.GetUCISections("applist_config", "command").then(function (rv) {
        //     for (var key in rv) {
        //         if (rv.hasOwnProperty(key)) {
        //             var obj = rv[key];
        //             var AppStatus = obj.running;
        //             if (AppStatus != 1) {
        //                 var ErrorMsg = "Please stop the applications before upgrading";
        //                 $("#UploadDiv").empty().show();
        //                 $("#UploadDiv").append(ErrorMsg);
        //             }
        //             else {
        //                 $("#UploadDiv").show();
        //             }
        //         }
        //     }
        // });



        $('#btn_upgrade').click(function () {
            var checksumval = $('#checksum').val();
            var sizeval = $('#size').val();

            self.GetUCISections("applist_config", "command").then(function (rv) {
                var obj = rv["appconfig"];
                if ((typeof rv === "undefined") || (typeof obj === "undefined")) {
                    if ((checksumval == "") && (sizeval == "")) {
                        L.ui.showAlert("error", "Validation Error", "Please enter the checksum and file size to proceed.");

                        // alert("Please enter the valid checksum and size");
                    }
                    else if (checksumval == "") {
                        L.ui.showAlert("error", "Validation Error", "Please enter the checksum to proceed.");

                        // alert("Please enter the checksum");
                    }
                    else if (sizeval == "") {
                        L.ui.showAlert("error", "Validation Error", "Please enter the file size to proceed.");

                        // alert("Please enter the size");
                    }
                    else {
                        self.handleArchiveUpload();
                    }
                }
                else {
                    var obj = rv["appconfig"];
                    var AppRunning = obj.running;

                    if (AppRunning == 0) {
                        L.ui.showAlert("error", "Stop Application", "Upgrade cannot continue while applications are running. Stop all applications and try again.");
                        // alert("Please stop the applications before upgrading");
                        return;
                    }
                    else {
                        if ((checksumval == "") && (sizeval == "")) {
                            L.ui.showAlert("error", "Validation Error", "Please enter the checksum and file size to proceed.");
                        }
                        else if (checksumval == "") {
                            L.ui.showAlert("error", "Validation Error", "Please enter the checksum to proceed.");
                        }
                        else if (sizeval == "") {
                            L.ui.showAlert("error", "Validation Error", "Please enter the file size to proceed.");
                        }
                        else {
                            self.handleArchiveUpload();
                        }
                    }
                }
            });
        });

        //self.InstalledVersion().then(function(rv) {
        //alert(rv);
        //self.InstalledPkgsRenderContents(rv); 
        //self.GetUCISections("applist_config","command").then(function(rv){
        //for(var key in rv) {
        //if(rv.hasOwnProperty(key)) {
        //var obj=rv[key];
        //var AppStatus=obj.running;
        //if (AppStatus != 0) {
        //var ErrorMsg="Please stop the applications before upgrading";
        //$("#UploadDiv").empty().show();
        //$("#UploadDiv").append(ErrorMsg);
        //}
        //else {
        //$("#UploadDiv").show();
        //}
        //}
        //}
        //});     
        //});

        s.commit = function () {
            self.fGetUCISections('UpgradeManagerGeneric', 'autoupgradeparameters').then(function (rv) {
                self.updateinterfaceconfig('Update', 'updateautoupgrade').then(function (rv) {

                });
            });
        }

        return m.insertInto('#map');
    }
});
