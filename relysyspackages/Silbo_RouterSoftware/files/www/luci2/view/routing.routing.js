L.ui.view.extend({


	fGetUCISections: L.rpc.declare({
		object: 'uci',
		method: 'get',
		params: ['config', 'type'],
		expect: { values: {} }
	}),

	fCreateUCISection: L.rpc.declare({
		object: 'uci',
		method: 'add',
		params: ['config', 'type', 'name', 'values']
	}),

	fDeleteUCISection: L.rpc.declare({
		object: 'uci',
		method: 'delete',
		params: ['config', 'type', 'section']
	}),

	fCommitUCISection: L.rpc.declare({
		object: 'uci',
		method: 'commit',
		params: ['config']
	}),

	updateroutingconfig: L.rpc.declare({
		object: 'rpc-updateroutingconfig',
		method: 'configure',
		expect: { output: '' }
	}),

	deleteroutingconfig: L.rpc.declare({
		object: 'rpc-updateroutingconfig',
		method: 'delete',
		expect: { output: '' }
	}),


	fCreateForm: function (mapwidget, fSectionID, fSectionType) {
		var self = this;

		if (!mapwidget)
			mapwidget = L.cbi.Map;

		if (fSectionType == "Droutes") {
			var FormContent = self.srCreateFormCallback;
		} else if (fSectionType == "Sroutes") {
			var FormContent = self.AsrCreateFormCallback;
		} else if (fSectionType == "Rroutes") {
			var FormContent = self.sr_ipv6CreateFormCallback;
		}
		// else if (fSectionType == "Rroutes") {
		// 	var FormContent = self.AsrttCreateFormCallback;
		// }
		// else if(fSectionType == "Troutes") {
		// 	var FormContent = self.AsrtCreateFormCallback;
		// }

		var map = new mapwidget('routingconfig', {
			prepare: FormContent,
			fSection: fSectionID
		});
		return map;
	},



	fSectionEdit: function (ev) {
		var self = ev.data.self;
		var fSectionID = ev.data.fSectionID;
		var fSectionType = ev.data.fSectionType;

		return self.fCreateForm(L.cbi.Modal, fSectionID, fSectionType).show();

	},

	srCreateFormCallback: function () {
		var map = this;
		var srSectionID = map.options.fSection;


		map.options.caption = L.tr('IPv4 Custom Routes Configuration → %s').format(srSectionID);

		var s = map.section(L.cbi.NamedSection, srSectionID, {
			collabsible: true,
			anonymous: true,
			tabbed: true,
			caption: L.tr(map.options.caption)
		});

		s.option(L.cbi.DummyValue, 'name', {
			caption: L.tr('Route Name'),
		});

		s.option(L.cbi.ListValue, 'routetype', {
			caption: L.tr('Route type'),
			optional: 'true'
		}).value("unicast", L.tr('Unicast'))
			.value("blackhole", L.tr('Blackhole'))
			.value("prohibit", L.tr('Prohibit'))
			.value("unreachable", L.tr('Unreachable'))
			.value("throw", L.tr('Throw'))
			.value("broadcast", L.tr('Broadcast'))
			.value("multicast", L.tr('Multicast'));

		s.option(L.cbi.ComboBox, 'tableid', {
			caption: L.tr('Table ID'),
			optional: 'true'
		}).value("main", L.tr('Table Main'));



		s.option(L.cbi.InputValue, 'target', {
			caption: L.tr('Target'),
			datatype: 'ip4addr',
			optional: true
		});

		s.option(L.cbi.InputValue, 'ipv4netmask', {
			caption: L.tr('IPv4 Netmask'),
			datatype: 'netmask4',
			optional: true,
		});

		s.option(L.cbi.InputValue, 'ipv4gateway', {
			caption: L.tr('IPv4 Gateway'),
			datatype: 'ip4addr',
			optional: true,
		});

		s.option(L.cbi.Interface_List_custom, 'interface', {
			caption: L.tr('Interface'),
			optional: true,
		});

		s.option(L.cbi.InputValue, 'metric', {
			caption: L.tr('Metric'),
			placeholder: "0",
			datatype: 'uinteger',
			optional: true,

		});

	},


	srRenderContents: function (rv) {
		var self = this;

		var len = Object.keys(rv).length;
		if (len > 0) {
			var list = new L.ui.table({
				columns: [{
					caption: L.tr('Route Name'),
					format: function (v, n) {
						var div = $('<p />').attr('id', 'srRoutename_%s'.format(n));
						return div.append('<strong>' + v + '</strong>');
					}
				}, {
					caption: L.tr('Route type'),
					format: function (v, n) {
						var div = $('<p />').attr('id', 'srRoutetype_%s'.format(n));
						return div.append(v);
					}
				}, {
					caption: L.tr('Table ID'),
					format: function (v, n) {
						var div = $('<p />').attr('id', 'srRoutetype_%s'.format(n));
						return div.append(v);
					}
				}, {
					caption: L.tr('Target'),
					format: function (v, n) {
						var div = $('<p />').attr('id', 'srTarget_%s'.format(n));
						return div.append(v);
					}
				}, {
					caption: L.tr('IPv4 Netmask'),
					format: function (v, n) {
						var div = $('<p />').attr('id', 'srIPV4Netmask_%s'.format(n));
						return div.append(v);
					}
				}, {
					caption: L.tr('IPv4 Gateway'),
					format: function (v, n) {
						var div = $('<p />').attr('id', 'srIPV4Gateway_%s'.format(n));
						return div.append(v);
					}
				}, {
					caption: L.tr('Interface'),
					format: function (v, n) {
						var div = $('<p />').attr('id', 'srInterface_%s'.format(n));
						return div.append(v);
					}
				}, {
					caption: L.tr('Metric'),
					format: function (v, n) {
						var div = $('<p />').attr('id', 'srMetric_%s'.format(n));
						return div.append(v);
					}
				}, {
					caption: L.tr('Actions'),
					format: function (v, n) {
						return $('<div />')
							.addClass('btn-group btn-group-sm')
							.append(L.ui.button(L.tr('Edit'), 'primary', L.tr('Edit Custom Routes'))
								.click({ self: self, fSectionID: v, fSectionType: "Droutes" }, self.fSectionEdit))
							.append(L.ui.button(L.tr('Delete'), 'danger', L.tr('Delete Custom Routes'))
								.click({ self: self, srSectionID: v }, self.srSectionRemove));
					}
				}]
			});

			for (var key in rv) {
				if (rv.hasOwnProperty(key)) {
					var obj = rv[key];
					var Name = obj.name
					var Sourcemap = obj.interface
					var SourceIP = obj.target;
					var SourceNetmask = obj.ipv4netmask
					var Sourcemetric = obj.metric
					var Sourcegateway = obj.ipv4gateway
					var Sourcetype = obj.routetype
					var Tableid = obj.tableid

					list.row([Name, Sourcetype, Tableid, SourceIP, SourceNetmask, Sourcegateway, Sourcemap, Sourcemetric, key]);
				}
			}


			$('#section_staticroutes_port').append(list.render());
		} else {
			L.ui.showNoConfigMessage('IPv4 Custom Routes', 'No-IPv4-Config')
		}



	},


	srSectionRemove: function (ev) {
		var self = ev.data.self;
		var srSectionID = ev.data.srSectionID;
		var infoIPv4 = `${srSectionID} IPv4 Routes`
		L.ui.confirmDelete(ev, infoIPv4, function (res) {
			if (res === 1) {
				self.deleteroutingconfig('delete').then(function (rv) {
					self.fDeleteUCISection("routingconfig", "routes", srSectionID).then(function (rv) {
						if (rv == 0) {
							self.fCommitUCISection("routingconfig").then(function (res) {
								if (res != 0) {
									alert("Error: Delete Static Routes Configuration");
								}
								else {
									setTimeout(() => {
										location.reload();
									}, 1500);

								}
							});
						};
					});
				});
			}
		});



	},



	srSectionAdd: function () {
		var self = this;
		var srName = $('#field_staticroutes_routes_newRoutes_name').val();
		var srInterface = $('#field_staticroutes_routes_newRoutes_interface').val();
		var srTarget = $('#field_staticroutes_routes_newRoutes_target').val();
		var srIPV4Netmask = $('#field_staticroutes_routes_newRoutes_ipv4netmask').val();
		var srMetric = $('#field_staticroutes_routes_newRoutes_metric').val();
		var srIPV4Gateway = $('#field_staticroutes_routes_newRoutes_ipv4gateway').val();
		var srRoutetype = $('#field_staticroutes_routes_newRoutes_routetype').val();
		var srTable = $('#field_staticroutes_routes_newRoutes_Table').val();
		var srTargetcheck = false;

		if (srInterface === "custom") {
			srInterface = $('#field_staticroutes_routes_newRoutes_inter').val();
		}

		if (srTable === "custom") {
			srTable = $('#field_staticroutes_routes_newRoutes_Table1').val();
		}
		// Regular expression pattern for IPv4 validation
		var ipv4Pattern = /^(\d{1,3}\.){3}\d{1,3}$/;

		// Check if the input matches the IPv4 pattern
		if (ipv4Pattern.test(srTarget)) {
			srTargetcheck = true; // Valid IPv4 address
		}
		var SectionOptions = { name: srName, interface: srInterface, target: srTarget, ipv4netmask: srIPV4Netmask, metric: srMetric, ipv4gateway: srIPV4Gateway, routetype: srRoutetype, tableid: srTable };
		self.fCreateUCISection("routingconfig", "routes", srName, SectionOptions).then(function (rv) {
			if (rv) {
				if (rv.section) {
					self.fCommitUCISection("routingconfig").then(function (res) {
						if (res != 0) {
							alert("Error: New Static Routes Configuration");
						}
						else {
							location.reload();
						}
					});

				};
			};
		});


	},

	AsrCreateFormCallback: function () {
		var map = this;
		var AsrSectionID = map.options.fSection;

		map.options.caption = L.tr('IPv4 Custom Rule Configurations → %s').format(AsrSectionID);


		var s = map.section(L.cbi.NamedSection, AsrSectionID, {
			collabsible: true,
			anonymous: true,
			tabbed: true,
			caption: L.tr(map.options.caption)
		});

		s.option(L.cbi.DummyValue, 'name', {
			caption: L.tr('Rule Name'),
		});

		s.option(L.cbi.ListValue, 'ruletype', {
			caption: L.tr('Rule type'),
			optional: 'true'
		}).value("unicast", L.tr('Unicast'))
			.value("prohibit", L.tr('Prohibit'))
			.value("blackhole", L.tr('Blackhole'))
			.value("unreachable", L.tr('Unreachable'));

		s.option(L.cbi.InputValue, 'table', {
			caption: L.tr('Table ID'),
			placeholder: "100",
			datatype: 'uinteger',
			optional: true,
		});


		s.option(L.cbi.InputValue, 'to', {
			caption: L.tr('	Target(To)'),
			datatype: 'ip4addr',
			optional: true
		});

		s.option(L.cbi.InputValue, 'ipv4netmask', {
			caption: L.tr('IPv4 Netmask'),
			datatype: 'netmask4',
			optional: true,
		});


		s.option(L.cbi.InputValue, 'from', {
			caption: L.tr('From'),
			datatype: 'ip4addr',
			optional: true,
		});

		s.option(L.cbi.InputValue, 'priority', {
			caption: L.tr('Priority'),
			datatype: 'uinteger',
			optional: 'true'
		});

		s.option(L.cbi.CheckboxValue, 'enable_iif', {
			caption: L.tr('Enable IIF'),
		});

		s.option(L.cbi.Interface_List_custom, 'interface_iif', {
			caption: L.tr('Interface'),
			optional: true
		}).depends({ 'enable_iif': "1" });

		s.option(L.cbi.CheckboxValue, 'enable_oif', {
			caption: L.tr('Enable OIF'),
		});

		s.option(L.cbi.Interface_List_custom, 'interface_oif', {
			caption: L.tr('Interface'),
			optional: true
		}).depends({ 'enable_oif': "1" });

		s.option(L.cbi.CheckboxValue, 'enable_fwmark', {
			caption: L.tr('Enable fwmark'),
		});

		s.option(L.cbi.InputValue, 'Hex_fwmark', {
			caption: L.tr('Mark'),
			datatype: 'rt_hexadecimal',
			optional: true
		}).depends({ 'enable_fwmark': "1" });

	},

	AsrRenderContents: function (rv) {
		var self = this;
		var len = Object.keys(rv).length;
		if (len > 0) {
			var list = new L.ui.table({
				columns: [{
					caption: L.tr('Rule Name'),
					format: function (v, n) {
						var div = $('<p />').attr('id', 'AsrName_%s'.format(n));
						return div.append('<strong>' + v + '</strong>');
					}
				}, {
					caption: L.tr('Rule Type'),
					format: function (v, n) {
						var div = $('<p />').attr('id', 'AsrInterface_%s'.format(n));
						return div.append(v);
					}
				}, {
					caption: L.tr('Table ID'),
					format: function (v, n) {
						var div = $('<p />').attr('id', 'AsrTable_%s'.format(n));
						return div.append(v);
					}
				},
				{
					caption: L.tr('Target(To)'),
					format: function (v, n) {
						var div = $('<p />').attr('id', 'AsrTo_%s'.format(n));
						return div.append(v);
					}
				}, {
					caption: L.tr('IPv4 Netmask'),
					format: function (v, n) {
						var div = $('<p />').attr('id', 'AsrIPV4Netmask_%s'.format(n));
						return div.append(v);
					}
				}, {
					caption: L.tr('From'),
					format: function (v, n) {
						var div = $('<p />').attr('id', 'AsrFrom_%s'.format(n));
						return div.append(v);
					}
				}, {
					caption: L.tr('Priority'),
					format: function (v, n) {
						var div = $('<p />').attr('id', 'AsrPriority_%s'.format(n));
						return div.append(v);
					}
				}, {
					caption: L.tr('Actions'),
					format: function (v, n) {
						return $('<div />')
							.addClass('btn-group btn-group-sm')
							.append(L.ui.button(L.tr('Edit'), 'primary', L.tr('Edit Custom Tables Rules'))
								.click({ self: self, fSectionID: v, fSectionType: "Sroutes" }, self.fSectionEdit))
							.append(L.ui.button(L.tr('Delete'), 'danger', L.tr('Delete Custom Tables Rules'))
								.click({ self: self, AsrSectionID: v }, self.AsrSectionRemove));
					}
				}]
			});

			for (var key in rv) {
				if (rv.hasOwnProperty(key)) {
					var obj = rv[key];
					var ruleName = obj.name
					var Ruletype = obj.ruletype
					var Sourceto = obj.to
					var Sourcenetmask = obj.ipv4netmask
					var Sourcetable = obj.table
					var Sourcefrom = obj.from
					var Sourcepriority = obj.priority

					list.row([ruleName, Ruletype, Sourcetable, Sourceto, Sourcenetmask, Sourcefrom, Sourcepriority, key]);
				}
			}


			$('#section_advancedstaticroutes_Asr').append(list.render());
		} else {
			L.ui.showNoConfigMessage('IPv4 Custom Rules', 'No-customtableRules-Config')
		}


	},

	AsrSectionRemove: function (ev) {
		var self = ev.data.self;

		var AsrSectionID = ev.data.AsrSectionID;

		var infoIPv4custom = `${AsrSectionID} IPv4 Custome Rule`
		L.ui.confirmDelete(ev, infoIPv4custom, function (res) {
			if (res === 1) {
				self.deleteroutingconfig('Delete').then(function (rv) {
					self.fDeleteUCISection("routingconfig", "rule", AsrSectionID).then(function (rv) {
						if (rv == 0) {
							self.fCommitUCISection("routingconfig").then(function (res) {

								if (res != 0) {
									alert("Error: Delete Advanced Static Routes Configuration");
								}
								else {
									document.cookie = "LastActiveTab=TabAsr";
									document.cookie = "LastAction=delete";
									setTimeout(() => {
										location.reload();
									}, 1500);

								}
								//});
							});
						};
					});
				});
			}
		})



	},


	AsrSectionAdd: function () {
		var self = this;
		var Asrrulename = $('#section_advancedstaticroutes_Asr_name').val();
		var Asrruletype = $('#section_advancedstaticroutes_Asr_ruletype').val();
		var AsrTo = $('#section_advancedstaticroutes_Asr_to').val();
		var AsrIPV4Netmask = $('#section_advancedstaticroutes_Asr_ipv4netmask').val();
		var AsrTable = $('#section_advancedstaticroutes_Asr_table').val();
		var AsrFrom = $('#section_advancedstaticroutes_Asr_from').val();
		var AsrPriority = $('#section_advancedstaticroutes_Asr_priority').val();
		var AsrTocheck = false;


		if (AsrTable === "custom") {
			AsrTable = $('#section_advancedstaticroutes_Asr_table1').val();
		}


		// Regular expression pattern for IPv4 validation
		var ipv4Pattern = /^(\d{1,3}\.){3}\d{1,3}$/;

		// Check if the input matches the IPv4 pattern
		if (ipv4Pattern.test(AsrTo)) {
			AsrTocheck = true; // Valid IPv4 address
		}

		var SectionOptions = { name: Asrrulename, to: AsrTo, ipv4netmask: AsrIPV4Netmask, ruletype: Asrruletype, from: AsrFrom, table: AsrTable, from: AsrFrom, priority: AsrPriority };
		self.fCreateUCISection("routingconfig", "rule", Asrrulename, SectionOptions).then(function (rv) {
			if (rv) {
				if (rv.section) {
					self.fCommitUCISection("routingconfig").then(function (res) {
						if (res != 0) {
							alert("Error:New Advanced Static Routes Configuration");
						}
						else {
							document.cookie = "LastActiveTab=TabAsr";
							document.cookie = "LastAction=add";
							location.reload();
						}
					});

				};
			};
		});


	},

	sr_ipv6CreateFormCallback: function () {
		var map = this;
		var sr_ipv6SectionID = map.options.fSection;


		map.options.caption = L.tr('IPv6 Custom Routes Configuration → %s').format(sr_ipv6SectionID);

		var s = map.section(L.cbi.NamedSection, sr_ipv6SectionID, {
			collabsible: true,
			anonymous: true,
			tabbed: true,
			caption: L.tr(map.options.caption)
		});

		s.option(L.cbi.DummyValue, 'name', {
			caption: L.tr('Route Name'),
		});

		s.option(L.cbi.ListValue, 'routetype', {
			caption: L.tr('Route type'),
			optional: 'true'
		}).value("unicast", L.tr('Unicast'))
			.value("blackhole", L.tr('Blackhole'))
			.value("prohibit", L.tr('Prohibit'))
			.value("unreachable", L.tr('Unreachable'))
			.value("throw", L.tr('Throw'))
			.value("broadcast", L.tr('Broadcast'))
			.value("multicast", L.tr('Multicast'));

		// s.option(L.cbi.ComboBox, 'tableid', {
		// 	caption: L.tr('Table ID'),
		// 	optional: 'true'
		// }).value("main", L.tr('Table Main'));



		s.option(L.cbi.InputValue, 'target', {
			caption: L.tr('Target'),
			datatype: 'ip6addr',
			optional: true
		});

		s.option(L.cbi.InputValue, 'ipv6prefix', {
			caption: L.tr('IPv4 Prefix'),
			datatype: 'uinteger',
			optional: true,
		});

		s.option(L.cbi.InputValue, 'ipv6gateway', {
			caption: L.tr('IPv6 Gateway'),
			datatype: 'ip6addr',
			optional: true,
		});

		s.option(L.cbi.Interface_List_custom, 'interface', {
			caption: L.tr('Interface'),
			optional: true,
		});

		s.option(L.cbi.InputValue, 'metric', {
			caption: L.tr('Metric'),
			placeholder: "0",
			datatype: 'uinteger',
			optional: true,

		});

	},


	sr_ipv6RenderContents: function (rv) {
		var self = this;
		var len = Object.keys(rv).length;
		if (len > 0) {
			var list = new L.ui.table({
				columns: [{
					caption: L.tr('Route Name'),
					format: function (v, n) {
						var div = $('<p />').attr('id', 'sr_ipv6Routename_%s'.format(n));
						return div.append('<strong>' + v + '</strong>');
					}
				}, {
					caption: L.tr('Route type'),
					format: function (v, n) {
						var div = $('<p />').attr('id', 'sr_ipv6Routetype_%s'.format(n));
						return div.append(v);
					}
				},
				//{
				// 	caption: L.tr('Table ID'),
				// 	format: function (v, n) {
				// 		var div = $('<p />').attr('id', 'sr_ipv6Routetype_%s'.format(n));
				// 		return div.append(v);
				// 	}
				// }, 
				{
					caption: L.tr('Target'),
					format: function (v, n) {
						var div = $('<p />').attr('id', 'sr_ipv6Target_%s'.format(n));
						return div.append(v);
					}
				}, {
					caption: L.tr('IPv6 Prefix'),
					format: function (v, n) {
						var div = $('<p />').attr('id', 'sr_IPV6Netmask_%s'.format(n));
						return div.append(v);
					}
				}, {
					caption: L.tr('IPv6 Gateway'),
					format: function (v, n) {
						var div = $('<p />').attr('id', 'sr_IPV6Gateway_%s'.format(n));
						return div.append(v);
					}
				}, {
					caption: L.tr('Interface'),
					format: function (v, n) {
						var div = $('<p />').attr('id', 'sr_ipv6Interface_%s'.format(n));
						return div.append(v);
					}
				}, {
					caption: L.tr('Metric'),
					format: function (v, n) {
						var div = $('<p />').attr('id', 'sr_ipv6Metric_%s'.format(n));
						return div.append(v);
					}
				}, {
					caption: L.tr('Actions'),
					format: function (v, n) {
						return $('<div />')
							.addClass('btn-group btn-group-sm')
							.append(L.ui.button(L.tr('Edit'), 'primary', L.tr('Edit Custom Routes'))
								.click({ self: self, fSectionID: v, fSectionType: "Rroutes" }, self.fSectionEdit))
							.append(L.ui.button(L.tr('Delete'), 'danger', L.tr('Delete Custom Routes'))
								.click({ self: self, sr_ipv6SectionID: v }, self.sr_ipv6SectionRemove));
					}
				}]
			});

			for (var key in rv) {
				if (rv.hasOwnProperty(key)) {
					var obj = rv[key];
					var Name = obj.name
					var Sourcemap = obj.interface
					var SourceIP = obj.target;
					var SourceNetmask = obj.ipv6prefix
					var Sourcemetric = obj.metric
					var Sourcegateway = obj.ipv6gateway
					var Sourcetype = obj.routetype
					//var Tableid = obj.tableid

					list.row([Name, Sourcetype, SourceIP, SourceNetmask, Sourcegateway, Sourcemap, Sourcemetric, key]);
				}
			}
			$('#section_staticroutes6_port').append(list.render());


		} else {
			L.ui.showNoConfigMessage('IPv6 Custom Routes', 'No-IPv6-Config')
		}

	},


	sr_ipv6SectionRemove: function (ev) {
		var self = ev.data.self;
		var sr_ipv6SectionID = ev.data.sr_ipv6SectionID;
		var infoIPv6 = `${sr_ipv6SectionID} IPv6 Routes`
		L.ui.confirmDelete(ev, infoIPv6, function (res) {
			if (res === 1) {
				self.deleteroutingconfig('delete').then(function (rv) {
					self.fDeleteUCISection("routingconfig", "route6", sr_ipv6SectionID).then(function (rv) {
						if (rv == 0) {
							self.fCommitUCISection("routingconfig").then(function (res) {
								if (res != 0) {
									alert("Error: Delete Static Routes Configuration");
								}
								else {
									document.cookie = "LastActiveTab=Tabsr6";
									document.cookie = "LastAction=delete";
									setTimeout(() => {
										location.reload();
									}, 1500);

								}
							});
						};
					});
				});
			}
		});



	},



	sr_ipv6SectionAdd: function () {
		var self = this;
		var sr_ipv6_Name = $('#field_staticroutes_routes_newRoutes_name_ipv6').val();
		var sr_ipv6_Interface = $('#field_staticroutes_routes_newRoutes_interface_ipv6').val();
		var sr_ipv6_Target = $('#field_staticroutes_routes_newRoutes_target_ipv6').val();
		var sr_ipv6_prefix = $('#field_staticroutes_routes_newRoutes_ipv6prefix').val();
		var sr_ipv6_Metric = $('#field_staticroutes_routes_newRoutes_ipv6_metric').val();
		var sr_ipv6_Gateway = $('#field_staticroutes_routes_newRoutes_ipv6gateway').val();
		var sr_ipv6_Routetype = $('#field_staticroutes_routes_newRoutes_routetype_ipv6').val();
		//var sr_ipv6_Table = $('#field_staticroutes_routes_newRoutes_Table_ipv6').val();
		//var sr_ipv6_Target = false;

		if (sr_ipv6_Interface === "custom") {
			sr_ipv6_Interface = $('#field_staticroutes_routes_newRoutes_interface_ipv6').val();
		}

		// if (sr_ipv6_Table === "custom") {
		// 	sr_ipv6_Table = $('#field_staticroutes_routes_newRoutes_Table3').val();
		// }

		//var ipv6Pattern = /^((?:[0-9A-Fa-f]{1,4}:){7}[0-9A-Fa-f]{1,4}|(?:[0-9A-Fa-f]{1,4}:){1,7}:|(?:[0-9A-Fa-f]{1,4}:){1,6}:[0-9A-Fa-f]{1,4}|(?:[0-9A-Fa-f]{1,4}:){1,5}(?::[0-9A-Fa-f]{1,4}){1,2}|(?:[0-9A-Fa-f]{1,4}:){1,4}(?::[0-9A-Fa-f]{1,4}){1,3}|(?:[0-9A-Fa-f]{1,4}:){1,3}(?::[0-9A-Fa-f]{1,4}){1,4}|(?:[0-9A-Fa-f]{1,4}:){1,2}(?::[0-9A-Fa-f]{1,4}){1,5}|[0-9A-Fa-f]{1,4}:(?:(?::[0-9A-Fa-f]{1,4}){1,6})|:(?:(?::[0-9A-Fa-f]{1,4}){1,7}|:)|fe80:(?::[0-9A-Fa-f]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(?::0{1,4}){0,1}:){0,1}(?:\d{1,3}\.){3}\d{1,3}|(?:[0-9A-Fa-f]{1,4}:){1,4}:(?:\d{1,3}\.){3}\d{1,3})$/;


		// Check if the input matches the IPv6 pattern
		//if (ipv6Pattern.test(sr_ipv6_Target)) {
		//	sr_ipv6_Target = true; // Valid IPv4 address
		//}
		var SectionOptions = { name: sr_ipv6_Name, interface: sr_ipv6_Interface, target: sr_ipv6_Target, ipv6prefix: sr_ipv6_prefix, metric: sr_ipv6_Metric, ipv6gateway: sr_ipv6_Gateway, routetype: sr_ipv6_Routetype };
		self.fCreateUCISection("routingconfig", "route6", sr_ipv6_Name, SectionOptions).then(function (rv) {
			if (rv) {
				if (rv.section) {
					self.fCommitUCISection("routingconfig").then(function (res) {
						if (res != 0) {
							alert("Error: New Static Routes Configuration");
						}
						else {
							document.cookie = "LastActiveTab=Tabsr6";
							document.cookie = "LastAction=add";
							location.reload();
						}
					});

				};
			};
		});


	},




	getCookie: function (cname) {
		var name = cname + "=";
		var ca = document.cookie.split(';');

		for (var i = 0; i < ca.length; i++) {
			var c = ca[i];

			while (c.charAt(0) == ' ')
				c = c.substring(1);
			if (c.indexOf(name) == 0)
				return c.substring(name.length, c.length);
		}
		return "";
	},

	execute: function () {
		var self = this;
		L.ui.createNote(
			'NOTE',
			'After editing or deleting, please click the Update button to apply the saved configuration.',
			{ type: 'warn', variant: 'inline', appendTo: '#Update-Routing-Note' }
		);
		var activeTab = self.getCookie("LastActiveTab");
		var action = self.getCookie("LastAction");
		if (action) {
			$('.TabC').removeClass('active');
			$('.' + activeTab).addClass('active');
			document.cookie = "LastAction=";
		}
		else {
			$('.TabC').removeClass('active');
			$('.Tabsr').addClass('active');
		}
		this.fGetUCISections("routingconfig", "routes").then(function (rv) {
			self.srRenderContents(rv);
		});
		this.fGetUCISections("routingconfig", "rule").then(function (rv) {
			self.AsrRenderContents(rv);
		});
		this.fGetUCISections("routingconfig", "route6").then(function (rv) {
			self.sr_ipv6RenderContents(rv);
		});
		// this.fGetUCISections("routingconfig","table").then(function(rv) {
		// 	self.AsrtRenderContents(rv);   
		// });



		$('#AddNewStaticRoutes').click(function () {
			self.srSectionAdd();
		});

		$('#AddNewAdvancedstaticRule').click(function () {
			self.AsrSectionAdd();
		});


		$('#AddNewipv6_StaticRoutes').click(function () {
			self.sr_ipv6SectionAdd();
		});


		// $('#AddNewAdvancedstatictable').click(function() {          
		// 	self.AsrtSectionAdd();
		// });



		$('#btn_update').click(function () {
			L.ui.loading(true);
			self.updateroutingconfig('configure').then(function (rv) {
				L.ui.loading(false);
				L.ui.showAlert(
					'success',
					'Update Complete',
					rv + `d successfully`
				);
			});

		});
	}
});
