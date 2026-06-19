L.ui.view.extend({

	fGetUCISections: L.rpc.declare({
		object: 'uci',
		method: 'get',
		params: [ 'config', 'type' ],
		expect: { values: {} }
	}),
	
	fCreateUCISection:  L.rpc.declare({
		object: 'uci',
		method: 'add',
		params: [ 'config', 'type','name', 'values' ]
	}),
	
	fDeleteUCISection:  L.rpc.declare({
		object: 'uci',
		method: 'delete',
		params: [ 'config','type','section' ]
	}),
	
	fCommitUCISection:  L.rpc.declare({
		object: 'uci',
		method: 'commit',
		params: [ 'config' ]
	}),

	updatefirewallconfig: L.rpc.declare({
        object: 'rpc-updatecustomfirewallconfig',
        method: 'configure',
        expect: { output: '' }
    }),
    
	
	fCreateForm: function(mapwidget, fSectionID, fSectionType)
	{
		var self = this;
		
		if (!mapwidget)
			mapwidget = L.cbi.Map;
		
		if(fSectionType == "Dredirect") {
			var FormContent = self.pfCreateFormCallback;
			//~ alert("create form");
		}
		
		var map = new mapwidget('customfirewall', {
			prepare:    FormContent,
			fSection:   fSectionID
		});
		//~ alert("after create form");
		return map;
	},
	
	fSectionEdit: function(ev) {
		var self = ev.data.self;
		var fSectionID = ev.data.fSectionID;
		var fSectionType = ev.data.fSectionType;
		
		return self.fCreateForm(L.cbi.Modal, fSectionID, fSectionType).show();
		
	},
	
	pfCreateFormCallback: function()
	{
		var map = this;
		var pfSectionID = map.options.fSection;
		
		// map.options.caption = L.tr('Port Forward Configuration');
		
		// var s = map.section(L.cbi.NamedSection, pfSectionID, {
		// 	collabsible: true,
		// 	anonymous:   true,
		// 	 tabbed:      true
		// });

		map.options.caption = L.tr('Port Forward Configuration → %s').format(pfSectionID);

		var s = map.section(L.cbi.NamedSection, pfSectionID, {
			collabsible: true,
			anonymous: true,
			tabbed: true,
			caption: L.tr(map.options.caption)
		});
		
		s.option(L.cbi.DummyValue, 'name', {
				caption:     L.tr('Name')
		});
		
		s.option(L.cbi.ComboBox, 'proto', {
			caption:     L.tr('Protocol'),
			optional:      'true'
		}).value("tcp udp", L.tr('TCP+UDP'))
		  .value("tcp", L.tr('TCP'))
		  .value("udp", L.tr('UDP'));
		 
		
		s.option(L.cbi.InputValue, 'src_ip', {
			caption:     L.tr('Source IP Address[Optional]'),
			description: L.tr('Only match incoming traffic from this source IP or range.'),
			datatype:    'ip4addr',
            optional: true 	
		});	
		
		s.option(L.cbi.InputValue, 'src_port', {
			caption:     L.tr('Source port[Optional]'),
			description: L.tr('Only match incoming traffic originating from the given source port or port range on the client host'),
			datatype:    'portrange',
		    optional: true,
			placeholder: "any",
		 });

				
		s.option(L.cbi.InputValue, 'dest_ip', {
			caption:     L.tr('Loopback IP Address'),
			description: L.tr('Only match incoming traffic with this Loopback IP or range.'),
			datatype:    'ip4addr',
			optional: true, 	

		});
		
		s.option(L.cbi.InputValue, 'dest_port', {
			caption:     L.tr('port'),
			datatype:    'portrange',
			placeholder: "any",
		    optional: true,
			description: L.tr('Only match incoming traffic originating with the given port or port range on the client host'),
		});

        s.option(L.cbi.ListValue, 'action', {
                caption: L.tr('Action'),
                })
                .value("none",L.tr("Choose Option"))
                .value("dnat",L.tr("DNAT"))
                .value("snat",L.tr("SNAT"));       
  
        s.option(L.cbi.InputValue, 'IP', {
			caption:     L.tr('Internal IP Address'),
			datatype:    'ip4addr',
		});
		
		s.option(L.cbi.InputValue, 'port', {
			caption:     L.tr('Internal Port'),
			datatype:    'portrange',
			placeholder: "any",
		    optional: true,
			description: L.tr('Redirect matched incoming traffic to the given port on the internal host')
		});
      
	     
	},
		
	pfRenderContents: function(rv)
	{
		var self = this;
		var len = Object.keys(rv).length
		if (len > 0) {
			var list = new L.ui.table({
				columns: [ { 
					caption: L.tr('Name'),
					format:  function(v,n) {
						var div = $('<p />').attr('id', 'pfName_%s'.format(n));
						return div.append('<strong>'+v+'</strong>');
					}
				},{ 
					caption: L.tr('Match'),
					format:  function(v,n) {
						var div = $('<small />').attr('id', 'pfMatch_%s'.format(n));
						return div.append(v);
					}
				},{ 
					caption: L.tr('Forward To'),
					format:  function(v,n) {
						var div = $('<small />').attr('id', 'pfForwardTo_%s'.format(n));
						return div.append(v);
					}
				},{
					caption: L.tr('Actions'),
					format:  function(v, n) {
						return $('<div />')
							.addClass('btn-group btn-group-sm')
							.append(L.ui.button(L.tr('Edit'), 'primary', L.tr('Edit Port Forward'))
								.click({ self: self, fSectionID: v, fSectionType: "Dredirect" }, self.fSectionEdit))
							//.append(L.ui.button(L.tr('Update'), 'success', L.tr('Update rule'))
							//	.click({ self: self, pfSectionID: v,fSectionType: "Dredirect" }, self.pfSectionUpdate))
							.append(L.ui.button(L.tr('Delete'), 'danger', L.tr('Delete Port Forward'))
								.click({ self: self, pfSectionID: v }, self.pfSectionRemove));
					}
				}]
			});
			
			for (var key in rv) {                                                                           
				if (rv.hasOwnProperty(key)) {            
					var obj = rv[key];                                                                  
					var SourceIP = obj.dest_ip;
					var SourceZone = obj.src;
					var SourcePort = obj.dest_port;
					var SourceMac = obj.src_mac;
					var SourceDIP = obj.src_dip;
					var SourceDPort = obj.src_dport;
					var proto = obj.proto;
					var Target = obj.target;
					var srctxt = '';
					var viatxt = '';
					var Match  = '';	
					var prototxt = '';
					var ForwardTo = '';          
					
					if ( Target != "DNAT" ) {
						continue;
					}

					if (!proto)
						proto = "TCP+UDP";
					var prototxt = "IPv4-"+proto;
					
					if (!SourceZone)
						SourceZone = "any zone";
					if (!SourceIP)
						SourceIP = "any host";
					//if (!SourceDIP)
						//SourceDIP = "any router IP";
				
					if (SourcePort && SourceMac) {
						var srctxt ="From "+"<strong>"+SourceIP+"</strong>"+" in "+"<strong>"+SourceZone+"</strong>"+" with port "+"<strong>"+SourcePort+"</strong>"+" and "+"<strong>"+SourceMac+"</strong>";
					}
					else if (SourcePort) {
						var srctxt = "From "+"<strong>"+SourceIP+"</strong>"+" in "+"<strong>"+SourceZone+"</strong>"+" with port "+"<strong>"+SourcePort+"</strong>";
					} 
					else if (SourceMac) {
						var srctxt ="From "+"<strong>"+SourceIP+"</strong>"+" in "+"<strong>"+SourceZone+"</strong>" +" with source "+"<strong>"+SourceMac+"</strong>";
					}
					else {
						var srctxt ="From "+"<strong>"+SourceIP+"</strong>"+" in "+"<strong>"+SourceZone+"</strong>";
					}
					//if (SourceDIP && SourceDPort) {
						//var viatxt ="Via "+"<strong>"+SourceDIP+"</strong>"+" at "+"<strong>"+SourceDPort+"</strong>";
					//}
					//else {
						//var viatxt = "Via "+"<strong>"+SourceDIP+"</strong>";
					//}
					var Match =prototxt+"<br />"+srctxt+"<br />"+viatxt ;
					
					var DestnZone = obj.dest_zone;
					var DestnIP = obj.IP;
					var DestnPort = obj.port;
					
					if(!DestnZone)
						DestnZone = "any zone";
					if(!DestnIP)
						DestnIP = "any host";
					if (!DestnPort)
						DestnPort = obj.src_dport;
					
					if (DestnPort) {
						var ForwardTo ="IP "+"<strong>"+DestnIP+"</strong>"+", port "+"<strong>"+DestnPort+"</strong>"+" in "+"<strong>"+DestnZone+"</strong>";
					}
					else {
						var ForwardTo ="IP "+"<strong>"+DestnIP+"</strong>"+" in "+"<strong>"+DestnZone+"</strong>";          
					}
					list.row([ obj.name, Match, ForwardTo, key ]);
				}                                                                   
			}    	
			
			$('#section_firewall_port').append(list.render());		
		}
		else
		{
			L.ui.showNoConfigMessage('LoopBack Rule', 'No-LoopBack-Config')
		}
	},

	// pfSectionRemove: function(ev) {
	// 	var self = ev.data.self;
	// 	var pfSectionID = ev.data.pfSectionID;
		
	// 	self.fDeleteUCISection("customfirewall","redirect",pfSectionID).then(function(rv){
	// 		if(rv == 0){
	// 			self.fCommitUCISection("customfirewall").then(function(res){
	// 				//self.updatefirewallconfig(pfSectionID).then(function(rv) {
	// 					if (res != 0){
	// 						alert("Error: Delete Port Forward Configuration");
	// 					}
	// 					else {
	// 						location.reload();
	// 					}
	// 				//});
	// 			});
	// 		};
	// 	});
	// },

	pfSectionRemove: function (ev) {
		var self = ev.data.self;
		var pfSectionID = ev.data.pfSectionID;
		var infoloop = `${pfSectionID} Port Forward`
		L.ui.confirmDelete(ev, infoloop, function (res) {
			if (res === 1) {
				self.fDeleteUCISection("customfirewall", "redirect", pfSectionID).then(function (rv) {
					if (rv == 0) {
						self.fCommitUCISection("customfirewall").then(function (res) {
							if (res != 0) {
								alert("Error: Delete Port Forward Configuration");
							}
							else {
								setTimeout(() => {
									location.reload();
								}, 1500);
							}
						});
					};
				});
			}
		});
	},
	
	pfSectionAdd: function () 
	{
		var self = this;
		var pfName = $('#field_firewall_redirect_newRedirect_name').val();		
		var pfsrc_IP = $('#field_firewall_redirect_newRedirect_src_IP').val();
		var pfsrc_port = $('#field_firewall_redirect_newRedirect_src_port').val();
		var pfdest_ip = $('#field_firewall_redirect_newRedirect_dest_IP').val();
		var pfdest_port = $('#field_firewall_redirect_newRedirect_dest_port').val();
		var SectionOptions = {name:pfName,target:"DNAT",proto:"tcp udp",dest_ip:pfsrc_IP,dest_port:pfsrc_port,action:"dnat",IP:pfdest_ip,port:pfdest_port,target:"DNAT"};

		self.fCreateUCISection("customfirewall","redirect",pfName,SectionOptions).then(function(rv){
			if(rv){
				if (rv.section){
					self.fCommitUCISection("customfirewall").then(function(res){
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
	
	execute: function() {		
		var self = this;
		L.ui.createNote(
			'NOTE',
			'After editing or deleting, please click the Update button to apply the saved configuration.',
			{ type: 'warn', variant: 'inline', appendTo: '#Update-LoopBack-Note' }
		);
		this.fGetUCISections("customfirewall","redirect").then(function(rv) {
			self.pfRenderContents(rv);   
		});
		
		$('#AddNewPortForward').click(function() {          
			self.pfSectionAdd();
		});
		
	    $('#btn_update').click(function () {
			L.ui.loading(true);
			self.updatefirewallconfig('configure').then(function (rv) {
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
