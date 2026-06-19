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

    // Declare counters globally so they persist
    oidCounter: 0,
    trapCounter: 0,
    sendConfigRowIndex: 0,
    editingSendConfigRow: null,
    currentEditingRow: null,


    // FILE UPLOAD 

    handleArchiveUpload: function () {
        var self = this;
        L.ui.archiveSNMPUpload(
            L.tr('Archive Upload'),
            L.tr('Select the archive and click on "Apply" button to proceed.').format(L.tr('Apply')), {
            success: function (info) {
                self.handleArchiveVerify(info);
            }
        }
        );
    },

    handleArchiveVerify: function (info) {
        var self = this;
        var archive = $('[name=filename]').val();

        // if((checksumval == info.checksum) &&(sizeval == info.size)) {
        L.ui.loading(true);
        self.TestArchive(archive).then(function (TestArchiveOutput) {

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

    addOIDRow: function (oidData = {}) {
        const self = this;
        const rowContainer = document.querySelector('#OIDTextBoxes');

        const row = document.createElement('div');
        row.classList.add('form-row');
        row.innerHTML = `
            <div class="form-group col-md-3">
                <label>Parameter Name</label>
                <input type="text" class="form-control" id="oidName${self.oidCounter}" 
                       name="oidName[${self.oidCounter}]" placeholder="Enter OID Name" 
                       value="${oidData.JSONKeyName || ''}">
            </div>
            <div class="form-group col-md-3">
                <label>OID Name/Number</label>
                <input type="text" class="form-control" id="oidNumber${self.oidCounter}" 
                       name="oidNumber[${self.oidCounter}]" placeholder="Enter OID Number" 
                       value="${oidData["OIDNumber/Name"] || ''}">
            </div>
            <div class="form-group col-md-3">
                <label>Data Type</label>
                <select class="form-control" id="dataType${self.oidCounter}" name="dataType[${self.oidCounter}]">
                    <option value="">Select type</option>
                    <option value="0" ${oidData.OIDDataType === 0 ? "selected" : ""}>Gauge32</option>
                    <option value="1" ${oidData.OIDDataType === 1 ? "selected" : ""}>Integer</option>
                    <option value="2" ${oidData.OIDDataType === 2 ? "selected" : ""}>String</option>
                </select>
            </div>
            <div class="col-md-3">
                <input type="button" value="Delete" class="btn btn-danger oidRemoveButton" style="margin-top: 22px;">
            </div>
        `;

        row.querySelector('.oidRemoveButton').addEventListener('click', function () {
            row.remove();
        });

        rowContainer.appendChild(row);
        self.oidCounter++;
    },

    addTrapRow: function (trapData = {}) {
        const self = this;
        const rowContainer = document.querySelector('#trapTextBoxes');

        const row = document.createElement('div');
        row.classList.add('form-row', 'trap-entry');
        row.innerHTML = `
            <div class="form-group col-md-2 trap-form">
                <label>Trap Name</label>
                <input type="text" class="form-control form-control-sm trap-input" id="trapName${self.trapCounter}" 
                       name="trapName[${self.trapCounter}]" placeholder="Trap Name" 
                       value="${trapData.TrapName || ''}" >
            </div>
            <div class="form-group col-md-2">
                <label>Alarm Name</label>
                <input type="text" class="form-control form-control-sm trap-input" id="alarmName${self.trapCounter}" 
                       name="alarmName[${self.trapCounter}]" placeholder="Alarm Name" 
                       value="${trapData.AlarmName || ''}">
            </div>
            <div class="form-group col-md-2">
                <label>Alarm Open Str</label>
                <input type="text" class="form-control form-control-sm trap-input" id="alarmOpenString${self.trapCounter}" 
                       name="alarmOpenString[${self.trapCounter}]" placeholder="Open String" 
                       value="${trapData.AlarmOpenString || ''}">
            </div>
            <div class="form-group col-md-2">
                <label>Open Substr 1</label>
                <input type="text" class="form-control form-control-sm trap-input" id="alarmOpenSubstring1${self.trapCounter}" 
                       name="alarmOpenSubstring1[${self.trapCounter}]" placeholder="Substring 1" 
                       value="${trapData.AlarmOpenSubstring1 || ''}">
            </div>
            <div class="form-group col-md-2">
                <label>Open Substr 2</label>
                <input type="text" class="form-control form-control-sm trap-input" id="alarmOpenSubstring2${self.trapCounter}" 
                       name="alarmOpenSubstring2[${self.trapCounter}]" placeholder="Substring 2" 
                       value="${trapData.AlarmOpenSubstring2 || ''}">
            </div>
            <div class="form-group col-md-2">
                <label>Alarm Close Str</label>
                <input type="text" class="form-control form-control-sm trap-input" id="alarmCloseString${self.trapCounter}" 
                       name="alarmCloseString[${self.trapCounter}]" placeholder="Close String" 
                       value="${trapData.AlarmCloseString || ''}">
            </div>
    
            <div class="form-group col-md-2">
                <label>Close Substr 1</label>
                <input type="text" class="form-control form-control-sm trap-input" id="alarmCloseSubstring1${self.trapCounter}" 
                       name="alarmCloseSubstring1[${self.trapCounter}]" placeholder="Close Substring 1" 
                       value="${trapData.AlarmCloseSubstring1 || ''}">
            </div>
            <div class="form-group col-md-2">
                <label>Close Substr 2</label>
                <input type="text" class="form-control form-control-sm trap-input" id="alarmCloseSubstring2${self.trapCounter}" 
                       name="alarmCloseSubstring2[${self.trapCounter}]" placeholder="Close Substring 2" 
                       value="${trapData.AlarmCloseSubstring2 || ''}">
            </div>
            <div class="col-md-2 text-center">
                <button type="button" class="btn btn-primary btn-sm editTrapButton" style="margin-top: 23px;">Edit</button>
                <button type="button" class="btn btn-danger btn-sm trapRemoveButton" style="margin-top: 23px;">Delete</button>
            </div>
        `;

        row.querySelector('.trapRemoveButton').addEventListener('click', function () {
            row.remove();
        });

        row.querySelector('.editTrapButton').addEventListener('click', function () {
            self.openEditPopup(row);
        });

        rowContainer.appendChild(row);
        self.trapCounter++;
    },

    openEditPopup: function (row) {
        this.currentEditingRow = row;

        document.getElementById('editTrapName').value = row.querySelector(`[id^="trapName"]`).value;
        document.getElementById('editAlarmName').value = row.querySelector(`[id^="alarmName"]`).value;
        document.getElementById('editAlarmOpenString').value = row.querySelector(`[id^="alarmOpenString"]`).value;
        document.getElementById('editOpenSubstring1').value = row.querySelector(`[id^="alarmOpenSubstring1"]`).value;
        document.getElementById('editOpenSubstring2').value = row.querySelector(`[id^="alarmOpenSubstring2"]`).value;
        document.getElementById('editAlarmCloseString').value = row.querySelector(`[id^="alarmCloseString"]`).value;
        document.getElementById('editCloseSubstring1').value = row.querySelector(`[id^="alarmCloseSubstring1"]`).value;
        document.getElementById('editCloseSubstring2').value = row.querySelector(`[id^="alarmCloseSubstring2"]`).value;

        $('#editTrapModal').modal('show');
    },


    editTrap: function (save = false) {
        const self = this;

        if (save && self.currentEditingRow) {
            // Save updated values into the row
            self.currentEditingRow.querySelector(`input[id^="trapName"]`).value = document.getElementById('editTrapName').value;
            self.currentEditingRow.querySelector(`input[id^="alarmName"]`).value = document.getElementById('editAlarmName').value;
            self.currentEditingRow.querySelector(`input[id^="alarmOpenString"]`).value = document.getElementById('editAlarmOpenString').value;
            self.currentEditingRow.querySelector(`input[id^="alarmOpenSubstring1"]`).value = document.getElementById('editOpenSubstring1').value;
            self.currentEditingRow.querySelector(`input[id^="alarmOpenSubstring2"]`).value = document.getElementById('editOpenSubstring2').value;
            self.currentEditingRow.querySelector(`input[id^="alarmCloseString"]`).value = document.getElementById('editAlarmCloseString').value;
            self.currentEditingRow.querySelector(`input[id^="alarmCloseSubstring1"]`).value = document.getElementById('editCloseSubstring1').value;
            self.currentEditingRow.querySelector(`input[id^="alarmCloseSubstring2"]`).value = document.getElementById('editCloseSubstring2').value;

            // Close the modal after saving
            $('#editTrapModal').modal('hide');
        } else {
            // Open modal and load existing values from the row
            self.currentEditingRow = row;
            document.getElementById('editTrapName').value = row.querySelector(`input[id^="trapName"]`).value;
            document.getElementById('editAlarmName').value = row.querySelector(`input[id^="alarmName"]`).value;
            document.getElementById('editAlarmOpenString').value = row.querySelector(`input[id^="alarmOpenString"]`).value;
            document.getElementById('editOpenSubstring1').value = row.querySelector(`input[id^="alarmOpenSubstring1"]`).value;
            document.getElementById('editOpenSubstring2').value = row.querySelector(`input[id^="alarmOpenSubstring2"]`).value;
            document.getElementById('editAlarmCloseString').value = row.querySelector(`input[id^="alarmCloseString"]`).value;
            document.getElementById('editCloseSubstring1').value = row.querySelector(`input[id^="alarmCloseSubstring1"]`).value;
            document.getElementById('editCloseSubstring2').value = row.querySelector(`input[id^="alarmCloseSubstring2"]`).value;

            // Open the modal
            $('#editTrapModal').modal('show');
        }
    },

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
            const actionType = self.isUpdateMode ? "Update" : "Add";

            const deviceIP = document.getElementById('deviceIP').value.trim();
            const devicePort = parseInt(document.getElementById('devicePort').value, 10);
            const enableDevice = document.getElementById('enableToggle').checked ? 1 : 0;
            const Communitystring = document.getElementById('Communitystring').value;

            let mibFileName = document.getElementById('fileName').value.trim();
            if (!mibFileName) {
                L.ui.showAlert(
                    "error",
                    "File Not Selected",
                    "Please select a MIB file before proceeding."
                );

                return;
            }
            if (!mibFileName.includes("/usr/share/snmp/mibs/")) {
                mibFileName = `/usr/share/snmp/mibs/${mibFileName}`;
            }

            if (!deviceName || !deviceIP || !devicePort || !mibFileName || !Communitystring) {
                L.ui.showAlert(
                    "error",
                    "Validation Error",
                    "Please complete all required fields before proceeding."
                );

                return;
            }
            if (!validateIPAddress(deviceIP)) {
                L.ui.showAlert(
                    "error",
                    "Invalid IP Address",
                    "Please enter a valid IP address to continue."
                );

                return;
            }

            const communicationConfig = {
                actionType,
                deviceName,
                deviceIP,
                devicePort,
                Communitystring,
                EnableDevice: enableDevice,
                MIBFileName: mibFileName
            };

            const oidConfig = {
                deviceName,
                "OID_Configuration": []
            };

            let oidValid = true;
            document.querySelectorAll('#OIDTextBoxes .form-row').forEach(row => {
                const jsonKeyName = row.querySelector('input[name^="oidName"]').value.trim();
                const oidNumber = row.querySelector('input[name^="oidNumber"]').value.trim();
                const oidDataType = parseInt(row.querySelector('select[name^="dataType"]').value.trim(), 10);

                if (!jsonKeyName || !oidNumber || isNaN(oidDataType)) {
                    oidValid = false;
                } else {
                    oidConfig["OID_Configuration"].push({
                        JSONKeyName: jsonKeyName,
                        "OIDNumber/Name": oidNumber,
                        OIDDataType: oidDataType
                    });
                }
            });

            if (!oidValid) {
                L.ui.showAlert(
                    "warning",
                    "Incomplete OID Configuration",
                    "Please fill all required fields in the OID Configuration section before proceeding."
                );

                return;
            }

            const trapConfig = {
                deviceName,
                "Trap_Configuration": []
            };

            let trapValid = true;
            document.querySelectorAll('#trapTextBoxes .form-row').forEach(row => {
                const trapName = row.querySelector('input[name^="trapName"]').value.trim();
                const alarmName = row.querySelector('input[name^="alarmName"]').value.trim();
                const alarmOpenString = row.querySelector('input[name^="alarmOpenString"]').value.trim();
                const alarmOpenSubstring1 = row.querySelector('input[name^="alarmOpenSubstring1"]').value.trim();
                const alarmOpenSubstring2 = row.querySelector('input[name^="alarmOpenSubstring2"]').value.trim() || "";
                const alarmCloseString = row.querySelector('input[name^="alarmCloseString"]').value.trim();
                const alarmCloseSubstring1 = row.querySelector('input[name^="alarmCloseSubstring1"]').value.trim();
                const alarmCloseSubstring2 = row.querySelector('input[name^="alarmCloseSubstring2"]').value.trim() || "";

                if (!trapName || !alarmName || !alarmOpenString || !alarmCloseString || !alarmOpenSubstring1 || !alarmCloseSubstring1) {
                    trapValid = false;
                } else {
                    trapConfig["Trap_Configuration"].push({
                        TrapName: trapName,
                        AlarmName: alarmName,
                        AlarmOpenString: alarmOpenString,
                        AlarmOpenSubstring1: alarmOpenSubstring1,
                        AlarmOpenSubstring2: alarmOpenSubstring2,
                        AlarmCloseString: alarmCloseString,
                        AlarmCloseSubstring1: alarmCloseSubstring1,
                        AlarmCloseSubstring2: alarmCloseSubstring2
                    });
                }
            });

            if (!trapValid) {
                L.ui.showAlert(
                    "warning",
                    "Incomplete Trap Configuration",
                    "Please fill all required fields in the Trap Configuration section before proceeding."
                );
                return;
            }

            document.getElementById("loadingOverlay").style.display = "flex";

            try {
                await self.sendCommunicationConfigAPI(communicationConfig);

                await self.sendOIDConfigAPI(oidConfig);

                await self.sendTrapConfigAPI(trapConfig);
                L.ui.showAlert(
                    "success",
                    "Saved Successful",
                    "Device Configurations has been saved successfully."
                );
                self.addDeviceDataToTable(communicationConfig, self.isUpdateMode);
                self.toggleSendConfigTabVisibility();
                setTimeout(() => {
                    location.reload();
                }, 2000);

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
        return fetch(`https://cors-anywhere.herokuapp.com/https://webhook.site/885711c7-8dd3-4c2e-8a2b-facbf4d9a18a`, {
            //return fetch(`${BaseURL}:30002/Device/Emerson`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(communicationConfig)
        }).then(response => {
            if (!response.ok) throw new Error('Network response was not ok');
            return response.text();
        }).then(text => {
        });
    },

    sendOIDConfigAPI: function (oidConfig) {
        let params = window.location.href;
        let BaseURL = new URL(params).origin;
        // return fetch(`${BaseURL}:30002/OID/Emerson`, {
        return fetch(`https://cors-anywhere.herokuapp.com/https://webhook.site/885711c7-8dd3-4c2e-8a2b-facbf4d9a18a`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(oidConfig)
        }).then(response => {
            if (!response.ok) throw new Error('Network response was not ok');
            return response.text();
        }).then(text => {
        });
    },

    sendTrapConfigAPI: function (trapConfig) {
        let params = window.location.href;
        let BaseURL = new URL(params).origin;
        return fetch(`https://cors-anywhere.herokuapp.com/https://webhook.site/885711c7-8dd3-4c2e-8a2b-facbf4d9a18a`, {
            //return fetch(`${BaseURL}:30002/Trap/Emerson`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(trapConfig)
        }).then(response => {
            if (!response.ok) throw new Error('Network response was not ok');
            return response.text();
        }).then(text => {
        });
    },

    editDevice: async function (selectedDevice) {
        try {
            const self = this;
            self.isUpdateMode = true;
            self.originalDeviceName = selectedDevice.deviceName;
            // Reset OID and Trap Configuration before loading new data
            document.getElementById('OIDTextBoxes').innerHTML = '';
            document.getElementById('trapTextBoxes').innerHTML = '';
            self.oidCounter = 0;
            self.trapCounter = 0;
            // Populate communication configuration fields
            document.getElementById('deviceName').value = selectedDevice.deviceName;
            document.getElementById('deviceName').readOnly = true; //  Make it read-only during edit
            document.getElementById('devicePort').value = selectedDevice.devicePort;
            document.getElementById('deviceIP').value = selectedDevice.deviceIP;
            document.getElementById('fileName').value = selectedDevice.MIBFileName;
            document.getElementById('enableToggle').checked = selectedDevice.EnableDevice;
            document.getElementById('Communitystring').value = selectedDevice.Communitystring;

            // Change modal title and button text for update mode
            document.getElementById('addDeviceModalLabel').textContent = "Update Device";
            document.getElementById('saveDeviceButton').textContent = "Update Device";

            // Show the modal
            $('#SNMPMasterModal').modal('show');

            // Fetch OID and Trap Configurations
            await self.fetchOIDConfiguration(selectedDevice.deviceName);
            await self.fetchTrapConfiguration(selectedDevice.deviceName);

            //  Update Table Immediately with Correct OID and Trap Count
            const OIDCount = document.querySelectorAll('#OIDTextBoxes .form-row').length;
            const TrapCount = document.querySelectorAll('#trapTextBoxes .form-row').length;
            self.addDeviceDataToTable(selectedDevice, true);
        } catch (error) {
            console.error('Error editing device:', error);
        }
    },

    fetchOIDConfiguration: async function (deviceName) {
        let params = window.location.href;
        let BaseURL = new URL(params).origin;
        try {
            const response = await fetch(`${BaseURL}:30002/OID_Configuration/${deviceName}`);
            const data = await response.json();

            //  Check if the API returned a valid response
            if (!data || !data["deviceName"] || !Array.isArray(data["OID_Configuration"])) {
                console.error(" API did not return a valid OID configuration array");
                return;
            }

            //  Ensure we only populate data for the selected device
            if (data["deviceName"] !== deviceName) {
                console.warn(` No OID data found for ${deviceName}`);
                document.getElementById('OIDTextBoxes').innerHTML = ''; // Clear old rows
                return;
            }

            document.getElementById('OIDTextBoxes').innerHTML = ''; // Clear old rows

            data["OID_Configuration"].forEach((oid) => {
                this.addOIDRow(oid);
            });

        } catch (error) {
            console.error(' Error fetching OID configuration:', error);
        }
    },

    fetchTrapConfiguration: async function (deviceName) {
        let params = window.location.href;
        let BaseURL = new URL(params).origin;
        try {
            const response = await fetch(`${BaseURL}:30002/Trap_Configuration/${deviceName}`);
            const data = await response.json();
            //  Check if the API returned a valid response
            if (!data || !data["deviceName"] || !Array.isArray(data["Trap_Configuration"])) {
                console.error(" API did not return a valid Trap configuration array");
                return;
            }

            //  Ensure we only populate data for the selected device
            if (data["deviceName"] !== deviceName) {
                console.warn(` No Trap data found for ${deviceName}`);
                document.getElementById('trapTextBoxes').innerHTML = ''; // Clear old rows
                return;
            }

            document.getElementById('trapTextBoxes').innerHTML = ''; // Clear old rows

            data["Trap_Configuration"].forEach((trap) => {
                this.addTrapRow(trap);
            });

        } catch (error) {
            console.error(' Error fetching Trap configuration:', error);
        }
    },



    addDeviceDataToTable: function (communicationConfig, isUpdate = false) {
        const self = this;
        const table = document.getElementById('devicesTable');
        let tableHeader = table.querySelector('thead');
        let tableBody = table.querySelector('tbody');
        const tableContainer = document.querySelector('.table-container');
        //  Create table header if not present
        if (!tableHeader) {
            tableHeader = document.createElement('thead');
            table.appendChild(tableHeader);
        }
        if (!tableBody) {
            tableBody = document.createElement('tbody');
            table.appendChild(tableBody);
        }

        //  Ensure headers are present
        if (tableHeader.rows.length === 0) {
            const headerRow = document.createElement('tr');
            headerRow.innerHTML = `
                <th>SNID</th>
                <th>Device Name</th>
                <th>Status</th>
                <th>No. of OIDs</th>
                <th>No. of Traps</th>
                <th>Actions</th>
            `;
            tableHeader.appendChild(headerRow);
        }
        if (isUpdate) {
            //  Find and update the existing row instead of adding a new one
            tableBody.querySelectorAll('tr').forEach(row => {
                const existingDeviceName = row.cells[1]?.textContent.trim();
                if (existingDeviceName === communicationConfig.deviceName) {
                    row.cells[2].textContent = communicationConfig.EnableDevice ? 'Enabled' : 'Disabled';
                    row.cells[3].textContent = communicationConfig.NOofOIDs;  //  Update OID count
                    row.cells[4].textContent = communicationConfig.NOofTraps; //  Update Trap count
                }
            });
            return; // Stop execution to prevent adding a duplicate row
        }

        //  Create a new row for a new device
        const newRow = document.createElement('tr');
        const snid = tableBody.getElementsByTagName('tr').length + 1;
        const status = communicationConfig.EnableDevice ? 'Enabled' : 'Disabled';
        const NOofOID = communicationConfig.NOofOIDs;
        const NOofTrap = communicationConfig.NOofTraps;

        newRow.innerHTML = `
            <td>${snid}</td>
            <td>${communicationConfig.deviceName}</td>
            <td>${status}</td>
            <td>${NOofOID}</td>  <!--  Correctly counted -->
            <td>${NOofTrap}</td>  <!--  Correctly counted -->
            <td class="action-buttons">
                <button class="btn btn-primary">Edit</button>
                <button class="btn btn-danger deleteBtn">Delete</button>
            </td>
        `;

        tableContainer.style.display = 'block';

        tableBody.appendChild(newRow);

        // Handle edit button click
        newRow.querySelector('.btn-primary').addEventListener('click', function () {
            self.editDevice(communicationConfig);
        });

        newRow.querySelector('.deleteBtn').addEventListener('click', async function () {
            const deviceName = newRow.cells[1]?.textContent?.trim();

            if (!deviceName) {
                console.error("Error: Device name is missing or undefined.");
                return;
            }
            document.getElementById("loadingOverlay").style.display = "flex";
            //  Send DELETE request to backend
            try {
                await self.sendDeleteDeviceAPI(deviceName);
                L.ui.showAlert(
                    "success",
                    "Deleted Successfully",
                    `device "${deviceName}" has been deleted successfully.`
                );
                //  Remove the row from the table only if delete API was called successfully
                tableBody.removeChild(newRow);
                setTimeout(() => {
                    location.reload();
                }, 2000);

                //  Renumber SNID after deleting a row
                let index = 1;
                tableBody.querySelectorAll('tr').forEach(row => {
                    row.cells[0].textContent = index++;
                });

                //  If no devices are left, remove the table header
                if (tableBody.children.length === 0) {
                    tableHeader.innerHTML = '';  // Clear headers
                    //  document.querySelector('.table-container').style.display = 'none'; // Hide table
                    tableContainer.style.display = 'none';
                }
            } catch (error) {
                console.error('Failed to delete device:', error);
                L.ui.showAlert(
                    "error",
                    "Deletion Failed",
                    `Unable to delete the device "${deviceName}". Please try again.`
                );

            }
            finally {
                document.getElementById("loadingOverlay").style.display = "none";
                self.toggleSendConfigTabVisibility();
            }

        });
        self.toggleSendConfigTabVisibility();
    },

    updateButtonStates: function () {
        const addOIDButton = document.getElementById('addOID');
        const addTrapsButton = document.getElementById('addTraps');

        function toggleButtons() {
            const activeTab = document.querySelector('.tab-pane.active').id;

            // Enable "ADD OID" only in OID Config, and disable in others
            addOIDButton.disabled = activeTab !== 'oidconfig';

            // Enable "ADD Traps" only in Trap Config, and disable in others
            addTrapsButton.disabled = activeTab !== 'trapconfig';
        }

        // Listen for tab changesmock
        document.querySelectorAll('#pills-tab a').forEach(tab => {
            tab.addEventListener('click', function () {
                setTimeout(toggleButtons, 100); // Small delay for tab switch to complete
            });
        });

        // Run initially to set correct state when the modal opens
        toggleButtons();
    },

    sendDeleteDeviceAPI: function (deviceName) {
        let params = window.location.href;
        let BaseURL = new URL(params).origin;
        return fetch(`https://cors-anywhere.herokuapp.com/https://webhook.site/885711c7-8dd3-4c2e-8a2b-facbf4d9a18a`, {
            //return fetch(`${BaseURL}:30002/Device/Emerson`, {
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
            L.ui.showAlert("error", "No value selected", "Please select a Field Content and enter a JSON Key Name.");
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

            const isCustom = field.startsWith('SNMPCustomfield');
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
                "Please fill both required fields before proceeding."
            );

            return;
        }

        if (this.editingSendConfigRow) {
            this.editingSendConfigRow.cells[1].textContent = fieldContent;
            this.editingSendConfigRow.cells[2].textContent = jsonKey;
            // this.editingSendConfigRow.setAttribute('data-json-key-value', jsonKeyValue);

            // Save the JSON key value only for SNMPCustomfield1–5
            const isCustomField = ['SNMPCustomfield1', 'SNMPCustomfield2', 'SNMPCustomfield3', 'SNMPCustomfield4', 'SNMPCustomfield5'].includes(fieldContent);

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
                if (fieldContent.startsWith('SNMPCustomfield')) {
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

        fetch(`${BaseURL}:30002/Send/Update`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(sendConfigs)
        })
            .then(response => {
                if (!response.ok) throw new Error("Network error");
                return response.text();
            })
            .then(responseText => {
                L.ui.showAlert("success", "Updated", "Device updated successfully !");
            })
            .catch(error => {
                console.error("Send Config Update Failed:", error);
                L.ui.showAlert("error", "Update Failed", "Failed to update send configurations!");
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
    bindSNMPPeriodicity: function () {
        const input = document.getElementById("snmpInput");
        if (!input) return;

        let BaseURL = new URL(window.location.href).origin;

        input.addEventListener("change", () => {
            const val = parseInt(input.value, 10);

            if (isNaN(val) || val < 60) {
                L.ui.showAlert(
                    "warning",
                    "Invalid Periodicity",
                    "The overall periodicity must be 60 seconds or greater."
                );
                input.value = 60;
                return;
            }
            // fetch(`https://cors-anywhere.herokuapp.com/https://webhook.site/885711c7-8dd3-4c2e-8a2b-facbf4d9a18a`, {
            fetch(`${BaseURL}30002/Snmp/Update`, {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({
                    SNMPInputPeriodicity: val
                })
            }).catch(err => console.error("SNMP periodicity save failed:", err));
        });
    },
    fetchSNMPPeriodicity: function () {
        const input = document.getElementById("snmpInput");
        if (!input) return;

        let BaseURL = new URL(window.location.href).origin;

        // fetch(`https://mocki.io/v1/218bd110-2ff2-4a55-8e2b-b75913eb7dab`)
        fetch(`${BaseURL}:30002/snmp_data/List/`)
            .then(res => res.json())
            .then(data => {
                if (data && data.SNMPInputPeriodicity) {
                    input.value = data.SNMPInputPeriodicity;
                }
            })
            .catch(err => console.error("Failed to fetch SNMP periodicity:", err));
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


    execute: async function () {
        const self = this;
        let params = window.location.href;
        let BaseURL = new URL(params).origin;
        // 🔐 Check SNMP app state
        try {
            const res = await fetch(`https://mocki.io/v1/55c8f785-a119-49f6-a81b-0f86d3985cdf`);
            //const res = await fetch(`${BaseURL}:30002/Device_Configuration/Device`);
            const apps = await res.json();
            const snmpApp = apps.find(app => app.id === "snmp");

            if (!snmpApp || snmpApp.state !== "running") {
                self.disableSNMPPage();
                return; // stop everything
            }

            self.enableSNMPPage();
        } catch (err) {
            console.error("Execute API failed:", err);
            self.disableSNMPPage();
            return;
        }
        fetch(`${BaseURL}:30002/Device_Configuration/Device`)
            //  fetch(`https://mocki.io/v1/3774770e-c441-4fbd-a603-484941b32d1e`)
            .then(response => response.json())
            .then(data => {
                // Ensure the response is wrapped inside an array
                const deviceArray = Array.isArray(data) ? data : [data];

                deviceArray.forEach(device => {
                    self.addDeviceDataToTable(device);
                    // self.updateOIDAndTrapCount(device.deviceName); // Fetch & update counts
                });
            })
            .catch(error => console.error('Error fetching device data:', error));

        //Populate Field Content Dropdown
        fetch(`${BaseURL}:30002/Available_Send_Configuration/List`)
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

                    // also add to edit modal
                    const editOption = option.cloneNode(true);
                    editDropdown.appendChild(editOption);
                });
            })
            .catch(err => console.error("Error loading dropdown values:", err));


        //Populate Existing Table Rows
        // fetch('https://mocki.io/v1/67af9f5f-11e0-4e35-99bd-a16e9f791d1c')
        fetch(`${BaseURL}:30002/Selected_Send_Configuration/List`)
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

                        // Set up event listeners
                        row.querySelector('.btn-primary').addEventListener('click', () => {
                            self.editingSendConfigRow = row;

                            const field = row.cells[1].textContent.trim();
                            const jsonKey = row.cells[2].textContent.trim();
                            const value = row.getAttribute('data-json-key-value') || '';

                            document.getElementById('editFieldContent').value = field;
                            document.getElementById('editFieldJsonKey').value = jsonKey;

                            const isCustom = field.startsWith('SNMPCustomfield');
                            document.getElementById('jsonKeyValueGroup').style.display = isCustom ? 'block' : 'none';
                            document.getElementById('editJsonKeyValue').value = isCustom ? value : '';

                            $('#editSendConfigModal').modal('show');
                        });
                        row.querySelector('.btn-danger').addEventListener('click', () => {
                            row.remove();
                            this.reindexSendConfigRows();
                            if (tableBody.children.length === 0) {
                                tableContainer.style.display = 'none';
                            }
                        });

                        tableBody.appendChild(row);
                    });
                }
            })
            .catch(err => console.error("Error loading table values:", err));

        //  Attach event listeners once globally, like BACnet
        document.getElementById('addOID').addEventListener('click', function () {
            self.addOIDRow({});
        });

        document.getElementById('addTraps').addEventListener('click', function () {
            self.addTrapRow({});
        });

        document.getElementById('saveTrapChanges').addEventListener('click', function () {
            self.editTrap(true);  //Now correctly calls editTrap with save = true
        });


        document.getElementById('addSendConfigRow').addEventListener('click', function () {
            self.addSendConfigRow();
        });

        document.getElementById('saveSendConfigChanges').addEventListener('click', function () {
            self.saveSendConfigChanges();
        });
        document.getElementById('editFieldContent').addEventListener('change', function () {
            const selected = this.value;
            const isCustom = selected.startsWith('SNMPCustomfield');
            document.getElementById('jsonKeyValueGroup').style.display = isCustom ? 'block' : 'none';
            if (!isCustom) {
                document.getElementById('editJsonKeyValue').value = '';
            }
        });
        document.getElementById('updateAllSendConfigsBtn')
            .addEventListener('click', () => self.updateAllSendConfigs());


        // Reset form and counters when "Add Device" is clicked
        document.getElementById('smpmasterdevice').addEventListener('click', function () {
            document.getElementById('snmp-device-config').reset();
            self.oidCounter = 0;
            self.trapCounter = 0;
            document.querySelector('#OIDTextBoxes').innerHTML = "";
            document.querySelector('#trapTextBoxes').innerHTML = "";
            document.getElementById('deviceName').readOnly = false; //  Allow editing when adding a new device


            self.oidCounter = 0;
            self.trapCounter = 0;
            self.isUpdateMode = false;  // Reset update mode
            self.originalDeviceName = ""; // Reset stored name

            //  Reset modal title and button text
            document.getElementById('addDeviceModalLabel').textContent = "Add New Device";
            document.getElementById('saveDeviceButton').textContent = "Save Device";


            $('#SNMPMasterModal').modal('show');
        });


        $('#fileUpload').click(function () {
            self.handleArchiveUpload();
        });
        this.bindSNMPPeriodicity();
        this.fetchSNMPPeriodicity();
        this.catchingJSONData();
        this.updateButtonStates();
        this.toggleSendConfigTabVisibility();
    }
});
