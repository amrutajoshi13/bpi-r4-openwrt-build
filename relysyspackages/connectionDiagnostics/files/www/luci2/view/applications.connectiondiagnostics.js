L.ui.view.extend({

    UpdateUCISection: L.rpc.declare({
        object: 'uci',
        method: 'add',
        params: ['config', 'type', 'name', 'values']
    }),

    CreateUCISection: L.rpc.declare({
        object: 'uci',
        method: 'add',
        params: ['config', 'type', 'values']
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

    GetAvailableDeviceNames: L.rpc.declare({
        object: 'network.device',
        method: 'status',
        expect: { '': {} }
    }),

    StartStopService: L.rpc.declare({
        object: 'luci',
        method: 'setInitAction',
        params: ['name', 'action'],
        expect: { '': {} }
    }),

    populateGeneralSettings: function (rv) {
        var self = this;
        for (var key in rv) {
            if (rv.hasOwnProperty(key)) {
                var obj = rv[key];
                if (obj.running == 1) {
                    document.getElementById('startStop').innerText = "Stop";
                }
                else {
                    document.getElementById('startStop').innerText = "Start";
                }

                document.getElementById('enable').value = obj.enable;
                document.getElementById('checkInterval').value = obj.checkInterval;
                document.getElementById('numOfPings').value = obj.numOfPings;
                document.getElementById('packetSize').value = obj.packetSize;
                document.getElementById('enableMqtt').value = obj.enableMqtt;
                document.getElementById('mqttBroker').value = obj.mqttBroker;
                document.getElementById('mqttTopic').value = obj.mqttTopic;
                document.getElementById('tcpPort').value = obj.tcpPort;

                if(obj.dataFormat == "json") {
                    document.getElementById("json").checked = 'checked';
                }
                else{
                    document.getElementById("csv").checked = 'checked';
                }
                if (obj.enable == "1") {
                    document.getElementById("enable").checked = 'checked';
                    document.getElementById("generalSettings").style.display = "block";
                }
                else {
                    document.getElementById("generalSettings").style.display = "none";
                }

                if (obj.enableMqtt == "1") {
                    document.getElementById("enableMqtt").checked = 'checked';
                    document.getElementById("mqttSettings").style.display = "block";
                }
                else {
                    document.getElementById("mqttSettings").style.display = "none";
                }
            }
        }
    },

    sectionReset: function (ev) {
        var self = ev.data.self;
        var sectionName = ev.data.sectionName;
        var mode = ev.data.mode;

        var currentDateTime = new Date();
        var currentDate = currentDateTime.toDateString();
        var currentTime = currentDateTime.toLocaleTimeString();

        var numOfDevices = 0;
        if (mode == "targetIP") {
            numOfDevices = 0;
        }
        var resetStatus = { successfulPings: 0, totalPings: 0, numberOfDevices: numOfDevices, currentDate: currentDate, currentTime: currentTime };
        var successMsg = "Success : Status reset successfull";
        var errorMsg = "Failure : Status reset failure";

        self.updateSection("connectionDiagnostics", "connectionDiagnostics", sectionName, resetStatus, errorMsg, successMsg);
    },

    sectionRemove: function (ev) {
        var self = ev.data.self;
        var sectionName = ev.data.sectionName;

        L.ui.loading(true);
        self.DeleteUCISection("connectionDiagnostics", "connectionDiagnostics", sectionName).then(function (rv) {
            L.ui.loading(false);
            if (rv == 0) {
                self.CommitUCISection("connectionDiagnostics").then(function (res) {
                    if (res != 0) {
                        alert("Error: Delete Configuration");
                    }
                    else {
                        location.reload();
                    }
                });
            };
        });
    },

    enableDisableConfig: function (ev) {
        var self = ev.data.self;
        var sectionName = ev.data.sectionName;
        var index = ev.data.index;
        var enableStatus = {};

        var enable = document.getElementById('enableDisableSwitch' + index).checked;

        if (enable == true) {
            enableStatus = { enable: '1' };
        }
        else {
            enableStatus = { enable: '0' };
        }

        self.updateSection("connectionDiagnostics", "connectionDiagnostics", sectionName, enableStatus);
    },

    renderContents: function (rv) {
        var self = this;

        var list = new L.ui.table({
            columns: [{
                caption: L.tr('Sl no.'),
                format: function (v, n) {
                    var div = $('<p />').attr('id', 'slNo%s'.format(n));
                    return div.append('<strong>' + v + '</strong>');
                }
            }, {
                caption: L.tr('Target IP'),
                format: function (v, n) {
                    var div = $('<p />').attr('id', 'TargetIP%s'.format(n));
                    return div.append(v);
                }
            }, {
                caption: "Monitoring Start" + "<br />" + "Time",
                format: function (v, n) {
                    var div = $('<p />').attr('id', 'TargetIP%s'.format(n));
                    return div.append(v);
                }
            }, {
                caption: "Status" + "<br />" + "(success/failure/total)",
                format: function (v, n) {
                    var myArray = v.split(",")
                    var mode = myArray[0];
                    var key = myArray[1];
                    var status = myArray[2];
                    var div = $('<p />').attr('id', 'Status%s'.format(n));
                    return div.append(status);
                }
            }, {
                caption: L.tr('Enable/Disable'),
                width: '14%',
                align: 'center',
                format: function (v, n) {
                    var myArray = v.split(",")
                    var mode = myArray[0];
                    var key = myArray[1];
                    if (mode == 1) {
                        mode = true;
                    }
                    else {
                        mode = false;
                    }
                    var checkbox = $('<input />')
                        .attr('type', 'checkbox')
                        .attr('id', 'enableDisableSwitch%s'.format(n))
                        .attr('checked', mode)
                        .addClass('slider round')
                        .click({ self: self, sectionName: key, index: n }, self.enableDisableConfig);

                    var span = $('<span />')
                        .addClass('slider round');

                    return $('<label />')
                        .addClass('switch')
                        .append(checkbox)
                        .append(span);

                }

            }, {
                caption: L.tr('Actions'),
                format: function (v, n) {
                    var myArray = v.split(",")
                    var mode = myArray[0];
                    var key = myArray[1];
                    return $('<div />')
                        .addClass('btn-group btn-group-sm')
                        .append(L.ui.button(L.tr('Reset'), 'primary', L.tr('Reset the status'))
                            .click({ self: self, sectionName: key, mode: mode }, self.sectionReset))
                        .append(L.ui.button(L.tr('Delete'), 'danger', L.tr('Delete Configuration'))
                            .click({ self: self, sectionName: key }, self.sectionRemove));
                }
            }]
        });

        var index = 0;
        for (var key in rv) {
            if (rv.hasOwnProperty) {
                index++;
                var obj = rv[key];
                var mode = obj.mode;
                var enable = obj.enable;
                var target = ""
                var status = "nil"

                if (mode == 'targetIP') {
                    target = obj.targetIP;
                }
                else {
                    target = obj.targetDevice;
                }
                var currentDate = obj.currentDate;
                var currentTime = obj.currentTime;
                var currentDateTime = currentDate + "<br />" + currentTime;
                var successfulPings = obj.successfulPings;
                var totalPings = obj.totalPings;
                if (totalPings > 0) {
                    status = (successfulPings / totalPings) * 100;
                    status = status.toFixed(2); // Round to 2 decimal places
                    status = status.substring(0, 5) + "%";
                }
                var finalStatus = status + "<br />" + "(" + successfulPings + "/" + (totalPings - successfulPings) + "/" + totalPings + ")";
                // list.row([index, target, status, enableSlider, resetDelet]);
                list.row([index, target, currentDateTime, mode + "," + key + "," + finalStatus, enable + "," + key, mode + "," + key]);
            }
        }
        $('#renderTable').append(list.render());
    },

    updateSection: function (config, type, name, values, errorMsg, successMsg) {
        var self = this;
        L.ui.loading(true);
        self.StartStopService("connectionDiagnostics", "stop").then(function (rv) {
            
            if (rv.result) {
                self.UpdateUCISection(config, type, name, values).then(function (rv) {
                    if (rv) {
                        L.ui.loading(false);
                        if (rv.section) {
                            self.CommitUCISection(config).then(function (res) {
                                if (res != 0) {
                                    if (errorMsg) {
                                        alert(errorMsg);
                                    }
                                    
                                    return false;
                                }
                                else {
                                    if (successMsg) {
                                        alert("Success : Configuration applied Successfully");
                                    }
                                    var appStatus = document.getElementById('startStop').innerText;
                                    if (appStatus == "Stop") {
                                        self.StartStopService("connectionDiagnostics", "start").then(function (rv) {
                                            if (!rv.result) {
                                                alert("Please restart the application");
                                            }
                                        });
                                    }
                                    location.reload();
                                    return true;
                                }
                            });
                        };
                    };
                });
            }
        });

    },

    execute: function () {
        var self = this;

        var data = {
            generalKey: "",
            general: {},
            targetIP: [],
            targetDevice: []
        };
        var deviceNames = [];
        var mode = "targetIP";
        var dataFormat = "csv";

        self.GetAvailableDeviceNames().then(function (rv) {
            for (var key in rv) {
                deviceNames.push(key);
            }
        });


        self.GetUCISections("connectionDiagnostics", "general").then(function (rv) {
            for (var key in rv) {
                if (rv.hasOwnProperty) {
                    data.generalKey = key;
                }
            }
            self.populateGeneralSettings(rv);
        });

        self.GetUCISections("connectionDiagnostics", "connectionDiagnostics").then(function (rv) {
            var keys = Object.keys(rv);
            var keysLength = keys.length;
            for (var key in rv) {
                if (rv.hasOwnProperty) {
                    var obj = rv[key];
                    if (obj.mode == "targetIP" && obj.targetIP != null) {
                        data.targetIP.push(obj.targetIP)
                    }

                    else if (obj.targetDevice != null) {
                        data.targetDevice.push(obj.targetDevice);
                    }
                }
            }
            if (keysLength > 0) {
                self.renderContents(rv);
            }
        });

        startStopEvent = function (ev) {
            var status = ev.target.innerText;
            if (status == "Start") {
                ev.target.innerText = "Stop";
                var value = { running: "1", mode: "start" };
                self.updateSection("connectionDiagnostics", "general", "general", value);
            }
            else {
                ev.target.innerText = "Start";
                var value = { running: "0", mode: "stop" };
                self.updateSection("connectionDiagnostics", "general", "general", value);
            }
        };

        Enable = function (ev) {
            var checkbox = ev.target.value
            if (checkbox == "1") {
                document.getElementById("enable").value = 0;
                document.getElementById("generalSettings").style.display = "none";
            }
            else {
                document.getElementById("enable").value = 1;
                document.getElementById("generalSettings").style.display = "block";
            }
        };

        EnableMqtt = function (ev) {
            var mqtt = ev.target.value;
            if (mqtt == "1") {
                document.getElementById("enableMqtt").value = 0;
                document.getElementById("mqttSettings").style.display = "none";
            }
            else {
                document.getElementById("enableMqtt").value = 1;
                document.getElementById("mqttSettings").style.display = "block";
            }
        };

        handlechange = function (ev) {
            mode = ev.target.value;

            if (mode == "targetIP") {
                document.getElementById("targetDeviceConfig").style.display = "none";
                document.getElementById("targetIpConfig").style.display = "block";
            }
            else {
                $("#deviceName").empty();
                $('<option />')
                    .attr('value', 'none')
                    .text(' Please Choose any Device')
                    .appendTo("#deviceName");

                for (var device of deviceNames) {
                    $('<option />')
                        .attr('value', device)
                        .text(device)
                        .appendTo("#deviceName");
                }
                document.getElementById("targetIpConfig").style.display = "none";
                document.getElementById("targetDeviceConfig").style.display = "block";
            }
        };

        handlechangeDataFormat = function (ev) {
            dataFormat = ev.target.value;
        };

        ValidateIPv4 = function (ev) {
            var input = ev.target.value;
            if (L.parseIPv4(input)) {
                document.getElementById('validateIPAddress').style.display = 'none';
            }
            else {
                document.getElementById('validateIPAddress').style.display = 'block';
            }
        };

        AddConfig = function () {
            var newData = {};
            // Create a new Date object
            var currentDateTime = new Date();
            var currentDate = currentDateTime.toDateString();
            var currentTime = currentDateTime.toLocaleTimeString();

            if (mode == "targetIP") {
                newData['enable'] = "1";
                newData['mode'] = "targetIP";
                newData['targetIP'] = document.getElementById('IPAddress').value;

                if (L.parseIPv4(newData['targetIP']) == undefined) {
                    alert("Enter a valid IPv4 Address");
                    return null;
                }

                for (var key of data.targetIP) {
                    if (key == newData['targetIP']) {
                        alert("Entered Target IP is already configured\nEnter new IP");
                        return null;
                    }
                }
                newData['successfulPings'] = "0";
                newData['totalPings'] = "0";
                newData['numberOfDevices'] = "0";
            }
            else {
                newData['enable'] = "1";
                newData['mode'] = "targetDevice"
                newData['targetDevice'] = document.getElementById('deviceName').value;
                for (var key of data.targetDevice) {
                    if (key == newData['targetDevice']) {
                        alert("Selected Target Device is already configured\nChoose a new Device");
                        return null;
                    }
                }
                newData['successfulPings'] = "0";
                newData['totalPings'] = "0";
                newData['numberOfDevices'] = "0";
            }
            newData['currentDate'] = currentDate;
            newData['currentTime'] = currentTime;

            L.ui.loading(true);
            self.StartStopService("connectionDiagnostics", "stop").then(function (rv) {
                if (rv.result) {
                    self.CreateUCISection("connectionDiagnostics", "connectionDiagnostics", newData).then(function (rv) {
                        L.ui.loading(false);
                        if (rv) {
                            if (rv.section) {
                                self.CommitUCISection("connectionDiagnostics").then(function (res) {

                                    if (res != 0) {
                                        alert("Error:New Event Configuration");
                                    }
                                    else {
                                        alert("Success : Configuration added Successfully");
                                        var appStatus = document.getElementById('startStop').innerText;
                                        if (appStatus == "Stop") {
                                            self.StartStopService("connectionDiagnostics", "start").then(function (rv) {
                                                if (!rv.result) {
                                                    alert("Please restart the application");
                                                }
                                            });
                                        }
                                        location.reload();
                                    }
                                });
                            };
                        };
                    });
                }
            });

        };

        AddGeneral = function () {
            var validation = document.getElementById('checkInterval').valid;
            if (validation == "0") {
                alert("ERROR : Enter valid Check Interval")
                return null;
            }
            var validation = document.getElementById('numOfPings').valid;
            if (validation == "0") {
                alert("ERROR : Enter valid Number of Pings")
                return null;
            }
            data.general['enable'] = document.getElementById('enable').value;
            data.general['checkInterval'] = document.getElementById('checkInterval').value;
            data.general['numOfPings'] = document.getElementById('numOfPings').value;
            data.general['packetSize'] = document.getElementById('packetSize').value;
            data.general['enableMqtt'] = document.getElementById('enableMqtt').value;
            data.general['mqttBroker'] = document.getElementById('mqttBroker').value;
            data.general['tcpPort'] = document.getElementById('tcpPort').value;
            data.general['mqttTopic'] = document.getElementById('mqttTopic').value;
            data.general['dataFormat'] = dataFormat;
            data.general['populate'] = "0";

            var successMsg = "Success : Configuration applied Successfully";
            var errorMsg = "Error : Error updating general Configuration";
            self.updateSection("connectionDiagnostics", "general", data.generalKey, data.general, errorMsg, successMsg);
        };

        validateInputRange = function (ev) {
            var min = parseFloat(ev.target.min); // Convert to number
            var max = parseFloat(ev.target.max); // Convert to number
            var val = parseFloat(ev.target.value); // Convert to number
            var id = ev.target.id;
            var vid = "validate" + id;

            if (!isNaN(min) && val < min) {
                document.getElementById(id).valid = "0";
                document.getElementById(vid).innerText = "Entered value is lower than " + min;
                document.getElementById(vid).style.display = 'block';
            } else if (!isNaN(max) && val > max) {
                document.getElementById(id).valid = "0";
                document.getElementById(vid).innerText = "Entered value is greater than " + max;
                document.getElementById(vid).style.display = 'block';
            } else {
                document.getElementById(id).valid = "1";
                document.getElementById(vid).style.display = 'none'; // Hide the validation message
            }
        };

    }
});