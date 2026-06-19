L.ui.view.extend({
	getRoutes: L.rpc.declare({
		object: 'luci2.network',
		method: 'routes',
		expect: { routes: [] }
	}),

	getIPv6Routes: L.rpc.declare({
		object: 'luci2.network',
		method: 'routes6',
		expect: { routes: [] }
	}),

	updateipv4ipv6: L.rpc.declare({
		object: 'rpc-updateneighbours',
		method: 'configure',
		expect: { output: '' }
	}),

	execute: function () {
		var self = this;
		L.ui.createNote(
			'NOTE',
			`1.The following rules are currently active on this system.
			 2.This page may refresh once during the initial load to initialize network information.`,
			{ type: 'info', variant: 'inline', appendTo: '#Routes-Info' }
		);
		
		var updatePromise = self.updateipv4ipv6();

		return $.when(

			updatePromise,

			self.getRoutes().then(function (routes) {
				var routeTable = new L.ui.table({
					columns: [{
						caption: L.tr('Target'),
						key: 'target'
					}, {
						caption: L.tr('Gateway'),
						key: 'nexthop'
					}, {
						caption: L.tr('Metric'),
						key: 'metric'
					}, {
						caption: L.tr('Interface'),
						key: 'device'
					}]
				});

				routeTable.rows(routes);
				routeTable.insertInto('#route_table');
			}),

			self.getIPv6Routes().then(function (routes) {
				var route6Table = new L.ui.table({
					columns: [{
						caption: L.tr('Target'),
						key: 'target'
					}, {
						caption: L.tr('Gateway'),
						key: 'nexthop'
					}, {
						caption: L.tr('Source'),
						key: 'source'
					}, {
						caption: L.tr('Metric'),
						key: 'metric'
					}, {
						caption: L.tr('Interface'),
						key: 'device'
					}]
				});

				for (var i = 0; i < routes.length; i++) {
					var prefix = routes[i].target.substr(0, 5).toLowerCase();
					if (prefix == 'fe80:' || prefix == 'fe90:' || prefix == 'fea0:' || prefix == 'feb0:' || prefix == 'ff00:')
						continue;

					route6Table.row(routes[i]);
				}

				route6Table.insertInto('#route6_table');
			}),

			$.getJSON('/dhcp_neighbors.json', function (data) {
				// IPv4 neighbors table
				var ipv4Table = new L.ui.table({
					columns: [
						{ caption: L.tr('IP Address'), key: 'ip' },
						{ caption: L.tr('MAC Address'), key: 'mac' },
						{ caption: L.tr('Interface'), key: 'interface' },
						{ caption: L.tr('State'), key: 'state' }
					]
				});
				ipv4Table.rows(data.ipv4_neighbors);
				ipv4Table.insertInto('#ipv4_table');

				// IPv6 neighbors table
				var ipv6Table = new L.ui.table({
					columns: [
						{ caption: L.tr('IP Address'), key: 'ip' },
						{ caption: L.tr('MAC Address'), key: 'mac' },
						{ caption: L.tr('Interface'), key: 'interface' },
						{ caption: L.tr('State'), key: 'state' }
					]
				});
				ipv6Table.rows(data.ipv6_neighbors);
				ipv6Table.insertInto('#ipv6_table');
			})
		);
	}
});
