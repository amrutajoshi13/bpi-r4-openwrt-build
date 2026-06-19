L.ui.view.extend({

    title: L.tr(''),
    description: L.tr(''),
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

    RS485RenderContents: function (rv) {
        configdata = function () {
            return rv;
        }
        var self = this;
        var list = new L.ui.table({
            columns: [{
                caption: L.tr('Sl No'),
                align: 'center',
                format: function (v, n) {
                    var div = $('<p />').attr('id', 'RS485DeviceSerialNo_%s'.format(n));
                    var serialNo = n + 1;
                    return div.append('<strong>' + serialNo + '<strong>');
                }
            },
            {
                caption: L.tr('Device Name'),
                align: 'center',
                format: function (v, n) {
                    var div = $('<p />').attr('id', 'RS485DeviceEventName_%s'.format(n));
                    return div.append('<strong>' + v + '</strong>');
                }
            },
            {
                caption: L.tr('Slave ID'),
                align: 'center',
                format: function (v, n) {
                    var div = $('<b />').attr('id', '_%s'.format(n));
                    return div.append('<strong>' + v + '</strong>');
                }
            },
            {
                caption: L.tr('No.of Block Config'),
                align: 'center',
                format: function (v, n) {
                    var div = $('<b />').attr('id', 'Blockconfig_%s'.format(n));
                    return div.append('<strong>' + v + '</strong>');
                }
            },
            {
                caption: L.tr('No.of Register Config'),
                align: 'center',
                format: function (v, n) {
                    var div = $('<b />').attr('id', 'Regconfig_%s'.format(n));
                    return div.append('<strong>' + v + '</strong>');
                }
            },

            {
                caption: L.tr('No.of Alarm/Event Config'),
                align: 'center',
                format: function (v, n) {
                    var div = $('<b />').attr('id', 'Alarmconfig_%s'.format(n));
                    return div.append('<strong>' + v + '</strong>');
                }
            },
            {
                caption: L.tr('Update'),
                align: 'center',
                format: function (v, n) {
                    return $('<div />')
                        .addClass('btn-group btn-group-sm')
                        .append(L.ui.button(L.tr('Edit'), 'primary')
                            .click({ self: self, RS485ConfigSectionName: v }, self.RS485ConfigSectionEdit))
                        .append(L.ui.button(L.tr('Delete'), 'danger')
                            .click({ self: self, RS485ConfigSectionName: v }, self.RS485ConfigSectionRemove));
                }
            }]
        });

        for (var key in rv) {
            console.log(rv)
            if (rv.hasOwnProperty(key)) {
                var obj = rv[key];
                let devicetype = obj.serialdeviceid
                let serialslaveid = obj.serialslaveid
                let Blockconfig = obj.Blocklen;
                console.log("Blockconfig", Blockconfig)
                let Regconfig = obj.registerlen;
                let Alarmconfig = obj.Alarmlen;
                list.row([key, devicetype, serialslaveid, Blockconfig, Regconfig, Alarmconfig, key]);
            }
        }

        $('#map').append(list.render());
    },




    RS485ConfigSectionAdd: function () {
        var self = this;
        var register_config = registerdata();
        var block_config = blockdata();
        console.log("block_config123", block_config)
        var alarm_config = alarmdata();
        var devicedata = configdata();
        var uniquedevicename = [];
        for (var key in devicedata) {
            uniquedevicename.push(devicedata[key].serialdeviceid)
        }
        var uniqueid;
        if (typeof getuniqid === 'function') {
            _unq = getuniqid();
        } else {
            _unq = '';
        }
        var registerconfig = {};
        var blockconfig = {};
        var alarmconfig = {};
        var parameterconfig = {}


        for (var i = 0; i < register_config.length; i++) {
            var config = register_config[i];
            for (var key in config) {
                registerconfig[key + '_' + i] = config[key];
            }
        }
        // for (var i = 0; i < register_config.length; i++) {
        //     var config = register_config[i];
        //     for (var key in config) {
        //         if (key === "multifactor") {
        //             continue;
        //         }
        //         if (!config[key] || config[key].trim() === "") {
        //             alert(`Please fill in the value for ${key} in row ${i + 1}.`);
        //             return false;
        //         }
        //         registerconfig[key + '_' + i] = config[key];
        //     }
        // }
        for (var i = 0; i < block_config.length; i++) {
            var config = block_config[i];
            for (var key in config) {
                blockconfig[key + '_' + i] = config[key];
            }
        }
        // for (var i = 0; i < block_config.length; i++) {
        //     var config = block_config[i];
        //     for (var key in config) {
        //         if (key === "functionCode") {
        //             continue;
        //         }
        //         if (!config[key] || config[key].trim() === "") {
        //             alert(`Please fill in the value for ${key} in row ${i + 1}.`);
        //             return false;
        //         }
        //         blockconfig[key + '_' + i] = config[key];
        //     }
        // }
        for (var i = 0; i < alarm_config.length; i++) {
            var config = alarm_config[i];
            for (var key in config) {
                alarmconfig[key + '_' + i] = config[key];
            }
        }

        // for (var i = 0; i < alarm_config.length; i++) {
        //     var config = alarm_config[i];
        //     for (var key in config) {
        //         if (["uprThreshold", "uprHysteresis", "lowerThreshold", "lowerHysteresis"].includes(key)) {
        //             continue;
        //         }
        //         if (!config[key] || config[key].trim() === "") {
        //             alert(`Please fill in the value for ${key} in row ${i + 1}.`);
        //             return false;
        //         }
        //         alarmconfig[key + '_' + i] = config[key];
        //     }
        // }


        var sensorSectionOptions = {}
        console.log("sensorSectionOptions", sensorSectionOptions)
        var cloudSectionOptions = {}
        var RS485ConfigSectionName;
        var cloudconfig = {}
        var sdevicename = $('#devicename').val();
        var defaultchecked = document.getElementById("Default")
        var Customchecked = document.getElementById("Custom")
        var alarmEnabled = document.getElementById("alarmEnabled0")
        var protocol = $('#protocol').val();

        if (sdevicename != "") {
            debugger
            uniqueid = uniquedevicename.includes(sdevicename)
            RS485ConfigSectionName = sdevicename
            parameterconfig["serialdeviceid"] = sdevicename
            parameterconfig["serialslaveid"] = $('#serialslaveid').val();
            parameterconfig["serialport1"] = $('#serialport1').val();
            parameterconfig["metermodel"] = $('#metermodel').val();
            let value = $('#stdModbusEnable1').val() || $('#stdModbusEnable').val();
            parameterconfig["stdModbusEnable"] = value;
            console.log(`Packed value: ${value}`);
            parameterconfig["MeterID"] = $('#equipmentid').val();
            parameterconfig["optiondevice"] = $('#optiondevice').val();
            parameterconfig["protocol"] = protocol
            parameterconfig["registerlen"] = register_config.length;
            parameterconfig["Blocklen"] = block_config.length;
            console.log("Blocklen assigned:", parameterconfig["Blocklen"]);
            parameterconfig["Alarmlen"] = alarm_config.length;
            parameterconfig["tagNameInput"] = $('#tagNameInput').val();
            parameterconfig["devicetype"] = "modbus"
            parameterconfig["TagDatatype"] = $('#TagDatatype').val();
            cloudconfig["topicname"] = $('#topicname').val();
            cloudconfig["topicnametwo"] = $('#topicnametwo').val();
            cloudconfig["jsonHeaderKeyName"] = $('#jsonHeaderKeyName').val();
            cloudconfig["jsonKeyName1"] = $('#jsonKeyName1').val();
            cloudconfig["jsonKeyValue1"] = $('#jsonKeyValue1').val();
            cloudconfig["jsonKeyName2"] = $('#jsonKeyName2').val();
            cloudconfig["jsonKeyValue2"] = $('#jsonKeyValue2').val();
            cloudconfig["jsonKeyName3"] = $('#jsonKeyName3').val();
            cloudconfig["jsonKeyValue3"] = $('#jsonKeyValue3').val();
            cloudconfig["dataSendingMethod"] = $('#dataSendingMethod').val();

            //for checkbox1
            // var checkBox1 = document.getElementById('enableSlaveData');
            // var enableSlaveDatastatus = checkBox1.checked ? '1' : '0';
            // cloudconfig["enableSlaveDatastatus"] = enableSlaveDatastatus;
            // console.log("asd", cloudconfig["enableSlaveDatastatus"])
            // for checkBox2
            // var checkBox2 = document.getElementById('enableSlaveCloudData');
            // var enableSlaveCloudDatastatus = checkBox2.checked ? '1' : '0';
            // cloudconfig["enableSlaveCloudDatastatus"] = enableSlaveCloudDatastatus;
            //checkBox3
            var checkBox3 = document.getElementById('enableJsonHeaderKey');
            var enableJsonHeaderKeystatus = checkBox3.checked ? '1' : '0';
            cloudconfig["enableJsonHeaderKeystatus"] = enableJsonHeaderKeystatus;
            //customField1
            var checkBox4 = document.getElementById('enableCustomField1');
            var enableCustomFieldStatus1 = checkBox4.checked ? '1' : '0';
            cloudconfig["enableCustomFieldStatus1"] = enableCustomFieldStatus1;
            //customField2
            var checkBox5 = document.getElementById('enableCustomField2');
            var enableCustomFieldStatus2 = checkBox5.checked ? '1' : '0';
            cloudconfig["enableCustomFieldStatus2"] = enableCustomFieldStatus2;

            //customField3
            var checkBox6 = document.getElementById('enableCustomField3');
            var enableCustomFieldStatus3 = checkBox6.checked ? '1' : '0';
            cloudconfig["enableCustomFieldStatus3"] = enableCustomFieldStatus3;

            const jsonHeaderKeyName = document.getElementById("jsonHeaderKeyName");
            const jsonKeyName1 = document.getElementById("jsonKeyName1");
            const jsonKeyValue1 = document.getElementById("jsonKeyValue1");
            const jsonKeyName2 = document.getElementById("jsonKeyName2");
            const jsonKeyValue2 = document.getElementById("jsonKeyValue2");
            const jsonKeyName3 = document.getElementById("jsonKeyName3");
            const jsonKeyValue3 = document.getElementById("jsonKeyValue3");


            function checkAllConditions(event) {
                if (checkBox3.checked) {
                    if (!jsonHeaderKeyName.value.trim()) {
                        alert("Please fill in the JSON Header Key Name before submitting.");
                        jsonHeaderKeyName.focus();
                        event.preventDefault();
                        return false;
                    }
                }
                if (checkBox4.checked) {
                    if ((jsonKeyName1 && !jsonKeyName1.value.trim()) || (jsonKeyValue1 && !jsonKeyValue1.value.trim())) {
                        alert("Please fill in both JSON Key Name 1 and JSON Key Value 1.");
                        if (!jsonKeyName1.value.trim()) jsonKeyName1.focus();
                        else jsonKeyValue1.focus();
                        event.preventDefault();
                        return false;
                    }
                }

                if (checkBox5.checked) {
                    if ((jsonKeyName2 && !jsonKeyName2.value.trim()) || (jsonKeyValue2 && !jsonKeyValue2.value.trim())) {
                        alert("Please fill in both JSON Key Name 2 and JSON Key Value 2.");
                        if (!jsonKeyName2.value.trim()) jsonKeyName2.focus();
                        else jsonKeyValue2.focus();
                        event.preventDefault();
                        return false;
                    }
                }
                if (checkBox6.checked) {
                    if ((jsonKeyName3 && !jsonKeyName3.value.trim()) || (jsonKeyValue3 && !jsonKeyValue3.value.trim())) {
                        alert("Please fill in both JSON Key Name 3 and JSON Key Value 3.");
                        if (!jsonKeyName3.value.trim()) jsonKeyName3.focus();
                        else jsonKeyValue3.focus();
                        event.preventDefault();
                        return false;
                    }
                }
                return true;
            }

            function validateTopicName(event) {
                var topicName = $('#topicname');
                var topicNametwo = $('#topicnametwo');

                // Check if the topicName field is visible and not filled
                if (topicName.is(":visible") && topicName.css('display') === 'block' && !topicName.val().trim()) {
                    alert("Please fill in the topic name before submitting.");
                    topicName.focus();
                    event.preventDefault(); // Prevent form submission or other actions
                    return false;
                }

                // Check if the topicNametwo field is visible and not filled
                if (topicNametwo.is(":visible") && topicNametwo.css('display') === 'block' && !topicNametwo.val().trim()) {
                    alert("Please fill in the second topic name before submitting.");
                    topicNametwo.focus();
                    event.preventDefault(); // Prevent form submission or other actions
                    return false;
                }

                return true;
            }


            if (protocol == "RTU") {
                parameterconfig["Baudrate"] = $('#serialbaudrate').val();
                parameterconfig["Parity"] = $('#serialparity').val();
                parameterconfig["NoOfStopbits"] = $('#serialstopbit').val();
                parameterconfig["Databits"] = $('#serialdatabits').val();
            }
            else {
                parameterconfig["CommIp"] = $('#CommIp').val();
                parameterconfig["CommPort"] = $('#CommPort').val();
                parameterconfig["commT"] = $('#commT').val();
            }
            console.log(parameterconfig)
            sensorSectionOptions = parameterconfig;
            // for (let key in sensorSectionOptions) {
            //     if (sensorSectionOptions[key] == null || sensorSectionOptions[key] == undefined || sensorSectionOptions[key] == "") {
            //         delete sensorSectionOptions[key];
            //     }
            // }
            for (let key in sensorSectionOptions) {
                if (sensorSectionOptions[key] == null || sensorSectionOptions[key] == undefined) {
                    delete sensorSectionOptions[key];
                }
            }
            cloudSectionOptions = cloudconfig;
            for (let key in cloudSectionOptions) {
                if (cloudSectionOptions[key] == null || cloudSectionOptions[key] == undefined || cloudSectionOptions[key] == "") {
                    delete cloudSectionOptions[key];
                }
            }
            var status = $("#Modbus_Submit").attr("name");

            if (status === "submit" && uniqueid) {
                alert("Device with the same name already exists.");
            } else if (!checkAllConditions(event)) {
                event.preventDefault();
            }
            else if (!validateTopicName(event)) {
                event.preventDefault();
            }
            else {

                self.RS485DeleteUCISection("registerconfig", "registerconfig", RS485ConfigSectionName).then(function (rv) {
                    self.RS485CommitUCISection("DeviceConfigGeneric").then(function (res) {
                        if (res != 0) {
                            // alert("Error: Delete Sensor Configuration");
                        }
                        else {
                        }
                    });

                });


                self.RS485CreateUCISection("registerconfig", "registerconfig", RS485ConfigSectionName, registerconfig).then(function (rv) {
                    if (rv) {
                        if (rv.section) {
                            self.RS485CommitUCISection("registorconfig").then(function (res) {

                                if (res != 0) {
                                    // alert("Error:New Event Configuration");
                                }
                                else {
                                    // location.reload();
                                }
                            });
                        };
                    };
                });

                self.RS485DeleteUCISection("blockconfig", "blockconfig", RS485ConfigSectionName).then(function (rv) {
                    self.RS485CommitUCISection("DeviceConfigGeneric").then(function (res) {
                        if (res != 0) {
                            // alert("Error: Delete Sensor Configuration");
                        }
                        else {
                        }
                    });

                });

                self.RS485CreateUCISection("blockconfig", "blockconfig", RS485ConfigSectionName, blockconfig).then(function (rv) {
                    if (rv) {
                        if (rv.section) {
                            self.RS485CommitUCISection("blockconfig").then(function (res) {

                                if (res != 0) {
                                    // alert("Error:New Event Configuration");
                                }
                                else {
                                    // location.reload();
                                }
                            });
                        };
                    };
                });

                self.RS485DeleteUCISection("alarmconfig", "alarmconfig", RS485ConfigSectionName).then(function (rv) {
                    self.RS485CommitUCISection("DeviceConfigGeneric").then(function (res) {
                        if (res != 0) {
                            // alert("Error: Delete Sensor Configuration");
                        }
                        else {
                        }
                    });

                });

                self.RS485CreateUCISection("alarmconfig", "alarmconfig", RS485ConfigSectionName, alarmconfig).then(function (rv) {
                    if (rv) {
                        if (rv.section) {
                            self.RS485CommitUCISection("alarmconfig").then(function (res) {

                                if (res != 0) {
                                    // alert("Error:New Event Configuration");
                                }
                                else {
                                    // location.reload();
                                }
                            });
                        };
                    };
                });

                self.RS485CreateUCISection("cloudconfigGeneric", "cloudConfig", RS485ConfigSectionName, cloudSectionOptions).then(function (rv) {
                    if (rv) {
                        if (rv.section) {
                            self.RS485CommitUCISection("cloudconfigGeneric").then(function (res) {

                                if (res != 0) {
                                    // alert("Error:New Event Configuration");
                                }
                                else {
                                    // location.reload();
                                }
                            });
                        };
                    };
                });

                self.RS485CreateUCISection("DeviceConfigGeneric", "RS485Config", RS485ConfigSectionName, sensorSectionOptions).then(function (rv) {
                    if (rv) {
                        if (rv.section) {
                            self.RS485CommitUCISection("DeviceConfigGeneric").then(function (res) {

                                if (res != 0) {
                                    // alert("Error:New Event Configuration");
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
        else {
            // alert("Please Enter Device Name");
        }
    },



    listobject: {},
    blockobject: {},
    alarmobject: {},
    RS485ConfigSectionEdit: function (ev) {
        console.log("ev", ev)
        var self = this;
        $("#jsoninfo").val("")
        $("#jsoninfo").css("display", "none")

        getuniqid = function () {
            return ev.data.RS485ConfigSectionName;
        }
        $('#devicename').prop('disabled', true);
        $("#updatetext").css("display", "block");
        $("#updatedevice").css("display", "block");
        $("#addtext").css("display", "none");
        $('#Modbus-ModelLabel')
            .attr('name', 'UpdateModbus') // Change the name attribute
            .text('Update Modbus Configuration');
        $('#Modbus_Submit')
            .attr('name', 'UpdatedSubmit')
            .addClass('btn btn-success') // Change the name attribute
            .text('Update');
        $("#modbusserialconfig").css("display", "block");
        $("#modbustcpconfig").css("display", "none");
        $(".modusregister").css("display", "block");
        $("#modustcpregister").css("display", "none");
        $("#defaultMappingInputs").css("display", "none");
        var self = ev.data.self;
        var RS485ConfigSectionName = ev.data.RS485ConfigSectionName;
        var register_config = configdata();
        var block_config = blockdata();
        console.log(block_config)
        var alarm_config = alarmdata();

        self.RS485GetUCISections("registerconfig", "registerconfig").then(function (rv) {
            // Validate and extract the configuration data
            let getregistrdata = rv[RS485ConfigSectionName];
            if (!getregistrdata) {
                console.error("No data found for RS485ConfigSectionName");
                return;
            }

            // Initialize variables for storing objects and unique indices
            let List_object = [];
            let List_key = [];

            // Clear the existing content in the target container
            document.getElementById('Registersection').innerHTML = ""; // Clears all appended content

            // Extract and filter unique indices from the keys of the retrieved data
            List_key = Object.keys(getregistrdata)
                .map(key => key.split("_")[1]) // Extract index from keys
                .filter(key => key !== undefined); // Filter out undefined keys

            // Remove duplicate indices using a Set
            let uniqueKeys = [...new Set(List_key)];

            // Build an array of objects for each unique index
            uniqueKeys.forEach(index => {
                List_object.push({
                    Datatype: getregistrdata["Datatype_" + index],
                    registercount: getregistrdata["registercount_" + index],
                    registername: getregistrdata["registername_" + index],
                    multifactor: getregistrdata["multifactor_" + index],
                    startregister: getregistrdata["startregister_" + index]
                });
            });

            // Update the `listobject` property and update the UI rows
            self.listobject = List_object;
            self.editrows(List_object); // Pass the processed data to update the UI
        });




        self.RS485GetUCISections("blockconfig", "blockconfig").then(function (rv) {
            let Blockgetregistrdata = rv[RS485ConfigSectionName];
            if (!Blockgetregistrdata) {
                console.error("No data found for RS485ConfigSectionName");
                return;
            }

            var Block_object = [];
            var Block_key = [];

            // Clear the existing content in the Registersection container
            document.getElementById('Blockregistersection').innerHTML = "";

            // Extract unique keys
            Object.keys(Blockgetregistrdata).forEach(function (key) {
                const index = key.split("_")[1];
                if (index !== undefined) {
                    Block_key.push(index);
                }
            });

            var uniqueKeys = [...new Set(Block_key)]; // Unique indices

            // Build the list of block objects
            uniqueKeys.forEach(index => {
                Block_object.push({
                    functionCode: Blockgetregistrdata["functionCode_" + index],
                    startRegister: Blockgetregistrdata["startRegister_" + index],
                    countRegister: Blockgetregistrdata["countRegister_" + index]
                });
            });

            // Assign the block object and call Blockeditrows to update the UI
            self.blockobject = Block_object;
            self.Blockeditrows(Block_object);
        });


        self.RS485GetUCISections("alarmconfig", "alarmconfig").then(function (rv) {
            let Alarmgetregistrdata = rv[RS485ConfigSectionName];
            let Alarm_object = [];
            let Alarm_key = [];

            // Clear existing alarm configuration
            document.getElementById('Alarm_Event_section').innerHTML = "";

            // Extract unique keys
            Object.keys(Alarmgetregistrdata).forEach(key => {
                Alarm_key.push(key.split("_")[1]);
            });

            let uniqueKeys = [...new Set(Alarm_key)].filter(element => element !== undefined);

            // Build Alarm_object
            uniqueKeys.forEach(key => {
                const alarmData = {
                    Category: Alarmgetregistrdata[`Category_${key}`],
                    alarmEnabled: Alarmgetregistrdata[`alarmEnabled_${key}`],
                    alarmName: Alarmgetregistrdata[`alarmName_${key}`],
                    Code: Alarmgetregistrdata[`Code_${key}`],
                    regAlarm: Alarmgetregistrdata[`regAlarm_${key}`],
                    alarmCount: Alarmgetregistrdata[`alarmCount_${key}`],
                    alarmDatatype: Alarmgetregistrdata[`alarmDatatype_${key}`]
                };

                if (alarmData.Category === 1) {
                    // For Category 1
                    if (alarmData.alarmDatatype === 11) {
                        alarmData.uprThreshold = Alarmgetregistrdata[`uprThreshold_${key}`];
                    } else {
                        alarmData.uprThreshold = Alarmgetregistrdata[`uprThreshold_${key}`];
                        alarmData.uprHysteresis = Alarmgetregistrdata[`uprHysteresis_${key}`];
                        alarmData.lowerThreshold = Alarmgetregistrdata[`lowerThreshold_${key}`];
                        alarmData.lowerHysteresis = Alarmgetregistrdata[`lowerHysteresis_${key}`];
                    }
                } else {
                    // For other Categories
                    if (alarmData.alarmDatatype !== 11) {
                        alarmData.uprThreshold = Alarmgetregistrdata[`uprThreshold_${key}`];
                        alarmData.uprHysteresis = Alarmgetregistrdata[`uprHysteresis_${key}`];
                        alarmData.lowerThreshold = Alarmgetregistrdata[`lowerThreshold_${key}`];
                        alarmData.lowerHysteresis = Alarmgetregistrdata[`lowerHysteresis_${key}`];
                    }
                }
                console.log("alarmData", alarmData)

                Alarm_object.push(alarmData);
            });

            // Save and process alarms
            self.alarmobject = Alarm_object;
            self.Alarmeditrows(Alarm_object);
        });


        //cloud config
        self.RS485GetUCISections("cloudconfigGeneric", "cloudConfig").then(function (rv) {
            debugger
            let data1 = rv[RS485ConfigSectionName]
            var dropdown1 = document.getElementById("dataSendingMethod");
            console.log(dropdown1)
            var topicNameOne1 = document.getElementById('topicNameField');
            var topicNameTwo1 = document.getElementById('topicNameTwoField');
            console.log("data1", data1)
            $('#topicname').val(data1.topicname);
            $('#topicnametwo').val(data1.topicnametwo);
            $('#jsonHeaderKeyName').val(data1.jsonHeaderKeyName);
            $('#jsonKeyName1').val(data1.jsonKeyName1);
            $('#jsonKeyValue1').val(data1.jsonKeyValue1);
            $('#jsonKeyName2').val(data1.jsonKeyName2);
            $('#jsonKeyValue2').val(data1.jsonKeyValue2);
            $('#jsonKeyName3').val(data1.jsonKeyName3);
            $('#jsonKeyValue3').val(data1.jsonKeyValue3);
            $('#dataSendingMethod').val(data1.dataSendingMethod);

            // checkbox3
            if (data1.enableJsonHeaderKeystatus == 1) {
                $('#enableJsonHeaderKey').prop('checked', true);  // Set checked
            } else {
                $('#enableJsonHeaderKey').prop('checked', false); // Set unchecked
            }

            // customField1
            if (data1.enableCustomFieldStatus1 == 1) {
                $('#enableCustomField1').prop('checked', true);  // Set checked
            } else {
                $('#enableCustomField1').prop('checked', false); // Set unchecked
            }

            // customField2
            if (data1.enableCustomFieldStatus2 == 1) {
                $('#enableCustomField2').prop('checked', true);  // Set checked
            } else {
                $('#enableCustomField2').prop('checked', false); // Set unchecked
            }

            // customField3
            if (data1.enableCustomFieldStatus3 == 1) {
                $('#enableCustomField3').prop('checked', true);  // Set checked
            } else {
                $('#enableCustomField3').prop('checked', false); // Set unchecked
            }




            if (["1", "2", "3"].includes(data1.dataSendingMethod)) {
                debugger

                self.RS485GetUCISections("cloudconfig", "cloudconfig").then(function (rv) {
                    var dataSlave = rv;
                    console.log("Editaaaaaa", rv);

                    const { cloudconfig } = dataSlave;
                    const { cloudprotocol, cloudprotocol2, server } = cloudconfig;

                    function setDisplay(displayOne, displayTwo) {
                        topicNameOne1.style.display = displayOne;
                        topicNameTwo1.style.display = displayTwo;
                        // dropdown1.value = value;
                    }

                    if (["primary"].includes(server) && cloudprotocol === 'mqtt') {
                        if (["1", "2", "3"].includes(data1.dataSendingMethod)) {
                            dropdown1.value = 1;
                            setDisplay("block", "none");
                        }
                    }
                    else if (["primary"].includes(server) && cloudprotocol !== 'mqtt') {
                        if (["1", "2", "3"].includes(data1.dataSendingMethod)) {
                            dropdown1.value = 1;
                            setDisplay("none", "none");
                        }

                    } else if (["both", "fallback", "primary"].includes(server) && cloudprotocol === 'mqtt' && cloudprotocol2 === 'http') {
                        if (data1.topicname) {
                            if (data1.dataSendingMethod === "1" && data1.topicname) {
                                console.log("12345", server);
                                dropdown1.value = 1;
                                setDisplay("block", "none");
                            } else if (data1.dataSendingMethod === "3") {
                                console.log("condition3", server);
                                dropdown1.value = 3;
                                setDisplay("block", "none");
                            } else if (data1.dataSendingMethod === "1") {
                                dropdown1.value = 2;
                                setDisplay("none", "none");
                            }
                        } else {
                            dropdown1.value = 1;
                            setDisplay("none", "none");
                        }

                    } else if (["both", "fallback"].includes(server) && cloudprotocol2 === 'mqtt' && cloudprotocol === 'http') {
                        if (data1.dataSendingMethod === "2" && data1.topicnametwo) {
                            console.log("123456", server);
                            dropdown1.value = 2;
                            setDisplay("none", "block");
                        } else if (data1.dataSendingMethod === "3") {
                            console.log("condition3", server);
                            dropdown1.value = 3;
                            setDisplay("none", "block");
                        } else if (data1.dataSendingMethod === "1") {
                            dropdown1.value = 1;
                            setDisplay("none", "none");
                        }


                    } else if (data1.dataSendingMethod === "3" && data1.topicname && data1.topicnametwo) {
                        if (["both", "fallback"].includes(server)) {
                            if (cloudprotocol === 'mqtt' && cloudprotocol2 === 'mqtt') {
                                console.log("condition3", server);
                                dropdown1.value = 3;
                                setDisplay("block", "block");
                            } else if (cloudprotocol === 'mqtt') {
                                dropdown1.value = 3;
                                console.log("condition31", cloudprotocol);
                                setDisplay("block", "none");
                            } else if (cloudprotocol2 === 'mqtt') {
                                dropdown1.value = 3;
                                console.log("condition32", cloudprotocol2);
                                setDisplay("none", "block");
                            }
                        }
                    } else if (["both", "fallback"].includes(server) && cloudprotocol2 === 'mqtt' && cloudprotocol === 'mqtt') {
                        if (data1.dataSendingMethod === "2") {
                            console.log("condition3", server);
                            dropdown1.value = 2;
                            setDisplay("none", "block");
                        } else {
                            dropdown1.value = 1;
                            setDisplay("block", "none");

                        }
                    }
                });
            }
        });

        var editdevice = register_config[RS485ConfigSectionName];
        console.log("editdevice:", editdevice)
        var alarm = alarm_config[RS485ConfigSectionName];
        console.log("alarmdevice:", alarm)
        $('#devicename').val(editdevice.serialdeviceid);
        $('#metermodel').val(editdevice.metermodel);

        $('#serialslaveid').val(editdevice.serialslaveid);
        $('#serialport1').val(editdevice.serialport1);
        $('#serialbaudrate').val(editdevice.Baudrate);
        $('#serialparity').val(editdevice.Parity);
        $('#protocol').val(editdevice.protocol);
        if (editdevice.protocol === "TCP") {
            $('#stdModbusEnable1').val(editdevice.stdModbusEnable);
        } else {
            $('#stdModbusEnable').val(editdevice.stdModbusEnable);
        }
        self.changemodbusprotocol();
        $('#CommIp').val(editdevice.CommIp);
        $('#CommPort').val(editdevice.CommPort);
        $('#commT').val(editdevice.commT);
        $('#equipmentid').val(editdevice.MeterID);
        $('#optiondevice').val(editdevice.optiondevice);
        $('#serialstopbit').val(editdevice.NoOfStopbits);
        $('#serialdatabits').val(editdevice.Databits);
        $('#tagNameInput').val(editdevice.tagNameInput);
        $('#TagDatatype').val(editdevice.TagDatatype);
        if (editdevice.defaultchecked == "1") {
            $("#TextBoxesGroup").css("display", "none")
            document.getElementById("Custom").checked = false
            document.getElementById("Default").style.pointerEvents = "none"
            document.getElementById("Custom").style.pointerEvents = "auto"
        }
        if (editdevice.Customchecked == "1") {
            $("#TextBoxesGroup").css("display", "block")
        }

        // self.validatefcatory();
        // self.somerandom()

        $('#Modbus-Model').modal('show');

    },




    RS485ConfigSectionRemove: function (ev) {
        var self = ev.data.self;
        var RS485ConfigSectionName = ev.data.RS485ConfigSectionName;
        // Remove the specific RS485 config section
        self.RS485DeleteUCISection("DeviceConfigGeneric", "RS485Config", RS485ConfigSectionName).then(function (rv) {
            if (rv == 0) {
                self.RS485CommitUCISection("DeviceConfigGeneric").then(function (res) {
                    if (res != 0) {
                        alert("Error: Delete Sensor Configuration");
                    }
                    else {
                        location.reload();
                    }
                });
            }
        });

        // Remove the specific register config section
        self.RS485DeleteUCISection("registerconfig", "registerconfig", RS485ConfigSectionName).then(function (rv) {
            if (rv == 0) {
                self.RS485CommitUCISection("registerconfig").then(function (res) {
                    if (res != 0) {
                        alert("Error: Delete Sensor Configuration");
                    }
                    else {
                        location.reload();
                    }
                });
            }
        });

        // Remove the specific block config section
        self.RS485DeleteUCISection("blockconfig", "blockconfig", RS485ConfigSectionName).then(function (rv) {
            if (rv == 0) {
                self.RS485CommitUCISection("blockconfig").then(function (res) {
                    if (res != 0) {
                        alert("Error: Delete Sensor Configuration");
                    }
                    else {
                        location.reload();
                    }
                });
            }
        });

        // Remove the specific alarm config section
        self.RS485DeleteUCISection("alarmconfig", "alarmconfig", RS485ConfigSectionName).then(function (rv) {
            if (rv == 0) {
                self.RS485CommitUCISection("alarmconfig").then(function (res) {
                    if (res != 0) {
                        alert("Error: Delete Sensor Configuration");
                    }
                    else {
                        location.reload();
                    }
                });
            }
        });

        self.RS485DeleteUCISection("cloudconfigGeneric", "cloudconfig", RS485ConfigSectionName).then(function (rv) {
            if (rv == 0) {
                self.RS485CommitUCISection("cloudconfigGeneric").then(function (res) {
                    if (res != 0) {
                        alert("Error: Delete Sensor Configuration");
                    }
                    else {
                        location.reload();
                    }
                });
            }
        });

        // After deletions, update the UI without reloading the page
        $("#RS485ConfigSectionDiv" + RS485ConfigSectionName).remove();

        // Update the IDs and event listeners of the remaining sections
        $(".RS485ConfigSectionDiv").each(function (index, element) {
            $(element).attr("id", "RS485ConfigSectionDiv" + index);
            // Update other attributes and event listeners if necessary
        });
    },




    /********************Pseudo Section Code*************************** */



    PseudoRenderContents: function (rv) {
        Pseudoconfigdata = function () {
            return rv;
        }
        var self = this;
        var pseudoList = new L.ui.table({
            columns: [{
                caption: L.tr('Sl No'),
                align: 'center',
                format: function (v, n) {
                    var div = $('<p />').attr('id', 'PseudoSerialNo_%a'.format(n));
                    var serialNo1 = n + 1;
                    return div.append('<strong>' + serialNo1 + '<strong>');
                }
            },
            {
                caption: L.tr('Pseudo Device Name'),
                align: 'center',
                format: function (v1, n) {
                    var div = $('<p />').attr('id', 'pseudodeviceName_%b'.format(n));
                    return div.append('<strong>' + v1 + '</strong>');
                }
            },
            {
                caption: L.tr('Pseudo Slave ID'),
                align: 'center',
                format: function (v1, n) {
                    var div = $('<b />').attr('id', 'pseudoslave_%c'.format(n));
                    return div.append('<strong>' + v1 + '</strong>');
                }
            },
            {
                caption: L.tr('No.of Register Config'),
                align: 'center',
                format: function (v1, n) {
                    var div = $('<b />').attr('id', 'Regconfig_%d'.format(n));
                    return div.append('<strong>' + v1 + '</strong>');
                }
            },
            {
                caption: L.tr('Update'),
                align: 'center',
                format: function (v, n) {
                    return $('<div />')
                        .addClass('btn-group btn-group-sm')
                        .append(L.ui.button(L.tr('Edit'), 'primary')
                            .click({ self: self, PseudoConfigSectionName: v }, self.PseudoConfigSectionEdit))
                        .append(L.ui.button(L.tr('Delete'), 'danger')
                            .click({ self: self, PseudoConfigSectionName: v }, self.PseudoConfigSectionRemove));
                }
            }]
        });

        for (var key1 in rv) {
            if (rv.hasOwnProperty(key1)) {
                var obj = rv[key1];
                let devicetype = obj.pseudoDeviceName
                let pseudoSlaveID = obj.pseudoSlaveID
                let PseudoRegconfig = obj.pseudoregisterlen;
                pseudoList.row([key1, devicetype, pseudoSlaveID, PseudoRegconfig, key1]);
            }
        }

        $('#map2').append(pseudoList.render());
    },




    PseudoSectionAdd: function () {
        var self = this;

        var Pseudoregister_config = pseudoRegisterData();
        console.log("Pseudoregister_config", Pseudoregister_config)
        var pseudodevicedata = Pseudoconfigdata();
        var pseudoconfig = {}
        var uniquepseudodevicename = [];
        for (var key in pseudodevicedata) {
            uniquepseudodevicename.push(pseudodevicedata[key].pseudoDeviceName)
        }
        var uniqueid;
        if (typeof getuniqid === 'function') {
            _unq = getuniqid();
        } else {
            _unq = '';
        }
        var PseudoRegisterconfig = {};
        console.log("PseudoRegisterconfig", PseudoRegisterconfig)


        for (var i = 0; i < Pseudoregister_config.length; i++) {
            var config = Pseudoregister_config[i];
            for (var key in config) {
                PseudoRegisterconfig[key + '_' + i] = config[key];
            }
        }
        // for (var i = 0; i < Pseudoregister_config.length; i++) {
        //     var config = Pseudoregister_config[i];
        //     for (var key in config) {
        //         if (["SlaveId", "pseudoSlaveRegister"].includes(key)) {
        //             continue;
        //         }
        //         if (!config[key] || config[key].trim() === "") {
        //             alert(`Please fill in the value for ${key} in row ${i + 1}.`);
        //             return false;
        //         }
        //         PseudoRegisterconfig[key + '_' + i] = config[key];
        //     }
        // }
        var pseudoSectionOptions = {}
        var PseudoConfigSectionName;
        var pseudocloudSectionOptions = {}
        var pseudocloudconfig = {}
        console.log("ColudDatanew", pseudocloudconfig)
        pseudocloudSectionOptions = pseudocloudconfig;
        var cdevicename = $('#pseudoDeviceName').val();

        if (cdevicename != "") {
            uniqueid = uniquepseudodevicename.includes(cdevicename)
            var PseudoConfigSectionName = cdevicename;
            pseudoconfig["pseudoDeviceName"] = $('#pseudoDeviceName').val();
            pseudoconfig["pseudoSlaveID"] = $('#pseudoSlaveID').val();
            pseudoconfig["pseudoregisterlen"] = Pseudoregister_config.length;
            pseudocloudconfig["pseudoTopicName"] = $('#pseudoTopicName').val();
            pseudocloudconfig["pseudoTopicNameTwo"] = $('#pseudoTopicNameTwo').val();
            pseudocloudconfig["pseudoJsonHeaderKeyName"] = $('#pseudoJsonHeaderKeyName').val();
            pseudocloudconfig["pseudoJsonKeyName1"] = $('#pseudoJsonKeyName1').val();
            pseudocloudconfig["pseudoJsonKeyValue1"] = $('#pseudoJsonKeyValue1').val();
            pseudocloudconfig["pseudoJsonKeyName2"] = $('#pseudoJsonKeyName2').val();
            pseudocloudconfig["pseudoJsonKeyValue2"] = $('#pseudoJsonKeyValue2').val();
            pseudocloudconfig["pseudoJsonKeyName3"] = $('#pseudoJsonKeyName3').val();
            pseudocloudconfig["pseudoJsonKeyValue3"] = $('#pseudoJsonKeyValue3').val();
            pseudocloudconfig["pseudoDataSendingMethod"] = $('#pseudoDataSendingMethod').val();

            //for checkbox1
            // var checkBox11 = document.getElementById('pseudoSlaveDataStatus');
            // var enablepseudoSlaveDataStatus = checkBox11.checked ? '1' : '0';
            // pseudocloudconfig["enablepseudoSlaveDataStatus"] = enablepseudoSlaveDataStatus;
            // for checkBox2
            // var checkBox22 = document.getElementById('pseudoSlaveCloudStatus');
            // var enablepseudoSlaveCloudStatus = checkBox22.checked ? '1' : '0';
            // pseudocloudconfig["enablepseudoSlaveCloudStatus"] = enablepseudoSlaveCloudStatus;
            //checkBox3
            var checkBox33 = document.getElementById('pseudoJsonHeaderKeyStatus');
            var enablepseudoJsonHeaderKeyStatus = checkBox33.checked ? '1' : '0';
            pseudocloudconfig["enablepseudoJsonHeaderKeyStatus"] = enablepseudoJsonHeaderKeyStatus;
            //customField1
            var checkBox44 = document.getElementById('pseudoCustomFieldStatus1');
            var enablepseudoCustomFieldStatus1 = checkBox44.checked ? '1' : '0';
            pseudocloudconfig["enablepseudoCustomFieldStatus1"] = enablepseudoCustomFieldStatus1;
            //customField2
            var checkBox55 = document.getElementById('pseudoCustomFieldStatus2');
            var enablepseudoCustomFieldStatus2 = checkBox55.checked ? '1' : '0';
            pseudocloudconfig["enablepseudoCustomFieldStatus2"] = enablepseudoCustomFieldStatus2;
            //customField3
            var checkBox66 = document.getElementById('pseudoCustomFieldStatus3');
            var enablepseudoCustomFieldStatus3 = checkBox66.checked ? '1' : '0';
            pseudocloudconfig["enablepseudoCustomFieldStatus3"] = enablepseudoCustomFieldStatus3;


            const pseudojsonHeaderKeyName = document.getElementById("pseudoJsonHeaderKeyName");
            const pseudojsonKeyName1 = document.getElementById("pseudoJsonKeyName1");
            const pseudojsonKeyValue1 = document.getElementById("pseudoJsonKeyValue1");
            const pseudojsonKeyName2 = document.getElementById("pseudoJsonKeyName2");
            const pseudojsonKeyValue2 = document.getElementById("pseudoJsonKeyValue2");
            const pseudojsonKeyName3 = document.getElementById("pseudoJsonKeyName3");
            const pseudojsonKeyValue3 = document.getElementById("pseudoJsonKeyValue3");


            function checkAllConditionspuedo(event) {
                if (checkBox33.checked) {
                    if (!pseudojsonHeaderKeyName.value.trim()) {
                        alert("Please fill in the JSON Header Key Name before submitting.");
                        pseudojsonHeaderKeyName.focus();
                        event.preventDefault();
                        return false;
                    }
                }
                if (checkBox44.checked) {
                    if ((pseudojsonKeyName1 && !pseudojsonKeyName1.value.trim()) || (pseudojsonKeyValue1 && !pseudojsonKeyValue1.value.trim())) {
                        alert("Please fill in both JSON Key Name 1 and JSON Key Value 1.");
                        if (!pseudojsonKeyName1.value.trim()) pseudojsonKeyName1.focus();
                        else pseudojsonKeyValue1.focus();
                        event.preventDefault();
                        return false;
                    }
                }

                if (checkBox55.checked) {
                    if ((pseudojsonKeyName2 && !pseudojsonKeyName2.value.trim()) || (pseudojsonKeyValue2 && !pseudojsonKeyValue2.value.trim())) {
                        alert("Please fill in both JSON Key Name 2 and JSON Key Value 2.");
                        if (!pseudojsonKeyName2.value.trim()) pseudojsonKeyName2.focus();
                        else pseudojsonKeyValue2.focus();
                        event.preventDefault();
                        return false;
                    }
                }
                if (checkBox66.checked) {
                    if ((pseudojsonKeyName3 && !pseudojsonKeyName3.value.trim()) || (pseudojsonKeyValue3 && !pseudojsonKeyValue3.value.trim())) {
                        alert("Please fill in both JSON Key Name 3 and JSON Key Value 3.");
                        if (!pseudojsonKeyName3.value.trim()) pseudojsonKeyName3.focus();
                        else pseudojsonKeyValue3.focus();
                        event.preventDefault();
                        return false;
                    }
                }
                return true;
            }


            function validateTopicNamepseudo(event) {
                var topicName = $('#pseudoTopicName');
                var topicNametwo = $('#pseudoTopicNameTwo');

                // Check if the topicName field is visible and not filled
                if (topicName.is(":visible") && topicName.css('display') === 'block' && !topicName.val().trim()) {
                    alert("Please fill in the topic name before submitting.");
                    topicName.focus();
                    event.preventDefault(); // Prevent form submission or other actions
                    return false;
                }

                // Check if the topicNametwo field is visible and not filled
                if (topicNametwo.is(":visible") && topicNametwo.css('display') === 'block' && !topicNametwo.val().trim()) {
                    alert("Please fill in the second topic name before submitting.");
                    topicNametwo.focus();
                    event.preventDefault(); // Prevent form submission or other actions
                    return false;
                }

                return true;
            }


            pseudoSectionOptions = pseudoconfig;
            for (let key in pseudoSectionOptions) {
                if (pseudoSectionOptions[key] == null || pseudoSectionOptions[key] == undefined) {
                    delete pseudoSectionOptions[key];
                }
            }
            pseudocloudSectionOptions = pseudocloudconfig;
            for (let key in pseudocloudSectionOptions) {
                if (pseudocloudSectionOptions[key] == null || pseudocloudSectionOptions[key] == undefined || pseudocloudSectionOptions[key] == "") {
                    delete pseudocloudSectionOptions[key];
                }
            }
            var status = $("#Pseudo_Sumbit").attr("name");

            if (status === "submit" && uniqueid) {
                alert("Device with the same name already exists.");
            }
            else if (!checkAllConditionspuedo(event)) {
                event.preventDefault();

            }
            else if (!validateTopicNamepseudo(event)) {
                event.preventDefault();

            }
            else {
                self.RS485DeleteUCISection("PseudoRegisterconfig", "PseudoRegisterconfig", PseudoConfigSectionName).then(function (rv) {
                    self.RS485CommitUCISection("pseudoParamconfig").then(function (res) {
                        if (res != 0) {
                            // alert("Error: Delete Sensor Configuration");
                        }
                        else {
                        }
                    });

                });

                self.RS485CreateUCISection("PseudoRegisterconfig", "PseudoRegisterconfig", PseudoConfigSectionName, PseudoRegisterconfig).then(function (rv) {
                    if (rv) {
                        if (rv.section) {
                            self.RS485CommitUCISection("PseudoRegistorconfig").then(function (res) {

                                if (res != 0) {
                                    // alert("Error:New Event Configuration");
                                }
                                else {
                                    // location.reload();
                                }
                            });
                        };
                    };
                });
                self.RS485CreateUCISection("PseudoCloudconfig", "pseudocloudConfig", PseudoConfigSectionName, pseudocloudSectionOptions).then(function (rv) {
                    if (rv) {
                        if (rv.section) {
                            self.RS485CommitUCISection("PseudoCloudconfig").then(function (res) {

                                if (res != 0) {
                                    // alert("Error:New Event Configuration");
                                }
                                else {
                                    // location.reload();
                                }
                            });
                        };
                    };
                });
                self.RS485CreateUCISection("pseudoParamconfig", "pseudoConfig", PseudoConfigSectionName, pseudoSectionOptions).then(function (rv) {
                    if (rv) {
                        if (rv.section) {
                            self.RS485CommitUCISection("pseudoParamconfig").then(function (res) {

                                if (res != 0) {
                                    // alert("Error:New Event Configuration");
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
        else {
            // alert("Please Enter Device Name");
        }
    },


    Pseudolistobject: {},
    PseudoConfigSectionEdit: function (ev) {
        var self = this;

        getuniqid = function () {
            return ev.data.PseudoConfigSectionName;
        }
        $('#pseudoDeviceName').prop('disabled', true);
        $("#updatepseudotext").css("display", "block");
        $("#updatedevice").css("display", "block");
        $("#addpseudotext").css("display", "none");
        $('#Pseudo-ModelLabel')
            .attr('name', 'UpdatePseudo') // Change the name attribute
            .text('Update Pseudo Configuration');
        $('#Pseudo_Sumbit')
            .attr('name', 'UpdatedSubmit')
            .addClass('btn btn-success') // Change the name attribute
            .text('Update');
        var self = ev.data.self;
        var PseudoConfigSectionName = ev.data.PseudoConfigSectionName;
        var Pseudoregister_config = Pseudoconfigdata();

        self.RS485GetUCISections("PseudoRegisterconfig", "PseudoRegisterconfig").then(function (rv) {
            let pseudogetregisterdata = rv[PseudoConfigSectionName]
            var Pseudo_List_object = [];
            var Pseudo_List_key = [];
            document.getElementById("PseudoRegisterSection").innerHTML = "",
                Object.keys(pseudogetregisterdata).forEach(function (key) {
                    Pseudo_List_key.push(key.split("_")[1]);
                });
            var set = [...new Set(Pseudo_List_key)];
            var data = set.filter(function (element) {
                return element !== undefined;
            });

            for (var i = 0; i < data.length; i++) {
                Pseudo_List_object.push({
                    ["pseudoRegisterName"]: pseudogetregisterdata["pseudoRegisterName_" + i],
                    ["SlaveId"]: pseudogetregisterdata["SlaveId_" + i],
                    ["pseudoSlaveRegister"]: pseudogetregisterdata["pseudoSlaveRegister_" + i]
                })
            }
            self.Pseudolistobject = Pseudo_List_object
            console.log(" self.Pseudolistobject", self.Pseudolistobject)
            self.Pseudoeditrows(Pseudo_List_object);
        });

        self.RS485GetUCISections("PseudoCloudconfig", "pseudocloudConfig").then(function (rv) {
            console.log("cloudData:", rv)
            let data2 = rv[PseudoConfigSectionName]
            var Pseudodropdown = document.getElementById("pseudoDataSendingMethod");
            var PseudotopicNameOne = document.getElementById('pseudoTopicNameField');
            var PseudodtopicNameTwo = document.getElementById('pseudoTopicNameTwoField');
            console.log(data2)
            $('#pseudoTopicName').val(data2.pseudoTopicName);
            $('#pseudoTopicNameTwo').val(data2.pseudoTopicNameTwo);
            $('#pseudoJsonHeaderKeyName').val(data2.pseudoJsonHeaderKeyName);
            $('#pseudoJsonKeyName1').val(data2.pseudoJsonKeyName1);
            $('#pseudoJsonKeyValue1').val(data2.pseudoJsonKeyValue1);
            $('#pseudoJsonKeyName2').val(data2.pseudoJsonKeyName2);
            $('#pseudoJsonKeyValue2').val(data2.pseudoJsonKeyValue2);
            $('#pseudoJsonKeyName3').val(data2.pseudoJsonKeyName3);
            $('#pseudoJsonKeyValue3').val(data2.pseudoJsonKeyValue3);
            $('#pseudoDataSendingMethod').val(data2.pseudoDataSendingMethod);

            //checkBox1
            if (data2.enablepseudoSlaveDataStatus == 1) {
                $('#pseudoSlaveDataStatus').prop('checked', true);  // Set checked
            } else {
                $('#pseudoSlaveDataStatus').prop('checked', false); // Set unchecked
            }

            // checkbox2
            if (data2.enablepseudoSlaveCloudStatus == 1) {
                $('#pseudoSlaveCloudStatus').prop('checked', true);  // Set checked
            } else {
                $('#pseudoSlaveCloudStatus').prop('checked', false); // Set unchecked
            }

            // checkbox3
            if (data2.enablepseudoJsonHeaderKeyStatus == 1) {
                $('#pseudoJsonHeaderKeyStatus').prop('checked', true);  // Set checked
            } else {
                $('#pseudoJsonHeaderKeyStatus').prop('checked', false); // Set unchecked
            }

            // customField1
            if (data2.enablepseudoCustomFieldStatus1 == 1) {
                $('#pseudoCustomFieldStatus1').prop('checked', true);  // Set checked
            } else {
                $('#pseudoCustomFieldStatus1').prop('checked', false); // Set unchecked
            }

            // customField2
            if (data2.enablepseudoCustomFieldStatus2 == 1) {
                $('#pseudoCustomFieldStatus2').prop('checked', true);  // Set checked
            } else {
                $('#pseudoCustomFieldStatus2').prop('checked', false); // Set unchecked
            }

            // customField3
            if (data2.enablepseudoCustomFieldStatus3 == 1) {
                $('#pseudoCustomFieldStatus3').prop('checked', true);  // Set checked
            } else {
                $('#pseudoCustomFieldStatus3').prop('checked', false); // Set unchecked
            }

            if (["1", "2", "3"].includes(data2.pseudoDataSendingMethod)) {

                self.RS485GetUCISections("cloudconfig", "cloudconfig").then(function (rv) {
                    var dataSlave1 = rv;
                    console.log("Editaaaaaa", rv);

                    const { cloudconfig } = dataSlave1;
                    const { cloudprotocol, cloudprotocol2, server } = cloudconfig;

                    function setDisplay(displayOne, displayTwo) {
                        PseudotopicNameOne.style.display = displayOne;
                        PseudodtopicNameTwo.style.display = displayTwo;
                        // dropdown1.value = value;
                    }
                    if (["primary"].includes(server) && cloudprotocol === 'mqtt') {
                        if (["1", "2", "3"].includes(data2.pseudoDataSendingMethod)) {
                            Pseudodropdown.value = 1;
                            setDisplay("block", "none");
                        }
                    }
                    else if (["primary"].includes(server) && cloudprotocol !== 'mqtt') {
                        if (["1", "2", "3"].includes(data2.pseudoDataSendingMethod)) {
                            Pseudodropdown.value = 1;
                            setDisplay("none", "none");
                        }

                    } else if (["both", "fallback", "primary"].includes(server) && cloudprotocol === 'mqtt' && cloudprotocol2 === 'http') {
                        if (data2.pseudoTopicName) {
                            if (data2.pseudoDataSendingMethod === "1" && data2.pseudoTopicName) {
                                console.log("12345", server);
                                Pseudodropdown.value = 1;
                                setDisplay("block", "none");
                            } else if (data2.pseudoDataSendingMethod === "3") {
                                console.log("condition3", server);
                                Pseudodropdown.value = 3;
                                setDisplay("block", "none");
                            } else if (data2.pseudoDataSendingMethod === "1") {
                                Pseudodropdown.value = 2;
                                setDisplay("none", "none");
                            }
                        } else {
                            Pseudodropdown.value = 1;
                            setDisplay("none", "none");

                        }

                    } else if (["both", "fallback"].includes(server) && cloudprotocol2 === 'mqtt' && cloudprotocol === 'http') {
                        if (data2.pseudoDataSendingMethod === "2" && data2.pseudoTopicNameTwo) {
                            console.log("123456", server);
                            Pseudodropdown.value = 2;
                            setDisplay("none", "block");
                        } else if (data2.pseudoDataSendingMethod === "3") {
                            console.log("condition3", server);
                            Pseudodropdown.value = 3;
                            setDisplay("none", "block");
                        } else if (data2.pseudoDataSendingMethod === "1") {
                            Pseudodropdown.value = 1;
                            setDisplay("none", "none");
                        }


                    } else if (data2.pseudoDataSendingMethod === "3" && data2.pseudoTopicName && data2.pseudoTopicNameTwo) {
                        if (["both", "fallback"].includes(server)) {
                            if (cloudprotocol === 'mqtt' && cloudprotocol2 === 'mqtt') {
                                console.log("condition3", server);
                                Pseudodropdown.value = 3;
                                setDisplay("block", "block");
                            } else if (cloudprotocol === 'mqtt') {
                                Pseudodropdown.value = 3;
                                console.log("condition31", cloudprotocol);
                                setDisplay("block", "none");
                            } else if (cloudprotocol2 === 'mqtt') {
                                Pseudodropdown.value = 3;
                                console.log("condition32", cloudprotocol2);
                                setDisplay("none", "block");
                            }
                        }
                    } else if (["both", "fallback"].includes(server) && cloudprotocol2 === 'mqtt' && cloudprotocol === 'mqtt') {
                        if (data2.pseudoDataSendingMethod === "2") {
                            console.log("condition3", server);
                            Pseudodropdown.value = 2;
                            setDisplay("none", "block");
                        } else {
                            Pseudodropdown.value = 1;
                            setDisplay("block", "none");

                        }
                    }
                });
            }
        });

        var editdevice1 = Pseudoregister_config[PseudoConfigSectionName];
        console.log("Pseudoeditdevice:", editdevice1)
        $('#pseudoDeviceName').val(editdevice1.pseudoDeviceName);
        $('#pseudoSlaveID').val(editdevice1.pseudoSlaveID);
        $('#Pseudo-Model').modal('show');

    },


    PseudoConfigSectionRemove: function (ev) {
        var self = ev.data.self;
        var PseudoConfigSectionName = ev.data.PseudoConfigSectionName;
        // Remove the specific RS485 config section
        self.RS485DeleteUCISection("pseudoParamconfig", "pseudoConfig", PseudoConfigSectionName).then(function (rv) {
            if (rv == 0) {
                self.RS485CommitUCISection("pseudoParamconfig").then(function (res) {
                    if (res != 0) {
                        alert("Error: Delete Sensor Configuration");
                    }
                    else {
                        location.reload();
                    }
                });
            }
        });
        self.RS485DeleteUCISection("PseudoRegisterconfig", "PseudoRegisterconfig", PseudoConfigSectionName).then(function (rv) {
            if (rv == 0) {
                self.RS485CommitUCISection("PseudoRegisterconfig").then(function (res) {
                    if (res != 0) {
                        alert("Error: Delete Sensor Configuration");
                    }
                    else {
                        location.reload();
                    }
                });
            }
        });
        self.RS485DeleteUCISection("PseudoCloudconfig", "pseudocloudConfig", PseudoConfigSectionName).then(function (rv) {
            if (rv == 0) {
                self.RS485CommitUCISection("PseudoCloudconfig").then(function (res) {
                    if (res != 0) {
                        alert("Error: Delete Sensor Configuration");
                    }
                    else {
                        location.reload();
                    }
                });
            }
        });
    },










    //Each Section Row edit 
    CounterRegister: 0,
    editrows: function (editdata) {
        var self = this;
        console.log("function entered");
        if (editdata && editdata.length > 0) {
            console.log("Register edited", editdata);
            document.getElementById('Registersection').innerHTML = "";


            self.CounterRegister = 0;
            editdata.forEach((rowData, index) => {
                console.log("register row", rowData)
                var _edit_register = document.createElement('div');
                _edit_register.innerHTML = `
                    <div class="row" style="margin-top:5px;">
                        <div class="col-md-2">
                            <label id="requiredfield">Register Name</label>
                            <input type="text" id="registername${self.CounterRegister}" class="form-control" name="Register Name">
                        </div>
                        <div class="col-md-2">
                            <label id="requiredfield">Start Register</label>
                            <input type="text" id="startregister${self.CounterRegister}" class="form-control" name="Start Register">
                        </div>
                        <div class="col-md-2">
                            <label id="requiredfield">Register Count</label>
                            <input type="text" id="registercount${self.CounterRegister}" class="form-control" name="Register Count">
                        </div>
                        <div class="col-md-2">
                            <label id="requiredfield">Datatype</label>
                            <select id="Datatype${self.CounterRegister}" class="form-control" name="DatatypeD" onchange="handleDatatypeCodeChange(${self.CounterRegister})">
                                <option value="">Select</option>
                                <option value="0">Hexadecimal</option>
                                <option value="1">Floating Point</option>
                                <option value="2">Floating Point (Swapped Byte)</option>
                                <option value="3">16-bit UINT (High Byte First)</option>
                                <option value="4">16-bit UINT (Low Byte First)</option>
                                <option value="5">16-bit INT (High Byte First)</option>
                                <option value="6">16-bit INT (Low Byte First)</option>
                                <option value="7">32-bit UINT (Byte Order 1,2,3,4)</option>
                                <option value="8">32-bit UINT (Byte Order 4,3,2,1)</option>
                                <option value="9">32-bit INT (Byte Order 1,2,3,4)</option>
                                <option value="10">32-bit INT (Byte Order 4,3,2,1)</option>
                                <option value="11">1-bit</option>
                            </select>
                        </div>
                        <div class="col-md-2">
                            <label>Multifactor</label>
                            <input type="number" id="multifactor${self.CounterRegister}" oninput="validatefcatory(this)"class="form-control">
                        </div>
                        <div class="col-md-2">
                            <input type="button" value="Delete" id="RegisterremoveButton${self.CounterRegister}" 
                                onclick="removeRegister(event)" class="btn btn-primary" style="margin-top:26px">
                        </div>
                    </div>
                `;
                console.log(_edit_register)

                document.getElementById('Registersection').appendChild(_edit_register);


                document.getElementById('registername' + self.CounterRegister).value = rowData.registername;
                document.getElementById('startregister' + self.CounterRegister).value = rowData.startregister;
                document.getElementById('registercount' + self.CounterRegister).value = rowData.registercount;
                document.getElementById('Datatype' + self.CounterRegister).value = rowData.Datatype;
                document.getElementById('multifactor' + self.CounterRegister).value = rowData.multifactor;


                const multifactorElement = document.getElementById('multifactor' + self.CounterRegister);
                if (rowData.Datatype === "0" || rowData.Datatype === "11") {
                    multifactorElement.style.display = 'none';
                } else {
                    multifactorElement.style.display = 'block';
                }

                self.CounterRegister++;
            });
        }
    },



    CounterBlock: 0,
    Blockeditrows: function (editdata) {
        var self = this;
        console.log("block dateee", editdata)

        if (editdata !== undefined && editdata.length > 0) {

            document.getElementById('Blockregistersection').innerHTML = "";

            self.CounterBlock = 0;
            editdata.forEach(function (blockData, index) {

                var _edit_blockrows = document.createElement('div');
                _edit_blockrows.classList.add("row");
                _edit_blockrows.style.marginTop = "5px";
                _edit_blockrows.innerHTML = `
                    <div class="col-md-3">
                        <label id="requiredfield">Function Code</label>
                        <select id="functionCode${self.CounterBlock}" class="form-control inputbox" name="Function Code" onchange="handleFunctionBlockConfig(${self.CounterBlock})">
                            <option value="1">1</option>
                            <option value="2">2</option>
                            <option value="3">3</option>
                            <option value="4">4</option>
                        </select>
                    </div>
                    <div class="col-md-3">
                        <label id="requiredfield">Start Register</label>
                        <input type="number" id="startRegister${self.CounterBlock}" class="form-control inputbox" name="Start Register" onchange="handleFunctionBlockConfig(${self.CounterBlock})">
                    </div>
                    <div class="col-md-3">
                        <label id="requiredfield">Count Register</label>
                        <input type="text" id="countRegister${self.CounterBlock}" class="form-control inputbox" name="Count Register">
                    </div>
                    <div class="col-md-2">
                        <input type="button" value="Delete" id="BlockremoveButton,${self.CounterBlock}" onclick="removeBlock(event)" class="btn btn-primary" style="margin-top:26px;">
                    </div>
                `;


                document.getElementById('Blockregistersection').appendChild(_edit_blockrows);


                $('#functionCode' + self.CounterBlock).val(blockData.functionCode);
                $('#startRegister' + self.CounterBlock).val(blockData.startRegister);
                $('#countRegister' + self.CounterBlock).val(blockData.countRegister);


                self.CounterBlock++;
            });
        }
    },

    CounterAlarm: 0,
    Alarmeditrows: function (editdata) {
        var self = this;


        if (!editdata || editdata.length === 0) return;
        editdata.forEach(item => {
            for (let key in item) {
                if (item[key] === undefined) item[key] = "disabled";
            }
        });
        document.getElementById('Alarm_Event_section').innerHTML = "";
        self.CounterAlarm = 0;

        editdata.forEach((data, index) => {

            // Create a new alarm section
            var _edit_alarm_rows = document.createElement('div');
            _edit_alarm_rows.innerHTML = `
                <div class="row" style="margin-top: 5px;">
                    <div class="col-sm-1">
                        <label id="requiredfield">Category</label>
                        <select id="Category${self.CounterAlarm}" class="form-control inputbox" name="Category" onchange="handleFunctionCodeChange(${self.CounterAlarm})">
                            <option value="1">Alarm</option>
                            <option value="2">Event</option>
                        </select>
                    </div>
                    <div class="col-sm-1">
                        <label id="requiredfield">Status</label>
                        <select id="alarmEnabled${self.CounterAlarm}" class="form-control inputbox" name="Status">
                            <option value="0">Disabled</option>
                            <option value="1">Enabled</option>
                        </select>
                    </div>
                    <div class="col-sm-1">
                        <label id="requiredfield">Name</label>
                        <input type="textbox" id="alarmName${self.CounterAlarm}" class="form-control inputbox" name="Name">
                    </div>
                    <div class="col-sm-1">
                        <label >Function Code</label>
                        <select id="Code${self.CounterAlarm}" class="form-control"  onchange="handleRegisterAndAlarmConfig(${self.CounterAlarm})">
                            <option value="1">1</option>
                            <option value="2">2</option>
                            <option value="3">3</option>
                            <option value="4">4</option>
                        </select>
                    </div>
                    <div class="col-sm-1">
                        <label id="requiredfield">Start Reg</label>
                        <input type="number" id="regAlarm${self.CounterAlarm}" class="form-control inputbox" name="Start Reg" onchange="handleRegisterAndAlarmConfig(${self.CounterAlarm})">
                    </div>
                    <div class="col-sm-1">
                        <label  id="requiredfield">No_of Reg</label>
                        <input type="number" id="alarmCount${self.CounterAlarm}" class="form-control inputbox" name="No_of Reg">
                    </div>
                    <div class="col-sm-1">
                        <label id="requiredfield">Data Type</label>
                        <select id="alarmDatatype${self.CounterAlarm}" class="form-control inputbox" name="Data Type" onchange="handleFunctionCodeChange(${self.CounterAlarm})">
                            <option value="">Select</option>
                            <option value="0">Hexdecimal</option>
                            <option value="1">Floating Point</option>
                            <option value="2">Floating Point (Swapped byte)</option>
                            <option value="3">16 bit UINT (high byte first)</option>
                            <option value="4">16 bit UINT (low byte first)</option>
                            <option value="5">16 bit INT (high byte first)</option>
                            <option value="6">16 bit INT (low byte first)</option>
                            <option value="7">32 bit UINT (byte order 1,2,3,4)</option>
                            <option value="8">32 bit UINT (byte order 4,3,2,1)</option>
                            <option value="9">32 bit INT (byte order 1,2,3,4)</option>
                            <option value="10">32 bit INT (byte order 4,3,2,1)</option>
                            <option value="11">Boolean</option>
                        </select>
                    </div>
                    <div class="col-sm-1">
                        <label >Upper Thresh</label>
                        <input type="number" id="uprThreshold${self.CounterAlarm}" class="form-control">
                    </div>
                    <div class="col-sm-1">
                        <label >Upper Hys</label>
                        <input type="number" id="uprHysteresis${self.CounterAlarm}" class="form-control">
                    </div>
                    <div class="col-sm-1">
                        <label>Lower Thresh</label>
                        <input type="number" id="lowerThreshold${self.CounterAlarm}" class="form-control">
                    </div>
                    <div class="col-sm-1">
                        <label >Lower Hys</label>
                        <input type="number" id="lowerHysteresis${self.CounterAlarm}" class="form-control">
                    </div>
                    <div class="col-sm-1">
                        <input type="button" value="Delete" id="AlarmremoveButton,${self.CounterAlarm}" onclick="removeAlarm(event)" class="btn btn-primary" style="margin-top:26px">
                    </div>
                </div>
            `;


            document.getElementById('Alarm_Event_section').appendChild(_edit_alarm_rows);


            document.getElementById(`Category${self.CounterAlarm}`).value = data.Category;
            document.getElementById(`alarmEnabled${self.CounterAlarm}`).value = data.alarmEnabled;
            document.getElementById(`alarmName${self.CounterAlarm}`).value = data.alarmName !== "disabled" ? data.alarmName : "";
            document.getElementById(`Code${self.CounterAlarm}`).value = data.Code;
            document.getElementById(`regAlarm${self.CounterAlarm}`).value = data.regAlarm;
            document.getElementById(`alarmCount${self.CounterAlarm}`).value = data.alarmCount;
            document.getElementById(`alarmDatatype${self.CounterAlarm}`).value = data.alarmDatatype;
            document.getElementById(`uprThreshold${self.CounterAlarm}`).value = data.uprThreshold;
            document.getElementById(`uprHysteresis${self.CounterAlarm}`).value = data.uprHysteresis;
            document.getElementById(`lowerThreshold${self.CounterAlarm}`).value = data.lowerThreshold;
            document.getElementById(`lowerHysteresis${self.CounterAlarm}`).value = data.lowerHysteresis;


            const isBoolean = data.alarmDatatype === "11";
            document.getElementById(`uprThreshold${self.CounterAlarm}`).style.display = isBoolean ? 'none' : 'block';
            document.getElementById(`uprHysteresis${self.CounterAlarm}`).style.display = isBoolean ? 'none' : 'block';
            document.getElementById(`lowerThreshold${self.CounterAlarm}`).style.display = isBoolean ? 'none' : 'block';
            document.getElementById(`lowerHysteresis${self.CounterAlarm}`).style.display = isBoolean ? 'none' : 'block';


            // Increment the counter for the next section
            self.CounterAlarm++;
        });
    },




    // PseudoRegisterCounter: 0,
    // Pseudoeditrows: function (editdata) {
    //     console.log("Edit data", editdata);
    //     var self = this;
    //     function populateDropdowns(slaveIDDropdown1, slaveIDDropdown2, selectedSlaveID, selectedSlaveRegister) {
    //         var $slaveIDDropdown = $('#' + slaveIDDropdown1);
    //         var $registerNameDropdown = $('#' + slaveIDDropdown2);
    //         $slaveIDDropdown.empty();
    //         $registerNameDropdown.empty();
    //         var modbusDevices = configdata();
    //         console.log("Modbus Device Data:", modbusDevices);
    //         if (modbusDevices && Object.keys(modbusDevices).length > 0) {
    //             Object.keys(modbusDevices).forEach(function (key) {
    //                 var device = modbusDevices[key];
    //                 console.log("Device:", device);
    //                 if (device.serialdeviceid && device.serialslaveid) {
    //                     // Set the value as 'device.serialdeviceid_device.serialslaveid'
    //                     var optionValue = device.serialdeviceid + '_' + device.serialslaveid;
    //                     $slaveIDDropdown.append(new Option(device.serialdeviceid + ' (Slave ID: ' + device.serialslaveid + ')', optionValue));
    //                 }
    //             });

    //             if (selectedSlaveID) {
    //                 // Set selected value
    //                 $slaveIDDropdown.val(selectedSlaveID);  // Set selected Slave ID
    //             }

    //             if (selectedDevice) {
    //                 // Get the selected option's text
    //                 var selectedDevice = $slaveIDDropdown.find("option:selected").text(); // Get the text of the selected option
    //                 alert(selectedDevice); // Show the full text of the selected option
    //             }

    //             $slaveIDDropdown.off("change").on("change", function () {
    //                 debugger
    //                 var selectedSlaveID = $(this).val();
    //                 var Test23434 = selectedSlaveID.split("_")[0]// Get the selected value (now in the format 'Device123_001')
    //                 var selectedDevice = $(this).find("option:selected").text();
    //                 var deviceName12345 = selectedDevice.split(" (")[0]; // Get the selected text
    //                 console.log('Slave ID changed to:', selectedSlaveID);
    //                 console.log('Selected Device:', deviceName12345); // Log the selected device text
    //                 $registerNameDropdown.empty();
    //                 self.RS485GetUCISections("registerconfig", "registerconfig").then(function (rv) {
    //                     let getregistrdata = rv;
    //                     if (getregistrdata && Object.keys(getregistrdata).length > 0) {
    //                         let hasRegisters = false;
    //                         // Now, use the selectedSlaveID in the form 'Device123_001' to find the matching device
    //                         var selectedDevice = Object.values(modbusDevices).find(dev => (dev.serialdeviceid + '_' + dev.serialslaveid === selectedSlaveID));
    //                         if (selectedDevice) {
    //                             var ModbusName = Test23434;
    //                             console.log("Selected Device ModbusName:", ModbusName);

    //                             Object.keys(getregistrdata).forEach(function (key) {
    //                                 var device = getregistrdata[key];
    //                                 var sectionName = device[".name"];
    //                                 if (sectionName === ModbusName) {
    //                                     for (let i = 0; ; i++) {
    //                                         let registerKey = 'registername_' + i;
    //                                         if (!device.hasOwnProperty(registerKey)) break;

    //                                         if (device[registerKey]) {
    //                                             $registerNameDropdown.append(new Option(device[registerKey], device[registerKey]));
    //                                             hasRegisters = true;
    //                                         }
    //                                     }
    //                                 }
    //                             });
    //                         }

    //                         if (!hasRegisters) {
    //                             $registerNameDropdown.append(new Option("No registers found", ""));
    //                         }
    //                     } else {
    //                         console.log("No register data found.");
    //                         $registerNameDropdown.append(new Option("No registers found", ""));
    //                     }
    //                 });
    //             });

    //             $slaveIDDropdown.trigger('change'); // Trigger change to populate registers
    //         } else {
    //             $slaveIDDropdown.append(new Option("No Modbus devices found", ""));
    //         }
    //     }

    //     if (editdata && editdata.length > 0) {
    //         console.log("Register edited", editdata);

    //         document.getElementById('PseudoRegisterSection').innerHTML = "";
    //         self.PseudoRegisterCounter = 0;

    //         editdata.forEach((rowData, index) => {
    //             console.log("Register row data", rowData)
    //             var _edit_Pseudoregister = document.createElement('div');
    //             _edit_Pseudoregister.innerHTML = `
    //                 <div class="row" style="margin-top:5px;">
    //                     <div class="col-md-3">
    //                         <label>Pseudo Register Name</label>
    //                         <input type="text" id="pseudoRegisterName${self.PseudoRegisterCounter}" class="form-control">
    //                     </div>
    //                     <div class="col-md-3">
    //                         <label>Slave ID</label>
    //                         <select id="SlaveId${self.PseudoRegisterCounter}" class="form-control">

    //                         </select>
    //                     </div>
    //                     <div class="col-md-3">
    //                         <label>Pseudo Slave Register</label>
    //                         <select id="pseudoSlaveRegister${self.PseudoRegisterCounter}" class="form-control">

    //                         </select>
    //                     </div>
    //                     <div class="col-md-2">
    //                         <input type="button" value="Delete" id="pseudoRemoveButton,${self.PseudoRegisterCounter}" onclick="removePseudoRegister(event)" class="btn btn-primary" style="margin-top:26px;">
    //                     </div>
    //                 </div>`;

    //             // Append the new row to the Registersection container
    //             document.getElementById('PseudoRegisterSection').appendChild(_edit_Pseudoregister);
    //             console.log(document.getElementById('PseudoRegisterSection').appendChild(_edit_Pseudoregister))

    //             populateDropdowns('SlaveId' + self.PseudoRegisterCounter, 'pseudoSlaveRegister' + self.PseudoRegisterCounter, rowData.SlaveId, rowData.pseudoSlaveRegister);
    //             $('#pseudoRegisterName' + self.PseudoRegisterCounter).val(rowData.pseudoRegisterName);

    //             self.PseudoRegisterCounter++;

    //             var _prious_count = self.PseudoRegisterCounter;
    //             localStorage.setItem("_previous_count", _prious_count);
    //         })
    //     };
    // },


    PseudoRegisterCounter: 0,
    Pseudoeditrows: function (editdata) {
        console.log("Edit data", editdata);
        var self = this;

        // Function to populate dropdowns dynamically
        function populateDropdowns(slaveIDDropdown1, slaveIDDropdown2, selectedSlaveID, selectedSlaveRegister) {
            var $slaveIDDropdown = $('#' + slaveIDDropdown1);
            var $registerNameDropdown = $('#' + slaveIDDropdown2);
            $slaveIDDropdown.empty();
            $registerNameDropdown.empty();
            var modbusDevices = configdata(); // Get the modbus device data
            console.log("Modbus Device Data:", modbusDevices);

            if (modbusDevices && Object.keys(modbusDevices).length > 0) {
                // Populate Slave ID dropdown
                Object.keys(modbusDevices).forEach(function (key) {
                    var device = modbusDevices[key];
                    console.log("Device:", device);
                    if (device.serialdeviceid && device.serialslaveid) {
                        $slaveIDDropdown.append(new Option(device.serialdeviceid + ' (Slave ID: ' + device.serialslaveid + ')', device.serialdeviceid + '_' + device.serialslaveid));
                    }
                });

                // Set the selected Slave ID
                if (selectedSlaveID) {
                    $slaveIDDropdown.val(selectedSlaveID);
                    populateRegistersForSelectedSlave(selectedSlaveID, selectedSlaveRegister, modbusDevices, slaveIDDropdown2);
                }

                // Event listener for when Slave ID changes
                $slaveIDDropdown.off("change").on("change", function () {
                    var selectedSlaveID = $(this).val(); // Get the selected value in format 'serialdeviceid_serialslaveid'
                    var selectedDevice = $(this).find("option:selected").text();
                    var deviceName123 = selectedDevice.split(" (")[0];
                    console.log('Slave ID changed to:', selectedSlaveID);
                    $registerNameDropdown.empty();
                    populateRegistersForSelectedSlave(selectedSlaveID, null, modbusDevices, slaveIDDropdown2);
                });

                // Trigger change to populate registers if Slave ID is already selected
                $slaveIDDropdown.trigger('change');
            } else {
                $slaveIDDropdown.append(new Option("No Modbus devices found", ""));
            }
        }

        // Function to populate registers for the selected slave
        function populateRegistersForSelectedSlave(selectedSlaveID, selectedSlaveRegister, modbusDevices, registerDropdownID) {
            var $registerNameDropdown = $('#' + registerDropdownID);
            $registerNameDropdown.empty(); // Clear dropdown first

            self.RS485GetUCISections("registerconfig", "registerconfig").then(function (rv) {
                let getregistrdata = rv;
                if (getregistrdata && Object.keys(getregistrdata).length > 0) {
                    let hasRegisters = false;
                    var [selectedDeviceID, selectedSlaveIDOnly] = selectedSlaveID.split('_');
                    var selectedDevice = Object.values(modbusDevices).find(dev => (dev.serialdeviceid === selectedDeviceID) && (dev.serialslaveid === selectedSlaveIDOnly));

                    if (selectedDevice) {
                        Object.keys(getregistrdata).forEach(function (key) {
                            var device = getregistrdata[key];
                            var sectionName = device[".name"];
                            if (sectionName === selectedDeviceID) {
                                for (let i = 0; ; i++) {
                                    let registerKey = 'registername_' + i;
                                    if (!device.hasOwnProperty(registerKey)) break;

                                    let registerOption = new Option(device[registerKey], device[registerKey]);
                                    if (device[registerKey] === selectedSlaveRegister) {
                                        registerOption.selected = true; // Mark the selected register
                                    }
                                    $registerNameDropdown.append(registerOption);
                                    hasRegisters = true;
                                }
                            }
                        });
                    }

                    if (!hasRegisters) {
                        $registerNameDropdown.append(new Option("No registers found", ""));
                    }
                } else {
                    $registerNameDropdown.append(new Option("No registers found", ""));
                }
            });
        }

        // If there is data to edit, populate the section
        if (editdata && editdata.length > 0) {
            console.log("Register edited", editdata);

            document.getElementById('PseudoRegisterSection').innerHTML = "";
            self.PseudoRegisterCounter = 0;

            editdata.forEach((rowData, index) => {
                console.log("Register row data", rowData);
                var _edit_Pseudoregister = document.createElement('div');
                _edit_Pseudoregister.innerHTML = `
                    <div class="row" style="margin-top:5px;">
                        <div class="col-md-3">
                            <label id="requiredfield">Pseudo Register Name</label>
                            <input type="text" id="pseudoRegisterName${self.PseudoRegisterCounter}" class="form-control inputbox" name="Pseudo Register Name">
                        </div>
                        <div class="col-md-3">
                            <label>Slave ID</label>
                            <select id="SlaveId${self.PseudoRegisterCounter}" class="form-control"></select>
                        </div>
                        <div class="col-md-3">
                            <label>Pseudo Slave Register</label>
                            <select id="pseudoSlaveRegister${self.PseudoRegisterCounter}" class="form-control"></select>
                        </div>
                        <div class="col-md-2">
                            <input type="button" value="Delete" id="pseudoRemoveButton${self.PseudoRegisterCounter}" onclick="removePseudoRegister(event)" class="btn btn-primary" style="margin-top:26px;">
                        </div>
                    </div>`;

                // Append the new row to the Registersection container
                document.getElementById('PseudoRegisterSection').appendChild(_edit_Pseudoregister);
                console.log("Appending new pseudo-register:", _edit_Pseudoregister);

                // Populate dropdowns with the selected Slave ID and Register
                populateDropdowns('SlaveId' + self.PseudoRegisterCounter, 'pseudoSlaveRegister' + self.PseudoRegisterCounter, rowData.SlaveId, rowData.pseudoSlaveRegister);
                $('#pseudoRegisterName' + self.PseudoRegisterCounter).val(rowData.pseudoRegisterName);

                self.PseudoRegisterCounter++;
            });

            var _previous_count = self.PseudoRegisterCounter;
            localStorage.setItem("_previous_count", _previous_count);
        }
    },















    changemodbusprotocol: function () {
        var protocolSelect = document.getElementById('protocol');
        var tcpOptions = document.getElementById('TCP_Paramters');
        var RTU_Common_Options = document.getElementById('ModbusRTU_Common_Parameters');
        var RTUOptions = document.getElementById('ModbusRTU_Paramters');
        if (protocolSelect.value === 'TCP') {
            tcpOptions.style.display = 'block';
            RTU_Common_Options.style.display = 'none';
            RTUOptions.style.display = 'none';

        } else {
            tcpOptions.style.display = 'none';
            RTU_Common_Options.style.display = 'block';
            RTUOptions.style.display = 'block';
        }
    },

    deleteDevice: function () {
        $.ajax({
            url: '/cgi-bin/delete_file.cgi', // Make sure this URL matches your CGI script's location
            type: 'GET',
            success: function (data) {
            },
            error: function (xhr, status, error) {
            }
        });
    },

    AddBlockSection: function () {
        if (this.CounterBlock > 20) {
            return alert("Maximum block configurations allowed is 20 only.");
        }
        var self = this;
        if (typeof this.CounterBlock === 'undefined') {
            this.CounterBlock = 0;
        }
        var new_blocksection = document.createElement('div');
        new_blocksection.innerHTML = `
            <div class="row" style="margin-top:5px";>
                <div class="col-md-3">
                     <label id="requiredfield">Function Code</label>
                    <select id="functionCode${self.CounterBlock}" class="form-control inputbox" name="Function Code" onchange="handleFunctionBlockConfig(${self.CounterBlock})">
                        <option value="1">1</option>
                        <option value="2">2</option>
                        <option value="3">3</option>
                        <option value="4">4</option>
                    </select>
                </div>
                <div class="col-md-3">
                  <label id="requiredfield">Start Register</label>
                    <input type="number" id="startRegister${self.CounterBlock}" class="form-control inputbox" name="Start Register" onchange="handleFunctionBlockConfig(${self.CounterBlock})">
                </div>
                <div class="col-md-3">
                  <label id="requiredfield">Count Register</label>
                    <input type="text" id="countRegister${self.CounterBlock}" class="form-control inputbox" name="Count Register">
                </div>
                <div class="col-md-2">
                    <input type="button" value="Delete"   id="BlockremoveButton,${self.CounterBlock}" onclick="removeBlock(event)" class="btn btn-primary" style="margin-top:26px";>
                </div>
            </div>`;
        // Append to Blockregistersection
        document.getElementById('Blockregistersection').appendChild(new_blocksection);
        this.CounterBlock++;
    },


    AddRegisterSection: function () {
        var self = this;
        if (typeof this.CounterRegister === 'undefined') {
            this.CounterRegister = 0;
        }
        var new_Registersection = document.createElement('div');
        new_Registersection.innerHTML = `
       <div class="row" style="margin-top:5px";>
            <div class="col-md-2">
            <label id="requiredfield">Register Name</label>
                <input type="textbox" id="registername${self.CounterRegister}" class="form-control inputbox" name="Register Name">
            </div>
            <div class="col-md-2">
             <label id="requiredfield">Start Register</label>
                <input type="textbox" id="startregister${self.CounterRegister}" class="form-control inputbox"  name="Start Register">
            </div>
            <div class="col-md-2">
             <label id="requiredfield">Register Count</label>
                <input type="textbox" id="registercount${self.CounterRegister}" class="form-control inputbox"  name="Register Count">
            </div>
            <div class="col-md-2">
             <label id="requiredfield">Datatype</label>
                <select id="Datatype${self.CounterRegister}" class="form-control inputbox" name="Datatype" onchange="handleDatatypeCodeChange(${self.CounterRegister})">
                    <option value="">Select</option>
                    <option value="0">Hexdecimal</option>
                    <option value="1">Floating Point</option>
                    <option value="2">Floating Point(Swapped byte)</option>
                    <option value="3">16 bit UINT (high byte first)</option>
                    <option value="4">16 bit UINT (low byte first)</option>
                    <option value="5">16 bit INT (high byte first)</option>
                    <option value="6">16 bit INT (low byte first)</option>
                    <option value="7">32 bit UINT (byte order 1,2,3,4)</option>
                    <option value="8">32 bit UINT ( byte order 4,3,2,1)</option>
                    <option value="9">32 bit INT (byte order 1,2,3,4)</option>
                    <option value="10">32 bit INT (byte order 4,3,2,1)</option>
                    <option value="11">1 bit</option>
                </select>
            </div>
            <div class="col-md-2">
             <label >Multifactor</label>
                <input type="number" id="multifactor${self.CounterRegister}" oninput="validatefcatory(this)"class="form-control">
            </div>
            <div class="col-md-2">
                <input type="button" value="Delete" id="RegisterremoveButton,${self.CounterRegister}" onclick="removeRegister(event)" class="btn btn-primary" style="margin-top:26px">
            </div>
            </div>
        `;
        document.getElementById('Registersection').appendChild(new_Registersection);
        self.CounterRegister++;
    },



    AddAlarmSection: function () {
        var self = this;
        if (typeof this.CounterAlarm === 'undefined') {
            this.CounterAlarm = 0;
        }
        var new_Alarmsection = document.createElement('div');
        new_Alarmsection.innerHTML = `
            <div class="row" style="margin-top: 5px; ">
                <div class="col-sm-1">
                <label id="requiredfield">Category</label>
                    <select id="Category${self.CounterAlarm}" class="form-control inputbox"  name="Category" onchange="handleFunctionCodeChange(${self.CounterAlarm})">
                        <option value="1">Alarm</option>
                        <option value="2">Event</option>
                    </select>
                </div>
                <div class="col-sm-1">
                <label id="requiredfield">Status</label>
                    <select id="alarmEnabled${self.CounterAlarm}" class="form-control inputbox"  name="Status" >
                        <option value="0">Disabled</option>
                        <option value="1">Enabled</option>
                    </select>
                </div>
                <div class="col-sm-1">
                <label id="requiredfield">Name</label>
                    <input type="textbox" id="alarmName${self.CounterAlarm}" class="form-control inputbox" name="Name">
                </div>
                <div class="col-sm-1">
                <label>Function Code</label>
                    <select id="Code${self.CounterAlarm}" class="form-control" onchange="handleRegisterAndAlarmConfig(${self.CounterAlarm})">
                        <option value="1">1</option>
                        <option value="2">2</option>
                        <option value="3">3</option>
                        <option value="4">4</option>
                    </select>
                </div>
                <div class="col-sm-1">
                <label id="requiredfield">Start Reg</label>
                    <input type="number" id="regAlarm${self.CounterAlarm}" class="form-control inputbox" name="Start Reg" onchange="handleRegisterAndAlarmConfig(${self.CounterAlarm})">
                </div>
                <div class="col-sm-1">
                <label id="requiredfield">No_of Reg</label>
                    <input type="number" id="alarmCount${self.CounterAlarm}" class="form-control inputbox" name="No_of Reg">
                </div>
                <div class="col-sm-1">
                 <label id="requiredfield">Data Type</label>
                    <select id="alarmDatatype${self.CounterAlarm}" class="form-control inputbox" name="Data Type" onchange="handleFunctionCodeChange(${self.CounterAlarm})">
                        <option value="">Select</option>
                        <option value="0">Hexdecimal</option>
                        <option value="1">Floating Point</option>
                        <option value="2">Floating Point (Swapped byte)</option>
                        <option value="3">16 bit UINT (high byte first)</option>
                        <option value="4">16 bit UINT (low byte first)</option>
                        <option value="5">16 bit INT (high byte first)</option>
                        <option value="6">16 bit INT (low byte first)</option>
                        <option value="7">32 bit UINT (byte order 1,2,3,4)</option>
                        <option value="8">32 bit UINT (byte order 4,3,2,1)</option>
                        <option value="9">32 bit INT (byte order 1,2,3,4)</option>
                        <option value="10">32 bit INT (byte order 4,3,2,1)</option>
                        <option value="11">Boolean</option>
                    </select>
                </div>
                <div class="col-sm-1">
                <label>Upper Thresh</label>
                    <input type="number" id="uprThreshold${self.CounterAlarm}" class="form-control">
                </div>
                <div class="col-sm-1">
                <label >Upper Hys</label>
                    <input type="number" id="uprHysteresis${self.CounterAlarm}" class="form-control">
                </div>
                <div class="col-sm-1">
                 <label>Lower Thresh</label>
                    <input type="number" id="lowerThreshold${self.CounterAlarm}" class="form-control">
                </div>
                <div class="col-sm-1">
                <label>Lower Hys</label>
                    <input type="number" id="lowerHysteresis${self.CounterAlarm}" class="form-control">
                </div>
                <div class="col-sm-1">
                    <input type="button" value="Delete" id="AlarmremoveButton,${self.CounterAlarm}" onclick="removeAlarm(event)" class="btn btn-primary" style="margin-top:26px">
                </div>
            </div>
        `;


        document.getElementById('Alarm_Event_section').appendChild(new_Alarmsection);
        self.CounterAlarm++;
    },



    AddPseudoRegistersection: function () {
        var self = this;
        if (typeof this.PseudoRegisterCounter === 'undefined') {
            this.PseudoRegisterCounter = 0;
        }
        var new_Pseudoregistersection = document.createElement('div');
        new_Pseudoregistersection.innerHTML = `
            <div class="row" style="margin-top:5px;">
                <div class="col-md-3">
                    <label id="requiredfield">Pseudo Register Name</label>
                    <input type="text" id="pseudoRegisterName${self.PseudoRegisterCounter}" class="form-control inputbox" name="Pseudo Register Name">
                </div>
                <div class="col-md-3">
                    <label>Slave ID</label>
                    <select id="SlaveId${self.PseudoRegisterCounter}" class="form-control">
                       
                    </select>
                </div>
                <div class="col-md-3">
                    <label>Pseudo Slave Register</label>
                    <select id="pseudoSlaveRegister${self.PseudoRegisterCounter}" class="form-control">
                       
                    </select>
                </div>
                <div class="col-md-2">
                    <input type="button" value="Delete" id="pseudoRemoveButton,${self.PseudoRegisterCounter}" onclick="removePseudoRegister(event)" class="btn btn-primary" style="margin-top:26px;">
                </div>
            </div>`;
        // Append to Pseudoregistersection
        document.getElementById('PseudoRegisterSection').appendChild(new_Pseudoregistersection);
        self.PseudoRegisterCounter++;
    },






    PseudoModbusDropdowns: function () {
        var self = this;
        var data = self.PseudoRegisterCounter;
        console.log("cuonxjbsba", data);
        var slaveIDDropdown1 = 'SlaveId' + (data - 1);
        var slaveIDDropdown2 = 'pseudoSlaveRegister' + (data - 1);

        populateDropdowns(slaveIDDropdown1, slaveIDDropdown2);

        function populateDropdowns(slaveIDDropdown1, slaveIDDropdown2) {
            var $slaveIDDropdown = $('#' + slaveIDDropdown1);
            var $registerNameDropdown = $('#' + slaveIDDropdown2);
            $slaveIDDropdown.empty();
            $registerNameDropdown.empty();
            var modbusDevices = configdata();

            if (modbusDevices && Object.keys(modbusDevices).length > 0) {
                Object.keys(modbusDevices).forEach(function (key, index) {
                    var device = modbusDevices[key];
                    if (device.serialdeviceid && device.serialslaveid) {
                        // Set the option value as 'serialdeviceid_serialslaveid'
                        $slaveIDDropdown.append(new Option(device.serialdeviceid + ' (Slave ID: ' + device.serialslaveid + ')', device.serialdeviceid + '_' + device.serialslaveid));
                    }
                    // Auto-select for 1st one
                    if (index === 0) {
                        var firstSlaveID = device.serialdeviceid + '_' + device.serialslaveid;
                        $slaveIDDropdown.val(firstSlaveID);
                        populateRegistersForSelectedSlave(firstSlaveID);
                    }
                });

                $slaveIDDropdown.off("change").on("change", function () {
                    var selectedSlaveID = $(this).val(); // Get the selected value in format 'serialdeviceid_serialslaveid'
                    var selectedDevice = $(this).find("option:selected").text();
                    var deviceName123 = selectedDevice.split(" (")[0]; // Extract the device name part
                    console.log(deviceName123);
                    populateRegistersForSelectedSlave(selectedSlaveID);
                });
            } else {
                $slaveIDDropdown.append(new Option("No Modbus devices found", ""));
            }

            function populateRegistersForSelectedSlave(selectedSlaveID) {
                $registerNameDropdown.empty();  // Clear existing register dropdown options

                self.RS485GetUCISections("registerconfig", "registerconfig").then(function (rv) {
                    let getregistrdata = rv;
                    if (getregistrdata && Object.keys(getregistrdata).length > 0) {
                        let hasRegisters = false;

                        // Split the selectedSlaveID to get device and slave ID
                        var [selectedDeviceID, selectedSlaveIDOnly] = selectedSlaveID.split('_');

                        var selectedDevice = Object.values(modbusDevices).find(dev => (dev.serialdeviceid === selectedDeviceID) && (dev.serialslaveid === selectedSlaveIDOnly));
                        if (selectedDevice) {
                            var ModbusName = selectedDeviceID;
                            console.log("Selected Device ModbusName:", ModbusName);

                            Object.keys(getregistrdata).forEach(function (key) {
                                var device = getregistrdata[key];
                                var sectionName = device[".name"];
                                if (sectionName === ModbusName) {
                                    for (let i = 0; ; i++) {
                                        let registerKey = 'registername_' + i;
                                        if (!device.hasOwnProperty(registerKey)) break;

                                        if (device[registerKey]) {
                                            $registerNameDropdown.append(new Option(device[registerKey], device[registerKey]));
                                            hasRegisters = true;
                                        }
                                    }
                                }
                            });
                        }

                        if (!hasRegisters) {
                            $registerNameDropdown.append(new Option("No registers found", ""));
                        }
                    } else {
                        console.log("No register data found.");
                        $registerNameDropdown.append(new Option("No registers found", ""));
                    }
                });
            }
        }
    },




















    execute: function () {
        var self = this;


        removeBlock = function (event) {
            var button = event.target;
            console.log(button);
            var blockRow = button.closest('.row');
            if (blockRow) {
                debugger
                blockRow.remove();
                var blockIndex = button.id.split(',')[1];
                // alert("Register_index", blockIndex)
                var _delete_index = parseInt(button.id.split(',')[1], 10);
                var _delete_count = _delete_index + 1;
                alert(`Block Register config ${_delete_count} is deleted`);
                for (var i = parseInt(blockIndex) + 1; i < self.CounterBlock; i++) {
                    // Update the ID of each element
                    $("#functionCode" + i).attr("id", "functionCode" + (i - 1));
                    $("#startRegister" + i).attr("id", "startRegister" + (i - 1));
                    $("#countRegister" + i).attr("id", "countRegister" + (i - 1));
                    $("#BlockremoveButton," + i).attr("id", "BlockremoveButton," + (i - 1)); // Corrected selector
                }
                self.CounterBlock--;
            }
        };

        removeRegister = function (event) {
            var button = event.target;
            console.log(button);
            var RegisterRow = button.closest('.row');
            if (RegisterRow) {
                debugger
                RegisterRow.remove();
                var Register_index = button.id.split(',')[1];
                alert("Register_index", Register_index)
                var _delete_index = parseInt(button.id.split(',')[1], 10);
                alert("_delete_index", _delete_index)
                var _delete_count = _delete_index + 1;
                alert(` Register Config ${_delete_count} is deleted`);
                for (var i = parseInt(Register_index) + 1; i < self.CounterRegister; i++) {
                    // Update the ID of each element
                    $("#registername" + i).attr("id", "registername" + (i - 1));
                    $("#startregister" + i).attr("id", "startregister" + (i - 1));
                    $("#registercount" + i).attr("id", "registercount" + (i - 1));
                    $("#Datatype" + i).attr("id", "Datatype" + (i - 1));
                    $("#multifactor" + i).attr("id", "multifactor" + (i - 1));
                    $("#RegisterremoveButton," + i).attr("id", "RegisterremoveButton," + (i - 1)); // Corrected selector


                }
                self.CounterRegister--;
            }
        };


        // removeRegister = function (event) {
        //     var button = event.target;
        //     console.log(button);
        //     var RegisterRow = button.closest('.row'); // Locate the row to remove

        //     if (RegisterRow) {
        //         RegisterRow.remove(); // Remove the row from the DOM

        //         var buttonId = button.id; // Get the button's ID
        //         console.log("Button ID:", buttonId);

        //         // Extract the numerical part of the ID
        //         var Register_index = buttonId.replace("RegisterremoveButton", "");
        //         console.log("Register Index:", Register_index);

        //         var _delete_index = parseInt(Register_index, 10); // Convert to an integer
        //         if (isNaN(_delete_index)) {
        //             alert("Error: Unable to parse register index as a number.");
        //             return;
        //         }

        //         var _delete_count = _delete_index + 1;
        //         alert(`Register Config ${_delete_count} is deleted`);

        //         // Update IDs for remaining rows
        //         for (var i = _delete_index + 1; i < self.CounterRegister; i++) {
        //             // Update the ID of each element
        //             $("#registername" + i).attr("id", "registername" + (i - 1));
        //             $("#startregister" + i).attr("id", "startregister" + (i - 1));
        //             $("#registercount" + i).attr("id", "registercount" + (i - 1));
        //             $("#Datatype" + i).attr("id", "Datatype" + (i - 1));
        //             $("#multifactor" + i).attr("id", "multifactor" + (i - 1));
        //             $("#RegisterremoveButton" + i).attr("id", "RegisterremoveButton" + (i - 1)); // Correct selector
        //         }

        //         self.CounterRegister--; // Decrement the counter
        //     }
        // };





        removeAlarm = function (event) {
            var button = event.target;
            console.log(button);
            var Register_row = button.closest('.row');
            if (Register_row) {
                Register_row.remove();
                var alarm_index = button.id.split(',')[1];
                var _delete_index = parseInt(button.id.split(',')[1], 10);
                var _delete_count = _delete_index + 1;
                alert(`Alearm/Event Config ${_delete_count} is deleted`);
                for (var i = parseInt(alarm_index) + 1; i < self.CounterAlarm; i++) {
                    // Update the ID of each element
                    $("#Category" + i).attr("id", "Category" + (i - 1));
                    $("#alarmEnabled" + i).attr("id", "alarmEnabled" + (i - 1));
                    $("#alarmName" + i).attr("id", "alarmName" + (i - 1));
                    $("#Code" + i).attr("id", "Code" + (i - 1));
                    $("#regAlarm" + i).attr("id", "regAlarm" + (i - 1));
                    $("#alarmCount" + i).attr("id", "alarmCount" + (i - 1));
                    $("#alarmDatatype" + i).attr("id", "alarmDatatype" + (i - 1));
                    $("#uprThreshold" + i).attr("id", "uprThreshold" + (i - 1));
                    $("#uprHysteresis" + i).attr("id", "uprHysteresis" + (i - 1));
                    $("#lowerThreshold" + i).attr("id", "lowerThreshold" + (i - 1));
                    $("#lowerHysteresis" + i).attr("id", "lowerHysteresis" + (i - 1));
                    $("#AlarmremoveButton," + i).attr("id", "AlarmremoveButton," + (i - 1)); // Corrected selector


                }
                self.CounterAlarm--;
            }
        };


        removePseudoRegister = function (event) {
            var button = event.target;
            console.log(button);
            var RegisterRow1 = button.closest('.row');
            if (RegisterRow1) {
                console.log(RegisterRow1.remove())
                RegisterRow1.remove();
                var Pseudo_Register_index = button.id.split(',')[1];
                var _delete_index = parseInt(button.id.split(',')[1], 10);
                var _delete_count = _delete_index + 1;
                alert(`Pseudo Register config  ${_delete_count} is deleted`);
                for (var i = parseInt(Pseudo_Register_index) + 1; i < self.PseudoRegisterCounter; i++) {
                    // Update the ID of each element
                    $("#pseudoRegisterName" + i).attr("id", "pseudoRegisterName" + (i - 1));
                    $("#SlaveId" + i).attr("id", "SlaveId" + (i - 1));
                    $("#pseudoSlaveRegister" + i).attr("id", "pseudoSlaveRegister" + (i - 1));
                    $("#pseudoRemoveButton," + i).attr("id", "pseudoRemoveButton," + (i - 1)); // Corrected selector


                }
                self.PseudoRegisterCounter--;
            }
        };



        $("#AddNewModbus").click(function () {
            document.getElementById("Blockregistersection").innerHTML = " "
            document.getElementById("Registersection").innerHTML = " "
            document.getElementById("Alarm_Event_section").innerHTML = " "
            self.CounterRegister = 0;
            self.CounterBlock = 0;
            self.CounterAlarm = 0;
            $('#devicename').prop('disabled', false);
            $("#modbusserialconfig").css("display", "block");
            $(".modusregister").css("display", "block");
            $("#AddNewEvent").val("Add Device");
            $('#devicename').val("");
            $('#serialslaveid').val("");
            $('#serialport1').val("");
            $('#serialbaudrate').val("");
            $('#serialparity').val("");
            $('#protocol').val("");
            $('#CommIp').val("");
            $('#CommPort').val("");
            $('#metermodel').val("");
            $('#commT').val("");
            $('#equipmentid').val("");
            $('#optiondevice').val("");
            $('#modelname').val("");
            $('#serialstopbit').val("");
            $('#tagNameInput').val("");
            $('#TagDatatype').val("");
            $('#serialdatabits').val("");
            $('#Modbus-ModelLabel')
                .attr('name', 'add_modbus')
                .text('Add Modbus Configuration');
            $('#Modbus_Submit')
                .attr('name', 'submit')
                .removeClass()
                .addClass('btn btn-primary') // Change the name attribute
                .text('Submit');

            $('#stdModbusEnable').val("")

            $('#topicname').val("")
            $('#topicnametwo').val("")
            $('#jsonHeaderKeyName').val('');
            $('#jsonKeyName1').val('');
            $('#jsonKeyValue1').val('');
            $('#jsonKeyName2').val('');
            $('#jsonKeyValue2').val('');
            $('#jsonKeyName3').val('');
            $('#jsonKeyValue3').val('');
            $('#dataSendingMethod').val('');
            $('#enableJsonHeaderKey').prop('checked', false);
            $('#enableCustomField1').prop('checked', false);
            $('#enableCustomField2').prop('checked', false);
            $('#enableCustomField3').prop('checked', false);
            $("#TextBoxesGroup").css("display", "block")
            $("#jsoninfo").val("")
            $("#jsoninfo").css("display", "none")
            self.changemodbusprotocol()
        })


        $("#AddNewPseudo").click(function () {
            self.PseudoRegisterCounter = 0;
            $('#Pseudo-ModelLabel')
                .attr('name', 'Add_pseudo')
                .text('Add Pseudo Configuration');
            $('#Pseudo_Sumbit')
                .attr('name', 'submit')
                .removeClass()
                .addClass('btn btn-primary')
                .text('Submit');

            document.getElementById("PseudoRegisterSection").innerHTML = " "



            $('#pseudoDeviceName').prop('disabled', false);
            $('#pseudoDeviceName').val("")
            $('#pseudoSlaveID').val("")
            $('#pseudoSlaveDataStatus').val("")
            $('#pseudoSlaveCloudStatus').val("")
            $('#pseudoDataSendingMethod').val("")
            $('#pseudoTopicName').val("")
            $('#pseudoTopicNameTwo').val("")
            $('#pseudoJsonHeaderKeyStatus').val("").prop('checked', false);
            $('#pseudoJsonHeaderKeyName').val("")
            $('#pseudoCustomFieldStatus1').val("").prop('checked', false);
            $('#pseudoJsonKeyName1').val("")
            $('#pseudoJsonKeyValue1').val("")
            $('#pseudoJsonKeyName2').val("")
            $('#pseudoJsonKeyValue2').val("")
            $('#pseudoCustomFieldStatus2').val("").prop('checked', false);
            $('#pseudoCustomFieldStatus3').val("").prop('checked', false);
            $('#pseudoJsonKeyName3').val("")
            $('#pseudoJsonKeyValue3').val("")
            $("#PseudoTextBoxesGroup").css("display", "block")
            self.PseudoModbusDropdowns();
        })


        var arr = [];
        var arrTwo = [];
        var arrThree = [];
        $('#Modbus_Submit').click(function () {


            self.deleteDevice();
            var rowCount = $('#TextBoxesGroup').length;
            arr = [];
            for (var i = 0; i < self.CounterRegister; i++) {
                arr.push({
                    "registername": $('#registername' + i).val(),
                    "multifactor": $('#multifactor' + i).val(),
                    "Datatype": $('#Datatype' + i).val(),
                    "startregister": $('#startregister' + i).val(),
                    "registercount": $('#registercount' + i).val(),
                })

            }
            var rowCountTwo = $('#BlockTextBoxesGroup').length;
            arrTwo = [];
            for (var i = 0; i < self.CounterBlock; i++) {
                arrTwo.push({
                    "functionCode": $('#functionCode' + i).val(),
                    "startRegister": $('#startRegister' + i).val(),
                    "countRegister": $('#countRegister' + i).val(),
                })
            }


            var rowCountThree = $('#AlarmTextBoxesGroup').length;
            arrThree = [];
            for (var i = 0; i < self.CounterAlarm; i++) {
                arrThree.push({
                    "Category": $('#Category' + i).val(),
                    "alarmEnabled": $('#alarmEnabled' + i).val(),
                    "alarmName": $('#alarmName' + i).val(),
                    "Code": $('#Code' + i).val(),
                    "regAlarm": $('#regAlarm' + i).val(),
                    "alarmCount": $('#alarmCount' + i).val(),
                    "alarmDatatype": $('#alarmDatatype' + i).val(),
                    "uprThreshold": $('#uprThreshold' + i).val(),
                    "uprHysteresis": $('#uprHysteresis' + i).val(),
                    "lowerThreshold": $('#lowerThreshold' + i).val(),
                    "lowerHysteresis": $('#lowerHysteresis' + i).val(),
                })

            }
            var formData = {};
            var isEmptyField;
            $('.inputbox:visible').each(function () {
                var fieldName = $(this).attr('name');
                var fieldValue = $(this).val().trim();

                // Check if the field value is empty
                if (fieldValue === '') {
                    alert('Please fill in ' + fieldName);
                    isEmptyField = true;
                    return false; // Exit the loop if any field is empty
                }
                isEmptyField = $('.inputbox:visible').filter(function () {
                    return $(this).val().trim() === '';
                }).length > 0;
            });
            if (!isEmptyField) {
                self.RS485ConfigSectionAdd();
            }

            // // If any field is empty, do not execute RS485ConfigSectionAdd method
            // self.RS485ConfigSectionAdd();
        });





        var Parr = [];
        $('#Pseudo_Sumbit').click(function () {

            const buttonName = $(this).attr('name');
            if (buttonName === 'UpdatedSubmit') {
                var _old_count = parseInt(localStorage.getItem("_previous_count"), 10);
                console.log("_old_count", _old_count)
                var _new_count = self.PseudoRegisterCounter;
                console.log("_new_count", _new_count)

                if (!isNaN(_old_count) && !isNaN(_new_count)) {
                    if ((_old_count - _new_count > 0) || (_old_count - _new_count < 0)) {
                        alert("You will lose the old data, and it will be updated with the latest edited data.");
                    }
                }
            }

            Parr = [];
            for (var i = 0; i < self.PseudoRegisterCounter; i++) {
                Parr.push({
                    "pseudoRegisterName": $('#pseudoRegisterName' + i).val(),
                    "SlaveId": $('#SlaveId' + i).val(),
                    "pseudoSlaveRegister": $('#pseudoSlaveRegister' + i).val(),
                })
            }

            var formData = {};
            var isEmptyField;
            $('.inputbox:visible').each(function () {
                var fieldName = $(this).attr('name');
                var fieldValue = $(this).val().trim();

                // Check if the field value is empty
                if (fieldValue === '') {
                    alert('Please fill in ' + fieldName);
                    isEmptyField = true;
                    return false; // Exit the loop if any field is empty
                }
                isEmptyField = $('.inputbox:visible').filter(function () {
                    return $(this).val().trim() === '';
                }).length > 0;
            });
            if (!isEmptyField) {
                self.PseudoSectionAdd();
                self.PseudoModbusDropdowns();
            }
        });



        var jsondata = [];
        var Request_data = {};
        var checkbox2 = document.getElementById("addJButton");

        showJson = function () {
            jsondata = [];
            Request_data = {};

            if (checkbox2) {
                for (let i = 0; i < self.CounterRegister; i++) {
                    var registerName = $('#registername' + i).val();
                    var dataTypeValue = $('#Datatype' + i).val();
                    var packedValue;

                    if (registerName) {

                        if (dataTypeValue === "0") {
                            packedValue = "0xAF";
                        } else if (dataTypeValue === "1" || dataTypeValue === "2") {
                            packedValue = 255.14;
                        } else if (dataTypeValue === "11") {
                            packedValue = true;
                        } else {
                            packedValue = 120;
                        }
                        Request_data[registerName] = packedValue;
                    }
                }
                $("#jsoninfo").css("display", "block");
                $("#jsoninfo").val(JSON.stringify(Request_data, null, 2));
            }
        };





        toggleParity = function () {
            self.changemodbusprotocol();

        }


        $('#AddBlock-btn').click(function () {
            self.AddBlockSection()

        });

        $('#AddRegister-btn').click(function () {
            self.AddRegisterSection()


        });
        $('#AddAlarm-btn').click(function () {
            self.AddAlarmSection()
        });
        $('#AddPsedoRegister-btn').click(function () {
            console.log("button")
            self.AddPseudoRegistersection()
            self.PseudoModbusDropdowns()
        });


        registerdata = function () {
            return arr;
        }
        blockdata = function () {
            return arrTwo;
        }
        alarmdata = function () {
            return arrThree;
        }
        pseudoRegisterData = function () {
            return Parr;
        }





        self.RS485GetUCISections("cloudconfig", "cloudconfig").then(function (rv) {

            var dataSlave = rv;
            console.log("Dataslave", dataSlave)
            let cloudDisplay = document.getElementById('cloud_config-tab');
            let pseudoCloudDisplay = document.getElementById('hidePart');
            let hideInput = document.getElementById('hideoptions');
            var topicNameOne = document.getElementById('topicNameField');
            var topicNameTwo = document.getElementById('topicNameTwoField');
            var pseudoTopicNameOne = document.getElementById('pseudoTopicNameField');
            var pseudoTopicNameTwo = document.getElementById('pseudoTopicNameTwoField');
            var dropdown = document.getElementById("dataSendingMethod");
            var pseudoDropdown = document.getElementById("pseudoDataSendingMethod");

            if (dataSlave.cloudconfig.slaveDataSending === '1') {
                cloudDisplay.style.display = 'block';
                // pseudoCloudDisplay.style.display = 'block';

                if (dataSlave.cloudconfig.server === "primary") {
                    dropdown.disabled = true;
                    pseudoDropdown.disabled = true;
                    dropdown.value = "1";
                    pseudoDropdown.value = "1";
                    if (dataSlave.cloudconfig.server === "primary" && dataSlave.cloudconfig.cloudprotocol === 'mqtt') {
                        topicNameOne.style.display = 'block';
                        pseudoTopicNameOne.style.display = 'block';
                        topicNameTwo.style.display = 'none';
                        pseudoTopicNameTwo.style.display = 'none';
                    }
                    else if (dataSlave.cloudconfig.server === "primary" && dataSlave.cloudconfig.cloudprotocol === 'http') {
                        topicNameOne.style.display = 'none';
                        pseudoTopicNameOne.style.display = 'none';
                        topicNameTwo.style.display = 'none';
                        pseudoTopicNameTwo.style.display = 'none';

                    }
                    else if (dataSlave.cloudconfig.server === "primary" && dataSlave.cloudconfig.cloudprotocol === 'azure') {
                        topicNameOne.style.display = 'none';
                        pseudoTopicNameOne.style.display = 'none';
                        topicNameTwo.style.display = 'none';
                        pseudoTopicNameTwo.style.display = 'none';
                    }
                }

                if ((dataSlave.cloudconfig.server === 'both' || dataSlave.cloudconfig.server === 'fallback') && (dataSlave.cloudconfig.cloudprotocol === 'mqtt' && dataSlave.cloudconfig.cloudprotocol2 === 'mqtt')) {
                    document.getElementById('dataSendingMethod').addEventListener('change', function () {
                        const selectedValue = this.value;
                        handleDisplayChange(selectedValue);
                    });

                    // Add event listener to the second element
                    document.getElementById('pseudoDataSendingMethod').addEventListener('change', function () {
                        const selectedValue = this.value;
                        handleDisplayChange(selectedValue);
                    });

                    function handleDisplayChange(selectedValue) {
                        if (selectedValue === "1") {
                            topicNameOne.style.display = 'block';
                            pseudoTopicNameOne.style.display = 'block';
                            topicNameTwo.style.display = 'none';
                            pseudoTopicNameTwo.style.display = 'none';
                        } else if (selectedValue === "2") {
                            topicNameOne.style.display = 'none';
                            pseudoTopicNameOne.style.display = 'none';
                            topicNameTwo.style.display = 'block';
                            pseudoTopicNameTwo.style.display = 'block';
                        } else if (selectedValue === "3") {
                            topicNameOne.style.display = 'block';
                            pseudoTopicNameOne.style.display = 'block';
                            topicNameTwo.style.display = 'block';
                            pseudoTopicNameTwo.style.display = 'block';
                        }
                    }




                }
                else if ((dataSlave.cloudconfig.server === 'both' || dataSlave.cloudconfig.server === 'fallback') && (dataSlave.cloudconfig.cloudprotocol === 'mqtt' && dataSlave.cloudconfig.cloudprotocol2 === 'http')) {
                    // const shouldHideOption3 = true;

                    // if (shouldHideOption3) {
                    //     $('#dataSendingMethod option[value="3"]').hide();
                    // }
                    // HideDropdown()
                    document.getElementById('dataSendingMethod').addEventListener('change', function () {
                        const selectedValue = this.value;
                        handleDisplayChange(selectedValue);
                    });

                    // Add event listener to the second element
                    document.getElementById('pseudoDataSendingMethod').addEventListener('change', function () {
                        const selectedValue = this.value;
                        handleDisplayChange(selectedValue);
                    });



                    function handleDisplayChange(selectedValue) {
                        // var selectedValue = document.getElementById('dataSendingMethod').value;
                        if (selectedValue === "1") {
                            topicNameOne.style.display = 'block';
                            pseudoTopicNameOne.style.display = 'block';
                            topicNameTwo.style.display = 'none';
                            pseudoTopicNameTwo.style.display = 'none';
                        } else if (selectedValue === "2") {
                            topicNameOne.style.display = 'none';
                            pseudoTopicNameOne.style.display = 'none';
                            topicNameTwo.style.display = 'none';
                            pseudoTopicNameTwo.style.display = 'none';
                        }
                        else if (selectedValue === "3") {
                            topicNameOne.style.display = 'block';
                            pseudoTopicNameOne.style.display = 'block';
                            topicNameTwo.style.display = 'none';
                            pseudoTopicNameTwo.style.display = 'none';
                        }
                    };
                }
                else if ((dataSlave.cloudconfig.server === 'both' || dataSlave.cloudconfig.server === 'fallback') && (dataSlave.cloudconfig.cloudprotocol === 'http' && dataSlave.cloudconfig.cloudprotocol2 === 'mqtt')) {
                    // topicNameOne.style.display = 'none';
                    // pseudoTopicNameOne.style.display = 'none';
                    // topicNameTwo.style.display = 'block';
                    // pseudoTopicNameTwo.style.display = 'block';
                    // HideDropdown()
                    document.getElementById('dataSendingMethod').addEventListener('change', function () {
                        const selectedValue = this.value;
                        handleDisplayChange(selectedValue);
                    });

                    // Add event listener to the second element
                    document.getElementById('pseudoDataSendingMethod').addEventListener('change', function () {
                        const selectedValue = this.value;
                        handleDisplayChange(selectedValue);
                    });

                    function handleDisplayChange(selectedValue) {
                        if (selectedValue === "1") {
                            topicNameOne.style.display = 'none';
                            pseudoTopicNameOne.style.display = 'none';
                            topicNameTwo.style.display = 'none';
                            pseudoTopicNameTwo.style.display = 'none';
                        } else if (selectedValue === "2") {
                            topicNameOne.style.display = 'none';
                            pseudoTopicNameOne.style.display = 'none';
                            topicNameTwo.style.display = 'block';
                            pseudoTopicNameTwo.style.display = 'block';
                        }
                        else if (selectedValue === "3") {
                            topicNameOne.style.display = 'none';
                            pseudoTopicNameOne.style.display = 'none';
                            topicNameTwo.style.display = 'block';
                            pseudoTopicNameTwo.style.display = 'block';
                        }
                    };
                }
                else if ((dataSlave.cloudconfig.server === 'both' || dataSlave.cloudconfig.server === 'fallback') && (dataSlave.cloudconfig.cloudprotocol === 'mqtt' && dataSlave.cloudconfig.cloudprotocol2 === 'azure')) {
                    document.getElementById('dataSendingMethod').addEventListener('change', function () {
                        const selectedValue = this.value;
                        handleDisplayChange(selectedValue);
                    });


                    document.getElementById('pseudoDataSendingMethod').addEventListener('change', function () {
                        const selectedValue = this.value;
                        handleDisplayChange(selectedValue);
                    });
                    function handleDisplayChange(selectedValue) {
                        // var selectedValue = document.getElementById('dataSendingMethod').value;
                        if (selectedValue === "1") {
                            topicNameOne.style.display = 'block';
                            pseudoTopicNameOne.style.display = 'block';
                            topicNameTwo.style.display = 'none';
                            pseudoTopicNameTwo.style.display = 'none';
                        } else if (selectedValue === "2") {
                            topicNameOne.style.display = 'none';
                            pseudoTopicNameOne.style.display = 'none';
                            topicNameTwo.style.display = 'none';
                            pseudoTopicNameTwo.style.display = 'none';
                        }
                        else if (selectedValue === "3") {
                            topicNameOne.style.display = 'block';
                            pseudoTopicNameOne.style.display = 'block';
                            topicNameTwo.style.display = 'none';
                            pseudoTopicNameTwo.style.display = 'none';
                        }
                    };
                }
                else if ((dataSlave.cloudconfig.server === 'both' || dataSlave.cloudconfig.server === 'fallback') && (dataSlave.cloudconfig.cloudprotocol === 'azure' && dataSlave.cloudconfig.cloudprotocol2 === 'mqtt')) {
                    document.getElementById('dataSendingMethod').addEventListener('change', function () {
                        const selectedValue = this.value;
                        handleDisplayChange(selectedValue);
                    });


                    document.getElementById('pseudoDataSendingMethod').addEventListener('change', function () {
                        const selectedValue = this.value;
                        handleDisplayChange(selectedValue);
                    });
                    function handleDisplayChange(selectedValue) {
                        // var selectedValue = document.getElementById('dataSendingMethod').value;
                        if (selectedValue === "1") {
                            topicNameOne.style.display = 'none';
                            pseudoTopicNameOne.style.display = 'none';
                            topicNameTwo.style.display = 'none';
                            pseudoTopicNameTwo.style.display = 'none';
                        } else if (selectedValue === "2") {
                            topicNameOne.style.display = 'none';
                            pseudoTopicNameOne.style.display = 'none';
                            topicNameTwo.style.display = 'block';
                            pseudoTopicNameTwo.style.display = 'block';
                        }
                        else if (selectedValue === "3") {
                            topicNameOne.style.display = 'none';
                            pseudoTopicNameOne.style.display = 'none';
                            topicNameTwo.style.display = 'block';
                            pseudoTopicNameTwo.style.display = 'block';
                        }
                    };
                }
                else if ((dataSlave.cloudconfig.server === 'both' || dataSlave.cloudconfig.server === 'fallback') && (dataSlave.cloudconfig.cloudprotocol === 'azure' && dataSlave.cloudconfig.cloudprotocol2 === 'http')) {
                    topicNameOne.style.display = 'none';
                    pseudoTopicNameOne.style.display = 'none';
                    topicNameTwo.style.display = 'none';
                    pseudoTopicNameTwo.style.display = 'none';
                }
                else if ((dataSlave.cloudconfig.server === 'both' || dataSlave.cloudconfig.server === 'fallback') && (dataSlave.cloudconfig.cloudprotocol === 'http' && dataSlave.cloudconfig.cloudprotocol2 === 'azure')) {
                    topicNameOne.style.display = 'none';
                    pseudoTopicNameOne.style.display = 'none';
                    topicNameTwo.style.display = 'none';
                    pseudoTopicNameTwo.style.display = 'none';
                }
                else if ((dataSlave.cloudconfig.server === 'both' || dataSlave.cloudconfig.server === 'fallback') && (dataSlave.cloudconfig.cloudprotocol === 'azure' && dataSlave.cloudconfig.cloudprotocol2 === 'azure')) {
                    topicNameOne.style.display = 'none';
                    pseudoTopicNameOne.style.display = 'none';
                    topicNameTwo.style.display = 'none';
                    pseudoTopicNameTwo.style.display = 'none';
                }
                else if ((dataSlave.cloudconfig.server === 'both' || dataSlave.cloudconfig.server === 'fallback') && (dataSlave.cloudconfig.cloudprotocol === 'http' && dataSlave.cloudconfig.cloudprotocol2 === 'http')) {
                    topicNameOne.style.display = 'none';
                    pseudoTopicNameOne.style.display = 'none';
                    topicNameTwo.style.display = 'none';
                    pseudoTopicNameTwo.style.display = 'none';
                }
            }

            console.log("cloud configurationnn5nnnnnnnnnnnnnnnnn: ", rv);
            console.log("cloud configuration Protocol: ", dataSlave.cloudconfig.cloudprotocol);
            console.log("cloud configuration Protocol 2: ", dataSlave.cloudconfig.cloudprotocol2);
        })


        self.RS485GetUCISections("DeviceConfigGeneric", "RS485Config").then(function (rv) {
            self.RS485RenderContents(rv);
        })
        self.RS485GetUCISections("pseudoParamconfig", "pseudoConfig").then(function (rv) {
            self.PseudoRenderContents(rv);
        })




    },

});