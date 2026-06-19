L.ui.view.extend({

        DisplayGenericRSXFromAPI: function () {
                let params = window.location.href;
                let BaseURL = new URL(params).origin;
                const tabList = document.getElementById('pills-tab');
                const tabContent = document.getElementById('pills-tabContent');
                const deviceInfo = document.getElementById('deviceInfo');

                // fetch(`https://mocki.io/v1/542f0c80-5ef9-4278-be67-7e8e427a7fc5`)
                fetch(`${BaseURL}:30001/snmpdata/1`)
                        .then(res => res.json())
                        .then(jsonData => {
                                const devices = jsonData.Devices || [];
                                const deviceID = jsonData.DeviceID || '';
                                const timestamp = jsonData.TimeStamp || '';


                                deviceInfo.value = `DeviceID: ${deviceID}\nTimeStamp: ${timestamp}`;
                                console.log(jsonData.NoGenericRSXDevice)
                                const noGenericRSXDevice = parseInt(jsonData.NoGenericSNMPDevice);

                                if (noGenericRSXDevice === 0) {
                                        L.ui.showNoConfigMessage("Generic SNMP Devices", "No-SNMPData");
                                        document.getElementById('downloadData').style.display = 'none'
                                        document.getElementById('deviceInfo').style.display = 'none'
                                } else {

                                        tabList.innerHTML = '';
                                        tabContent.innerHTML = '';
                                        devices.forEach((device, index) => {
                                                const devNum = index + 1;
                                                const tabId = `pills-snmp${devNum}-tab`;
                                                const paneId = `pills-snmp${devNum}`;
                                                const tableId = `snmp${devNum}datatable`;

                                                const tabItem = document.createElement('li');
                                                tabItem.className = `nav-item${index === 0 ? ' active' : ''}`;
                                                tabItem.innerHTML = `
                                                <a class="nav-link${index === 0 ? ' active' : ''}" id="${tabId}" data-toggle="pill"
                                                href="#${paneId}" role="tab" aria-controls="${paneId}" aria-selected="${index === 0}">
                                                Device ${devNum}
                                                </a>
                                                `;
                                                tabList.appendChild(tabItem);


                                                const tabPane = document.createElement('div');
                                                tabPane.className = `tab-pane${index === 0 ? ' active' : ''}`;
                                                tabPane.id = paneId;
                                                tabPane.setAttribute('role', 'tabpanel');
                                                tabPane.setAttribute('aria-labelledby', tabId);


                                                let rows = '';
                                                Object.entries(device).forEach(([key, val]) => {
                                                        rows += `<tr><td>${key}</td><td>${val}</td></tr>`;
                                                });

                                                tabPane.innerHTML = `
                                                <table class="table table-condensed table-hover"  id="${tableId}">
                                                        <tbody>
                                                                <tr class="cbi-section-table-titles">
                                                                <th class="cbi-section-table-cell">Parameter</th>
                                                                <th class="cbi-section-table-cell">Value</th>
                                                                </tr>
                                                        ${rows}
                                                        </tbody>
                                                        </table>
                                                `;
                                                tabContent.appendChild(tabPane);
                                        });
                                }
                        })
                        .catch(err => {
                                console.error('Fetch error:', err);
                                deviceInfo.value = 'Error loading SNMP data.';
                        });
        },




        downloadAllDataAsPDF: function () {
                const { jsPDF } = window.jspdf;

                const extractSiteInfo = (text) => {
                        const lines = text.split('\n');
                        let deviceId = '';
                        let timestamp = '';
                        lines.forEach(line => {
                                if (line.startsWith('DeviceID')) {
                                        deviceId = line.split(':')[1].trim();
                                } else if (line.startsWith('TimeStamp')) {
                                        timestamp = line.split(':')[1].trim();
                                }
                        });
                        return { deviceId, timestamp };
                };

                const addFooter = (doc) => {
                        const pageCount = doc.internal.getNumberOfPages();
                        doc.setFontSize(10);
                        doc.setTextColor(128, 128, 128);
                        for (let i = 1; i <= pageCount; i++) {
                                doc.setPage(i);
                                doc.text('Invendis Technologies India Pvt. Ltd', 10, doc.internal.pageSize.height - 10);
                        }
                };

                const addHeader = (doc, siteInfo) => {
                        doc.setFontSize(10);
                        doc.setTextColor(255, 3, 62); // #FF033E
                        const text = `Device ID: ${siteInfo.deviceId}, Date: ${siteInfo.timestamp}`;
                        const pageWidth = doc.internal.pageSize.getWidth();
                        const textWidth = doc.getTextWidth(text);
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

                const deviceInfoTextArea = document.getElementById('deviceInfo');
                const siteInfo = extractSiteInfo(deviceInfoTextArea.value);

                const doc = new jsPDF();

                const tables = document.querySelectorAll('table[class="table"]');
                let isFirstTable = true;

                tables.forEach((table, index) => {
                        const tableData = getTableData(table);
                        if (!tableData || tableData.length < 2) return;

                        if (!isFirstTable) doc.addPage();

                        doc.setFontSize(12);
                        doc.setTextColor(0);
                        doc.text(`SNMP Device ${index + 1} Data:`, 10, 20);

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
                                        addHeader(doc, siteInfo);
                                }
                        });

                        isFirstTable = false;
                });

                addFooter(doc);

                const filename = `${siteInfo.deviceId}'_SNMP_Devices_${siteInfo.timestamp || Date.now()}.pdf`;
                doc.save(filename);
        },

        execute: function () {
                var self = this;
                self.DisplayGenericRSXFromAPI()
                $('#downloadData').click(function () {
                        self.downloadAllDataAsPDF();
                });
        }
});
