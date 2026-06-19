L.ui.view.extend({

        RS485GetUCISections: L.rpc.declare({
                object: 'uci',
                method: 'get',
                params: ['config', 'type'],
                expect: { values: {} }
        }),

        ModechangeCreateUCISection: L.rpc.declare({
                object: 'uci',
                method: 'add',
                params: ['config', 'type', 'name', 'values']
        }),


        RS485CreateUCISection: L.rpc.declare({
                object: 'uci',
                method: 'add',
                params: ['config', 'type', 'values']
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

        updatefirewallconfig: L.rpc.declare({
                object: 'rpc-updateurlconfig',
                method: 'configure',
                expect: { output: '' }
        }),

        TestArchive: L.rpc.declare({
                object: 'rpc-updateurlconfig',
                method: 'testarchive',
                params: ['archive'],
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
                var fileSize = info.size; // Size in bytes
                var maxFileSize = 3 * 1024; // 3KB in bytes

                if (fileSize > maxFileSize) {
                        L.ui.dialog(false)
                        L.ui.showAlert(
                                'error',
                                'File Upload Failed',
                                'The maximum allowed file size is 3 KB. Please upload a smaller .txt file.'
                        );

                        return;
                } else {
                        var archive = $('[name=filename]').val();

                        if (!archive) {
                                alert('No file selected!');
                                L.ui.loading(false);
                                return;
                        }


                        L.ui.loading(true);
                        self.TestArchive(archive).then(function (TestArchiveOutput) {
                                L.ui.dialog(false)
                                L.ui.showAlert(
                                        'success',
                                        'File Upload',
                                        'File uploaded successfully.'
                                );

                                L.ui.loading(false);
                                localStorage.removeItem('urlfilterinfo');

                                const now = new Date();
                                const FileName = archive.split('/').pop();
                                const formatted = now.toLocaleString();
                                const urlfilter_info = `File name- ${FileName}<br> Date- ${formatted}`;
                                localStorage.setItem('urlfilterinfo', urlfilter_info);
                                $('#last-upload-url').html(urlfilter_info);

                        })
                }



        },
        RS485FormCallback: function () {
                var map = this;
                var RS485ConfigSectionName = map.options.RS485ConfigSection;
                var numericExpression = /^[0-9]+$/;

                map.options.caption = L.tr(RS485ConfigSectionName + ' Configuration');

                var s = map.section(L.cbi.NamedSection, RS485ConfigSectionName, {

                        collabsible: true
                });
                s.option(L.cbi.CheckboxValue, 'Enable', {
                        caption: L.tr('Enable/Disable')
                })

                s.option(L.cbi.InputValue, 'RS485ConfigSectionName', {

                        caption: L.tr('Url Blocking'),
                        datatype: 'url',
                }).depends({ 'Enable': '1' });

        },

        RS485RenderContents: function (rv) {
                var self = this;
                configdata = function () {
                        return rv;
                };

                var len = Object.keys(rv).length
                if (len > 0) {

                        // Create the table container
                        var tableContainer = $('<div />').attr('id', 'table_container');
                        var deleteButton = $('<button />')
                                .attr('id', 'delete_selected')
                                .addClass('btn btn-danger')
                                .text(L.tr('Delete Selected'))
                                .hide() // Initially hidden
                                .on('click', function () {
                                        // Collect IDs of selected checkboxes
                                        var selectedItems = [];
                                        $('input[type="checkbox"].row-checkbox:checked').each(function () {
                                                selectedItems.push($(this).attr('data-section-name'));
                                        });

                                        if (selectedItems.length > 0) {
                                                // Call RS485ConfigSectionRemove to delete all selected items
                                                self.RS485ConfigSectionRemove({
                                                        data: {
                                                                self: self,
                                                                selectedItems: selectedItems
                                                        }
                                                });
                                        } else {
                                                alert('No items selected.');
                                        }
                                });

                        tableContainer.append(deleteButton);

                        var list = new L.ui.table({
                                columns: [
                                        {
                                                caption: $('<input />') // Master checkbox in the header
                                                        .attr('type', 'checkbox')
                                                        .attr('id', 'select_all')
                                                        .on('change', function () { // Event listener for toggling all checkboxes
                                                                var isChecked = $(this).is(':checked');
                                                                $('input[type="checkbox"].row-checkbox').prop('checked', isChecked);
                                                                toggleDeleteButton();
                                                        }),
                                                align: 'center',
                                                format: function (v, n) {
                                                        return $('<input />')
                                                                .attr('type', 'checkbox')
                                                                .addClass('row-checkbox') // Class to identify row checkboxes
                                                                .attr('id', 'checkbox_%s'.format(n))
                                                                .attr('data-section-name', v) // Optional attribute for additional context
                                                                .on('change', function () {
                                                                        toggleDeleteButton();
                                                                });
                                                }
                                        },
                                        {
                                                caption: L.tr('Sl No'),
                                                align: 'center',
                                                format: function (v, n) {
                                                        var div = $('<p />').attr('id', 'remoteserverIP%s'.format(n));
                                                        return div.append(n + 1);
                                                }
                                        },
                                        {
                                                caption: L.tr('Url Blocking'),
                                                width: '30%',
                                                align: 'center',
                                                format: function (v, n) {
                                                        return $('<p />').attr('id', 'remoteserverIP%s'.format(n)).append(v);
                                                }
                                        },
                                        {
                                                caption: L.tr('Mode'),
                                                width: '30%',
                                                align: 'center',
                                                format: function (v, n) {
                                                        return $('<p />').attr('id', 'remoteserverIP%s'.format(n)).append(v);
                                                }
                                        },
                                        {
                                                caption: L.tr('Status'),
                                                width: '30%',
                                                align: 'center',
                                                format: function (v, n) {
                                                        return $('<p />').attr('id', 'remoteserverIP%s'.format(n)).append(v);
                                                }
                                        },
                                        {
                                                caption: L.tr('Update'),
                                                align: 'center',
                                                format: function (v, n) {
                                                        return $('<div />')
                                                                .addClass('btn-group btn-group-sm')
                                                                .append(
                                                                        L.ui.button(L.tr('Edit'), 'primary', L.tr('Configure'))
                                                                                .click({ self: self, RS485ConfigSectionName: v }, self.RS485ConfigSectionEdit)
                                                                )
                                                                .append(
                                                                        L.ui.button(L.tr('Delete'), 'danger', L.tr('Delete Event'))
                                                                                .click({ self: self, RS485ConfigSectionName: v }, self.RS485ConfigSectionRemove)
                                                                );
                                                }
                                        }
                                ]
                        });

                        for (var key in rv) {
                                if (rv.hasOwnProperty(key)) {
                                        var obj = rv[key];
                                        var RS485ConfigSectionName = obj.RS485ConfigSectionName;
                                        var status = obj.UrlfilteringSwitch == "1" ? "Enabled" : "Disabled";
                                        var Accesspolicy = obj.Accesspolicy;

                                        list.row([key, key, RS485ConfigSectionName, Accesspolicy, status, key]);
                                }
                        }

                        tableContainer.append(list.render());
                        $('#section_vpn_ipsec').append(tableContainer);

                        // Function to toggle the visibility of the Delete button
                        function toggleDeleteButton() {
                                var isAnyCheckboxChecked = $('input[type="checkbox"].row-checkbox:checked').length > 0;
                                deleteButton.toggle(isAnyCheckboxChecked);
                        }
                } else {
                        L.ui.showNoConfigMessage('URL Filtering', 'No-URLFilter-Config')

                }

        },

        RS485ConfigSectionAdd: function (id) {
                var self = this;
                var UrlfilteringSwitch = $('#UrlfilteringSwitch')[0].checked;
                var RS485ConfigSectionName = $('#UrlBlocking').val();
                // RS485ConfigSectionName = RS485ConfigSectionName.replaceAll("/", "")
                // RS485ConfigSectionName = "/" + RS485ConfigSectionName + "/";
                var Accesspolicy = $('#Accesspolicy1').val();

                // if (UrlfilteringSwitch == 1) {
                //         var Accesspolicy = $('#Accesspolicy1').val();
                // }
                // else {
                //         var Accesspolicy = "Disable";
                // }
                var sensorSectionOptions = { EEnable: 0, UrlfilteringSwitch: UrlfilteringSwitch, Accesspolicy: Accesspolicy, RS485ConfigSectionName: RS485ConfigSectionName };

                this.RS485GetUCISections("urlipconfig", "urlipconfig").then(function (rv) {
                        var keys = Object.keys(rv);
                        var uniquedevicename = [];

                        for (var key in rv) {
                                var obj = rv[key];
                                uniquedevicename.push(obj.RS485ConfigSectionName)
                        }
                        var keysLength = keys.length;
                        if (id != "") {

                        }
                        if (keysLength >= 100) {

                                L.ui.showAlert(
                                        'warning',
                                        'Limit Reached',
                                        'You can configure up to 100 URL Filerting connections only.'
                                );

                        }
                        else {
                                if (id != "") {
                                        var editfields = rv[id]
                                        var key = editfields.RS485ConfigSectionName;
                                        self.RS485DeleteUCISection("urlipconfig", "urlipconfig", id).then(function (rv) {
                                                if (rv == 0) {
                                                        self.RS485CommitUCISection("urlipconfig").then(function (res) {
                                                                if (res != 0) {
                                                                        alert("Error: Delete Configuration");
                                                                }
                                                                else {
                                                                        location.reload();
                                                                }
                                                        });
                                                };
                                        });
                                        self.RS485CreateUCISection("urlipconfig", "urlipconfig", sensorSectionOptions).then(function (rv) {
                                                if (rv) {
                                                        if (rv.section) {
                                                                self.RS485CommitUCISection("urlipconfig").then(function (res) {

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
                                // else {
                                //         debugger;
                                //         let uniquekey = uniquedevicename.includes(RS485ConfigSectionName)
                                //         if (uniquekey) {
                                //                 alert("Url Already Exists Please Enter different url")
                                //         }
                                else {
                                        self.RS485CreateUCISection("urlipconfig", "urlipconfig", sensorSectionOptions).then(function (rv) {
                                                if (rv) {
                                                        if (rv.section) {
                                                                self.RS485CommitUCISection("urlipconfig").then(function (res) {

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

        ModeConfigSectionAdd1: function (id) {
                var self = this;
                var Accesspolicy = $('#Accesspolicy1').val();
                //var UrlfilteringSwitch = 1;
                L.ui.showAlert(
                        'success',
                        'Update Complete',
                        `${Accesspolicy} Updated Succesfully`
                );

                var sensorSectionOptions = { EEnable: 1, Accesspolicy: Accesspolicy };

                // this.MACFilteringUCISections("vpnconfog1","MACFilteringConfig").then(function(rv) {
                this.RS485GetUCISections("urlipconfig", "urlipconfig").then(function (rv) {

                        var keys = Object.keys(rv);
                        for (var key in rv) {
                                self.ModechangeCreateUCISection("urlipconfig", "urlipconfig", key, sensorSectionOptions).then(function (rv) {
                                        if (rv) {
                                                if (rv.section) {
                                                        self.RS485CommitUCISection("urlipconfig").then(function (res) {

                                                                if (res != 0) {
                                                                        alert("Error:New Event Configuration");
                                                                }
                                                                else {
                                                                        setTimeout(() => {
                                                                                location.reload();
                                                                        }, 1500);

                                                                }
                                                        });
                                                };
                                        };
                                });
                        }
                        // }


                });
                this.RS485GetUCISections("urlipconfig", "Mode").then(function (rv) {

                        var keys = Object.keys(rv);
                        for (var key in rv) {
                                self.ModechangeCreateUCISection("urlipconfig", "Mode", key, sensorSectionOptions).then(function (rv) {
                                        if (rv) {
                                                if (rv.section) {
                                                        self.RS485CommitUCISection("urlipconfig").then(function (res) {

                                                                if (res != 0) {
                                                                        alert("Error:New Event Configuration");
                                                                }
                                                                else {
                                                                        setTimeout(() => {
                                                                                location.reload();
                                                                        }, 1500);
                                                                }
                                                        });
                                                };
                                        };
                                });
                        }
                        // }


                });
        },

        RS485ConfigSectionRemove: function (ev) {
                var isRealEvent = ev && typeof ev.preventDefault === 'function';
                var safeEv = isRealEvent ? ev : {
                        preventDefault: function () { },
                        target: null,
                        data: (ev && ev.data) ? ev.data : {}
                };

                var self = safeEv.data.self;
                var selectedItems = safeEv.data.selectedItems; // Array of section names to delete
                var RS485ConfigSectionName = safeEv.data.RS485ConfigSectionName;

                var infourl = `${RS485ConfigSectionName || ''} URL Filtering`;

                L.ui.confirmDelete(safeEv, infourl, function (res) {
                        if (res === 1) {
                                // Single delete logic
                                if (RS485ConfigSectionName) {
                                        self.RS485DeleteUCISection("urlipconfig", "urlipconfig", RS485ConfigSectionName).then(function (rv) {
                                                if (rv == 0) {
                                                        self.RS485CommitUCISection("urlipconfig").then(function (res) {
                                                                if (res != 0) {
                                                                        alert("Error: Delete Configuration");
                                                                } else {
                                                                        location.reload();
                                                                }
                                                        });
                                                } else {
                                                        alert("Error: Failed to delete section: " + RS485ConfigSectionName);
                                                }
                                        });
                                        return; // Exit to avoid running multiple-delete logic
                                }

                                // Multiple delete logic
                                if (!selectedItems || selectedItems.length === 0) {
                                        alert('No items selected.');
                                        return;
                                }

                                // Delete each section from the configuration
                                var deletePromises = selectedItems.map(function (sectionName) {
                                        return self.RS485DeleteUCISection("urlipconfig", "urlipconfig", sectionName).then(function (rv) {
                                                if (rv !== 0) {
                                                        return Promise.reject(new Error("Failed to delete section: " + sectionName));
                                                }
                                        });
                                });

                                // Execute all deletions and commit the changes
                                Promise.all(deletePromises)
                                        .then(function () {
                                                // Commit the changes after deleting all sections
                                                return self.RS485CommitUCISection("urlipconfig");
                                        })
                                        .then(function (res) {
                                                if (res !== 0) {
                                                        alert("Error: Commit Configuration after Deletion");
                                                } else {
                                                        location.reload(); // Refresh the page to reflect changes
                                                }
                                        })
                                        .catch(function (error) {
                                                // Handle errors during deletion or commit
                                                alert(error.message || "Error occurred during deletion");
                                        });


                        }
                })

        },

        RS485ConfigSectionEdit: function (ev) {

                $('#updatetext').text('Edit URL Filter IP Configuration');
                $('#Applyconfig')
                        .removeClass('btn-success')
                        .addClass('btn-primary')
                        .text('Save');


                // $("#Applyconfig").css("display", "none")
                // $("#editconfig").css("display", "inline")

                var key = ev.data.RS485ConfigSectionName;
                editkey = function () {
                        return key;
                }
                var porteditdata = configdata();
                var editfields = porteditdata[key];

                var status = editfields.UrlfilteringSwitch
                if (status == "1") {
                        status = true;
                }
                else {
                        status = false;
                }
                var urlfiltering = editfields.RS485ConfigSectionName
                //1.12-1.13-RC1 ### 
                //sometimes https will not get removed when add button in GUI is pressed.
                //urlfiltering = urlfiltering.replaceAll("/", "")
                //### 1.12-1.13-RC1
                $('#UrlBlocking').val(urlfiltering);
                document.getElementById("UrlfilteringSwitch").checked = status;
                $("#exampleModal").modal('show');
        },

        execute: function () {
                var self = this;
                L.ui.createNote(
                        'NOTE',
                        'After editing or deleting, please click the Update button to apply the saved configuration.',
                        { type: 'warn', variant: 'inline', appendTo: '#Update-URLFilter-Note' }
                );
                const info = localStorage.getItem('urlfilterinfo')
                $('#last-upload-url').html(info);

                $('#addnew').click(function () {
                        $('#UrlBlocking').val("");
                        document.getElementById("UrlfilteringSwitch").checked = true;
                        $('#updatetext').text('Add URL Filter IP Configuration');
                        $('#Applyconfig')
                                .removeClass('btn-primary')
                                .addClass('btn-success')
                                .text('Add');
                });
                // $("#editconfig").css("display", "none")
                // $("#Applyconfig").css("display", "inline")


                var m = new L.cbi.Map('urlipconfig', {
                });

                var s = m.section(L.cbi.NamedSection, 'general', {
                        caption: L.tr('General Configurations')
                });


                var m1 = new L.cbi.Map('urlipconfig', {
                });




                $('#Applyconfig').click(function () {
                        var btn = document.getElementById('Applyconfig');
                        var btnValue = btn.textContent.trim();


                        var url = document.getElementById("UrlBlocking").value;
                        var validationResult = document.getElementById("validationResult");
                        var res = "";

                        if (btnValue === 'Add') {
                                self.RS485ConfigSectionAdd("");
                                // btn.textContent = "Edit";
                        }
                        else if (btnValue === 'Save') {
                                var key = editkey();
                                self.RS485ConfigSectionAdd(key);
                                // btn.textContent = "Add";
                        }
                        validationResult.innerHTML = res;
                });


                $('#editconfig').click(function () {

                });
                self.RS485GetUCISections("urlipconfig", "urlipconfig").then(function (rv) {
                        self.RS485RenderContents(rv);
                });

                $('#update_urlfilter').click(function () {
                        L.ui.loading(true);
                        self.updatefirewallconfig('configure').then(function (rv) {


                                L.ui.showAlert(
                                        'success',
                                        'Update Complete',
                                        'URL Filtering Configurations Updated successfully'
                                );
                                setTimeout(() => {
                                        location.reload()
                                }, 1500);


                                L.ui.loading(false);
                        });
                });
                //URL List    
                $('#btn_upload').click(function () {


                        self.handleArchiveUpload();

                });


                $('#ChangeMode1').click(function () {
                        self.ModeConfigSectionAdd1(1);
                })

                s.commit = function () {

                        self.updateopenvpnconfig('enableopenvpn').then(function (rv) {

                        });
                }
        }
});


