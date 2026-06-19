L.ui.view.extend({
	
	// title: L.tr('Firewall'),
	// description: L.tr('Reboot the board after saving the changes'),	
	
	fGetUCISections: L.rpc.declare({
		object: 'uci',
		method: 'get',
		params: [ 'config', 'type' ],
		expect: { values: {} }
	}),
	
	fCreateUCISection:  L.rpc.declare({
		object: 'uci',
		method: 'add',
		params: [ 'config', 'type', 'values' ]
	}),
		
	fDeleteUCISection:  L.rpc.declare({
		object: 'uci',
		method: 'delete',
		params: [ 'config','type','section' ]
	}),
	
	updateinterfaceconfig: L.rpc.declare({
        object: 'rpc-updateddosconfig',
        method: 'configure',
        params: ['application','action'],
        expect: { output: '' }
    }),
        
	fCommitUCISection:  L.rpc.declare({
		object: 'uci',
		method: 'commit',
		params: [ 'config' ]
	}),
	
	fCreateForm: function(mapwidget, fSectionID, fSectionType)
	{
		var self = this;
		
		if (!mapwidget)
			mapwidget = L.cbi.Map;
		
		if(fSectionType == "Dredirect") {
			var FormContent = self.pfCreateFormCallback;
		}else if(fSectionType == "Sredirect") {
			var FormContent = self.snCreateFormCallback;
		}else if(fSectionType == "Drule") {
			var FormContent =self.rlCreateFormCallback;
		}else if(fSectionType == "Srule") {
			var FormContent =self.pcCreateFormCallback;
		}else if(fSectionType == "for") {
			var FormContent =self.zfCreateFormCallback;
		}
		var map = new mapwidget('firewall', {
			prepare:    FormContent,
			fSection:   fSectionID
		});
		
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
		map.options.caption = L.tr('Port Forward Configuration → %s').format(pfSectionID);
		
		// var s = map.section(L.cbi.SingleSection, pfSectionID, {
		// 	anonymous:   true,
		// 	 tabbed:      true
		// });

		var s = map.section(L.cbi.NamedSection, pfSectionID, {
			anonymous: true,
			tabbed: true,
			caption: L.tr(map.options.caption)
		});
		
		s.option(L.cbi.InputValue, 'name', {
				caption:     L.tr('Name')
		});
		
		s.option(L.cbi.ComboBox, 'proto', {
			caption:     L.tr('Protocol'),
			optional:      'true'
		}).value("tcp udp", L.tr('TCP+UDP'))
		  .value("tcp", L.tr('TCP'))
		  .value("udp", L.tr('UDP'))
		  .value("icmp", L.tr('ICMP'));	
		
		/*s.option(L.cbi.InputValue, 'src', {
			caption:     L.tr('Source zone'),
			placeholder:     'wan' 
		});*/
		
		s.option(L.cbi.ComboBox, 'src', {
			caption:     L.tr('Source zone'),
			//description: L.tr('Only match incoming traffic from this IP or range.'),
			//datatype:    'ip4addr',
			//optional:    true
		}).value("none", L.tr('--please choose--'))
		  .value("EWAN2", L.tr('EWAN2'))
		  .value("SW_LAN", L.tr('SW_LAN'))
		  .value("CWAN1", L.tr('CWAN1'))
		  .value("CWAN1_0", L.tr('CWAN1_0'))
		  .value("CWAN1_1", L.tr('CWAN1_1'))
		  .value("VPN", L.tr('VPN'));	
		
		s.option(L.cbi.DynamicList, 'src_mac', {
			caption:     L.tr('Source MAC address [optional]'),
			description: L.tr('Only match incoming traffic from these MACs.'),
			datatype:    'macaddr',
			placeholder: "any",
			optional:    true
		});
		
		s.option(L.cbi.ComboBox, 'src_ip', {
			caption:     L.tr('Source IP address[optional]'),
			description: L.tr('Only match incoming traffic from this IP or range.'),
			datatype:    'ip4addr',
			optional:    true
		}).value("none", L.tr('--please choose--'))
		  .value("192.168.1.1", L.tr('192.168.1.1'))
		  .value("192.168.2.1", L.tr('192.168.2.1'));	
		
		/*s.option(L.cbi.InputValue, 'src_port', {
			caption:     L.tr('Source port'),
			description: L.tr('Only match incoming traffic originating from the given source port or port range on the client host'),
			datatype:    'portrange',
			placeholder: "any",
			optional:    true
		});
		
		s.option(L.cbi.ComboBox, 'src_dip', {
			caption:     L.tr('External IP address'),
			description: L.tr('Only match incoming traffic directed at the given IP address.'),
			datatype:    'ip4addr',
			optional:    true
		}).value("192.168.1.1", L.tr('192.168.1.1'))
		  .value("192.168.2.1", L.tr('192.168.2.1'));	*/
		
		s.option(L.cbi.InputValue, 'src_dport', {
			caption:     L.tr('Source port'),
			description: L.tr('Match incoming traffic directed at the given destination port or port range on this host'),
			datatype:    'portrange'
		});
		
		/*s.option(L.cbi.InputValue, 'dest', {
			caption:     L.tr('Destination zone'),
			placeholder:     'lan' 
		});*/
		
		s.option(L.cbi.ComboBox, 'dest', {
			caption:     L.tr('Destination zone'),
			optional:    true
		}).value("SW_LAN", L.tr('SW_LAN'));
		
		s.option(L.cbi.ComboBox, 'dest_ip', {
			caption:     L.tr('Destination IP address'),
			description: L.tr('Redirect matched incoming traffic to the specified internal host'),
			placeholder: L.tr('any'),
			datatype:    'ip4addr',
			optional:    true
		}).value("none", L.tr('--please choose--'))
		  .value("192.168.1.1", L.tr('192.168.1.1'))
		  .value("192.168.2.1", L.tr('192.168.2.1'));	
		
		s.option(L.cbi.InputValue, 'dest_port', {
			caption:     L.tr('Destination port'),
			datatype:    'portrange',
			placeholder: "any",
			description: L.tr('Redirect matched incoming traffic to the given port on the internal host')
		});
		
		/*s.option(L.cbi.CheckboxValue, 'reflection', {
			caption:      L.tr('Enable NAT Loopback'),
			optional:     true,
			enabled:     '1'
		});
		
		s.option(L.cbi.InputValue, 'extra', {
			caption:     L.tr('Extra arguments'),
			optional:     true,
			description: L.tr('Passes additional arguments to iptables. Use with care!')
		});*/
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
							.append(L.ui.button(L.tr('Delete'), 'danger', L.tr('Delete Port Forward'))
								.click({ self: self, fSectionID: v }, self.pfSectionRemove));
					}
				}]
			});
			
			for (var key in rv) {                                                                           
				if (rv.hasOwnProperty(key)) {            
					var obj = rv[key];                                                                  
					var SourceIP = obj.src_ip;
					var SourceZone = obj.src;
					var SourcePort = obj.src_port;
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
					if (!SourceDIP)
						SourceDIP = "any router IP";
				
					if (SourcePort && SourceMac) {
						var srctxt ="From "+"<strong>"+SourceIP+"</strong>"+" in "+"<strong>"+SourceZone+"</strong>"+" with source "+"<strong>"+SourcePort+"</strong>"+" and "+"<strong>"+SourceMac+"</strong>";
					}
					else if (SourcePort) {
						var srctxt = "From "+"<strong>"+SourceIP+"</strong>"+" in "+"<strong>"+SourceZone+"</strong>"+" with source "+"<strong>"+SourcePort+"</strong>";
					} 
					else if (SourceMac) {
						var srctxt ="From "+"<strong>"+SourceIP+"</strong>"+" in "+"<strong>"+SourceZone+"</strong>" +" with source "+"<strong>"+SourceMac+"</strong>";
					}
					else {
						var srctxt ="From "+"<strong>"+SourceIP+"</strong>"+" in "+"<strong>"+SourceZone+"</strong>";
					}
					if (SourceDIP && SourceDPort) {
						var viatxt ="Via "+"<strong>"+SourceDIP+"</strong>"+" at "+"<strong>"+SourceDPort+"</strong>";
					}
					else {
						var viatxt = "Via "+"<strong>"+SourceDIP+"</strong>";
					}
					var Match =prototxt+"<br />"+srctxt+"<br />"+viatxt ;
					
					var DestnZone = obj.dest;
					var DestnIP = obj.dest_ip;
					var DestnPort = obj.dest_port;
					
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
		} else {
			L.ui.showNoConfigMessage('Port Forward', 'No-PortForward-Config')

		}	
	},

	// pfSectionRemove: function(ev) {
	// 	var self = ev.data.self;
	// 	var pfSectionID = ev.data.fSectionID;
		
	// 	self.fDeleteUCISection("firewall","redirect",pfSectionID).then(function(rv){
	// 		if(rv == 0){
	// 			self.fCommitUCISection("firewall").then(function(res){
	// 				if (res != 0){
	// 					alert("Error: Delete Port Forward Configuration");
	// 				}
	// 				else {
	// 					document.cookie="LastActiveTab=TabPf";
	// 					document.cookie="LastAction=delete";
	// 					location.reload();
	// 				}
					
	// 			});
	// 		};
	// 	});
	// },

	pfSectionRemove: function (ev) {
		var self = ev.data.self;
		var pfSectionID = ev.data.fSectionID;
		// var infoportfw = `${pfSectionID} Port Forward`
		var infoportfw = `Port Forward`
		L.ui.confirmDelete(ev, infoportfw, function (res) {
			if (res === 1) {
				self.fDeleteUCISection("firewall", "redirect", pfSectionID).then(function (rv) {
					if (rv == 0) {
						self.fCommitUCISection("firewall").then(function (res) {
							if (res != 0) {
								alert("Error: Delete Port Forward Configuration");
							}
							else {
								document.cookie = "LastActiveTab=TabPf";
								document.cookie = "LastAction=delete";
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
		var pfSrcZone = $('#field_firewall_redirect_newRedirect_src_zone').val();
		var pfSrcPort = $('#field_firewall_redirect_newRedirect_src_port').val();
		var pfDestIp = $('#field_firewall_redirect_newRedirect_dest_ip_addr').val();
		var pfDestport = $('#field_firewall_redirect_newRedirect_dest_port').val();
		var SectionOptions = {name:pfName,target:"DNAT",proto:"tcp udp",src:pfSrcZone,src_dport:pfSrcPort,dest_ip:pfDestIp,dest_port:pfDestport};
		
	    if (pfSrcZone === "custom")
		{
			pfSrcZone = $('#field_firewall_zone_newRedirect_srczone').val();
		}
	
		var SectionOptions = {name:pfName,target:"DNAT",proto:"tcp udp",src:pfSrcZone,src_dport:pfSrcPort,dest_ip:pfDestIp,dest_port:pfDestport};
		this.fCreateUCISection("firewall","redirect",SectionOptions).then(function(rv){
			if(rv){
				if (rv.section){
					self.fCommitUCISection("firewall").then(function(res){
						if (res != 0) {
							alert("Error: New Port Forward Configuration");
						}
						else {
							document.cookie="LastActiveTab=TabPf";
							document.cookie="LastAction=add";
							location.reload();
						}
					});
					
				};
			};
		});
		
	},
	
	rlCreateFormCallback: function()
	{
		var map = this;
		var rlSectionID = map.options.fSection;
		
		// map.options.caption = L.tr('Traffic rules');
		map.options.caption = L.tr('Traffic rules Configuration → %s').format(rlSectionID);
		
		// var s = map.section(L.cbi.SingleSection, rlSectionID, {
		// 	anonymous:   true
		// });

		var s = map.section(L.cbi.NamedSection, rlSectionID, {
			anonymous: true,
			caption: L.tr(map.options.caption)
		});

		
		s.option(L.cbi.InputValue, 'name', {
				caption:     L.tr('Name')
		});
		
		s.option(L.cbi.ListValue, 'family', {
			caption:     L.tr('Restrict to address family'),
			description: L.tr('Protocol family to generate iptables rules for'),
			optional: true
		}).value("ipv4", L.tr("IPv4 only"))
		.value("ipv6", L.tr("IPv6 only"))
		.value("any", L.tr("IPv4 and IPv6"));
	        
		s.option(L.cbi.ComboBox, 'proto', {
			caption:     L.tr('Protocol'),
			description: L.tr('Match incoming traffic using the given protocol'),
			optional:      true
		}).value("all", L.tr('Any'))
		  .value("tcp udp", L.tr('TCP+UDP'))
		  .value("tcp", L.tr('TCP'))
		  .value("udp", L.tr('UDP'))
		  .value("icmp", L.tr('ICMP'));	
		
		s.option(L.cbi.DynamicList, 'icmp_type', {
			caption:     L.tr('Match ICMP type'),
			optional:     true
		}).value("", "any")
		.value("echo-reply")
		.value("destination-unreachable")
		.value("network-unreachable")
		.value("host-unreachable")
		.value("protocol-unreachable")
		.value("port-unreachable")
		.value("fragmentation-needed")
		.value("source-route-failed")
		.value("network-unknown")
		.value("host-unknown")
		.value("network-prohibited")
		.value("host-prohibited")
		.value("TOS-network-unreachable")
		.value("TOS-host-unreachable")
		.value("communication-prohibited")
		.value("host-precedence-violation")
		.value("precedence-cutoff")
		.value("source-quench")
		.value("redirect")
		.value("network-redirect")
		.value("host-redirect")
		.value("TOS-network-redirect")
		.value("TOS-host-redirect")
		.value("echo-request")
		.value("router-advertisement")
		.value("router-solicitation")
		.value("time-exceeded")
		.value("ttl-zero-during-transit")
		.value("ttl-zero-during-reassembly")
		.value("parameter-problem")
		.value("ip-header-bad")
		.value("required-option-missing")
		.value("timestamp-request")
		.value("timestamp-reply")
		.value("address-mask-request")
		.value("address-mask-reply");
	
		s.option(L.cbi.InterfaceList_ra, 'src', {
			caption:     L.tr('Source zone'),
			optional:     true,
			description: L.tr('Specifies the traffic source zone'),
		}).value("*", "Any");
		  
		  
		s.option(L.cbi.CheckboxValue, 'enabled', {
            caption: L.tr('Enable DDOS Prevention'),
            optional: true
        });
		 
		s.option(L.cbi.InputValue, 'limit', {
			caption: L.tr('Limit'),
			datatype: 'rate',
			optional: true
		}).depends({'enabled':'1'});
		
		s.option(L.cbi.InputValue, 'limit_burst', {
			caption:     L.tr('Limit Burst'),
			optional:     true
		}).depends({'enabled':'1'});
		
		
		s.option(L.cbi.InputValue, 'src_mac', {
			caption:     L.tr('Source MAC address'),
			datatype:    'macaddr',
			placeholder: "any",
			optional:     true
		});
		
		s.option(L.cbi.ComboBox, 'src_ip', {
			caption:     L.tr('Source address'),
			description: L.tr('Match incoming traffic from the specified source ip address'),
			//datatype:    'ipaddr',
			optional:     true
		}).value("192.168.1.1", L.tr('192.168.1.1'))
		  .value("192.168.2.1", L.tr('192.168.2.1'));	
		
		s.option(L.cbi.InputValue, 'src_port', {
			caption:     L.tr('Source port'),
			description: L.tr('Match incoming traffic from the specified source port or port range'),
			datatype:    'portrange',
			placeholder: "any",
			optional:     true
		});
	  
		s.option(L.cbi.InterfaceList_ra, 'dest', {
			caption:     L.tr('Destination zone'),
			optional:     true,
			description: L.tr('Match incoming traffic directed to the specified destination ip address')
		}).value("*", "Any");
		
		s.option(L.cbi.ComboBox, 'dest_ip', {
			caption:     L.tr('Destination address'),
			optional:     true,
			description: L.tr('Match incoming traffic directed to the specified destination ip address')
			//datatype:    'ipaddr'
		}).value("192.168.1.1", L.tr('192.168.1.1'))
		  .value("192.168.2.1", L.tr('192.168.2.1'));	
		
		s.option(L.cbi.InputValue, 'dest_port', {
			caption:     L.tr('Destination port'),
			//datatype:    'portrange',
			placeholder: "any",
			description: L.tr('Match incoming traffic directed at the given destination port or port range'),
			//optional:     true
		});
		
		s.option(L.cbi.ListValue, 'target', {
			caption:     L.tr('Action'),
			optional: true,
			description: L.tr('Firewall action for matched traffic')
		}).value("DROP", L.tr("drop"))
		  .value("ACCEPT", L.tr("accept"))
		  .value("REJECT", L.tr("reject"))
		  .value("NOTRACK", L.tr("don't track"));
	
		s.option(L.cbi.InputValue, 'limit', {
			caption:     L.tr('Limit'),
			optional:     true,
			description: L.tr('Maximum average matching rate; specified as a number, with an optional /second, /minute, /hour or /day suffix')
		});
	
		s.option(L.cbi.InputValue, 'extra', {
			caption:     L.tr('Extra arguments'),
			optional:     true,
			description: L.tr('Passes additional arguments to iptables. Use with care!')
		});
	},
	
	rlRenderContents: function(rv)
	{
		var self = this;
		var len = Object.keys(rv).length
		if (len > 1) {
			var list = new L.ui.table({
				columns: [ { 
					caption: L.tr('Name'),
					width:   '125px',
					format:  function(v,n) {
						var div = $('<p />').attr('id', 'rlName_%s'.format(n));
						return div.append('<strong>'+v+'</strong>');
					}
				},{ 
					caption: L.tr('Match'),
					width:   '250px',
					format:  function(v,n) {
						var div = $('<small />').attr('id', 'rlMatch_%s'.format(n));
						return div.append(v);
					}
				},
				
				{ 
					caption: L.tr('Action'),
					width:   '125px',
					format:  function(v,n) {
						var div = $('<small />').attr('id', 'rlAction_%s'.format(n));
						return div.append(v);
					}
				},{
					caption: L.tr('Modify'),
					width:   '125px',
					format:  function(v, n) {
						return $('<div />')
							.addClass('btn-group btn-group-sm')
							.append(L.ui.button(L.tr('Edit'), 'primary', L.tr('Edit Traffic Rule'))
								.click({ self: self, fSectionID: v, fSectionType: "Drule"}, self.fSectionEdit))
							.append(L.ui.button(L.tr('Delete'), 'danger', L.tr('Delete Traffic Rule'))
								.click({ self: self, fSectionID: v }, self.rlSectionRemove));
					}
				}]
			});
			
			for (var key in rv) {
					
				if (rv.hasOwnProperty(key)) {
				
					var obj = rv[key];  
					var proto = obj.proto;
						//	var monthdays=obj.monthdays;                                                
					var SourceIP = obj.src_ip;
					var SourceZone = obj.src;
					var SourcePort = obj.src_port;
					var SourceMac = obj.src_mac;
					var DestZone = obj.dest;
					var DestPort = obj.dest_port;
					var enabled=obj.enabled;
					var family = obj.family;
					var icmpType = obj.icmp_type;
					var prototxt = '';
					var srctxt = '';
					var desttxt = '';
					var tartxt = '';
					var Action = '';	
					var Match = '';		
					var weekdays=obj.weekdays;
					if((weekdays  == " ") || (weekdays  == "Sun") || (weekdays  == "Mon") || (weekdays  == "Tue") || (weekdays  == "Wed") || (weekdays  == "Thu") || (weekdays  == "Fri") || (weekdays  == "Sat")){  
					self.counter++;                                                     
					continue;
				}
				
					if(enabled  ==  "1"){
						enabled="Enable"
					}
					else if(enabled =="0"){
						enabled="Disable";
					}
					if (!family) {
						family = "Any";
					}
					if(!proto) {
						proto = "traffic";
					}
		
					if (proto == "icmp") {
						var prototxt = family+"-"+proto+" with types <strong>"+icmpType+"</strong>";
					}
					else {
						var prototxt = family+"-"+proto;
					}
					
					if (!SourceZone) {
						SourceZone = "any zone";
					}
					if (!SourceIP) {
						SourceIP = "any host";
					}
					
					if (SourcePort && SourceMac) {
						var srctxt ="From <strong>"+SourceIP+"</strong> in <strong>"+SourceZone+"</strong> with source port <strong>"+SourcePort+"</strong> and <strong>"+SourceMac+"</strong>";
					}
					else if (SourcePort) {
						var srctxt = "From <strong>"+SourceIP+"</strong> in <strong>"+SourceZone+"</strong> with source port <strong>"+SourcePort+"</strong>";
					} 
					else if (SourceMac) {
						var srctxt ="From <strong>"+SourceIP+"</strong> in <strong>"+SourceZone+"</strong> with source <strong>"+SourceMac+"</strong>";
					}
					else {
						var srctxt ="From <strong>"+SourceIP+"</strong> in <strong>"+SourceZone+"</strong>";
					}
					
					
					if (DestZone) {
						var DestIP = obj.dest_ip;
						
						if(DestZone == "*")
							DestZone="any zone";
						
						if (!DestIP)
							DestIP = "any host";
						
						if (DestPort) {
							desttxt="To <strong>"+DestIP+"</strong>, <strong>"+DestPort+" in </strong><strong>"+DestZone+"</strong>";
						}
						else {
							desttxt="To <strong>"+DestIP+"</strong>"+" in <strong>"+DestZone+"</strong>";
						}
					}
					else {
						var DestIP = obj.dest_ip;
						
						if (!DestIP)
							DestIP = "any router IP";
					
						if (DestPort) {
							desttxt="To <strong>"+DestIP+"</strong> at port <strong>"+DestPort+"</strong> on this device";
						}
						else {
							desttxt="To <strong>"+DestIP+"</strong> on this device";
						}
					}
					
					var Match =prototxt+"<br />"+srctxt+"<br />"+desttxt;
					
				
					var Target = obj.target;
					var Limit = obj.limit;
					var LimitBurst = obj.limit_burst;
					
					if (DestZone) {
						if (Target == "ACCEPT") {
							tartxt="Accept forward";
						}
						else if (Target == "REJECT") {
							tartxt="Refuse forward";
						}
						else if (Target == "NOTRACK") {
							tartxt="Do not track forward";
						}
						else { //Target == "DROP" 
							tartxt="Discard forward";
						}
					}
					else {
						if (Target == "ACCEPT" ) {
							tartxt="Accept input";
						}
						else if (Target == "REJECT") {
							tartxt="Refuse input";
						}
						else if (Target == "NOTRACK") {
							tartxt="Do not track input";
						}
						else { //Target == "DROP"
							tartxt="Discard input";
						}
					}
					
					
					if(Limit) {
						var limits = Limit.split("/");
						var limittxt = ''
						if(limits[0]) {
							if (!limits[1])
								limits[1]="second";
								
							if(LimitBurst)
								var limittxt="<strong>"+limits[0]+"</strong> pkts. per <strong>"+limits[1]+"</strong>,burst <strong>"+LimitBurst+"</strong> pkts.";
							else
								var limittxt="<strong>"+limits[0]+"</strong> pkts. per <strong>"+limits[1]+"</strong>";
							
							var Action="<strong>"+tartxt+"<br /></strong> and limit to "+limittxt;
						}
					}
					else {
						var Action="<strong>"+tartxt+"</strong>";
					}		                              
					list.row([ obj.name, Match, Action, key ]); 
					//list.row([ obj.name, Match,enabled, Action, key ]);     
																
				}
			}

			
			$('#section_firewall_rules').append(list.render());

		} else {
			L.ui.showNoConfigMessage('Traffice Rules', 'No-Traffic-Config')

		}
	},
	
	// rlSectionRemove: function(ev) {
	// 	var self = ev.data.self;
	// 	var rlSectionID = ev.data.fSectionID;
	// 	self.fDeleteUCISection("firewall","rule",rlSectionID).then(function(rv){
	// 		if(rv == 0){
	// 			self.fCommitUCISection("firewall").then(function(res){
	// 				if (res != 0){
	// 					alert("Error: Delete Traffic Rule Configuration");
	// 				}
	// 				else {
	// 					document.cookie="LastActiveTab=TabRl";
	// 					document.cookie="LastAction=delete";
	// 					location.reload();
	// 				}
	// 			});
	// 		};
	// 	});
	// },

	rlSectionRemove: function (ev) {
		var self = ev.data.self;
		var rlSectionID = ev.data.fSectionID;
		// var infofirewall = `${rlSectionID}  Firewall`
		var infofirewall = `Firewall`
		L.ui.confirmDelete(ev, infofirewall, function (res) {
			if (res === 1) {
				self.fDeleteUCISection("firewall", "rule", rlSectionID).then(function (rv) {
					if (rv == 0) {
						self.fCommitUCISection("firewall").then(function (res) {
							if (res != 0) {
								alert("Error: Delete Traffic Rule Configuration");
							}
							else {
								document.cookie = "LastActiveTab=TabRl";
								document.cookie = "LastAction=delete";
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
	
	rlSectionAdd: function () 
	{
		var self = this;
		var rlName = $('#field_firewall_rule_NewRule_name').val();
		var rlProto = $('#field_firewall_rule_NewRule_proto').val();
		var SectionOptions = {name:rlName,proto:rlProto};
		this.fCreateUCISection("firewall","rule", SectionOptions).then(function(rv){
			if(rv){
				if (rv.section){
					self.fCommitUCISection("firewall").then(function(res){
						if (res != 0) {
							alert("Error: New Traffic Rules Configuration");
						}
						else {
							document.cookie="LastActiveTab=TabRl";
							document.cookie="LastAction=add";
							location.reload();
						}
					});
				};
			};
		});
	},
	
	snCreateFormCallback: function()
	{
		var map = this;
		var snSectionID = map.options.fSection;
		
		// map.options.caption = L.tr('Firewall - Traffic Rules - SNAT');
		map.options.caption = L.tr('Firewall - Traffic Rules - SNAT → %s').format(snSectionID);
		
		// var s = map.section(L.cbi.SingleSection, snSectionID, {
		// 	anonymous:   true
		// });

		var s = map.section(L.cbi.NamedSection, snSectionID, {
			anonymous: true,
			caption: L.tr(map.options.caption)
		});
		
		s.option(L.cbi.InputValue, 'name', {
				caption:     L.tr('Name')
		});
		
		s.option(L.cbi.ComboBox, 'proto', {
			caption:     L.tr('Protocol'),
			optional: true
		}).value("all", L.tr('All protocols'))
		  .value("tcp udp", L.tr('TCP+UDP'))
		  .value("tcp", L.tr('TCP'))
		  .value("udp", L.tr('UDP'))
		  .value("icmp", L.tr('ICMP'));	
	
		s.option(L.cbi.InputValue, 'src', {
			caption:     L.tr('Source zone'),
			placeholder: "wan",
			optional:     true
		});
		
		s.option(L.cbi.ComboBox, 'src_ip', {
			caption:     L.tr('Source IP address'),
			//datatype:    'ipaddr',
			optional:     true
		}).value("192.168.1.1", L.tr('192.168.1.1'))
		  .value("192.168.2.1", L.tr('192.168.2.1'));	
		
		s.option(L.cbi.InputValue, 'src_port', {
			caption:     L.tr('Source port'),
			description: L.tr('Match incoming traffic originating from the given source port or port range on the client host.'),
			datatype:    'portrange',
			placeholder: "any",
			optional:     true
		});
		
		s.option(L.cbi.InputValue, 'dest', {
			caption:     L.tr('Destination zone'),
			placeholder: "lan",
			optional:     true
		});
		
		s.option(L.cbi.ComboBox, 'dest_ip', {
			caption:     L.tr('Destination IP address'),
			optional:     true
			//datatype:    'ipaddr'
		}).value("192.168.1.1", L.tr('192.168.1.1'))
		  .value("192.168.2.1", L.tr('192.168.2.1'));	
		
		s.option(L.cbi.InputValue, 'dest_port', {
			caption:     L.tr('Destination port'),
			datatype:    'portrange',
			placeholder: "any",
			description: L.tr('Match forwarded traffic to the given destination port or port range.'),
			optional:     true
		});
		
		s.option(L.cbi.ComboBox, 'src_dip', {
			caption:     L.tr('SNAT IP address'),
			description: L.tr('Rewrite matched traffic to the given address.'),
			datatype:    'ip4addr',
			optional:    true
		}).value("192.168.1.1", L.tr('192.168.1.1'))
		  .value("192.168.2.1", L.tr('192.168.2.1'));	
		
		s.option(L.cbi.InputValue, 'src_dport', {
			caption:     L.tr('SNAT port'),
			optional:    true,
			description: L.tr('Rewrite matched traffic to the given source port. May be left empty to only rewrite the IP address.'),
			datatype:    'portrange'
		});
		
		s.option(L.cbi.InputValue, 'extra', {
			caption:     L.tr('Extra arguments'),
			optional:     true,
			description: L.tr('Passes additional arguments to iptables. Use with care!')
		});
	},

	snRenderContents: function(rv)
	{
		var self = this;
		var len = Object.keys(rv).length;
		if (len > 0) {
			var list = new L.ui.table({
				columns: [ { 
					caption: L.tr('Name'),
					width:   '125px',
					format:  function(v,n) {
						var div = $('<p />').attr('id', 'snName_%s'.format(n));
						return div.append('<strong>'+v+'</strong>');
					}
				},{ 
					caption: L.tr('Match'),
					width:   '250px',
					format:  function(v,n) {
						var div = $('<small />').attr('id', 'snMatch_%s'.format(n));
						return div.append(v);
					}
				},{ 
					caption: L.tr('Action'),
					width:   '125px',
					format:  function(v,n) {
						var div = $('<small />').attr('id', 'snAction_%s'.format(n));
						return div.append(v);
					}
				},{
					caption: L.tr('Modify'),
					width:   '125px',
					format:  function(v, n) {
						return $('<div />')
							.addClass('btn-group btn-group-sm')
							.append(L.ui.button(L.tr('Edit'), 'primary', L.tr('Edit Traffic Rule SNAT'))
								.click({ self: self, fSectionID: v , fSectionType: "Sredirect"}, self.fSectionEdit))
							.append(L.ui.button(L.tr('Delete'), 'danger', L.tr('Delete Traffic Rule SNAT'))
								.click({ self: self, fSectionID: v }, self.snSectionRemove));
					}
				}]
			});
			
			for (var key in rv) {
					
				if (rv.hasOwnProperty(key)) {
				
					var obj = rv[key];                                                                  
					var proto = obj.proto;
					var family = obj.family;
					var SourceZone = obj.src;
					var SourceIP = obj.src_ip;
					var SourcePort = obj.src_port;
					var SourceMac = obj.src_mac;
					var DestZone = obj.dest;
					var DestIP = obj.dest_ip;
					var DestPort = obj.dest_port;
					var SourceDIP = obj.src_dip;
					var SourceDPort = obj.src_dport;
					var Target = obj.target;
					var Action = '';
					var srctxt = '';
					var prototxt = '';
					var snat_dest_txt ='';
					var Match = '';
		
					if ( Target != "SNAT" ) {
						continue;
					}
					
					if (!SourceZone) {
						SourceZone = "any zone";
					}
					if (!SourceIP) {
						SourceIP = "any host";
					}
					
					if (!family) {
						family = "Any";
					}
					if(!proto) {
						proto = "traffic";
					}
						
					if (!DestZone) {
						DestZone="any zone";
					}
					if (!DestIP) {
						DestIP="any host";
					}
					if (!DestPort) {
						DestPort=obj.src_dport;
					}
					
					// if (proto == "icmp") {
					// 	var prototxt = family+"-"+proto+" with types <strong>"+icmpType+"</strong>";
					// }
					// else {
					// 	var prototxt = family+"-"+proto;
					// }

					if (proto === "icmp") {
						var icmpType = obj.icmp_type || "any";
						var prototxt = family + "-" + proto + " with types <strong>" + icmpType + "</strong>";
					} else {
						var prototxt = family + "-" + proto;
					}
					
					if (SourcePort && SourceMac) {
						var srctxt ="From <strong>"+SourceIP+"</strong> in <strong>"+SourceZone+"</strong> with source port <strong>"+SourcePort+"</strong> and <strong>"+SourceMac+"</strong>";
					}
					else if (SourcePort) {
						var srctxt = "From <strong>"+SourceIP+"</strong> in <strong>"+SourceZone+"</strong> with source port <strong>"+SourcePort+"</strong>";
					} 
					else if (SourceMac) {
						var srctxt ="From <strong>"+SourceIP+"</strong> in <strong>"+SourceZone+"</strong> with source <strong>"+SourceMac+"</strong>";
					}
					else {
						var srctxt ="From <strong>"+SourceIP+"</strong> in <strong>"+SourceZone+"</strong>";
					}
					
					if (DestPort) {
						var snat_dest_txt="To <strong>"+DestIP+"</strong>, <strong>"+DestPort+"</strong> in <strong>"+DestZone+"</strong>";;
					}
					else {
						var snat_dest_txt="To <strong>"+DestIP+"</strong> in <strong>"+DestZone+"</strong>";
					}
					
					var Match =prototxt+"<br />"+srctxt+"<br />"+snat_dest_txt;
					
					if (SourceDIP && SourceDPort) {
						var Action = "Rewrite to source IP <strong>"+SourceDIP+"</strong>, <strong>"+SourceDPort+"</strong>";
					}
					else if(SourceDIP) {
						var Action = "Rewrite to source IP <strong>"+SourceDIP+"</strong>";
					}
					else if (SourceDPort) {
						var Action = "Rewrite to source IP <strong>"+SourceDPort+"</strong>";
					}
					list.row([ obj.name, Match, Action, key ]);
				}
			}
			$('#section_firewall_snat').append(list.render());
		} else {
			L.ui.showNoConfigMessage('SNAT', 'No-SNAT-Config')
		}
	},
	
	// snSectionRemove: function(ev) {
	// 	var self = ev.data.self;
	// 	var snSectionID = ev.data.fSectionID;
	// 	self.fDeleteUCISection("firewall","redirect",snSectionID).then(function(rv){
	// 		if(rv == 0){
	// 			self.fCommitUCISection("firewall").then(function(res){
	// 				if (res != 0){
	// 					alert("Error: Delete SNAT Traffic Rule Configuration");
	// 				}
	// 				else {
	// 					document.cookie="LastActiveTab=TabSn";
	// 					document.cookie="LastAction=delete";
	// 					location.reload();
	// 				}
	// 			});
	// 		};
	// 	});
	// },

	snSectionRemove: function (ev) {
		var self = ev.data.self;
		var snSectionID = ev.data.fSectionID;
		// var infosnat = `${snSectionID}  SNAT`
		var infosnat = `SNAT`
		L.ui.confirmDelete(ev, infosnat, function (res) {
			if (res === 1) {
				self.fDeleteUCISection("firewall", "redirect", snSectionID).then(function (rv) {
					if (rv == 0) {
						self.fCommitUCISection("firewall").then(function (res) {
							if (res != 0) {
								alert("Error: Delete SNAT Traffic Rule Configuration");
							}
							else {
								document.cookie = "LastActiveTab=TabSn";
								document.cookie = "LastAction=delete";
								setTimeout(() => {
									location.reload();
								}, 1500);

							}
						});
					};
				});
			}
		})

	},
	
	snSectionAdd: function () 
	{
		var self = this;
		var snName = $('#field_firewall_snat_newSnat_name').val();
		var snSrc = $('#field_firewall_snat_newSnat_src').val();
		var snSrcIp = $('#field_firewall_snat_newSnat_src_IP').val();
		var snSnatIp = $('#field_firewall_snat_newSnat_snat_IP').val();

		var SectionOptions = {name:snName,proto:"tcp udp",src:snSrc,src_ip:snSrcIp,src_dip:snSnatIp,target:"SNAT"};
 
		this.fCreateUCISection("firewall","redirect",SectionOptions).then(function(rv){
			if(rv){
				if (rv.section){
					self.fCommitUCISection("firewall").then(function(res){
						if (res != 0) {
							alert("Error: New SNAT Traffic Rules Configuration");
						}
						else {
							document.cookie="LastActiveTab=TabSn;Action=add";
							document.cookie="LastAction=add";
							location.reload();
						}
					});
				};
			};
		});
	},
	
	//PARENTAL CONTROL//
	
	pcCreateFormCallback: function()
	{
		var map = this;
		var pcSectionID = map.options.fSection;
		
		// map.options.caption = L.tr('Parental Control Configuration');
		map.options.caption = L.tr('Parental Control Configuration → %s').format(pcSectionID);
		
		// var s = map.section(L.cbi.SingleSection, pcSectionID, {
		// 	anonymous:   true
		// });

		var s = map.section(L.cbi.NamedSection, pcSectionID, {
			anonymous: true,
			caption: L.tr(map.options.caption)
		});

		s.option(L.cbi.InputValue, 'name', {
			caption: L.tr('Name')
		});
		
		s.option(L.cbi.ListValue, 'proto', {
			caption:     L.tr('Proto'),
		}).value("all", L.tr('all'));
		
		s.option(L.cbi.InputValue, 'src', {
			caption:     L.tr('Source zone'),
			description: L.tr('Please look at Firewall->Zone Settings to find  zone names.'),
		});
		
		s.option(L.cbi.InputValue, 'dest', {
			caption:     L.tr('Destination zone'),
			description: L.tr('Please look at Firewall->Zone Settings to find  zone names.'),
			//datatype:    'ip4addr',
			//optional:    true
		});	
		
		s.option(L.cbi.InputValue, 'src_mac', {
			caption:     L.tr('Source MAC address'),
			datatype:    'macaddr',
			optional:    true
		});
		
		s.option(L.cbi.ListValue, 'target', {
			caption:     L.tr('Target'),
		}).value('ACCEPT', L.tr('Accept'))
            .value('REJECT', L.tr('Reject'))
            .value('DROP', L.tr('Drop'));
		
		s.option(L.cbi.ListValue, 'weekdays', {
			caption:     L.tr('Week Days'),
		}).value(" ", L.tr('All'))
		.value("Sun", L.tr('Sunday'))
		.value("Mon", L.tr('Monday'))
		.value("Tue", L.tr('Tuesday'))
		.value("Wed", L.tr('Wednesday'))
		.value("Thu", L.tr('Thursday'))
		.value("Fri", L.tr('Friday'))
		.value("Sat", L.tr('Saturday'));
		
		
		s.option(L.cbi.ListValue, 'monthdays', {
			caption:     L.tr('Month Days'),
		}).value(" ", L.tr('All'))
		.value("1", L.tr('1'))
		.value("2", L.tr('2'))
		.value("3", L.tr('3'))
		.value("4", L.tr('4'))
		.value("5", L.tr('5'))
		.value("6", L.tr('6'))
		.value("7", L.tr('7'))
		.value("8", L.tr('8'))
		.value("9", L.tr('9'))
		.value("10", L.tr('10'))
		.value("11", L.tr('11'))
		.value("12", L.tr('12'))
		.value("13", L.tr('13'))
		.value("14", L.tr('14'))
		.value("15", L.tr('15'))
		.value("16", L.tr('16'))
		.value("17", L.tr('17'))
		.value("18", L.tr('18'))
		.value("19", L.tr('19'))
		.value("20", L.tr('20'))
		.value("21", L.tr('21'))
		.value("22", L.tr('22'))
		.value("23", L.tr('23'))
		.value("24", L.tr('24'))
		.value("25", L.tr('25'))
		.value("26", L.tr('26'))
		.value("27", L.tr('27'))
		.value("28", L.tr('28'))
		.value("29", L.tr('29'))
		.value("30", L.tr('30'))
		.value("31", L.tr('31'));
		
		// s.option(L.cbi.InputValue, 'start_time', {
		// 		caption:     L.tr('Start Time (hh:mm:ss)')
		// });
		
		// s.option(L.cbi.InputValue, 'stop_time', {
		// 		caption:     L.tr('Stop Time (hh:mm:ss)')
		// });

		s.option(L.cbi.InputValue, 'start_time', {
			datatype: 'rt_time_format',
			optional: true,
			placeholder: "hh:mm:ss",
			caption: L.tr('Start Time (hh:mm:ss)')
		});

		s.option(L.cbi.InputValue, 'stop_time', {
			datatype: 'rt_time_format',
			optional: true,
			placeholder: "hh:mm:ss",
			caption: L.tr('Stop Time (hh:mm:ss)')
		});
	
	},
		
	pcRenderContents: function(rv)
	{
		var self = this;
		// var len = Object.keys(rv).length;
		var len = self.counter;
		if (len > 0) {
			var list1 = new L.ui.table({
				columns: [ { 
					caption: L.tr('Name'),
					width:   '125px',
					format:  function(v,n) {
						var div = $('<p />').attr('id', 'pcName_%s'.format(n));
						return div.append('<strong>'+v+'</strong>');
					}
				},{
					caption: L.tr('Modify'),
					width:   '125px',
					format:  function(v, n) {
						return $('<div />')
							.addClass('btn-group btn-group-sm')
							.append(L.ui.button(L.tr('Edit'), 'primary', L.tr('Edit Parental Control'))
								.click({ self: self, fSectionID: v, fSectionType: "Srule"}, self.fSectionEdit))
							.append(L.ui.button(L.tr('Delete'), 'danger', L.tr('Delete Parental Control'))
								.click({ self: self, fSectionID: v }, self.pcSectionRemove));
					}
				}]
			});
			for (var key in rv) {                                                                           
				if (rv.hasOwnProperty(key)) {     
					
					var obj = rv[key];                
					var proto = obj.proto;
						var weekdays=obj.weekdays; 
						var monthdays=obj.monthdays;
						var start_time=obj.start_time;
						var stop_time=obj.stop_time; 
					if((weekdays  == " ") || (weekdays  == "Sun") || (weekdays  == "Mon") || (weekdays  == "Tue") || (weekdays  == "Wed") || (weekdays  == "Thu") || (weekdays  == "Fri") || (weekdays  == "Sat")){ 
					
					list1.row([ obj.name,key ]);
				}  
			}
																
			}    	
			$('#section_firewall_parent').append(list1.render());
		} else {
			L.ui.showNoConfigMessage('Parental Control', 'No-Parental-Config')
		}
	},
	
	// pcSectionRemove: function(ev) {
	// 	var self = ev.data.self;
	// 	var pcSectionID = ev.data.fSectionID;
	// 	self.fDeleteUCISection("firewall","rule",pcSectionID).then(function(rv){
	// 		if(rv == 0){
	// 			self.fCommitUCISection("firewall").then(function(res){
	// 				if (res != 0){
	// 					alert("Error: Delete Parental Control Configuration");
	// 				}
	// 				else {
	// 					document.cookie="LastActiveTab=TabPc";
	// 					document.cookie="LastAction=delete";
	// 					location.reload();
	// 				}
	// 			});
	// 		};
	// 	});
	// },

	pcSectionRemove: function (ev) {
		var self = ev.data.self;
		var pcSectionID = ev.data.fSectionID;
		// var infopc = `${pcSectionID}  Parental Control`
		var infopc = `Parental Control`
		L.ui.confirmDelete(ev, infopc, function (res) {
			if (res === 1) {
				self.fDeleteUCISection("firewall", "rule", pcSectionID).then(function (rv) {
					if (rv == 0) {
						self.fCommitUCISection("firewall").then(function (res) {
							if (res != 0) {
								alert("Error: Delete Parental Control Configuration");
							}
							else {
								document.cookie = "LastActiveTab=TabPc";
								document.cookie = "LastAction=delete";
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
	
	pcSectionAdd: function () 
	{
		var self = this;
		var pcName = $('#field_firewall_pcontrol_NewPcontrol_name').val();
		var weekdays = $('#field_firewall_pcontrol_NewPcontrol_weekdays').val();
		var weekdays="Sun";
		var SectionOptions = {name:pcName, weekdays:weekdays};
		this.fCreateUCISection("firewall","rule",SectionOptions).then(function(rv){
			if(rv){
				if (rv.section){
					self.fCommitUCISection("firewall").then(function(res){
						if (res != 0) {
							alert("Error: New Parental Control Configuration");
						}
						else {
							document.cookie="LastActiveTab=TabPc";
							document.cookie="LastAction=add";
							location.reload();
						}
					});
				};
			};
		});
	},

	
	zfCreateFormCallback: function()
	{
		var map = this;
		var zfSectionID = map.options.fSection;
		
		// map.options.caption = L.tr('Zone Forwarding');
		map.options.caption = L.tr('Zone Forwarding Configuration → %s').format(zfSectionID);
		
		// var s = map.section(L.cbi.SingleSection, zfSectionID, {
		// 	anonymous:   true,
		// 	 tabbed:      true
		// });

		var s = map.section(L.cbi.NamedSection, zfSectionID, {
			anonymous: true,
			tabbed: true,
			caption: L.tr(map.options.caption)
		});
	
	
	     s.option(L.cbi.InterfaceList_ra, 'src', {
			caption:     L.tr('Source zone'),
		});		

		s.option(L.cbi.InterfaceList_ra, 'dest', {
			caption:     L.tr('Destination zone'),
		});
	
	},
		
	zfRenderContents: function(rv)
	{
		var self = this;
		var len = Object.keys(rv).length
		if (len > 0) {
			var list2 = new L.ui.table({
				columns: [ 
				
				{ 
					caption: L.tr('Source'),
					format:  function(v,n) {
						var div = $('<small />').attr('id', 'zfSource_%s'.format(n));
						return div.append(v);
					}
				},{ 
					caption: L.tr('Destination'),
					format:  function(v,n) {
						var div = $('<small />').attr('id', 'zfDestination_%s'.format(n));
						return div.append(v);
					}
				},{
					caption: L.tr('Actions'),
					format:  function(v, n) {
						return $('<div />')
							.addClass('btn-group btn-group-sm')
							.append(L.ui.button(L.tr('Edit'), 'primary', L.tr('Edit Zone Forwarding'))
								.click({ self: self, fSectionID: v, fSectionType: "for" }, self.fSectionEdit))
							.append(L.ui.button(L.tr('Delete'), 'danger', L.tr('Delete Zone Forwarding'))
								.click({ self: self, fSectionID: v }, self.zfSectionRemove));
					}
				}]
			});
			
			for (var key in rv) {                                                                           
				if (rv.hasOwnProperty(key)) {            
					var obj = rv[key];                                                
					var Source = obj.src;
					var Destination = obj.dest;
					
					list2.row([Source,Destination, key ]);
				}
			}
			$('#section_firewall_zonefor').append(list2.render());	
		} else {
			L.ui.showNoConfigMessage('Zone Forwarding', 'No-Zone-Config')

		}	
		
	},

	// zfSectionRemove: function(ev) {
	// 	var self = ev.data.self;
	// 	var zfSectionID = ev.data.fSectionID;
		
		
	// 	self.fDeleteUCISection("firewall","forwarding",zfSectionID).then(function(rv){
	// 		if(rv == 0){
	// 			self.fCommitUCISection("firewall").then(function(res){
	// 				if (res != 0){
	// 					alert("Error: Delete Zone Forwarding");
	// 				}
	// 				else {
	// 					document.cookie="LastActiveTab=TabZf";
	// 					document.cookie="LastAction=delete";
	// 					location.reload();
	// 				}
					
	// 			});
	// 		};
	// 	});
	// },


	zfSectionRemove: function (ev) {
		var self = ev.data.self;
		var zfSectionID = ev.data.fSectionID;
		// var infozf = `${zfSectionID}  Zone Forwarding`
		var infozf = `Zone Forwarding`
		L.ui.confirmDelete(ev, infozf, function (res) {
			if (res === 1) {
				self.fDeleteUCISection("firewall", "forwarding", zfSectionID).then(function (rv) {
					if (rv == 0) {
						self.fCommitUCISection("firewall").then(function (res) {
							if (res != 0) {
								alert("Error: Delete Zone Forwarding");
							}
							else {
								document.cookie = "LastActiveTab=TabZf";
								document.cookie = "LastAction=delete";
								setTimeout(() => {
									location.reload();
								}, 1500);

							}

						});
					};
				});
			}
		})

	},
	
	zfSectionAdd: function () 
	{
		var self = this;
		var zfSource = $('#field_firewall_zone_newZone_src').val();
		var zfDestination = $('#field_firewall_zone_newZone_dest').val();
		
		if (zfSource === "custom")
		{
			zfSource = $('#field_firewall_zone_newZone_srczone').val();
		}
		
		if (zfDestination === "custom")
		{
			zfDestination = $('#field_firewall_zone_newZone_destzone').val();
		}
		
        var SectionOptions = {src:zfSource,dest:zfDestination};
		this.fCreateUCISection("firewall","forwarding",SectionOptions).then(function(rv){
			if(rv){
				if (rv.section){
					self.fCommitUCISection("firewall").then(function(res){
						if (res != 0) {
							alert("Error: New Zone Forwarding");
						}
						else {
							document.cookie="LastActiveTab=TabZf";
							document.cookie="LastAction=add";
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
    	
		for(var i=0; i<ca.length; i++) {                                                                                   
        		var c = ca[i];                                                                    
        		
			while (c.charAt(0)==' ') 
				c = c.substring(1);                                                    
        		if (c.indexOf(name) == 0) 
				return c.substring(name.length,c.length);                            
    		}
    		return "";                                                                                        
	},

	execute: function() {		
		var self = this;
		self.counter = 0;
		L.ui.createNote(
			'NOTE',
			'After editing or deleting, please click the Update button to apply the saved configuration.',
			{ type: 'warn', variant: 'inline', appendTo: '#Update-Firewall-Note' }
		);
		var activeTab = self.getCookie("LastActiveTab");
		var action = self.getCookie("LastAction");
		if (action) {
			$('.TabC').removeClass('active');
			$('.'+activeTab).addClass('active');
			document.cookie="LastAction=";
		}
		else {
			$('.TabC').removeClass('active');
			$('.TabGn').addClass('active');
		}


		$('#firewall_update').click(function () {
			L.ui.loading(true);
			self.updateinterfaceconfig('Update', 'updateinterface').then(function (rv) {
				L.ui.loading(false);
				L.ui.showAlert(
					'success',
					'Update Complete',
					rv + 'd successfully'
				);

			});
		});
	
		var m = new L.cbi.Map('firewall', {
			//caption:     L.tr('Firewall'),
			//description: L.tr('Firewall Configuration'),
		});
		var s = m.section(L.cbi.TypedSection, 'defaults', {
			caption: L.tr('General Setting'),
                        //collabsible:    true
        });
		s.option(L.cbi.CheckboxValue, 'syn_flood', {
            caption: L.tr('Enable SYN-flood protection'),
            optional: true
        });
		s.option(L.cbi.CheckboxValue, 'disable_ipv6', {
            caption: L.tr('Disable IPV6'),
            optional: true
        });
        s.option(L.cbi.CheckboxValue, 'drop_invalid', {
            caption: L.tr('Drop invalid packets'),         
            optional: true
        });        
        s.option(L.cbi.CheckboxValue, 'tcp_syncookies', {
            caption: L.tr('TCP SYN Cookies'),         
            optional: true
        });
		s.option(L.cbi.ListValue, 'input', {
			caption:     L.tr('Input'),
			optional:true
		}).value('ACCEPT', L.tr('Accept'))
		  .value('REJECT', L.tr('Reject'))
		  .value('DROP', L.tr('Drop'));
		
		s.option(L.cbi.ListValue, 'output', {
            caption: L.tr('Output'),
            optional:true
        }).value('ACCEPT', L.tr('Accept'))
            .value('REJECT', L.tr('Reject'))
            .value('DROP', L.tr('Drop'));
		
		s.option(L.cbi.ListValue, 'forward', {
            caption: L.tr('Forward'),
            optional:true
        }).value('ACCEPT', L.tr('Accept'))
            .value('REJECT', L.tr('Reject'))
            .value('DROP', L.tr('Drop'));
    
		m.insertInto('#section_firewall_general');



		
		var s1 = m.section(L.cbi.TableSection, 'zone', {
			caption:     L.tr('Zone Setting'),
			addremove:   true,
			add_caption: L.tr('Add New Zone'),
			remove_caption: L.tr('Remove Zone')          
        });

		s1.option(L.cbi.InputValue, 'name', {       
            caption: L.tr('Name'),
            optional: true
        });  
		
        s1.option(L.cbi.ListValue, 'input', {
			caption: L.tr('Input'),
			optional: true,
		}).value("ACCEPT", L.tr("Accept"))
		  .value("REJECT", L.tr("Reject"))
		  .value("DROP", L.tr("Drop"));
		
        s1.option(L.cbi.ListValue, 'output', {
			caption: L.tr('Output'),
			optional: true,
		}).value("ACCEPT", L.tr("Accept"))
		  .value("REJECT", L.tr("Reject"))
		  .value("DROP", L.tr("Drop"));
 		
        s1.option(L.cbi.ListValue, 'forward', {
			caption:     L.tr('Forward'),
			optional: true,
		}).value("ACCEPT", L.tr("Accept"))
		  .value("REJECT", L.tr("Reject"))
		  .value("DROP", L.tr("Drop"));
		
		s1.option(L.cbi.CheckboxValue, 'masq', {
            caption: L.tr('Masquerading'),
            optional: true
        });
                
		s1.option(L.cbi.CheckboxValue, 'mtu_fix', {
        	caption: L.tr('MSS Clamping'),
            optional: true
        });
		
		s1.option(L.cbi.InputValue, 'network', { 
            caption: L.tr('Covered Networks'),        
            optional: true                                    
        }); 
                
		
		m.appendTo('#section_firewall_general');
              
				

		this.fGetUCISections("firewall","redirect").then(function(rv) {
			self.pfRenderContents(rv);
		});
		
		$('#AddNewPortForward').click(function() {          
			self.pfSectionAdd();
		});
		
		this.fGetUCISections("firewall","rule").then(function(rv) {
			self.rlRenderContents(rv);
		});
		
		$('#AddNewRule').click(function() {          
             		self.rlSectionAdd();
        });
        this.fGetUCISections("firewall","redirect").then(function(rv) {
			self.snRenderContents(rv);
		});
		
		$('#AddNewSnatRule').click(function() {          
			self.snSectionAdd();
		});
		
		this.fGetUCISections("firewall","rule").then(function(rv) {
			self.pcRenderContents(rv);
		});
		$('#AddNewParentalControl').click(function() {          
			self.pcSectionAdd();
		});
		
		this.fGetUCISections("firewall","forwarding").then(function(rv) {
			self.zfRenderContents(rv);
		});
		
		$('#AddNewzoneForwarding').click(function() {          
			self.zfSectionAdd();
		});

	}
});
