L.ui.view.extend({

	title: L.tr('VLAN'),
	description: L.tr('Do not mix tagged and untagged frames on the same physical interface. Please update after editing or deleting any changes.'),

	fGetUCISections: L.rpc.declare({
		object: 'uci',
		method: 'get',
		params: ['config', 'type'],
		expect: { values: {} }
	}),

	fCreateUCISection: L.rpc.declare({
		object: 'uci',
		method: 'add',
		params: ['config', 'type', 'values']
	}),


	fEditUCISection: L.rpc.declare({
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

	updatefirewallconfig: L.rpc.declare({
		object: 'rpc-updateportbasedvlan',
		method: 'configure',
		expect: { output: '' }
	}),

	deletefirewallconfig: L.rpc.declare({
		object: 'rpc-updateportbasedvlan',
		method: 'delete',
		expect: { output: '' }
	}),

	updatetagvlanconfig: L.rpc.declare({
		object: 'rpc-updatetagbasedvlan',
		method: 'configurevlan',
		expect: { output: '' }
	}),

	deletetagvlanconfig: L.rpc.declare({
		object: 'rpc-updatetagbasedvlan',
		method: 'delete',
		expect: { output: '' }
	}),

	pbCreateFormCallback: function () {
		var map = this;
		var pbSectionID = map.options.pbfSection;

		map.options.caption = L.tr('Port Based VLAN');

		var s = map.section(L.cbi.NamedSection, pbSectionID, {
			collabsible: true,
			anonymous: true,
			tabbed: true
		});

		s.option(L.cbi.InputValue, 'vlanid', {
			caption: L.tr('VLAN ID')
		});

		//s.option(L.cbi.ComboBox, 'interface', {
		//caption:     L.tr('Interface'),
		//optional:      'true'
		//}).value("sw_lan", L.tr('SW_LAN'))
		// .value("ewan5", L.tr('EWAN5'));

		s.option(L.cbi.ListValue, 'port0', {
			caption: L.tr('Port 0'),
			optional: 'true'
		}).value("off", L.tr('OFF'))
			.value("untagged", L.tr('Untagged'))
			.value("tagged", L.tr('Tagged'));

		//s.option(L.cbi.ListValue, 'port1', {
			//caption: L.tr('Port 1'),
			//optional: 'true'
		//}).value("off", L.tr('OFF'))
			//.value("untagged", L.tr('Untagged'))
			//.value("tagged", L.tr('Tagged'));

		//s.option(L.cbi.ListValue, 'port2', {
			//caption: L.tr('Port 2'),
			//optional: 'true'
		//}).value("off", L.tr('OFF'))
			//.value("untagged", L.tr('Untagged'))
			//.value("tagged", L.tr('Tagged'));

		//s.option(L.cbi.ListValue, 'port3', {
			//caption: L.tr('Port 3'),
			//optional: 'true'
		//}).value("off", L.tr('OFF'))
			//.value("untagged", L.tr('Untagged'))
			//.value("tagged", L.tr('Tagged'));

		//s.option(L.cbi.ListValue, 'port4', {
			//caption: L.tr('Port 4'),
			//optional: 'true'
		//}).value("off", L.tr('OFF'))
			//.value("untagged", L.tr('Untagged'))
			//.value("tagged", L.tr('Tagged'));

	},


	tbCreateFormCallback: function () {
		var map = this;
		var tbSectionID = map.options.tbfSection;

		map.options.caption = L.tr('Tagged Based VLAN');

		var s = map.section(L.cbi.NamedSection, tbSectionID, {
			collabsible: true,
			anonymous: true,
			tabbed: true
		});

		//s.option(L.cbi.InputValue, 'name', {
		//caption:     L.tr('Device Name')
		//});

		//s.option(L.cbi.InputValue, 'vid', {
		//caption:     L.tr('Tag')
		//});

		s.option(L.cbi.ListValue, 'type', {
			caption: L.tr('Type')
		})
			//.value("8021ad", L.tr('802.1AD'))
			.value("8021q", L.tr('802.1Q'));

		s.option(L.cbi.InputValue, 'ifname', {
			caption: L.tr('Parent Interface')
		});


	},

	pbfCreateForm: function (mapwidget, pbfSectionID, pbfSectionType) {
		var self = this;

		if (!mapwidget)
			mapwidget = L.cbi.Map;

		if (pbfSectionType == "Dredirect") {
			var FormContent = self.pbCreateFormCallback;
			//~ alert("create form");
		}

		var map = new mapwidget('portbasedvlanconfig', {
			prepare: FormContent,
			pbfSection: pbfSectionID
		});
		//~ alert("after create form");
		return map;


	},

	tbfCreateForm: function (mapwidget, tbfSectionID, tbfSectionType) {
		var self = this;

		if (!mapwidget)
			mapwidget = L.cbi.Map;

		if (tbfSectionType == "rule") {
			var FormContent = self.tbCreateFormCallback;
			//~ alert("create form");
		}

		var map = new mapwidget('tagbasedvlanconfig', {
			prepare: FormContent,
			tbfSection: tbfSectionID
		});
		//~ alert("after create form");
		return map;


	},

	pbRenderContents: function (rv) {
		var self = this;
		config = function () {
			return rv
		}
		var list = new L.ui.table({
			columns: [{
				caption: L.tr('VLAN ID'),
				format: function (v, n) {
					var div = $('<small />').attr('id', 'pbvlanid_%s'.format(n));
					return div.append('<strong>' + v + '</strong>');
				}
			},
			//{ 
			//caption: L.tr('Interface'),
			//format:  function(v,n) {
			//var div = $('<small />').attr('id', 'pbinterface_%s'.format(n));
			//return div.append(v);
			//}
			//},
			{
				caption: L.tr('Port 0'),
				format: function (v, n) {
					var div = $('<small />').attr('id', 'pbport0_%s'.format(n));
					return div.append(v);
				}
			}, 
			//{
				//caption: L.tr('Port 1'),
				//format: function (v, n) {
					//var div = $('<small />').attr('id', 'pbport1_%s'.format(n));
					//return div.append(v);
				//}
			//}, 
			//{
				//caption: L.tr('Port 2'),
				//format: function (v, n) {
					//var div = $('<small />').attr('id', 'pbport2_%s'.format(n));
					//return div.append(v);
				//}
			//}, 
			//{
				//caption: L.tr('Port 3'),
				//format: function (v, n) {
					//var div = $('<small />').attr('id', 'pbport3_%s'.format(n));
					//return div.append(v);
				//}
			//}, {
				//caption: L.tr('Port 4'),
				//format: function (v, n) {
					//var div = $('<small />').attr('id', 'pbport4_%s'.format(n));
					//return div.append(v);
				//}
			//},
			 {
				caption: L.tr('Actions'),
				format: function (v, n) {
					return $('<div />')
						.addClass('btn-group btn-group-sm')
						.append(L.ui.button(L.tr('Edit'), 'primary', L.tr('Edit Port Forward'))
							.click({ self: self, pbfSectionID: v, pbfSectionType: "Dredirect" }, self.pbfSectionEdit))
						.append(L.ui.button(L.tr('Delete'), 'danger', L.tr('Delete Port Forward'))
							.click({ self: self, pbSectionID: v }, self.pbSectionRemove));
				}
			}]
		});

		for (var key in rv) {
			if (rv.hasOwnProperty(key)) {
				var obj = rv[key];
				var VLANID = obj.vlanid
				var Interface = obj.interface
				var Port0 = obj.port0
				//var Port1 = obj.port1
				//var Port2 = obj.port2
				//var Port3 = obj.port3
				//var Port4 = obj.port4

				//list.row([VLANID,Interface,Port0,Port1,Port2,Port3,Port4,key]); 
				//list.row([VLANID, Port0, Port1, Port2, Port3, Port4, key]);
				list.row([VLANID, Port0, key]);
			}
		}

		$('#section_vlan_port').
			append(list.render());
	},


	tbRenderContents: function (rv) {
		var self = this;

		var list = new L.ui.table({
			columns: [{
				caption: L.tr('Device Name'),
				format: function (v, n) {
					var div = $('<small />').attr('id', 'tbname_%s'.format(n));
					return div.append('<strong>' + v + '</strong>');
				}
			}
				//,{ 
				//caption: L.tr('Tag'),
				//format:  function(v,n) {
				//var div = $('<small />').attr('id', 'tbvid_%s'.format(n));
				//return div.append(v);
				//}
				//}

				, {
				caption: L.tr('Type'),
				format: function (v, n) {
					var div = $('<small />').attr('id', 'tbtype_%s'.format(n));
					return div.append(v);
				}
			}, {
				caption: L.tr('Parent Interface'),
				format: function (v, n) {
					var div = $('<small />').attr('id', 'tbifname_%s'.format(n));
					return div.append(v);
				}
			}, {
				caption: L.tr('Actions'),
				format: function (v, n) {
					return $('<div />')
						.addClass('btn-group btn-group-sm')
						.append(L.ui.button(L.tr('Edit'), 'primary', L.tr('Edit VLAN'))
							.click({ self: self, tbfSectionID: v, tbfSectionType: "rule" }, self.tbfSectionEdit))
						.append(L.ui.button(L.tr('Delete'), 'danger', L.tr('Delete VLAN'))
							.click({ self: self, tbSectionID: v }, self.tbSectionRemove));
				}
			}]
		});

		for (var key in rv) {
			if (rv.hasOwnProperty(key)) {
				var obj = rv[key];
				var Devicename = obj.name
				//var Tag = obj.vid
				var Type = obj.type
				var ParentInterface = obj.ifname

				//list.row([Devicename,Tag,Type,ParentInterface,key]); 
				list.row([Devicename, Type, ParentInterface, key]);
			}
		}

		$('#section_vlan_tag').
			append(list.render());
	},


	pbSectionAdd: function () {
		var self = this;
		var status = $("#AddNewPortForward").text()
		// Check if VLAN ID is empty
		var pbvlan = $('#vlanid').val();
		if (!pbvlan) {
        alert("Please enter Vlan ID.");
        return;  // Stop the function if VLAN ID is empty
		}
		
		if(status != "Add")
		{
			key = uniqkey()
			var key_1 = key.split(",")[0];
			var key_2 = key.split(",")[1];
		}
		else
		{
			key_1 = null;
		}
		var vlanidlist = []
		var pbport0List = []
		var pbport1List = []
		var pbport2List = [] 
		var pbport3List = [] 
		var pbport4List = []  
		var list = config()
		for (var key in list) {
			if(key != key_1)
			{
				vlanidlist.push(list[key].vlanid)
				pbport0List.push(list[key].port0)
				pbport1List.push(list[key].port1)
				pbport2List.push(list[key].port2)
				pbport3List.push(list[key].port3)
				pbport4List.push(list[key].port4)
			}
		}
		var pbvlan = $('#vlanid').val();
		var pbport0 = $('#port0Id').val();
		var pbport1 = $('#port1Id').val();
		var pbport2 = $('#port2Id').val();
		var pbport3 = $('#port3Id').val();
		var pbport4 = $('#port4Id').val();
		var id = vlanidlist.includes(pbvlan)
		var port0 = pbport0List.includes('untagged') && pbport0 == 'untagged'
		var port1 = pbport1List.includes('untagged') && pbport1 == 'untagged'
		var port2 = pbport2List.includes('untagged') && pbport2 == 'untagged'
		var port3 = pbport3List.includes('untagged') && pbport3 == 'untagged'
		var port4 = pbport4List.includes('untagged') && pbport4 == 'untagged'
		var key;
		var SectionOptions = { vlanid: pbvlan, port0: pbport0, port1: pbport1, port2: pbport2, port3: pbport3, port4: pbport4 };
		if (status == "Add") {
			if (!id && !port0 && !port1 && !port2 && !port3 && !port4) {
				self.fCreateUCISection("portbasedvlanconfig", "redirect", SectionOptions).then(function (rv) {
					if (rv) {
						if (rv.section) {
							self.fCommitUCISection("portbasedvlanconfig").then(function (res) {
								if (res != 0) {
									alert("Error: New Port Forward Configuration");
								}
								else {
									location.reload();
								}
							});
						};
					};
				});
			}
			else {
				if(id)
				{
					alert("VLAN ID already exits");
				}
				if(port0 || port1 || port2 || port3 || port4)
				{
					alert("Do not mix untagged and untagged frames on the same physical interface");
				}
			}

		}
		else {
			if ((key_2 == pbvlan || !id) && !port0 && !port1 && !port2 && !port3 && !port4) {
				self.fEditUCISection("portbasedvlanconfig", "redirect", key_1, SectionOptions).then(function (rv) {
					if (rv) {
						if (rv.section) {
							self.fCommitUCISection("portbasedvlanconfig").then(function (res) {
								if (res != 0) {
									alert("Error: New Port Forward Configuration");
								}
								else {
									location.reload();
								}
							});

						};
					};
				});
			}
			else {
				
				if(port0 || port1 || port2 || port3 || port4)
				{
					alert("Do not mix untagged and untagged frames on the same physical interface");
				}
				else{
					alert("VLAN ID already exits")

				}
			}

		}
	},

	tbSectionAdd: function () {
		var self = this;
		var tbname = $('#field_vlantag_redirect_newRedirect_new_device').val();

		var SectionOptions = { name: tbname };
		self.fCreateUCISection("tagbasedvlanconfig", "rule", SectionOptions).then(function (rv) {
			if (rv) {
				if (rv.section) {
					self.fCommitUCISection("tagbasedvlanconfig").then(function (res) {
						if (res != 0) {
							alert("Error: New Port Forward Configuration");
						}
						else {
							location.reload();
						}
					});

				};
			};
		});

	},

	pbSectionRemove: function (ev) {
		var self = ev.data.self;
		var pbSectionID = ev.data.pbSectionID;
		self.deletefirewallconfig('delete').then(function (rv) {
			self.fDeleteUCISection("portbasedvlanconfig", "redirect", pbSectionID).then(function (rv) {
				if (rv == 0) {
					self.fCommitUCISection("portbasedvlanconfig").then(function (res) {
						if (res != 0) {
							alert("Error: Delete VLAN Configuration");
						}
						else {
							location.reload();
						}
					});
				};
			});
		});
	},

	tbSectionRemove: function (ev) {
		var self = ev.data.self;
		var tbSectionID = ev.data.tbSectionID;
		self.deletetagvlanconfig('delete').then(function (rv) {
			self.fDeleteUCISection("tagbasedvlanconfig", "rule", tbSectionID).then(function (rv) {
				if (rv == 0) {
					self.fCommitUCISection("tagbasedvlanconfig").then(function (res) {
						if (res != 0) {
							alert("Error: Delete VLAN Configuration");
						}
						else {
							location.reload();
						}
					});
				};
			});
		});
	},

	pbfSectionEdit: function (ev) {
		var self = ev.data.self;
		var data = config();
		var pbfSectionID = ev.data.pbfSectionID;
		var rowdata = data[pbfSectionID]
		$("#vlanid").val(rowdata.vlanid)
		$("#port0Id").val(rowdata.port0)
		$("#port1Id").val(rowdata.port1)
		$("#port2Id").val(rowdata.port2)
		$("#port3Id").val(rowdata.port3)
		$("#port4Id").val(rowdata.port4)
		
		document.getElementById("vlanid").disabled=true;
		$("#AddNewPortForward").text("Save")
		$('#exampleModal').modal('show');
		uniqkey = function () {
			return pbfSectionID + "," + rowdata.vlanid
		}
		// self.pbSectionAdd();

	},

	tbfSectionEdit: function (ev) {
		var self = ev.data.self;
		var tbfSectionID = ev.data.tbfSectionID;
		var tbfSectionType = ev.data.tbfSectionType;

		return self.tbfCreateForm(L.cbi.Modal, tbfSectionID, tbfSectionType).show();

	},

	execute: function () {
		var self = this;

		this.fGetUCISections("portbasedvlanconfig", "redirect").then(function (rv) {
			self.pbRenderContents(rv);
		});

		this.fGetUCISections("tagbasedvlanconfig", "rule").then(function (rv) {
			self.tbRenderContents(rv);
		});

		$('#AddNewPortForward').click(function () {
			self.pbSectionAdd();
		});



		$('#createdevice').click(function () {
			$("#AddNewPortForward").text("Add")
			$("#vlanid").val("")
			$("#port0Id").val("")
			$("#port1Id").val("")
			$("#port2Id").val("")
			$("#port3Id").val("")
			$("#port4Id").val("")


		});
		$('#AddNewTaggedVlan').click(function () {
			self.tbSectionAdd();
		});

		$('#btn_update').click(function () {
			L.ui.loading(true);
			self.updatefirewallconfig('configure').then(function (rv) {
				L.ui.loading(false);
				L.ui.dialog(
					L.tr('update vlan configuration'), [
					$('<pre />')
						.addClass('alert alert-success')
						.text(rv)
				],
					{ style: 'close' }
				);

			});

		});

		$('#tagged_btn_update').click(function () {
			L.ui.loading(true);
			self.updatetagvlanconfig('configurevlan').then(function (rv) {
				L.ui.loading(false);
				L.ui.dialog(
					L.tr('Update configuration'), [
					$('<pre />')
						.addClass('alert alert-success')
						.text(rv)
				],
					{ style: 'close' }
				);

			});
			L.ui.loading(false);

		});
	}
});

