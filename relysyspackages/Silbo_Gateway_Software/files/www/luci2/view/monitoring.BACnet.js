L.ui.view.extend({



    DisplayBACnetData: function () {
        var self = this;
        let params = window.location.href;
        let BaseURL = new URL(params).origin;
        const tabList = document.getElementById('pills-tab');
        const tabContent = document.getElementById('pills-tabContent');
        const deviceInfo = document.getElementById('deviceInfo');

        // fetch(`https://mocki.io/v1/d49ae246-95c1-4435-98fb-7fe2697aa136`)
        fetch(BaseURL + ":30008/BACnetDeviceGroupMoniteringConfiguration/1")
            .then(res => res.json())
            .then(jsonData => {
                const devices = jsonData.devices || [];
                const noOfDevices = parseInt(jsonData.NoOfBacNetDevices || 0);

                if (noOfDevices === 0) {
                    L.ui.showNoConfigMessage("BACnet Devices", "No-BACNetData");
                    document.getElementById('downloadData').style.display = 'none'
                } else {
                    tabList.innerHTML = '';
                    tabContent.innerHTML = '';

                    devices.forEach((device, index) => {
                        const devNum = index + 1;
                        const tabId = `pills-bacnet${devNum}-tab`;
                        const paneId = `pills-bacnet${devNum}`;
                        const selectId = `bacnetSelect${devNum}`;
                        const selectorDivId = `groupSelector-${devNum}`;
                        const dataDivId = `groupData-${devNum}`;

                        // Create Tab Header
                        const tabItem = document.createElement('li');
                        tabItem.className = `nav-item${index === 0 ? ' active' : ''}`;
                        tabItem.innerHTML = `
                        <a class="nav-link${index === 0 ? ' active' : ''}" 
                           id="${tabId}" 
                           data-toggle="pill"
                           href="#${paneId}" 
                           role="tab" 
                           aria-controls="${paneId}" 
                           aria-selected="${index === 0}">
                            ${device.deviceName}
                        </a>
                    `;
                        tabList.appendChild(tabItem);

                        // Create Tab Pane
                        const tabPane = document.createElement('div');
                        tabPane.className = `tab-pane${index === 0 ? ' active' : ''}`;
                        tabPane.id = paneId;
                        tabPane.setAttribute('role', 'tabpanel');
                        tabPane.setAttribute('aria-labelledby', tabId);

                        // Create Dropdown Section
                        const selectorDiv = document.createElement('div');
                        selectorDiv.id = selectorDivId;
                        selectorDiv.className = 'group-container';

                        const label = document.createElement('label');
                        label.className = 'group-label';
                        label.setAttribute('for', selectId);
                        label.textContent = 'Select Group Name:';

                        const select = document.createElement('select');
                        select.id = selectId;
                        select.className = 'group-select';
                        select.innerHTML = `<option value="">Please Select Group</option>`;

                        device.groups.forEach(group => {
                            const option = document.createElement('option');
                            option.value = `${device.deviceName}_${group}`;
                            option.textContent = group;
                            select.appendChild(option);
                        });

                        // Add change event
                        select.addEventListener('change', (e) => {
                            const selectedValue = e.target.value;
                            if (selectedValue) {
                                const dataDiv = document.getElementById(dataDivId);
                                dataDiv.innerHTML = `<p>Loading data for <b>${selectedValue}</b>...</p>`;
                                self.sendData(selectedValue, dataDivId);
                            }
                        });

                        selectorDiv.appendChild(label);
                        selectorDiv.appendChild(select);

                        // Create Data Section

                        const dataDiv = document.createElement('div');
                        dataDiv.id = dataDivId;


                        // Append both sections to tab content
                        tabPane.appendChild(selectorDiv);
                        tabPane.appendChild(dataDiv);
                        tabContent.appendChild(tabPane);
                    });
                    L.ui.createNote(
                        null,
                        'Please select a group to view the data',
                        { type: 'muted', variant: 'inline', appendTo: '#Update-Note' }
                    );
                }
            })
            .catch(err => {
                console.error('Fetch error:', err);
                deviceInfo.value = 'Error loading BACnet data.';
            });
    }
    ,


    sendData: function (selectedGroup, id) {
        var self = this;
        let params = window.location.href;
        let BaseURL = new URL(params).origin;
        const [deviceName, groupName] = selectedGroup.split('_');
        const POSTData = {
            deviceName: deviceName,
            groupName: groupName
        };



        fetch(BaseURL + ":30008/BACnetMoniteringData/1", {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(POSTData)
        })
            .then(response => response.json())
            .then(data => {
                self.renderData(data, id)
            })
            .catch(error => {
                console.error('Error sending selected group:', error);
            });
        // self.renderData(id)
    },




    renderData: function (data, id) {
        var self = this;
        const tabContentData = document.getElementById(id);
        tabContentData.innerHTML = '';
        // fetch('https://mocki.io/v1/98cb95eb-997d-45a5-a982-53c0a64da781')
        //     .then(res => res.json())
        //     .then(data => {
        Object.entries(data).forEach(([deviceName, groups]) => {
            Object.entries(groups).forEach(([groupName, dataPoints]) => {
                const groupTitle = document.createElement('div');
                groupTitle.className = 'data-header';

                groupTitle.innerHTML = `
                            <span class="data-header__label">Displaying</span>
                            <span class="data-header__group">${groupName}</span>
                            <span class="data-header__label">data for</span>
                            <span class="data-header__device">${deviceName}</span>
                            `;

                let rows = '';
                Object.entries(dataPoints).forEach(([param, value]) => {
                    rows += `<tr><td>${param}</td><td>${value}</td></tr>`;
                });

                const tableHTML = `
                            <table class="table table-condensed table-hover">
                            <tbody>
                                <tr class="cbi-section-table-titles">
                                <th class="cbi-section-table-cell">Parameter</th>
                                <th class="cbi-section-table-cell">Value</th>
                                </tr>
                            ${rows}</tbody>
                            </table>
                        `;

                const wrapper = document.createElement('div');
                wrapper.appendChild(groupTitle);
                wrapper.innerHTML += tableHTML;
                tabContentData.appendChild(wrapper);
            });
            // });
        })


    },

    downloadAllDataAsPDF: function () {
        const { jsPDF } = window.jspdf;

        const addFooter = (doc) => {
            const pageCount = doc.internal.getNumberOfPages();
            doc.setFontSize(10);
            doc.setTextColor(128, 128, 128);
            for (let i = 1; i <= pageCount; i++) {
                doc.setPage(i);
                doc.text('Invendis Technologies India Pvt. Ltd', 10, doc.internal.pageSize.height - 10);
            }
        };

        const addHeader = (doc, deviceName, groupName) => {
            const pageWidth = doc.internal.pageSize.getWidth();
            const text = `Device: ${deviceName} | Group: ${groupName}`;
            const textWidth = doc.getTextWidth(text);
            doc.setFontSize(10);
            doc.setTextColor(255, 3, 62); // #FF033E
            doc.text(text, pageWidth - textWidth - 10, 10);
        };

        const getTableData = (table) => {
            const rows = table.querySelectorAll('tr');
            const data = [];
            rows.forEach(row => {
                const cells = row.querySelectorAll('th, td');
                const rowData = [];
                cells.forEach(cell => {
                    rowData.push(cell.textContent.trim());
                });
                data.push(rowData);
            });
            return data;
        };


        const activeTab = document.querySelector('.tab-pane.active');
        if (!activeTab) {
            alert("No active device tab is selected.");
            return;
        }


        const select = activeTab.querySelector('select');
        if (!select || !select.value) {
            alert("Please select a group name first.");
            return;
        }

        const [deviceName, groupName] = select.value.split('_');

        const dataDiv = activeTab.querySelector('.group-data');
        const table = dataDiv.querySelector('table');

        if (!table) {
            alert("No data table found to export.");
            return;
        }

        const tableData = getTableData(table);
        if (!tableData || tableData.length < 2) {
            alert("No data available to export.");
            return;
        }

        // Create PDF
        const doc = new jsPDF();

        doc.setFontSize(12);
        doc.setTextColor(0);
        doc.text(`${deviceName} - ${groupName} BACnet Data`, 10, 20);

        doc.autoTable({
            head: [tableData[0]],
            body: tableData.slice(1),
            startY: 25,
            theme: 'grid',
            styles: { halign: 'center' },
            columnStyles: {
                0: { cellWidth: 60 }
            },
            didDrawPage: function () {
                addHeader(doc, deviceName, groupName);
            }
        });

        addFooter(doc);

        const fileName = `${deviceName}_${groupName}_bacnet.pdf`;
        doc.save(fileName);
    },



    execute: function () {
        var self = this;
        self.DisplayBACnetData()

        $('#downloadData').click(function () {
            self.downloadAllDataAsPDF();
        });

    }
});
