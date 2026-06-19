L.ui.view.extend({
        MACFilteringUCISections: L.rpc.declare({
                object: 'uci',
                method: 'get',
                params: ['config', 'type'],
                expect: { values: {} }
        }),
        
        ModechangeCreateUCISection:L.rpc.declare({
                object: 'uci',
                method: 'add',
                params: ['config', 'type','name', 'values']
        }),

        MACFilteringCreateUCISection: L.rpc.declare({
                object: 'uci',
                method: 'add',
                params: ['config', 'type', 'values']
        }),

        MACFilteringCommitUCISection: L.rpc.declare({
                object: 'uci',
                method: 'commit',
                params: ['config']
        }),

        MACFilteringDeleteUCISection: L.rpc.declare({
                object: 'uci',
                method: 'delete',
                params: ['config', 'type', 'section']
        }),

        updatefirewallconfig: L.rpc.declare({
                object: 'rpc-updatemacidconfig',
                method: 'configure',
                expect: { output: '' }
        }),

        MACFilteringFormCallback: function () {
                var map = this;
                var MACFilteringConfigSectionName = map.options.MACFilteringConfigSection;
                var numericExpression = /^[0-9]+$/;

                map.options.caption = L.tr(MACFilteringConfigSectionName + ' Configuration');

                var s = map.section(L.cbi.NamedSection, MACFilteringConfigSectionName, {

                        collabsible: true
                });
                s.option(L.cbi.CheckboxValue, 'Enable', {
                        caption: L.tr('Enable/Disable')
                })
                s.option(L.cbi.InputValue, 'MACFilteringConfigSectionName', {
                        caption: L.tr('Url Blocking'),
                        datatype: 'url',
                }).depends({ 'Enable': '1' });
        },

        MACFilteringRenderContents: function (rv) {
                var self = this;
                configdata = function () {
                        return rv;
                }
                var listcount = false;
                var listcount2 = false;

                var list = new L.ui.table({
                        columns: [{
                                caption: L.tr('Sl No'),
                                align: 'center',
                                format: function (v, n) {
                                        var div = $('<p />').attr('id', 'remoteserverIP%s'.format(n));
                                        var serialNo = n + 1;
                                        return div.append(serialNo);
                                }
                        },

                        {
                                caption: L.tr('Mac id'),
                                width: '30%',
                                align: 'center',
                                format: function (v, n) {
                                        var div = $('<p />').attr('id', 'remoteserverIP%s'.format(n));
                                        return div.append(v);

                                }
                        },
                        {
                                caption: L.tr('Mode'),
                                width: '30%',
                                align: 'center',
                                format: function (v, n) {
                                        var div = $('<p />').attr('id', 'remoteserverIP%s'.format(n));
                                        return div.append(v);
                                }
                        },
                        
                        {
                                caption: L.tr('Status'),
                                width: '30%',
                                align: 'center',
                                format: function (v, n) {
                                        console.log(this.status)
                                        var div = $('<label />').attr('id', 'MACFilteringDeviceEventName_%s'.format(n)).attr('class', 'switch');
                                        return div.append(`<input type="checkbox" ${v} disabled  id="PortforwardingstatusSwitch${n}" onclick="changestatus(${n})">
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
                                                        .click({ self: self, MACID: v }, self.MACFilteringConfigSectionEdit))
                                                .append(L.ui.button(L.tr('Delete'), 'danger', L.tr('Delete Event'))
                                                        .click({ self: self, MACID: v }, self.MACFilteringConfigSectionRemove));

                                }
                        }]
                });
               
               
                var list2 = new L.ui.table({
                        columns: [{
                                caption: L.tr('Sl No'),
                                align: 'center',
                                format: function (v, n) {
                                        var div = $('<p />').attr('id', 'remoteserverIP%s'.format(n));
                                        var serialNo = n + 1;
                                        return div.append(serialNo);
                                }
                        },

                        {
                                caption: L.tr('Mac id'),
                                width: '30%',
                                align: 'center',
                                format: function (v, n) {
                                        var div = $('<p />').attr('id', 'remoteserverIP%s'.format(n));
                                        return div.append(v);

                                }
                        },
                        {
                                caption: L.tr('Mode'),
                                width: '30%',
                                align: 'center',
                                format: function (v, n) {
                                        var div = $('<p />').attr('id', 'remoteserverIP%s'.format(n));
                                        return div.append(v);
                                }
                        },
                        
                        {
                                caption: L.tr('Status'),
                                width: '30%',
                                align: 'center',
                                format: function (v, n) {
                                        console.log(this.status)
                                        var div = $('<label />').attr('id', 'MACFilteringDeviceEventName_%s'.format(n)).attr('class', 'switch');
                                        return div.append(`<input type="checkbox" ${v} disabled  id="PortforwardingstatusSwitch${n}" onclick="changestatus(${n})">
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
                                                        .click({ self: self, MACID: v }, self.MACFilteringConfigSectionEdit))
                                                .append(L.ui.button(L.tr('Delete'), 'danger', L.tr('Delete Event'))
                                                        .click({ self: self, MACID: v }, self.MACFilteringConfigSectionRemove));

                                }
                        }]
                });

                for (var key in rv) {
                        if (rv.hasOwnProperty(key)) {
                                var obj = rv[key];
                                var MACID = obj.MACID
                                var Accesspolicy = obj.Accesspolicy
                                var status = obj.MACfilteringSwitch;
                                var NetworkMode=obj.NetworkMode;
                                if (status == "1") {
                                        status = "checked"
                                } else {
                                        status = ""
                                }
                                if (NetworkMode == '1') {
                                        list.row([key, MACID, Accesspolicy, status, key])
                                        var list_1 = (list._rows && list._rows.length) || 0;
                                        if (list_1 > 0) {
                                                listcount = true;
                                        }

                                } else {
                                        list2.row([key, MACID, Accesspolicy, status, key]);
                                        var list_2 = (list2._rows && list2._rows.length) || 0;
                                        if (list_2 > 0) {
                                                listcount2 = true;
                                        }

                                }
                                
                        }
                }
                if (listcount) {
                        $('#networktype1').empty().append(list.render());
                        listcount = false
                } else {
                        L.ui.showNoConfigMessage('WiFi 2.4G AP Filtering', 'No-Wifi2.4G-Config')
                }

                if (listcount2) {
                        $('#networktype2').empty().append(list2.render());
                        listcount2 = false
                } else {
                        L.ui.showNoConfigMessage('WiFi 2.4G Guest AP Filtering', 'No-Wifi5G-Config')
                }
        },

        MACFilteringConfigSectionAdd: function (id) {
                var self = this;
                var MACfilteringSwitch = $('#MACfilteringSwitch')[0].checked;
                var MACID = $('#MACID').val();
                var Accesspolicy = $('#Accesspolicy1').val();
                var NetworkMode = $('#NetworkMode').val();
                
                if(MACfilteringSwitch == 1){
                        var Accesspolicy = $('#Accesspolicy1').val(); 
                }
                else{
                        var Accesspolicy = "Disable";
                }
                var sensorSectionOptions = { EEnable: 1, MACfilteringSwitch: MACfilteringSwitch, MACID: MACID,Accesspolicy:Accesspolicy,NetworkMode:NetworkMode};

                // this.MACFilteringUCISections("vpnconfog1","MACFilteringConfig").then(function(rv) {
                this.MACFilteringUCISections("macidconfig", "macidconfig").then(function (rv) {
                        var keys = Object.keys(rv);
                        var uniquedevicename = [];

                        for (var key in rv) {
                                var obj = rv[key];
                                uniquedevicename.push(obj.MACID)
                        }
                        var keysLength = keys.length;
                        if (id != "") {

                        }
                        // alert(keysLength);
                        if (keysLength >= 15) {
                                L.ui.showAlert(
                                        'warning',
                                        'Limit Reached',
                                        'You can configure up to 15 Wireless WiFi Filerting connections only.'
                                );
                        }
                        else {
                                if (id != "") {
                                        var editfields = rv[id]
                                        var key = editfields.MACID;
                                        self.MACFilteringDeleteUCISection("macidconfig", "macidconfig", id).then(function (rv) {
                                                if (rv == 0) {
                                                        self.MACFilteringCommitUCISection("macidconfig").then(function (res) {
                                                                if (res != 0) {
                                                                        alert("Error: Delete Configuration");
                                                                }
                                                                else {
                                                                        location.reload();
                                                                }
                                                        });
                                                };
                                        });
                                        //   self.MACFilteringCreateUCISection("vpnconfig1","MACFilteringConfig",MACFilteringConfigSectionName,sensorSectionOptions).then(function(rv){
                                        self.MACFilteringCreateUCISection("macidconfig", "macidconfig", sensorSectionOptions).then(function (rv) {
                                                if (rv) {
                                                        if (rv.section) {
                                                                self.MACFilteringCommitUCISection("macidconfig").then(function (res) {

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
                                        else {
                                                self.MACFilteringCreateUCISection("macidconfig", "macidconfig", sensorSectionOptions).then(function (rv) {
                                                        if (rv) {
                                                                if (rv.section) {
                                                                        self.MACFilteringCommitUCISection("macidconfig").then(function (res) {

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
                })
        },

        ModeConfigSectionAdd1: function (id) {
                var self = this;
                var Accesspolicy = $('#Accesspolicy'+id).val();
                L.ui.showAlert(
                        'success',
                        'Update Complete',
                        `${Accesspolicy} Updated Succesfully`
                );
                var MACfilteringSwitch=1;
                var sensorSectionOptions = { EEnable: 1,Accesspolicy:Accesspolicy,MACfilteringSwitch:MACfilteringSwitch };

                // this.MACFilteringUCISections("vpnconfog1","MACFilteringConfig").then(function(rv) {
                this.MACFilteringUCISections("macidconfig", "macidconfig").then(function (rv) {
                       
                        var keys = Object.keys(rv);
                        for (var key in rv) {
                                var networkmode=rv[key].NetworkMode
                                if(networkmode==id){
                                self.ModechangeCreateUCISection("macidconfig", "macidconfig",key,sensorSectionOptions).then(function (rv) {
                                        if (rv) {
                                                if (rv.section) {
                                                        self.MACFilteringCommitUCISection("macidconfig").then(function (res) {

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
        },

        MACFilteringConfigSectionRemove: function (ev) {
                var self = ev.data.self;
                var MACID = ev.data.MACID;
                //self.MACFilteringDeleteUCISection("vpnconfig1","MACFilteringConfig",MACFilteringConfigSectionName).then(function(rv){
                self.MACFilteringDeleteUCISection("macidconfig", "macidconfig", MACID).then(function (rv) {
                        if (rv == 0) {
                                self.MACFilteringCommitUCISection("macidconfig").then(function (res) {
                                        if (res != 0) {
                                                alert("Error: Delete Configuration");
                                        }
                                        else {
                                                setTimeout(() => {
                                                        location.reload();
                                                }, 1500);
                                        }
                                });
                        };
                });
        },

        MACFilteringConfigSectionEdit: function (ev) {
                // $("#Applyconfig").css("display", "none")
                // $("#editconfig").css("display", "inline")
                $('#updatetext').text('Edit Wireless Filter MAC ID Configuration');
                $('#Applyconfig')
                        .removeClass('btn-success')
                        .addClass('btn-primary')
                        .text('Save');

                var key = ev.data.MACID;
                editkey = function () {
                        return key;
                }
                var porteditdata = configdata();
                var editfields = porteditdata[key];

                var status = editfields.MACfilteringSwitch
                if (status == "1") {
                        status = true;
                }
                else {
                        status = false;
                }
                var MACID = editfields.MACID
               
                $('#MACID').val(MACID);
                document.getElementById("MACfilteringSwitch").checked = status;
                // $('#LANIP').val(editfields.LANIP);
                //  return self.MACFilteringConfigCreateForm(L.cbi.Modal,MACFilteringConfigSectionName).show();
                $("#exampleModal").modal('show');
        },

        execute: function () {
                L.ui.createNote(
                        'NOTE',
                        'After editing or deleting, please click the Update button to apply the saved configuration.',
                        { type: 'warn', variant: 'inline', appendTo: '#Update-WiFiFilter-Note' }
                );
                $('#addnew').click(function () {
                        $('#UrlBlocking').val("");
                        document.getElementById("MACfilteringSwitch").checked = true;
                        $('#updatetext').text('Add Wireless Filter MAC ID Configuration');
                        $('#Applyconfig')
                                .removeClass('btn-primary')
                                .addClass('btn-success')
                                .text('Add');
                });

                var self = this;
                $('#Applyconfig').click(function () {
                        var btn = document.getElementById('Applyconfig');
                        var btnValue = btn.textContent.trim();


                        var url = document.getElementById("MACID").value;
                        var validationResult = document.getElementById("validationResult");
                        var res = "";

                        if (btnValue === 'Add') {

                                if (
                                        url.match(
                                                /^[a-fA-F0-9:]{17}|[a-fA-F0-9]{12}$/g
                                        )
                                ) {

                                        self.MACFilteringConfigSectionAdd("");
                                } else {
                                        console.log("Invalid");

                                        res = "Must be a valid MacID";
                                }
                        }
                        else if (btnValue === 'Save') {
                                if (/^([a-fA-F0-9]{2}:){5}[a-fA-F0-9]{2}$/.test(url)) { // Exact MAC address format validation
                                        var key = editkey(); // Call the editkey function
                                        self.MACFilteringConfigSectionAdd(key); // Perform your operation with the validated key
                                } else {
                                        //console.log("Invalid"); // Log invalid case to the console
                                        res = "Must be a valid MAC address"; // Set the validation result message
                                }
                        }
                        validationResult.style.display = 'block'
                        validationResult.innerHTML = res;
                });

                // $('#editconfig').click(function () {
                //         var res = ""; // Initialize the result message
                //         // Get the value of the MAC address input field
                //         var url = document.getElementById("MACID").value;
                //         var validationResult = document.getElementById("validationResult");
                    
                //         // MAC address validation logic
                //         if (/^([a-fA-F0-9]{2}:){5}[a-fA-F0-9]{2}$/.test(url)) { // Exact MAC address format validation
                //             var key = editkey(); // Call the editkey function
                //             self.MACFilteringConfigSectionAdd(key); // Perform your operation with the validated key
                //         } else {
                //             //console.log("Invalid"); // Log invalid case to the console
                //             res = "Must be a valid MAC address"; // Set the validation result message
                //         }
                //         // Update the validation result display
                //         validationResult.innerHTML = res;
                //     });
                    
                self.MACFilteringUCISections("macidconfig", "macidconfig").then(function (rv) {
                        self.MACFilteringRenderContents(rv);
                });

                $('#update_ipsec').click(function () {
                        L.ui.loading(true);
                        self.updatefirewallconfig('configure').then(function (rv) {
                                L.ui.showAlert(
                                        'success',
                                        'Update Complete',
                                        'Wireless MAC ID Filtering Configurations Updated successfully'
                                );
                                setTimeout(() => {
                                        location.reload()
                                }, 1500);
                                L.ui.loading(false);
                        });
                });

                $('#ChangeMode1').click(function(){
                        self.ModeConfigSectionAdd1(1);
                })
                $('#ChangeMode2').click(function(){
                        self.ModeConfigSectionAdd1(2);
                })
        }

});


