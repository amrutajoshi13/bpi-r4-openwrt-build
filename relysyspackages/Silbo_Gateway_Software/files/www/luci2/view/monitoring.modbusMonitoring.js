L.ui.view.extend({

	devices: [],
	registers: [],
	filtered: [],
	currentPage: 1,
	entriesPerPage: 10,
	currentDevice: null,

	cacheDOM: function () {
		const self = this;
		self.deviceSelect = document.getElementById("deviceSelect");
		self.registerBody = document.getElementById("registerBody");
		self.summaryDiv = document.getElementById("summary");
		self.searchInput = document.getElementById("search");
		self.entriesDropdown = document.getElementById("entriesPerPage");
		self.prevBtn = document.getElementById("prevBtn");
		self.nextBtn = document.getElementById("nextBtn");
		self.pageInfo = document.getElementById("pageInfo");
		self.entryInfo = document.getElementById("entryInfo");
	},

	bindEvents: function () {
		const self = this;
		self.deviceSelect.addEventListener("change", self.onDeviceChange.bind(self));
		self.searchInput.addEventListener("input", self.applyFilter.bind(self));
		self.entriesDropdown.addEventListener("change", self.changeEntries.bind(self));
		self.prevBtn.addEventListener("click", self.prevPage.bind(self));
		self.nextBtn.addEventListener("click", self.nextPage.bind(self));

		// document.getElementById("downloadPDF").addEventListener("click", self.downloadPDF.bind(self));
	},

	/* ================= API CALLS ================= */

	loadDevices: function () {
		const self = this;
		let params = window.location.href;
		let BaseURL = new URL(params).origin;
		// fetch("https://mocki.io/v1/c471d3fb-2522-4da3-8ccb-13abc0cdcd75")
		fetch(`${BaseURL}:30006/Get_Available_Meters_Data/`)
			.then(res => res.json())
			.then(data => {

				const noOfDevices = parseInt(data.NoOfDevices);
				if (noOfDevices === 0) {
					L.ui.showNoConfigMessage("Modbus Devices", "No-ModbusData");
					const pdfBtn = document.getElementById('downloadPDF');
					const dataSection = document.getElementById('renderdatasection');

					if (pdfBtn) pdfBtn.style.display = 'none';
					if (dataSection) dataSection.style.display = 'none';
				} else {
					self.devices = Object.values(data.Devices);
					self.populateDeviceDropdown();
				}
			});
	},

	// loadRegisters: function (deviceName) {
	// 	const self = this;

	// 	// visual feedback so you KNOW it is fetching
	// 	self.summaryDiv.innerHTML = "Loading device data...";
	// 	self.registerBody.innerHTML = "";
	// 	console.log("Fetching data for:", deviceName);

	// 	fetch("https://mocki.io/v1/4078c395-7075-45ec-9e38-4f8c48a09746")
	// 		.then(res => res.json())
	// 		.then(data => {
	// 			// backend returns ONLY ONE device
	// 			const dev = Object.values(data)[0];

	// 			if (!dev) {
	// 				console.warn("No device data received from backend");
	// 				return;
	// 			}

	// 			self.currentDevice = dev;
	// 			self.registers = Object.entries(dev.Data).map(([name, value]) => ({
	// 				name,
	// 				value
	// 			}));

	// 			self.updateSummary(deviceName); // deviceName is ONLY for label
	// 			self.applyFilter();
	// 		})
	// 		.catch(err => {
	// 			console.error("Failed to fetch registers:", err);
	// 			self.summaryDiv.innerHTML = "Failed to load device data";
	// 		});
	// },
	loadRegisters: function (deviceName) {
		const self = this;
		let params = window.location.href;
		let BaseURL = new URL(params).origin;
		self.summaryDiv.innerHTML = "Loading device data...";
		self.registerBody.innerHTML = "";


		// const url = `https://mocki.io/v1/6d0fcb51-51f6-4505-84a6-236fcd778a70`;
		const url = `${BaseURL}:30005/Get_Selected_Register_Data/${deviceName}`;

		fetch(url)
			.then(res => res.json())
			.then(data => {
				const dev = Object.values(data)[0];

				if (!dev) {
					self.showNoData(deviceName);
					return;
				}

				self.currentDevice = dev;
				self.registers = Object.entries(dev.Data).map(([name, value]) => ({
					name,
					value
				}));

				self.updateSummary(deviceName);
				self.applyFilter();
			})
			.catch(err => {
				console.error("Failed to fetch registers:", err);
				self.showNoData(deviceName);
			});
	},

	showNoData: function (deviceName) {
		const self = this;

		self.currentDevice = null;
		self.registers = [];
		self.filtered = [];

		self.summaryDiv.style.borderLeftColor = "#dc2626";
		self.summaryDiv.innerHTML = `
        <span class="device-name">${deviceName}</span>
        <span class="status-pill status-bad">No data available</span>
    `;

		self.renderTable();
	},

	/* ================= UI ================= */

	populateDeviceDropdown: function () {
		const self = this;
		self.deviceSelect.innerHTML = "";
		self.devices.forEach(dev => {
			self.deviceSelect.innerHTML += `<option value="${dev}">${dev}</option>`;
		});

		if (self.devices.length) {
			self.loadRegisters(self.devices[0]);
		}
	},

	updateSummary: function (deviceName) {
		const self = this;

		const status = self.currentDevice.Status || 'Unknown';
		const isOk = status.toLowerCase() === 'responding';

		// Apply BOTH classes (this is the key fix)
		self.summaryDiv.className = 'context-header context-bar';

		self.summaryDiv.innerHTML = `
        <div class="context-left">
            <span class="ctx-label">Device:</span>
            <span class="ctx-value">${deviceName}</span>

            <span class="ctx-label">Status:</span>
            <span class="ctx-status ${isOk ? 'ok' : 'bad'}">
                <span class="ctx-dot"></span>
                ${status}
            </span>
        </div>

        <div class="context-right">
            <span class="ctx-label">Slave ID:</span>
            <span class="ctx-value">${self.currentDevice.SlaveId}</span>
        </div>
    `;
	},






	applyFilter: function () {
		const self = this;
		const q = self.searchInput.value.toLowerCase();
		self.filtered = self.registers.filter(r =>
			r.name.toLowerCase().includes(q)
		);

		self.currentPage = 1;
		self.renderTable();
	},

	renderTable: function () {
		const self = this;
		self.registerBody.innerHTML = "";

		const start = (self.currentPage - 1) * self.entriesPerPage;
		const pageItems = self.filtered.slice(start, start + self.entriesPerPage);

		pageItems.forEach(r => {
			self.registerBody.innerHTML +=
				`<tr><td>${r.name}</td><td>${r.value}</td></tr>`;
		});

		const end = Math.min(start + self.entriesPerPage, self.filtered.length);
		self.entryInfo.textContent =
			`Showing ${self.filtered.length ? start + 1 : 0} to ${end} of ${self.filtered.length}`;

		const totalPages = Math.max(1, Math.ceil(self.filtered.length / self.entriesPerPage));
		self.pageInfo.textContent = `Page ${self.currentPage} of ${totalPages}`;

		self.prevBtn.disabled = self.currentPage === 1;
		self.nextBtn.disabled = self.currentPage === totalPages;
	},

	/* ================= EVENTS ================= */

	onDeviceChange: function () {
		const self = this;
		self.searchInput.value = "";
		self.currentPage = 1;
		self.loadRegisters(self.deviceSelect.value);
	},

	changeEntries: function () {
		const self = this;
		self.entriesPerPage = +self.entriesDropdown.value;
		self.currentPage = 1;
		self.renderTable();
	},

	prevPage: function () {
		const self = this;
		if (self.currentPage > 1) {
			self.currentPage--;
			self.renderTable();
		}
	},

	nextPage: function () {
		const self = this;
		const totalPages = Math.ceil(self.filtered.length / self.entriesPerPage);
		if (self.currentPage < totalPages) {
			self.currentPage++;
			self.renderTable();
		}
	},
	downloadPDF: function () {
		const self = this;
		const { jsPDF } = window.jspdf;
		const doc = new jsPDF();

		/* ---------- HEADER ---------- */
		doc.setFontSize(16);
		doc.text("Modbus Monitoring", 10, 15);

		doc.setFontSize(11);
		doc.text(`Device: ${self.deviceSelect.value}`, 10, 25);
		doc.text(`Status: ${self.currentDevice.Status}`, 10, 32);
		doc.text(`Slave ID: ${self.currentDevice.SlaveId}`, 10, 39);

		/* ---------- TABLE DATA ---------- */
		const tableBody = self.filtered.map(r => [r.name, r.value]);

		doc.autoTable({
			head: [["Name", "Value"]],
			body: tableBody,
			startY: 45,
			theme: "grid",
			styles: {
				fontSize: 10,
				halign: "center"
			},
			headStyles: {
				fillColor: [21, 90, 135] // matches your UI blue
			},
			columnStyles: {
				0: { halign: "left" }
			},
			didDrawPage: function (data) {
				/* ---------- FOOTER ---------- */
				const pageHeight = doc.internal.pageSize.height;
				doc.setFontSize(9);
				doc.setTextColor(150);
				doc.text(
					"Invendis Technologies India Pvt. Ltd",
					10,
					pageHeight - 10
				);
			}
		});

		/* ---------- FILE NAME ---------- */
		const fileName = `${self.deviceSelect.value}_Modbus_Monitoring.pdf`;
		doc.save(fileName);
	},

	execute: function () {
		const self = this;
		self.cacheDOM();
		self.bindEvents();
		self.loadDevices();
		$('#downloadPDF').click(function () {
			self.downloadPDF()
		})
	}
});
