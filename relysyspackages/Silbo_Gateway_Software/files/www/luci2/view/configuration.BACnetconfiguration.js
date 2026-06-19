L.ui.view.extend({
    // Internal properties
    processedGroups: new Map(),
    groupDataPointLimits: new Map(),

    freeIndices: [],
    AddGroupCount: 0,
    isUpdateMode: false,       // New flag to differentiate update from add mode
    originalDeviceName: '',    // Store the original device name when updating

    // --- Dynamic Group Fields ---
    dynamicGroupFields: function () {
        const self = this;
        document.getElementById('addGroupButton').addEventListener('click', function () {
            const groupContainer = document.getElementById('GroupTextBoxes');
            const existingGroups = groupContainer.children.length;

            if (existingGroups >= 10) {
                L.ui.showAlert("warning", "Limit reached", "You can add a maximum of 10 groups.");
                return;
            }

            let groupIndex;
            if (self.freeIndices.length > 0) {
                groupIndex = self.freeIndices.shift();
            } else {
                groupIndex = existingGroups;
            }

            const groupRow = document.createElement('div');
            groupRow.className = 'row modusblock';
            groupRow.innerHTML = `
                <div class="form-group col-md-2">
                    <label for="groupName-${groupIndex}">Group Name</label>
                    <input type="text" id="groupName-${groupIndex}" class="form-control group-name"
                    oninput="validateTheNames(this)" placeholder="Enter group name"
                    data-index="${groupIndex}" data-original-name="">
                </div>
                <div class="form-group col-md-2">
                    <label>Number of Data points</label>
                    <input type="number" id="numDataPoints-${groupIndex}" class="form-control num-data-points" placeholder="Enter number"  max="100">
                </div>
                <div class="form-group col-md-2">
                    <label>Interval to Query Parameters</label>
                    <input type="text" id="intervalQuery-${groupIndex}" class="form-control interval-query" placeholder="Enter interval">
                </div>
                 <div class="form-group col-md-2">
                    <label>Object Property</label>
                    <input type="number" id="objectProperty-${groupIndex}" class="form-control object-property" placeholder="Enter object property">
                </div>
                <div class="col-md-2">
                    <button class="btn btn-danger remove-group-btn" style="margin-top: 22px;">Delete</button>
                </div>
            `;
            groupContainer.appendChild(groupRow);
            // ✅ Enable Excel upload on first group
            const excelBtn = document.getElementById('excelUploadBtn');
            const excelInput = document.getElementById('excelUpload');

            if (excelBtn && excelInput) {
                excelBtn.disabled = false;
                excelInput.disabled = false;
            }

            const numDataPointsInput = groupRow.querySelector('.num-data-points');
            let lastValidCount = null;

            numDataPointsInput.addEventListener('focus', function () {
                lastValidCount = parseInt(numDataPointsInput.value, 10) || 0;
            });

            // numDataPointsInput.addEventListener('input', function () {
            //     let val = parseInt(numDataPointsInput.value, 10);
            //     if (val > 100) {
            //         val = 100;
            //         numDataPointsInput.value = val;
            //     }

            //     const groupNameInput = groupRow.querySelector('.group-name');
            //     const groupName = groupNameInput.value.trim();

            //     if (groupName && !isNaN(val)) {
            //         self.groupDataPointLimits.set(groupName, val);

            //         const tabId = self.processedGroups.get(groupName);
            //         const tabContent = document.getElementById(tabId);
            //         const rowContainer = tabContent?.querySelector('.data-row-container');

            //         if (tabContent && rowContainer) {
            //             const currentRows = rowContainer.children.length;

            //             // If reducing rows
            //             if (val < currentRows) {
            //                 // Check if rows to be deleted have any data
            //                 let hasData = false;
            //                 for (let i = val; i < currentRows; i++) {
            //                     const row = rowContainer.children[i];
            //                     const name = row.querySelector('.dataPointName')?.value.trim();
            //                     const type = row.querySelector('.dataType')?.value;
            //                     const instance = row.querySelector('.instance')?.value.trim();
            //                     const description = row.querySelector('.description')?.value.trim();
            //                     if (name || type || instance || description) {
            //                         hasData = true;
            //                         break;
            //                     }
            //                 }

            //                 if (hasData) {
            //                     const confirmDelete = confirm(`Reducing to ${val} will delete rows with filled data. Continue?`);
            //                     if (!confirmDelete) {
            //                         numDataPointsInput.value = lastValidCount;
            //                         return;
            //                     }
            //                 }

            //                 // Now actually remove the extra rows
            //                 for (let i = currentRows - 1; i >= val; i--) {
            //                     rowContainer.removeChild(rowContainer.children[i]);
            //                 }
            //             }

            //             // If increasing
            //             if (val > currentRows && val <= 100) {
            //                 for (let i = currentRows; i < val; i++) {
            //                     self.addDataPointRow(tabId);
            //                 }
            //             }

            //             self.updateRowCount(tabId);
            //         }
            //     }
            // });

            numDataPointsInput.addEventListener('input', function (ev) {
                let val = parseInt(numDataPointsInput.value, 10);
                if (val > 100) {
                    val = 100;
                    numDataPointsInput.value = val;
                }

                const groupNameInput = groupRow.querySelector('.group-name');
                const groupName = groupNameInput.value.trim();

                if (groupName && !isNaN(val)) {
                    self.groupDataPointLimits.set(groupName, val);

                    const tabId = self.processedGroups.get(groupName);
                    const tabContent = document.getElementById(tabId);
                    const rowContainer = tabContent?.querySelector('.data-row-container');

                    if (tabContent && rowContainer) {
                        const currentRows = rowContainer.children.length;

                        // Reducing rows
                        if (val < currentRows) {
                            let hasData = false;

                            for (let i = val; i < currentRows; i++) {
                                const row = rowContainer.children[i];
                                const name = row.querySelector('.dataPointName')?.value.trim();
                                const type = row.querySelector('.dataType')?.value;
                                const instance = row.querySelector('.instance')?.value.trim();
                                const description = row.querySelector('.description')?.value.trim();
                                if (name || type || instance || description) {
                                    hasData = true;
                                    break;
                                }
                            }

                            if (hasData) {
                                L.ui.confirmDelete(ev, function (res) {
                                    if (!res) {
                                        numDataPointsInput.value = lastValidCount;
                                        return;
                                    }

                                    for (let i = currentRows - 1; i >= val; i--) {
                                        rowContainer.removeChild(rowContainer.children[i]);
                                    }

                                    self.updateRowCount(tabId);
                                });
                                return;
                            }

                            // No data → safe to remove
                            for (let i = currentRows - 1; i >= val; i--) {
                                rowContainer.removeChild(rowContainer.children[i]);
                            }
                        }

                        // Increasing rows
                        if (val > currentRows && val <= 100) {
                            for (let i = currentRows; i < val; i++) {
                                self.addDataPointRow(tabId);
                            }
                        }

                        self.updateRowCount(tabId);
                    }
                }
            });


            groupRow.querySelector('.group-name').dataset.originalName = '';

            self.AddGroupCount++;
            const groupNameInput = groupRow.querySelector('.group-name');
            groupNameInput.addEventListener('change', function () {
                const newGroupName = groupNameInput.value.trim();
                const oldGroupName = groupNameInput.dataset.originalName || "";

                if (oldGroupName && oldGroupName !== newGroupName) {
                    if (self.processedGroups.has(oldGroupName)) {
                        const tabId = self.processedGroups.get(oldGroupName);
                        self.processedGroups.delete(oldGroupName);
                        self.processedGroups.set(newGroupName, tabId);

                        const existingTab = document.getElementById(`${tabId}-tab`);
                        if (existingTab) {
                            existingTab.textContent = newGroupName; // Update the tab name
                        }
                    }
                }
                groupNameInput.dataset.originalName = newGroupName; // Store new name
            });

            groupRow.querySelector('.remove-group-btn').addEventListener('click', function () {
                const groupName = groupRow.querySelector('.group-name').value.trim();
                const groupIndex = groupRow.querySelector('.group-name').dataset.index;
                const tabId = self.processedGroups.get(groupName); // Get tabId based on groupName


                if (tabId) {
                    const tabContent = document.getElementById(tabId);
                    if (tabContent) {
                        const dataRows = tabContent.querySelectorAll('.data-row-container .form-row');
                        const dataPoints = [];

                        dataRows.forEach((dataRow) => {
                            const name = dataRow.querySelector('.dataPointName').value.trim();
                            const type = dataRow.querySelector('.dataType').value;
                            const instance = dataRow.querySelector('.instance').value.trim();
                            const description = dataRow.querySelector('.description').value.trim();

                            if (name && type && instance && description) {
                                dataPoints.push({ name, type, instance, description });
                            }
                        });

                        self.storedDataPoints.set(groupName, dataPoints);
                    }

                    // Remove tab and tab content
                    document.getElementById(`${tabId}-tab`)?.remove();
                    document.getElementById(tabId)?.remove();
                }

                //Cleanup
                self.processedGroups.delete(groupName);
                self.existingGroupNames?.delete(groupName);
                self.storedDataPoints?.delete(groupName);
                self.groupDataPointLimits?.delete(groupName); // Also clear the limit
                groupContainer.removeChild(groupRow);
                self.freeIndices.push(parseInt(groupIndex, 10));
                // ❌ Disable Excel upload if no groups remain
                if (self.processedGroups.size === 0) {
                    const excelBtn = document.getElementById('excelUploadBtn');
                    const excelInput = document.getElementById('excelUpload');

                    if (excelBtn && excelInput) {
                        excelBtn.disabled = true;
                        excelInput.disabled = true;
                    }
                }

            });
        });
    },


    dynamicDataTabs: function (deviceName = null, isEditMode = false, existingGroups = []) {
        const self = this;
        self.existingGroupNames = new Set();

        function createTab(groupName, tabId) {
            const dataPointTabs = document.getElementById('dataPointTabs');
            const dataPointTabContent = document.getElementById('dataPointTabContent');

            if (!document.getElementById(`${tabId}-tab`)) {
                const newTab = document.createElement('li');
                newTab.classList.add('nav-item', 'slide-in');
                newTab.innerHTML = `
                    <a class="nav-link" id="${tabId}-tab" data-toggle="tab" href="#${tabId}" role="tab">${groupName}</a>
                `;
                dataPointTabs.appendChild(newTab);

                const newTabContent = document.createElement('div');
                newTabContent.classList.add('tab-pane');
                newTabContent.id = tabId;
                newTabContent.setAttribute('role', 'tabpanel');
                newTabContent.innerHTML = `
                 <div class="data-row-container">
                        <!-- Data rows will be added here -->
                    </div>
                    <button id="addRow-${tabId}" class="btn btn-primary" style="margin: 10px 0;">Add Data Points</button>
                   
                `;
                dataPointTabContent.appendChild(newTabContent);

                document.getElementById(`addRow-${tabId}`).addEventListener('click', function () {
                    self.addDataPointRow(tabId);
                });

                self.processedGroups.set(groupName.trim(), tabId);
                // Auto-add rows based on "Number of Data Points"
                const groupRows = document.querySelectorAll('#GroupTextBoxes .row.modusblock');
                groupRows.forEach((row) => {
                    const nameInput = row.querySelector('.group-name');
                    const countInput = row.querySelector('.num-data-points');

                    if (nameInput && countInput) {
                        const name = nameInput.value.trim();
                        const count = parseInt(countInput.value, 10);

                        if (name === groupName && !isNaN(count)) {
                            self.groupDataPointLimits.set(groupName, count);
                            for (let i = 0; i < count; i++) {
                                self.addDataPointRow(tabId);
                            }
                        }
                    }
                });
                self.existingGroupNames.add(groupName);
            }
        }

        if (isEditMode) {
            existingGroups.forEach((groupName, index) => {
                const tabId = `tab-${index}`;
                createTab(groupName, tabId);

                setTimeout(() => {
                    self.fetchDataPointsConfiguration(groupName);
                }, 200);
                const groupInput = document.querySelector(`#groupName-${index}`);
                if (groupInput) {
                    groupInput.dataset.originalName = groupName;
                }

                self.processedGroups.set(groupName, tabId);
            });

            return;
        }


        document.getElementById('next').addEventListener('click', function (e) {
            e.preventDefault();
            const groupRows = document.querySelectorAll('#GroupTextBoxes .row.modusblock');
            let addedGroup = false;

            groupRows.forEach((row, newIndex) => {
                const input = row.querySelector('.group-name');
                const newGroupName = input.value.trim();
                const oldGroupName = input.dataset.originalName || "";
                const tabId = `tab-${newIndex}`;

                if (!newGroupName) {
                    // alert('Please enter a group name.');
                    L.ui.showAlert("error", "Missing Information", "Please enter the group name before proceeding.");
                    return;
                }

                if (oldGroupName && oldGroupName !== newGroupName) {
                    if (self.processedGroups.has(oldGroupName)) {
                        const existingTabId = self.processedGroups.get(oldGroupName);
                        self.processedGroups.delete(oldGroupName);
                        self.processedGroups.set(newGroupName, existingTabId);

                        const existingTab = document.getElementById(`${existingTabId}-tab`);
                        if (existingTab) {
                            existingTab.textContent = newGroupName;
                        }
                    }
                }

                if (!self.processedGroups.has(newGroupName)) {
                    createTab(newGroupName, tabId);
                    addedGroup = true;
                }

                input.dataset.originalName = newGroupName;
                input.dataset.index = newIndex;
            });

            if (addedGroup) {
                L.ui.showAlert("success", "Group Added", "Group successfully added to Data Points!");
                document.getElementById('datapointconfig').scrollIntoView({ behavior: 'smooth' });
                const excelBtn = document.getElementById('excelUploadBtn');
                const excelInput = document.getElementById('excelUpload');

                if (excelBtn && excelInput) {
                    excelBtn.disabled = false;
                    excelInput.disabled = false;
                }
            }
        });
    },

    addDataPointRow: function (tabId, dataPoint = {}, index = null) {
        const self = this;
        const tabContent = document.getElementById(tabId);
        const rowContainer = tabContent.querySelector('.data-row-container');

        const groupName = [...self.processedGroups.entries()].find(([, val]) => val === tabId)?.[0];
        let maxAllowed = 100;

        if (groupName && self.groupDataPointLimits.has(groupName)) {
            maxAllowed = self.groupDataPointLimits.get(groupName);
        }

        if (rowContainer.children.length >= maxAllowed) {
            L.ui.showAlert("warning", "Limit Reached", `You can add a maximum of ${maxAllowed} data points for this group.`);
            return;
        }


        const currentRows = rowContainer.children.length;
        const rowNumber = index !== null ? index + 1 : currentRows + 1;

        const row = document.createElement('div');
        row.classList.add('form-row');
        row.innerHTML = `
            <div class="col-md-12">
                <p class="serial-number">${rowNumber}</p>
            </div>
            <div class="form-group col-md-2">
                <label>Data Point Name</label>
                <input type="text" class="form-control dataPointName"  placeholder="Enter data point name" value="${dataPoint.name || ''}">
            </div>
            <div class="form-group col-md-2">
                <label>Data Type</label>
                <select class="form-control dataType">
                    <option value="">Select type</option>
                      <option value="0" ${dataPoint.type == "0" ? "selected" : ""}>analog-input</option>
                          <option value="1" ${dataPoint.type == "1" ? "selected" : ""}>analog-output</option>
                          <option value="2" ${dataPoint.type == "2" ? "selected" : ""}>analog-value</option>
                          <option value="3" ${dataPoint.type == "3" ? "selected" : ""}>binary-input</option>
                          <option value="4" ${dataPoint.type == "4" ? "selected" : ""}>binary-output</option>
                          <option value="5" ${dataPoint.type == "5" ? "selected" : ""}>binary-value</option>
                          <option value="13" ${dataPoint.type == "13" ? "selected" : ""}>multi-state-input</option>
                          <option value="14" ${dataPoint.type == "14" ? "selected" : ""}>multi-state-output</option>
                          <option value="19" ${dataPoint.type == "19" ? "selected" : ""}>multi-state-value</option>
                </select>
            </div>
            <div class="form-group col-md-2">
                <label>Instance</label>
                <input type="text" class="form-control instance"  placeholder="Enter instance" value="${dataPoint.instance || ''}">
            </div>
            <div class="form-group col-md-2">
                <label>Description</label>
                <input type="text" class="form-control description" placeholder="Enter description" value="${dataPoint.description || ''}">
            </div>
            <div class="col-md-2">
                <input type="button" value="Delete" class="btn btn-danger dataRemoveButton" style="margin-top: 22px;">
            </div>
        `;

        //  Add delete functionality for removing data points
        row.querySelector('.dataRemoveButton').addEventListener('click', function () {
            rowContainer.removeChild(row);
            self.updateRowCount(tabId);
        });

        rowContainer.appendChild(row);
        self.updateRowCount(tabId);
    },


    updateRowCount: function (tabId) {
        const tabContent = document.getElementById(tabId);
        const rowContainer = tabContent.querySelector('.data-row-container');
        const rows = rowContainer.querySelectorAll('.form-row');
        rows.forEach((row, index) => {
            const serialNumberElement = row.querySelector('.serial-number');
            serialNumberElement.textContent = index + 1;
        });
    },


    reindexGroups: function () {
        const self = this;
        const groupRows = document.querySelectorAll('#GroupTextBoxes .row.modusblock');
        const dataPointTabs = document.getElementById('dataPointTabs');
        const dataPointTabContent = document.getElementById('dataPointTabContent');

        dataPointTabs.innerHTML = '';
        dataPointTabContent.innerHTML = '';
        self.processedGroups.clear();

        groupRows.forEach((row, newIndex) => {
            const groupNameInput = row.querySelector('.group-name');
            const numDataPointsInput = row.querySelector('.num-data-points');
            const intervalQueryInput = row.querySelector('.interval-query');
            // const objectPropertyInput = row.querySelector('.object-property');

            // Update input attributes
            groupNameInput.dataset.index = newIndex;
            groupNameInput.id = `groupName-${newIndex}`;
            numDataPointsInput.id = `numDataPoints-${newIndex}`;
            intervalQueryInput.id = `intervalQuery-${newIndex}`;
            // objectPropertyInput.id = `objectProperty-${newIndex}`;

            const groupName = groupNameInput.value.trim();
            const tabId = `tab-${newIndex}`;

            // Create tab and content
            const tabElement = document.createElement('li');
            tabElement.classList.add('nav-item');
            tabElement.innerHTML = `
                <a class="nav-link" id="${tabId}-tab" data-toggle="tab" href="#${tabId}" role="tab">
                    ${groupName || `Group ${newIndex + 1}`}
                </a>`;
            dataPointTabs.appendChild(tabElement);

            const tabContentElement = document.createElement('div');
            tabContentElement.classList.add('tab-pane');
            tabContentElement.id = tabId;
            tabContentElement.setAttribute('role', 'tabpanel');
            tabContentElement.innerHTML = `
                <button id="addRow-${tabId}" class="btn btn-primary" style="margin: 10px 0;">Add Data Point</button>
                <div class="data-row-container"></div>
            `;
            dataPointTabContent.appendChild(tabContentElement);

            // Set click listener for Add Data Point
            const addButton = document.getElementById(`addRow-${tabId}`);
            addButton.addEventListener('click', function () {
                self.addDataPointRow(tabId);
            });

            // Add to processedGroups
            self.processedGroups.set(groupName, tabId);

            // Restore stored data points if they exist
            if (self.storedDataPoints.has(groupName)) {
                const storedData = self.storedDataPoints.get(groupName);
                storedData.forEach((dataPoint, index) => {
                    self.addDataPointRow(tabId, dataPoint, index);
                });
            }
        });

        // Update freeIndices
        self.freeIndices = [];
        for (let i = 0; i < groupRows.length; i++) {
            if (![...self.processedGroups.values()].includes(`tab-${i}`)) {
                self.freeIndices.push(i);
            }
        }
    },


    // showing the loader according to the timing of api calls
    catchingData: function () {
        const self = this;
        document.getElementById('saveDeviceButton').addEventListener('click', async function (event) {
            event.preventDefault();

            //  Show loader
            document.getElementById("loadingOverlay").style.display = "flex";

            // Force UI to update before API calls
            await new Promise(resolve => setTimeout(resolve, 100));

            const deviceName = document.getElementById('deviceName').value.trim();
            if (!deviceName) {
                L.ui.showAlert("error", "Validation Error", "Please enter a device name to continue.");
                document.getElementById("loadingOverlay").style.display = "none";
                return;
            }

            const actionType = self.isUpdateMode ? "Update" : "Add";

            if (actionType === "Add") {
                let isDuplicate = false;
                document.querySelectorAll("#devicesTable tbody tr").forEach(row => {
                    const existingDeviceName = row.cells[1].textContent.trim().toLowerCase();
                    if (existingDeviceName === deviceName.toLowerCase()) {
                        isDuplicate = true;
                    }
                });

                if (isDuplicate) {
                    // alert('Device name must be unique!');
                    L.ui.showAlert("error", "Duplicate Name", "The device name must be unique. Please choose a different name.");
                    document.getElementById("loadingOverlay").style.display = "none";
                    return;
                }
            }

            const deviceMode = document.getElementById('deviceMode').value.trim();
            const deviceIp = document.getElementById('deviceIp').value.trim();
            const devicePort = parseInt(document.getElementById('devicePort').value, 10);
            const objectInstanceValue = document.getElementById('objectInstance').value.trim();
            const objectInstance = parseInt(objectInstanceValue, 10);

            if (!deviceMode || !deviceIp || isNaN(devicePort) || isNaN(objectInstance)) {
                L.ui.showAlert("error", "Validation Error", "Please complete all required fields before proceeding.");
                document.getElementById("loadingOverlay").style.display = "none";
                return;
            }
            if (!validateIPAddress(deviceIp)) {
                L.ui.showAlert("error", "Invalid IP Address", "Please enter a valid IP address to continue.");
                document.getElementById("loadingOverlay").style.display = "none";
                return;
            }

            const deviceData = { actionType, deviceName, deviceMode, deviceIp, devicePort, objectInstance };

            const groups = [];

            const groupRows = document.querySelectorAll('#GroupTextBoxes .row.modusblock');

            groupRows.forEach(row => {
                const groupName = row.querySelector('.group-name')?.value.trim();
                const numDataPoints = parseInt(row.querySelector('.num-data-points')?.value, 10);
                const queryInterval = parseInt(row.querySelector('.interval-query')?.value, 10);
                const objectProperty = parseInt(row.querySelector('.object-property')?.value, 10);


                if (groupName && !isNaN(numDataPoints) && !isNaN(queryInterval)) {
                    groups.push({ groupName, numDataPoints, queryInterval, objectProperty });
                }

            });


            const groupConfig = {
                deviceName,
                numberOfGroups: groups.length,
                groups
            };

            const dataPointsConfig = [];
            if (groups.length === 0) {
                // No groups defined, send empty structure
                dataPointsConfig.push({
                    deviceName: deviceName,
                    dataPoints: []
                });
            } else {
                groups.forEach((group) => {
                    const tabId = self.processedGroups.get(group.groupName);
                    const dataPoints = [];

                    if (tabId) {
                        const tabContent = document.getElementById(tabId);
                        if (tabContent) {
                            const dataRows = tabContent.querySelectorAll('.data-row-container .form-row');
                            dataRows.forEach((dataRow) => {
                                const name = dataRow.querySelector('.dataPointName').value.trim();
                                const type = dataRow.querySelector('.dataType').value;
                                const instance = dataRow.querySelector('.instance').value.trim();
                                const description = dataRow.querySelector('.description').value.trim();

                                if (name && type && instance && description) {
                                    dataPoints.push({ name, type, instance, description });
                                }
                            });
                        }
                    }

                    dataPointsConfig.push({
                        devicename: deviceName,
                        Groupname: group.groupName,
                        dataPoints,
                    });
                });
            }
            try {
                // Wait for all API calls before hiding loader
                await self.sendDeviceConfigAPI(deviceData);
                await self.sendGroupConfigAPI(groupConfig);
                await self.sendDataPointsConfigAPI(dataPointsConfig);

                //  Hide loader **only after** API calls are done
                document.getElementById("loadingOverlay").style.display = "none";

                const successMessage = self.isUpdateMode
                    ? 'Device updated successfully!'
                    : 'Device added successfully!';
                L.ui.showAlert("success", "Saved", successMessage);

                //    Reload after success message
                setTimeout(() => {
                    location.reload();
                }, 2000);

            } catch (error) {
                console.error('Error processing device:', error);
                //  Hide loader and show error message
                document.getElementById("loadingOverlay").style.display = "none";
                L.ui.showAlert("error", "Save Failed", "Unable to save the device. Please try again.");
            }
        });
    },


    sendDeviceConfigAPI: function (deviceData) {
        let params = window.location.href;
        let BaseURL = new URL(params).origin;
        // return fetch('https://cors-anywhere.herokuapp.com/https://webhook.site/92844bf7-af09-4bbe-9cba-59fd31030ff8', {
        return fetch(`${BaseURL}:30008/Device_Post/1`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(deviceData)
        })
            .then(response => {
                if (!response.ok) {
                    throw new Error('Network response was not ok');
                }
                return response.text();
            })
            .then(text => { })
            .catch(error => { console.error('Fetch error:', error); throw error; }); // Rethrow to catch in main
    },



    sendGroupConfigAPI: function (groupConfig) {
        let params = window.location.href;
        let BaseURL = new URL(params).origin;
        //return fetch('https://cors-anywhere.herokuapp.com/https://webhook.site/92844bf7-af09-4bbe-9cba-59fd31030ff8', {
        return fetch(`${BaseURL}:30008/Group_Post/1`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(groupConfig)
        })
            .then(response => {
                if (!response.ok) {
                    throw new Error('Network response was not ok');
                }
                return response.text();
            })
            .then(text => { })
            .catch(error => { console.error('Fetch error:', error); throw error; });
    },

    sendDataPointsConfigAPI: function (dataPointsConfig) {
        let params = window.location.href;
        let BaseURL = new URL(params).origin;
        //return fetch('https://cors-anywhere.herokuapp.com/https://webhook.site/92844bf7-af09-4bbe-9cba-59fd31030ff8', {
        return fetch(`${BaseURL}:30008/Datapoints_Post/1`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(dataPointsConfig)
        })
            .then(response => {
                if (!response.ok) {
                    throw new Error('Network response was not ok');
                }
                return response.text();
            })
            .then(text => { })
            .catch(error => { console.error('Fetch error:', error); throw error; });
    },


    editDevice: async function (selectedDevice) {
        try {
            const self = this;
            self.isUpdateMode = true;
            self.originalDeviceName = selectedDevice.deviceName;
            // Reset Group and Data Points Configuration before loading new data
            document.getElementById('GroupTextBoxes').innerHTML = '';
            document.getElementById('dataPointTabs').innerHTML = '';
            document.getElementById('dataPointTabContent').innerHTML = '';

            document.getElementById('deviceName').value = selectedDevice.deviceName;
            document.getElementById('deviceName').readOnly = true; //  Make it read-only during edit
            document.getElementById('deviceMode').value = selectedDevice.deviceMode;
            document.getElementById('deviceIp').value = selectedDevice.deviceIp;
            document.getElementById('devicePort').value = selectedDevice.devicePort;
            document.getElementById('objectInstance').value = selectedDevice.objectInstance;

            // Change modal title and button text for update mode
            document.getElementById('addDeviceModalLabel').textContent = "Update Device";
            document.getElementById('saveDeviceButton').textContent = "Update Device";

            $('#BACnetModal').modal('show');

            // Fetch Group Configuration
            await self.fetchGroupConfiguration(selectedDevice.deviceName);
        } catch (error) {
            console.error(' Error editing device:', error);
        }
    },

    fetchGroupConfiguration: async function (deviceName) {
        let params = window.location.href;
        let BaseURL = new URL(params).origin;
        try {
            const self = this;
            //const response = await fetch('https://mocki.io/v1/a9994ec1-4dd3-4b93-83ea-e0e9efc8c297');
            const response = await fetch(`${BaseURL}:30008/BACnetGroupConfiguration/${deviceName}`);
            const data = await response.json();

            if (!data || !Array.isArray(data.groups)) {
                console.error(" API did not return a valid groups array");
                return;
            }

            if (data.deviceName !== deviceName) {
                console.warn(` No groups found for device: ${deviceName}`);
                return;
            }

            const deviceGroups = data.groups;
            if (deviceGroups.length === 0) {
                console.warn(` No groups found for device: ${deviceName}`);
                return;
            }

            document.getElementById('GroupTextBoxes').innerHTML = '';

            self.dynamicDataTabs(deviceName, true, deviceGroups.map(g => g.groupName));

            for (let [index, group] of deviceGroups.entries()) {
                document.getElementById('addGroupButton').click();
                await new Promise(resolve => setTimeout(resolve, 100));

                let groupNameField = document.getElementById(`groupName-${index}`);
                let numDataPointsField = document.getElementById(`numDataPoints-${index}`);
                let intervalQueryField = document.getElementById(`intervalQuery-${index}`);
                let objectPropertyField = document.getElementById(`objectProperty-${index}`);

                if (groupNameField) {
                    groupNameField.value = group.groupName || '';
                    groupNameField.dataset.originalName = group.groupName; // Store original name for tracking
                }
                if (numDataPointsField) numDataPointsField.value = group.numDataPoints || '';
                if (intervalQueryField) intervalQueryField.value = group.queryInterval || '';
                if (objectPropertyField) objectPropertyField.value = group.objectProperty || '';
                await self.fetchDataPointsConfiguration(group.groupName, deviceName);
            }
        } catch (error) {
            console.error(' Error fetching group configuration:', error);
        }
        // ✅ Enable Excel upload in edit mode if groups exist
        const excelBtn = document.getElementById('excelUploadBtn');
        const excelInput = document.getElementById('excelUpload');

        if (excelBtn && excelInput && this.processedGroups.size > 0) {
            excelBtn.disabled = false;
            excelInput.disabled = false;
        }

    },


    fetchDataPointsConfiguration: async function (groupName, deviceName) {
        let params = window.location.href;
        let BaseURL = new URL(params).origin;
        try {
            const self = this;
            //const response = await fetch('https://mocki.io/v1/5023eda2-5824-40cd-b790-03ee56f2ed99');
            const response = await fetch(`${BaseURL}:30008/BACnetDatapointsConfiguration/${deviceName}`);
            const data = await response.json();

            if (!Array.isArray(data)) {
                console.error(" API did not return a valid array of data points."); return;
            }

            const groupData = data.find(group => group.Groupname === groupName);
            if (!groupData) {
                console.warn(` No data points found for group: ${groupName}`);
                return;
            }

            const tabId = self.processedGroups.get(groupName);
            if (!tabId) {
                console.error(` Tab for group ${groupName} not found!`);
                return;
            }
            const tabContent = document.getElementById(tabId);
            if (!tabContent) {
                console.error(` Tab content for ${tabId} not found!`);
                return;
            }

            const dataRowContainer = tabContent.querySelector('.data-row-container');
            dataRowContainer.innerHTML = ''; // Clear existing rows

            //  Ensure previous stored data is merged with new fetched data
            const existingData = self.storedDataPoints.get(groupName) || [];
            const newData = groupData.dataPoints.filter(dp => !existingData.some(e => e.name === dp.name));

            self.storedDataPoints.set(groupName, [...existingData, ...newData]);

            //  Add all stored data points to the UI
            self.storedDataPoints.get(groupName).forEach((dataPoint, index) => {
                self.addDataPointRow(tabId, dataPoint, index);
            });
        } catch (error) {
            console.error(' Error fetching data points configuration:', error);
        }
    },


    addDeviceDataToTable: function (deviceData) {
        const table = document.getElementById('devicesTable');
        let tableHeader = table.querySelector('thead');
        let tableBody = table.querySelector('tbody');

        if (!tableHeader) {
            tableHeader = document.createElement('thead');
            table.appendChild(tableHeader);
        }
        if (!tableBody) {
            tableBody = document.createElement('tbody');
            table.appendChild(tableBody);
        }

        if (tableHeader.rows.length === 0) {
            const headerRow = document.createElement('tr');
            const snidHeader = document.createElement('th');
            snidHeader.textContent = 'SNID';
            headerRow.appendChild(snidHeader);

            Object.keys(deviceData).forEach(key => {
                const headerCell = document.createElement('th');
                headerCell.textContent = key.charAt(0).toUpperCase() + key.slice(1);
                headerRow.appendChild(headerCell);
            });

            const actionsHeader = document.createElement('th');
            actionsHeader.textContent = 'Actions';
            headerRow.appendChild(actionsHeader);
            tableHeader.appendChild(headerRow);
        }

        let isDuplicate = false;
        tableBody.querySelectorAll('tr').forEach(row => {
            const existingDeviceName = row.cells[1]?.textContent.trim().toLowerCase();
            if (existingDeviceName === deviceData.deviceName.trim().toLowerCase()) {
                isDuplicate = true;
            }
        });

        if (isDuplicate) {
            L.ui.showAlert("error", "Duplicate Name", "The device name must be unique. Please choose a different name.");
            return;
        }

        const newRow = document.createElement('tr');
        const snid = tableBody.getElementsByTagName('tr').length + 1;
        newRow.innerHTML = `<td>${snid}</td>`;

        Object.keys(deviceData).forEach(key => {
            const dataCell = document.createElement('td');
            dataCell.textContent = deviceData[key];
            newRow.appendChild(dataCell);
        });

        const actionsCell = document.createElement('td');
        actionsCell.classList.add('action-buttons');
        actionsCell.innerHTML = `
            <button class="btn btn-primary">Edit</button>
            <button class="btn btn-danger deleteBtn">Delete</button>
        `;
        newRow.appendChild(actionsCell);

        tableBody.appendChild(newRow);

        const self = this;
        const editButton = newRow.querySelector('.btn-primary');
        const deleteButton = newRow.querySelector('.deleteBtn');

        editButton.addEventListener('click', function () {
            self.editDevice(deviceData);
        });
        deleteButton.addEventListener('click', function (ev) {
            ev.preventDefault();

            L.ui.confirmDelete(ev, async function (res) {
                if (!res) return;
                document.getElementById("loadingOverlay").style.display = "flex";

                try {
                    const success = await self.sendDeleteBACnetDeviceAPI(deviceData.deviceName);
                    if (!success) throw new Error("Delete failed");

                    tableBody.removeChild(newRow);

                    // Reindex SNIDs
                    let index = 1;
                    tableBody.querySelectorAll('tr').forEach(row => {
                        row.cells[0].textContent = index++;
                    });

                    L.ui.showAlert("success", "Deleted", `"${deviceData.deviceName}" deleted successfully!`);

                    if (tableBody.children.length === 0) {
                        document.querySelector('#devicesTable thead').innerHTML = '';
                    }

                    setTimeout(() => location.reload(), 2000);

                } catch (err) {
                    console.error(err);
                    L.ui.showAlert("error", "Delete Failed", "Unable to delete the device. Please try again.");
                } finally {
                    document.getElementById("loadingOverlay").style.display = "none";
                }
            });
        });
    },

    sendDeleteBACnetDeviceAPI: function (deviceName) {
        let params = window.location.href;
        let BaseURL = new URL(params).origin;
        if (!deviceName) {
            console.error("Error: Device name is missing or undefined.");
            return;
        }
        const payload = {
            actionType: "Delete",
            deviceName: deviceName
        };

        //return fetch('https://cors-anywhere.herokuapp.com/https://webhook.site/92844bf7-af09-4bbe-9cba-59fd31030ff8', {
        return fetch(`${BaseURL}:30008/Device_Post/1`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(payload)
        })
            .then(response => {
                if (!response.ok) {
                    throw new Error('Network response was not ok');
                }
                return response.text();
            })
            .then(text => {
                return true;
            })
            .catch(error => {
                console.error('Failed to delete device:', error);
                return false;
            });
    },

    showToast: function (message, isError = false) {
        const toast = document.getElementById('bacnetToast');
        const toastText = document.getElementById('toastText');

        toastText.textContent = message;
        toast.style.background = isError
            ? "linear-gradient(135deg, #dc3545, #b02a37)"  // Red for errors
            : "linear-gradient(135deg, #007bff, #0056b3)"; // Blue for success

        toast.classList.add('toast-show');  // Show animation

        setTimeout(() => {
            toast.classList.add('toast-hide'); // Start fade out
        }, 2500); // After 2.5 seconds, fade out

        setTimeout(() => {
            toast.classList.remove('toast-show', 'toast-hide'); // Reset after fade out
        }, 3000);
    },
    disableBACPage: function () {
        const wrapper = document.getElementById("bacContentWrapper");
        const overlay = document.getElementById("BACDisabledOverlay");

        if (wrapper) wrapper.classList.add("bac-blurred");
        if (overlay) overlay.style.display = "flex";
    },

    enableBACPage: function () {
        const wrapper = document.getElementById("bacContentWrapper");
        const overlay = document.getElementById("BACDisabledOverlay");

        if (wrapper) wrapper.classList.remove("bac-blurred");
        if (overlay) overlay.style.display = "none";
    },

    downloadBACnetSampleExcel: function () {
        const self = this;

        // Safety check
        if (!self.processedGroups || self.processedGroups.size === 0) {
            L.ui.showAlert(
                "warning",
                "No Groups Found",
                "Please add at least one Group before downloading sample Excel."
            );
            return;
        }

        const wb = XLSX.utils.book_new();

        // For each Group → create one sheet
        self.processedGroups.forEach((groupIndex, groupName) => {

            // Sample rows (only format demo, user will edit)
            const sampleRows = [
                {
                    "Data Point Name": "dp_1",
                    "Data Type": "0",
                    "Instance": "1001",
                    "Description": "Sample description"
                },
                {
                    "Data Point Name": "dp_2",
                    "Data Type": "1",
                    "Instance": "1002",
                    "Description": "Sample description"
                }
            ];

            const ws = XLSX.utils.json_to_sheet(sampleRows);

            // Sheet name MUST match Group name exactly
            XLSX.utils.book_append_sheet(wb, ws, groupName);
        });

        XLSX.writeFile(wb, "BACnet_DataPoints_Sample.xlsx");
    },


    execute: function () {
        var self = this;
        let params = window.location.href;
        let BaseURL = new URL(params).origin;
        //  Initialize stored data points to keep track of fetched data
        self.storedDataPoints = new Map();
        self.dynamicDataTabs();
        self.dynamicGroupFields();
        self.catchingData();
        // fetch(`https://mocki.io/v1/917e978b-bb56-42a5-b4ee-cbec6e5fe568`)
        //fetch(`https://mocki.io/v1/51890fc6-8dc6-4c1d-b866-9b36a55913a5`)
        // fetch(`${BaseURL}:30008/device/applications/`)
        //     .then(res => res.json())
        //     .then(apps => {
        //         const bacnetApp = apps.find(app => app.id === "bacnet");

        //         if (bacnetApp && bacnetApp.state === "running") {
        //             self.enableBACPage();
        //         } else {
        //             self.disableBACPage();
        //         }
        //     })
        //     .catch(err => {
        //         console.error("Execute API failed:", err);
        //         self.disableBACPage(); // fail-safe
        //     });
        self.enableBACPage();

        document.getElementById('excelUpload').addEventListener('change', function (e) {
            const file = e.target.files[0];
            if (!file) return;

            const reader = new FileReader();

            reader.onload = function (e) {
                const data = new Uint8Array(e.target.result);
                const workbook = XLSX.read(data, { type: 'array' });
                // ADD THIS GUARD HERE (IMPORTANT)
                if (!self.processedGroups || self.processedGroups.size === 0) {
                    L.ui.showAlert(
                        "warning",
                        "No Groups Found",
                        "Please add at least one Group before uploading Excel."
                    );

                    // reset file input so user can re-select later
                    document.getElementById('excelUpload').value = '';
                    return;
                }

                workbook.SheetNames.forEach(sheetName => {
                    const sheetData = XLSX.utils.sheet_to_json(workbook.Sheets[sheetName], { defval: '' });

                    if (!Array.isArray(sheetData) || sheetData.length === 0) return;

                    const groupName = sheetName.trim();
                    const tabId = self.processedGroups.get(groupName);

                    if (!tabId) {
                        L.ui.showAlert(
                            "error",
                            "Group Not Found",
                            `Group "${groupName}" not found. Create the group first before uploading.`
                        );
                        return;
                    }

                    const tabContent = document.getElementById(tabId);
                    const rowContainer = tabContent.querySelector('.data-row-container');
                    rowContainer.innerHTML = ''; // Clear existing rows

                    const points = [];

                    sheetData.forEach((row, index) => {
                        const name = row["Data Point Name"]?.toString().trim() || "";
                        const type = row["Data Type"]?.toString().trim() || "";
                        const instance = row["Instance"]?.toString().trim() || "";
                        const description = row["Description"]?.toString().trim() || "";

                        if (name && type && instance && description) {
                            points.push({ name, type, instance, description });
                        }
                    });

                    self.storedDataPoints.set(groupName, points);
                    points.forEach((dataPoint, index) => {
                        self.addDataPointRow(tabId, dataPoint, index);
                    });

                    self.updateRowCount(tabId);
                    L.ui.showAlert(
                        "success",
                        "Success",
                        `Data points loaded for group "${groupName}".`
                    );
                });

                document.getElementById('excelUpload').value = ''; // Clear input
            };

            reader.readAsArrayBuffer(file);
        });


        const sampleBtn = document.getElementById('downloadBACnetSampleExcel');
        if (sampleBtn) {
            sampleBtn.addEventListener('click', () => {
                this.downloadBACnetSampleExcel();
            });
        }


        validateTheNames = function (inputElement) {
            var nameArray = [];
            $('.group-name').each(function () {
                var name = $(this).val().trim();
                var index = $(this).data("index");
                if (name && $(this).closest('.row.modusblock').length > 0) {
                    nameArray.push({ name, index });
                }
            });

            var currentName = $(inputElement).val();
            var currentIndex = $(inputElement).data("index");

            for (let item of nameArray) {
                if (item.name === currentName && item.index != currentIndex) {
                    L.ui.showAlert("error", "Duplicate Name", "The group name must be unique. Please choose a different group name.");
                    $(inputElement).val('');
                    return false;
                }
            }
        };

        // fetch('https://mocki.io/v1/cc6c9afb-75ef-4325-878c-57f918b9b33b')
        fetch(`${BaseURL}:30008/BACnetConfiguration/1`)
            .then(response => response.json())
            .then(data => {
                data.forEach(device => {
                    self.addDeviceDataToTable(device);
                });
            })
            .catch(error => console.error('Error fetching device data:', error));
        $('#BACnetModal').on('hidden.bs.modal', function () {
            self.isUpdateMode = false;
            self.originalDeviceName = '';
            // Reset all input fields
            document.getElementById('bacnet-device-config').reset();

            // Clear Group and Data Points Configurations
            document.getElementById('GroupTextBoxes').innerHTML = '';
            document.getElementById('dataPointTabs').innerHTML = '';
            document.getElementById('dataPointTabContent').innerHTML = '';
            document.getElementById('deviceName').readOnly = false;

            // Reset modal title and button text
            document.getElementById('saveDeviceButton').textContent = "Save Device";
            document.getElementById('addDeviceModalLabel').textContent = "Add New Device";
        });

    }
});
