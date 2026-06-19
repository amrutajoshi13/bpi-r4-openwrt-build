L.ui.view.extend({
    cleanBackup: L.rpc.declare({
        object: 'luci2.system',
        method: 'backup_clean'
    }),

    TestArchive: L.rpc.declare({
        object: 'rpc-uploadSNMPmib',
        method: 'testarchive',
        params: ['archive'],
    }),

    sendConfigRowIndex: 0,
    editingSendConfigRow: null,
    currentEditingRow: null,



    catchingJSONData: function () {
        const self = this;

        document.getElementById('saveDeviceButton').addEventListener('click', async function (event) {
            event.preventDefault();

            const deviceName = document.getElementById('deviceName').value.trim();
            if (!deviceName) {
                L.ui.showAlert(
                    "error",
                    "Missing Device Name",
                    "Please enter a device name to continue."
                );
                return;
            }

            const actionType = self.isUpdateMode ? "Edit" : "Add";

            // ALL VALUES AS STRINGS
            const InterfaceID = document.getElementById('interfaceid').value;
            const MeterID = document.getElementById('meterid').value;
            const Model = document.getElementById('metermodel').value;

            const SlaveAddress = document.getElementById('serialslaveid').value;
            const Baudrate = document.getElementById('serialbaudrate').value;
            const Parity = document.getElementById('serialparity').value;
            const Databits = document.getElementById('serialdatabits').value;
            const NoOfStopbits = document.getElementById('serialstopbit').value;
            const FunctionalCode = document.getElementById('functioncode').value;
            const FlowControl = document.getElementById('flowcontrol').value;

            const Delay = document.getElementById('delay').value;
            const StartRegister = document.getElementById('startregister').value;
            const NoOfRegister = document.getElementById('noOfRegister').value;
            // VALIDATION

            if (!InterfaceID) {
                L.ui.showAlert("warning", "Empty field", "Please enter Interface ID.");
                return;
            }

            if (!MeterID) {
                L.ui.showAlert("warning", "Empty field", "Please enter Meter ID.");
                return;
            }

            if (!Model) {
                L.ui.showAlert("warning", "Empty field", "Please enter Model.");
                return;
            }

            if (!SlaveAddress) {
                L.ui.showAlert("warning", "Empty field", "Please enter Slave Address.");
                return;
            }

            if (!Delay) {
                L.ui.showAlert("warning", "Empty field", "Please enter Delay.");
                return;
            }

            if (!StartRegister) {
                L.ui.showAlert("warning", "Empty field", "Please enter Start Register.");
                return;
            }

            if (!NoOfRegister) {
                L.ui.showAlert("warning", "Empty field", "Please enter Number Of Registers.");
                return;
            }

            const communicationConfig = {
                actionType,
                deviceName,
                InterfaceID,
                MeterID,
                Model,
                StartRegister,
                NoOfRegister,
                Baudrate,
                NoOfStopbits,
                Databits,
                FunctionalCode,
                Parity,
                FlowControl,
                Delay,
                SlaveAddress
            };

            document.getElementById("loadingOverlay").style.display = "flex";

            try {
                await self.sendCommunicationConfigAPI(communicationConfig);

                L.ui.showAlert(
                    "success",
                    "Saved Successful",
                    " Device Configurations has been saved successfully."
                );

                // self.addDeviceDataToTable(communicationConfig, self.isUpdateMode);
                self.toggleSendConfigTabVisibility();

                setTimeout(() => location.reload(), 2000);
                $('#SNMPMasterModal').modal('hide');

            } catch (error) {
                console.error('Error processing device:', error);
                L.ui.showAlert(
                    "error",
                    "Save Failed",
                    "Unable to save the device. Please try again."
                );
            } finally {
                document.getElementById("loadingOverlay").style.display = "none";
            }
        });
    },

    sendCommunicationConfigAPI: function (communicationConfig) {
        let params = window.location.href;
        let BaseURL = new URL(params).origin;
        //return fetch(`https://cors-anywhere.herokuapp.com/https://webhook.site/b586ea75-e0a0-4cc1-b20b-cfbba37afd9b`, {
        return fetch(`${BaseURL}:30007/RS232_Post/`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(communicationConfig)
        }).then(response => {
            if (!response.ok) throw new Error('Network response was not ok');
            return response.text();
        }).then(text => {
        });
    },

    addDeviceRowToTable: function (device) {
        const self = this;
        const table = document.getElementById('devicesTable');
        const tableContainer = document.querySelector('.table-container');

        // Create headers ONLY when first row comes
        self.ensureDeviceTableReady();

        if (tableContainer) {
            tableContainer.style.display = 'block';
        }

        let tbody = table.querySelector('tbody');
        if (!tbody) {
            tbody = document.createElement('tbody');
            table.appendChild(tbody);
        }

        const row = document.createElement('tr');

        row.innerHTML = `
        <td>${tbody.children.length + 1}</td>
        <td>${device.deviceName}</td>
        <td>${device.SlaveID || '-'}</td>
        <td>${device.FunctionalCode || '-'}</td>
        <td>${device.MeterID || '-'}</td>
        <td>
            <button class="btn btn-primary editBtn">Edit</button>
            <button class="btn btn-danger deleteBtn">Delete</button>
        </td>
    `;

        row.querySelector('.editBtn').addEventListener('click', () => {
            self.fetchDeviceDetails(device.deviceName);
        });

        self.attachDeleteHandler(row);
        tbody.appendChild(row);
    },


    ensureDeviceTableReady: function () {
        const table = document.getElementById('devicesTable');
        if (!table) return;

        let thead = table.querySelector('thead');

        if (!thead) {
            thead = document.createElement('thead');
            table.appendChild(thead);
        }

        if (thead.rows.length === 0) {
            thead.innerHTML = `
            <tr>
                <th>SNID</th>
                <th>Device Name</th>
                <th>Slave ID</th>
                <th>Function Code</th>
                <th>Meter ID</th>
                <th>Actions</th>
            </tr>
        `;
        }
    },


    fetchDeviceTableData: function () {
        const self = this;
        let params = window.location.href;
        let BaseURL = new URL(params).origin;
        //    fetch('https://mocki.io/v1/b2798d1a-0f84-47c0-9bef-297149bf10e2') // TABLE API
        fetch(`${BaseURL}:30007/RS232_Configuration/`) // TABLE API
            .then(res => res.json())
            .then(data => {
                const devices = Array.isArray(data) ? data : [data];
                devices.forEach(device => {
                    self.addDeviceRowToTable(device);
                });
                self.toggleSendConfigTabVisibility();
            })
            .catch(err => console.error("Table API failed:", err));
    },


    attachDeleteHandler: function (row) {
        const self = this;

        row.querySelector('.deleteBtn').addEventListener('click', async function () {
            const deviceName = row.cells[1]?.textContent?.trim();
            if (!deviceName) return;

            document.getElementById("loadingOverlay").style.display = "flex";

            try {
                await self.sendDeleteDeviceAPI(deviceName);

                L.ui.showAlert(
                    "success",
                    "Deleted Successfully",
                    `device "${deviceName}" has been deleted successfully.`
                );


                row.remove();

                const tbody = document.querySelector('#devicesTable tbody');
                const thead = document.querySelector('#devicesTable thead');
                const tableContainer = document.querySelector('.table-container');

                // Renumber
                tbody.querySelectorAll('tr').forEach((r, i) => {
                    r.cells[0].textContent = i + 1;
                });

                //  NO ROWS → REMOVE HEADERS + HIDE TABLE
                if (tbody.children.length === 0) {
                    if (thead) thead.innerHTML = '';
                    if (tableContainer) tableContainer.style.display = 'none';
                }
                setTimeout(() => {
                    location.reload();
                }, 2000);

            } catch (err) {
                L.ui.showAlert(
                    "error",
                    "Delete Failed",
                    "Unable to delete the device. Please try again."
                );

            } finally {
                document.getElementById("loadingOverlay").style.display = "none";
                self.toggleSendConfigTabVisibility();
            }
        });
    },

    fetchDeviceDetails: function (deviceName) {
        const self = this;
        let params = window.location.href;
        let BaseURL = new URL(params).origin;
        //fetch('https://mocki.io/v1/9d9b5773-824f-45a6-87c5-2b71249380ab') // MODAL API
        fetch(`${BaseURL}:30007/Parameter_Configuration/${deviceName}`) // MODAL API
            .then(res => res.json())
            .then(data => {
                const device = Array.isArray(data)
                    ? data.find(d => d.deviceName === deviceName)
                    : data;

                if (!device) {
                    L.ui.showAlert(
                        "error",
                        "Device Not Found",
                        "The requested device could not be found."
                    );
                    return;
                }

                self.populateDeviceModal(device);
            })
            .catch(err => console.error("Modal API failed:", err));
    },


    populateDeviceModal: function (device) {
        this.isUpdateMode = true;
        this.originalDeviceName = device.deviceName;

        document.getElementById('deviceName').value = device.deviceName;
        document.getElementById('interfaceid').value = device.InterfaceID;
        document.getElementById('meterid').value = device.MeterID;
        document.getElementById('metermodel').value = device.Model;
        document.getElementById('serialslaveid').value = device.SlaveAddress;

        document.getElementById('serialbaudrate').value = device.Baudrate;
        document.getElementById('serialparity').value = device.Parity;
        document.getElementById('serialdatabits').value = device.Databits;
        document.getElementById('serialstopbit').value = device.NoOfStopbits;
        document.getElementById('functioncode').value = device.FunctionalCode;
        document.getElementById('flowcontrol').value = device.FlowControl;

        document.getElementById('delay').value = device.Delay;
        document.getElementById('startregister').value = device.StartRegister;
        document.getElementById('noOfRegister').value = device.NoOfRegister;

        document.getElementById('deviceName').readOnly = true;
        document.getElementById('addDeviceModalLabel').textContent = "Update Device";
        document.getElementById('saveDeviceButton').textContent = "Update Device";

        $('#SNMPMasterModal').modal('show');
    },

    sendDeleteDeviceAPI: function (deviceName) {
        let params = window.location.href;
        let BaseURL = new URL(params).origin;
        //return fetch(`https://cors-anywhere.herokuapp.com/https://webhook.site/b586ea75-e0a0-4cc1-b20b-cfbba37afd9b`, {
        return fetch(`${BaseURL}:30007/RS232_Post/`, {
            method: 'POST',  // If DELETE is supported, change this to 'DELETE'
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ actionType: "Delete", deviceName })
        })
            .then(response => {
                if (!response.ok) throw new Error('Network response was not ok');
                return response.text();  //  No JSON parsing, just return text
            })
            .then(text => {
            })
            .catch(error => {
                console.error("Error deleting device:", error);
            });
    },

    addSendConfigRow: function () {
        const self = this; // Capture correct context

        const fieldContent = document.getElementById('fieldContentDropdown').value;
        const jsonKey = document.getElementById('fieldJsonKey').value.trim();
        const value = document.getElementById('fieldJsonKeyValue')?.value.trim() || '';
        const tableBody = document.querySelector('#sendConfigTable tbody');
        const tableContainer = document.getElementById('sendConfigTableContainer');

        if (!fieldContent || !jsonKey) {
            L.ui.showAlert("error",
                "Validation Error",
                "Please select a Field Content and enter a JSON Key Name.");
            return;
        }

        const row = document.createElement('tr');
        row.innerHTML = `
        <td></td>
        <td>${fieldContent}</td>
        <td>${jsonKey}</td>
        <td class="action-buttons">
            <button class="btn btn-primary btn-sm">Edit</button>
            <button class="btn btn-danger btn-sm">Delete</button>
        </td>
    `;

        row.querySelector('.btn-primary').addEventListener('click', () => {
            self.editingSendConfigRow = row;
            const field = row.cells[1].textContent;
            const jsonKey = row.cells[2].textContent;
            const value = row.getAttribute('data-json-key-value') || '';
            document.getElementById('editJsonKeyValue').value = '';

            document.getElementById('editFieldContent').value = field;
            document.getElementById('editFieldJsonKey').value = jsonKey;
            // document.getElementById('editJsonKeyValue').value = jsonKeyValue;

            const isCustom = field.startsWith('RS232Customfield');
            document.getElementById('jsonKeyValueGroup').style.display = isCustom ? 'block' : 'none';
            // document.getElementById('editJsonKeyValue').value = jsonKeyValue;
            if (isCustom) {
                document.getElementById('editJsonKeyValue').value = value;
            }

            $('#editSendConfigModal').modal('show');
        });


        row.querySelector('.btn-danger').addEventListener('click', () => {
            row.remove();
            self.reindexSendConfigRows();

            // OPTIONAL: Hide table if empty
            if (tableBody.children.length === 0) {
                tableContainer.style.display = 'none';
            }
        });
        tableBody.appendChild(row);
        row.setAttribute('data-json-key-value', value);

        tableContainer.style.display = 'block';
        self.reindexSendConfigRows();

        // Clear inputs
        document.getElementById('fieldContentDropdown').value = '';
        document.getElementById('fieldJsonKey').value = '';
        document.getElementById('fieldJsonKeyValue').value = '';
        document.getElementById('jsonKeyValueGroupAdd').style.display = 'none';
    },

    reindexSendConfigRows: function () {
        const rows = document.querySelectorAll('#sendConfigTable tbody tr');
        rows.forEach((row, index) => {
            row.cells[0].textContent = index + 1;
        });
        if (rows.length === 0) {
            document.getElementById('sendConfigTableContainer').style.display = 'none';
        }
    },


    saveSendConfigChanges: function () {
        const fieldContent = document.getElementById('editFieldContent').value;
        const jsonKey = document.getElementById('editFieldJsonKey').value.trim();
        const value = document.getElementById('editJsonKeyValue').value.trim(); // new field

        if (!fieldContent || !jsonKey) {
            L.ui.showAlert(
                "error",
                "Validation Error",
                "Both fields are mandatory and must be filled in."
            );

            return;
        }

        if (this.editingSendConfigRow) {
            this.editingSendConfigRow.cells[1].textContent = fieldContent;
            this.editingSendConfigRow.cells[2].textContent = jsonKey;
            // this.editingSendConfigRow.setAttribute('data-json-key-value', jsonKeyValue);

            // Save the JSON key value only for SNMPCustomfield1–5
            const isCustomField = ['RS232Customfield1', 'RS232Customfield2', 'RS232Customfield3', 'RS232Customfield4', 'RS232Customfield5'].includes(fieldContent);

            if (isCustomField) {
                this.editingSendConfigRow.setAttribute('data-json-key-value', value);
            } else {
                this.editingSendConfigRow.removeAttribute('data-json-key-value');
            }
        }

        $('#editSendConfigModal').modal('hide');
    },

    updateAllSendConfigs: function () {
        const self = this;
        let params = window.location.href;
        let BaseURL = new URL(params).origin;
        const tableRows = document.querySelectorAll('#sendConfigTable tbody tr');

        if (tableRows.length === 0) {
            L.ui.showAlert(
                "error",
                "No Data to Update",
                "There are no rows available to update."
            );

            return;
        }

        const sendConfigs = [];

        tableRows.forEach(row => {
            const fieldContent = row.cells[1].textContent.trim();
            const jsonKey = row.cells[2].textContent.trim();
            const value = row.getAttribute('data-json-key-value') || '';

            if (fieldContent && jsonKey) {
                const config = { fieldContent, jsonKey };
                if (fieldContent.startsWith('RS232Customfield')) {
                    config.value = value;
                }
                sendConfigs.push(config);
            }
        });

        //Ensure SNMPData is always last
        const snmpIndex = sendConfigs.findIndex(
            item => item.fieldContent.toLowerCase() === "snmpdata"
        );
        if (snmpIndex > -1) {
            const [snmpItem] = sendConfigs.splice(snmpIndex, 1);
            sendConfigs.push(snmpItem);
        }

        // Show loading overlay for Send Configuration
        document.getElementById("sendConfigLoadingOverlay").style.display = "flex";

        fetch(`${BaseURL}:30005/POST_Selected_RS232_Configuration/`, {
            //fetch(`https://cors-anywhere.herokuapp.com/https://webhook.site/b586ea75-e0a0-4cc1-b20b-cfbba37afd9b`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(sendConfigs)
        })
            .then(response => {
                if (!response.ok) throw new Error("Network error");
                return response.text();
            })
            .then(responseText => {
                L.ui.showAlert("success", "Saved successfully", "Device updated successfully !");
                setTimeout(() => {
                    location.reload();
                }, 1000);

            })
            .catch(error => {
                console.error("Send Config Update Failed:", error);
                L.ui.showAlert("error", "Save Failed", "Failed to update send configurations!");
            })
            .finally(() => {
                document.getElementById("sendConfigLoadingOverlay").style.display = "none";
            });
    },

    toggleSendConfigTabVisibility: function () {
        const tableBody = document.querySelector('#devicesTable tbody');
        const sendConfigTab = document.getElementById('sendConfigTab');

        if (tableBody && sendConfigTab) {
            const hasDevices = tableBody.rows.length > 0;

            if (hasDevices) {
                sendConfigTab.classList.remove('disabled-tab');
                sendConfigTab.style.pointerEvents = 'auto';
                sendConfigTab.style.opacity = '1';
            } else {
                sendConfigTab.classList.add('disabled-tab');
                sendConfigTab.style.pointerEvents = 'none';
                sendConfigTab.style.opacity = '0.5';
            }
        }
    },

    bindModbusTiming: function () {
        const self = this;
        if (this._modbusTimingBound) return;
        this._modbusTimingBound = true;
        const sleepRetrie = document.getElementById('deviceInput');
        const noOFRetrie = document.getElementById('deviceDelay');

        if (!sleepRetrie || !noOFRetrie) return;

        // --- Periodicity ---
        sleepRetrie.addEventListener('change', () => {
            const sleep = parseInt(sleepRetrie.value, 10);

            if (isNaN(sleep) || sleep < 120) {
                L.ui.showAlert(
                    "error",
                    "Invalid Periodicity value",
                    "The overall Periodicity must be 120 seconds or greater."
                );

                sleepRetrie.value = 120;
                return;
            }

            self.postModbusTiming();
        });

        // --- Delay ---
        noOFRetrie.addEventListener('change', () => {
            const retrie = parseInt(noOFRetrie.value, 10);

            if (isNaN(retrie) || retrie < 0) {
                L.ui.showAlert(
                    "error",
                    "Delay Too Low",
                    "Please enter a delay value of 0 or higher."
                );
                noOFRetrie.value = 2000;
                return;
            }

            self.postModbusTiming();
        });
    },
    postModbusTiming: function () {
        const self = this;
        const sleepRetrie = parseInt(document.getElementById('deviceInput')?.value, 10);
        const noOFRetrie = parseInt(document.getElementById('deviceDelay')?.value, 10);

        if (isNaN(sleepRetrie) || sleepRetrie < 60) return;

        let BaseURL = new URL(window.location.href).origin;

        fetch(`${BaseURL}:30008/RS232_Source_post/`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                SleepRetries: sleepRetrie,
                MaxNoOfRetries: noOFRetrie || 0
            })
        })
            .then(res => {
                if (!res.ok) {
                    throw new Error("Failed to save RS232 timing");
                }
                return res.text();
            })
            .then(() => {
                L.ui.showAlert(
                    "success",
                    "Applied",
                    "Configuration applied successfully!"
                );
                setTimeout(() => {
                    location.reload();
                }, 1000);
            })
            .catch(err => {
                console.error("RS232 save failed:", err);
                L.ui.showAlert(
                    "error",
                    "Failed",
                    "Failed to update configuration."
                );
            });
    },

    fetchModbusTiming: function () {
        const periodicityInput = document.getElementById('deviceInput');
        const delayInput = document.getElementById('deviceDelay');

        if (!periodicityInput || !delayInput) return;

        let BaseURL = new URL(window.location.href).origin;

        fetch(`${BaseURL}:30008/RS232_Enable/`)
            //fetch(`https://mocki.io/v1/d547d17d-8377-49b0-ad83-e0f6594b0b72`)
            .then(res => {
                if (!res.ok) throw new Error("GET failed");
                return res.json();
            })
            .then(data => {
                periodicityInput.value =
                    data.SleepRetries ?? 120;

                delayInput.value =
                    data.MaxNoOfRetries ?? 0;
            })
            .catch(err => {
                console.error(" Failed to fetch Modbus timing:", err);
            });
    },

    disableSNMPPage: function () {
        const wrapper = document.getElementById("snmpContentWrapper");
        const overlay = document.getElementById("snmpDisabledOverlay");

        if (wrapper) wrapper.classList.add("snmp-blurred");
        if (overlay) overlay.style.display = "flex";
    },

    enableSNMPPage: function () {
        const wrapper = document.getElementById("snmpContentWrapper");
        const overlay = document.getElementById("snmpDisabledOverlay");

        if (wrapper) wrapper.classList.remove("snmp-blurred");
        if (overlay) overlay.style.display = "none";
    },



    // execute: async function () {
    //     const self = this;
    //     let params = window.location.href;
    //     let BaseURL = new URL(params).origin;
    //     // Check SNMP app state
    //     try {
    //         const res = await fetch(`${BaseURL}:30008/device/applications/`);
    //         const apps = await res.json();
    //         const rs232App = apps.find(app => app.id === "rs232");

    //         if (!rs232App || rs232App.state !== "running") {
    //             self.disableSNMPPage();
    //         }

    //         self.enableSNMPPage();
    //     } catch (err) {
    //         console.error("Execute API failed:", err);
    //         self.disableSNMPPage();
    //     }

    //     //Populate Field Content Dropdown
    //     fetch(`${BaseURL}:30005/RS232_Available_Configuration/`)
    //         //fetch(`https://mocki.io/v1/960797d2-fbc7-444c-bf15-d7765b4887f5`)
    //         .then(res => res.json())
    //         .then(data => {
    //             const dropdown = document.getElementById('fieldContentDropdown');
    //             const editDropdown = document.getElementById('editFieldContent');

    //             dropdown.innerHTML = '<option value="">Select Field Content</option>';
    //             editDropdown.innerHTML = '<option value="">Select Field Content</option>';

    //             data.forEach(item => {
    //                 const option = document.createElement('option');
    //                 option.value = item.fieldContent;
    //                 option.textContent = item.fieldContent;
    //                 dropdown.appendChild(option);

    //                 // also add to edit modal
    //                 const editOption = option.cloneNode(true);
    //                 editDropdown.appendChild(editOption);
    //             });
    //         })
    //         .catch(err => console.error("Error loading dropdown values:", err));


    //     //Populate Existing Table Rows
    //     // fetch('https://mocki.io/v1/7c72f490-b284-4a4e-86f2-d1b9f95f2066')
    //     fetch(`${BaseURL}:30005/RS232_Selected_Configuration/`)
    //         .then(res => res.json())
    //         .then(data => {
    //             const tableBody = document.querySelector('#sendConfigTable tbody');
    //             const tableContainer = document.getElementById('sendConfigTableContainer');

    //             if (Array.isArray(data) && data.length > 0) {
    //                 tableContainer.style.display = 'block';
    //                 data.forEach((item, index) => {
    //                     const row = document.createElement('tr');
    //                     row.innerHTML = `
    //                     <td>${index + 1}</td>
    //                     <td>${item.fieldContent}</td>
    //                     <td>${item.jsonKey}</td>
    //                     <td class="action-buttons">
    //                         <button class="btn btn-primary btn-sm">Edit</button>
    //                         <button class="btn btn-danger btn-sm">Delete</button>
    //                     </td>
    //                 `;

    //                     row.setAttribute('data-json-key-value', item.value || '');

    //                     // Set up event listeners
    //                     row.querySelector('.btn-primary').addEventListener('click', () => {
    //                         self.editingSendConfigRow = row;

    //                         const field = row.cells[1].textContent.trim();
    //                         const jsonKey = row.cells[2].textContent.trim();
    //                         const value = row.getAttribute('data-json-key-value') || '';

    //                         document.getElementById('editFieldContent').value = field;
    //                         document.getElementById('editFieldJsonKey').value = jsonKey;

    //                         const isCustom = field.startsWith('RS232Customfield');
    //                         document.getElementById('jsonKeyValueGroup').style.display = isCustom ? 'block' : 'none';
    //                         document.getElementById('editJsonKeyValue').value = isCustom ? value : '';

    //                         $('#editSendConfigModal').modal('show');
    //                     });
    //                     row.querySelector('.btn-danger').addEventListener('click', () => {
    //                         row.remove();
    //                         this.reindexSendConfigRows();
    //                         if (tableBody.children.length === 0) {
    //                             tableContainer.style.display = 'none';
    //                         }
    //                     });

    //                     tableBody.appendChild(row);
    //                 });
    //             }
    //         })
    //         .catch(err => console.error("Error loading table values:", err));




    //     document.getElementById('addSendConfigRow').addEventListener('click', function () {
    //         self.addSendConfigRow();
    //     });

    //     document.getElementById('saveSendConfigChanges').addEventListener('click', function () {
    //         self.saveSendConfigChanges();
    //     });
    //     document.getElementById('editFieldContent').addEventListener('change', function () {
    //         const selected = this.value;
    //         const isCustom = selected.startsWith('RS232Customfield');
    //         document.getElementById('jsonKeyValueGroup').style.display = isCustom ? 'block' : 'none';
    //         if (!isCustom) {
    //             document.getElementById('editJsonKeyValue').value = '';
    //         }
    //     });
    //     document.getElementById('updateAllSendConfigsBtn')
    //         .addEventListener('click', () => self.updateAllSendConfigs());

    //     validateDeviceName = function () {
    //         var inputField = document.getElementById("deviceName");
    //         var value = inputField.value;


    //         var regex = /^[A-Za-z0-9]+$/;

    //         if (!regex.test(value)) {
    //             L.ui.showAlert(
    //                 "error",
    //                 "Invalid Device Name",
    //                 "The device name may contain only letters and numbers. Spaces and special characters are not allowed."
    //             );
    //             inputField.value = value.replace(/[^A-Za-z0-9]/g, '');
    //         }
    //     }
    //     // Reset form and counters when "Add Device" is clicked
    //     document.getElementById('smpmasterdevice').addEventListener('click', function () {
    //         document.getElementById('snmp-device-config').reset();
    //         document.getElementById('deviceName').readOnly = false; //  Allow editing when adding a new device

    //         self.isUpdateMode = false;  // Reset update mode
    //         self.originalDeviceName = ""; // Reset stored name

    //         //  Reset modal title and button text
    //         document.getElementById('addDeviceModalLabel').textContent = "Add New Device";
    //         document.getElementById('saveDeviceButton').textContent = "Save Device";


    //         $('#SNMPMasterModal').modal('show');
    //     });

    //     this.bindModbusTiming();
    //     this.fetchModbusTiming();
    //     this.catchingJSONData();
    //     this.toggleSendConfigTabVisibility();
    //     this.fetchDeviceTableData();

    // }
    execute: async function () {
        const self = this;
        let BaseURL = new URL(window.location.href).origin;

        // Check RS232 app state with retry
        async function checkState(retryCount) {
            retryCount = retryCount || 0;
            const MAX_RETRIES = 3;
            const RETRY_DELAY_MS = 2000;

            try {
                const res = await fetch(`${BaseURL}:30008/device/applications/`);
                if (!res.ok) throw new Error('Non-OK response: ' + res.status);
                const apps = await res.json();
                const rs232App = apps.find(app => app.id === "rs232");

                if (rs232App && rs232App.state === "running") {
                    self.enableSNMPPage();
                } else {
                    self.disableSNMPPage();
                }
            } catch (err) {
                console.error('Execute API failed (attempt ' + (retryCount + 1) + '):', err);

                if (retryCount < MAX_RETRIES) {
                    await new Promise(resolve => setTimeout(resolve, RETRY_DELAY_MS));
                    return checkState(retryCount + 1);
                } else {
                    console.warn('Max retries reached. Disabling RS232 page.');
                    self.disableSNMPPage();
                }
            }
        }

        await checkState(0);

        // Rest of execute only runs after state is resolved
        fetch(`${BaseURL}:30005/RS232_Available_Configuration/`)
            .then(res => res.json())
            .then(data => {
                const dropdown = document.getElementById('fieldContentDropdown');
                const editDropdown = document.getElementById('editFieldContent');

                dropdown.innerHTML = '<option value="">Select Field Content</option>';
                editDropdown.innerHTML = '<option value="">Select Field Content</option>';

                data.forEach(item => {
                    const option = document.createElement('option');
                    option.value = item.fieldContent;
                    option.textContent = item.fieldContent;
                    dropdown.appendChild(option);
                    editDropdown.appendChild(option.cloneNode(true));
                });
            })
            .catch(err => console.error("Error loading dropdown values:", err));

        fetch(`${BaseURL}:30005/RS232_Selected_Configuration/`)
            .then(res => res.json())
            .then(data => {
                const tableBody = document.querySelector('#sendConfigTable tbody');
                const tableContainer = document.getElementById('sendConfigTableContainer');

                if (Array.isArray(data) && data.length > 0) {
                    tableContainer.style.display = 'block';
                    data.forEach((item, index) => {
                        const row = document.createElement('tr');
                        row.innerHTML = `
                        <td>${index + 1}</td>
                        <td>${item.fieldContent}</td>
                        <td>${item.jsonKey}</td>
                        <td class="action-buttons">
                            <button class="btn btn-primary btn-sm">Edit</button>
                            <button class="btn btn-danger btn-sm">Delete</button>
                        </td>
                    `;
                        row.setAttribute('data-json-key-value', item.value || '');

                        row.querySelector('.btn-primary').addEventListener('click', () => {
                            self.editingSendConfigRow = row;
                            const field = row.cells[1].textContent.trim();
                            const jsonKey = row.cells[2].textContent.trim();
                            const value = row.getAttribute('data-json-key-value') || '';

                            document.getElementById('editFieldContent').value = field;
                            document.getElementById('editFieldJsonKey').value = jsonKey;

                            const isCustom = field.startsWith('RS232Customfield');
                            document.getElementById('jsonKeyValueGroup').style.display = isCustom ? 'block' : 'none';
                            document.getElementById('editJsonKeyValue').value = isCustom ? value : '';

                            $('#editSendConfigModal').modal('show');
                        });

                        row.querySelector('.btn-danger').addEventListener('click', () => {
                            row.remove();
                            self.reindexSendConfigRows();
                            if (tableBody.children.length === 0) {
                                tableContainer.style.display = 'none';
                            }
                        });

                        tableBody.appendChild(row);
                    });
                }
            })
            .catch(err => console.error("Error loading table values:", err));

        document.getElementById('addSendConfigRow').addEventListener('click', function () {
            self.addSendConfigRow();
        });
        document.getElementById('saveSendConfigChanges').addEventListener('click', function () {
            self.saveSendConfigChanges();
        });
        document.getElementById('editFieldContent').addEventListener('change', function () {
            const selected = this.value;
            const isCustom = selected.startsWith('RS232Customfield');
            document.getElementById('jsonKeyValueGroup').style.display = isCustom ? 'block' : 'none';
            if (!isCustom) {
                document.getElementById('editJsonKeyValue').value = '';
            }
        });
        document.getElementById('updateAllSendConfigsBtn')
            .addEventListener('click', () => self.updateAllSendConfigs());

        validateDeviceName = function () {
            var inputField = document.getElementById("deviceName");
            var value = inputField.value;
            var regex = /^[A-Za-z0-9]+$/;
            if (!regex.test(value)) {
                L.ui.showAlert(
                    "error",
                    "Invalid Device Name",
                    "The device name may contain only letters and numbers. Spaces and special characters are not allowed."
                );
                inputField.value = value.replace(/[^A-Za-z0-9]/g, '');
            }
        }

        document.getElementById('smpmasterdevice').addEventListener('click', function () {
            document.getElementById('snmp-device-config').reset();
            document.getElementById('deviceName').readOnly = false;
            self.isUpdateMode = false;
            self.originalDeviceName = "";
            document.getElementById('addDeviceModalLabel').textContent = "Add New Device";
            document.getElementById('saveDeviceButton').textContent = "Save Device";
            $('#SNMPMasterModal').modal('show');
        });

        this.bindModbusTiming();
        this.fetchModbusTiming();
        this.catchingJSONData();
        this.toggleSendConfigTabVisibility();
        this.fetchDeviceTableData();
    }
});
