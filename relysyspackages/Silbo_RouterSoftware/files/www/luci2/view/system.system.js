L.ui.view.extend({

	fGetUCISections: L.rpc.declare({
		object: 'uci',
		method: 'get',
		// params: [ 'config', 'type', 'section']  
		params: ['config', 'type']
	}),

	fGetUCISectionsRB: L.rpc.declare({
		object: 'uci',
		method: 'get',
		params: ['config', 'type', 'section']
	}),

	updateinterfaceconfig: L.rpc.declare({
		object: 'rpc-maintenancereboot',
		method: 'configure',
		params: ['application', 'action'],
		expect: { output: '' }
	}),

	execute: function () {
		var self = this;

		var m = new L.cbi.Map('system', {
			// collapsible: true
		});

		var s = m.section(L.cbi.TypedSection, 'system', {
			caption: L.tr('System Properties'),
			teasers: ['hostname', 'zonename', 'languages', 'themes'],
			readonly: !this.options.acls.system
		});


		s.tab({
			id: 'general',
			caption: L.tr('General Settings')
		});

		var t = s.taboption('general', L.cbi.DummyValue, '__time', {
			caption: L.tr('Local Time')
		});

		t.load = function (sid) {
			var id = this.id(sid);

			return L.system.getSystemInfo().then(function (info) {
				var date = new Date();
				var time = info.localtime;

				window.setInterval(function () {
					date.setTime(++time * 1000);

					$('#' + id).text('%04d/%02d/%02d %02d:%02d:%02d'.format(
						date.getUTCFullYear(),
						date.getUTCMonth() + 1,
						date.getUTCDate(),
						date.getUTCHours(),
						date.getUTCMinutes(),
						date.getUTCSeconds()
					));
				}, 1000);
			});
		};


		s.taboption('general', L.cbi.InputValue, 'hostname', {
			caption: L.tr('Hostname'),
			datatype: 'hostname'
		});


		var z = s.taboption('general', L.cbi.ListValue, 'zonename', {
			caption: L.tr('Timezone')
		});

		z.load = function (sid) {
			return $.getJSON(L.globals.resource + '/zoneinfo.json').then(function (zones) {
				var znames = [];

				for (var i = 0; i < zones.length; i++)
					for (var j = 5; j < zones[i].length; j++)
						znames.push(zones[i][j]);

				znames.sort();

				for (var i = 0; i < znames.length; i++)
					z.value(znames[i]);

				z.zones = zones;
			});
		};

		z.save = function (sid) {
			var uci = this.ucipath(sid);
			var val = this.formvalue(sid);

			if (!this.callSuper('save', sid))
				return false;

			for (var i = 0; i < z.zones.length; i++)
				for (var j = 5; j < z.zones[i].length; j++)
					if (z.zones[i][j] == val) {
						m.set(uci.config, uci.section, 'timezone', z.zones[i][0]);
						return true;
					}

			m.set(uci.config, uci.section, 'timezone', 'GMT0');
			return true;
		};


		s.tab({
			id: 'logging',
			caption: L.tr('Logging')
		});

		s.taboption('logging', L.cbi.InputValue, 'log_size', {
			caption: L.tr('System log buffer size'),
			description: L.tr('kiB'),
			placeholder: 16,
			optional: true,
			datatype: 'range(0, 32)'
		});

		s.taboption('logging', L.cbi.InputValue, 'log_ip', {
			caption: L.tr('External system log server'),
			placeholder: '0.0.0.0',
			optional: true,
			datatype: 'ip4addr'
		});

		s.taboption('logging', L.cbi.InputValue, 'log_port', {
			caption: L.tr('External system log server port'),
			placeholder: 514,
			optional: true,
			datatype: 'port'
		});

		s.taboption('logging', L.cbi.ListValue, 'conloglevel', {
			caption: L.tr('Log output level')
		}).value(8, L.tr('Debug'))
			.value(7, L.tr('Info'))
			.value(6, L.tr('Notice'))
			.value(5, L.tr('Warning'))
			.value(4, L.tr('Error'))
			.value(3, L.tr('Critical'))
			.value(2, L.tr('Alert'))
			.value(1, L.tr('Emergency'));

		s.taboption('logging', L.cbi.ListValue, 'cronloglevel', {
			caption: L.tr('Cron Log level')
		}).value(5, L.tr('Debug'))
			.value(8, L.tr('Normal'))
			.value(9, L.tr('Warning'));

		s.tab({
			id: 'language',
			caption: L.tr('Language and Style')
		});


		var l = s.taboption('language', L.cbi.ListValue, 'languages', {
			caption: L.tr('Language'),
			uci_package: 'luci',
			uci_section: 'main',
			uci_option: 'lang'
		}).value('auto', L.tr('Automatic'));

		l.load = function (sid) {
			var langs = m.get('luci', 'languages');
			for (var key in langs)
				if (key.charAt(0) != '.')
					l.value(key, langs[key]);
		};

		m.insertInto('#map-general');

		// Board Configurations

		// var m1 = new L.cbi.Map('boardconfigfile', {
		// });

		// var s1 = m1.section(L.cbi.NamedSection, 'boardconfigfile', {
		// 	caption: L.tr('Board Configuration')
		// });

		// s1.option(L.cbi.InputValue, 'serialnum', {
		// 	caption: L.tr('Router Serial Number'),
		// })

		// s1.commit = function () {
		// 	self.fGetUCISections('siteconfig', 'siteconfig').then(function (rv) {
		// 	});
		// }
		// m1.insertInto('#map-deviceinfo');

		//Maintenance Reboot
		var m2 = new L.cbi.Map('MaintenanceRebootAction', {
		});

		var s2 = m2.section(L.cbi.NamedSection, 'event', {
			caption: L.tr('Maintenance Reboot Configurations')
		});

		s2.option(L.cbi.CheckboxValue, 'enable', {
			caption: L.tr('Enable Maintenance Reboot')
		});

		s2.option(L.cbi.ListValue, 'SelectReboot', {
			caption: L.tr('Type')
		}).depends({ 'enable': '1' })
			.value("reboot", L.tr("Maintenance Reboot"));

		s2.option(L.cbi.ListValue, 'RebootType', {
			caption: L.tr('Reboot Type'),
			optional: true
		}).depends({ 'enable': '1', 'SelectReboot': 'reboot' })
			.value("system", L.tr("Software"))
			.value("hardware", L.tr("Hardware"));

		var MinuteVal = s2.option(L.cbi.DynamicList, 'Minutes', {
			caption: L.tr('Minutes'),
			optional: true,
			listlimit: 60,
			listcustom: false
		}).depends({ 'enable': '1', 'SelectReboot': 'reboot' })
			.value('', L.tr('-- Please choose --'))
			.value('*', L.tr('All'));

		MinuteVal.load = function (sid) {
			var minutes = [];
			for (var i = 0; i < 60; i++)
				minutes.push(i);
			minutes.sort();
			for (var i = 0; i < minutes.length; i++)
				MinuteVal.value(i);
		};

		var HourVal = s2.option(L.cbi.DynamicList, 'Hours', {
			caption: L.tr('Hours'),
			optional: true,
			listlimit: 24,
			listcustom: false,
		}).depends({ 'enable': '1', 'SelectReboot': 'reboot' })
			.value('', L.tr('-- Please choose --'))
			.value('*', L.tr('All'));

		HourVal.load = function (sid) {
			var hours = [];
			for (var i = 0; i < 24; i++)
				hours.push(i);
			hours.sort();
			for (var i = 0; i < hours.length; i++)
				HourVal.value(i);
		};

		var DaysVal = s2.option(L.cbi.DynamicList, 'DayOfMonth', {
			caption: L.tr('Day Of Month'),
			optional: true,
			listlimit: 31,
			listcustom: false
		}).depends({ 'enable': '1', 'SelectReboot': 'reboot' })
			.value('', L.tr('-- Please choose --'))
			.value('*', L.tr('All'));

		DaysVal.load = function (sid) {
			var days = [];
			for (var i = 1; i <= 31; i++)
				days.push(i);
			days.sort();
			for (var i = 1; i <= days.length; i++)
				DaysVal.value(i);
		};

		s2.option(L.cbi.DynamicList, 'Month', {
			caption: L.tr('Month'),
			optional: true,
			listlimit: 12,
			listcustom: false
		}).depends({ 'enable': '1', 'SelectReboot': 'reboot' })
			.value('*', L.tr('All'))
			.value('1', L.tr('January'))
			.value('2', L.tr('February'))
			.value('3', L.tr('March'))
			.value('4', L.tr('April'))
			.value('5', L.tr('May'))
			.value('6', L.tr('June'))
			.value('7', L.tr('July'))
			.value('8', L.tr('August'))
			.value('9', L.tr('September'))
			.value('10', L.tr('October'))
			.value('11', L.tr('November'))
			.value('12', L.tr('December'));

		s2.option(L.cbi.DynamicList, 'DayOfWeek', {
			caption: L.tr('Day Of Week'),
			optional: true,
			listlimit: 12,
			listcustom: false
		}).depends({ 'enable': '1', 'SelectReboot': 'reboot' })
			.value('*', L.tr('All'))
			.value('0', L.tr('Sunday'))
			.value('1', L.tr('Monday'))
			.value('2', L.tr('Tuesday'))
			.value('3', L.tr('Wednesday'))
			.value('4', L.tr('Thursday'))
			.value('5', L.tr('Friday'))
			.value('6', L.tr('Saturday'));



		s2.commit = function () {
			self.fGetUCISectionsRB('MaintenanceRebootAction', 'event').then(function (rv) {
				self.updateinterfaceconfig('Update', 'updatemaintenancereboot').then(function (rv) {

				});
			});
		}

		m2.insertInto('#map-reboot');
	}
});
