L.ui.view.extend({


	getConntrackCount: L.rpc.declare({
		object: 'luci2.network',
		method: 'conntrack_count',
		expect: { '': { count: 0, limit: 0 } }
	}),

	fGetUCISections: L.rpc.declare({
		object: 'uci',
		method: 'get',
		params: ['config', 'section'],
		expect: { values: {} }
	}),

	getDHCPLeases: L.rpc.declare({
		object: 'luci2.network',
		method: 'dhcp_leases',
		expect: { leases: [] }
	}),

	getDHCPv6Leases: L.rpc.declare({
		object: 'luci-rpc', // Adjusted object to match the ubus call
		method: 'getDHCPLeases',
		expect: { dhcp6_leases: [] }
	}),

	gettimezone: L.rpc.declare({
		object: 'rpc-gettimezone',
		method: 'get',
		params: ['application', 'action'],
		expect: { output: '' }
	}),
	GetUCISections: L.rpc.declare({
		object: 'uci',
		method: 'get',
		params: ['config', 'type'],
		expect: { values: {} }
	}),
	updateport: L.rpc.declare({
		object: 'rpc-updateportstatus',
		method: 'configurelan',
		expect: { lanports: {} }
	}),
	updateConnectivity: L.rpc.declare({
		object: 'rpc-UpdateConnectivityinfo',
		method: 'configurecon',
		expect: { lanports: {} }
	}),
	// --- NEW RPC calls for setting & committing config ---
	setUCIOption: L.rpc.declare({
		object: 'uci',
		method: 'set',
		params: ['config', 'section', 'values'],
		expect: { result: {} }
	}),

	commitUCI: L.rpc.declare({
		object: 'uci',
		method: 'commit',
		params: ['config'],
		expect: { result: {} }
	}),

	updatewebinterface: L.rpc.declare({
		object: 'rpc-updatewebinterface',
		method: 'configuregre',
		expect: { output: '' }
	}),

	wifi_enable_disable:true,

	deviceOverview: function () {
		var self = this;

		// Fetch timezone first
		self.gettimezone('get').then(function (tz) {
			window.$tmzone = tz;
		});

		const options = {
			weekday: 'long',
			year: 'numeric',
			month: 'long',
			day: 'numeric',
			timeZone: window.$tmzone,
			hour: '2-digit',
			minute: '2-digit',
			second: '2-digit'
		};

		// vijay changes  ---------------- Device info ----------------
		Promise.all([L.system.getInfo(), self.GetUCISections("boardconfig", "interface")]).then(function ([info, rv]) {
			let uciModel = "";
			let firmwareVer = "";
			let appSwVer = "";

			for (var key in rv) {
				if (rv.hasOwnProperty(key)) {
					var obj = rv[key];
					uciModel = obj.model || "";
					firmwareVer = obj.FirmwareVer || "";
					appSwVer = obj.ApplicationSwVer || "";
					break;
				}
			}

			info.model = uciModel || info.model;   // override model
			info.FirmwareAndIPK = (firmwareVer && appSwVer)
				? `${firmwareVer}_${appSwVer}`
				: (firmwareVer || appSwVer || "N/A");

			const allowedKeys = ["hostname", "model", "kernel", "FirmwareAndIPK", "localtime", "load", "uptime"];
			
			let deviceinfo = `
		  <div class="main-card-header">
			<h2 id="wireless-title" class="card-title">
				<span class="fa-icon" aria-hidden> <img src="/luci2/icons/bi--router-fill.svg" alt="wifi image"></span>
				Device  Informations
			</h2>
			<button class="btn ghost " id="refresh-dash" style="padding:6px 10px;"> <span class="righticon" aria-hidden><img src="/luci2/icons/refresh-icon.svg" alt="wifi image"></span>Refresh</button>
		 </div>
            <div class="main-card-content">`;



			allowedKeys.forEach((key) => {
				let formattedKey = key.charAt(0).toUpperCase() + key.slice(1);
				let extraClass = "";
				let value = info[key];

				if (formattedKey === "Hostname") extraClass = "blue";
				if (formattedKey === "Kernel") extraClass = "subtle";
				if (formattedKey === "Load") 
					{
						formattedKey = L.tr("load average");
						extraClass = "teal";
					}
				if (formattedKey === "Model") extraClass = "amber";
				if (formattedKey === "Uptime") extraClass = "green";
				if (formattedKey === "FirmwareAndIPK") {
					formattedKey = L.tr("Firmware Version and IPK Version");
					extraClass = "purple";
				}
				if (key === "localtime") {
					formattedKey = L.tr("Local Time");
					value = new Date().toLocaleString(undefined, options); // formatted date/time
				}
				if (key === "uptime") {
				value = '%t'.format(info[key]);
				}
				if (key === "kernel") {
						formattedKey = L.tr("Kernel Version");
				}
				if (key === "load") {
					value = info[key].map(l => (l / 65535.0).toFixed(2)).join(", ");
				}

				deviceinfo += `
                <div class="info-row">
						<div class="info-label">${formattedKey}</div>
						<div class="info-value"><span class="value ${extraClass}">${value || "N/A"}</span></div>
                </div>`;
			});

			deviceinfo += `</div>`;
			document.getElementById("device-informations").innerHTML = deviceinfo;

			self.updateConnectivity().then(function (data) {
							const container = document.getElementById("connectivity_info");
							let connectivityInfo = `
							<div class="main-card-header">
								<h2 id="wireless-title" class="card-title">
									<span class="fa-icon" aria-hidden>
									<svg width="30" height="30" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
												<path d="M2 7.5C4.5 5 8.5 5 11 7.5" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
												<path d="M4 10C5.5 8.5 7.5 8.5 9 10" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
												<circle cx="6.5" cy="13" r="1.5" fill="currentColor"/>

												<rect x="11" y="17" width="2" height="3" rx="0.5" fill="currentColor"/>
												<rect x="14" y="14" width="2" height="6" rx="0.5" fill="currentColor"/>
												<rect x="17" y="11" width="2" height="9" rx="0.5" fill="currentColor"/>
												<rect x="20" y="8" width="2" height="12" rx="0.5" fill="currentColor"/>
									</svg>
									</span>
									Connectivity
								</h2>
							</div>

					<div class="main-card-content">

						<!-- Cellular Section -->
						<div class="section-title" id="sim_section">Cellular Networks</div>
						<div class="status-grid">

							<!-- SIM 1 -->
							<div class="info-card" id="card-sim1">
								<div class="sim-card-header">
									<div class="icon-box sim-icon">
										<img src="/luci2/icons/sim_outline.svg" alt="SIM 1">
									</div>
								
									<div class="sim-meta">
										<span class="sim-name-row">
											<span id="sim1-name">Carrier</span> -
											<span id="sim1-net" class="net-type">--</span>
										</span>
									</div>
									<span class="sim-slot-badge sim1-badge">SIM 1</span>
									<div class="signal-meter" id="sim1-bars"></div>
								</div>

								<div class="sim-footer">
									<div>
										<span class="param-label">Strength:</span>
										<span class="param-value" id="sim1-percent">0%</span>
									</div>
									<span class="status-pill" id="sim1-active">ACTIVE</span>
								</div>
							</div>

							<!-- SIM 2 -->
							<div class="info-card" id="card-sim2">
								<div class="sim-card-header">
									<div class="icon-box sim-icon">
										<img src="/luci2/icons/sim_outline.svg" alt="SIM 2">
									</div>


									<div class="sim-meta">
										<span class="sim-name-row">
											<span id="sim2-name">Carrier</span> -
											<span id="sim2-net" class="net-type">--</span>
										</span>
									</div>
									<span class="sim-slot-badge sim2-badge">SIM 2</span>
									<div class="signal-meter" id="sim2-bars"></div>
									
								</div>

								<div class="sim-footer">
									<div>
										<span class="param-label">Strength:</span>
										<span class="param-value" id="sim2-percent">0%</span>
									</div>
									<span class="status-pill" id="sim2-active">ACTIVE</span>
								</div>
							</div>

						</div>

						<!-- WiFi Section -->
						<div class="section-title" id="wifi_section">Wireless Fidelity</div>
						<div class="status-grid">

							<!-- 2.4 GHz -->
							<div class="info-card" id="card-wifi2">
								<div class="sim-card-header">
									<div class="icon-box wifi-icon">
										<svg width="22" height="22" viewBox="0 0 24 24" fill="none"
											stroke="currentColor" stroke-width="2.5"
											stroke-linecap="round" stroke-linejoin="round">
											<path d="M5 12.55a11 11 0 0 1 14.08 0"></path>
											<path d="M1.42 9a16 16 0 0 1 21.16 0"></path>
											<path d="M8.53 16.11a6 6 0 0 1 6.95 0"></path>
											<line x1="12" y1="20" x2="12.01" y2="20"></line>
										</svg>
									</div>

									<div class="sim-meta">
										<span class="sim-name-row">2.4 GHz Band</span>
									</div>

									<span class="wifi-badge" id="wifi2-status">Online</span>
								</div>

								<div class="wifi-grid-layout">
									<div class="wifi-param"><span class="param-label">SSID</span><span class="param-value" id="wifi2-ssid">--</span></div>
									<div class="wifi-param"><span class="param-label">Security</span><span class="param-value" id="wifi2-sec">--</span></div>
									<div class="wifi-param"><span class="param-label">Channel</span><span class="param-value" id="wifi2-chan">--</span></div>
									<div class="wifi-param"><span class="param-label">Clients</span><span class="param-value" id="wifi2-clients">0</span></div>
								</div>
							</div>

							<!-- 5 GHz -->
							<div class="info-card" id="card-wifi5">
								<div class="sim-card-header">
									<div class="icon-box wifi-icon">
										<svg width="22" height="22" viewBox="0 0 24 24" fill="none"
											stroke="currentColor" stroke-width="2.5"
											stroke-linecap="round" stroke-linejoin="round">
											<path d="M5 12.55a11 11 0 0 1 14.08 0"></path>
											<path d="M1.42 9a16 16 0 0 1 21.16 0"></path>
											<path d="M8.53 16.11a6 6 0 0 1 6.95 0"></path>
											<line x1="12" y1="20" x2="12.01" y2="20"></line>
										</svg>
									</div>

									<div class="sim-meta">
										<span class="sim-name-row">5.0 GHz Band</span>
									</div>

									<span class="wifi-badge" id="wifi5-status">Online</span>
								</div>

								<div class="wifi-grid-layout">
									<div class="wifi-param"><span class="param-label">SSID</span><span class="param-value" id="wifi5-ssid">--</span></div>
									<div class="wifi-param"><span class="param-label">Security</span><span class="param-value" id="wifi5-sec">--</span></div>
									<div class="wifi-param"><span class="param-label">Channel</span><span class="param-value" id="wifi5-chan">--</span></div>
									<div class="wifi-param"><span class="param-label">Clients</span><span class="param-value" id="wifi5-clients">0</span></div>
								</div>
							</div>

						</div>
					</div>
				`;

							container.innerHTML = connectivityInfo;
							updateDashboard(data);
			});


			// ---------------- MEMORY CARD ----------------
			let memoryinfo = `
							<div class="main-card-header">
							<h2 id="wireless-title" class="card-title">
								<span class="fa-icon" aria-hidden>
								<img src="/luci2/icons/memory.svg" alt="memory image">
								</span>
								Memory Status
							</h2>
							</div>

							<div class="main-card-content">
							`;

			const total = info.memory.total;
			const free = info.memory.free;
			const cache = info.memory.cached + info.memory.buffered;
			const used = total - free - cache;

			const totalMB = (total / 1024 / 1024).toFixed(0);
			const usedMB = (used / 1024 / 1024).toFixed(0);
			const cacheMB = (cache / 1024 / 1024).toFixed(0);
			const freeMB = (free / 1024 / 1024).toFixed(0);

			const usedPct = ((used / total) * 100).toFixed(1);
			const cachePct = ((cache / total) * 100).toFixed(1);
			const freePct = ((free / total) * 100).toFixed(1);

			memoryinfo += `
											<div class="memory-total-row tooltip-box">
											<span>Total Memory</span>
											<span>${totalMB} MB</span>
											<div class="tooltip-msg">Total Memory:${totalMB} MB</div>
											</div>

											<div class="memory-donut-row">

											<div class="donut tooltip-box"
												style="
												--used:${usedPct};
												--cache:${cachePct};
												--free:${freePct};
												">
												<div class="donut-center">
												<strong>${usedPct}%</strong>
												<span>Used</span>
												</div>
												<div class="tooltip-msg">
												Used: ${usedMB} MB<br>
												Cache: ${cacheMB} MB<br>
												Free: ${freeMB} MB
												</div>
											</div>

											<div class="memory-legend">
												<div class="tooltip-box">
												<span class="dot used"></span>
												Used  : <b>${usedPct}%</b>
												<div class="tooltip-msg">${usedMB} MB / ${totalMB} MB</div>
												</div>

												<div class="tooltip-box">
												<span class="dot cache"></span>
												Cache + Buffers : <b>${cachePct}%</b>
												<div class="tooltip-msg">${cacheMB} MB / ${totalMB} MB</div>
												</div>

												<div class="tooltip-box">
												<span class="dot free"></span>
												Free : <b>${freePct}%</b>
												<div class="tooltip-msg">${freeMB} MB / ${totalMB} MB</div>
												</div>
											</div>

											</div>

											<div class="memory-update-time">
											Last updated: ${new Date().toLocaleTimeString()}
											</div>
											</div>
											`;

			document.getElementById("memory-informations").innerHTML = memoryinfo;



			// ---------------- STORAGE CARD ----------------
			let storageinfo = `
						<div class="main-card-header">
							<h2 id="storage-title" class="card-title">
								<span class="fa-icon" aria-hidden>
									<img src="/luci2/icons/database.svg" alt="storage image">
								</span>
								Storage Information
							</h2>
						</div>
						<div class="main-card-content">
						`;

			// Root partition calculations
			const rootTotal = info.root.total;
			const rootUsed = info.root.used;
			const rootFree = rootTotal - rootUsed;

			const rootTotalMB = (rootTotal / 1024 / 1024).toFixed(0);
			const rootUsedMB = (rootUsed / 1024 / 1024).toFixed(0);
			const rootFreeMB = (rootFree / 1024 / 1024).toFixed(0);

			const rootUsedPct = ((rootUsed / rootTotal) * 100).toFixed(1);
			const rootFreePct = (100 - rootUsedPct).toFixed(1);

			// Temporary Storage (/tmp) calculations
			const tmpUsed = info.tmp.used;
			const tmpTotal = info.tmp.total;
			const tmpUsedMB = (tmpUsed / 1024 / 1024).toFixed(2);
			const tmpTotalMB = (tmpTotal / 1024 / 1024).toFixed(2);
			const tmpPct = ((tmpUsed / tmpTotal) * 100).toFixed(1); // Calculate percentage

			storageinfo += `
									<div class="memory-total-row tooltip-box">
										<span>Total  Storage</span>
										<span>32 MB</span>
										<div class="tooltip-msg">Total Partition Size: 32 MB</div>
									</div>

									<div class="memory-donut-row">
										<div class="donut tooltip-box"
											style="
												--used: ${rootUsedPct};
												--free: ${rootFreePct};
												--cache: 0; 
											">
											<div class="donut-center">
												<strong>${rootUsedPct}%</strong>
												<span>Used</span>
											</div>
											<div class="tooltip-msg">
												Used: ${rootUsedMB} MB<br>
												Free: ${rootFreeMB} MB<br>
												tmp: ${tmpUsedMB} MB
											</div>
										</div>

										<div class="memory-legend">
										<div class="tooltip-box">
												Available Storage : <b>11 MB</b>
												<div class="tooltip-msg">11 MB / 32 MB</div>
											</div>
											<div class="tooltip-box">
												<span class="dot used"></span>
												Root Used  : <b>${rootUsedPct}%</b>
												<div class="tooltip-msg">${rootUsedMB} MB / ${rootTotalMB} MB</div>
											</div>

											<div class="tooltip-box">
												<span class="dot free"></span>
												Root Free : <b>${rootFreePct}%</b>
												<div class="tooltip-msg">${rootFreeMB} MB / ${rootTotalMB} MB</div>
											</div>

											<div class="tooltip-box">
												<span class="dot cache"></span>
												Tmp (/tmp) : <b>${tmpPct}%</b>
												<div class="tooltip-msg">Used: ${tmpUsedMB} MB / ${tmpTotalMB} MB</div>
											</div>
										</div>
									</div>

									<div class="memory-update-time">
										Last updated: ${new Date().toLocaleTimeString()}
									</div>
									</div>
									`;

			document.getElementById("storage-informations").innerHTML = storageinfo;

			// ---------------- Connection CARD ----------------
			self.getConntrackCount().then(function (count) {
				let connectioninfo = `
							<div class="main-card-header">
								<h2 id="connection-title" class="card-title">
									<span class="fa-icon" aria-hidden>
										<img src="/luci2/icons/connection_tracking.svg" alt="connection icon">
									</span>
									Connection Tracking
								</h2>
							</div>

							<div class="main-card-content">
							`;

				const active = count.count;
				const limit = count.limit;
				const remaining = limit - active;

				const usedPct = ((active / limit) * 100).toFixed(1);
				const freePct = (100 - usedPct).toFixed(1);

				connectioninfo += `
										<div class="memory-total-row tooltip-box">
											<span>Max Connections Limit</span>
											<span>${limit}</span>
											<div class="tooltip-msg">System Max: ${limit} connections</div>
										</div>

										<div class="memory-donut-row">
											<div class="donut tooltip-box"
												style="
													--used: ${usedPct};
													--free: ${freePct};
													--cache: 0;
												">
												<div class="donut-center">
													<strong>${usedPct}%</strong>
													<span>Active</span>
												</div>
												<div class="tooltip-msg">
													Active: ${active}<br>
													Remaining: ${remaining}
												</div>
											</div>

											<div class="memory-legend">
												<div class="tooltip-box">
													<span class="dot used"></span>
													Active Sessions : <b>${active}</b>
													<div class="tooltip-msg">${usedPct}% of system limit</div>
												</div>

												<div class="tooltip-box">
													<span class="dot free"></span>
													Free Slots : <b>${remaining}</b>
													<div class="tooltip-msg">${freePct}% capacity available</div>
												</div>
											</div>
										</div>

										<div class="memory-update-time">
											Last updated: ${new Date().toLocaleTimeString()}
										</div>
										</div>
										`;

				document.getElementById("connection-informations").innerHTML = connectioninfo;
			});
		});


		// ---------------- DHCPv4 CARD ----------------

		self.getDHCPLeases().then(function (leases) {

			let DHCPv4info = `
					<div class="main-card-header">
						<h2 id="wireless-title" class="card-title">
							<span class="fa-icon" aria-hidden> <img src="/luci2/icons/globe.svg" alt="globe image"></span>
							DHCPv4 Leases
						</h2>
						
					</div>
					<div class="main-card-content scrollable-x">
						<div class="progress-card-section" id="IPv4leases_status_table_inner"></div>
					</div>`;


			document.getElementById("DHCPv4leases_status_table").innerHTML = DHCPv4info;

			const container = document.querySelector('#IPv4leases_status_table_inner');
			container.innerHTML = '';
			const table = document.createElement('table');
			table.className = 'table table-condensed table-hover';
			const thead = document.createElement('thead');
			thead.innerHTML = `
							<tr class="cbi-section-table-titles">
								<th class="cbi-section-table-cell" style="text-align:center;">Hostname</th>
								<th class="cbi-section-table-cell" style="text-align:center;">IPv4 Address</th>
								<th class="cbi-section-table-cell" style="text-align:center;">MAC Address</th>
								<th class="cbi-section-table-cell" style="text-align:center;">Leasetime Remaining</th>
							</tr>`;
			table.appendChild(thead);
			const tbody = document.createElement('tbody');

			if (leases && leases.length > 0) {
				leases.forEach((lease) => {
					const row = document.createElement('tr');
					row.innerHTML = `
				<td style="text-align:left;"><small>${lease.hostname || '?'}</small></td>
				<td style="text-align:center;"><small>${lease.ipaddr || '-'}</small></td>
				<td style="text-align:center;"><small>${lease.macaddr || '-'}</small></td>
				<td style="text-align:center;"><small>${lease.expires <= 0 ? 'expired' : '%t'.format(lease.expires)}</small></td>
			    `;
					tbody.appendChild(row);
					table.appendChild(tbody);
					container.appendChild(table);
				});

			} else {
				const emptyMsg = document.createElement('p');
				emptyMsg.className = 'no-configurations';
				emptyMsg.textContent = 'There are currently no DHCPv4 lease entries.';
				tbody.innerHTML = '';
				const tableWrapper = container.closest('.progress-card-section') || container;
				tableWrapper.appendChild(emptyMsg);
			}
		});

		// ---------------- DHCPv6 CARD ----------------

		self.getDHCPv6Leases().then(function (leases) {

			let DHCPv6info = `
						<div class="main-card-header">
							<h2 id="wireless-title" class="card-title">
								<span class="fa-icon" aria-hidden> <img src="/luci2/icons/desktop.svg" alt="globe image"></span>
								DHCPv6 Leases
							</h2>
							
						</div>
						<div class="main-card-content scrollable-x">
							<div class="progress-card-section" id="IPv6leases_status_table_inner"></div>
						</div>`;

			document.getElementById("DHCPv6leases_status_table").innerHTML = DHCPv6info;

			const container = document.querySelector('#IPv6leases_status_table_inner');
			container.innerHTML = '';
			const table = document.createElement('table');
			table.className = 'table table-condensed table-hover';
			const thead = document.createElement('thead');
			thead.innerHTML = `
							<tr class="cbi-section-table-titles">
								<th class="cbi-section-table-cell" style="text-align:center;">Hostname</th>
								<th class="cbi-section-table-cell" style="text-align:center;">IPv6 Address </th>
								<th class="cbi-section-table-cell" style="text-align:center;">DUID Address</th>
								<th class="cbi-section-table-cell" style="text-align:center;">Leasetime Remaining</th>
							</tr>`;
			table.appendChild(thead);
			const tbody = document.createElement('tbody');

			if (leases && leases.length > 0) {
				leases.forEach((lease) => {
					const row = document.createElement('tr');
					row.innerHTML = `
									<td style="text-align:left;"><small>${lease.hostname || '?'}</small></td>
									<td style="text-align:center;"><small>${lease.ip6addr || '-'}</small></td>
									<td style="text-align:center;"><small>${lease.duid || '-'}</small></td>
									<td style="text-align:center;"><small>${lease.expires <= 0 ? 'expired' : '%t'.format(lease.expires)}</small></td>
								`;
					tbody.appendChild(row);
					table.appendChild(tbody);
					container.appendChild(table);
				});

			} else {
				const emptyMsg = document.createElement('p');
				emptyMsg.className = 'no-configurations';
				emptyMsg.textContent = 'There are currently no DHCPv6 lease entries.';
				tbody.innerHTML = '';
				const tableWrapper = container.closest('.progress-card-section') || container;
				tableWrapper.appendChild(emptyMsg);
			}
		});

		// ---------------- SIM Details ----------------

		self.fGetUCISections("system", "system").then(function (val) {
			let siminfo = `
		  <div class="main-card-header">
			<h2 id="wireless-title" class="card-title">
				<span class="fa-icon" aria-hidden> <img src="/luci2/icons/bi--router-fill.svg" alt="wifi image"></span>
				SIM  Informations
			</h2>
		 </div>
            <div class="main-card-content">`;

			var allowedKeys = ['simNum', 'qccid']

			allowedKeys.forEach((key) => {
				let formattedKey = key.charAt(0).toUpperCase() + key.slice(1);
				let extraClass = "";
				let value = val[key];

				if (formattedKey === "simNum") extraClass = "blue";	
				if (formattedKey === "qccid") extraClass = "subtle";
				if (formattedKey === "Load") extraClass = "teal";
				if (formattedKey === "Model") extraClass = "amber";
				if (formattedKey === "Uptime") extraClass = "green";
				if (formattedKey === "FirmwareAndIPK") {
					formattedKey = L.tr("Firmware Version and IPK Version");
					extraClass = "purple";
				}

				if (key === "simNum") {
						formattedKey = L.tr("Active sim number");
				}

				// // Local Time override
				// if (key === "localtime") {
				// 	formattedKey = L.tr("Local Time");
				// 	value = new Date().toLocaleString(undefined, options); // formatted date/time
				// }

				// if (key === "uptime") {
				// 	let hours = Math.floor(info[key] / 3600);
				// 	let minutes = Math.floor((info[key] % 3600) / 60);
				// 	let seconds = info[key] % 60;
				// 	value = `${hours} h ${minutes} min ${seconds} sec`;
				// }

				// if (key === "load") {
				// 	value = info[key].map(l => (l / 65535.0).toFixed(2)).join(", ");
				// }

				siminfo += `
                <div class="info-row">
						<div class="info-label">${formattedKey}</div>
						<div class="info-value"><span class="value ${extraClass}">${value || "N/A"}</span></div>
                </div>`;
			});

			siminfo += `</div>`;
			document.getElementById("sim_status_table").innerHTML = siminfo;
		});

		// ---------------- Network CARD ----------------

		L.network.refreshStatus().then(function () {
			const wanList  = (L.network.findActiveWAN('0.0.0.0') || []).filter(i => i.getIPv4Addrs()?.length);
			const wan6List = (L.network.findActiveWAN('::') || []).filter(i => i.getIPv6Addrs()?.length);

			const networkinfo = `
				<div class="main-card-header">
					<h2 id="network-title" class="card-title">
						<span class="fa-icon">
							<img src="/luci2/icons/network-wired.svg">
						</span>
						Network Status
					</h2>
				</div>
				<div class="main-card-content scrollable-x">
					<div class="progress-card-section" id="network_status_table_inner"></div>
				</div>`;

			document.getElementById("network_status_table").innerHTML = networkinfo;
			const container = document.getElementById("network_status_table_inner");
			container.innerHTML = '';

			if (wanList.length === 0 && wan6List.length === 0) {
				const emptyMsg = document.createElement('p');
				emptyMsg.className = 'no-configurations';
				emptyMsg.textContent = 'No active network connections found.';
				container.appendChild(emptyMsg);
				return;
			}

			const table = document.createElement('table');
			table.className = 'table table-condensed table-hover';

			const thead = document.createElement('thead');
			thead.innerHTML = `
				<tr class="cbi-section-table-titles">
					<th style="text-align:left;">Status</th>
					<th style="text-align:center;">Device</th>
					<th style="text-align:left;">Details</th>
				</tr>`;
			table.appendChild(thead);

			const tbody = document.createElement('tbody');

			function addNetworkRow(title, iface, isIPv6) {
				if (!iface) return;

				const devNameRaw = iface.getDevice ? iface.getDevice() : iface.options?.l3dev || '-';
				const dev = L.network.resolveAlias(devNameRaw);
				const devIcon = dev ? `<img src="${dev.icon()}" title="${dev.description()}" style="width:16px; height:16px; vertical-align:middle;">` : '';
				const devName = dev ? dev.name() : devNameRaw;

				const protocol = (iface.getProtocol && iface.getProtocol()?.description) || '-';
				const uptime = iface.getUptime ? '%t'.format(iface.getUptime()) : '-';
				const addrList = isIPv6 ? (iface.getIPv6Addrs ? iface.getIPv6Addrs() : []) : (iface.getIPv4Addrs ? iface.getIPv4Addrs() : []);
				if (!addrList.length) return; // Skip empty interfaces

				const address = addrList.join(', ') || '-';
				const gateway = isIPv6 ? (iface.getIPv6Gateway ? iface.getIPv6Gateway() || '-' : '-') : (iface.getIPv4Gateway ? iface.getIPv4Gateway() || '-' : '-');
				const dnsList = isIPv6 ? (iface.getIPv6DNS ? iface.getIPv6DNS() : []) : (iface.getIPv4DNS ? iface.getIPv4DNS() : []);
				const dns = dnsList.length ? dnsList.join(', ') : '-';

				const detailsHtml = `
					<div class="net-detail"><small><strong>Type:</strong> ${protocol}</small></div>
					<div class="net-detail"><small><strong>Connected:</strong> ${uptime}</small></div>
					<div class="net-detail"><small><strong>Address:</strong> ${address}</small></div>
					<div class="net-detail"><small><strong>Gateway:</strong> ${gateway}</small></div>
					<div class="net-detail"><small><strong>DNS:</strong> ${dns}</small></div>
				`;

				const row = document.createElement('tr');
				row.innerHTML = `
					<td style="text-align:left;"><small>${title}</small></td>
					<td style="text-align:center;"><small>
						<span class="badge" title="${dev ? dev.description() : ''}">
						${devIcon} ${devName}
						</span>
					</small></td>
					<td style="text-align:left;">${detailsHtml}</td>
				`;
				tbody.appendChild(row);
			}

			wanList.forEach(w => addNetworkRow('IPv4 WAN Status', w, false));
			wan6List.forEach(w => addNetworkRow('IPv6 WAN Status', w, true));

			table.appendChild(tbody);
			container.appendChild(table);
		});

		// ---------------- LAN Port Status ----------------

		self.updateport().then(function (data) {
			let deviceinfo = `<div class="ports-list">`;
			$.each(data, function (interfaceName, detailsArray) {
				if (Array.isArray(detailsArray) && detailsArray.length > 0) {
					const details = detailsArray[0];
					const tooltipText = `Name: &nbsp; ${interfaceName}<br>Status:&nbsp;${details.status}<br>Speed:&nbsp;${details.speed || 'N/A'} Mbps`;
					const isOn = details.status === 'Connected';

					deviceinfo += `
						<div class="port ${isOn ? 'on' : 'off'}" role="listitem">
							<div class="port-left tooltip-box">
							<div class="port-icon">
								<img src="/luci2/icons/ethernet_grey.svg" alt="ethernet icon">
							</div>
							<div class="port-name">
								${interfaceName}
								<div class="lanstatus" title="Connection status">
								<span class="status-dot"></span>
								</div>
							</div>
							<div class="tooltip-msg">${tooltipText}</div>
							</div>

						</div>`;
				}
			});
			deviceinfo += `</div>`;

			$('#lanport-informations').html(deviceinfo)
		});
	},

	// applyUCIOption: function (config, section, values) {
	// 	var self = this;
	// 	return self.setUCIOption(config, section, values)
	// 		.then(function () {
	// 			return self.commitUCI(config);
	// 		});
	// },

	// newwebuiinfo: function () {
	// 	var self = this;
	// 	var dontShowChk = document.getElementById('dontshow');
	// 	if (!dontShowChk) return;

	// 	self.GetUCISections('webinterface', 'webinterface').then(function (rv) {
	// 		var showwebenable, webValue;

	// 		for (var key in rv) {
	// 			if (rv.hasOwnProperty(key)) {
	// 				var obj = rv[key];
	// 				if (obj.hasOwnProperty('showwebenable')) {
	// 					showwebenable = obj.showwebenable;
	// 					webValue = obj.enable;
	// 					break;
	// 				}
	// 			}
	// 		}

	// 		dontShowChk.checked = (showwebenable === '1');

	// 		if (webValue === '0' && showwebenable === '0') {
	// 			L.ui.showAlert(
	// 				'info',
	// 				'New UI Available',
	// 				'We have developed a new user interface. To try it now, click the "Switch UI" button and select the interface you prefer. You can switch back at any time.',
	// 				{ duration: 0 }
	// 			);
	// 		}
	// 	});

	// 	dontShowChk.addEventListener('change', function () {
	// 		var newValue = dontShowChk.checked ? '1' : '0';
	// 		self.applyUCIOption('webinterface', 'main', { showwebenable: newValue })
	// 			.then(function () {
	// 				if (newValue === '1') {
	// 					L.ui.hideAlerts();
	// 				} else {
	// 					L.ui.showAlert(
	// 						'info',
	// 						'New UI Available',
	// 						'We have developed a new user interface. To try it now, click the "Switch UI" button and select the interface you prefer. You can switch back at any time.',
	// 						{ duration: 0 }
	// 					);
	// 				}
	// 			});
	// 	});
	// },

	// initWebSwitch: function () {
	// 	var self = this;
	// 	var btnNew = document.getElementById('segNew');
	// 	var btnOld = document.getElementById('segOld');
	// 	var btnApply = document.getElementById('apply');
	// 	var btnCancel = document.getElementById('cancel');

	// 	if (!btnNew || !btnOld || !btnApply || !btnCancel) return;

	// 	var currentValue = null;   // actual config value from UCI
	// 	var pendingValue = null;   // user selection before apply

	// 	self.GetUCISections('webinterface', 'webinterface').then(function (rv) {
	// 		for (var key in rv) {
	// 			if (rv.hasOwnProperty(key)) {
	// 				var obj = rv[key];
	// 				currentValue = obj.enable;
	// 				pendingValue = currentValue;

	// 				var isNew = (currentValue === '1');

	// 				btnNew.classList.toggle('active', isNew);
	// 				btnNew.setAttribute('aria-selected', isNew);
	// 				btnOld.classList.toggle('active', !isNew);
	// 				btnOld.setAttribute('aria-selected', !isNew);
	// 				if (typeof previewChoice !== "undefined") {
	// 					previewChoice = isNew ? 'new' : 'old';
	// 					if (typeof updateSegment === "function") updateSegment();
	// 				}
	// 			}
	// 		}
	// 	});

	// 	// Button click: just change selection visually, not config yet
	// 	btnNew.addEventListener('click', function () {
	// 		pendingValue = '1';
	// 		btnNew.classList.add('active');
	// 		btnNew.setAttribute('aria-selected', true);
	// 		btnOld.classList.remove('active');
	// 		btnOld.setAttribute('aria-selected', false);
	// 	});

	// 	btnOld.addEventListener('click', function () {
	// 		pendingValue = '0';
	// 		btnOld.classList.add('active');
	// 		btnOld.setAttribute('aria-selected', true);
	// 		btnNew.classList.remove('active');
	// 		btnNew.setAttribute('aria-selected', false);
	// 	});

	// 	// Apply button: now update config & call RPC
	// 	btnApply.addEventListener('click', function () {
	// 		if (pendingValue === currentValue) {
	// 			// alert("No changes to apply.");
	// 			return;
	// 		}

	// 		self.applyUCIOption('webinterface', 'main', { enable: pendingValue }).then(function () {
	// 			currentValue = pendingValue; // update reference
	// 			var isNew = (pendingValue === '1');

	// 			if (isNew) {
	// 				// alert("Web interface has a new version uploaded. Please wait a minute.");
	// 				return self.updatewebinterface();
	// 			} else {
	// 				// alert("Reverted to the current web interface.");
	// 				return self.updatewebinterface();
	// 			}
	// 		});
	// 	});

	// 	// Cancel button: revert UI selection to last saved config
	// 	btnCancel.addEventListener('click', function () {
	// 		pendingValue = currentValue;
	// 		var isNew = (currentValue === '1');

	// 		btnNew.classList.toggle('active', isNew);
	// 		btnNew.setAttribute('aria-selected', isNew);
	// 		btnOld.classList.toggle('active', !isNew);
	// 		btnOld.setAttribute('aria-selected', !isNew);
	// 	});
	// },

	execute: function () {
		var self = this;
		$(document).off("click", "#refresh-dash").on("click", "#refresh-dash", function () {
			self.deviceOverview();
			L.ui.showAlert('success', 'Live Data Updated', 'SUCCESS: Dashboard data has been refreshed successfully!');
			return L.network.load().then(function () {
			});
		});

		updateDashboard = function (data) {

			if (data.SIM.Sim_Inserted === "true") {
				document.getElementById('sim1-name').innerText = data.SIM.Sim_Name;
				document.getElementById('sim1-net').innerText = data.SIM.Sim_Netmode;
				document.getElementById('sim1-percent').innerText = data.SIM.Sim_Signalper;
				setSignalBars('sim1-bars', data.SIM.Sim_quality);
				document.getElementById('sim1-active').style.display = (data.SIM.Sim_Active === "true" ? 'block' : 'none');
			} else { document.getElementById('card-sim1').classList.add('hidden'); }

			if (data.SIM.Sim_Inserted2 === "true") {
				document.getElementById('sim2-name').innerText = data.SIM.Sim_Name2;
				document.getElementById('sim2-net').innerText = data.SIM.Sim_Netmode2;
				document.getElementById('sim2-percent').innerText = data.SIM.Sim_Signalper2;
				setSignalBars('sim2-bars', data.SIM.Sim_quality2);
				document.getElementById('sim2-active').style.display = (data.SIM.Sim_Active2 === "true" ? 'block' : 'none');
			} else { document.getElementById('card-sim2').classList.add('hidden'); }

			if (data.SIM.Sim_Inserted2 === "NA" && data.SIM.Sim_Inserted === "NA") {
				document.getElementById('sim_section').classList.add('hidden');
			}

			// if (data.WIFI.wifiv1_status === "ON") {
			if (data.WIFI.wifiv1_status === "ON" && self.wifi_enable_disable === true) {
				document.getElementById('wifi2-ssid').innerText = data.WIFI.wifiv1_ssid;
				document.getElementById('wifi2-sec').innerText = data.WIFI.wifiv1_security;
				document.getElementById('wifi2-chan').innerText = data.WIFI.wifiv1_channel;
				document.getElementById('wifi2-clients').innerText = data.WIFI.wifiv1_con_client;
			} else { document.getElementById('card-wifi2').classList.add('hidden');
					document.getElementById('wifi_section').classList.add('hidden'); }

			if (data.WIFI.wifiv5_status === "ON" && self.wifi_enable_disable === true) {
				document.getElementById('wifi5-ssid').innerText = data.WIFI.wifiv5_ssid;
				document.getElementById('wifi5-sec').innerText = data.WIFI.wifiv5_security;
				document.getElementById('wifi5-chan').innerText = data.WIFI.wifiv5_channel;
				document.getElementById('wifi5-clients').innerText = data.WIFI.wifiv5_con_client;
			} else { document.getElementById('card-wifi5').classList.add('hidden'); }

			if (data.WIFI.wifiv5_status === "OFF" && data.WIFI.wifiv1_status === "OFF" ) {
				document.getElementById('wifi_section').classList.add('hidden');
			}

			if ((data.WIFI.wifiv5_status === "OFF" && data.WIFI.wifiv1_status === "OFF") && (data.SIM.Sim_Inserted2 === "NA" && data.SIM.Sim_Inserted === "NA")) {
				document.getElementById('connectivity_info').classList.add('hidden');
			}

		};

		// self.repeat(self.deviceOverview, 5000);
		self.deviceOverview()
		// self.initWebSwitch()
		// self.newwebuiinfo()
		return L.network.load().then(function () {
		});

	}
});
