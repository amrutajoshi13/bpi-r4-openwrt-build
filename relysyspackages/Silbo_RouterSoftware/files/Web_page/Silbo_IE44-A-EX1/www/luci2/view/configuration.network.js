L.ui.view.extend({

    title: L.tr('Network Configuration'),
    description: L.tr('<b>Please click on update after editing or deleting any changes.</b>'),
    
     
     fGetUCISections: L.rpc.declare({
		object: 'uci',
		method: 'get',
		params: [ 'config', 'type' ],
		expect: { values: {} }
	}),
	
	 GetUCISections: L.rpc.declare({
        object: 'uci',
        method: 'get',
        params: ['config', 'type'],
        expect: { values: {} }
    }),
	
	fCreateUCISection:  L.rpc.declare({
		object: 'uci',
		method: 'add',
		params: [ 'config', 'type', 'name', 'values' ]
	}),
	
	drfCreateUCISection:  L.rpc.declare({
		object: 'uci',
		method: 'add',
		params: [ 'config', 'type', 'values' ]
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

	//updatefirewallconfig: L.rpc.declare({
        //object: 'rpc-updatenetworkinterfaces',
        //method: 'configure',
        //expect: { output: '' }
    //}),
    
    deletefirewallconfig: L.rpc.declare({
        object: 'rpc-updatewanconfig',
        method: 'delete',
        expect: { output: '' }
    }),
    
    
       updateinterfaceconfig: L.rpc.declare({
        object: 'rpc-updatewanconfig',
        method: 'configure',
        params: ['application','action'],
        expect: { output: '' }
        }),

   
    
wifi_enable_disable:true,
	
	pbfCreateForm: function(mapwidget, pbfSectionID, pbfSectionType, pbfInterfaceName)
	{
		var self = this;
		
		if (!mapwidget)
			mapwidget = L.cbi.Map;
		
		if(pbfSectionType == "Dredirect") {
			var FormContent = self.pbCreateFormCallback;
			//~ alert("create form");
		}
		
		var map = new mapwidget('networkinterfaces', {
			prepare:    FormContent,
			pbfSection:   pbfSectionID,
			pbfInterfaceName: pbfInterfaceName
		});
		//~ alert("after create form");
		return map;
	},
	
	
		drfCreateForm: function(mapwidget, drfSectionID, drfSectionType)
	    {
		var self = this;
		
		if (!mapwidget)
			mapwidget = L.cbi.Map;
		
		if(drfSectionType == "relay") {
			var FormContent = self.drCreateFormCallback;
			//~ alert("create form");
		}
		
		var map = new mapwidget('dhcprelayconfig', {
			prepare:    FormContent,
			drfSection:   drfSectionID,
			//fInterfaceName: fInterfaceName
		});
		//~ alert("after create form");
		return map;
	},
	
	pbCreateFormCallback: function()
	{
		var map = this;
		var pbSectionID = map.options.pbfSection;
		var pbfInterfaceName = map.options.pbfInterfaceName;
		
		map.options.caption = L.tr('Network Interfaces');
		
		var s = map.section(L.cbi.NamedSection, pbSectionID, {
			collabsible: true,
			anonymous:   true,
			 tabbed:      true
		});
		
		
	   s.option(L.cbi.DummyValue, 'connectionsettings', {
         caption: L.tr(''),
         //  caption: L.tr(a),
        }).ucivalue = function () {
         var id = "<h5><b>&nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbspNetwork Configuration Settings </b> </h3>";
         return id;
       };		
		
	   s.option(L.cbi.DummyValue, 'interface', {
			caption:     L.tr('Interface Name'),
			optional:      'true'
		});
		
		
	   s.option(L.cbi.InputValue, 'ifname', {
			caption:     L.tr('Physical device'),
			optional:      'true'
		});
		
	   s.option(L.cbi.ListValue, 'type', {
			caption:     L.tr('Type'),
		}).value("LAN",L.tr("LAN"))
	      .value("WAN",L.tr("WAN"));	
		
/////////////////////////////////////////////////////////////////////		
	
	s.option(L.cbi.ListValue,'protocol_lan',{          
                 caption:L.tr('Protocol'), 
		}).depends({'type':'LAN'})   
		.value("static_lan", L.tr('Static'));
            
       s.option(L.cbi.ListValue,'protocol',{          
                 caption:L.tr('Protocol'), 
		}).depends({'type':'WAN'}) 
		  .value("static", L.tr('Static'))
          .value("dhcpclient", L.tr('DHCP'))
          .value("pppoe",L.tr("PPPoE"));
         
       s.option(L.cbi.InputValue, 'staticIP', {
           caption: L.tr('IP Address'), 
           datatype: 'ip4addr',
           optional: true
        }).depends({'type':'LAN','protocol_lan':'static_lan'})
        .depends({'type':'WAN','protocol':'static'});
          
        s.option(L.cbi.InputValue, 'staticnetmask', {
           caption: L.tr('Static Netmask'), 
           datatype: 'ip4addr',
           optional: true
        }).depends({'type':'LAN','protocol_lan':'static_lan'})
        .depends({'type':'WAN','protocol':'static'});
        
        s.option(L.cbi.InputValue, 'staticgateway', {
           caption: L.tr('Static Gateway'), 
           datatype: 'ip4addr',
           optional: true
        }).depends({'type':'WAN','protocol':'static'});
      
      s.option(L.cbi.InputValue, 'dhcpgateway', {
           caption: L.tr('DHCP Gateway'), 
           datatype: 'ip4addr',
           optional: true
        }).depends({'type':'WAN','protocol':'dhcpclient'}); 
          
   		   //s.option(L.cbi.DummyValue, 'macaddr', {
           //caption: L.tr('Mac Address')
        //});
        
   		   s.option(L.cbi.InputValue, 'macaddress', {
           caption: L.tr('Override Mac Address'), 
           datatype: 'macaddr',
           optional: true
        });
        
         s.option(L.cbi.CheckboxValue, 'enable_dns', {
           caption: L.tr('Enable DNS'),
         }).depends({'type':'LAN','protocol_lan':'static_lan'})
        .depends({'type':'WAN','protocol':'static'});
		  
		 s.option(L.cbi.DynamicList, 'ServerStaticDnsServer', {
		   caption:     L.tr('DNS Server Address'),
		   datatype: 'ip4addr',
		   placeholder:'8.8.8.8',
		   optional:     true
		 })//.depends({'enable_dns':'1'})
		 .depends({'type':'LAN','protocol_lan':'static_lan','enable_dns':'1'})
        .depends({'type':'WAN','protocol':'static','enable_dns':'1'});
		 
        
        s.option(L.cbi.InputValue, 'EthernetClientPppoeUsername', {
           caption: L.tr('Username'), 
        }).depends({'type':'WAN','protocol':'pppoe'});   
        
        s.option(L.cbi.InputValue, 'EthernetClientPppoePassword', {
           caption: L.tr('Password'), 
        }).depends({'type':'WAN','protocol':'pppoe'});  
        
        s.option(L.cbi.InputValue, 'EthernetClientPppoeAccessConcentrator', {
           caption: L.tr('Access Concentrator'),
           optional:     true 
        }).depends({'type':'WAN','protocol':'pppoe'});  
        
         s.option(L.cbi.InputValue, 'EthernetClientPppoeServiceName', {
           caption: L.tr('Service Name'), 
           optional:     true
        }).depends({'type':'WAN','protocol':'pppoe'}); 
        
         s.option(L.cbi.InputValue, 'pppoegateway', {
           caption: L.tr('Gateway'), 
           placeholder: "0.0.0.0", 
           datatype: 'ip4addr',
        }).depends({'type':'WAN','protocol':'pppoe'}); 

         s.option(L.cbi.CheckboxValue, 'enable_dhcpserver', {
           caption: L.tr('Enable DHCP Server'),
        }).depends({'protocol_lan':'static_lan','type':'LAN'});
        
        s.option(L.cbi.InputValue, 'ServerDHCPrange', {
           caption: L.tr('DHCP Start Address'), 
           datatype : 'uinteger',
           optional: true
        }).depends({'protocol_lan':'static_lan','type':'LAN','enable_dhcpserver':'1'});
        
          s.option(L.cbi.InputValue, 'ServerDHCPlimit', {
           caption: L.tr('DHCP Limit'),
            datatype : 'uinteger',
           optional: true 
        }).depends({'protocol_lan':'static_lan','type':'LAN','enable_dhcpserver':'1'});
        
         s.option(L.cbi.ListValue, 'leasetime_duration', {
          caption: L.tr('Lease Time Duration'),
       }).value("h", L.tr('Hours-(Hr)'))
          .value("m", L.tr('Minutes-(Min)'))
          .value("s", L.tr('Seconds-(Sec)'))
          .depends({ 'protocol_lan': 'static_lan','type':'LAN','enable_dhcpserver': '1' });
                 
         s.option(L.cbi.InputValue, 'leasetimehr', {
           caption: L.tr('Lease time'), 
             placeholder:'12',
              datatype: 'uinteger',
           optional: true
        }).depends({'protocol_lan':'static_lan','type':'LAN','enable_dhcpserver':'1','leasetime_duration':'h'});
        
        s.option(L.cbi.InputValue, 'leasetimemin', {
           caption: L.tr('Lease time'), 
             placeholder:'12',
             datatype: 'greaterthanminutes',
           optional: true
        }).depends({'protocol_lan':'static_lan','type':'LAN','enable_dhcpserver':'1','leasetime_duration':'m'});
        
         s.option(L.cbi.InputValue, 'leasetimesec', {
           caption: L.tr('Lease time'), 
             placeholder:'120',
              datatype: 'greaterthanseconds',
           optional: true
        }).depends({'protocol_lan':'static_lan','type':'LAN','enable_dhcpserver':'1','leasetime_duration':'s'});
		
////////////////////////////////////////////////////////////////////		
       //s.option(L.cbi.ListValue,'protocol',{          
                 //caption:L.tr('Protocol'), 
		//}).value("static", L.tr('Static'))
          //.value("dhcpclient", L.tr('DHCP'))
          //.value("pppoe",L.tr("PPPoE"));
	      ////.value("pptp",L.tr("PPTP"))
	      ////.value("l2tp",L.tr("L2TP"));
        
       //s.option(L.cbi.InputValue, 'staticIP', {
           //caption: L.tr('IP Address'), 
           //datatype: 'ip4addr',
           //optional: true
        //}).depends({'protocol':'static'});   
          
        //s.option(L.cbi.InputValue, 'staticnetmask', {
           //caption: L.tr('Static Netmask'), 
           //datatype: 'ip4addr',
           //optional: true
        //}).depends({'protocol':'static'});   
        
        //s.option(L.cbi.InputValue, 'staticgateway', {
           //caption: L.tr('Static Gateway'), 
           //datatype: 'ip4addr',
           //optional: true
        //}).depends({'protocol':'static'});  
        
         //s.option(L.cbi.CheckboxValue, 'enable_dns', {
           //caption: L.tr('Enable DNS'),
         //}).depends({'protocol':'static'});
		  
		 //s.option(L.cbi.DynamicList, 'ServerStaticDnsServer', {
		   //caption:     L.tr('DNS Server Address'),
		   //placeholder:'8.8.8.8',
		   //optional:     true
		 //}).depends({'enable_dns':'1','protocol':'static'});
        
        //s.option(L.cbi.InputValue, 'dhcpgateway', {
           //caption: L.tr('DHCP Gateway'), 
           //datatype: 'ip4addr',
           //optional: true
        //}).depends({'protocol':'dhcpclient'});  
        
        //s.option(L.cbi.InputValue, 'EthernetClientPppoeUsername', {
           //caption: L.tr('Username'), 
        //}).depends({'protocol':'pppoe'});   
        
        //s.option(L.cbi.InputValue, 'EthernetClientPppoePassword', {
           //caption: L.tr('Password'), 
        //}).depends({'protocol':'pppoe'});  
        
        //s.option(L.cbi.InputValue, 'EthernetClientPppoeAccessConcentrator', {
           //caption: L.tr('Access Concentrator'), 
        //}).depends({'protocol':'pppoe'});  
        
         //s.option(L.cbi.InputValue, 'EthernetClientPppoeServiceName', {
           //caption: L.tr('Service Name'), 
        //}).depends({'protocol':'pppoe'}); 
        
         //s.option(L.cbi.InputValue, 'ppoegateway', {
           //caption: L.tr('Gateway'), 
           //datatype: 'ip4addr',
           //optional: true
        //}).depends({'protocol':'static'});  
        
         //s.option(L.cbi.InputValue, 'macaddress', {
           //caption: L.tr('Override Mac Address'), 
           //datatype: 'macaddr',
           //optional: 'true'
           //});
        
         //s.option(L.cbi.CheckboxValue, 'enable_dhcpserver', {
           //caption: L.tr('Enable DHCP Server'),
        //}).depends({'protocol':'static'});
        
        //s.option(L.cbi.InputValue, 'ServerDHCPrange', {
           //caption: L.tr('DHCP Start Address'), 
           //optional: true
        //}).depends({'protocol':'static','enable_dhcpserver':'1'});
        
          //s.option(L.cbi.InputValue, 'ServerDHCPlimit', {
           //caption: L.tr('DHCP Limit'),
           //optional: true 
        //}).depends({'protocol':'static','enable_dhcpserver':'1'});
          ////.depends({'protocol':'static'});
        
        //s.option(L.cbi.InputValue, 'leasetime', {
           //caption: L.tr('Lease time'), 
             //placeholder:'12',
           //optional: true
        //}).depends({'protocol':'static','enable_dhcpserver':'1'});
          ////.depends({'protocol':'static'});
        
         s.option(L.cbi.CheckboxValue, 'enable_bridge', {
           caption: L.tr('Enable Bridge'),
        });
        
         s.option(L.cbi.NetworkList, 'bridge_interfaces', {
           caption: L.tr('Interfaces'), 
           multiple: true,
            customInput: true,
            labelName: 'device',
           optional: true
        }).depends({'enable_bridge':'1'});
        
        s.option(L.cbi.CheckboxValue, 'enable_dhcprelay', {
           caption: L.tr('Enable DHCP Relay'),
        }).depends({'protocol_lan':'static_lan','type':'LAN'});
        
         s.option(L.cbi.InputValue, 'EthernetRelayServerIP', {
           caption: L.tr('Relay Server IP'), 
           datatype: 'ip4addr',
        }).depends({'protocol_lan':'static_lan','type':'LAN','enable_dhcprelay':'1'}); 
        
		//s.option(L.cbi.InputValue, 'EthernetRelayLocalIP', {
        //caption: L.tr('Relay Local IP'), 
        //datatype: 'ip4addr',
        //}).depends({'enable_dhcprelay':'1'}); 
           
        s.option(L.cbi.CheckboxValue, 'enable_zoneforward', {
           caption: L.tr('Create Firewall Zone'),
        });
       
         s.option(L.cbi.CheckboxValue, 'internetoverinterface', {
           caption: 'Internet Over ' + pbfInterfaceName,
        }).depends({'type':'LAN'}); 
        
       
        s.option(L.cbi.CheckboxValue, 'advanced_settings', {
           caption: L.tr('Advanced Settings'),
        }); 
       
        s.option(L.cbi.CheckboxValue, 'enableipv4routetable', {
           caption: L.tr('IPV4 Route Table'),  
        }).depends({'advanced_settings':'1'});
        
        s.option(L.cbi.InputValue, 'ip4table', {
           caption: L.tr('Table No'), 
            datatype: 'uinteger',
           optional: true
        }).depends({'advanced_settings':'1','enableipv4routetable':'1'});
        
        s.option(L.cbi.InputValue, 'gatewaymetric', {
           caption: L.tr('Gateway Metric'), 
            datatype: 'uinteger',
           optional: true
        }).depends({'advanced_settings':'1'});
        
        s.option(L.cbi.InputValue, 'broadcast', {
           caption: L.tr('Broadcast'), 
           datatype: 'ip4addr',
           optional: true
        }).depends({'advanced_settings':'1'});
        
         s.option(L.cbi.InputValue, 'mtu', {
           caption: L.tr('Override MTU'),
           placeholder:'1500', 
           optional: true
        }).depends({'advanced_settings':'1'});
	
        //s.option(L.cbi.CheckboxValue, 'delegate', {
           //caption: L.tr('Delegate'),
        //}).depends({'advanced_settings':'1'});
        
        s.option(L.cbi.CheckboxValue, 'force_link', {
           caption: L.tr('Force Link'),
        }).depends({'advanced_settings':'1'});
        
        
		//s.option(L.cbi.DummyValue, 'src_port', {
			//caption:     L.tr(''),
			//description: L.tr('Note:if required, add an interface in Internet page under Settings'),
			
		//});
      
     s.option(L.cbi.DummyValue, 'mwan3', {
    caption: L.tr('')
    })
    .ucivalue = function() {
    var noteText = "<b>Note:if required, add an interface in Settings-->Multi-WAN-->Failover</b>";
    return noteText;
    };


//s.option(L.cbi.DummyValue, 'mwan3', {
    //caption: L.tr('')
//})
//.ucivalue = function() {
    //var noteText = "<div style='text-align: left;'><h3><b>Note: If required, need to add Interface in Mwan3 </b></h3></div>";
    //return noteText;
//};	
	
     
 },  
 
      drCreateFormCallback: function()
	  {
		var map = this;
		var drSectionID = map.options.drfSection;
		//var fInterfaceName = map.options.fInterfaceName;
		
		map.options.caption = L.tr('Relay Server');
		
		var s = map.section(L.cbi.NamedSection, drSectionID, {
			collabsible: true,
			anonymous:   true,
			 tabbed:      true
		});
		
	s.option(L.cbi.ListValue, 'interface', {
			caption:     L.tr('Interface'),
		}).value("eth0.1",L.tr("eth0.1"))
	      .value("ra0",L.tr("ra0"));	
		
     s.option(L.cbi.InputValue, 'startip', {
			caption:     L.tr('Start IP Address'),
			datatype: 'ip4addr',
			optional:      'true'
		}); 
	
     
      s.option(L.cbi.InputValue, 'endip', {
			caption:     L.tr('End IP Address'),
			datatype: 'ip4addr',
			optional:      'true'
			
		}); 
     
      s.option(L.cbi.InputValue, 'netmask', {
			caption:     L.tr('Netmask'),
			datatype: 'ip4addr',
			optional:      'true'
		}); 
		
	s.option(L.cbi.InputValue, 'leasetime', {
			caption:     L.tr('Lease Time'),
			 datatype : 'uinteger',
			optional:      'true'
		}); 	
		
     
 },  
 
		
	pbRenderContents: function(rv)
	{
		var self = this;

		var list = new L.ui.table({
			columns: [ 
			{ 
				caption: L.tr('Interface Name'),
				format:  function(v,n) {
					var div = $('<small />').attr('id', 'pbinterface_%s'.format(n));
					return div.append(v);
				}
		    },{ 
				caption: L.tr('Physical Device'),
				format:  function(v,n) {
					var div = $('<small />').attr('id', 'pbphysicaldevice_%s'.format(n));
					return div.append(v);
				}
			},{ 
				caption: L.tr('Type'),
				format:  function(v,n) {
					var div = $('<small />').attr('id', 'pbtype_%s'.format(n));
					return div.append(v);
				}
			},{ 
				caption: L.tr('Override Mac Address'), 
				format:  function(v,n) {
					var div = $('<small />').attr('id', 'pbmacaddress_%s'.format(n));
					return div.append(v);
				}
			},{
				caption: L.tr('Actions'),
				format:  function(v, n) {
					return $('<div />')
						.addClass('btn-group btn-group-sm')
						.append(L.ui.button(L.tr('Edit'), 'primary', L.tr('Edit Port Forward'))
							.click({ self: self, pbfSectionID: v, pbfSectionType: "Dredirect" ,interfaceName: rv[v].interface}, self.pbfSectionEdit))
						.append(L.ui.button(L.tr('Delete'), 'danger', L.tr('Delete Port Forward'))
							.click({ self: self, pbSectionID: v }, self.pbSectionRemove));
				}
			}]
		});
		
		for (var key in rv) 
                {
                        if (rv.hasOwnProperty(key)) 
                        {
                                var obj = rv[key];
								var Interface = obj.interface
								var PhysicalDevice = obj.ifname
								var Type = obj.type
								var OverrideMacAddress = obj.macaddress
			                
                                 list.row([Interface,PhysicalDevice,Type,OverrideMacAddress,key]); 
                        }
                }
		
		$('#section_network_interface_port').append(list.render());		
	},

  
    drRenderContents: function(rv)
	{
		var self = this;

		var list1 = new L.ui.table({
			columns: [ 
			{ 
				caption: L.tr('Interface'),
				format:  function(v,n) {
					var div = $('<small />').attr('id', 'drinterface_%s'.format(n));
					return div.append(v);
				}
		    },{ 
				caption: L.tr('Start IP Address'),
				format:  function(v,n) {
					var div = $('<small />').attr('id', 'drstartip_%s'.format(n));
					return div.append(v);
				}
			},{ 
				caption: L.tr('End IP Address'),
				format:  function(v,n) {
					var div = $('<small />').attr('id', 'drdhcplimit_%s'.format(n));
					return div.append(v);
				}
			},{ 
				caption: L.tr('Netmask'),
				format:  function(v,n) {
					var div = $('<small />').attr('id', 'drnetmask_%s'.format(n));
					return div.append(v);
				}
			},{ 
				caption: L.tr('Lease Time'),
				format:  function(v,n) {
					var div = $('<small />').attr('id', 'drleasetime_%s'.format(n));
					return div.append(v);
				}
			},{
				caption: L.tr('Actions'),
				format:  function(v, n) {
					return $('<div />')
						.addClass('btn-group btn-group-sm')
						.append(L.ui.button(L.tr('Edit'), 'primary', L.tr('Edit Port Forward'))
							.click({ self: self, drfSectionID: v, drfSectionType: "relay" ,interfaceName: rv[v].interface}, self.drfSectionEdit))
						.append(L.ui.button(L.tr('Delete'), 'danger', L.tr('Delete Port Forward'))
							.click({ self: self, drSectionID: v }, self.drSectionRemove));
				}
			}]
		});
		
		for (var key in rv) 
                {
                        if (rv.hasOwnProperty(key)) 
                        {
                                var obj = rv[key];
								var interface = obj.interface
								var startip = obj.startip
								var endip = obj.endip
								var netmask = obj.netmask
								var leasetime = obj.leasetime
			                
                                 list1.row([interface,startip,endip,netmask,leasetime,key]); 
                        }
                }
		
		$('#section_dhcprelay_port').append(list1.render());		
	},
  
  
	pbSectionRemove: function(ev) {
		var self = ev.data.self;
		//var SectionOptions = ev.data.pbinterface;
		var pbSectionID = ev.data.pbSectionID;
		L.ui.loading(true);
		self.deletefirewallconfig('delete').then(function(rv) {
		self.fDeleteUCISection("networkinterfaces","redirect",pbSectionID).then(function(rv){
			if(rv == 0){
				self.fCommitUCISection("networkinterfaces").then(function(res){
						if (res != 0){
							alert("Error: Delete Port Forward Configuration");
							L.ui.loading(false);
						}
						else {
							location.reload();
							L.ui.loading(false);
						}
				});
			};
		});
	});	
		
	},
	
	
	drSectionRemove: function(ev) {
		var self = ev.data.self;
		//var SectionOptions = ev.data.pbinterface;
		var drSectionID = ev.data.drSectionID;
		//self.deletefirewallconfig('delete').then(function(rv) {
		self.fDeleteUCISection("dhcprelayconfig","relay",drSectionID).then(function(rv){
			if(rv == 0){
				self.fCommitUCISection("dhcprelayconfig").then(function(res){
						if (res != 0){
							alert("Error: Delete Port Forward Configuration");
						}
						else {
							location.reload();
						}
				});
			};
		});
	//});	
		
	},
	
	
	
	pbSectionAdd: function () 
	{
		var self = this;
		var pbinterface = $('#field_netint_redirect_newRedirect_interfacename').val();		
		var pbphysicaldevice = $('#field_vlan_redirect_newRedirect_physicaldevice').val();
		var pbtype = $('#field_vlan_redirect_newRedirect_type').val();
		
		var SectionOptions = {interface:pbinterface,ifname:pbphysicaldevice,type:pbtype};
			self.fCreateUCISection("networkinterfaces","redirect",pbinterface,SectionOptions).then(function(rv){
			if(rv){
				if (rv.section){
					self.fCommitUCISection("networkinterfaces").then(function(res){
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
     
    drSectionAdd: function () 
	{
		var self = this;
		var drinterface = $('#field_dhcprelay_redirect_newRedirect_interfacename').val();		
		var drstartip = $('#field_dhcprelay_redirect_newRedirect_startip').val();
		var drendip = $('#field_dhcprelay_redirect_newRedirect_endip').val();
		var drnetmask = $('#field_dhcprelay_redirect_newRedirect_netmask').val();
		var drleasetime = $('#field_dhcprelay_redirect_newRedirect_leasetime').val();
		
		var SectionOptions = {interface:drinterface,startip:drstartip,endip:drendip,netmask:drnetmask,leasetime:drleasetime};
			//self.fCreateUCISection("networkinterfaces","redirect",pbinterface,SectionOptions).then(function(rv){
				self.drfCreateUCISection("dhcprelayconfig","relay",SectionOptions).then(function(rv){
			if(rv){
				if (rv.section){
					self.fCommitUCISection("dhcprelayconfig").then(function(res){
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
     
   
	pbfSectionEdit: function(ev) {
		var self = ev.data.self;
		var pbfSectionID = ev.data.pbfSectionID;
		var pbfSectionType = ev.data.pbfSectionType;
		var pbfInterfaceName = ev.data.interfaceName;
		
		return self.pbfCreateForm(L.cbi.Modal, pbfSectionID, pbfSectionType, pbfInterfaceName).show();
		
	},
   
      drfSectionEdit: function(ev) {
		var self = ev.data.self;
		var drfSectionID = ev.data.drfSectionID;
		var drfSectionType = ev.data.drfSectionType;
		//var fInterfaceName = ev.data.interfaceName;
		
		//return self.fCreateForm(L.cbi.Modal, fSectionID, fSectionType, fInterfaceName).show();
			return self.drfCreateForm(L.cbi.Modal, drfSectionID, drfSectionType).show();
	},
   

        execute:function() {
		
		//to throw error message on webpage while adding wrong ipv4 address format
		ValidateIPv4 = function (ev) {
            var input = ev.target.value;
            if (L.parseIPv4(input)) {
                document.getElementById('validateIPAddress').style.display = 'none';
            }
            else {
                document.getElementById('validateIPAddress').style.display = 'block';
            }
        };
		
		ValidateIPv42 = function (ev) {
            var input = ev.target.value;
            if (L.parseIPv4(input)) {
                document.getElementById('validateIPAddress2').style.display = 'none';
            }
            else {
                document.getElementById('validateIPAddress2').style.display = 'block';
            }
        };
		
		ValidateIPv43 = function (ev) {
            var input = ev.target.value;
            if (L.parseIPv4(input)) {
                document.getElementById('validateIPAddress3').style.display = 'none';
            }
            else {
                document.getElementById('validateIPAddress3').style.display = 'block';
            }
        };
		
			
	   
        $('#AddNewPortForward').click(function() {          
			self.pbSectionAdd();
		});
		   
		
		 $('#AddNewRelay').click(function() {          
			self.drSectionAdd();
		});   
		        
        var self = this;
		this.fGetUCISections("networkinterfaces","redirect").then(function(rv) {
			self.pbRenderContents(rv);   
		});
		
		        
        var self = this;
		this.fGetUCISections("dhcprelayconfig","relay").then(function(rv) {
			self.drRenderContents(rv);   
		});
		
		 $('#btn_update').click(function() {
                        L.ui.loading(true);
                        self.updateinterfaceconfig('Update','updateinterface').then(function(rv){
                            L.ui.loading(false);
                                L.ui.dialog(
                                    L.tr('Updated interface configuration'),[
                                        $('<pre />')
                                        .addClass('alert alert-success')
                                        .text(rv)
                                    ],
                                    { style: 'close'}
                                );
                                
                               });
                    });
                 		
			
			
		
	var self = this;  
    var m = new L.cbi.Map('sysconfig', {       
		
                });
         
        
    var s = m.section(L.cbi.NamedSection, 'sysconfig', {
        caption:L.tr(''),
    });
    
    
   s.option(L.cbi.CheckboxValue, 'enablecellular', {
                        caption: L.tr('Cellular Enable'),
                        optional: true
              }).depends({'cellularconfig' : '1'});
              
              
        
        s.option(L.cbi.ListValue, 'CellularOperationMode', {
           caption: L.tr('Cellular Operation Mode'),
        }).depends({'cellularconfig':'1','enablecellular':'1'})
           .value("none",L.tr("Choose Option"))
            .value("singlecellulardualsim",L.tr("Single Cellular With Dual SIM"))
          //.value("dualcellularsinglesim",L.tr("Dual Cellular each With Single SIM"))
          .value("singlecellularsinglesim",L.tr("Single Cellular With Single SIM"));
         
          
           //============================General settings ==============================================
           
                s.option(L.cbi.DummyValue, 'cellularmodem1', {
                        caption: L.tr('Cellular Modem 1'),
                }).depends({'cellularconfig':'1'})
               // .depends({'enablecellular':'1'})
                .depends({'CellularOperationMode' : 'dualcellularsinglesim','enablecellular':'1'})
                .depends({'CellularOperationMode' : 'singlecellularsinglesim','enablecellular':'1'})
                .depends({'CellularOperationMode' : 'singlecellulardualsim','enablecellular':'1'});
                
           /*      s.option('cellularconfig',L.cbi.DummyValue, 'usbbuspath1', {
                        caption: L.tr('USB Bus Path 1'),
                }).depends({'cellularconfig':'1'})
               // .depends({'enablecellular':'1'})
                .depends({'CellularOperationMode' : 'dualcellularsinglesim','enablecellular':'1'})
                .depends({'CellularOperationMode' : 'singlecellularsinglesim','enablecellular':'1'})
                .depends({'CellularOperationMode' : 'singlecellulardualsim','enablecellular':'1'});*/
                
                 s.option(L.cbi.ListValue, 'protocol1', {
                        caption: L.tr('Protocol'),
                }).depends({'cellularconfig':'1'})
               // .depends({'enablecellular':'1'})
                .depends({'CellularOperationMode' : 'dualcellularsinglesim','enablecellular':'1','cellularmodem1':'QuectelEC200T'})
                .depends({'CellularOperationMode' : 'singlecellularsinglesim','enablecellular':'1','cellularmodem1':'QuectelEC200T'})
                .depends({'CellularOperationMode' : 'singlecellulardualsim','enablecellular':'1','cellularmodem1':'QuectelEC200T'})

                .value("none",L.tr("Choose Option"))
				.value("cdcether",L.tr("CDC-ETHER"))
				.value("ppp",L.tr("PPP"));
				

                
                 s.option(L.cbi.DummyValue, 'cellularmodem2', {
                        caption: L.tr('Cellular Modem 2'),
                }).depends({'cellularconfig':'1'})
               // .depends({'enablecellular':'1'})
                .depends({'CellularOperationMode' : 'dualcellularsinglesim','enablecellular':'1'})
                
          /*        s.option('cellularconfig',L.cbi.DummyValue, 'usbbuspath2', {
                        caption: L.tr('USB Bus Path 2'),
                }).depends({'cellularconfig':'1'})
               // .depends({'enablecellular':'1'})
                .depends({'CellularOperationMode' : 'dualcellularsinglesim','enablecellular':'1'});*/
               
               s.option(L.cbi.ListValue, 'protocol2', {
                        caption: L.tr('Protocol 2'),
                }).depends({'cellularconfig':'1'})
               // .depends({'enablecellular':'1'})
                .depends({'CellularOperationMode' : 'dualcellularsinglesim','enablecellular':'1'})
               // .depends({'CellularOperationMode' : 'singlecellulardualsim','enablecellular':'1'})
                .value("none",L.tr("Choose Option"))
				.value("cdcether",L.tr("CDC-ETHER"))
				.value("ppp",L.tr("PPP"));
				
				

               // =================================Monitoring for sencod module================================== 
                
                 s.option(L.cbi.CheckboxValue, 'monitorenable2', {
                        caption: L.tr('Monitor 2'),
                        optional: true
                }).depends({'cellularconfig':'1'})
                  .depends({'CellularOperationMode' : 'dualcellularsinglesim','modemenable':'1','enablecellular':'1'});

                 s.option(L.cbi.InputValue, 'actioninterval2', {
                        caption: L.tr('Action Interval 2 (In Seconds)'),
                        datatype : 'uinteger',
                }).depends({'cellularconfig':'1'})
                 // .depends({'CellularOperationMode' : 'dualcellularsinglesim','modemenable':'1','monitorenable1':'1'})
                 // .depends({'CellularOperationMode' : 'singlecellularsinglesim','monitorenable1':'1'});
                .depends({'CellularOperationMode' : 'dualcellularsinglesim','modemenable':'1','enablecellular':'1'});
           
                s.option(L.cbi.CheckboxValue, 'querymodematanalytics2', {
                        caption: L.tr('Modem Analytics 2'),
                        optional: true
                }).depends({'cellularconfig':'1'})
                  .depends({'CellularOperationMode' : 'dualcellularsinglesim','modemenable':'1','enablecellular':'1'})
                 // .depends({'CellularOperationMode' : 'singlecellularsinglesim','monitorenable2':'1'})
                 // .depends({'CellularOperationMode' : 'singlecellulardualsim','monitorenable2':'1'});
                
                s.option(L.cbi.CheckboxValue, 'datatestenable2', {
                        caption: L.tr('Data Test 2'),
                        caption: L.tr('Data Test 2'),
                        optional: true
                }).depends({'cellularconfig':'1'})
                  .depends({'CellularOperationMode' : 'dualcellularsinglesim','modemenable':'1','enablecellular':'1'})
                 // .depends({'CellularOperationMode' : 'singlecellularsinglesim'})
                //  .depends({'CellularOperationMode' : 'singlecellulardualsim'});    
                
                 s.option(L.cbi.CheckboxValue, 'pingtestenable2', {
                        caption: L.tr('Ping Test 2'),
                        optional: true
                }).depends({'cellularconfig':'1'})
                  .depends({'CellularOperationMode' : 'dualcellularsinglesim','modemenable':'1','enablecellular':'1'})
                
                s.option(L.cbi.InputValue, 'pingip2', {
                        caption: L.tr('Ping IP 2'),
                        optional: true
                }).depends({'cellularconfig':'1'})
                  .depends({'CellularOperationMode' : 'dualcellularsinglesim','modemenable':'1','pingtestenable2' : '1','enablecellular':'1'}) 
                 
                //===================Data /SIM settings===============================
                 s.option(L.cbi.CheckboxValue, 'dataenable', {
                        caption: L.tr('Data Service'),
                        optional: true
                }) .depends({'cellularconfig':'1'})
                  .depends({'CellularOperationMode' : 'dualcellularsinglesim','modemenable':'1','enablecellular':'1'})
                  .depends({'CellularOperationMode' : 'singlecellularsinglesim','enablecellular':'1'})
                  .depends({'CellularOperationMode' : 'singlecellulardualsim','enablecellular':'1'});  
                
      /*  s.option('cellularconfig',L.cbi.InputValue,'cellular',{          
                        caption:L.tr('Cellular Module'),                    
                }).depends({'cellularconfig':'1'})
                  .depends({'CellularOperationMode' : 'dualcellularsinglesim','modemenable':'1','dataenable' : '1','enablecellular':'1'})
                  .depends({'CellularOperationMode' : 'singlecellularsinglesim','modemenable':'1','dataenable' : '1','enablecellular':'1'})
                  .depends({'CellularOperationMode' : 'singlecellulardualsim','modemenable':'1','dataenable' : '1','enablecellular':'1'});  */                    
         
         //========================SIM1 Settings ==============================
         
         /* s.option('cellularconfig',L.cbi.ListValue, 'service', {         
                        caption: L.tr('Network Mode'),                    
                }).depends({'cellularconfig':'1'})
                  .depends({'CellularOperationMode' : 'dualcellularsinglesim','modemenable':'1','dataenable' : '1','enablecellular':'1'})
                  .depends({'CellularOperationMode' : 'singlecellularsinglesim','modemenable':'1','dataenable' : '1','enablecellular':'1'})
                  .depends({'CellularOperationMode' : 'singlecellulardualsim','modemenable':'1','dataenable' : '1','enablecellular':'1'})                                
                .value('auto', L.tr('AUTOMATIC'))                             
                .value('lte', L.tr('LTE only')); */                             
          
                    s.option(L.cbi.ListValue, 'Sim1type', {
                        caption: L.tr('Choose SIM Type')
					}).depends({'cellularconfig':'1'})
                      .depends({'CellularOperationMode' : 'singlecellularsinglesim','modemenable':'1','dataenable' : '1','enablecellular':'1'})
					  .value('m2mesim', L.tr('M2M Esim'))                        
                      .value('consumerEsim', L.tr('Connector sim')); 
          
                    s.option(L.cbi.ListValue, 'Sim1apntype', {
                        caption: L.tr('Choose SIM 1 APN Mode')
					}).depends({'cellularconfig':'1'})
					  .depends({'CellularOperationMode' : 'dualcellularsinglesim','modemenable':'1','dataenable' : '1','enablecellular':'1'})
                      .depends({'CellularOperationMode' : 'singlecellularsinglesim','modemenable':'1','dataenable' : '1','enablecellular':'1'})
                      .depends({'CellularOperationMode' : 'singlecellulardualsim','modemenable':'1','dataenable' : '1','enablecellular':'1'}) 
					  .value('auto', L.tr('Auto'))                        
                      .value('manual', L.tr('Manual')); 
                        
                        s.option(L.cbi.DummyValue, 'sim1autoapn', {
                        caption: L.tr('SIM 1 Access Point Name')
					}).depends({'cellularconfig':'1'})
					  .depends({'CellularOperationMode' : 'dualcellularsinglesim','modemenable':'1','dataenable' : '1','enablecellular':'1','Sim1apntype':'auto'})
                      .depends({'CellularOperationMode' : 'singlecellularsinglesim','modemenable':'1','dataenable' : '1','enablecellular':'1','Sim1apntype':'auto'})
                      .depends({'CellularOperationMode' : 'singlecellulardualsim','modemenable':'1','dataenable' : '1','enablecellular':'1','Sim1apntype':'auto'});     
                                                 
					s.option(L.cbi.InputValue, 'apn', {
                        caption: L.tr('SIM 1 Access Point Name')
                }).depends({'cellularconfig':'1'})
                  .depends({'CellularOperationMode' : 'dualcellularsinglesim','modemenable':'1','dataenable' : '1','enablecellular':'1','Sim1apntype':'manual'})
                  .depends({'CellularOperationMode' : 'singlecellularsinglesim','modemenable':'1','dataenable' : '1','enablecellular':'1','Sim1apntype':'manual'})
                  .depends({'CellularOperationMode' : 'singlecellulardualsim','modemenable':'1','dataenable' : '1','enablecellular':'1','Sim1apntype':'manual'}) ;
                
                  s.option(L.cbi.ListValue, 'pdp', {
                        caption: L.tr('SIM 1 PDP Type')
                }).depends({'cellularconfig':'1'})
                  .depends({'CellularOperationMode' : 'dualcellularsinglesim','modemenable':'1','dataenable' : '1','enablecellular':'1'})
                  .depends({'CellularOperationMode' : 'singlecellularsinglesim','modemenable':'1','dataenable' : '1','enablecellular':'1'})
                  .depends({'CellularOperationMode' : 'singlecellulardualsim','modemenable':'1','dataenable' : '1','enablecellular':'1'})
                .value('IPV4', L.tr('IPV4'))                        
                .value('IPV6', L.tr('IPV6'))                        
                .value('IPV4V6', L.tr('IPV4V6')); 
                
            s.option(L.cbi.CheckboxValue, 'Enable464xlatSim1', {
                        caption: L.tr('Enable CLAT support for SIM1')
                }).depends({'cellularconfig':'1'})
                  .depends({'CellularOperationMode' : 'dualcellularsinglesim','modemenable':'1','dataenable' : '1','enablecellular':'1','pdp':'IPV6'})
                  .depends({'CellularOperationMode' : 'singlecellularsinglesim','modemenable':'1','dataenable' : '1','enablecellular':'1','pdp':'IPV6'})
                  .depends({'CellularOperationMode' : 'singlecellulardualsim','modemenable':'1','dataenable' : '1','enablecellular':'1','pdp':'IPV6'});

                
         /* s.option('cellularconfig',L.cbi.InputValue, 'pincode', {
                        caption: L.tr('SIM 1 PIN Code'),
                        optional: true 
                }).depends({'cellularconfig' : '1','modemenable':'1','dataenable':'1'});*/
                
                s.option(L.cbi.InputValue, 'username', {
                        caption: L.tr('SIM 1 Username'),
                        optional: true 
                }).depends({'cellularconfig':'1'})
                  .depends({'CellularOperationMode' : 'dualcellularsinglesim','modemenable':'1','dataenable' : '1','enablecellular':'1'})
                  .depends({'CellularOperationMode' : 'singlecellularsinglesim','modemenable':'1','dataenable' : '1','enablecellular':'1'})
                  .depends({'CellularOperationMode' : 'singlecellulardualsim','modemenable':'1','dataenable' : '1','enablecellular':'1'});
                
                s.option(L.cbi.PasswordValue,'password',{
                        caption: L.tr('SIM 1 Password'),
                        optional: true 
                }).depends({'cellularconfig':'1'})
                  .depends({'CellularOperationMode' : 'dualcellularsinglesim','modemenable':'1','dataenable' : '1','enablecellular':'1'})
                  .depends({'CellularOperationMode' : 'singlecellularsinglesim','modemenable':'1','dataenable' : '1','enablecellular':'1'})
                  .depends({'CellularOperationMode' : 'singlecellulardualsim','modemenable':'1','dataenable' : '1','enablecellular':'1'});
                
                s.option(L.cbi.ListValue, 'auth', {
                        caption: L.tr('SIM 1 Authentication Protocol'),
                }).depends({'cellularconfig':'1'})
                  .depends({'CellularOperationMode' : 'dualcellularsinglesim','modemenable':'1','dataenable' : '1','enablecellular':'1'})
                  .depends({'CellularOperationMode' : 'singlecellularsinglesim','modemenable':'1','dataenable' : '1','enablecellular':'1'})
                  .depends({'CellularOperationMode' : 'singlecellulardualsim','modemenable':'1','dataenable' : '1','enablecellular':'1'})
                .value('0', L.tr('None'))
                .value('1', L.tr('PAP'))
                .value('2', L.tr('CHAP')); 
                
                s.option(L.cbi.InputValue, 'Sim1mtu', {
                        caption: L.tr('SIM 1 MTU'),
                        optional: true
                }).depends({'cellularconfig':'1'})
                  .depends({'CellularOperationMode' : 'dualcellularsinglesim','modemenable':'1','dataenable' : '1','enablecellular':'1'})
                  .depends({'CellularOperationMode' : 'singlecellularsinglesim','modemenable':'1','dataenable' : '1','enablecellular':'1'})
                  .depends({'CellularOperationMode' : 'singlecellulardualsim','modemenable':'1','dataenable' : '1','enablecellular':'1'});
                
            //=========================== SIM 2 Settings ====================================
            
			 s.option(L.cbi.CheckboxValue, 'dataenable2', {
                        caption: L.tr('Data Service2'),
                        optional: true
                }) .depends({'cellularconfig':'1'})
                  .depends({'CellularOperationMode' : 'dualcellularsinglesim','modemenable':'1','enablecellular':'1'});
                 
			

            /*   s.option('cellularconfig',L.cbi.ListValue, 'sim2service', {         
                        caption: L.tr('SIM 2 Service'),                    
                })
                //.depends({'cellularconfig' : '1','CellularOperationMode' : 'singlecellulardualsim','CellularOperationMode' :'dualcellularsinglesim','modemenable':'1','dataenable':'1'})                                
                .depends({'cellularconfig' : '1'})
                .depends({'CellularOperationMode' : 'singlecellulardualsim','modemenable':'1','dataenable':'1','enablecellular':'1'})
                .depends({'CellularOperationMode' : 'dualcellularsinglesim','modemenable':'1','dataenable':'1','enablecellular':'1'})
                .value('auto', L.tr('AUTOMATIC'))               
                .value('2g', L.tr('2G only'))                           
                .value('lte', L.tr('LTE only')); */                             
           
             s.option(L.cbi.ListValue, 'Sim2apntype', {
                        caption: L.tr('Choose SIM 2 APN Mode')
					}).depends({'cellularconfig':'1'})
					  .depends({'CellularOperationMode' : 'dualcellularsinglesim','modemenable':'1','dataenable' : '1','enablecellular':'1'})
                      .depends({'CellularOperationMode' : 'singlecellulardualsim','modemenable':'1','dataenable' : '1','enablecellular':'1'}) 
					  .value('auto', L.tr('Auto'))                        
                      .value('manual', L.tr('Manual')); 
                     
                s.option(L.cbi.DummyValue, 'sim2autoapn', {
                        caption: L.tr('SIM 2 Access Point Name')
					}).depends({'cellularconfig':'1'})
					  .depends({'CellularOperationMode' : 'dualcellularsinglesim','modemenable':'1','dataenable' : '1','enablecellular':'1','Sim2apntype':'auto'})
                      .depends({'CellularOperationMode' : 'singlecellulardualsim','modemenable':'1','dataenable' : '1','enablecellular':'1','Sim2apntype':'auto'});     
                                     
          s.option(L.cbi.InputValue, 'sim2apn', {
                        caption: L.tr('SIM 2 Access Point Name')
                })
                //.depends({'cellularconfig' : '1','CellularOperationMode' : 'singlecellulardualsim','CellularOperationMode' :'dualcellularsinglesim','modemenable':'1','dataenable':'1'});
                 .depends({'cellularconfig' : '1'})
                .depends({'CellularOperationMode' : 'singlecellulardualsim','modemenable':'1','dataenable':'1','enablecellular':'1','Sim2apntype':'manual'})
                .depends({'CellularOperationMode' : 'dualcellularsinglesim','modemenable':'1','dataenable':'1','enablecellular':'1','Sim2apntype':'manual'});
                
          s.option(L.cbi.ListValue, 'sim2pdp', {
                        caption: L.tr('SIM 2 PDP Type')
                })
                //.depends({'cellularconfig' : '1','CellularOperationMode' : 'singlecellulardualsim','CellularOperationMode' :'dualcellularsinglesim','modemenable':'1','dataenable':'1'})
                .depends({'cellularconfig' : '1'})
                .depends({'CellularOperationMode' : 'singlecellulardualsim','modemenable':'1','dataenable':'1','enablecellular':'1'})
                .depends({'CellularOperationMode' : 'dualcellularsinglesim','modemenable':'1','dataenable':'1','enablecellular':'1'})
                .value('IPV4', L.tr('IPV4'))                        
                .value('IPV6', L.tr('IPV6'))                        
                .value('IPV4V6', L.tr('IPV4V6')); 
                
            s.option(L.cbi.CheckboxValue, 'Enable464xlatSim2', {
                        caption: L.tr('Enable CLAT support for SIM2')
                }).depends({'cellularconfig':'1'})
                  .depends({'CellularOperationMode' : 'dualcellularsinglesim','modemenable':'1','dataenable' : '1','enablecellular':'1','sim2pdp':'IPV6'})
                  .depends({'CellularOperationMode' : 'singlecellulardualsim','modemenable':'1','dataenable' : '1','enablecellular':'1','sim2pdp':'IPV6'});
                
         /* s.option('cellularconfig',L.cbi.InputValue, 'sim2pincode', {
                        caption: L.tr('SIM 2 PIN Code'),
                        optional: true 
                })
                //.depends({'cellularconfig' : '1','CellularOperationMode' : 'singlecellulardualsim','CellularOperationMode' : 'dualcellularsinglesim','modemenable':'1','dataenable':'1'});
                                .depends({'cellularconfig' : '1'})
                .depends({'CellularOperationMode' : 'singlecellulardualsim','modemenable':'1','dataenable':'1'})
                .depends({'CellularOperationMode' : 'dualcellularsinglesim','modemenable':'1','dataenable':'1'});*/
                
                
                s.option(L.cbi.InputValue, 'sim2username', {
                        caption: L.tr('SIM 2 Username'),
                        optional: true 
                })
                //.depends({'cellularconfig' : '1','CellularOperationMode' : 'singlecellulardualsim','CellularOperationMode' : 'dualcellularsinglesim','modemenable':'1','dataenable':'1'});
                                .depends({'cellularconfig' : '1'})
                .depends({'CellularOperationMode' : 'singlecellulardualsim','modemenable':'1','dataenable':'1','enablecellular':'1'})
                .depends({'CellularOperationMode' : 'dualcellularsinglesim','modemenable':'1','dataenable':'1','enablecellular':'1'});
                                
                s.option(L.cbi.PasswordValue,'sim2password',{
                        caption: L.tr('SIM 2 Password'),
                        optional: true 
                })
                //.depends({'cellularconfig' : '1','CellularOperationMode' : 'singlecellulardualsim','CellularOperationMode' : 'dualcellularsinglesim','modemenable':'1','dataenable':'1'});
                 .depends({'cellularconfig' : '1'})
                .depends({'CellularOperationMode' : 'singlecellulardualsim','modemenable':'1','dataenable':'1','enablecellular':'1'})
                .depends({'CellularOperationMode' : 'dualcellularsinglesim','modemenable':'1','dataenable':'1','enablecellular':'1'});
                
                s.option(L.cbi.ListValue, 'sim2auth', {
                        caption: L.tr('SIM 2 Authentication Protocol'),
                })
                //.depends({'cellularconfig' : '1','CellularOperationMode' : 'singlecellulardualsim','CellularOperationMode' : 'dualcellularsinglesim','modemenable':'1','dataenable':'1'})
                 .depends({'cellularconfig' : '1'})
                .depends({'CellularOperationMode' : 'singlecellulardualsim','modemenable':'1','dataenable':'1','enablecellular':'1'})
                .depends({'CellularOperationMode' : 'dualcellularsinglesim','modemenable':'1','dataenable':'1','enablecellular':'1'})
                .value('0', L.tr('None'))
                .value('1', L.tr('PAP'))
                .value('2', L.tr('CHAP'));  
                
                 s.option(L.cbi.InputValue, 'Sim2mtu', {
                        caption: L.tr('SIM 2 MTU'),
                        optional: true
                }).depends({'cellularconfig':'1'})
                  .depends({'CellularOperationMode' : 'dualcellularsinglesim','modemenable':'1','dataenable' : '1','enablecellular':'1'})
                  .depends({'CellularOperationMode' : 'singlecellulardualsim','modemenable':'1','dataenable' : '1','enablecellular':'1'});
                
                   s.option(L.cbi.CheckboxValue, 'primarysimswitchbackenable', {
                        caption: L.tr('Primary SIM Switchback Enable'),
                        optional: true
                }) .depends({'cellularconfig':'1'})
                   .depends({'CellularOperationMode' : 'singlecellulardualsim','modemenable':'1','dataenable':'1','enablecellular':'1'});   
                
                
                  s.option(L.cbi.InputValue, 'primarysimswitchbacktime', {
                        caption: L.tr('Primary SIM Switchback Time (In Minutes)'),
                        optional: true 
                })
                .depends({'cellularconfig' : '1'})
                .depends({'CellularOperationMode' : 'singlecellulardualsim','modemenable':'1','dataenable':'1','primarysimswitchbackenable': '1','enablecellular':'1'});
                
               
               /* s.option(L.cbi.InputValue, 'mtu', {
                caption: L.tr('Override MTU'),
                optional: true
                }).depends({'cellularconfig':'1','enablecellular':'1'}); */
               
               
                //=================================GPS settings ========================================
                
               /* s.option('cellularconfig',L.cbi.CheckboxValue,'gps',{
                        caption:L.tr('GPS Enable'),
                }).depends({'cellularconfig' : '1','modemenable':'1','dataenable':'1'});*/
                
                          
                                                          
                   
       //s.option('cellularconfig',L.cbi.CheckboxValue, 'mode2', {
                        //caption: L.tr('Mode2'),
                        //optional: true
                //});
                
       //s.option('cellularconfig',L.cbi.CheckboxValue, 'mode3', {
                        //caption: L.tr('Mode3'),
                        //optional: true
                //});
   
   m.insertInto('#section_cellular');  
   
   var m = new L.cbi.Map('sysconfig', {
                });     
   
   var s = m.section(L.cbi.NamedSection, 'bandlock', {
        caption:L.tr('')
    });
    
    
    //s.option('band',L.cbi.CheckboxValue, 'bandselectenable', {
			//caption:	L.tr('Enable Bandselect')
		//}).depends({'cellularconfig':'1','enablecellular':'1'});
		 
		 
		  s.option(L.cbi.ListValue, 'bandselectenable', {         
                        caption: L.tr('Band Lock Selection'), 
                        optional: true                   
                })
                  .depends({'CellularOperationMode' : 'dualcellularsinglesim','modemenable':'1','dataenable' : '1','enablecellular':'1','band':'1'})
                  .depends({'CellularOperationMode' : 'singlecellularsinglesim','modemenable':'1','dataenable' : '1','enablecellular':'1','band':'1'})
                  .depends({'CellularOperationMode' : 'singlecellulardualsim','modemenable':'1','dataenable' : '1','enablecellular':'1','band':'1'})                                
                .value('auto', L.tr('AUTOMATIC'))
                .value('2g', L.tr('2G'))                              
                .value('3g', L.tr('3G'))                               
                .value('lte', L.tr('LTE only'));   
                
              s.option(L.cbi.CheckboxValue, 'gsm900', {
                        caption: L.tr('GSM 900'),
                        optional: true
                }).depends({'enablecellular':'1','dataenable':'1','bandselectenable':'1'})
                .depends({'CellularOperationMode' : 'singlecellularsinglesim','enablecellular':'1','bandselectenable' : '2g'})
                .depends({'CellularOperationMode' : 'singlecellulardualsim','enablecellular':'1','bandselectenable' : '2g'});
                
                s.option(L.cbi.CheckboxValue, 'gsm1800', {
                        caption: L.tr('GSM 1800'),
                        optional: true
                }).depends({'enablecellular':'1','dataenable':'1','bandselectenable':'1'})
                .depends({'CellularOperationMode' : 'singlecellularsinglesim','enablecellular':'1','bandselectenable' : '2g'})
                .depends({'CellularOperationMode' : 'singlecellulardualsim','enablecellular':'1','bandselectenable' : '2g'});
                
                 s.option(L.cbi.CheckboxValue, 'wcdma2100', {
                        caption: L.tr('WCDMA 2100'),
                        optional: true
                }).depends({'enablecellular':'1','dataenable':'1','bandselectenable':'1'})
                .depends({'CellularOperationMode' : 'singlecellularsinglesim','enablecellular':'1','bandselectenable' : '3g'})
                .depends({'CellularOperationMode' : 'singlecellulardualsim','enablecellular':'1','bandselectenable' : '3g'});
                
                 s.option(L.cbi.CheckboxValue, 'wcdma850', {
                        caption: L.tr('WCDMA 850'),
                        optional: true
                }).depends({'enablecellular':'1','dataenable':'1','bandselectenable':'1'})
                .depends({'CellularOperationMode' : 'singlecellularsinglesim','enablecellular':'1','bandselectenable' : '3g'})
                .depends({'CellularOperationMode' : 'singlecellulardualsim','enablecellular':'1','bandselectenable' : '3g'});
                
                 s.option(L.cbi.CheckboxValue, 'wcdma900', {
                        caption: L.tr('WCDMA 900'),
                        optional: true
                }).depends({'enablecellular':'1','dataenable':'1','bandselectenable':'1'})
                .depends({'CellularOperationMode' : 'singlecellularsinglesim','enablecellular':'1','bandselectenable' : '3g'})
                .depends({'CellularOperationMode' : 'singlecellulardualsim','enablecellular':'1','bandselectenable' : '3g'});
                
                s.option(L.cbi.CheckboxValue, 'lteb1', {
                        caption: L.tr('LTE B1'),
                        optional: true
                }).depends({'enablecellular':'1','dataenable':'1','bandselectenable':'1'})
                .depends({'CellularOperationMode' : 'singlecellularsinglesim','enablecellular':'1','bandselectenable' : 'lte'})
                .depends({'CellularOperationMode' : 'singlecellulardualsim','enablecellular':'1','bandselectenable' : 'lte'});  
                
                 s.option(L.cbi.CheckboxValue, 'lteb3', {
                        caption: L.tr('LTE B3'),
                        optional: true
                }).depends({'enablecellular':'1','dataenable':'1','bandselectenable':'1'})
                .depends({'CellularOperationMode' : 'singlecellularsinglesim','enablecellular':'1','bandselectenable' : 'lte'})
                .depends({'CellularOperationMode' : 'singlecellulardualsim','enablecellular':'1','bandselectenable' : 'lte'});  
                
                 s.option(L.cbi.CheckboxValue, 'lteb5', {
                        caption: L.tr('LTE B5'),
                        optional: true
                }).depends({'enablecellular':'1','dataenable':'1','bandselectenable':'1'})
                .depends({'CellularOperationMode' : 'singlecellularsinglesim','enablecellular':'1','bandselectenable' : 'lte'})
                .depends({'CellularOperationMode' : 'singlecellulardualsim','enablecellular':'1','bandselectenable' : 'lte'});  
                
                 s.option(L.cbi.CheckboxValue, 'lteb8', {
                        caption: L.tr('LTE B8'),
                        optional: true
                }).depends({'enablecellular':'1','dataenable':'1','bandselectenable':'1'})
                .depends({'CellularOperationMode' : 'singlecellularsinglesim','enablecellular':'1','bandselectenable' : 'lte'})
                .depends({'CellularOperationMode' : 'singlecellulardualsim','enablecellular':'1','bandselectenable' : 'lte'});  
                
                 s.option(L.cbi.CheckboxValue, 'lteb34', {
                        caption: L.tr('LTE B34'),
                        optional: true
                }).depends({'enablecellular':'1','dataenable':'1','bandselectenable':'1'})
                .depends({'CellularOperationMode' : 'singlecellularsinglesim','enablecellular':'1','bandselectenable' : 'lte'})
                .depends({'CellularOperationMode' : 'singlecellulardualsim','enablecellular':'1','bandselectenable' : 'lte'});  
                
                 s.option(L.cbi.CheckboxValue, 'lteb38', {
                        caption: L.tr('LTE B38'),
                        optional: true
                }).depends({'enablecellular':'1','dataenable':'1','bandselectenable':'1'})
                .depends({'CellularOperationMode' : 'singlecellularsinglesim','enablecellular':'1','bandselectenable' : 'lte'})
                .depends({'CellularOperationMode' : 'singlecellulardualsim','enablecellular':'1','bandselectenable' : 'lte'});  
                
                 s.option(L.cbi.CheckboxValue, 'lteb39', {
                        caption: L.tr('LTE B39'),
                        optional: true
                }).depends({'enablecellular':'1','dataenable':'1','bandselectenable':'1'})
                .depends({'CellularOperationMode' : 'singlecellularsinglesim','enablecellular':'1','bandselectenable' : 'lte'})
                .depends({'CellularOperationMode' : 'singlecellulardualsim','enablecellular':'1','bandselectenable' : 'lte'});  
                
                 s.option(L.cbi.CheckboxValue, 'lteb40', {
                        caption: L.tr('LTE B40'),
                        optional: true
                }).depends({'enablecellular':'1','dataenable':'1','bandselectenable':'1'})
                .depends({'CellularOperationMode' : 'singlecellularsinglesim','enablecellular':'1','bandselectenable' : 'lte'})
                .depends({'CellularOperationMode' : 'singlecellulardualsim','enablecellular':'1','bandselectenable' : 'lte'});  
                
                 s.option(L.cbi.CheckboxValue, 'lteb41', {
                        caption: L.tr('LTE B41'),
                        optional: true
                }).depends({'enablecellular':'1','dataenable':'1','bandselectenable':'1'})
                .depends({'CellularOperationMode' : 'singlecellularsinglesim','enablecellular':'1','bandselectenable' : 'lte'})
                .depends({'CellularOperationMode' : 'singlecellulardualsim','enablecellular':'1','bandselectenable' : 'lte'});  
                
//=================================Operator sections ==============================================================================         
       
         s.option(L.cbi.CheckboxValue, 'enableoperator', {
                    caption: L.tr('Operator Select Enable'),
                    optional: true
                  }).depends({'enablecellular':'1'});
                            
         s.option(L.cbi.ListValue, 'operatorlockenable', {         
                    caption: L.tr('Operator Selection Mode'), 
                    optional: true                   
                  }).depends({'enablecellular':'1','dataenable':'1','bandselectenable':'1'})
                    .depends({'enableoperator':'1' ,'band':'1'})
                    
                    .value('auto', L.tr('AUTOMATIC'))
                    .value('manual', L.tr('MANUAL'))                              
                    .value('manual-auto', L.tr('MANUAL-AUTOMATIC')); 
                
         s.option(L.cbi.InputValue, 'Code', {
                    caption: L.tr('Operator Code'),
                    optional: true 
                    }).depends({'enableoperator':'1', 'operatorlockenable' : 'manual'})
                      .depends({'enableoperator':'1','operatorlockenable' : 'manual-auto'});
    
   m.insertInto('#section_bandop');  
   
 if (!self.wifi_enable_disable) {
      document.getElementById('sectiontab_wifi').style.display = 'none';
      document.getElementById('sectiontab_guestwifi').style.display = 'none';
      document.getElementById('sectiontab_wireless').style.display = 'none';
    } else if (self.wifi_enable_disable) { 
    var m2 = new L.cbi.Map('sysconfig', {
                });     
   
   var s2 = m2.section(L.cbi.NamedSection, 'wificonfig', {
        caption:L.tr('')
    });
    
    
     s2.option(L.cbi.DummyValue, 'generalsettings', {
		  caption: L.tr(''),
        }).depends({'wificonfig':'1'})
        .ucivalue=function()
          {
            var id="<h3><b>&nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbspGeneral settings </b> </h3>";
            return id;
          };  
          
       
        //Wifi Devices
        
        s2.option(L.cbi.ListValue, 'wifi1protocol', {
		caption:	L.tr('Radio 0 Protocol'),
		}).depends({'wificonfig':'1'})
		.value('none', L.tr('Please choose'))
		.value('IEEE802.11b/g/n', L.tr('IEEE 802.11 b/g/n'));
        
          
         s2.option(L.cbi.ListValue, 'CountryCode', {
		caption:	L.tr('Country Code'),
		}).depends({'wificonfig':'1'})
		.value('none', L.tr('Please choose'))
		.value('AF', L.tr('Afghanistan'))
        .value('AX', L.tr('Åland Islands'))
        .value('AL', L.tr('ALBANIA'))    
        .value('AS', L.tr('American Samoa'))  
        .value('AD', L.tr('Andorra'))  
        .value('AO', L.tr('Angola'))  
        .value('AI', L.tr('Anguilla')) 
        .value('AQ', L.tr('Antarctica')) 
        .value('AG', L.tr('Antigua and Barbuda')) 
        .value('AR', L.tr('ARGENTINA'))  
        .value('AM', L.tr('ARMENIA'))  
        .value('AW', L.tr('Aruba'))  
        .value('AU', L.tr('AUSTRALIA'))  
        .value('AT', L.tr('AUSTRIA'))  
        .value('AZ', L.tr('AZERBAIJAN'))  
        .value('BH', L.tr('BAHRAIN'))  
        .value('BD', L.tr('Bangladesh'))  
        .value('BB', L.tr('Barbados'))  
        .value('BY', L.tr('BELARUS'))  
        .value('BE', L.tr('BELGIUM'))  
        .value('BZ', L.tr('BELIZE'))  
        .value('BJ', L.tr('Benin'))  
        .value('BM', L.tr('Bermuda'))  
        .value('BT', L.tr('Bhutan'))  
        .value('BO', L.tr('BOLIVIA'))  
        .value('BQ', L.tr('Bonaire'))  
        .value('BQ', L.tr('Sint Eustatius'))  
        .value('BQ', L.tr('Saba'))  
        .value('BA', L.tr('Bosnia and Herzegovina'))  
        .value('BW', L.tr('Botswana'))  
        .value('BV', L.tr('Bouvet Island'))  
        .value('BR', L.tr('BRAZIL'))  
        .value('IO', L.tr('British Indian Ocean Territory'))  
        .value('BN', L.tr('BRUNEI DARUSSALAM'))  
        .value('BG', L.tr('BULGARIA'))  
        .value('BF', L.tr('Burkina Faso'))  
        .value('BI', L.tr('Burundi'))  
        .value('CV', L.tr('Cabo Verde'))  
        .value('KH', L.tr('Cambodia'))  
        .value('CM', L.tr('Cameroon'))  
        .value('CA', L.tr('CANADA'))  
        .value('KY', L.tr('Cayman Islands '))  
        .value('CF', L.tr('Central African Republic'))  
        .value('TD', L.tr('Chad'))  
        .value('CL', L.tr('CHILE'))  
        .value('CN', L.tr('CHINA'))  
        .value('CX', L.tr('Christmas Island'))  
        .value('CC', L.tr('Cocos (Keeling) Islands (the)'))  
        .value('CO', L.tr('COLOMBIA'))  
        .value('KM', L.tr('Comoros'))  
        .value('CD', L.tr('Congo(the Democratic Republic of the)'))  
        .value('CG', L.tr('Congo'))  
        .value('CK', L.tr('Cook Islands'))    
        .value('CR', L.tr('COSTA RICA'))  
        .value('CI', L.tr('Côte dIvoire'))  
        .value('HR', L.tr('CROATIA'))  
        .value('CU', L.tr('Cuba'))  
        .value('CW', L.tr('Curaçao'))  
        .value('CY', L.tr('CYPRUS'))  
        .value('CZ', L.tr('CZECH REPUBLIC'))  
        .value('DK', L.tr('DENMARK'))  
        .value('DJ', L.tr('Djibouti'))  
        .value('DM', L.tr('Dominica'))  
        .value('DO', L.tr('DOMINICAN REPUBLIC'))  
        .value('EC', L.tr('ECUADOR'))  
        .value('EG', L.tr('EGYPT'))  
        .value('SV', L.tr('EL SALVADOR'))  
        .value('GQ', L.tr('Equatorial Guinea'))  
        .value('ER', L.tr('Eritrea'))  
        .value('EE', L.tr('ESTONIA'))  
        .value('ET', L.tr('Ethiopia'))  
        .value('FK', L.tr('Falkland Islands'))  
        .value('FO', L.tr('Faroe Islands'))  
        .value('FJ', L.tr('Fiji'))  
        .value('FI', L.tr('FINLAND'))  
        .value('FR', L.tr('FRANCE'))  
        .value('GF', L.tr('French Guiana'))  
        .value('PF', L.tr('French Polynesia'))  
        .value('TF', L.tr('French Southern Territories'))  
        .value('GA', L.tr('Gabon'))  
        .value('GM', L.tr('Gambia'))  
        .value('GE', L.tr('GEORGIA'))  
        .value('DE', L.tr('GERMANY'))  
        .value('GH', L.tr('Ghana'))  
        .value('GI', L.tr('Gibraltar'))  
        .value('GR', L.tr('GREECE'))  
        .value('GL', L.tr('Greenland'))  
        .value('GD', L.tr('Grenada'))  
        .value('GP', L.tr('Guadeloupe'))  
        .value('GU', L.tr('Guam'))  
        .value('GT', L.tr('GUATEMALA'))  
        .value('GG', L.tr('Guernsey'))  
        .value('GW', L.tr('Guinea-Bissau'))  
        .value('GY', L.tr('Guyana'))  
        .value('HT', L.tr('Haiti'))  
        .value('HM', L.tr('Heard Island and McDonald Islands'))  
        .value('VA', L.tr('Holy See'))  
        .value('HN', L.tr('HONDURAS'))  
        .value('HK', L.tr('HONG KONG'))  
        .value('HU', L.tr('HUNGARY'))  
        .value('IS', L.tr('ICELAND'))  
        .value('IN', L.tr('INDIA'))  
        .value('ID', L.tr('INDONESIA'))  
        .value('IR', L.tr('IRAN'))  
        .value('IQ', L.tr('Iraq'))  
        .value('IE', L.tr('IRELAND'))  
        .value('IL', L.tr('ISRAEL'))  
        .value('IT', L.tr('ITALY'))  
        .value('JM', L.tr('Jamaica'))  
        .value('JP', L.tr('JAPAN'))  
        .value('JE', L.tr('Jersey'))  
        .value('JO', L.tr('JORDAN'))  
        .value('KZ', L.tr('KAZAKHSTAN'))  
        .value('KE', L.tr('Kenya'))  
        .value('KI', L.tr('Kiribati'))  
        .value('KP', L.tr('KOREA DEMOCRATIC'))  
        .value('KR', L.tr('REPUBLIC OF KOREA '))  
        .value('KW', L.tr('KUWAIT'))  
        .value('KG', L.tr('Kyrgyzstan'))  
        .value('LA', L.tr('Lao People Democratic Republic'))  
        .value('LV', L.tr('LATVIA'))  
        .value('LB', L.tr('LEBANON'))  
        .value('LS', L.tr('Lesotho'))  
        .value('LR', L.tr('Liberia'))  
        .value('LY', L.tr('Libya'))  
        .value('LI', L.tr('LIECHTENSTEIN'))  
        .value('LT', L.tr('LITHUANIA'))  
        .value('LU', L.tr('LUXEMBOURG'))  
        .value('MO', L.tr('MACAO'))  
        .value('MK', L.tr('MACEDONIA'))  
        .value('MG', L.tr('Madagascar'))  
        .value('MW', L.tr('Malawi'))  
        .value('MY', L.tr('MALAYSIA'))  
        .value('MV', L.tr('Maldives'))  
        .value('ML', L.tr('Mali'))  
        .value('MT', L.tr('Malta'))  
        .value('MH', L.tr('Marshall Islands'))  
        .value('MQ', L.tr('Martinique'))  
        .value('MR', L.tr('Mauritania'))  
        .value('MU', L.tr('Mauritius'))  
        .value('YT', L.tr('Mayotte'))  
        .value('MX', L.tr('MEXICO'))  
        .value('FM', L.tr('Micronesia'))  
        .value('MD', L.tr('Moldova'))  
        .value('MC', L.tr('MONACO'))  
        .value('MN', L.tr('Mongolia'))  
        .value('ME', L.tr('Montenegro'))  
        .value('MS', L.tr('Montserrat'))  
        .value('MA', L.tr('MOROCCO'))  
        .value('MZ', L.tr('Mozambique'))  
        .value('MM', L.tr('Myanmar'))  
        .value('NA', L.tr('Namibia'))  
        .value('NR', L.tr('Nauru'))  
        .value('NP', L.tr('Nepal'))  
        .value('NL', L.tr('NETHERLANDS'))  
        .value('NC', L.tr('New Caledonia '))  
        .value('NZ', L.tr('NEW ZEALAND'))   
        .value('NI', L.tr('Nicaragua'))  
        .value('NE', L.tr('Niger'))  
        .value('NG', L.tr('Nigeria'))  
        .value('NU', L.tr('Niue'))  
        .value('NF', L.tr('Norfolk Island'))  
        .value('MP', L.tr('Northern Mariana Islands'))  
        .value('NO', L.tr('NORWAY')) 
        .value('OM', L.tr('OMAN'))  
        .value('PK', L.tr('PAKISTAN'))  
        .value('PW', L.tr('Palau'))  
        .value('PS', L.tr('Palestine'))  
        .value('PA', L.tr('PANAMA'))  
        .value('PG', L.tr('Papua New Guinea'))  
        .value('PY', L.tr('Paraguay'))  
        .value('PE', L.tr('PERU'))  
        .value('PH', L.tr('PHILIPPINES'))  
        .value('PN', L.tr('Pitcairn'))  
        .value('PL', L.tr('POLAND'))  
        .value('PT', L.tr('PORTUGAL'))  
        .value('PR', L.tr('PUERTO RICO'))  
        .value('QA', L.tr('QATAR'))  
        .value('RE', L.tr('Réunion'))  
        .value('RO', L.tr('ROMANIA'))  
        .value('RU', L.tr('RUSSIA FEDERATION'))  
        .value('RW', L.tr('Rwanda'))  
        .value('BL', L.tr('Saint Barthélemy'))  
        .value('SH', L.tr('Saint Helena'))  
        .value('SH', L.tr('Ascension Island'))  
        .value('SH', L.tr('Tristan da Cunha'))  
        .value('KN', L.tr('Saint Kitts and Nevis'))  
        .value('LC', L.tr('Saint Lucia'))  
        .value('MF', L.tr('Saint Martin '))  
        .value('PM', L.tr('Saint Pierre and Miquelon'))  
        .value('VC', L.tr('Saint Vincent and the Grenadines'))  
        .value('WS', L.tr('Samoa'))  
        .value('SM', L.tr('San Marino'))  
        .value('ST', L.tr('Sao Tome and Principe'))  
        .value('SA', L.tr('SAUDI ARABIA'))  
        .value('SN', L.tr('Senegal'))  
        .value('RS', L.tr('Serbia'))  
        .value('SC', L.tr('Seychelles'))  
        .value('SL', L.tr('Sierra Leone'))  
        .value('SG', L.tr('SINGAPORE'))  
        .value('SX', L.tr('Sint Maarten'))  
        .value('SK', L.tr('SLOVAKIA'))  
        .value('SI', L.tr('SLOVENIA'))  
        .value('SB', L.tr('Solomon Islands'))  
        .value('SO', L.tr('Somalia'))  
        .value('ZA', L.tr('SOUTH AFRICA'))  
        .value('GS', L.tr('South Georgia and the South Sandwich Islands'))  
        .value('SS', L.tr('South Sudan'))  
        .value('ES', L.tr('SPAIN'))  
        .value('LK', L.tr('Sri Lanka'))  
        .value('SD', L.tr('Sudan'))  
        .value('SR', L.tr('Suriname'))  
        .value('SJ', L.tr('Svalbard'))  
        .value('SJ', L.tr('Jan Mayen'))  
        .value('SE', L.tr('SWEDEN'))  
        .value('CH', L.tr('SWITZERLAND'))  
        .value('SY', L.tr('SYRIAN ARAB REPUBLIC'))  
        .value('TW', L.tr('TAIWAN'))  
        .value('TJ', L.tr('Tajikistan'))  
        .value('TZ', L.tr('Tanzania'))  
        .value('TH', L.tr('THAILAND'))  
        .value('TL', L.tr('Timor-Leste'))  
        .value('TG', L.tr('Togo'))  
        .value('TK', L.tr('Tokelau'))  
        .value('TO', L.tr('Tonga'))  
        .value('TT', L.tr('TRINIDAD AND TOBAGO'))  
        .value('TN', L.tr('TUNISIA'))  
        .value('TR', L.tr('TURKEY'))  
        .value('TM', L.tr('Turkmenistan'))  
        .value('TC', L.tr('Turks and Caicos Islands'))  
        .value('TV', L.tr('Tuvalu'))  
        .value('UG', L.tr('Uganda'))  
        .value('UA', L.tr('UKRAINE'))  
        .value('AE', L.tr('UNITED ARAB EMIRATES'))  
        .value('GB', L.tr('UNITED KINGDOM'))  
        .value('US', L.tr('UNITED STATES'))  
        .value('UY', L.tr('URUGUAY'))  
        .value('UZ', L.tr('UZBEKISTAN'))  
        .value('VU', L.tr('Vanuatu'))  
        .value('VE', L.tr('VENEZUELA'))  
        .value('VN', L.tr('VIET NAM'))  
        .value('VG', L.tr('Virgin Islands'))  
        .value('WF', L.tr('Wallis and Futuna'))  
        .value('EH', L.tr('Western Sahara '))  
        .value('YE', L.tr('YEMEN'))  
        .value('ZM', L.tr('Zambia'))  
        .value('ZW', L.tr('ZIMBABWE')); 
        
        
         s2.option(L.cbi.ListValue, 'wifideviceschannel', {
			caption:	L.tr('Channel')
		}).depends({'wificonfig':'1'})
		.value('1', L.tr('1'))
		.value('2', L.tr('2'))
		.value('3', L.tr('3'))
		.value('4', L.tr('4'))
		.value('5', L.tr('5'))
		.value('6', L.tr('6'))
		.value('7', L.tr('7'))
		.value('8', L.tr('8'))
		.value('9', L.tr('9'))
		.value('10', L.tr('10'))
		.value('11', L.tr('11'))
		.value('12', L.tr('12'))
		.value('13', L.tr('13'))
		.value('14', L.tr('14'))
		.value('auto', L.tr('auto'));
         
         s2.option(L.cbi.InputValue, 'TxPower', {
		caption:	L.tr('TX Power'),
		datatype:'rangelength(0,100)',
		}).depends({'wificonfig':'1'});
		
		s2.option(L.cbi.ListValue, 'channelwidth', {
		caption:	L.tr('Channel width'),
		}).depends({'wificonfig':'1'})
		  .value('0', L.tr('20 MHz'))
		.value('1', L.tr('20/40 MHz')); 
		    
		s2.option(L.cbi.CheckboxValue, 'wifi1enable', {
			caption:	L.tr('Enable Radio'),
			optional: true,
		});//.depends({'wificonfig':'1'})
		
		  		
		s2.option(L.cbi.ListValue, 'wifi1mode', {
			caption:	L.tr('Radio Mode'),
		}).depends({'wifi1enable':'1'})
		//.depends({'wificonfig':'1','wifi1enable':'1'})
		.value('ap', L.tr('Access Point'))
		.value('sta', L.tr('Client only'))
		.value('apsta', L.tr('Access Point and Client'));
				       
        s2.option(L.cbi.InputValue, 'wifi1ssid', {
			caption:	'Radio SSID',
			datatype: 'rt_alphanumericsplchar',
		}).depends({'wifi1enable' : '1','wifi1mode':'ap'})
		  .depends({'wifi1enable' : '1','wifi1mode':'apsta'});
		
		s2.option(L.cbi.ListValue, 'wifi1authentication', {
			caption:	L.tr('Radio Authentication'),
			initial:	'none'
		}).depends({'wificonfig':'1','wifi1enable' : '1','wifi1mode':'ap'})
		  .depends({'wificonfig':'1','wifi1enable' : '1','wifi1mode':'apsta'})
		.value('OPEN', L.tr('No Authentication'))
		.value('WPAPSK', L.tr('WPA Personal (PSK)'))
		.value('WPA2PSK', L.tr('WPA2 Personal (PSK)'))
		.value('WPAPSKWPA2PSK', L.tr('WPAPSK/WPA2PSK mixed mode'))
		.value('WPA3PSK', L.tr('WPA3 Personal(PSK)'))
		.value('WPA2PSKWPA3PSK', L.tr('WPA2PSK/WPA3PSK mixed mode'));
		
		s2.option(L.cbi.ListValue, 'wifi1encryption', {
			caption:	L.tr('Radio Encryption'),
			initial:	'none'
		}).depends({'wificonfig':'1','wifi1enable' : '1','wifi1mode':'ap'})
		  .depends({'wificonfig':'1','wifi1enable' : '1','wifi1mode':'apsta'})
		.value('NONE', L.tr('NONE'))
		.value('TKIP', L.tr('TKIP'))
		.value('TKIPAES', L.tr('TKIPAES'))
		.value('AES', L.tr('AES'));
		
	
		s2.option(L.cbi.PasswordValue, 'wifi1key', {
			caption:	L.tr('Radio Passphrase'),
			datatype:'rangelength(8,11)',
			optional:	true
		}).depends({'wificonfig':'1','wifi1enable' : '1','wifi1mode':'ap'})
		  .depends({'wificonfig':'1','wifi1enable' : '1','wifi1mode':'apsta'});
		
			 s2.option(L.cbi.InputValue, 'radio0dhcpip', {
           caption: L.tr('Radio DHCP Server IP'), 
           datatype: 'ip4addr',
        }).depends({'wificonfig':'1','wifi1enable' : '1','wifi1mode':'ap'})
		  .depends({'wificonfig':'1','wifi1enable' : '1','wifi1mode':'apsta'});
        
                
           s2.option(L.cbi.InputValue, 'Radio0DHCPrange', {
           caption: L.tr('Radio DHCP Start Address'), 
             datatype: 'uinteger',
        }).depends({'wificonfig':'1','wifi1enable' : '1','wifi1mode':'ap'})
		  .depends({'wificonfig':'1','wifi1enable' : '1','wifi1mode':'apsta'});
        
          s2.option(L.cbi.InputValue, 'Radio0DHCPlimit', {
           caption: L.tr('Radio DHCP Limit'), 
             datatype: 'uinteger',
        }).depends({'wificonfig':'1','wifi1enable' : '1','wifi1mode':'ap'})
		  .depends({'wificonfig':'1','wifi1enable' : '1','wifi1mode':'apsta'});
		  
        //s2.option(L.cbi.CheckboxValue, 'WpsEnable', {
           //caption: L.tr('WPS Enable'), 
        //}).depends({'wificonfig':'1','wifi1enable' : '1','wifi1mode':'ap'})
		  //.depends({'wificonfig':'1','wifi1enable' : '1','wifi1mode':'apsta'});
        
        s2.option(L.cbi.CheckboxValue, 'WmmEnable', {
           caption: L.tr('WMM Enable'), 
        }).depends({'wificonfig':'1','wifi1enable' : '1','wifi1mode':'ap'})
		  .depends({'wificonfig':'1','wifi1enable' : '1','wifi1mode':'apsta'});
     
     //////////////////////////////////////////////////////
        
        s2.option(L.cbi.CheckboxValue, 'EnableDhcpRelay', {
			caption:	L.tr('Enable DHCP Relay'),
		}).depends({'wificonfig':'1','wifi1enable' : '1','wifi1mode':'sta'})
		  .depends({'wificonfig':'1','wifi1enable' : '1','wifi1mode':'apsta'});
		

		s2.option(L.cbi.InputValue, 'WifiRelayServerIP', {
           caption: L.tr('Relay Server IP'), 
           datatype: 'ip4addr',
        }).depends({'wificonfig':'1','wifi1enable' : '1','wifi1mode':'sta','EnableDhcpRelay':'1'})
		  .depends({'wificonfig':'1','wifi1enable' : '1','wifi1mode':'apsta','EnableDhcpRelay':'1'});
        
		s2.option(L.cbi.InputValue, 'WifiRelayLocalIP', {
        caption: L.tr('Relay Local IP'), 
        datatype: 'ip4addr',
        }).depends({'wificonfig':'1','wifi1enable' : '1','wifi1mode':'sta','EnableDhcpRelay':'1'});
		  
        
    /////////////////////////////////////////////////////////////////
        
        s2.option(L.cbi.InputValue, 'wifi1stassid', {
			caption:	'Client SSID'
		})
		.depends({'wificonfig':'1','wifi1enable' : '1','wifi1mode':'sta'})
		  .depends({'wificonfig':'1','wifi1enable' : '1','wifi1mode':'apsta'});
		
		s2.option(L.cbi.ListValue, 'wifi1staencryption', {
			caption:	L.tr('Client Encryption'),
			initial:	'none'
		}).depends({'wificonfig':'1','wifi1enable' : '1','wifi1mode':'sta'})
		  .depends({'wificonfig':'1','wifi1enable' : '1','wifi1mode':'apsta'})
		.value('none', L.tr('No encryption'))
		.value('psk', L.tr('WPA Personal (PSK)'))
		.value('psk2', L.tr('WPA2 Personal (PSK)'))
		.value('mixed-psk', L.tr('WPA/WPA2 Personal (PSK) mixed'));
		
		
		s2.option(L.cbi.PasswordValue, 'wifi1stakey', {
			caption:	L.tr('Client Passphrase'),
			optional:	true
		}).depends({'wificonfig':'1','wifi1enable' : '1','wifi1mode':'sta'})
		  .depends({'wificonfig':'1','wifi1enable' : '1','wifi1mode':'apsta'});
    
 
     
   m2.insertInto('#section_wifi');  
   
   
    var m3 = new L.cbi.Map('sysconfig', {
                });     
   
   var s3 = m3.section(L.cbi.NamedSection, 'guestwifi', {
        caption:L.tr('')
    });
    
     s3.option(L.cbi.CheckboxValue, 'guestwifienable', {
			caption:	L.tr('Enable Guest Wifi'),
			optional: true
		}).depends({'wificonfig':'1','wifi1enable':'1','wifi1mode':'ap'});
		  		
      
          s3.option(L.cbi.InputValue, 'guestwifissid', {
			caption:	'SSID'
		  }).depends({'wifi1enable' : '1','wifi1mode':'ap','guestwifi':'1','guestwifienable':'1'})
		
		s3.option(L.cbi.ListValue, 'guestwifi1authentication', {
			caption:	L.tr('Radio Authentication'),
			initial:	'none'
		}).depends({'wifi1enable' : '1','wifi1mode':'ap','guestwifi':'1','guestwifienable':'1'})
		.value('OPEN', L.tr('No Authentication'))
		.value('WPAPSK', L.tr('WPA Personal (PSK)'))
		.value('WPA2PSK', L.tr('WPA2 Personal (PSK)'))
		.value('WPAPSKWPA2PSK', L.tr('WPAPSK/WPA2PSK mixed mode'))
		.value('WPA3PSK', L.tr('WPA3 Personal(PSK)'))
		.value('WPA2PSKWPA3PSK', L.tr('WPA2PSK/WPA3PSK mixed mode'));
		
		s3.option(L.cbi.ListValue, 'guestwifi1encryption', {
			caption:	L.tr('Radio Encryption'),
			initial:	'none'
		}).depends({'wifi1enable' : '1','wifi1mode':'ap','guestwifi':'1','guestwifienable':'1'})
				.value('NONE', L.tr('NONE'))
		.value('TKIP', L.tr('TKIP'))
		.value('TKIPAES', L.tr('TKIPAES'))
		.value('AES', L.tr('AES'));
		
		s3.option(L.cbi.PasswordValue, 'guestwifikey', {
			caption:	L.tr('Passphrase'),
			datatype:'rangelength(8,11)',
			optional:	true
		}).depends({'wifi1enable' : '1','wifi1mode':'ap','guestwifi':'1','guestwifienable':'1'})
      
        s3.option(L.cbi.InputValue, 'guestradio0dhcpip', {
           caption: L.tr('Server IP'), 
           datatype: 'ip4addr',
        }).depends({'wifi1enable' : '1','wifi1mode':'ap','guestwifi':'1','guestwifienable':'1'})
        
                
        s3.option(L.cbi.InputValue, 'guestRadio0DHCPrange', {
           caption: L.tr('Start Address'), 
            datatype: 'uinteger',
        }).depends({'wifi1enable' : '1','wifi1mode':'ap','guestwifi':'1','guestwifienable':'1'})
        
        s3.option(L.cbi.InputValue, 'guestRadio0DHCPlimit', {
           caption: L.tr('DHCP Limit'), 
            datatype: 'uinteger',
        }).depends({'wifi1enable' : '1','wifi1mode':'ap','guestwifi':'1','guestwifienable':'1'})
        
            
   m3.insertInto('#section_guestwifi');  
   
    var m4 = new L.cbi.Map('sysconfig', {
                });     
   
   var s4 = m4.section(L.cbi.NamedSection, 'wirelessconfig', {
        caption:L.tr('')
    });
    
         s4.option(L.cbi.DummyValue, 'generalsettings', {
		  caption: L.tr(''),
        }).depends({'wificonfig':'1'})
        .depends({'wifi1enable':'1' })
        .ucivalue=function()
          {
            var id="<h3><b>&nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbspWifi Schedule ON/OFF settings </b> </h3>";
            return id;
          }; 
		
		s4.option(L.cbi.DummyValue, 'generalsettings', {
		  caption: L.tr(''),
        }).depends({'wificonfig':'1','wifi1enable':'0' })
        .ucivalue=function()
          {
            var id="<h3><b>&nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbspPlease Enable wifi to configure.</b> </h3>";
            return id;
          }; 
		
		 s4.option(L.cbi.CheckboxValue, 'ScheduledOnOff', {
			caption:	L.tr('Scheduled Wifi Off'),
			optional: true,
		}).depends({'wificonfig':'1','wifi1enable':'1','wificonfigschedule':'1'});
		
        s4.option(L.cbi.DynamicList, 'DayOfWeek', {
            caption: L.tr('Day Of Week'),
            optional: true,
            listlimit: 12,
            listcustom:false
        }).depends({'wificonfig':'1','wifi1enable':'1','wificonfigschedule':'1','ScheduledOnOff':'1'})
        .value('*', L.tr('All'))
        .value('0', L.tr('Sunday'))
        .value('1', L.tr('Monday'))
        .value('2', L.tr('Tuesday'))
        .value('3', L.tr('Wednesday'))
        .value('4', L.tr('Thursday'))
        .value('5', L.tr('Friday'))
        .value('6', L.tr('Saturday'));
        		
		
		s4.option(L.cbi.DummyValue, 'from', {
		  caption: L.tr(''),
        }).depends({'wificonfig':'1','wifi1enable':'1' ,'wificonfigschedule':'1'})
        .ucivalue=function()
          {
            var id="<h5><b>&nbsp &nbsp &nbsp &nbsp &nbsp &nbsp From: </b> </h5>";
            return id;
          }; 
		
		
		var fromHourVal = s4.option(L.cbi.DynamicList, 'fromHours', {
            caption: L.tr('Hours'),
            optional: true,
            listlimit: 24,
            listcustom:false,
        }).depends({'wificonfig':'1','wifi1enable':'1','wificonfigschedule':'1','ScheduledOnOff':'1'})
        .value('',L.tr('-- Please choose --'))
        .value('*', L.tr('All'));

        fromHourVal.load = function(sid) {
            var hours = [ ];
            for (var i = 0; i < 24; i++)
                hours.push(i);
            hours.sort();
            for (var i = 0; i < hours.length; i++)
                fromHourVal.value(i);
        };
		
		
		var fromMinuteVal = s4.option(L.cbi.DynamicList, 'fromMinutes', {
            caption: L.tr('Minutes'),
            optional: true,
            listlimit: 60,
            listcustom: false
        }).depends({'wificonfig':'1','wifi1enable':'1','wificonfigschedule':'1','ScheduledOnOff':'1'})
        .value('',L.tr('-- Please choose --'))
        .value('*', L.tr('All'));

        fromMinuteVal.load = function(sid) {
            var minutes = [ ];
            for (var i = 0; i < 60; i++)
                minutes.push(i);
            minutes.sort();
            for (var i = 0; i < minutes.length; i++)
                fromMinuteVal.value(i);
        };

        
        s4.option(L.cbi.DummyValue, 'to', {
		  caption: L.tr(''),
        }).depends({'wificonfig':'1'})
        .depends({'wifi1enable':'1' })
        .ucivalue=function()
          {
            var id="<h5><b>&nbsp &nbsp &nbsp &nbsp &nbsp &nbsp To: </b> </h5>";
            return id;
          }; 
        
        var HourVal = s4.option(L.cbi.DynamicList, 'toHours', {
            caption: L.tr('Hours'),
            optional: true,
            listlimit: 24,
            listcustom:false,
        }).depends({'wificonfig':'1','wifi1enable':'1','wificonfigschedule':'1','ScheduledOnOff':'1'})
        .value('',L.tr('-- Please choose --'))
        .value('*', L.tr('All'));

        HourVal.load = function(sid) {
            var hours = [ ];
            for (var i = 0; i < 24; i++)
                hours.push(i);
            hours.sort();
            for (var i = 0; i < hours.length; i++)
                HourVal.value(i);
        };
		
		
		var MinuteVal = s4.option( L.cbi.DynamicList, 'toMinutes', {
            caption: L.tr('Minutes'),
            optional: true,
            listlimit: 60,
            listcustom: false
        }).depends({'wificonfig':'1','wifi1enable':'1','wificonfigschedule':'1','ScheduledOnOff':'1'})
        .value('',L.tr('-- Please choose --'))
        .value('*', L.tr('All'));

        MinuteVal.load = function(sid) {
            var minutes = [ ];
            for (var i = 0; i < 60; i++)
                minutes.push(i);
            minutes.sort();
            for (var i = 0; i < minutes.length; i++)
                MinuteVal.value(i);
        };

   m4.insertInto('#section_wireless');
}  
    
     var m5 = new L.cbi.Map('sysconfig', {
                });     
   
   var s5 = m5.section(L.cbi.NamedSection, 'smsconfig', {
        caption:L.tr('')
    });
    
		s5.option(L.cbi.CheckboxValue, 'smsenable1', {
			caption: L.tr('SMS Enable'),
			optional: true
		}).depends('smsconfig');
                
		s5.option(L.cbi.DummyValue, 'smsnote', {
			caption: L.tr(''),
			}).depends({'smsconfig':'1'})
			.ucivalue=function()
			{
				var id="<h5><b>Note: Depending upon SIM & cellular service provider,SMS center number may need to be appropriately updated</b> </h5>";
				return id;
			}; 
                 				
			s5.option(L.cbi.CheckboxValue, 'enable_deviceid', {
                       caption: L.tr('Enable Serial Number'),
            }).depends({'smsenable1':'1'});	

			s5.option(L.cbi.DummyValue, 'smsdeviceid', {
    			caption: L.tr('Serial Number'),
			}).depends({ 'enable_deviceid': '1', 'smsenable1': '1' });

                s5.option(L.cbi.CheckboxValue, 'enable_apikey', {
                       caption: L.tr('Enable API Key'),
                }).depends({'modemenable':'1','smsenable1':'1'})
                .depends({'smsenable1':'1'});	
        
               s5.option( L.cbi.InputValue, 'smsapikey', {
    			caption: L.tr('API Key'),
    		description: L.tr('API key used for SMS communication')
		}).depends({ 'enable_apikey': '1', 'smsenable1': '1' });

               s5.option(L.cbi.ListValue, 'validsmsreceivernumbers', {
                        caption: L.tr('Select Valid SMS user Numbers')
                }).depends({'modemenable':'1','smsenable1':'1'})
	              .value("choose",L.tr("Please select the option"))
	              .value("0",L.tr("anyone"))
	              .value("1",L.tr("1"))
	              .value("2",L.tr("2"))
			      .value("3",L.tr("3"))
	              .value("4",L.tr("4"))
	              .value("5",L.tr("5"));       

                s5.option(L.cbi.InputValue, 'smsservernumber1', {
                        caption: L.tr('Valid SMS User Number1'),
		                //optional: true,
		                description:L.tr('phone number in international format without the leading +'),
                }).depends({'validsmsreceivernumbers':'1','modemenable':'1','smsenable1':'1'})
                  .depends({'validsmsreceivernumbers':'2','modemenable':'1','smsenable1':'1'})
                  .depends({'validsmsreceivernumbers':'3','modemenable':'1','smsenable1':'1'})
                  .depends({'validsmsreceivernumbers':'4','modemenable':'1','smsenable1':'1'})
                  .depends({'validsmsreceivernumbers':'5','modemenable':'1','smsenable1':'1'}); 

	            s5.option(L.cbi.InputValue, 'smsservernumber2', {                                       
                        caption: L.tr('Valid SMS User Number2'),                                                           
                        //optional: true,                                                                             
                }).depends({'validsmsreceivernumbers':'2','modemenable':'1','smsenable1':'1'})
                  .depends({'validsmsreceivernumbers':'3','modemenable':'1','smsenable1':'1'})
                  .depends({'validsmsreceivernumbers':'4','modemenable':'1','smsenable1':'1'})
                  .depends({'validsmsreceivernumbers':'5','modemenable':'1','smsenable1':'1'}); 

	            s5.option(L.cbi.InputValue, 'smsservernumber3', {           
                        caption: L.tr('Valid SMS User Number3'),
                       // optional: true                                     
                }).depends({'validsmsreceivernumbers':'3','modemenable':'1','smsenable1':'1'})
                  .depends({'validsmsreceivernumbers':'4','modemenable':'1','smsenable1':'1'})
                  .depends({'validsmsreceivernumbers':'5','modemenable':'1','smsenable1':'1'}); 

                s5.option(L.cbi.InputValue, 'smsservernumber4',{
                        caption: L.tr('Valid SMS User Number4'),
                        //optional: true
                }).depends({'validsmsreceivernumbers':'4','modemenable':'1','smsenable1':'1'})
                  .depends({'validsmsreceivernumbers':'5','modemenable':'1','smsenable1':'1'});       

                s5.option(L.cbi.InputValue, 'smsservernumber5',{   
                        caption: L.tr('Valid SMS User Number5'),    
                        //optional: true                                       
                }).depends({'validsmsreceivernumbers':'5','modemenable':'1','smsenable1':'1'});
                
                 s5.option(L.cbi.CheckboxValue, 'smsresponseserverenable', {
                       caption: L.tr('SMS Response Enable'),
                      // optional: true
                }).depends({'smsenable1':'1'});
                
                
                s5.option(L.cbi.CheckboxValue, 'enable_smscenternosim1', {
                       caption: L.tr('Enable SMS Center Number for Sim1'),
                }).depends({'smsenable1':'1'});	

                s5.option(L.cbi.InputValue, 'smscenternumber1', {
                        caption: L.tr('SMS center number for Sim1'),
                        datatype: 'uinteger',
                        description: L.tr('SMS center number in international format without the leading +')
                }).depends({'modemenable':'1','smsenable1':'1','enable_smscenternosim1':'1'});
  
                self.GetUCISections("sysconfig", "sysconfig").then(function (rv) {
					for (var key in rv) {
						if (rv.hasOwnProperty(key)) {
							var obj = rv[key];
							var cellularoperatormode = obj.CellularOperationMode;
                       
							var depends = {'smsenable1':'1'};
                       
                    
							if (cellularoperatormode === 'singlecellulardualsim') {
								depends['CellularOperationMode'] = 'singlecellulardualsim';
									s5.option(L.cbi.CheckboxValue, 'enable_smscenternosim2', {
					                       caption: L.tr('Enable SMS Center Number for Sim2'),
					               }).depends(depends);
				                }
						}
					}
				});
				
				self.GetUCISections("sysconfig", "sysconfig").then(function (rv) {
					for (var key in rv) {
						if (rv.hasOwnProperty(key)) {
							var obj = rv[key];
							var cellularoperatormode = obj.CellularOperationMode;
                       
							var depends = {'modemenable':'1','smsenable1':'1','enable_smscenternosim2':'1'};
                       
                    
							if (cellularoperatormode === 'singlecellulardualsim') {
								depends['CellularOperationMode'] = 'singlecellulardualsim';
								s5.option(L.cbi.InputValue, 'smscenternumber2', {
									caption: L.tr('SMS center number for Sim2'),
									description: L.tr('SMS center number in international format without the leading +')
								}).depends(depends);
							}
						}
					}
				});


   m5.insertInto('#section_sms');
   
     
   
   var m6 = new L.cbi.Map('sysconfig', {
                });     
   
   var s6 = m6.section(L.cbi.NamedSection, 'loopback', {
        caption:L.tr('')
    });
    
    
       s6.option(L.cbi.InputValue, 'loopbackip', {
           caption: L.tr('Loopback IP'), 
           datatype: 'ip4addr',
           placeholder:'8.8.8.8',
           optional: true
        }).depends({'loopbackipconfig':'1'}); 
        
        s6.option(L.cbi.InputValue, 'loopbacknetmask', {
           caption: L.tr('Loopback NetMask'),
           placeholder:'8.8.8.8', 
           datatype: 'ip4addr',
           optional: true
        }).depends({'loopbackipconfig':'1'});
        
   m6.insertInto('#section_loopback');  
        
     
  
    }
});
