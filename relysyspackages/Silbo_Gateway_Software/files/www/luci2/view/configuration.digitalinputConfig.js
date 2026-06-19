L.ui.view.extend({
    generateDigitalIOSections: function (totalIOs) {
        const self = this;
        const tabsNav = document.getElementById("tabs-nav");
        const tabsContainer = document.getElementById("tabs");

        tabsNav.innerHTML = "";
        tabsContainer.innerHTML = "";

        for (let i = 1; i <= totalIOs; i++) {
            let tabItem = document.createElement("li");
            tabItem.innerHTML = `<span class="tab-label">Digital IO ${i}</span>`;
            tabItem.id = `tab-link-${i}`;
            tabItem.onclick = () => self.showTab(i);
            tabsNav.appendChild(tabItem);

            let section = document.createElement("div");
            section.id = `tab${i}`;
            section.className = "digital-io-section";
            section.innerHTML = `
                    <label class="digital-io-label">
                        <input type="checkbox" id="enableDigitalIO${i}" class="digital-io-checkbox">
                        Enable Digital IO ${i}
                    </label>
                    <div id="digitalIO${i}Section" class="config-section" style="display: none;">
                        <label class="digital-io-label">Digital IO ${i} Mode:
                            <select id="digitalIOMode${i}" class="digital-io-select">
                                <option value="0">Input</option>
                                <option value="1">Output</option>
                            </select>
                        </label>
                        <label class="digital-io-label">Digital IO ${i} Alarm Active State:
                            <select id="digitalIOAlarmState${i}" class="digital-io-select">
                                <option>0</option>
                                <option>1</option>
                            </select>
                        </label>
                        <label class="digital-io-label">Digital IO ${i} Alarm Active Filter Time (ms):
                            <input type="number" id="digitalIOAlarmActiveFilter${i}" class="digital-io-input">
                        </label>
                        <label class="digital-io-label">Digital IO ${i} Alarm DeActive Filter Time (ms):
                            <input type="number" id="digitalIOAlarmDeactiveFilter${i}" class="digital-io-input">
                        </label>
                        <label class="digital-io-label">
                            <input type="checkbox" id="digitalIO${i}TimeDependency" class="digital-io-checkbox">
                            Digital IO ${i} Time Dependency
                        </label>
                        <label id="digitalIO${i}AlarmStartTime" class="digital-io-label" style="display: none;">
                            Digital IO ${i} Alarm Start Time:
                            <input type="time" id="digitalIOStartTime${i}" class="digital-io-input" step="1">
                        </label>
                        <label id="digitalIO${i}AlarmStopTime" class="digital-io-label" style="display: none;">
                            Digital IO ${i} Alarm Stop Time:
                            <input type="time" id="digitalIOStopTime${i}" class="digital-io-input" step="1">
                        </label>
                        <label class="digital-io-label">Digital IO ${i} Mask Value:
                            <select id="digitalIOMaskValue${i}" class="digital-io-select">
                                <option>0</option>
                                <option>1</option>
                            </select>
                        </label>
                        <label class="digital-io-label">Digital IO ${i} Alarm Set Notify Value:
                            <select id="digitalIOSetNotify${i}" class="digital-io-select">
                                <option>0</option>
                                <option>1</option>
                            </select>
                        </label>
                        <label class="digital-io-label">Digital IO ${i} Alarm Reset Notify Value:
                            <select id="digitalIOResetNotify${i}" class="digital-io-select">
                                <option>0</option>
                                <option>1</option>
                            </select>
                        </label>
                    </div>
                `;
            tabsContainer.appendChild(section);
            //  Add event listener for enabling/disabling section
            document.getElementById(`enableDigitalIO${i}`).addEventListener("click", function () {
                self.toggleDigitalIO(i);
            });
            //  Add event listener for time dependency
            document.getElementById(`digitalIO${i}TimeDependency`).addEventListener("click", function () {
                self.toggleTimeDependency(i);
            });
        }
    },


    toggleDigitalIO: function (ioNumber) {
        const section = document.getElementById(`digitalIO${ioNumber}Section`);
        const checkbox = document.getElementById(`enableDigitalIO${ioNumber}`);
        if (section && checkbox) {
            section.style.display = checkbox.checked ? "block" : "none";
        }
    },

    toggleTimeDependency: function (ioNumber) {
        const checkbox = document.getElementById(`digitalIO${ioNumber}TimeDependency`);
        const startTimeLabel = document.getElementById(`digitalIO${ioNumber}AlarmStartTime`);
        const stopTimeLabel = document.getElementById(`digitalIO${ioNumber}AlarmStopTime`);
        if (checkbox && startTimeLabel && stopTimeLabel) {
            startTimeLabel.style.display = checkbox.checked ? "block" : "none";
            stopTimeLabel.style.display = checkbox.checked ? "block" : "none";
        }
    },

    showTab: function (tabNumber) {
        const target = document.getElementById(`tab${tabNumber}`);
        if (!target) {
            console.warn(`Tab ${tabNumber} not found`);
            return;
        }

        // Hide all sections
        document.querySelectorAll('.digital-io-section')
            .forEach(tab => tab.style.display = 'none');

        // Show selected
        target.style.display = 'block';

        // Update active tab
        document.querySelectorAll('#tabs-nav li')
            .forEach(tab => tab.classList.remove('active-tab'));

        const activeTab = document.getElementById(`tab-link-${tabNumber}`);
        if (activeTab) activeTab.classList.add('active-tab');
    },



    collectData: function () {
        let params = window.location.href;
        let BaseURL = new URL(params).origin;
        const overlay = document.getElementById("dioLoadingOverlay");
        // show overlay
        if (overlay) {
            overlay.style.display = "flex";
            overlay.style.zIndex = "12000";
        }

        let data = { DIO_Pins: {}, DIOModes: {} };

        const totalPins = document.querySelectorAll('#tabs-nav li').length;
        data.DIO_Pins.NoOfDIOPins = String(totalPins);
        for (let i = 1; i <= totalPins; i++) {
            // guard DOM reads with null checks in case elements don't exist
            const alarmStateEl = document.getElementById(`digitalIOAlarmState${i}`);
            const setNotifyEl = document.getElementById(`digitalIOSetNotify${i}`);
            const resetNotifyEl = document.getElementById(`digitalIOResetNotify${i}`);
            const activeFilterEl = document.getElementById(`digitalIOAlarmActiveFilter${i}`);
            const deactiveFilterEl = document.getElementById(`digitalIOAlarmDeactiveFilter${i}`);
            const timeDepEl = document.getElementById(`digitalIO${i}TimeDependency`);
            const startTimeEl = document.getElementById(`digitalIOStartTime${i}`);
            const stopTimeEl = document.getElementById(`digitalIOStopTime${i}`);
            const maskEl = document.getElementById(`digitalIOMaskValue${i}`);
            const enableEl = document.getElementById(`enableDigitalIO${i}`);
            const modeEl = document.getElementById(`digitalIOMode${i}`);

            data.DIO_Pins[`DInput${i}`] = {
                AlarmActiveState: alarmStateEl ? alarmStateEl.value : "0",
                AlarmSetNotifyVal: setNotifyEl ? setNotifyEl.value : "0",
                AlarmResetNotifyVal: resetNotifyEl ? resetNotifyEl.value : "0",
                AlarmActiveFilterTimeInMilliSeconds: activeFilterEl ? activeFilterEl.value : "",
                AlarmDeActiveFilterTimeInMilliSeconds: deactiveFilterEl ? deactiveFilterEl.value : "",
                TimeDependency: timeDepEl && timeDepEl.checked ? "1" : "0",
                AlarmStartTime: startTimeEl ? (startTimeEl.value || "00:00:00") : "00:00:00",
                AlarmStopTime: stopTimeEl ? (stopTimeEl.value || "00:00:00") : "00:00:00",
                MaskValue: maskEl ? maskEl.value : "0",
                Enable: enableEl && enableEl.checked ? "1" : "0"
            };

            data.DIOModes[`DIOMode${i}`] = modeEl ? modeEl.value : "0";
        }


        fetch(`${BaseURL}:30003/DI_Post/`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(data)
        })
            .then(response => {
                if (!response.ok) throw new Error(`HTTP error! Status: ${response.status}`);
                const contentType = response.headers.get("content-type");
                if (contentType && contentType.includes("application/json")) {
                    return response.json();
                }
                return response.text();
            })
            .then(result => {
                L.ui.showAlert("success", "Saved", "Configuration saved successfully!");
                setTimeout(() => {
                    location.reload();
                }, 1000);

            })
            .catch(error => {
                console.error("Error sending data:", error);
                L.ui.showAlert("error", "Failed", "Failed to save configuration!");
            })
            .finally(() => {
                if (overlay) overlay.style.display = "none";
            });
    },

    fetchAndPopulateData: async function () {
        var self = this;
        let params = window.location.href;
        let BaseURL = new URL(params).origin;

        try {
            const response = await fetch(`${BaseURL}:30003/DI_Configuration/`)
            // const response = await fetch(`https://mocki.io/v1/0d2b2892-2bfc-4165-ada9-56dedfc43dd2`)
            const data = await response.json();
            if (!data || !data.DIO_Pins) return;

            //  NEW: Read NoOfDIOPins
            const totalPins = parseInt(data.DIO_Pins.NoOfDIOPins || "4", 10);

            //  Build tabs dynamically
            self.generateDigitalIOSections(totalPins);

            for (let i = 1; i <= totalPins; i++) {
                const dioKey = `DInput${i}`;
                const dio = data.DIO_Pins[dioKey];
                if (!dio) {
                    console.warn(`No entry for ${dioKey}`);
                    continue;
                }

                // safe getters
                const getEl = id => document.getElementById(id);
                const enableEl = getEl(`enableDigitalIO${i}`);
                const modeEl = getEl(`digitalIOMode${i}`);
                const alarmStateEl = getEl(`digitalIOAlarmState${i}`);
                const setNotifyEl = getEl(`digitalIOSetNotify${i}`);
                const resetNotifyEl = getEl(`digitalIOResetNotify${i}`);
                const activeFilterEl = getEl(`digitalIOAlarmActiveFilter${i}`);
                const deactiveFilterEl = getEl(`digitalIOAlarmDeactiveFilter${i}`);
                const timeDepEl = getEl(`digitalIO${i}TimeDependency`);
                const startTimeEl = getEl(`digitalIOStartTime${i}`);
                const stopTimeEl = getEl(`digitalIOStopTime${i}`);
                const maskEl = getEl(`digitalIOMaskValue${i}`);

                // set values (guarded)
                if (enableEl) enableEl.checked = String(dio.Enable) === "1";
                if (modeEl) modeEl.value = (data.DIOModes && data.DIOModes[`DIOMode${i}`]) ?? modeEl.value ?? "0";
                if (alarmStateEl) alarmStateEl.value = dio.AlarmActiveState ?? alarmStateEl.value;
                if (setNotifyEl) setNotifyEl.value = dio.AlarmSetNotifyVal ?? setNotifyEl.value;
                if (resetNotifyEl) resetNotifyEl.value = dio.AlarmResetNotifyVal ?? resetNotifyEl.value;
                if (activeFilterEl) activeFilterEl.value = dio.AlarmActiveFilterTimeInMilliSeconds ?? activeFilterEl.value;
                if (deactiveFilterEl) deactiveFilterEl.value = dio.AlarmDeActiveFilterTimeInMilliSeconds ?? deactiveFilterEl.value;
                if (timeDepEl) timeDepEl.checked = String(dio.TimeDependency) === "1";
                if (startTimeEl) startTimeEl.value = dio.AlarmStartTime || "00:00:00";
                if (stopTimeEl) stopTimeEl.value = dio.AlarmStopTime || "00:00:00";
                if (maskEl) maskEl.value = dio.MaskValue ?? maskEl.value;

                // ensure UI reacts to the new states
                // call your toggle functions so sections/time inputs show/hide accordingly
                try { self.toggleDigitalIO(i); } catch (e) { /* ignore */ }
                try { self.toggleTimeDependency(i); } catch (e) { /* ignore */ }
            }

        }

        catch (error) {
            console.error("Error fetching data:", error);
        }
        //  Ensure first tab is shown after everything is ready
        setTimeout(() => {
            self.showTab(1);
        }, 0);

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

            const isCustom = field.startsWith('DIOCustomfield');
            document.getElementById('jsonKeyValueGroup').style.display = isCustom ? 'block' : 'none';
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
            L.ui.showAlert("error", "Empty field", "Please fill both fields.");
            return;
        }

        if (this.editingSendConfigRow) {
            this.editingSendConfigRow.cells[1].textContent = fieldContent;
            this.editingSendConfigRow.cells[2].textContent = jsonKey;
            const isCustomField = ['DIOCustomfield1', 'DIOCustomfield2', 'DIOCustomfield3', 'DIOCustomfield4', 'DIOCustomfield5'].includes(fieldContent);

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
            L.ui.showAlert("error", "Error", "No rows to update.");
            return;
        }

        const sendConfigs = [];

        tableRows.forEach(row => {
            const fieldContent = row.cells[1].textContent.trim();
            const jsonKey = row.cells[2].textContent.trim();
            const value = row.getAttribute('data-json-key-value') || '';

            if (fieldContent && jsonKey) {
                const config = { fieldContent, jsonKey };
                if (fieldContent.startsWith('DIOCustomfield')) {
                    config.keyValue = value;
                }
                sendConfigs.push(config);
            }
        });

        const snmpIndex = sendConfigs.findIndex(
            item => item.fieldContent.toLowerCase() === "snmpdata"
        );
        if (snmpIndex > -1) {
            const [snmpItem] = sendConfigs.splice(snmpIndex, 1);
            sendConfigs.push(snmpItem);
        }

        // ? Show loading overlay for Send Configuration
        document.getElementById("sendConfigLoadingOverlay").style.display = "flex";

        fetch(`${BaseURL}:30005/POST_Selected_DIO_Configuration/`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(sendConfigs)
        })
            .then(response => {
                if (!response.ok) throw new Error("Network error");
                return response.text();
            })
            .then(() => {
                L.ui.showAlert("success", "Update Complete", "Device updated successfully !");
                setTimeout(() => {
                    location.reload();
                }, 1000);

            })
            .catch(error => {
                console.error("Send Config Update Failed:", error);
                L.ui.showAlert("error", "Update Failed", "Failed to update send configurations!");
            })
            .finally(() => {
                document.getElementById("sendConfigLoadingOverlay").style.display = "none";
            });
    },

    bindDIOPeriodicity: function () {
        const dioInput = document.getElementById('dioInput');
        if (!dioInput) return;

        dioInput.addEventListener('change', () => {
            const value = parseInt(dioInput.value, 10);

            if (isNaN(value) || value < 60) {
                L.ui.showAlert(
                    "warning",
                    "Invalid Value",
                    "Overall periodicity must be >= 60 seconds."
                );
                dioInput.value = 60;
                return;
            }

            let BaseURL = new URL(window.location.href).origin;

            // Optional loading overlay (if exists)
            const overlay = document.getElementById("dioLoadingOverlay");
            if (overlay) overlay.style.display = "flex";

            fetch(`${BaseURL}:30008/DIO_Source_post/`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    DIOInputPeriodicity: value
                })
            })
                .then(response => {
                    if (!response.ok) {
                        throw new Error("Failed to apply configuration");
                    }
                    return response.text();
                })
                .then(() => {
                    // SUCCESS ALERT
                    L.ui.showAlert(
                        "success",
                        "Applied",
                        "Configuration applied successfully"
                    );
                    setTimeout(() => {
                        location.reload();
                    }, 1000);

                })
                .catch(err => {
                    console.error(" DIO periodicity update failed:", err);
                    L.ui.showAlert(
                        "error",
                        "Failed",
                        "Failed to apply configuration"
                    );
                })
                .finally(() => {
                    if (overlay) overlay.style.display = "none";
                });
        });
    },


    loadDIOUIAndData: function () {
        var self = this;
        let params = window.location.href;
        let BaseURL = new URL(params).origin;

        // -------------------- DROPDOWN DATA --------------------
        fetch(`${BaseURL}:30005/DIO_Available_Configuration/`)
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
            .catch(err => console.error("DIO dropdown load failed:", err));

        // -------------------- TABLE DATA --------------------
        fetch(`${BaseURL}:30005/DIO_Selected_Configuration/`)
            .then(res => res.json())
            .then(data => {
                const tableBody = document.querySelector('#sendConfigTable tbody');
                const tableContainer = document.getElementById('sendConfigTableContainer');

                tableBody.innerHTML = "";

                if (Array.isArray(data) && data.length) {
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
                        row.setAttribute('data-json-key-value', item.keyValue || '');

                        row.querySelector('.btn-primary').addEventListener('click', () => {
                            self.editingSendConfigRow = row;
                            document.getElementById('editFieldContent').value = item.fieldContent;
                            document.getElementById('editFieldJsonKey').value = item.jsonKey;
                            document.getElementById('editJsonKeyValue').value = item.keyValue || '';

                            const isCustom = item.fieldContent.startsWith('DIOCustomfield');
                            document.getElementById('jsonKeyValueGroup').style.display = isCustom ? 'block' : 'none';

                            $('#editSendConfigModal').modal('show');
                        });

                        row.querySelector('.btn-danger').addEventListener('click', () => {
                            row.remove();
                            self.reindexSendConfigRows();
                        });

                        tableBody.appendChild(row);
                    });
                }
            })
            .catch(err => console.error("DIO table load failed:", err));

        document.getElementById('editFieldContent').addEventListener('change', function () {
            const selected = this.value;
            const isCustom = selected.startsWith('DIOCustomfield');
            document.getElementById('jsonKeyValueGroup').style.display = isCustom ? 'block' : 'none';
            if (!isCustom) {
                document.getElementById('editJsonKeyValue').value = '';
            }
        });

        // -------------------- DIGITAL IO UI --------------------
        // if (!document.getElementById("tabs-nav").hasChildNodes()) {
        //     this.generateDigitalIOSections(4);
        // }
        self.fetchAndPopulateData();
        //self.showTab(1);
        // -------------------- BUTTON WIRING --------------------
        document.getElementById("saveButton").onclick = () => this.collectData();
        document.getElementById("addSendConfigRow").onclick = () => this.addSendConfigRow();
        document.getElementById("saveSendConfigChanges").onclick = () => this.saveSendConfigChanges();

        const updateBtn = document.getElementById("updateAllSendConfigsBtn");
        if (updateBtn) {
            updateBtn.onclick = (e) => {
                e.preventDefault();
                this.updateAllSendConfigs();
            };
        }
    },

    disableDIOPage: function () {
        const wrapper = document.getElementById("dioContentWrapper");
        const overlay = document.getElementById("dioDisabledOverlay");

        if (wrapper) wrapper.classList.add("dio-blurred");
        if (overlay) overlay.style.display = "flex";
    },

    enableDIOPage: function () {
        const wrapper = document.getElementById("dioContentWrapper");
        const overlay = document.getElementById("dioDisabledOverlay");

        if (wrapper) wrapper.classList.remove("dio-blurred");
        if (overlay) overlay.style.display = "none";
    },

    loadDIOPeriodicity: function () {
        const dioInput = document.getElementById('dioInput');
        if (!dioInput) return;

        let BaseURL = new URL(window.location.href).origin;

        fetch(`${BaseURL}:30008/DIO_Enable/`)
            .then(res => res.json())
            .then(data => {
                if (data.DIOInputPeriodicity !== undefined) {
                    dioInput.value = data.DIOInputPeriodicity;
                }
            })
            .catch(err => console.error("Failed to load DIO periodicity", err));
    },

    execute: function () {
    const self = this;
    let params = window.location.href;
    let BaseURL = new URL(params).origin;

    function checkState(retryCount) {
        retryCount = retryCount || 0;
        const MAX_RETRIES = 3;
        const RETRY_DELAY_MS = 2000;

        fetch(`${BaseURL}:30008/device/applications/`)
            .then(res => {
                if (!res.ok) throw new Error('Non-OK response: ' + res.status);
                return res.json();
            })
            .then(apps => {
                const dioApp = apps.find(app => app.id === "dio");

                if (dioApp && dioApp.state === "running") {
                    self.enableDIOPage();
                    self.loadDIOUIAndData();
                    self.loadDIOPeriodicity();
                    self.bindDIOPeriodicity();
                } else {
                    // API responded clearly: app is NOT running
                    self.disableDIOPage();
                }
            })
            .catch(err => {
                console.error('Execute API failed (attempt ' + (retryCount + 1) + '):', err);

                if (retryCount < MAX_RETRIES) {
                    setTimeout(function () {
                        checkState(retryCount + 1);
                    }, RETRY_DELAY_MS);
                } else {
                    console.warn('Max retries reached. Disabling DIO page.');
                    self.disableDIOPage();
                }
            });
    }

    checkState(0);
}
});
