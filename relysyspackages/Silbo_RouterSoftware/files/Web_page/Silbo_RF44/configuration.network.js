L.ui.view.extend({

    title: L.tr('Network Configuration'),
    description: L.tr('Please click on update after saving any changes.'),
      RunUdev:L.rpc.declare({
        object:'command',
        method:'exec',
        params : ['command','args'],
    }),
    
    
     fGetUCISections: L.rpc.declare({
        object: 'uci',
        method: 'get',
       // params: [ 'config', 'type', 'section']  
              params: [ 'config', 'type']  
       
    }),
    
      updateinterfaceconfig: L.rpc.declare({
        object: 'rpc-updatewanconfig',
        method: 'configure',
        params: ['application','action'],
        expect: { output: '' }
        }),

wifi_enable_disable:true,
        execute:function() {
                var self = this;
                var m = new L.cbi.Map('sysconfig', {
                });
                
                var s = m.section(L.cbi.NamedSection, 'sysconfig', {
                    caption:L.tr('Network')
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
                    }
                
                );
  
 
                       
 //=======================================================================================================================================
	//	Port 1 Eth0.1 LAN  settings
//=========================================================================================================================================		
        
        s.tab({
            id: 'ethernetconfig',
            caption: L.tr('Ethernet Settings')
        });
        
          s.taboption('ethernetconfig',L.cbi.DummyValue, 'port1settings', {
		  caption: L.tr(''),
		//  caption: L.tr(a),
        }).depends({'ethernetconfig':'1'})
        .ucivalue=function()
          {
            var id="<h3><b>&nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbspPort 1 settings </b> </h3>";
            return id;
          };   
          
         s.taboption('ethernetconfig',L.cbi.ListValue,'portmode',{          
                        caption:L.tr('Ethernet Mode'),                    
                }).value("EWAN", L.tr('EWAN'))
                 .value("LAN", L.tr('LAN')); 
                      
          s.taboption('ethernetconfig',L.cbi.ListValue, 'EthernetProtocolPortlan', {
           caption: L.tr('Ethernet LAN Connection Type'),
        }).depends({'ethernetconfig':'1','port':'port1','portmode' : 'LAN'})
          .value("dhcp",L.tr("DHCP Server"))
          .value("static",L.tr("STATIC"));
          
           s.taboption('ethernetconfig',L.cbi.InputValue, 'EthernetServerDHCPIPPortlan', {
           caption: L.tr('DHCP Server IP'), 
           datatype: 'ip4addr',
        }).depends({'ethernetconfig':'1','port':'port1','portmode' : 'LAN','EthernetProtocolPortlan':'dhcp'}); 
        
         s.taboption('ethernetconfig',L.cbi.InputValue, 'EthernetServerDHCPNetmaskPortlan', {
           caption: L.tr('DHCP Netmask'), 
           datatype: 'ip4addr',
        }).depends({'ethernetconfig':'1','port':'port1','portmode' : 'LAN','EthernetProtocolPortlan':'dhcp'}); 
        
           s.taboption('ethernetconfig',L.cbi.InputValue, 'EthernetServerDHCPrangePortlan', {
           caption: L.tr('DHCP Start Address'), 
          // datatype: 'ip4addr',
        }).depends({'ethernetconfig':'1','port':'port1','portmode' : 'LAN','EthernetProtocolPortlan':'dhcp'}); 
        
          s.taboption('ethernetconfig',L.cbi.InputValue, 'EthernetServerDHCPlimitPortlan', {
           caption: L.tr('DHCP Limit'), 
          // datatype: 'ip4addr',
        }).depends({'ethernetconfig':'1','port':'port1','portmode' : 'LAN','EthernetProtocolPortlan':'dhcp'}); 
        
       
        s.taboption('ethernetconfig',L.cbi.InputValue, 'EthernetServerStaticIPPortlan', {
           caption: L.tr('Static IP'), 
           datatype:    'ip4addr',
        }).depends({'ethernetconfig':'1','port':'port1','portmode' : 'LAN','EthernetProtocolPortlan':'static'});
          
        s.taboption('ethernetconfig',L.cbi.InputValue, 'EthernetServerStaticNetmaskPortlan', {
           caption: L.tr('Netmask'), 
           datatype:    'ip4addr',
        }).depends({'ethernetconfig':'1','port':'port1','portmode' : 'LAN','EthernetProtocolPortlan':'static'});   
        
		s.taboption('ethernetconfig',L.cbi.ListValue, 'EthernetServerStaticDnsServer', {
		   caption: L.tr('DNS Server'), 
		}).depends({'ethernetconfig':'1','port':'port1','portmode' : 'LAN'})  
		  .value("0",L.tr("Please choose no of DNS servers"))
		  .value("1",L.tr("1"))
		  .value("2",L.tr("2"));
		  
		s.taboption('ethernetconfig',L.cbi.InputValue, 'EthernetServerStaticDnsServerNo1', {
			caption: L.tr('DNS Server Address'),
			optional: true
		}).depends({'ethernetconfig':'1','port':'port1','EthernetServerStaticDnsServer':'1','portmode' : 'LAN'})   
		  .depends({'ethernetconfig':'1','port':'port1','EthernetServerStaticDnsServer':'2','portmode' : 'LAN'}); 
		
		s.taboption('ethernetconfig',L.cbi.InputValue, 'EthernetServerStaticDnsServerNo2', {
			caption: L.tr('DNS Server Address'),
		    optional: true
		}).depends({'ethernetconfig':'1','port':'port1','EthernetServerStaticDnsServer':'2','portmode' : 'LAN'});  
	      
        //s.taboption('ethernetconfig',L.cbi.CheckboxValue, 'portinternetoverlan', {
         //caption: L.tr('Internet Over LAN'),
         //optional: true
         //}).depends({'ethernetconfig' : '1','port':'port1','portmode' : 'LAN'});   
       
      //**********************EWAN Setting************************************************//
       
       s.taboption('ethernetconfig',L.cbi.ListValue, 'EthernetProtocolPortwan', {
           caption: L.tr('Ethernet WAN Connection Type'),
        }).depends({'ethernetconfig':'1','port':'port1','portmode' : 'EWAN'})
			.value("dhcp",L.tr("DHCP Client"))
			.value("static",L.tr("Static"))
			.value("pppoe",L.tr("PPPoE"))
			.value("pptp",L.tr("PPTP"))
			.value("l2tp",L.tr("L2TP"));
          
          
          s.taboption('ethernetconfig',L.cbi.InputValue,'EthernetClientDHCPGatewayPortwan' , {
           caption: L.tr('Gateway'),
           datatype: 'ip4addr',           
        }).depends({'ethernetconfig':'1','port':'port1','portmode' : 'EWAN','EthernetProtocolPortwan':'dhcp'});
             
          s.taboption('ethernetconfig',L.cbi.InputValue, 'EthernetClientStaticIPPortwan', {
           caption: L.tr('Static IP'), 
           datatype:'ip4addr',
        }).depends({'ethernetconfig':'1','port':'port1','portmode' : 'EWAN','EthernetProtocolPortwan':'static'});
            
           s.taboption('ethernetconfig',L.cbi.InputValue, 'EthernetClientnetmaskPortwan', {
           caption: L.tr('Netmask'), 
        }).depends({'ethernetconfig':'1','port':'port1','portmode' : 'EWAN','EthernetProtocolPortwan':'static'});
            
         s.taboption('ethernetconfig',L.cbi.InputValue,'EthernetClientStaticGatewayPortwan' , {
           caption: L.tr('Gateway'),
        }).depends({'ethernetconfig':'1','port':'port1','portmode' : 'EWAN','EthernetProtocolPortwan':'static'});  
          
        
        s.taboption('ethernetconfig',L.cbi.InputValue,'EthernetClientPppoeUsername' , {
           caption: L.tr('Username'),
        }).depends({'ethernetconfig':'1','port':'port1','portmode' : 'EWAN','EthernetProtocolPortwan':'pppoe'});

	s.taboption('ethernetconfig',L.cbi.InputValue,'EthernetClientPppoePassword' , {                                                       
           caption: L.tr('Password'),                                                                                                         
        }).depends({'ethernetconfig':'1','port':'port1','portmode' : 'EWAN','EthernetProtocolPortwan':'pppoe'}); 
        
        s.taboption('ethernetconfig',L.cbi.InputValue,'EthernetClientPppoeAccessConcentrator' , {                                                       
           caption: L.tr('Access Concentrator'),   
	   optional: true                                                                                                      
        }).depends({'ethernetconfig':'1','port':'port1','portmode' : 'EWAN','EthernetProtocolPortwan':'pppoe'}); 
        
	s.taboption('ethernetconfig',L.cbi.InputValue,'EthernetClientPppoeServiceName' , {
           caption: L.tr('Service Name'),
	   optional: true
        }).depends({'ethernetconfig':'1','port':'port1','portmode' : 'EWAN','EthernetProtocolPortwan':'pppoe'});
        
        s.taboption('ethernetconfig',L.cbi.InputValue,'EthernetClientPptpServerAddress' , {
           caption: L.tr('Server Address'),
        }).depends({'ethernetconfig':'1','port':'port1','portmode' : 'EWAN','EthernetProtocolPortwan':'pptp'})
	.depends({'ethernetconfig':'1','port':'port1','portmode' : 'EWAN','EthernetProtocolPortwan':'l2tp'});
        
        s.taboption('ethernetconfig',L.cbi.InputValue,'EthernetClientPptpUsername' , {
           caption: L.tr('User Name'),
        }).depends({'ethernetconfig':'1','port':'port1','portmode' : 'EWAN','EthernetProtocolPortwan':'pptp'})
        .depends({'ethernetconfig':'1','port':'port1','portmode' : 'EWAN','EthernetProtocolPortwan':'l2tp'});
        
        s.taboption('ethernetconfig',L.cbi.InputValue,'EthernetClientPptpPassword' , {
           caption: L.tr('Password'),
        }).depends({'ethernetconfig':'1','port':'port1','portmode' : 'EWAN','EthernetProtocolPortwan':'pptp'})
        .depends({'ethernetconfig':'1','port':'port1','portmode' : 'EWAN','EthernetProtocolPortwan':'l2tp'});
        
        s.taboption('ethernetconfig',L.cbi.CheckboxValue,'EthernetClientPptpMppeEncryption' , {
           caption: L.tr('MPPE Encryption'),
           optional: true
        }).depends({'ethernetconfig':'1','port':'port1','portmode' : 'EWAN','EthernetProtocolPortwan':'pptp'});
        
        s.taboption('ethernetconfig',L.cbi.ListValue, 'EthernetClientPptpDNSServerSource', {
           caption: L.tr('DNS Server Source'),
        }).depends({'ethernetconfig':'1','port':'port1','portmode' : 'EWAN','EthernetProtocolPortwan':'pptp'})
	.depends({'ethernetconfig':'1','port':'port1','portmode' : 'EWAN','EthernetProtocolPortwan':'l2tp'})  
        .value("0",L.tr("Get dynamic from ISP"))
        .value("1",L.tr("Use these DNS Servers"));        
  
        s.taboption('ethernetconfig',L.cbi.ListValue, 'EthernetClientPptpNumberOfDNSServer', {
           caption: L.tr('Number of DNS Server'),
        }).depends({'ethernetconfig':'1','port':'port1','portmode' : 'EWAN','EthernetProtocolPortwan':'pptp','EthernetClientPptpDNSServerSource':'1'})
	.depends({'ethernetconfig':'1','port':'port1','portmode' : 'EWAN','EthernetProtocolPortwan':'l2tp','EthernetClientPptpDNSServerSource':'1'})  
        .value("1",L.tr("1"))
        .value("2",L.tr("2"));
     
		s.taboption('ethernetconfig',L.cbi.InputValue, 'EthernetClientPptpDnsServerNo1', {
		caption: L.tr('DNS Server Address'),
		optional: true
		}).depends({'ethernetconfig':'1','port':'port1','portmode' : 'EWAN','EthernetProtocolPortwan':'pptp','EthernetClientPptpDNSServerSource' : '1','EthernetClientPptpNumberOfDNSServer':'1'})  
		.depends({'ethernetconfig':'1','port':'port1','portmode' : 'EWAN','EthernetProtocolPortwan':'pptp','EthernetClientPptpDNSServerSource' : '1','EthernetClientPptpNumberOfDNSServer':'2'})
		.depends({'ethernetconfig':'1','port':'port1','portmode' : 'EWAN','EthernetProtocolPortwan':'l2tp','EthernetClientPptpDNSServerSource' : '1','EthernetClientPptpNumberOfDNSServer':'1'})
		.depends({'ethernetconfig':'1','port':'port1','portmode' : 'EWAN','EthernetProtocolPortwan':'l2tp','EthernetClientPptpDNSServerSource' : '1','EthernetClientPptpNumberOfDNSServer':'2'}); 

		s.taboption('ethernetconfig',L.cbi.InputValue, 'EthernetClientPptpDnsServerNo2', {
		caption: L.tr('DNS Server Address'),
		optional: true
		}).depends({'ethernetconfig':'1','port':'port1','portmode' : 'EWAN','EthernetProtocolPortwan':'pptp','EthernetClientPptpDNSServerSource' : '1','EthernetClientPptpNumberOfDNSServer':'2'}) 
		.depends({'ethernetconfig':'1','port':'port1','portmode' : 'EWAN','EthernetProtocolPortwan':'l2tp','EthernetClientPptpDNSServerSource' : '1','EthernetClientPptpNumberOfDNSServer':'2'});
        
        
       
       
//#################################################################################################################
 // 
 //					Cellular Settings
 //
 // ##################################################################################################################                        

       s.tab({
            id: 'cellularconfig',
            caption: L.tr('Cellular Settings')
        });
        
        /* s.tab({
            id: 'simconfig',
            caption: L.tr('Cellular sim Settings')
        }).depends({'cellularconfig':'1'});*/
        
             s.taboption('cellularconfig',L.cbi.CheckboxValue, 'enablecellular', {
                        caption: L.tr('Cellular Enable'),
                        optional: true
              }).depends({'cellularconfig' : '1'});
              
        
        s.taboption('cellularconfig',L.cbi.ListValue, 'CellularOperationMode', {
           caption: L.tr('Cellular Operation Mode'),
        }).depends({'cellularconfig':'1','enablecellular':'1'})
           .value("none",L.tr("Choose Option"))
            //.value("singlecellulardualsim",L.tr("Single Cellular With Dual SIM"))
          //.value("dualcellularsinglesim",L.tr("Dual Cellular each With Single SIM"))
          .value("singlecellularsinglesim",L.tr("Single Cellular With Single SIM"));
         
          
           //============================General settings ==============================================
           
                s.taboption('cellularconfig',L.cbi.DummyValue, 'cellularmodem1', {
                        caption: L.tr('Cellular Modem 1'),
                }).depends({'cellularconfig':'1'})
               // .depends({'enablecellular':'1'})
                .depends({'CellularOperationMode' : 'dualcellularsinglesim','enablecellular':'1'})
                .depends({'CellularOperationMode' : 'singlecellularsinglesim','enablecellular':'1'})
                .depends({'CellularOperationMode' : 'singlecellulardualsim','enablecellular':'1'});
                
           /*      s.taboption('cellularconfig',L.cbi.DummyValue, 'usbbuspath1', {
                        caption: L.tr('USB Bus Path 1'),
                }).depends({'cellularconfig':'1'})
               // .depends({'enablecellular':'1'})
                .depends({'CellularOperationMode' : 'dualcellularsinglesim','enablecellular':'1'})
                .depends({'CellularOperationMode' : 'singlecellularsinglesim','enablecellular':'1'})
                .depends({'CellularOperationMode' : 'singlecellulardualsim','enablecellular':'1'});*/
                
                 s.taboption('cellularconfig',L.cbi.ListValue, 'protocol1', {
                        caption: L.tr('Protocol'),
                }).depends({'cellularconfig':'1'})
               // .depends({'enablecellular':'1'})
                .depends({'CellularOperationMode' : 'dualcellularsinglesim','enablecellular':'1','cellularmodem1':'QuectelEC200T'})
                .depends({'CellularOperationMode' : 'singlecellularsinglesim','enablecellular':'1','cellularmodem1':'QuectelEC200T'})
                .depends({'CellularOperationMode' : 'singlecellulardualsim','enablecellular':'1','cellularmodem1':'QuectelEC200T'})

                .value("none",L.tr("Choose Option"))
				.value("cdcether",L.tr("CDC-ETHER"))
				.value("ppp",L.tr("PPP"));
				
				 s.taboption('cellularconfig',L.cbi.ListValue, 'protocol1EC20', {
                        caption: L.tr('Protocol'),
                }).depends({'cellularconfig':'1'})
               // .depends({'enablecellular':'1'})
                .depends({'CellularOperationMode' : 'dualcellularsinglesim','enablecellular':'1','cellularmodem1':'QuectelEC20'})
                .depends({'CellularOperationMode' : 'singlecellularsinglesim','enablecellular':'1','cellularmodem1':'QuectelEC20'})
                .depends({'CellularOperationMode' : 'singlecellulardualsim','enablecellular':'1','cellularmodem1':'QuectelEC20'})
                .depends({'CellularOperationMode' : 'dualcellularsinglesim','enablecellular':'1','cellularmodem1':'QuectelEC25E'})
                .depends({'CellularOperationMode' : 'singlecellularsinglesim','enablecellular':'1','cellularmodem1':'QuectelEC25E'})
				.depends({'CellularOperationMode' : 'singlecellulardualsim','enablecellular':'1','cellularmodem1':'QuectelEC25E'})
				
                .value("none",L.tr("Choose Option"))
				.value("qmi",L.tr("QMI"))
				.value("ppp",L.tr("PPP"));
				
                 s.taboption('cellularconfig',L.cbi.DummyValue, 'cellularmodem2', {
                        caption: L.tr('Cellular Modem 2'),
                }).depends({'cellularconfig':'1'})
               // .depends({'enablecellular':'1'})
                .depends({'CellularOperationMode' : 'dualcellularsinglesim','enablecellular':'1'})
                

               
               s.taboption('cellularconfig',L.cbi.ListValue, 'protocol2', {
                        caption: L.tr('Protocol 2'),
                }).depends({'cellularconfig':'1'})
               // .depends({'enablecellular':'1'})
                .depends({'CellularOperationMode' : 'dualcellularsinglesim','enablecellular':'1'})
               // .depends({'CellularOperationMode' : 'singlecellulardualsim','enablecellular':'1'})
                .value("none",L.tr("Choose Option"))
				.value("cdcether",L.tr("CDC-ETHER"))
				.value("ppp",L.tr("PPP"));
				
				                
               // =================================Monitoring for sencod module================================== 
                
                 s.taboption('cellularconfig',L.cbi.CheckboxValue, 'monitorenable2', {
                        caption: L.tr('Monitor 2'),
                        optional: true
                }).depends({'cellularconfig':'1'})
                  .depends({'CellularOperationMode' : 'dualcellularsinglesim','modemenable':'1','enablecellular':'1'});

                 s.taboption('cellularconfig',L.cbi.InputValue, 'actioninterval2', {
                        caption: L.tr('Action Interval 2 (In Seconds)'),
                        datatype : 'uinteger',
                }).depends({'cellularconfig':'1'})
                 // .depends({'CellularOperationMode' : 'dualcellularsinglesim','modemenable':'1','monitorenable1':'1'})
                 // .depends({'CellularOperationMode' : 'singlecellularsinglesim','monitorenable1':'1'});
                .depends({'CellularOperationMode' : 'dualcellularsinglesim','modemenable':'1','enablecellular':'1'});
           
                s.taboption('cellularconfig',L.cbi.CheckboxValue, 'querymodematanalytics2', {
                        caption: L.tr('Modem Analytics 2'),
                        optional: true
                }).depends({'cellularconfig':'1'})
                  .depends({'CellularOperationMode' : 'dualcellularsinglesim','modemenable':'1','enablecellular':'1'})
                 // .depends({'CellularOperationMode' : 'singlecellularsinglesim','monitorenable2':'1'})
                 // .depends({'CellularOperationMode' : 'singlecellulardualsim','monitorenable2':'1'});
                
                s.taboption('cellularconfig',L.cbi.CheckboxValue, 'datatestenable2', {
                        caption: L.tr('Data Test 2'),
                        caption: L.tr('Data Test 2'),
                        optional: true
                }).depends({'cellularconfig':'1'})
                  .depends({'CellularOperationMode' : 'dualcellularsinglesim','modemenable':'1','enablecellular':'1'})
                 // .depends({'CellularOperationMode' : 'singlecellularsinglesim'})
                //  .depends({'CellularOperationMode' : 'singlecellulardualsim'});    
                
                 s.taboption('cellularconfig',L.cbi.CheckboxValue, 'pingtestenable2', {
                        caption: L.tr('Ping Test 2'),
                        optional: true
                }).depends({'cellularconfig':'1'})
                  .depends({'CellularOperationMode' : 'dualcellularsinglesim','modemenable':'1','enablecellular':'1'})
                
                s.taboption('cellularconfig',L.cbi.InputValue, 'pingip2', {
                        caption: L.tr('Ping IP 2'),
                        optional: true
                }).depends({'cellularconfig':'1'})
                  .depends({'CellularOperationMode' : 'dualcellularsinglesim','modemenable':'1','pingtestenable2' : '1','enablecellular':'1'}) 
                 
         
         //========================SIM1 Settings ==============================
         
         /* s.taboption('cellularconfig',L.cbi.ListValue, 'service', {         
                        caption: L.tr('Network Mode'),                    
                }).depends({'cellularconfig':'1'})
                  .depends({'CellularOperationMode' : 'dualcellularsinglesim','modemenable':'1','dataenable' : '1','enablecellular':'1'})
                  .depends({'CellularOperationMode' : 'singlecellularsinglesim','modemenable':'1','dataenable' : '1','enablecellular':'1'})
                  .depends({'CellularOperationMode' : 'singlecellulardualsim','modemenable':'1','dataenable' : '1','enablecellular':'1'})                                
                .value('auto', L.tr('AUTOMATIC'))                             
                .value('lte', L.tr('LTE only')); */                             
          
                    s.taboption('cellularconfig',L.cbi.ListValue, 'Sim1apntype', {
                        caption: L.tr('Choose SIM 1 APN Mode')
					}).depends({'cellularconfig':'1'})
					  .depends({'CellularOperationMode' : 'dualcellularsinglesim','modemenable':'1','dataenable' : '1','enablecellular':'1'})
                      .depends({'CellularOperationMode' : 'singlecellularsinglesim','modemenable':'1','dataenable' : '1','enablecellular':'1'})
                      .depends({'CellularOperationMode' : 'singlecellulardualsim','modemenable':'1','dataenable' : '1','enablecellular':'1'}) 
					  .value('auto', L.tr('Auto'))                        
                      .value('manual', L.tr('Manual')); 
                        
                        s.taboption('cellularconfig',L.cbi.DummyValue, 'sim1autoapn', {
                        caption: L.tr('SIM 1 Access Point Name')
					}).depends({'cellularconfig':'1'})
					  .depends({'CellularOperationMode' : 'dualcellularsinglesim','modemenable':'1','dataenable' : '1','enablecellular':'1','Sim1apntype':'auto'})
                      .depends({'CellularOperationMode' : 'singlecellularsinglesim','modemenable':'1','dataenable' : '1','enablecellular':'1','Sim1apntype':'auto'})
                      .depends({'CellularOperationMode' : 'singlecellulardualsim','modemenable':'1','dataenable' : '1','enablecellular':'1','Sim1apntype':'auto'});     
                                                 
					s.taboption('cellularconfig',L.cbi.InputValue, 'apn', {
                        caption: L.tr('SIM 1 Access Point Name')
                }).depends({'cellularconfig':'1'})
                  .depends({'CellularOperationMode' : 'dualcellularsinglesim','modemenable':'1','dataenable' : '1','enablecellular':'1','Sim1apntype':'manual'})
                  .depends({'CellularOperationMode' : 'singlecellularsinglesim','modemenable':'1','dataenable' : '1','enablecellular':'1','Sim1apntype':'manual'})
                  .depends({'CellularOperationMode' : 'singlecellulardualsim','modemenable':'1','dataenable' : '1','enablecellular':'1','Sim1apntype':'manual'}) ;
                
          s.taboption('cellularconfig',L.cbi.ListValue, 'pdp', {
                        caption: L.tr('SIM 1 PDP Type')
                }).depends({'cellularconfig':'1'})
                  .depends({'CellularOperationMode' : 'dualcellularsinglesim','modemenable':'1','dataenable' : '1','enablecellular':'1'})
                  .depends({'CellularOperationMode' : 'singlecellularsinglesim','modemenable':'1','dataenable' : '1','enablecellular':'1'})
                  .depends({'CellularOperationMode' : 'singlecellulardualsim','modemenable':'1','dataenable' : '1','enablecellular':'1'})
                .value('IPV4', L.tr('IPV4'))                        
                .value('IPV6', L.tr('IPV6'))                        
                .value('IPV4V6', L.tr('IPV4V6')); 
                
               
                s.taboption('cellularconfig',L.cbi.InputValue, 'username', {
                        caption: L.tr('SIM 1 Username'),
                        optional: true 
                }).depends({'cellularconfig':'1'})
                  .depends({'CellularOperationMode' : 'dualcellularsinglesim','modemenable':'1','dataenable' : '1','enablecellular':'1'})
                  .depends({'CellularOperationMode' : 'singlecellularsinglesim','modemenable':'1','dataenable' : '1','enablecellular':'1'})
                  .depends({'CellularOperationMode' : 'singlecellulardualsim','modemenable':'1','dataenable' : '1','enablecellular':'1'});
                
                s.taboption('cellularconfig',L.cbi.PasswordValue,'password',{
                        caption: L.tr('SIM 1 Password'),
                        optional: true 
                }).depends({'cellularconfig':'1'})
                  .depends({'CellularOperationMode' : 'dualcellularsinglesim','modemenable':'1','dataenable' : '1','enablecellular':'1'})
                  .depends({'CellularOperationMode' : 'singlecellularsinglesim','modemenable':'1','dataenable' : '1','enablecellular':'1'})
                  .depends({'CellularOperationMode' : 'singlecellulardualsim','modemenable':'1','dataenable' : '1','enablecellular':'1'});
                
                s.taboption('cellularconfig',L.cbi.ListValue, 'auth', {
                        caption: L.tr('SIM 1 Authentication Protocol'),
                }).depends({'cellularconfig':'1'})
                  .depends({'CellularOperationMode' : 'dualcellularsinglesim','modemenable':'1','dataenable' : '1','enablecellular':'1'})
                  .depends({'CellularOperationMode' : 'singlecellularsinglesim','modemenable':'1','dataenable' : '1','enablecellular':'1'})
                  .depends({'CellularOperationMode' : 'singlecellulardualsim','modemenable':'1','dataenable' : '1','enablecellular':'1'})
           .value('0', L.tr('None'))
                .value('1', L.tr('PAP'))
                .value('2', L.tr('CHAP')); 
                
            //=========================== SIM 2 Settings ====================================
            
			 s.taboption('cellularconfig',L.cbi.CheckboxValue, 'dataenable2', {
                        caption: L.tr('Data Service2'),
                        optional: true
                }) .depends({'cellularconfig':'1'})
                  .depends({'CellularOperationMode' : 'dualcellularsinglesim','modemenable':'1','enablecellular':'1'});
                 
			

            /*   s.taboption('cellularconfig',L.cbi.ListValue, 'sim2service', {         
                        caption: L.tr('SIM 2 Service'),                    
                })
                //.depends({'cellularconfig' : '1','CellularOperationMode' : 'singlecellulardualsim','CellularOperationMode' :'dualcellularsinglesim','modemenable':'1','dataenable':'1'})                                
                .depends({'cellularconfig' : '1'})
                .depends({'CellularOperationMode' : 'singlecellulardualsim','modemenable':'1','dataenable':'1','enablecellular':'1'})
                .depends({'CellularOperationMode' : 'dualcellularsinglesim','modemenable':'1','dataenable':'1','enablecellular':'1'})
                .value('auto', L.tr('AUTOMATIC'))               
                .value('2g', L.tr('2G only'))                           
                .value('lte', L.tr('LTE only')); */                             
                                     
          s.taboption('cellularconfig',L.cbi.InputValue, 'sim2apn', {
                        caption: L.tr('SIM 2 Access Point Name')
                })
                //.depends({'cellularconfig' : '1','CellularOperationMode' : 'singlecellulardualsim','CellularOperationMode' :'dualcellularsinglesim','modemenable':'1','dataenable':'1'});
                 .depends({'cellularconfig' : '1'})
                .depends({'CellularOperationMode' : 'singlecellulardualsim','modemenable':'1','dataenable':'1','enablecellular':'1'})
                .depends({'CellularOperationMode' : 'dualcellularsinglesim','modemenable':'1','dataenable':'1','enablecellular':'1'});
                
          s.taboption('cellularconfig',L.cbi.ListValue, 'sim2pdp', {
                        caption: L.tr('SIM 2 PDP Type')
                })
                //.depends({'cellularconfig' : '1','CellularOperationMode' : 'singlecellulardualsim','CellularOperationMode' :'dualcellularsinglesim','modemenable':'1','dataenable':'1'})
                .depends({'cellularconfig' : '1'})
                .depends({'CellularOperationMode' : 'singlecellulardualsim','modemenable':'1','dataenable':'1','enablecellular':'1'})
                .depends({'CellularOperationMode' : 'dualcellularsinglesim','modemenable':'1','dataenable':'1','enablecellular':'1'})
                .value('IPV4', L.tr('IPV4'))                        
                .value('IPV6', L.tr('IPV6'))                        
                .value('IPV4V6', L.tr('IPV4V6')); 
                
            s.taboption('cellularconfig',L.cbi.CheckboxValue, 'Enable464xlatSim1', {
                        caption: L.tr('Enable CLAT support for SIM1')
                }).depends({'cellularconfig':'1'})
                  .depends({'CellularOperationMode' : 'dualcellularsinglesim','modemenable':'1','dataenable' : '1','enablecellular':'1','pdp':'IPV6'})
                  .depends({'CellularOperationMode' : 'singlecellularsinglesim','modemenable':'1','dataenable' : '1','enablecellular':'1','pdp':'IPV6'})
                  .depends({'CellularOperationMode' : 'singlecellulardualsim','modemenable':'1','dataenable' : '1','enablecellular':'1','pdp':'IPV6'});
                
         /* s.taboption('cellularconfig',L.cbi.InputValue, 'sim2pincode', {
                        caption: L.tr('SIM 2 PIN Code'),
                        optional: true 
                })
                //.depends({'cellularconfig' : '1','CellularOperationMode' : 'singlecellulardualsim','CellularOperationMode' : 'dualcellularsinglesim','modemenable':'1','dataenable':'1'});
                                .depends({'cellularconfig' : '1'})
                .depends({'CellularOperationMode' : 'singlecellulardualsim','modemenable':'1','dataenable':'1'})
                .depends({'CellularOperationMode' : 'dualcellularsinglesim','modemenable':'1','dataenable':'1'});*/
                
                
                s.taboption('cellularconfig',L.cbi.InputValue, 'sim2username', {
                        caption: L.tr('SIM 2 Username'),
                        optional: true 
                })
                //.depends({'cellularconfig' : '1','CellularOperationMode' : 'singlecellulardualsim','CellularOperationMode' : 'dualcellularsinglesim','modemenable':'1','dataenable':'1'});
                                .depends({'cellularconfig' : '1'})
                .depends({'CellularOperationMode' : 'singlecellulardualsim','modemenable':'1','dataenable':'1','enablecellular':'1'})
                .depends({'CellularOperationMode' : 'dualcellularsinglesim','modemenable':'1','dataenable':'1','enablecellular':'1'});
                                
                s.taboption('cellularconfig',L.cbi.PasswordValue,'sim2password',{
                        caption: L.tr('SIM 2 Password'),
                        optional: true 
                })
                //.depends({'cellularconfig' : '1','CellularOperationMode' : 'singlecellulardualsim','CellularOperationMode' : 'dualcellularsinglesim','modemenable':'1','dataenable':'1'});
                 .depends({'cellularconfig' : '1'})
                .depends({'CellularOperationMode' : 'singlecellulardualsim','modemenable':'1','dataenable':'1','enablecellular':'1'})
                .depends({'CellularOperationMode' : 'dualcellularsinglesim','modemenable':'1','dataenable':'1','enablecellular':'1'});
                
                s.taboption('cellularconfig',L.cbi.ListValue, 'sim2auth', {
                        caption: L.tr('SIM 2 Authentication Protocol'),
                })
                //.depends({'cellularconfig' : '1','CellularOperationMode' : 'singlecellulardualsim','CellularOperationMode' : 'dualcellularsinglesim','modemenable':'1','dataenable':'1'})
                 .depends({'cellularconfig' : '1'})
                .depends({'CellularOperationMode' : 'singlecellulardualsim','modemenable':'1','dataenable':'1','enablecellular':'1'})
                .depends({'CellularOperationMode' : 'dualcellularsinglesim','modemenable':'1','dataenable':'1','enablecellular':'1'})
                .value('0', L.tr('None'))
                .value('1', L.tr('PAP'))
                .value('2', L.tr('CHAP'));  
                
                   s.taboption('cellularconfig',L.cbi.CheckboxValue, 'primarysimswitchbackenable', {
                        caption: L.tr('Primary SIM Switchback Enable'),
                        optional: true
                }) .depends({'cellularconfig':'1'})
                   .depends({'CellularOperationMode' : 'singlecellulardualsim','modemenable':'1','dataenable':'1','enablecellular':'1'});   
                
                
                  s.taboption('cellularconfig',L.cbi.InputValue, 'primarysimswitchbacktime', {
                        caption: L.tr('Primary SIM Switchback Time (In Minutes)'),
                        optional: true 
                })
                .depends({'cellularconfig' : '1'})
                .depends({'CellularOperationMode' : 'singlecellulardualsim','modemenable':'1','dataenable':'1','primarysimswitchbackenable': '1','enablecellular':'1'});
                      
                         s.tab({
            id: 'band',
            caption: L.tr('Band Lock and Operator Lock')
        });
		
      		 
		  s.taboption('band',L.cbi.ListValue, 'bandselectenable', {         
                        caption: L.tr('Band Lock Selection'), 
                        optional: true                   
                }).depends({'cellularconfig':'1'})
                  .depends({'CellularOperationMode' : 'dualcellularsinglesim','modemenable':'1','dataenable' : '1','enablecellular':'1','band':'1'})
                  .depends({'CellularOperationMode' : 'singlecellularsinglesim','modemenable':'1','dataenable' : '1','enablecellular':'1','band':'1'})
                  .depends({'CellularOperationMode' : 'singlecellulardualsim','modemenable':'1','dataenable' : '1','enablecellular':'1','band':'1'})                                
                .value('auto', L.tr('AUTOMATIC'))
                .value('2g', L.tr('2G'))                              
                .value('3g', L.tr('3G')) 
                .value('lte', L.tr('LTE only'));   
                
              s.taboption('band',L.cbi.CheckboxValue, 'gsm900', {
                        caption: L.tr('GSM 900'),
                        optional: true
                }).depends({'cellularconfig':'1','enablecellular':'1','dataenable':'1','bandselectenable':'1'})
                .depends({'CellularOperationMode' : 'singlecellularsinglesim','enablecellular':'1','bandselectenable' : '2g'})
                .depends({'CellularOperationMode' : 'singlecellulardualsim','enablecellular':'1','bandselectenable' : '2g'});
                
                s.taboption('band',L.cbi.CheckboxValue, 'gsm1800', {
                        caption: L.tr('GSM 1800'),
                        optional: true
                }).depends({'cellularconfig':'1','enablecellular':'1','dataenable':'1','bandselectenable':'1'})
                .depends({'CellularOperationMode' : 'singlecellularsinglesim','enablecellular':'1','bandselectenable' : '2g'})
                .depends({'CellularOperationMode' : 'singlecellulardualsim','enablecellular':'1','bandselectenable' : '2g'});
                
                 s.taboption('band',L.cbi.CheckboxValue, 'wcdma2100', {
                        caption: L.tr('WCDMA 2100'),
                        optional: true
                }).depends({'cellularconfig':'1','enablecellular':'1','dataenable':'1','bandselectenable':'1'})
                .depends({'CellularOperationMode' : 'singlecellularsinglesim','enablecellular':'1','bandselectenable' : '3g'})
                .depends({'CellularOperationMode' : 'singlecellulardualsim','enablecellular':'1','bandselectenable' : '3g'});
                
                 s.taboption('band',L.cbi.CheckboxValue, 'wcdma850', {
                        caption: L.tr('WCDMA 850'),
                        optional: true
                }).depends({'cellularconfig':'1','enablecellular':'1','dataenable':'1','bandselectenable':'1'})
                .depends({'CellularOperationMode' : 'singlecellularsinglesim','enablecellular':'1','bandselectenable' : '3g'})
                .depends({'CellularOperationMode' : 'singlecellulardualsim','enablecellular':'1','bandselectenable' : '3g'});
                
                 s.taboption('band',L.cbi.CheckboxValue, 'wcdma900', {
                        caption: L.tr('WCDMA 900'),
                        optional: true
                }).depends({'cellularconfig':'1','enablecellular':'1','dataenable':'1','bandselectenable':'1'})
                .depends({'CellularOperationMode' : 'singlecellularsinglesim','enablecellular':'1','bandselectenable' : '3g'})
                .depends({'CellularOperationMode' : 'singlecellulardualsim','enablecellular':'1','bandselectenable' : '3g'});
                
                s.taboption('band',L.cbi.CheckboxValue, 'lteb1', {
                        caption: L.tr('LTE B1'),
                        optional: true
                }).depends({'cellularconfig':'1','enablecellular':'1','dataenable':'1','bandselectenable':'1'})
                .depends({'CellularOperationMode' : 'singlecellularsinglesim','enablecellular':'1','bandselectenable' : 'lte'})
                .depends({'CellularOperationMode' : 'singlecellulardualsim','enablecellular':'1','bandselectenable' : 'lte'});  
                
                 s.taboption('band',L.cbi.CheckboxValue, 'lteb3', {
                        caption: L.tr('LTE B3'),
                        optional: true
                }).depends({'cellularconfig':'1','enablecellular':'1','dataenable':'1','bandselectenable':'1'})
                .depends({'CellularOperationMode' : 'singlecellularsinglesim','enablecellular':'1','bandselectenable' : 'lte'})
                .depends({'CellularOperationMode' : 'singlecellulardualsim','enablecellular':'1','bandselectenable' : 'lte'});  
                
                 s.taboption('band',L.cbi.CheckboxValue, 'lteb5', {
                        caption: L.tr('LTE B5'),
                        optional: true
                }).depends({'cellularconfig':'1','enablecellular':'1','dataenable':'1','bandselectenable':'1'})
                .depends({'CellularOperationMode' : 'singlecellularsinglesim','enablecellular':'1','bandselectenable' : 'lte'})
                .depends({'CellularOperationMode' : 'singlecellulardualsim','enablecellular':'1','bandselectenable' : 'lte'});  
                
                 s.taboption('band',L.cbi.CheckboxValue, 'lteb8', {
                        caption: L.tr('LTE B8'),
                        optional: true
                }).depends({'cellularconfig':'1','enablecellular':'1','dataenable':'1','bandselectenable':'1'})
                .depends({'CellularOperationMode' : 'singlecellularsinglesim','enablecellular':'1','bandselectenable' : 'lte'})
                .depends({'CellularOperationMode' : 'singlecellulardualsim','enablecellular':'1','bandselectenable' : 'lte'});  
                
                 s.taboption('band',L.cbi.CheckboxValue, 'lteb34', {
                        caption: L.tr('LTE B34'),
                        optional: true
                }).depends({'cellularconfig':'1','enablecellular':'1','dataenable':'1','bandselectenable':'1'})
                .depends({'CellularOperationMode' : 'singlecellularsinglesim','enablecellular':'1','bandselectenable' : 'lte'})
                .depends({'CellularOperationMode' : 'singlecellulardualsim','enablecellular':'1','bandselectenable' : 'lte'});  
                
                 s.taboption('band',L.cbi.CheckboxValue, 'lteb38', {
                        caption: L.tr('LTE B38'),
                        optional: true
                }).depends({'cellularconfig':'1','enablecellular':'1','dataenable':'1','bandselectenable':'1'})
                .depends({'CellularOperationMode' : 'singlecellularsinglesim','enablecellular':'1','bandselectenable' : 'lte'})
                .depends({'CellularOperationMode' : 'singlecellulardualsim','enablecellular':'1','bandselectenable' : 'lte'});  
                
                 s.taboption('band',L.cbi.CheckboxValue, 'lteb39', {
                        caption: L.tr('LTE B39'),
                        optional: true
                }).depends({'cellularconfig':'1','enablecellular':'1','dataenable':'1','bandselectenable':'1'})
                .depends({'CellularOperationMode' : 'singlecellularsinglesim','enablecellular':'1','bandselectenable' : 'lte'})
                .depends({'CellularOperationMode' : 'singlecellulardualsim','enablecellular':'1','bandselectenable' : 'lte'});  
                
                 s.taboption('band',L.cbi.CheckboxValue, 'lteb40', {
                        caption: L.tr('LTE B40'),
                        optional: true
                }).depends({'cellularconfig':'1','enablecellular':'1','dataenable':'1','bandselectenable':'1'})
                .depends({'CellularOperationMode' : 'singlecellularsinglesim','enablecellular':'1','bandselectenable' : 'lte'})
                .depends({'CellularOperationMode' : 'singlecellulardualsim','enablecellular':'1','bandselectenable' : 'lte'});  
                
                 s.taboption('band',L.cbi.CheckboxValue, 'lteb41', {
                        caption: L.tr('LTE B41'),
                        optional: true
                }).depends({'cellularconfig':'1','enablecellular':'1','dataenable':'1','bandselectenable':'1'})
                .depends({'CellularOperationMode' : 'singlecellularsinglesim','enablecellular':'1','bandselectenable' : 'lte'})
                .depends({'CellularOperationMode' : 'singlecellulardualsim','enablecellular':'1','bandselectenable' : 'lte'});  
                

//=================================Operator sections ==============================================================================         
       
         s.taboption('band',L.cbi.CheckboxValue, 'enableoperator', {
                    caption: L.tr('Operator Select Enable'),
                    optional: true
                  }).depends({'cellularconfig':'1','enablecellular':'1'});
                            
         s.taboption('band',L.cbi.ListValue, 'operatorlockenable', {         
                    caption: L.tr('Operator Selection Mode'), 
                    optional: true                   
                  }).depends({'cellularconfig':'1','enablecellular':'1','dataenable':'1','bandselectenable':'1'})
                    .depends({'enableoperator':'1' ,'band':'1'})
                    
                    .value('auto', L.tr('AUTOMATIC'))
                    .value('manual', L.tr('MANUAL'))                              
                    .value('manual-auto', L.tr('MANUAL-AUTOMATIC')); 
                
         s.taboption('band',L.cbi.InputValue, 'Code', {
                    caption: L.tr('Operator Code'),
                    optional: true 
                    }).depends({'enableoperator':'1', 'operatorlockenable' : 'manual'})
                      .depends({'enableoperator':'1','operatorlockenable' : 'manual-auto'});
         
//=================================Operator sections =================================================================================                                 
                                                            
        

      if(self.wifi_enable_disable)
    {
                    
        s.tab({
            id: 'wificonfig',
            caption: L.tr('WIFI Settings')
        });
        
        s.taboption('wificonfig',L.cbi.DummyValue, 'generalsettings', {
		  caption: L.tr(''),
        }).depends({'wificonfig':'1'})
        .ucivalue=function()
          {
            var id="<h3><b>&nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbspGeneral settings </b> </h3>";
            return id;
          };  
          
       
        //Wifi Devices
        
        s.taboption('wificonfig', L.cbi.ListValue, 'wifi1protocol', {
		caption:	L.tr('Radio 0 Protocol'),
		}).depends({'wificonfig':'1'})
		.value('none', L.tr('Please choose'))
		.value('IEEE802.11b/g/n', L.tr('IEEE 802.11 b/g/n'));
        
          
         s.taboption('wificonfig', L.cbi.ListValue, 'CountryCode', {
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
        
        
         s.taboption('wificonfig',L.cbi.ListValue, 'wifideviceschannel', {
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
         
         s.taboption('wificonfig', L.cbi.InputValue, 'TxPower', {
		caption:	L.tr('TX Power'),
		datatype:'rangelength(0,100)',
		}).depends({'wificonfig':'1'});
		
		s.taboption('wificonfig', L.cbi.ListValue, 'channelwidth', {
		caption:	L.tr('Channel width'),
		}).depends({'wificonfig':'1'})
		  .value('0', L.tr('20 MHz'))
		.value('1', L.tr('20/40 MHz')); 
		    
		s.taboption('wificonfig',L.cbi.CheckboxValue, 'wifi1enable', {
			caption:	L.tr('Enable Radio')
		}).depends({'wificonfig':'1'});
		  		
		s.taboption('wificonfig', L.cbi.ListValue, 'wifi1mode', {
			caption:	L.tr('Radio Mode'),
		}).depends({'wificonfig':'1','wifi1enable':'1'})
		.value('ap', L.tr('Access Point'))
		.value('sta', L.tr('Client only'))
		.value('apsta', L.tr('Access Point and Client'));
				       
        s.taboption('wificonfig', L.cbi.InputValue, 'wifi1ssid', {
			caption:	'Radio SSID',
			datatype: 'rt_alphanumericsplchar',
		}).depends({'wificonfig':'1','wifi1enable' : '1','wifi1mode':'ap'})
		  .depends({'wificonfig':'1','wifi1enable' : '1','wifi1mode':'apsta'});
		
		s.taboption('wificonfig', L.cbi.ListValue, 'wifi1authentication', {
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
		
		s.taboption('wificonfig', L.cbi.ListValue, 'wifi1encryption', {
			caption:	L.tr('Radio Encryption'),
			initial:	'none'
		}).depends({'wificonfig':'1','wifi1enable' : '1','wifi1mode':'ap'})
		  .depends({'wificonfig':'1','wifi1enable' : '1','wifi1mode':'apsta'})
		.value('NONE', L.tr('NONE'))
		.value('TKIP', L.tr('TKIP'))
		.value('TKIPAES', L.tr('TKIPAES'))
		.value('AES', L.tr('AES'));
		
		
		
		s.taboption('wificonfig', L.cbi.PasswordValue, 'wifi1key', {
			caption:	L.tr('Radio Passphrase'),
			datatype:'rangelength(8,11)',
			optional:	true
		}).depends({'wificonfig':'1','wifi1enable' : '1','wifi1mode':'ap'})
		  .depends({'wificonfig':'1','wifi1enable' : '1','wifi1mode':'apsta'});
		
			 s.taboption('wificonfig',L.cbi.InputValue, 'radio0dhcpip', {
           caption: L.tr('Radio DHCP Server IP'), 
           datatype: 'ip4addr',
        }).depends({'wificonfig':'1','wifi1enable' : '1','wifi1mode':'ap'})
		  .depends({'wificonfig':'1','wifi1enable' : '1','wifi1mode':'apsta'});
        
                
           s.taboption('wificonfig',L.cbi.InputValue, 'Radio0DHCPrange', {
           caption: L.tr('Radio DHCP Start Address'), 
        }).depends({'wificonfig':'1','wifi1enable' : '1','wifi1mode':'ap'})
		  .depends({'wificonfig':'1','wifi1enable' : '1','wifi1mode':'apsta'});
        
          s.taboption('wificonfig',L.cbi.InputValue, 'Radio0DHCPlimit', {
           caption: L.tr('Radio DHCP Limit'), 
        }).depends({'wificonfig':'1','wifi1enable' : '1','wifi1mode':'ap'})
		  .depends({'wificonfig':'1','wifi1enable' : '1','wifi1mode':'apsta'});
        
        s.taboption('wificonfig', L.cbi.InputValue, 'wifi1stassid', {
			caption:	'Client SSID'
		})
		.depends({'wificonfig':'1','wifi1enable' : '1','wifi1mode':'sta'})
		  .depends({'wificonfig':'1','wifi1enable' : '1','wifi1mode':'apsta'});
		
		s.taboption('wificonfig', L.cbi.ListValue, 'wifi1staencryption', {
			caption:	L.tr('Client Encryption'),
			initial:	'none'
		}).depends({'wificonfig':'1','wifi1enable' : '1','wifi1mode':'sta'})
		  .depends({'wificonfig':'1','wifi1enable' : '1','wifi1mode':'apsta'})
		.value('none', L.tr('No encryption'))
		.value('psk', L.tr('WPA Personal (PSK)'))
		.value('psk2', L.tr('WPA2 Personal (PSK)'))
		.value('mixed-psk', L.tr('WPA/WPA2 Personal (PSK) mixed'));
		
		
		s.taboption('wificonfig', L.cbi.PasswordValue, 'wifi1stakey', {
			caption:	L.tr('Client Passphrase'),
			optional:	true
		}).depends({'wificonfig':'1','wifi1enable' : '1','wifi1mode':'sta'})
		  .depends({'wificonfig':'1','wifi1enable' : '1','wifi1mode':'apsta'});
		
			s.taboption('wificonfig',L.cbi.ListValue, 'wifiServerStaticDnsServer', {
		   caption: L.tr('Wifi DNS Server'), 
		}).depends({'wificonfig':'1','wifi1enable' : '1','wifi1mode':'apsta'})  
		  .depends({'wificonfig':'1','wifi1enable' : '1','wifi1mode':'ap'})  
		  .value("0",L.tr("Please choose no of DNS servers"))
		  .value("1",L.tr("1"))
		  .value("2",L.tr("2"));
		  
		s.taboption('wificonfig',L.cbi.InputValue, 'WifiServerStaticDnsServerNo1', {
			caption: L.tr('DNS Server Address'),
			optional: true
		}).depends({'wificonfig':'1','wifi1enable' : '1','wifi1mode':'apsta','wifiServerStaticDnsServer':'1'})  
		  .depends({'wificonfig':'1','wifi1enable' : '1','wifi1mode':'ap','wifiServerStaticDnsServer':'1'})  
		  .depends({'wificonfig':'1','wifi1enable' : '1','wifi1mode':'apsta','wifiServerStaticDnsServer':'2'})
		  .depends({'wificonfig':'1','wifi1enable' : '1','wifi1mode':'ap','wifiServerStaticDnsServer':'2'});
		
		s.taboption('wificonfig',L.cbi.InputValue, 'WifiServerStaticDnsServerNo2', {
			caption: L.tr('DNS Server Address'),
		    optional: true
		}).depends({'wificonfig':'1','wifi1enable' : '1','wifi1mode':'ap','wifiServerStaticDnsServer':'2'}) 
		  .depends({'wificonfig':'1','wifi1enable' : '1','wifi1mode':'apsta','wifiServerStaticDnsServer':'2'});
	
         s.tab({
            id: 'guestwifi',
            caption: L.tr('Guest Wifi')
        });
		
      
         s.taboption('guestwifi',L.cbi.CheckboxValue, 'guestwifienable', {
			caption:	L.tr('Enable Guest Wifi')
		}).depends({'wificonfig':'1','wifi1enable' : '1','wifi1mode':'ap'});
		  		
      
         s.taboption('guestwifi', L.cbi.InputValue, 'guestwifissid', {
			caption:	'SSID'
		}).depends({'wificonfig':'1','wifi1enable' : '1','wifi1mode':'ap','guestwifi':'1','guestwifienable':'1'})
		
				s.taboption('guestwifi', L.cbi.ListValue, 'guestwifi1authentication', {
			caption:	L.tr('Radio Authentication'),
			initial:	'none'
		}).depends({'wificonfig':'1','wifi1enable' : '1','wifi1mode':'ap','guestwifi':'1','guestwifienable':'1'})
		.value('OPEN', L.tr('No Authentication'))
		.value('WPAPSK', L.tr('WPA Personal (PSK)'))
		.value('WPA2PSK', L.tr('WPA2 Personal (PSK)'))
		.value('WPAPSKWPA2PSK', L.tr('WPAPSK/WPA2PSK mixed mode'))
		.value('WPA3PSK', L.tr('WPA3 Personal(PSK)'))
		.value('WPA2PSKWPA3PSK', L.tr('WPA2PSK/WPA3PSK mixed mode'));
		
		s.taboption('guestwifi', L.cbi.ListValue, 'guestwifi1encryption', {
			caption:	L.tr('Radio Encryption'),
			initial:	'none'
		}).depends({'wificonfig':'1','wifi1enable' : '1','wifi1mode':'ap','guestwifi':'1','guestwifienable':'1'})
		.value('NONE', L.tr('NONE'))
		.value('TKIP', L.tr('TKIP'))
		.value('TKIPAES', L.tr('TKIPAES'))
		.value('AES', L.tr('AES'));
		
		s.taboption('guestwifi', L.cbi.PasswordValue, 'guestwifikey', {
			caption:	L.tr('Passphrase'),
			datatype:'rangelength(8,11)',
			optional:	true
		}).depends({'wificonfig':'1','wifi1enable' : '1','wifi1mode':'ap','guestwifi':'1','guestwifienable':'1'})
      
        s.taboption('guestwifi',L.cbi.InputValue, 'guestradio0dhcpip', {
           caption: L.tr('Server IP'), 
           datatype: 'ip4addr',
        }).depends({'wificonfig':'1','wifi1enable' : '1','wifi1mode':'ap','guestwifi':'1','guestwifienable':'1'})
        
                
        s.taboption('guestwifi',L.cbi.InputValue, 'guestRadio0DHCPrange', {
           caption: L.tr('Start Address'), 
        }).depends({'wificonfig':'1','wifi1enable' : '1','wifi1mode':'ap','guestwifi':'1','guestwifienable':'1'})
        
        s.taboption('guestwifi',L.cbi.InputValue, 'guestRadio0DHCPlimit', {
           caption: L.tr('DHCP Limit'), 
        }).depends({'wificonfig':'1','wifi1enable' : '1','wifi1mode':'ap','guestwifi':'1','guestwifienable':'1'})
        
      
        s.tab({
            id: 'wificonfigschedule',
            caption: L.tr('Wireless Schedule')
        });
		
		   s.taboption('wificonfigschedule',L.cbi.DummyValue, 'generalsettings', {
		  caption: L.tr(''),
        }).depends({'wificonfig':'1'})
        .depends({'wifi1enable':'1' })
        .ucivalue=function()
          {
            var id="<h3><b>&nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbspWifi Schedule ON/OFF settings </b> </h3>";
            return id;
          }; 
		
		s.taboption('wificonfigschedule',L.cbi.DummyValue, 'generalsettings', {
		  caption: L.tr(''),
        }).depends({'wificonfig':'1','wifi1enable':'0' })
        .ucivalue=function()
          {
            var id="<h3><b>&nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbspPlease Enable wifi to configure Schedule ON/OFF settings</b> </h3>";
            return id;
          }; 
		
		 s.taboption('wificonfigschedule', L.cbi.CheckboxValue, 'ScheduledOnOff', {
			caption:	L.tr('Scheduled Wifi On/Off'),
		}).depends({'wificonfig':'1','wifi1enable':'1','wificonfigschedule':'1'});
		
		
        
        /*var DaysVal = s.taboption('wificonfigschedule', L.cbi.DynamicList, 'DayOfMonth', {
            caption: L.tr('Day Of Month'),
            optional: true,
            listlimit: 31,
            listcustom:false
        }).depends({'wificonfig':'1','wifi1enable':'1','wificonfigschedule':'1','ScheduledOnOff':'1'})
        .value('',L.tr('-- Please choose --'))
        .value('*', L.tr('All'));

        DaysVal.load = function(sid) {
            var days = [ ];
            for (var i = 1; i <= 31; i++)
                days.push(i);
            days.sort();
            for (var i = 1; i <= days.length; i++)
                DaysVal.value(i);
        };*/

        /*s.taboption('wificonfigschedule', L.cbi.DynamicList, 'Month', {
            caption: L.tr('Month'),
            optional: true,
            listlimit: 12,
            listcustom:false
        }).depends({'wificonfig':'1','wifi1enable':'1','wificonfigschedule':'1','ScheduledOnOff':'1'})
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
        .value('12', L.tr('December'));*/

        s.taboption('wificonfigschedule', L.cbi.DynamicList, 'DayOfWeek', {
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
        		
		
		s.taboption('wificonfigschedule',L.cbi.DummyValue, 'from', {
		  caption: L.tr(''),
        }).depends({'wificonfig':'1','wifi1enable':'1' ,'wificonfigschedule':'1'})
        .ucivalue=function()
          {
            var id="<h5><b>&nbsp &nbsp &nbsp &nbsp &nbsp &nbsp From: </b> </h5>";
            return id;
          }; 
		
		
		
		var fromHourVal = s.taboption('wificonfigschedule', L.cbi.DynamicList, 'fromHours', {
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
		
		
		var fromMinuteVal = s.taboption('wificonfigschedule', L.cbi.DynamicList, 'fromMinutes', {
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

        
        s.taboption('wificonfigschedule',L.cbi.DummyValue, 'to', {
		  caption: L.tr(''),
        }).depends({'wificonfig':'1'})
        .depends({'wifi1enable':'1' })
        .ucivalue=function()
          {
            var id="<h5><b>&nbsp &nbsp &nbsp &nbsp &nbsp &nbsp To: </b> </h5>";
            return id;
          }; 
        
        var HourVal = s.taboption('wificonfigschedule', L.cbi.DynamicList, 'toHours', {
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
		
		
		var MinuteVal = s.taboption('wificonfigschedule', L.cbi.DynamicList, 'toMinutes', {
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
}
   	 s.tab({
            id: 'smsconfig',
            caption: L.tr('SMS Settings')
        });
        
		s.taboption('smsconfig',L.cbi.CheckboxValue, 'smsenable1', {
                       caption: L.tr('SMS Enable'),
                       optional: true,
                }).depends('smsconfig');
         
         
        s.taboption('smsconfig',L.cbi.DummyValue, 'smsnote', {                                                                                  
                  caption: L.tr(''),                                                                                                            
        }).depends({'smsenable1':'1'})                                                                                                          
        .ucivalue=function()                                                                                                                    
        {                                                                                                                                     
            var id="<h5><b>Note: Depending upon SIM & cellular service provider,SMS center number may need to be appropriately updated</b> </h5>";
            return id;
        };  
            
		s.taboption('smsconfig',L.cbi.InputValue, 'smscenternumber1', {
                        caption: L.tr('SMS center number for Sim1'),
                        datatype: 'uinteger',
                        description: L.tr('SMS center number in international format without the leading +')
                }).depends({'modemenable':'1','smsenable1':'1'});
        

        
		 s.taboption('smsconfig',L.cbi.InputValue, 'smscenternumber2', {                                                                         
		                        caption: L.tr('SMS center number for Sim2'),        
		                        datatype: 'uinteger',      
		                        description: L.tr('SMS center number in international format without the leading +')
		}).depends({'CellularOperationMode' : 'singlecellulardualsim','modemenable':'1'});
					
         s.taboption('smsconfig',L.cbi.CheckboxValue, 'enable_deviceid', {
                       caption: L.tr('Enable Serial Number'),
                }).depends({'smsenable1':'1'});	

	s.taboption('smsconfig', L.cbi.DummyValue, 'smsdeviceid', {
    			caption: L.tr('Serial Number'),
		}).depends({ 'enable_deviceid': '1', 'smsenable1': '1' });

                s.taboption('smsconfig',L.cbi.CheckboxValue, 'enable_apikey', {
                       caption: L.tr('Enable API Key'),
                }).depends({'modemenable':'1','smsenable1':'1'})
                .depends({'smsenable1':'1'});	
        
               s.taboption('smsconfig', L.cbi.InputValue, 'smsapikey', {
    			caption: L.tr('API Key'),
    		description: L.tr('API key used for SMS communication')
		}).depends({ 'enable_apikey': '1', 'smsenable1': '1' });

                s.taboption('smsconfig',L.cbi.ListValue, 'validsmsreceivernumbers', {
                        caption: L.tr('Select Valid SMS user Numbers')
                }).depends({'modemenable':'1','smsenable1':'1'})
	              .value("choose",L.tr("Please select the option"))
	              .value("0",L.tr("anyone"))
	              .value("1",L.tr("1"))
	              .value("2",L.tr("2"))
			      .value("3",L.tr("3"))
	              .value("4",L.tr("4"))
	              .value("5",L.tr("5"));       

                s.taboption('smsconfig',L.cbi.InputValue, 'smsservernumber1', {
                        caption: L.tr('Valid SMS User Number1'),
		                //optional: true,
		                description:L.tr('phone number in international format without the leading +'),
                }).depends({'validsmsreceivernumbers':'1','modemenable':'1','smsenable1':'1'})
                  .depends({'validsmsreceivernumbers':'2','modemenable':'1','smsenable1':'1'})
                  .depends({'validsmsreceivernumbers':'3','modemenable':'1','smsenable1':'1'})
                  .depends({'validsmsreceivernumbers':'4','modemenable':'1','smsenable1':'1'})
                  .depends({'validsmsreceivernumbers':'5','modemenable':'1','smsenable1':'1'}); 

	            s.taboption('smsconfig',L.cbi.InputValue, 'smsservernumber2', {                                       
                        caption: L.tr('Valid SMS User Number2'),                                                           
                        //optional: true,                                                                             
                }).depends({'validsmsreceivernumbers':'2','modemenable':'1','smsenable1':'1'})
                  .depends({'validsmsreceivernumbers':'3','modemenable':'1','smsenable1':'1'})
                  .depends({'validsmsreceivernumbers':'4','modemenable':'1','smsenable1':'1'})
                  .depends({'validsmsreceivernumbers':'5','modemenable':'1','smsenable1':'1'}); 

	            s.taboption('smsconfig',L.cbi.InputValue, 'smsservernumber3', {           
                        caption: L.tr('Valid SMS User Number3'),
                       // optional: true                                     
                }).depends({'validsmsreceivernumbers':'3','modemenable':'1','smsenable1':'1'})
                  .depends({'validsmsreceivernumbers':'4','modemenable':'1','smsenable1':'1'})
                  .depends({'validsmsreceivernumbers':'5','modemenable':'1','smsenable1':'1'}); 

                s.taboption('smsconfig',L.cbi.InputValue, 'smsservernumber4',{
                        caption: L.tr('Valid SMS User Number4'),
                        //optional: true
                }).depends({'validsmsreceivernumbers':'4','modemenable':'1','smsenable1':'1'})
                  .depends({'validsmsreceivernumbers':'5','modemenable':'1','smsenable1':'1'});       

                s.taboption('smsconfig',L.cbi.InputValue, 'smsservernumber5',{   
                        caption: L.tr('Valid SMS User Number5'),    
                        //optional: true                                       
                }).depends({'validsmsreceivernumbers':'5','modemenable':'1','smsenable1':'1'});
                
                 s.taboption('smsconfig',L.cbi.CheckboxValue, 'smsresponseserverenable', {
                       caption: L.tr('SMS Response Enable'),
                      // optional: true
                }).depends({'smsenable1':'1'});

        s.tab({
            id: 'loopbackipconfig',
            caption: L.tr('Loopback IP Settings')
        });
        
           s.taboption('loopbackipconfig',L.cbi.InputValue, 'loopbackip', {
           caption: L.tr('Loopback IP'), 
           datatype: 'ip4addr',
           placeholder:'8.8.8.8',
           optional: true
        }).depends({'loopbackipconfig':'1'}); 
        
        s.taboption('loopbackipconfig',L.cbi.InputValue, 'loopbacknetmask', {
           caption: L.tr('Loopback NetMask'),
           placeholder:'8.8.8.8', 
           datatype: 'ip4addr',
           optional: true
        }).depends({'loopbackipconfig':'1'});
        
         
         
        		
        s.commit=function(){
 
        }
		                        
        return m.insertInto('#map');
    }
});
