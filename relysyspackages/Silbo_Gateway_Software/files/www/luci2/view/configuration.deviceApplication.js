L.ui.view.extend({

	applications: [],
	processingApps: {},
	exclusiveGroup: ['modbus', 'port'],
	configRoutes: {
		rs232: 'configuration/rs232Configuration',
		rs485: 'configuration/modbusConfiguration',
		dio: 'configuration/digitalinputConfig',
		aio: 'configuration/analoginputConfig',
		bacnet: 'configuration/BACnetconfiguration',
		snmp: 'configuration/snmpMasterConfig',
		modbus: 'configuration/modbusConfiguration',
		port: 'configuration/portconfiguration'
	},



	openConfigPage: function (appId) {
		const route = this.configRoutes[appId];

		if (!route) {
			console.warn('No config route for:', appId);
			alert('Configuration page not available');
			return;
		}

		let params = window.location.href;
		let base = params.split(",")[0];

		let link = base + `,view:${route}`;
		window.open(link, "_self");
	},

	startLoading: function (panelId) {
		const el = document.getElementById(panelId);
		if (!el) return;
		el.classList.add('loading');
	},

	stopLoading: function (panelId, success = true) {
		const el = document.getElementById(panelId);
		if (!el) return;
		el.classList.remove('loading');
	},

	showError: function (containerId, message) {
		const el = document.getElementById(containerId);
		if (!el) return;
		el.innerHTML = `<div class="card-center-message">${message}</div>`;
	},

	isExclusiveLocked: function (currentAppId) {
		var self = this

		if (!this.exclusiveGroup.includes(currentAppId)) {
			return false;
		}
		return self.applications.some(app =>
			this.exclusiveGroup.includes(app.id) &&
			app.id !== currentAppId &&
			(app.state === 'running' || app.state === 'starting')
		);
	},
	getExclusiveLockMessage: function (app) {
		var self = this;
		// only for exclusive apps
		if (!this.exclusiveGroup.includes(app.id)) {
			return '';
		}

		const blocker = self.applications.find(a =>
			this.exclusiveGroup.includes(a.id) &&
			a.id !== app.id &&
			(a.state === 'running' || a.state === 'starting')
		);

		if (!blocker) return '';

		return `Disable ${blocker.name} to enable ${app.name}`;
	},



	loadApplications: function () {
		var self = this;
		let params = window.location.href;
		let BaseURL = new URL(params).origin;
		const container = document.getElementById('apps');

		if (container) {
			container.innerHTML = `<div class="card-center-message">Loading applications…</div>`;
		}

		//return fetch('https://mocki.io/v1/9d4bf494-dfb4-4f15-90a0-f0abad2e3c31')

			fetch(`${BaseURL}:30008/device/applications/`)
			.then(res => res.json())
			.then(data => {
				console.log("data", data)
				if (!Array.isArray(data)) {
					self.showError('apps', 'Invalid application data');
					return;
				}

				self.applications = data;
				if (container) container.innerHTML = '';
				self.renderApplications();
			})
			.catch(err => {
				console.error('Application fetch error:', err);
				self.showError('apps', 'Unable to load applications');
			});
	},


	renderApplications: function () {
		var self = this;
		const container = document.getElementById('apps');
		const search = document.getElementById('search');

		if (!container) return;
		container.innerHTML = '';

		const keyword = (search?.value || '').toLowerCase();

		const filtered = self.applications.filter(app =>
			app.name.toLowerCase().includes(keyword) ||
			app.desc.toLowerCase().includes(keyword)
		);

		if (!filtered.length) {
			container.innerHTML = `<div class="card-center-message">No applications found</div>`;
			return;
		}

		filtered.forEach(app => {
			container.appendChild(this.createApplicationRow(app));
		});
	},

	createApplicationRow: function (app) {

		const isProcessing = this.processingApps[app.id] === true;
		const isLockedByOther = this.isExclusiveLocked(app.id);
		const lockMessage = isLockedByOther ? this.getExclusiveLockMessage(app) : '';
		const state = (app.state || 'disabled').toLowerCase();

		const wrapper = document.createElement('div');

		// ----- Lock note ABOVE row -----
		if (lockMessage) {
			const note = document.createElement('div');
			note.className = 'lock-note-row';
			note.innerHTML = `⚠ ${lockMessage}`;
			wrapper.appendChild(note);
		}

		const row = document.createElement('div');

		let rowClass = 'disabled-row';
		if (state === 'running' || state === 'starting') {
			rowClass = 'running-row';
		} else if (state === 'stopping') {
			rowClass = 'processing-row';
		}

		row.className = `app-row ${rowClass} ${isLockedByOther ? 'row-disabled' : ''}`;

		row.innerHTML = `
        <div class="app-name">
            <div class="icon">${app.name?.[0] || '?'}</div>
            <div>
                <div class="app-title">${app.name}</div>
                <div class="app-desc">${app.desc || '—'}</div>
            </div>
        </div>

        <div class="status ${this.getStatusClass(state)}">
            ${this.getStatusText(state)}
        </div>

        <div class="message">${app.message || '—'}</div>

        <div class="actions">
            ${state === 'disabled'
				? `<button class="enable" data-id="${app.id}"
                    ${(isProcessing || isLockedByOther) ? 'disabled' : ''}>
                    Start
                  </button>`
				: `<button class="disable" data-id="${app.id}"
                    ${isProcessing ? 'disabled' : ''}>
                    Disable
                  </button>`
			}

            ${state === 'running'
				? `<button class="config" data-id="${app.id}"
                    ${isProcessing ? 'disabled' : ''}>
                    Config
                  </button>`
				: ``
			}
        </div>
    `;

		wrapper.appendChild(row);
		return wrapper;
	},

	getStatusText: function (state) {
		if (state === 'running') return 'Running';
		if (state === 'starting') return 'Starting';
		if (state === 'stopping') return 'Stopping';
		return 'Disabled';
	},

	getStatusClass: function (state) {
		if (state === 'running' || state === 'starting') {
			return 'running'; // green
		}
		if (state === 'stopping') {
			return 'stopping'; // amber
		}
		return 'disabled-status';
	},

	bindEvents: function () {
		const self = this;

		document.getElementById('search')?.addEventListener('input', () => {
			self.renderApplications();
		});

		document.addEventListener('click', e => {
			if (e.target.classList.contains('enable')) {
				//self.startApplication(e.target.dataset.id);
				const appId = e.target.dataset.id;

				// Port Start behaves like Config
				if (appId === 'port') {
					self.openConfigPage('port');
					return;
				}
				self.startApplication(appId);

			}

			if (e.target.classList.contains('disable')) {
				const appId = e.target.dataset.id;

				// Port Disable behaves like Config
				if (appId === 'port') {
					self.openConfigPage('port');
					return;
				}

				self.stopApplication(appId);
			}
			if (e.target.classList.contains('config')) {
				self.openConfigPage(e.target.dataset.id);
			}
		});
	},

	// postApplicationState: function (payload) {
	// 	let params = window.location.href;
	// 	let BaseURL = new URL(params).origin;
	// 	return fetch(
	// 		'https://cors-anywhere.herokuapp.com/https://webhook.site/d2863ebd-c578-4421-b270-7ab6975b25c8',
	// 		{
	// 			// return fetch(
	// 			// 	`${BaseURL}:30006/Register_Configuration/${deviceName}`,
	// 			// 	{
	// 			method: 'POST',
	// 			headers: {
	// 				'Content-Type': 'application/json'
	// 			},
	// 			body: JSON.stringify(payload)
	// 		}
	// 	).then(res => {
	// 		// success if HTTP 2xx
	// 		if (!res.ok) {
	// 			throw new Error('POST failed');
	// 		}
	// 		return true; // <-- IMPORTANT
	// 	});
	// },

	// postApplicationState: function (payload) {
	// 	var self = this;
	// 	let params = window.location.href;
	// 	let BaseURL = new URL(params).origin;

	// 	//return fetch('https://cors-anywhere.herokuapp.com/https://webhook.site/92844bf7-af09-4bbe-9cba-59fd31030ff8',
	// 	return fetch(`${BaseURL}:30008/device/`,
	// 		{
	// 			method: 'POST',
	// 			headers: {
	// 				'Content-Type': 'application/json'
	// 			},
	// 			body: JSON.stringify(payload)
	// 		}
	// 	)
	// 		.then(res => {
	// 			if (!res.ok) {
	// 				throw new Error('POST failed');
	// 			}
	// 			return res.json();
	// 		});
	// },

	postApplicationState: function (payload) {
		let BaseURL = new URL(window.location.href).origin;

		return fetch(`${BaseURL}:30008/device/`, {
			method: 'POST',
			headers: {
				'Content-Type': 'application/json'
			},
			body: JSON.stringify(payload)
		})
			.then(res => {
				if (!res.ok) {
					throw new Error('POST failed');
				}
				return res.json();
			})
			.then(data => {
				if (data?.status !== "success") {
					throw new Error(data?.message || 'Stop failed');
				}
				return data;
			});
	},



	startApplication: function (id) {
		if (this.processingApps[id]) return;
		const self = this;
		const app = self.applications.find(a => a.id === id);
		if (!app) return;
		self.processingApps[id] = true;
		// UI immediately shows STARTING
		app.state = 'starting';
		app.message = 'Starting application…';
		self.renderApplications();

		const payload = {
			id: app.id,
			state: "running",
			message: `Started successfully at ${new Date().toLocaleString()}`
		};

		self.showGlobalLoader('Starting application…');
		self.postApplicationState(payload)

		setTimeout(() => {
			delete self.processingApps[id];
			self.hideGlobalLoader();
			location.reload()
		}, 7000);



		// .then(() => {
		// 	self.loadApplications(); // correct place
		// })
		// .catch(err => {
		// 	console.error(err.message);
		// 	// self.loadApplications(); // optional fallback
		// })
		// .finally(() => {
		// 	delete self.processingApps[id];
		// 	self.hideGlobalLoader();
		// });

	},



	stopApplication: function (id) {
		if (this.processingApps[id]) return;
		const self = this;
		const app = self.applications.find(a => a.id === id);
		if (!app) return;
		self.processingApps[id] = true;
		//  UI immediately shows STARTING
		app.state = 'stopping';
		app.message = 'Stopping application…';
		self.renderApplications();

		const payload = {
			id: app.id,
			state: "disabled",
			message: `Disabled successfully at ${new Date().toLocaleString()}`
		};


		self.showGlobalLoader('Stopping application…');

		self.postApplicationState(payload)
		setTimeout(() => {
			delete self.processingApps[id];
			self.hideGlobalLoader();
			location.reload()
		}, 7000);
		// .then(() => {
		// 	self.loadApplications(); // correct place
		// })
		// .catch(err => {
		// 	console.error(err.message);
		// 	// self.loadApplications(); // optional fallback
		// })
		// .finally(() => {
		// 	delete self.processingApps[id];
		// 	self.hideGlobalLoader();
		// });

	},

	showGlobalLoader: function (text = 'Applying changes…') {
		const loader = document.getElementById('globalLoader');
		if (!loader) return;
		loader.querySelector('.loader-text').innerText = text;
		loader.classList.remove('hidden');
	},

	hideGlobalLoader: function () {
		const loader = document.getElementById('globalLoader');
		if (!loader) return;
		loader.classList.add('hidden');
	},

	execute: function () {
		var self = this;
		self.applications = [];
		self.bindEvents();
		self.loadApplications();
	}
});
