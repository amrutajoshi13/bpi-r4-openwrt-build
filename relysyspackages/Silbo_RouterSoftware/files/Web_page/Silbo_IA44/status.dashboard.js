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

		// vijay changes
		Promise.all([L.system.getInfo(), self.GetUCISections("boardconfig", "interface")]).then(function ([info, rv]) {
			let uciModel = "";
			let firmwareVer = "";
			let appSwVer = "";
			let GWfirmarever = "";
            let GWApplicationver = "";
 
            for (var key in rv) {
                if (rv.hasOwnProperty(key)) {
                    var obj = rv[key];
                    uciModel = obj.model || "";
                    firmwareVer = obj.FirmwareVer || "";
                    appSwVer = obj.ApplicationSwVer || "";
                    GWfirmarever = obj.GWFirmwareVer || "";
                    GWApplicationver = obj.GWApplicationSwVer || "";
                    break;
                }
            }
 
            info.model = uciModel || info.model;   // override model
            info.FirmwareAndIPK = (firmwareVer && appSwVer)
                ? `${firmwareVer}_${appSwVer}`
                : (firmwareVer || appSwVer || "N/A");
            info.GWFirmwareAndIPK = (GWfirmarever && GWApplicationver)
                ? `${GWfirmarever}_${GWApplicationver}`
                : (GWfirmarever || GWApplicationver || "N/A");
 
            const allowedKeys = ["hostname", "model", "FirmwareAndIPK", "GWFirmwareAndIPK", "kernel", "localtime", "uptime", "load"];
			// const allowedKeys = ["hostname", "model", "kernel", "localtime", "load", "uptime"];

			// RAJ
			// L.system.getInfo().then(function (info) {     

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
				if (formattedKey === "GWFirmwareAndIPK") {
                    formattedKey = L.tr("Application Firmware Version and IPK Version");
                    extraClass = "blue";
                }

				// Local Time override
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



			// ---------------- MEMORY CARD ----------------
			let memoryinfo = `
             <div class="main-card-header">
					<h2 id="wireless-title" class="card-title">
						<span class="fa-icon" aria-hidden> <img src="/luci2/icons/memory.svg" alt="memory image"></span>
						Memory Status
					</h2>
			</div>
            <div class="main-card-content">

           <div class="progress-card-section">`;

			const totalMemory = info.memory.total;

			const memoryData = [
				{ label: "Total Memory", value: info.memory.total },
				{ label: "Used (System + Apps)", value: (info.memory.free + info.memory.buffered) },
				{ label: "Cache + Buffers", value: info.memory.shared + info.memory.buffered },
				{ label: "Free", value: info.memory.free },
			];

			memoryData.forEach(item => {
				const isTotal = item.label.toLowerCase().includes("total");
				const isFree = item.label.toLowerCase().includes("free");
				const isUsed = item.label.toLowerCase().includes("used");

				const usedMB = (item.value / (1024 * 1024)).toFixed(2);
				const totalMB = (totalMemory / (1024 * 1024)).toFixed(2);
				const tooltipText = `${usedMB} MB / ${totalMB} MB`;

				if (isTotal) {
					memoryinfo += `
					<div class="progress-card-label tooltip-box">
							<span>${item.label}</span>
							<span class="progress-card-value">${usedMB} MB</span>
							<div class="tooltip-msg">${tooltipText}</div>
							</div>
							
							`;
				} else {
					const percentage = ((item.value / totalMemory) * 100).toFixed(2);
					const usedpercentage = (100 - percentage).toFixed(2);
					const fillColor = getColorForValue(percentage, isFree);

					memoryinfo += `
						<div class="progress-card-item tooltip-box" data-metric="${isFree ? 'free' : 'used'}">
							<div class="progress-card-label">
							<span>${item.label}</span>
							<span class="progress-card-value">${isUsed ? `${usedpercentage}` : ` ${percentage}`}%</span>
							</div>
							<div class="progress-card-bar">
							<div class="progress-card-fill" style="width: ${percentage}%; background-color: ${fillColor};"></div>
							</div>
							<div class="tooltip-msg">${tooltipText}</div>
						</div>
						`;
				}
			});

			memoryinfo += `</div>`;

			// Render into container
			document.getElementById("memory-informations").innerHTML = memoryinfo;


			// ---------------- STORAGE CARD ----------------
			let storageinfo = `
      		<div class="main-card-header">
						<h2 id="wireless-title" class="card-title">
						<span class="fa-icon" aria-hidden> <img src="/luci2/icons/database.svg" alt="memory image"></span>
						Storage  Informations
						</h2>
			</div>
            <div class="main-card-content">

    		<div class="progress-card-section">`;
			console.log(info.root.total)
			const storageData = [
				{ label: "Total Storage", value: info.root.total, total: info.root.total },
				{ label: "Available Storage", value: info.root.total, total: info.root.total },
				{ label: "Root Usage (/)", value: info.root.used, total: info.root.total },
				{ label: "Temporary Usage (/tmp)", value: info.tmp.used, total: info.tmp.total }

			];
			storageData.forEach(item => {
				const Totalstrg = item.label.toLowerCase().includes("total");
				const isavailable = item.label.toLowerCase().includes("available");
				const usedMB = (item.value / (1024 * 1024)).toFixed(2);
				const totalMB = (item.total / (1024 * 1024)).toFixed(2);
				const tooltipText = `${usedMB} MB / ${totalMB} MB`;

				if (Totalstrg) {
					storageinfo += `
					<div class="progress-card-label">
						<span>${item.label}</span>
						<span class="progress-card-value"> 32 MB</span>
						<div class="tooltip-msg">${tooltipText}</div>
					</div>`;
				} else if (isavailable) {
					storageinfo += `
					<div class="progress-card-label tooltip-box">
						<span>${item.label}</span>
						<span class="progress-card-value">${usedMB} MB</span>
						<div class="tooltip-msg">${tooltipText}</div>
					</div>`;
				} else {
					const percentage = ((item.value / item.total) * 100).toFixed(2);
					const fillColor = getColorForValue(percentage);
					storageinfo += `
					<div class="progress-card-item tooltip-box">
						<div class="progress-card-label">
							<span>${item.label}</span>
							<span class="progress-card-value">${percentage}%</span>
						</div>
						<div class="progress-card-bar">
							<div class="progress-card-fill" style="width: ${percentage}%; background-color: ${fillColor};"></div>
						</div>
						<div class="tooltip-msg">${tooltipText}</div>
					</div>`;
				}
			});

			storageinfo += `
						</div> 
					</div> 
					`;

			document.getElementById("storage-informations").innerHTML = storageinfo;

			// ---------------- Connection CARD ----------------
			let connectioninfo = `
      		<div class="main-card-header">
						<h2 id="wireless-title" class="card-title">
						<span class="fa-icon" aria-hidden> <img src="/luci2/icons/connection_tracking.svg" alt="memory image"></span>
						Connection Tracking
						</h2>
			</div>
            <div class="main-card-content">

    		<div class="progress-card-section">`;

			self.getConntrackCount().then(function (count) {
				const connectionData = [
					{ label: "Connection Tracking", value: count.count, total: count.limit },

				];
				connectionData.forEach(item => {
					const percentage = ((item.value / item.total) * 100).toFixed(2);
					const fillColor = getColorForValue(percentage);
					const usedMB = (item.value);
					const totalMB = (item.total);
					const tooltipText = `${usedMB}  / ${totalMB} `;

					connectioninfo += `
				<div class="progress-card-item tooltip-box">
					<div class="progress-card-label">
						<span>${item.label}</span>
						<span class="progress-card-value">${percentage}%</span>
					</div>
					<div class="progress-card-bar">
						<div class="progress-card-fill" style="width: ${percentage}%; background-color: ${fillColor};"></div>
					</div>
					<div class="tooltip-msg">${tooltipText}</div>
				</div>`;
				});

				connectioninfo += `
					</div> 
				</div> 
				`;

				document.getElementById("connection-informations").innerHTML = connectioninfo;

			})

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

	applyUCIOption: function (config, section, values) {
		var self = this;
		return self.setUCIOption(config, section, values)
			.then(function () {
				return self.commitUCI(config);
			});
	},

	newwebuiinfo: function () {
		var self = this;
		var dontShowChk = document.getElementById('dontshow');
		if (!dontShowChk) return;

		self.GetUCISections('webinterface', 'webinterface').then(function (rv) {
			var showwebenable, webValue;

			for (var key in rv) {
				if (rv.hasOwnProperty(key)) {
					var obj = rv[key];
					if (obj.hasOwnProperty('showwebenable')) {
						showwebenable = obj.showwebenable;
						webValue = obj.enable;
						break;
					}
				}
			}

			dontShowChk.checked = (showwebenable === '1');

			if (webValue === '0' && showwebenable === '0') {
				L.ui.showAlert(
					'info',
					'New UI Available',
					'We have developed a new user interface. To try it now, click the "Switch UI" button and select the interface you prefer. You can switch back at any time.',
					{ duration: 0 }
				);
			}
		});

		dontShowChk.addEventListener('change', function () {
			var newValue = dontShowChk.checked ? '1' : '0';
			self.applyUCIOption('webinterface', 'main', { showwebenable: newValue })
				.then(function () {
					if (newValue === '1') {
						L.ui.hideAlerts();
					} else {
						L.ui.showAlert(
							'info',
							'New UI Available',
							'We have developed a new user interface. To try it now, click the "Switch UI" button and select the interface you prefer. You can switch back at any time.',
							{ duration: 0 }
						);
					}
				});
		});
	},

	initWebSwitch: function () {
		var self = this;
		var btnNew = document.getElementById('segNew');
		var btnOld = document.getElementById('segOld');
		var btnApply = document.getElementById('apply');
		var btnCancel = document.getElementById('cancel');

		if (!btnNew || !btnOld || !btnApply || !btnCancel) return;

		var currentValue = null;   // actual config value from UCI
		var pendingValue = null;   // user selection before apply

		self.GetUCISections('webinterface', 'webinterface').then(function (rv) {
			for (var key in rv) {
				if (rv.hasOwnProperty(key)) {
					var obj = rv[key];
					currentValue = obj.enable;
					pendingValue = currentValue;

					var isNew = (currentValue === '1');

					btnNew.classList.toggle('active', isNew);
					btnNew.setAttribute('aria-selected', isNew);
					btnOld.classList.toggle('active', !isNew);
					btnOld.setAttribute('aria-selected', !isNew);
					if (typeof previewChoice !== "undefined") {
						previewChoice = isNew ? 'new' : 'old';
						if (typeof updateSegment === "function") updateSegment();
					}
				}
			}
		});

		// Button click: just change selection visually, not config yet
		btnNew.addEventListener('click', function () {
			pendingValue = '1';
			btnNew.classList.add('active');
			btnNew.setAttribute('aria-selected', true);
			btnOld.classList.remove('active');
			btnOld.setAttribute('aria-selected', false);
		});

		btnOld.addEventListener('click', function () {
			pendingValue = '0';
			btnOld.classList.add('active');
			btnOld.setAttribute('aria-selected', true);
			btnNew.classList.remove('active');
			btnNew.setAttribute('aria-selected', false);
		});

		// Apply button: now update config & call RPC
		btnApply.addEventListener('click', function () {
			if (pendingValue === currentValue) {
				// alert("No changes to apply.");
				return;
			}

			self.applyUCIOption('webinterface', 'main', { enable: pendingValue }).then(function () {
				currentValue = pendingValue; // update reference
				var isNew = (pendingValue === '1');

				if (isNew) {
					// alert("Web interface has a new version uploaded. Please wait a minute.");
					return self.updatewebinterface();
				} else {
					// alert("Reverted to the current web interface.");
					return self.updatewebinterface();
				}
			});
		});

		// Cancel button: revert UI selection to last saved config
		btnCancel.addEventListener('click', function () {
			pendingValue = currentValue;
			var isNew = (currentValue === '1');

			btnNew.classList.toggle('active', isNew);
			btnNew.setAttribute('aria-selected', isNew);
			btnOld.classList.toggle('active', !isNew);
			btnOld.setAttribute('aria-selected', !isNew);
		});
	},

	execute: function () {
		var self = this;
		$(document).off("click", "#refresh-dash").on("click", "#refresh-dash", function () {
			self.deviceOverview();
			L.ui.showAlert('success', 'Live Data Updated', 'SUCCESS: Dashboard data has been refreshed successfully!');
			return L.network.load().then(function () {
			});
		});


		// self.repeat(self.deviceOverview, 5000);
		self.deviceOverview()
		self.initWebSwitch()
		self.newwebuiinfo()
		return L.network.load().then(function () {
		});

	}
});
