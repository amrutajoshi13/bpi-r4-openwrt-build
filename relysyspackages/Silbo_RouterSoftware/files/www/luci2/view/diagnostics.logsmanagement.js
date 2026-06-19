L.ui.view.extend({



    handleFilters: function () {
        var self = this;
        let params = window.location.href;
        let BaseURL = new URL(params).origin;
        // fetch('https://mocki.io/v1/e7a4b283-a390-4c59-8039-a913405b8f50')
        fetch(BaseURL + ":30000/DBInfo/logs")
            .then(response => response.json())
            .then(data => {
                self.c = data.Category;
                self.sourceData = data.Source || {};
                self.categorySourceMap = data.CategorySourceMap || {};


                const categoryOptionsDiv = document.getElementById('category-options');
                categoryOptionsDiv.innerHTML = '';
                if (data.Category) {
                    Object.entries(data.Category).forEach(([key, count]) => {
                        categoryOptionsDiv.innerHTML += `
                        <label>
                            <input type="checkbox" name="category" value="${key}"> ${key}
                            <span class="filter-option-count">${count}</span>
                        </label>`;
                    });
                }


                const severityOptionsDiv = document.getElementById('severity-options');
                severityOptionsDiv.innerHTML = '';
                if (data.Severity) {
                    Object.entries(data.Severity).forEach(([key, count]) => {
                        severityOptionsDiv.innerHTML += `
                        <label>
                            <input type="checkbox" name="severity" value="${key}"> ${key}
                            <span class="filter-option-count">(${count})</span>
                        </label>`;
                    });
                }


                const sourceOptionsDiv = document.getElementById('source-options');
                sourceOptionsDiv.innerHTML = '';
                Object.entries(data.Source).forEach(([key, count]) => {
                    sourceOptionsDiv.innerHTML += `
                    <label>
                        <input type="checkbox" name="source" value="${key}"> ${key}
                        <span class="filter-option-count">(${count})</span>
                    </label>`;
                });


                const today = new Date().toISOString().split('T')[0];
                document.getElementById('date-min').value = today;
                document.getElementById('date-max').value = today;
                self.defaultMinDate = today;
                self.defaultMaxDate = today;
            })
            .then(() => self.bindFilterEvents());
    },

    bindFilterEvents: function () {
        var self = this;
        document.querySelectorAll('.filter-group').forEach(group => {
            const applyBtn = group.querySelector('.apply-filter');
            const clearBtn = group.querySelector('.clear-filter');
            const filterOptionsContainer = group.querySelector('.filter-options');
            const categoryName = self.getCategoryName(group);

            applyBtn.onclick = function () {
                const newSelections = [];

                if (['category', 'severity', 'source'].includes(categoryName)) {
                    filterOptionsContainer.querySelectorAll('input[type="checkbox"]:checked').forEach(checkbox => {
                        newSelections.push(checkbox.value);
                    });
                } else if (categoryName === 'date') {
                    const minDateInput = filterOptionsContainer.querySelector('input[name="date-min"]');
                    const maxDateInput = filterOptionsContainer.querySelector('input[name="date-max"]');
                    const minDate = minDateInput.value;
                    const maxDate = maxDateInput.value;

                    if (minDate || maxDate) {
                        if (minDate && maxDate && new Date(minDate) > new Date(maxDate)) {
                            alert("Start date cannot be after end date.");
                            return;
                        }

                        const formatToDDMMYY = (dateStr) => {
                            if (!dateStr) return '';
                            const [yyyy, mm, dd] = dateStr.split("-");
                            const yy = yyyy.slice(2);
                            return `${dd}-${mm}-${yy}`;
                        };

                        const fromDate = formatToDDMMYY(minDate);
                        const toDate = formatToDDMMYY(maxDate);

                        newSelections.push(`From:${fromDate}`, `To:${toDate}`);
                    }
                }

                self.selectedFilters[categoryName] = newSelections;

                // update Source section if Category changed
                if (categoryName === 'category') {
                    const sourceOptionsDiv = document.getElementById('source-options');
                    sourceOptionsDiv.innerHTML = '';

                    if (newSelections.length === 0) {
                        // Show all sources
                        Object.entries(self.sourceData).forEach(([key, count]) => {
                            sourceOptionsDiv.innerHTML += `
                            <label>
                                <input type="checkbox" name="source" value="${key}"> ${key}
                                <span class="filter-option-count">(${count})</span>
                            </label>`;
                        });
                    } else {
                        // Show only sources mapped to selected categories
                        let combinedSources = [];
                        newSelections.forEach(cat => {
                            const mapped = self.categorySourceMap[cat] || [];
                            combinedSources.push(...mapped);
                        });
                        const uniqueSources = [...new Set(combinedSources)];

                        uniqueSources.forEach(sourceKey => {
                            const count = self.sourceData[sourceKey];
                            if (count !== undefined) {
                                sourceOptionsDiv.innerHTML += `
                                <label>
                                    <input type="checkbox" name="source" value="${sourceKey}"> ${sourceKey}
                                    <span class="filter-option-count">(${count})</span>
                                </label>`;
                            }
                        });
                    }
                }

                self.updateHeaderCounts();
                document.querySelectorAll("th.sortable").forEach(th => {
                    th.classList.remove("sorted-asc", "sorted-desc")
                });
                self.sendFilterData(newSelections, categoryName, '1');
                group.querySelector('.filter-header').click();
                $('#filterPanel').removeClass('open');
                $('#overlay').removeClass('active');
            };

            clearBtn.onclick = function () {
                if (['category', 'severity', 'source'].includes(categoryName)) {
                    filterOptionsContainer.querySelectorAll('input[type="checkbox"]').forEach(input => {
                        input.checked = false;
                    });
                } else if (categoryName === 'date') {
                    document.getElementById('date-min').value = self.defaultMinDate;
                    document.getElementById('date-max').value = self.defaultMaxDate;
                }

                self.selectedFilters[categoryName] = [];

                // Reset Source list when Category is cleared
                if (categoryName === 'category') {
                    const sourceOptionsDiv = document.getElementById('source-options');
                    sourceOptionsDiv.innerHTML = '';
                    Object.entries(self.sourceData).forEach(([key, count]) => {
                        sourceOptionsDiv.innerHTML += `
                        <label>
                            <input type="checkbox" name="source" value="${key}"> ${key}
                            <span class="filter-option-count">(${count})</span>
                        </label>`;
                    });
                }

                self.updateHeaderCounts();
                group.querySelector('.filter-header').click();
            };
        });
    },

    getCategoryName: function (groupElement) {


        // Select the first input/select that is NOT inside the search box
        const inputElement = groupElement.querySelector(
            '.filter-content input:not(.filter-search-box input), .filter-content select'
        );


        if (!inputElement) return null;

        const nameAttr = inputElement.name;
        if (nameAttr) {
            if (nameAttr.startsWith('date')) return 'date';
            return nameAttr;
        }
        return null;
    },

    updateHeaderCounts: function () {
        var self = this;
        document.querySelectorAll('.filter-group').forEach(group => {
            const categoryName = self.getCategoryName(group);

            var count = '';
            if (categoryName === 'date') {
                count = self.selectedFilters[categoryName]?.length - 1 || 0;
            } else {
                count = self.selectedFilters[categoryName]?.length || 0;
            }
            const headerCountSpan = group.querySelector('.selected-count');
            if (headerCountSpan) {
                headerCountSpan.textContent = count > 0 ? `${count}` : '0';
            }
        });
    },


    LogsDataRender: function (jsonData) {
        var self = this;
        const tbody = document.getElementById("logBody");

        self.currentLogs = [...jsonData.logdata];
        self.loginfo = {
            startOffset: jsonData.loginfo.startOffset,
            pageLimit: jsonData.loginfo.pageLimit,
            totalEntries: jsonData.loginfo.totalEntries
        };




        const globalStartIndex = (self.currentPage - 1) * self.itemsPerPage;
        const localSliceStart = globalStartIndex - self.loginfo.startOffset;
        const localSliceEnd = localSliceStart + self.itemsPerPage;
        const logsToRender = self.currentLogs.slice(localSliceStart, localSliceEnd);


        if (logsToRender.length > 0) {
            tbody.innerHTML = '';

            logsToRender.forEach(log => {
                const [datePart, timePart] = log.date.split(' ');
                const tr = document.createElement("tr");
                tr.innerHTML = `
                <td data-label="Date:">${datePart}<br><span style="color:#888;">${timePart}</span></td>
                <td data-label="Category:">${log.category}</td>
                <td data-label="Source:">${log.source}</td>
                <td data-label="Severity:">${log.severity}</td>
                <td data-label="Message:" class="log-message">${log.log_message}</td>
            `;
                tbody.appendChild(tr);
            });
        } else {
            tbody.innerHTML = '';
            tbody.innerHTML = `
    <tr>
        <td colspan="5" 
            style="
                text-align:center; 
                color:#555;  
                font-size:15px; 
                font-weight:500; 
                padding:40px; 
                background-color:#f9f9f9;
                border:1px solid #ddd;
            ">
            <i class="fas fa-info-circle" style="color:#007bff; margin-right:6px; font-size:16px;"></i>
            No Logs to Render
        </td>
    </tr>
`;



            // alert('No Logs to Render')

        }

        self.totallogs = self.loginfo.totalEntries;
        renderPaginationControls(self.totallogs);
    },

    sendFilterData: function (p1, p2, section) {
        var self = this;
        let params = window.location.href;
        let BaseURL = new URL(params).origin;
        let POSTData = [{}];


        if (section === "1") {
            // Filter section
            POSTData = [{
                Offset: 0,
                pageLimit: 50,
                selected_date: p1,
                Category_type: p2
            }];
            self.currentPage = 1;
        } else if (section === "2") {
            // Next button
            POSTData = [{
                Offset: p1,
                pageLimit: p2,
                btn_action: "Next"
            }];
        } else if (section === "3") {
            // Sorting
            POSTData = [{
                sortField: p1,
                sortOrder: p2
            }];
        } else if (section === "4") {
            // Clear filter
            POSTData = [{
                Offset: 0,
                pageLimit: 50,
                selected_date: p1,
                Category_type: p2
            }];
        } else if (section === "5") {
            // Previous button
            POSTData = [{
                Offset: p1,
                pageLimit: p2,
                btn_action: "Previous"
            }];
        }

        const loader = document.getElementById("dataLoader");
        const isSorting = (section === "3");

        if (isSorting) {
            loader.style.display = "flex";
        }
        fetch(`${BaseURL}:30000/Filter_sort_pag_Logs/logs`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(POSTData)
        }).then(response => response.json())
            .then(jsonData => {
                self.LogsDataRender(jsonData);
                if (isSorting) {
                    loader.style.display = "none";
                }
            })
            .catch(error => {

            });
    },



    mainDataRender: function () {
        var self = this;
        let params = window.location.href;
        let BaseURL = new URL(params).origin;
        const loader = document.getElementById("dataLoader");
        loader.style.display = "flex";
        document.querySelector('.pagecontent').style.display = 'none';

        fetch(`${BaseURL}:30000/ALLlogs/logs`)
            // fetch(`https://mocki.io/v1/db9e3ce2-a1c3-44e5-9c56-7101a53706fa`)
            .then(response => {
                if (!response.ok) throw new Error("Network response was not ok");
                return response.json();
            })
            .then(jsonData => {
                self.LogsDataRender(jsonData);
                document.querySelector('.pagecontent').style.display = 'block';
                loader.style.display = "none";
            })
    },

    downloadData: function () {
        var self = this;
        var Data = self.c;
        const DownloadOptions = document.getElementById('downloadoptions');
        if (!DownloadOptions) {

            return;
        }
        DownloadOptions.innerHTML = '';

        let categorydataHTML = `
                        <div class="row">
                            <div class="col-md-7">
                            <div class="form-group">
                                <select name="category" id="categorySelect" class="form-control">
                                <option value="">Please Select Category</option>
                        `;
        Object.keys(Data).forEach((key) => {
            categorydataHTML += `<option value="${key}">${key}</option>`;
        });

        categorydataHTML += `
                        </select>
                    </div>
                    </div>
                </div>
                `;
        DownloadOptions.innerHTML = categorydataHTML;
    },






    downloadLogsAsPDF: function (rv) {

        let BaseURL = new URL(window.location.href).origin;
        const loader = document.getElementById("pdfLoader");
        const download_btn = document.getElementById("logs_download");
        loader.style.display = "flex";
        download_btn.disabled = true;
        $('#exampleModal').modal('hide');
        fetch(`${BaseURL}:30000/Downloadlogs/${rv}`)
            .then(response => {
                if (!response.ok) {
                    throw new Error("Network response was not ok");
                }
                return response.json();
            })
            .then(data => {
                const logData = data.logdata || [];
                const { jsPDF } = window.jspdf;
                const doc = new jsPDF();

                const pageWidth = doc.internal.pageSize.getWidth();
                const pageHeight = doc.internal.pageSize.getHeight();
                const margin = 10;
                const footerHeight = 12; // Reserve footer space

                const now = new Date();
                const date = now.toLocaleDateString('en-GB'); // DD/MM/YYYY
                const time = now.toLocaleTimeString('en-GB', {
                    hour: '2-digit',
                    minute: '2-digit',
                    second: '2-digit',
                    hour12: true
                });
                const dateTime = `${date} ${time} `;

                const tableHeaders = ["Date", "Category", "Severity", "Source", "Message"];
                const tableRows = logData.map(log => [
                    log.date,
                    log.category,
                    log.severity,
                    log.source,
                    log.message || log.log_message || ""
                ]);

                // Draw outer border
                const drawPageBorder = () => {
                    doc.setDrawColor(180);
                    doc.rect(margin, margin, pageWidth - 2 * margin, pageHeight - 2 * margin);
                };

                // Draw main header (first page only)
                const drawMainHeader = () => {
                    doc.setFillColor(17, 77, 115); // Blue
                    doc.rect(margin, margin, pageWidth - 2 * margin, 18, 'F');

                    doc.setTextColor(255);
                    doc.setFont("helvetica", "bold");
                    doc.setFontSize(14);
                    const title = "Logs Management Report";
                    const titleWidth = doc.getTextWidth(title);
                    doc.text(title, (pageWidth - titleWidth) / 2, margin + 7);

                    // DateTime at top-right
                    doc.setFontSize(10);
                    doc.setFont("helvetica", "normal");
                    doc.text(`Date: ${dateTime} `, pageWidth - margin - 50, margin + 13);

                    // Bottom border under header
                    doc.setDrawColor(220);
                    doc.line(margin, margin + 18, pageWidth - margin, margin + 18);
                };

                // Table section starts after header
                const startTableY = margin + 20;

                doc.autoTable({
                    startY: startTableY,  // This is enough
                    head: [tableHeaders],
                    body: tableRows,
                    styles: { fontSize: 8, cellPadding: 2 },
                    headStyles: { fillColor: [17, 77, 115], textColor: 255 },
                    columnStyles: { 5: { cellWidth: 80 } },
                    margin: { left: margin, right: margin, bottom: margin + footerHeight }, // ✅ NO top margin
                    didDrawPage: function (data) {
                        const pageNumber = doc.internal.getCurrentPageInfo().pageNumber;


                        drawPageBorder();

                        // Header only on first page
                        if (pageNumber === 1) {
                            drawMainHeader();
                        }

                        // Footer with margin padding
                        const footerY = pageHeight - margin - 4;
                        doc.setFontSize(9);
                        doc.setTextColor(100);
                        doc.setFont("helvetica", "normal");
                        // doc.text("Invendis Technologies India Pvt. Ltd", margin + 2, footerY);
                        doc.text(`Page ${pageNumber} of ${doc.internal.getNumberOfPages()} `, pageWidth - margin - 35, footerY);
                    }
                });

                const safeFileName = `Router_Logs_Report_${date.replace(/\//g, "-")}_${time.replace(/[: ]/g, "")}.pdf`;
                doc.save(safeFileName);
                loader.style.display = "none";
                download_btn.disabled = false;

            })
            .catch(error => {

            });

    },


    execute: function () {

        var self = this;
        self.selectedFilters = {}
        self.sourceData = {}
        self.categorySourceMap = {}
        self.defaultMinDate = ''
        self.defaultMaxDate = ''
        let sortColumn = null;
        let sortDirection = null;
        self.currentPage = 1;
        self.itemsPerPage = 10;


        self.handleFilters()
        self.mainDataRender();

        const filterHeaders = document.querySelectorAll('.filter-header');
        const clearAllFiltersBtn = document.querySelector('.clear-all-filters');
        const itemsPerPageSelect = document.getElementById("itemsPerPage");
        const prevPageBtn = document.getElementById("prevPageBtn");
        const nextPageBtn = document.getElementById("nextPageBtn");
        const pageInfoSpan = document.getElementById("pageInfo");
        const pageNumberSpan = document.getElementById("pageNumber")


        renderPaginationControls = function (totalLogsCount) {





            const startIndex = ((self.currentPage - 1) * self.itemsPerPage) + 1;

            const endIndex = Math.min(startIndex + self.itemsPerPage - 1, totalLogsCount);



            if (totalLogsCount === 0) {
                pageInfoSpan.textContent = "No logs to display.";
            } else {
                pageInfoSpan.textContent = `Showing ${startIndex} -${endIndex} of ${totalLogsCount} `;

            }

            const totalPages = Math.ceil(totalLogsCount / self.itemsPerPage);


            pageNumberSpan.textContent = `Page ${self.currentPage} of ${totalPages} `;
            prevPageBtn.disabled = self.currentPage === 1;
            nextPageBtn.disabled = self.currentPage === totalPages || totalLogsCount === 0;

            // Ensure self.itemsPerPage select box reflects current value
            itemsPerPageSelect.value = self.itemsPerPage;
        }



        updateIcons = function (activeKey) {
            document.querySelectorAll("th.sortable").forEach(th => {
                th.classList.remove("sorted-asc", "sorted-desc");
                if (th.dataset.key === activeKey && sortDirection !== null) {
                    th.classList.add(sortDirection === 'asc' ? 'sorted-asc' : 'sorted-desc');
                }
            });
        }



        goToPage = function (page) {
            self.currentPage = page;

            const slicedData = {
                logdata: self.currentLogs,
                loginfo: self.loginfo
            };
            self.LogsDataRender(slicedData);
        }




        // 1. Toggle Filter Panels (Accordion functionality)
        filterHeaders.forEach(header => {
            header.addEventListener('click', () => {
                const content = document.getElementById(header.getAttribute('aria-controls'));
                const isExpanded = header.getAttribute('aria-expanded') === 'true';

                filterHeaders.forEach(otherHeader => {
                    if (otherHeader !== header && otherHeader.getAttribute('aria-expanded') === 'true') {
                        const otherContent = document.getElementById(otherHeader.getAttribute('aria-controls'));
                        otherHeader.setAttribute('aria-expanded', 'false');
                        otherContent.setAttribute('aria-hidden', 'true');
                        otherContent.classList.remove('expanded');
                    }
                });

                header.setAttribute('aria-expanded', !isExpanded);
                content.setAttribute('aria-hidden', isExpanded);
                content.classList.toggle('expanded', !isExpanded);
            });
        });


        // Clear All Filters
        clearAllFiltersBtn.addEventListener('click', () => {
            const self = this;

            // Reset selected filters
            for (const category in self.selectedFilters) {
                self.selectedFilters[category] = [];
            }


            document.querySelectorAll('.filter-options input[type="checkbox"]').forEach(input => {
                input.checked = false;
            });


            document.getElementById('date-min').value = self.defaultMinDate;
            document.getElementById('date-max').value = self.defaultMaxDate;

            // Reset Source section manually (same logic as in clearBtn)
            const sourceOptionsDiv = document.getElementById('source-options');
            sourceOptionsDiv.innerHTML = '';
            Object.entries(self.sourceData).forEach(([key, count]) => {
                sourceOptionsDiv.innerHTML += `
            < label >
            <input type="checkbox" name="source" value="${key}"> ${key}
                <span class="filter-option-count">(${count})</span>
            </label>`;
            });
            self.updateHeaderCounts?.();
            self.sendFilterData?.([], 'clearAll', '4');
            $('#filterPanel').removeClass('open');
            $('#overlay').removeClass('active');

        });






        document.querySelectorAll("th.sortable").forEach(th => {
            th.addEventListener("click", () => {
                const key = th.dataset.key;

                if (sortColumn === key) {
                    // Cycle through asc → desc → null
                    if (sortDirection === 'asc') {
                        sortDirection = 'desc';
                    } else if (sortDirection === 'desc') {
                        sortDirection = null;
                    } else {
                        sortDirection = 'asc';
                    }
                } else {
                    // New column clicked, start with ascending
                    sortColumn = key;
                    sortDirection = 'asc';
                }



                updateIcons(key);
                self.sendFilterData(key, sortDirection, '3');

            });
        });

        $('#nextPageBtn').click(function () {

            const targetPage = self.currentPage + 1;

            const startIndex = (targetPage - 1) * self.itemsPerPage;

            const batchStart = self.loginfo.startOffset;

            const batchEnd = batchStart + self.loginfo.pageLimit;


            if (startIndex >= batchEnd) {
                const newOffset = batchStart + self.loginfo.pageLimit;
                self.currentPage = targetPage;
                self.loginfo.startOffset = newOffset;
                self.sendFilterData(Number(newOffset), self.loginfo.pageLimit, '2'); // Fetch next batch
                return;
            }

            goToPage(targetPage);
        });

        $('#prevPageBtn').click(function () {
            const targetPage = self.currentPage - 1;
            if (targetPage >= 1) {
                const startIndex = (targetPage - 1) * self.itemsPerPage;
                const batchStart = self.loginfo.startOffset;

                if (startIndex < batchStart) {
                    const newOffset = batchStart - self.loginfo.pageLimit;
                    self.currentPage = targetPage;
                    self.loginfo.startOffset = newOffset;
                    self.sendFilterData(Number(newOffset), self.loginfo.pageLimit, '5'); // Fetch previous batch
                    return;
                }

                goToPage(targetPage);
            }
        });



        itemsPerPageSelect.addEventListener("change", (event) => {
            self.itemsPerPage = parseInt(event.target.value);
            self.currentPage = 1;
            const slicedData = {
                logdata: self.currentLogs,
                loginfo: self.loginfo
            };
            self.LogsDataRender(slicedData);
        });




        $('#filterToggleButton').on('click', function () {
            $('#filterPanel').addClass('open');
            $('#overlay').addClass('active');
        });

        $('#filterCloseButton').on('click', function () {
            $('#filterPanel').removeClass('open');
            $('#overlay').removeClass('active');
        });

        $('#overlay').on('click', function () {
            $('#filterPanel').removeClass('open');
            $('#overlay').removeClass('active');
        });
        $('#logs_download').click(function () {
            self.downloadData()
        })

        $('#submit_data').click(function () {
            var downalod_Data = document.getElementById('categorySelect').value;
            self.downloadLogsAsPDF(downalod_Data)

        })


    }
});

