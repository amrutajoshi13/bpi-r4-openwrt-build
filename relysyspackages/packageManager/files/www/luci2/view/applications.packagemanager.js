L.ui.view.extend({

    UpdateUCISection: L.rpc.declare({
        object: 'uci',
        method: 'add',
        params: ['config', 'type', 'name', 'values']
    }),

    CommitUCISection: L.rpc.declare({
        object: 'uci',
        method: 'commit',
        params: ['config']
    }),

    GetUCISections: L.rpc.declare({
        object: 'uci',
        method: 'get',
        params: ['config', 'type'],
        expect: { values: {} }
    }),

    DeleteUCISection: L.rpc.declare({
        object: 'uci',
        method: 'delete',
        params: ['config', 'type', 'section']
    }),

    installCustomPackage: L.rpc.declare({
        object: 'luci2.opkg',
        method: 'install',
        params: ['package'],
        expect: { '': {} }
    }),

    verifyPackageInstallation: L.rpc.declare({
        object: 'luci2.opkg',
        method: 'find',
        params: ['pattern'],
        expect: { '': {} }
    }),

    StartStopService: L.rpc.declare({
        object: 'luci',
        method: 'setInitAction',
        params: ['name', 'action'],
        expect: { '': {} }
    }),

    updateinterfaceconfig: L.rpc.declare({
        object: 'rpc-packagerinstall',
        method: 'configure',
        params: ['boardName', 'packageName', 'packageChecksum'],
        expect: { output: '' }
    }),

    getBoardName: L.rpc.declare({
        object: 'system',
        method: 'board',
        expect: { model: "" }
    }),

    removePackage: L.rpc.declare({
        object: 'luci2.opkg',
        method: 'remove',
        params: ['package'],
        expect: { stdout: "" }
    }),

    handlePackageInstall: function (packageName, size) {
        var self = this;
        L.ui.loading(true);
        self.installCustomPackage(packageName).then(function (res) {
            var str = res.stdout.split(" ");
            console.log(str);
            if (res.code == 0) {
                if (str[0] == "Package") {
                    alert(str[1] + " is already existing in root and up to date");
                    location.reload();
                }
                else {
                    var installedPackage = {};

                    self.verifyPackageInstallation(str[1]).then(function (rv) {

                        for (var i = 0; i < rv.total; i++) {
                            if (rv.packages[i][0] == str[1]) {
                                installedPackage['appName'] = rv.packages[i][0];
                                installedPackage['version'] = rv.packages[i][1];
                            }
                        }
                        var currentDateTime = new Date();
                        var currentDate = currentDateTime.toDateString();
                        installedPackage['installedDate'] = currentDate;
                        installedPackage['size'] = size;

                        self.UpdateUCISection("packagemanager", "package", installedPackage['appName'], installedPackage).then(function (rv) {
                            if (rv) {
                                if (rv.section) {
                                    self.CommitUCISection("packagemanager").then(function (res) {
                                        if (res == 0) {
                                            alert(installedPackage['appName'] + " installed successfully");
                                            // alert("Press 'ok' and Login again");
                                            // self.StartStopService("rpcd", "restart").then( function (res){
                                            //     if (rv.result) {
                                            //         // self.StartStopService("uhttpd", "restart").then( function (res){
                                            //         //     if (!rv.result) {
                                            //         //         alert("Please reboot the System");
                                            //         //     }
                                            //         // });
                                            //     }
                                            //     else{
                                            //         alert("Please reboot the System");
                                            //     }
                                            // });
                                            location.reload();
                                        }
                                    });
                                }
                            }
                            L.ui.loading(false);
                        });
                    });
                }
            }
            else {
                alert(str[1] + " installation failure");
                location.reload();
            }
        });
    },

    handleBackupVerify: function (packageInfo, packageName) {
        var self = this;
        L.ui.dialog(
            L.tr('Backup restore'), [
            $('<p />').text(L.tr('Enter checksum and size and then click on "Apply" to upload tar file and to start upgrade')),
            $('<div />')
                .addClass('row')
                .append($('<div />')
                    .addClass('col-sm-4')
                    .append($('<div />')
                        .addClass('form-group')
                        .append($('<label />')
                            .addClass('_fnt')
                            .text('Checksum'))
                        .append($('<input />')
                            .addClass('form-control')
                            .attr({
                                type: 'text',
                                id: 'ipkChecksum',
                                placeholder: 'Enter checksum',
                                style: 'width:250%'
                            })))
                    .append($('<div />')
                        .addClass('form-group')
                        .append($('<label />')
                            .addClass('_fnt')
                            .text('Size'))
                        .append($('<input />')
                            .addClass('form-control')
                            .attr({
                                type: 'number',
                                id: 'ipkSize',
                                placeholder: 'Enter size of file',
                                style: 'width:250%'
                            }))))
        ], {
            style: 'confirm',
            confirm: function (info) {
                var checksum = document.getElementById('ipkChecksum').value;
                var size = document.getElementById('ipkSize').value;
                if (packageInfo.checksum == checksum && packageInfo.size == size) {
                    self.handlePackageInstall(packageName, size);
                }
                else {
                    if ((checksum != packageInfo.checksum) && (size != packageInfo.size)) {
                        RPCErrorMsg = "Archive checksum and size verification failed";
                    }
                    else if (checksum != packageInfo.checksum) {
                        RPCErrorMsg = "Archive Checksum verification failed";
                    }
                    else if (size != packageInfo.size) {
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
            }
        }
        );
    },

    sectionInstall: function (ev) {
        var self = ev.data.self;
        var boardName = ev.data.boardName;
        var packageName = ev.data.packageName;
        var packageChecksum = ev.data.packageChecksum;
        var packageSize = ev.data.size;

        self.updateinterfaceconfig(boardName, packageName, packageChecksum).then(function (rv) {
            if (rv == "FAILURE : Configuration Update") {
                alert("Error : Connecting to the server Failure");
            }
            else if (rv == "FAILURE : Checksum mismatch") {
                alert("Error : Checksum mismatch");
            }
            else {
                self.handlePackageInstall(rv, packageSize);
            }

        });
    },

    sectionRemove: function (ev) {
        var self = ev.data.self;
        var packageName = ev.data.sectionName;
        L.ui.loading(true);
        self.removePackage(packageName).then(function (res) {
            L.ui.loading(false);
            var str = res.split(" ");
            if (str[0] == "Removing" || str[0] == "No") {
                self.DeleteUCISection("packagemanager", "package", packageName).then(function (rv) {
                    if (rv == 0) {
                        self.CommitUCISection("packagemanager").then(function (res) {
                            if (res != 0) {
                                alert("Error: Delete Configuration");
                            }
                            else {
                                alert(packageName + " uninstalled Successfully");
                                location.reload();
                            }
                        });
                    }
                });
            }
        });
    },

    renderInstalledApp: function (rv) {
        var self = this;
        var keys = Object.keys(rv);
        var keysLength = keys.length;

        if (keysLength == 0) {
            var noteContainer = document.createElement('div');
            noteContainer.classList.add('note');

            // Create an h2 element
            var display = document.createElement('h4');
            display.textContent = "No Apps Installed using Package Manager";

            noteContainer.appendChild(display);

            $('#installedAppSettings').append(noteContainer);
        }
        else {
            var list = new L.ui.table({
                columns: [{
                    caption: L.tr('Sl no.'),
                    format: function (v, n) {
                        var div = $('<p />').attr('id', 'slNo%s'.format(n));
                        var serialNumber = n + 1;
                        return div.append('<strong>' + serialNumber + '</strong>');
                    }
                }, {
                    caption: L.tr('App Name'),
                    format: function (v, n) {
                        var div = $('<p />').attr('id', 'appName%s'.format(n));
                        return div.append(v);
                    }
                }, {
                    caption: "Version",
                    format: function (v, n) {
                        var div = $('<p />').attr('id', 'version%s'.format(n));
                        return div.append(v);
                    }
                }, {
                    caption: "Installed Date",
                    format: function (v, n) {
                        var div = $('<p />').attr('id', 'installedDate%s'.format(n));
                        return div.append(v);
                    }
                }, {
                    caption: "Size",
                    format: function (v, n) {
                        var div = $('<p />').attr('id', 'size%s'.format(n));
                        return div.append(v);
                    }
                }, {
                    caption: L.tr('Actions'),
                    format: function (v, n) {
                        return $('<div />')
                            .addClass('btn-group btn-group-sm')
                            .append(L.ui.button(L.tr('Uninstall'), 'danger', L.tr('Uninstall the package'))
                                .click({ self: self, sectionName: v }, self.sectionRemove));
                    }
                }]
            });
            for (var key in rv) {
                if (rv.hasOwnProperty) {
                    var obj = rv[key];
                    var appName = obj.appName;
                    var version = obj.version;
                    var installedDate = obj.installedDate;
                    var size = obj.size;

                    list.row([key, appName, version, installedDate, size, key]);
                }
            }
            $('#installedAppSettings').append(list.render());
        }
    },

    renderAvailableApp: function (rv, boardName, installedAppData) {
        var self = this;
        var keys = Object.keys(rv);
        var keysLength = keys.length;

        if (keysLength == 0 || rv.error) {
            var noteContainer = document.createElement('div');
            noteContainer.classList.add('note');

            // Create an h2 element
            var display = document.createElement('h4');
            if (rv.error) {
                display.textContent = "No Apps Available For This Model";
            }
            else {
                display.textContent = "Error : Failed Connecting to the server";
            }

            noteContainer.appendChild(display);

            $('#availableAppSettings').append(noteContainer);
        }
        else {
            var list = new L.ui.table({
                columns: [{
                    caption: L.tr('Sl no.'),
                    format: function (v, n) {
                        var div = $('<p />').attr('id', 'slNo%s'.format(n));
                        var serialNumber = n + 1;
                        return div.append('<strong>' + serialNumber + '</strong>');
                    }
                }, {
                    caption: L.tr('App Name'),
                    format: function (v, n) {
                        var div = $('<p />').attr('id', 'appName%s'.format(n));
                        return div.append(v);
                    }
                }, {
                    caption: "Version",
                    format: function (v, n) {
                        var div = $('<p />').attr('id', 'version%s'.format(n));
                        return div.append(v);
                    }
                }, {
                    caption: "Released Date",
                    format: function (v, n) {
                        var div = $('<p />').attr('id', 'installedDate%s'.format(n));
                        return div.append(v);
                    }
                }, {
                    caption: "Size",
                    format: function (v, n) {
                        var div = $('<p />').attr('id', 'size%s'.format(n));
                        return div.append(v);
                    }
                }, {
                    caption: L.tr('Actions'),
                    format: function (v, n) {
                        var temp = v.split(",");
                        var style = "success";
                        if(temp[4] == "Install") {
                            style = "primary";
                        }
                        return $('<div />')
                            .addClass('btn-group btn-group-sm')
                            .append(L.ui.button(L.tr(temp[4]), style, L.tr(temp[4]))
                                .click({ self: self, packageName: temp[0], boardName: temp[1], packageChecksum: temp[2], size: temp[3] }, self.sectionInstall));
                    }
                }]

            });

            var installedAppNames = [];
            var version = {};

            for (var key in installedAppData) {
                if (installedAppData.hasOwnProperty) {
                    installedAppNames.push(installedAppData[key].appName);
                    version[installedAppData[key].appName] = installedAppData[key].version;
                }
            }

            rv.forEach(function (obj, index) {
                var key = obj.deviceName;
                var appName = obj.packageName;
                var version = obj.packageVersion;
                var installedDate = obj.packageReleaseDate;
                var size = obj.packageSize;
                var achecksum = obj.packageChecksum;

                if (!(installedAppNames.includes(appName))) {
                    list.row([key, appName, version, installedDate, size, appName + "," + key + "," + achecksum + "," + size + "," + "Install"]);
                }
                else if (version[obj.packageName] != version) {
                    list.row([key, appName, version, installedDate, size, appName + "," + key + "," + achecksum + "," + size + "," + "Update"]);
                }
            });
            $('#availableAppSettings').append(list.render());
        }
    },

    execute: function () {
        var self = this;

        var installedAppData = [];
        var boardName = "";
        var url = "";
        self.GetUCISections("packagemanager", "package").then(function (rv) {
            installedAppData = rv;
            self.renderInstalledApp(rv);

            self.getBoardName().then(function (res) {

                boardName = res.split('_')[1];

                self.GetUCISections("packagemanager", "general").then(function (rv) {
                    for (var key in rv) {
                        if (rv.hasOwnProperty) {
                            url = rv[key].url;
                        }
                    }
                    var api = url + "getpackagelist?deviceName=" + boardName;
                    fetch(api)
                        .then(response => response.json())
                        .then(data => {
                            var packageList = data;
                            self.renderAvailableApp(packageList, boardName, installedAppData);
                        })
                        .catch(error => console.error("Unable to reach to server"));
                });
            });
        });

        uploadIpk = function () {
            L.ui.archiveUpload(
                L.tr('Upload Package'),
                L.tr('Select the Package .ipk file and click "ok" to proceed'), {
                success: function (info) {
                    var packageName = $('[name=filename]').val();
                    self.handleBackupVerify(info, packageName);
                }
            });
        };

    }
});