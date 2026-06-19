L.ui.view.extend({
	configRoutes: {
		modbus: 'monitoring/modbusMonitoring',
		snmp: 'configuration/snmpMasterConfig',
		bacnet: 'configuration/BACnetconfiguration'
	},

	openConfigPage: function (type) {
		const route = this.configRoutes[type];

		if (!route) {
			console.warn('No route for:', type);
			return;
		}

		let params = window.location.href;
		let base = params.split(",")[0];

		let link = base + `,view:${route}`;
		window.open(link, "_self");
	},

	startLoading: function (cardId) {
		const card = document.getElementById(cardId);
		if (!card) return;
		card.classList.add('loading');
		card.classList.remove('error', 'flash');
	},

	stopLoading: function (cardId, success = true) {
		const card = document.getElementById(cardId);
		if (!card) return;
		card.classList.remove('loading');
		if (success) {
			card.classList.add('flash');
			setTimeout(() => card.classList.remove('flash'), 700);
		}
	},

	showError: function (containerId, message = 'Unable to load data') {
		const el = document.getElementById(containerId);
		if (!el) return;
		el.innerHTML = `<div class="card-center-message">${message}</div>`;
	},

	serviceStatusInfo: function () {
		const self = this;
		let params = window.location.href;
		let BaseURL = new URL(params).origin;
		self.startLoading('serviceStatusCard');

		fetch(`${BaseURL}:30005/device/applications/`)
			.then(res => res.json())
			.then(data => {
				const list = document.getElementById('serviceStatusList');
				if (!list) return;
				list.innerHTML = '';

				if (self.isEmptyPayload(data)) {
					self.showError('serviceStatusList', 'No service data');
					self.stopLoading('serviceStatusCard', false);
					return;
				}

				self.showCard('serviceStatusCard');

				data.forEach(item => {
					const isRunning = item.state === 'running';

					const row = document.createElement('div');
					row.className = `service-row ${isRunning ? 'service-running' : 'service-disabled'
						}`;

					const name = document.createElement('div');
					name.className = 'service-name';

					// mapping applied here
					name.textContent = item.name;
					// name.textContent = rename[item.name] || item.name;

					const state = document.createElement('div');
					state.className = `service-state ${isRunning ? 'service-running' : 'service-disabled'}`;

					state.innerHTML = `<span class="service-dot"></span>`;


					row.appendChild(name);
					row.appendChild(state);
					list.appendChild(row);
				});
				self.adjustTopRowLayout();
				self.stopLoading('serviceStatusCard', true);
			})
			.catch(err => {
				console.error('Service status error:', err);
				self.showError('serviceStatusList', 'Unable to load service status');
				self.stopLoading('serviceStatusCard', false);
			});
	},


	diInfo: function () {
		let params = window.location.href;
		let BaseURL = new URL(params).origin;
		const self = this;
		self.startLoading('digitalio_card');

		fetch(`${BaseURL}:30005/dashboard_DIO/`)
			.then(res => res.json())
			.then(data => {
				// detect array shapes
				let DIData = [];
				if (Array.isArray(data.DIpins)) DIData = data.DIpins;
				else if (data.DIOStatus && Array.isArray(data.DIOStatus.Pins)) DIData = data.DIOStatus.Pins;
				else if (Array.isArray(data.Pins)) DIData = data.Pins;
				else {
					const arr = Object.values(data).find(v => Array.isArray(v));
					if (arr) DIData = arr;
				}

				const dashboard = document.getElementById('digitalinput');
				if (!dashboard) return;
				dashboard.innerHTML = '';

				const pins = data?.DIOStatus?.Pins;

				if (self.isEmptyPayload(pins)) {
					self.hideCard('digitalio_card');
					self.adjustTopRowLayout();
					self.stopLoading('digitalio_card', false);
					return;
				}


				self.showCard('digitalio_card');


				const lastProduced = document.getElementById('lastProduced');
				const lastSent = document.getElementById('lastSent');

				const producedVal = data?.DIOStatus?.LastDataProducedTime || "N/A";
				const sentVal = data?.DIOStatus?.LastDataSentTime || "N/A";

				lastProduced.textContent = "Last Produced: " + producedVal;
				lastSent.textContent = "Last Sent: " + sentVal;

				if (data.DIOStatus) {
					lastProduced.textContent = "Last Produced: " + data.DIOStatus.LastDataProducedTime;
					lastSent.textContent = "Last Sent: " + data.DIOStatus.LastDataSentTime;
				}


				DIData.forEach((di, index) => {
					let rawValue = (di.value ?? di.status ?? di.state ?? "N/A")
						.toString().trim().toUpperCase();
					let statusClass = "not"; // default gray
					if (rawValue === "ON" || rawValue === "1" || rawValue === "TRUE") statusClass = "on";
					else if (rawValue === "OFF" || rawValue === "0" || rawValue === "FALSE") statusClass = "off";
					else statusClass = "not"; // for N/A, null, empty, undefined


					// create element using your exact class names
					const card = document.createElement('div');
					card.className = `card ${statusClass}`;
					card.textContent = `DIO ${index + 1}`;
					card.setAttribute('data-pin-name', di.pin || di.name || '');
					card.setAttribute('data-pin-state', statusClass);

					dashboard.appendChild(card);
				});

				// Re-apply current active filter if any
				try {
					if (typeof activeFilters !== 'undefined' && activeFilters.di) {
						toggleFilter('di', activeFilters.di);
					}
				} catch (e) { /* ignore */ }
				self.adjustTopRowLayout();

				self.stopLoading('digitalio_card', true);
			})

			.catch(err => {
				console.error('Error fetching DIO:', err);
				self.showError('digitalinput', 'Unable to load digital inputs');
				self.stopLoading('digitalio_card', false);
			});

	},

	aioInfo: function () {
		var self = this;
		let params = window.location.href;
		let BaseURL = new URL(params).origin;
		self.startLoading('analogInput_card');
		fetch(`${BaseURL}:30005/dashboard_AI/`)
			.then(res => res.json())
			.then(data => {
				const A = data?.AnalogValues || data?.Analog || null;

				const lastProducedEl = document.getElementById('analogLastProduced');
				const lastSentEl = document.getElementById('analogLastSent');
				const container = document.getElementById('analoginput');
				if (!container) return;
				container.innerHTML = '';

				// fill meta (show N/A when missing)
				const producedVal = (A && (A.LastDataProducedTime ?? A.LastProduced ?? 'N/A')) || 'N/A';
				const sentVal = (A && (A.LastDataSentTime ?? A.LastSent ?? 'N/A')) || 'N/A';
				if (lastProducedEl) lastProducedEl.textContent = 'Last Produced: ' + producedVal;
				if (lastSentEl) lastSentEl.textContent = 'Last Sent: ' + sentVal;

				//  EMPTY PAYLOAD → hide card
				if (self.isEmptyPayload(A)) {
					self.hideCard('analogInput_card');
					self.adjustTopRowLayout();
					self.stopLoading('analogInput_card', false);
					return;
				}



				const reserved = new Set([
					'LastDataProducedTime',
					'LastDataSentTime',
					'LastProduced',
					'LastSent',
					'lastProduced',
					'lastSent'
				]);

				const entries = Object.entries(A).filter(([k]) => !reserved.has(k));

				if (entries.length === 0) {
					self.hideCard('analogInput_card');
					self.adjustTopRowLayout();
					self.stopLoading('analogInput_card', false);
					return;
				}


				// DATA EXISTS
				self.showCard('analogInput_card');
				self.adjustTopRowLayout();

				entries.forEach(([key, val]) => {
					const raw =
						val === null ||
							val === undefined ||
							val === '' ||
							String(val).toUpperCase() === 'NA'
							? 'N/A'
							: String(val);

					const tile = document.createElement('div');
					tile.className = 'analog-card';

					const label = document.createElement('div');
					label.className = 'analog-label';
					label.textContent = key.replace(/_/g, ' ');

					const value = document.createElement('div');
					value.className = 'analog-value';
					value.textContent = raw;

					tile.appendChild(label);
					tile.appendChild(value);
					container.appendChild(tile);
				});
				self.adjustTopRowLayout();

				self.stopLoading('analogInput_card', true);
			})
			.catch(err => {
				self.showCard('analogInput_card');
				self.showError('analoginput', 'Unable to load analog inputs');
				self.stopLoading('analogInput_card', false);
			});

	},

	// === SNMP table renderer - paste after aioInfo / diInfo functions ===
	renderSNMPTable: function (snmpJson) {
		const infoArr = Array.isArray(snmpJson.SNMPInfo) ? snmpJson.SNMPInfo : (snmpJson.SNMPInfo ? [snmpJson.SNMPInfo] : []);
		const metaObj = infoArr[0] || {};
		// find SNMP object inside the array (or top-level)
		let snmpObj = null;
		for (let i = 0; i < infoArr.length; i++) {
			if (infoArr[i] && infoArr[i].SNMP) { snmpObj = infoArr[i].SNMP; break; }
		}
		if (!snmpObj && snmpJson.SNMP) snmpObj = snmpJson.SNMP;

		const table = document.getElementById('snmpTable');
		const metaWrap = document.getElementById('snmpMeta');
		if (!table) return;

		// inject meta (DO NOT include device count)
		const lastProduced = metaObj.LastDataProducedTime || metaObj.LastProduced || 'N/A';
		const lastSent = metaObj.LastDataSentTime || metaObj.LastSent || 'N/A';

		if (metaWrap) {
			metaWrap.innerHTML = '';
			const lines = [];
			if (lastProduced) lines.push(`<div>Last Produced: ${lastProduced}</div>`);
			if (lastSent) lines.push(`<div>Last Sent: ${lastSent}</div>`);
			metaWrap.innerHTML = lines.join('');
		}

		// build table
		table.innerHTML = '';
		if (!snmpObj || !snmpObj.Headers || !Array.isArray(snmpObj.Data)) {
			table.innerHTML = '<thead><tr><th>Parameter</th><th>No devices</th></tr></thead><tbody><tr><td class="param">No data</td><td>N/A</td></tr></tbody>';
			table.style.minWidth = '600px';
			return;
		}

		const headers = snmpObj.Headers;
		const headerKeys = Object.keys(headers || {});
		const paramKey = headerKeys.find(k => /parameter/i.test(headers[k]) || /parameter/i.test(k)) || headerKeys[0];
		const controllerKeys = headerKeys.filter(k => k !== paramKey);

		// thead
		const thead = document.createElement('thead');
		const htr = document.createElement('tr');
		const thParam = document.createElement('th');
		thParam.textContent = headers[paramKey] || 'Parameter';
		htr.appendChild(thParam);
		controllerKeys.forEach(k => {
			const th = document.createElement('th');
			th.className = 'device';
			th.textContent = headers[k] || k;
			th.style.textAlign = 'center';
			htr.appendChild(th);
		});
		thead.appendChild(htr);
		table.appendChild(thead);

		// tbody
		const tbody = document.createElement('tbody');
		snmpObj.Data.forEach(row => {
			const tr = document.createElement('tr');
			const tdParam = document.createElement('td');
			tdParam.className = 'param';
			tdParam.textContent = row[paramKey] || row.Parameters || '';
			tr.appendChild(tdParam);

			controllerKeys.forEach(k => {
				const td = document.createElement('td');
				const rawVal = row[k] ?? '';
				const valText = (typeof rawVal === 'object') ? JSON.stringify(rawVal) : String(rawVal);
				const cleaned = valText.trim().toLowerCase();

				// robust matching for responding / not responding
				if (cleaned.length) {
					if (cleaned.includes('not') && cleaned.includes('respond')) {
						td.classList.add('snmp-status-not');
					} else if (cleaned.includes('respond')) {
						td.classList.add('snmp-status-responding');
					} else if (cleaned.includes('not responding') || /^not\s*respond(ing)?/.test(cleaned)) {
						td.classList.add('snmp-status-not');
					}
				}

				td.textContent = valText;
				td.style.textAlign = 'center';
				tr.appendChild(td);
			});

			tbody.appendChild(tr);
		});
		table.appendChild(tbody);

		// min width so table scrolls horizontally when many devices exist
		const deviceCount = controllerKeys.length;
		const minWidth = Math.max(640, 180 + (deviceCount * 160));
		table.style.minWidth = minWidth + 'px';
	},
	snmpInfo: function () {
		const self = this;
		let params = window.location.href;
		let BaseURL = new URL(params).origin;
		self.startLoading('snmpCard');
		fetch(`${BaseURL}:30005/dashboard_SNMPInfo`)
		//fetch(`https://mocki.io/v1/32ccb6e9-3c59-4331-95f0-d2eed36661d3`)
			.then(res => res.json())
			.then(data => {
				const infoArr = Array.isArray(data.SNMPInfo) ? data.SNMPInfo : [];
				const snmpObj = infoArr.find(i => i.SNMP)?.SNMP;

				if (!snmpObj || self.isEmptyPayload(snmpObj.Data)) {
					self.hideCard('snmpCard');
					return;
				}

				self.showCard('snmpCard');
				self.renderSNMPTable(data);
				self.stopLoading('snmpCard', true);
			})

			.catch(err => {
				console.error('SNMP fetch error', err);
				self.showError('snmpTable', 'Unable to load SNMP data');
				self.stopLoading('snmpCard', false);
			});
	},


	renderGenericModbusTable: function (json) {
		// json -> { GenericModbusInfo: [...] }
		const infoArr = Array.isArray(json.GenericModbusInfo) ? json.GenericModbusInfo
			: (json.GenericModbusInfo ? [json.GenericModbusInfo] : []);
		const metaObj = infoArr[0] || {};
		// find Modbus object
		let modObj = null;
		for (let i = 0; i < infoArr.length; i++) {
			if (infoArr[i] && infoArr[i].Modbus) { modObj = infoArr[i].Modbus; break; }
		}
		if (!modObj && json.Modbus) modObj = json.Modbus;

		const table = document.getElementById('modbusTable');
		const metaWrap = document.getElementById('modbusMeta');
		if (!table) return;

		// inject meta (only Last Produced / Last Sent)
		const lastProduced = metaObj.LastDataProducedTime || metaObj.LastProduced || 'N/A';
		const lastSent = metaObj.LastDataSentTime || metaObj.LastSent || 'N/A';
		if (metaWrap) {
			metaWrap.innerHTML = '';
			const lines = [];
			if (lastProduced) lines.push(`<div>Last Produced: ${lastProduced}</div>`);
			if (lastSent) lines.push(`<div>Last Sent: ${lastSent}</div>`);
			metaWrap.innerHTML = lines.join('');
		}

		// build table
		table.innerHTML = '';
		if (!modObj || !modObj.Headers || !Array.isArray(modObj.Data)) {
			table.innerHTML = '<thead><tr><th>Parameter</th><th>No devices</th></tr></thead><tbody><tr><td class="param">No data</td><td>N/A</td></tr></tbody>';
			table.style.minWidth = '600px';
			return;
		}

		const headers = modObj.Headers;
		const headerKeys = Object.keys(headers || {});
		const paramKey = headerKeys.find(k => /parameter/i.test(headers[k]) || /parameter/i.test(k)) || headerKeys[0];
		const controllerKeys = headerKeys.filter(k => k !== paramKey);

		// thead
		const thead = document.createElement('thead');
		const htr = document.createElement('tr');
		const thParam = document.createElement('th');
		thParam.textContent = headers[paramKey] || 'Parameter';
		htr.appendChild(thParam);
		controllerKeys.forEach(k => {
			const th = document.createElement('th');
			th.className = 'device';
			th.textContent = headers[k] || k;
			th.style.textAlign = 'center';
			htr.appendChild(th);
		});
		thead.appendChild(htr);
		table.appendChild(thead);

		// tbody
		const tbody = document.createElement('tbody');
		modObj.Data.forEach(row => {
			const tr = document.createElement('tr');
			const tdParam = document.createElement('td');
			tdParam.className = 'param';
			tdParam.textContent = row[paramKey] || row.Parameters || '';
			tr.appendChild(tdParam);

			controllerKeys.forEach(k => {
				const td = document.createElement('td');
				const rawVal = row[k] ?? '';
				const valText = (typeof rawVal === 'object') ? JSON.stringify(rawVal) : String(rawVal);
				const cleaned = valText.trim().toLowerCase();

				// reuse status classes: Responding -> green, Not Responding -> red
				if (cleaned.length) {
					if (cleaned.includes('not') && cleaned.includes('respond')) {
						td.classList.add('snmp-status-not');
					} else if (cleaned.includes('respond')) {
						td.classList.add('snmp-status-responding');
					} else if (cleaned.includes('not responding') || /^not\s*respond(ing)?/.test(cleaned)) {
						td.classList.add('snmp-status-not');
					}
				}

				td.textContent = valText;
				td.style.textAlign = 'center';
				tr.appendChild(td);
			});

			tbody.appendChild(tr);
		});
		table.appendChild(tbody);

		// min width so table scrolls when many devices
		const deviceCount = controllerKeys.length;
		const minWidth = Math.max(640, 180 + (deviceCount * 160));
		table.style.minWidth = minWidth + 'px';
	},

	modbusInfo: function () {
		const self = this;
		let params = window.location.href;
		let BaseURL = new URL(params).origin;
		self.startLoading('modbusCard');
		fetch(`${BaseURL}:30005/dashboard_ModbusInfo/`)
			.then(res => res.json())
			.then(data => {
				const infoArr = Array.isArray(data.GenericModbusInfo)
					? data.GenericModbusInfo
					: [];

				const modbusObj = infoArr.find(i => i.Modbus)?.Modbus;

				if (!modbusObj || self.isEmptyPayload(modbusObj.Data)) {
					self.hideCard('modbusCard');
					return;
				}

				self.showCard('modbusCard');
				self.renderGenericModbusTable(data);
				self.stopLoading('modbusCard', true);
			})

			.catch(err => {
				console.error('Modbus fetch error', err);
				self.showError('modbusTable', 'Unable to load Modbus data');
				self.stopLoading('modbusCard', false);
			});
	},

	renderBACnetTable: function (json) {
		const infoArr = Array.isArray(json.BACNetInfo) ? json.BACNetInfo
			: (json.BACNetInfo ? [json.BACNetInfo] : []);
		const metaObj = infoArr[0] || {};

		// find BACNet object
		let bacObj = null;
		for (let i = 0; i < infoArr.length; i++) {
			if (infoArr[i] && infoArr[i].BACNet) { bacObj = infoArr[i].BACNet; break; }
		}
		if (!bacObj && json.BACNet) bacObj = json.BACNet;

		const table = document.getElementById('bacnetTable');
		const metaWrap = document.getElementById('bacnetMeta');
		if (!table) return;

		// Meta text
		const lastProduced = metaObj.LastDataProducedTime || metaObj.LastProduced || 'N/A';
		const lastSent = metaObj.LastDataSentTime || metaObj.LastSent || 'N/A';

		if (metaWrap) {
			metaWrap.innerHTML = `
            <div>Last Produced: ${lastProduced}</div>
            <div>Last Sent: ${lastSent}</div>
        `;
		}

		// Basic checks
		table.innerHTML = '';
		if (!bacObj || !bacObj.Headers || !Array.isArray(bacObj.Data)) {
			table.innerHTML = `
            <thead><tr><th>Parameter</th><th>No devices</th></tr></thead>
            <tbody><tr><td class="param">No data</td><td>N/A</td></tr></tbody>
        `;
			table.style.minWidth = '600px';
			return;
		}

		const headers = bacObj.Headers;
		const headerKeys = Object.keys(headers || {});
		const paramKey = headerKeys.find(k => /parameter/i.test(headers[k])) || headerKeys[0];
		const controllerKeys = headerKeys.filter(k => k !== paramKey);

		// Build THEAD
		const thead = document.createElement('thead');
		const htr = document.createElement('tr');
		const thParam = document.createElement('th');
		thParam.textContent = headers[paramKey] || 'Parameter';
		htr.appendChild(thParam);

		controllerKeys.forEach(k => {
			const th = document.createElement('th');
			th.textContent = headers[k] || k;
			th.style.textAlign = 'center';
			htr.appendChild(th);
		});

		thead.appendChild(htr);
		table.appendChild(thead);

		// Build TBODY
		const tbody = document.createElement('tbody');
		bacObj.Data.forEach(row => {
			const tr = document.createElement('tr');

			// Parameter cell
			const tdParam = document.createElement('td');
			tdParam.className = 'param';
			tdParam.textContent = row[paramKey] || row.Parameters || '';
			tr.appendChild(tdParam);

			// Device columns
			controllerKeys.forEach(k => {
				const td = document.createElement('td');
				const val = row[k] ?? 'N/A';
				const valText = String(val).trim();
				td.textContent = valText;

				const cleaned = valText.toLowerCase();

				if (cleaned.includes('not') && cleaned.includes('respond')) {
					td.classList.add('snmp-status-not');
				} else if (cleaned.includes('respond')) {
					td.classList.add('snmp-status-responding');
				}

				td.style.textAlign = 'center';
				tr.appendChild(td);
			});

			tbody.appendChild(tr);
		});

		table.appendChild(tbody);

		// Auto resize for many controllers
		const deviceCount = controllerKeys.length;
		const minWidth = Math.max(640, 180 + (deviceCount * 160));
		table.style.minWidth = minWidth + 'px';
	},

	bacnetInfo: function () {
		const self = this;
		let params = window.location.href;
		let BaseURL = new URL(params).origin;
		self.startLoading('bacnetCard');
		fetch(`${BaseURL}:30005/dashboard_BacNetInfo`)
			.then(res => res.json())
			.then(data => {
				const infoArr = Array.isArray(data.BACNetInfo)
					? data.BACNetInfo
					: [];

				const bacObj = infoArr.find(i => i.BACNet)?.BACNet;

				if (!bacObj || self.isEmptyPayload(bacObj.Data)) {
					self.hideCard('bacnetCard');
					return;
				}

				self.showCard('bacnetCard');
				self.renderBACnetTable(data);
				self.stopLoading('bacnetCard', true);
			})

			.catch(err => {
				console.error('BACnet fetch error', err);
				self.showError('bacnetTable', 'Unable to load BACnet data');
				self.stopLoading('bacnetCard', false);
			});
	},
	// ---------- GLOBAL HELPERS ----------

	isEmptyPayload: function (value) {
		if (value == null) return true;
		if (Array.isArray(value)) return value.length === 0;
		if (typeof value === 'object') return Object.keys(value).length === 0;
		return false;
	},

	hideCard: function (cardId) {
		const card = document.getElementById(cardId);
		if (!card) return;
		card.style.display = 'none';
	},

	showCard: function (cardId) {
		const card = document.getElementById(cardId);
		if (!card) return;
		card.style.display = '';
	},

	adjustTopRowLayout: function () {
		const panel = document.getElementById('dashboardPanel');
		if (!panel) return;

		const cards = Array.from(panel.querySelectorAll('.top-card'))
			.filter(c => c.style.display !== 'none');

		// reset
		cards.forEach(c => c.classList.remove('full-row'));

		if (cards.length === 1) {
			panel.style.gridTemplateColumns = '1fr';
			cards[0].classList.add('full-row');
		}
		else if (cards.length === 2) {
			panel.style.gridTemplateColumns = 'repeat(2, 1fr)';
		}
		else {
			panel.style.gridTemplateColumns = 'repeat(3, 1fr)';
		}
	},

	getApplicationsStatus: function () {
		const self = this;
		let params = window.location.href;
		let BaseURL = new URL(params).origin;

		return fetch(`${BaseURL}:30005/AppmanagerConfig/`)
		//return fetch(`https://mocki.io/v1/035fe043-ff0f-4343-8ba9-03e12ebfb330`)
			.then(res => res.json())
			.then(data => {
				self.appFlags = data?.applications || {};
				return self.appFlags;
			})
			.catch(err => {
				console.error('Applications API failed:', err);

				// fallback → show all
				self.appFlags = {
					modbus_enabled: 1,
					rs232_enabled: 1,
					dio_enabled: 1,
					aio_enabled: 1,
					bacnet_enabled: 1,
					snmp_enabled: 1
				};
				return self.appFlags;
			});
	},
	isAppEnabled: function (key) {
		return Number(this.appFlags?.[key]) === 1;
	},

	execute: function () {
		var self = this;
		let activeFilters = { di: null, do: null };
		let activeServiceFilter = null;
		window.activeFilters = activeFilters;

		function loadAll() {
			self.getApplicationsStatus().then(() => {
				//  ALWAYS refresh service status (no gating)
				self.showCard('serviceStatusCard');
				self.serviceStatusInfo();
				// ===== DIO =====
				if (self.isAppEnabled('dio_enabled')) {
					self.showCard('digitalio_card');
					self.diInfo();
				} else {
					self.hideCard('digitalio_card');
				}

				// ===== AIO =====
				if (self.isAppEnabled('aio_enabled')) {
					self.showCard('analogInput_card');
					self.aioInfo();
				} else {
					self.hideCard('analogInput_card');
				}

				// ===== SNMP =====
				if (self.isAppEnabled('snmp_enabled')) {
					self.showCard('snmpCard');
					self.snmpInfo();
				} else {
					self.hideCard('snmpCard');
				}

				// ===== MODBUS =====
				if (self.isAppEnabled('modbus_enabled')) {
					self.showCard('modbusCard');
					self.modbusInfo();
				} else {
					self.hideCard('modbusCard');
				}

				// ===== BACNET =====
				if (self.isAppEnabled('bacnet_enabled')) {
					self.showCard('bacnetCard');
					self.bacnetInfo();
				} else {
					self.hideCard('bacnetCard');
				}

				self.adjustTopRowLayout();
			});
		}
		window.dashboardReload = loadAll;
		loadAll();
		setInterval(loadAll, 60000);

		toggleFilter = function (section, status) {
			let dashboard = section === 'di' ? document.getElementById('digitalinput') : document.getElementById('digitaloutput');
			let cards = dashboard.querySelectorAll('.card');

			if (activeFilters[section] === status) {
				activeFilters[section] = null;
				cards.forEach(card => card.style.display = 'flex');
			} else {
				activeFilters[section] = status;
				cards.forEach(card => {
					card.style.display = card.classList.contains(status) ? 'flex' : 'none';
				});
			}
		}
		toggleServiceFilter = function (status) {
			const list = document.getElementById('serviceStatusList');
			if (!list) return;

			const rows = list.querySelectorAll('.service-row');

			// clicking same filter again → reset
			if (activeServiceFilter === status) {
				activeServiceFilter = null;
				rows.forEach(row => {
					row.style.display = 'flex';
				});
				return;
			}
			activeServiceFilter = status;
			rows.forEach(row => {
				if (row.classList.contains(`service-${status}`)) {
					row.style.display = 'flex';
				} else {
					row.style.display = 'none';
				}
			});
		}
		document.addEventListener('click', function (e) {
			if (e.target.classList.contains('config-btn')) {
				const type = e.target.dataset.type;
				self.openConfigPage(type);
			}
		});

	}
});
