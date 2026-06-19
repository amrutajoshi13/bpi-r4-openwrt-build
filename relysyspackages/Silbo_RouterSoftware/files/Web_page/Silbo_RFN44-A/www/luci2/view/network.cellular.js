L.ui.view.extend({
 
        // fGetUCISections: L.rpc.declare({
	// 	object: 'uci',
	// 	method: 'get',
	// 	params: [ 'config', 'type' ],
	// 	expect: { values: {} }
	// }),
	
	GetUCISections: L.rpc.declare({
                object: 'uci',
                method: 'get',
                params: ['config', 'type'],
                expect: { values: {} }
        }),

        GetUCISectionsa: L.rpc.declare({
                object: 'uci',
                method: 'get',
                params: ['config', 'type'],
                expect: { values: {} }
        }),

        RunUdev: L.rpc.declare({
                object: 'command',
                method: 'exec',
                params: ['command', 'args'],
        }),
	
	// fCreateUCISection:  L.rpc.declare({
	// 	object: 'uci',
	// 	method: 'add',
	// 	params: [ 'config', 'type', 'name', 'values' ]
	// }),
	
	// drfCreateUCISection:  L.rpc.declare({
	// 	object: 'uci',
	// 	method: 'add',
	// 	params: [ 'config', 'type', 'values' ]
	// }),
	
	// fDeleteUCISection:  L.rpc.declare({
	// 	object: 'uci',
	// 	method: 'delete',
	// 	params: [ 'config','type','section' ]
	// }),
	
	// fCommitUCISection:  L.rpc.declare({
	// 	object: 'uci',
	// 	method: 'commit',
	// 	params: [ 'config' ]
	// }),
    
        // deletefirewallconfig: L.rpc.declare({
        //         object: 'rpc-updatewanconfig',
        //         method: 'delete',
        //         params: ['pbSectionID'],
        //         expect: { output: '' }
        // }),
    
        updateinterfaceconfig: L.rpc.declare({
                object: 'rpc-updatecellularconfig',
                method: 'configure',
                params: ['application','action'],
                expect: { output: '' }
        }),

        updatesimswitchconfig: L.rpc.declare({
                object: 'rpc-simswitchconfig',
                method: 'configure',
                params: ['application','action'],
                expect: { output: '' }
        }),

        execute:function() {
                var self = this;
                L.ui.createNote(
                        'NOTE',
                        `1. After editing or deleting, please click the Update button to apply the saved configuration.
                         2. Depending on your SIM card and cellular service provider, you may need to update the SMS center number to ensure proper message delivery.`,
                        { type: 'warn', variant: 'inline', appendTo: '#Update-Note-Celluar' }
                );
                
		$('#btn_update_cellular').click(function () {
                        L.ui.loading(true);
                        self.updateinterfaceconfig('Update', 'updateinterface').then(function (rv) {
                                L.ui.loading(false);
                                L.ui.showAlert("success", "Update Complete", "Cellular configurations have been successfully updated.");
                                setTimeout(function () {
                                location.reload();
                                }, 1500);
                        });
                });

                $('#btn_updatesim').click(function () {
                        L.ui.loading(true);
                        self.updatesimswitchconfig('Update', 'updateinterface').then(function (rv) {
                                L.ui.loading(false);
                                L.ui.showAlert("success", "Update Complete", "SIM configurations have been successfully updated.");
                                setTimeout(function () {
                                location.reload();
                                }, 1500);
                        });
                });
                 		
	        //  ************************ Cellullar Settings****************************************************************** 
                var m = new L.cbi.Map('sysconfig', {       
                });
         
                var s = m.section(L.cbi.NamedSection, 'sysconfig', {
                        caption:L.tr('Cellullar Settings'),
                });
    
                s.option(L.cbi.CheckboxValue, 'enablecellular', {
                        caption: L.tr('Cellular Enable'),
                        optional: true
                }).depends({'cellularconfig' : '1'});
              
                s.option(L.cbi.ListValue, 'CellularOperationMode', {
                        caption: L.tr('Cellular Operation Mode'),
                }).depends({'cellularconfig':'1','enablecellular':'1'})
                  //.value("none",L.tr("Choose Option"))
                  .value("singlecellulardualsim",L.tr("Single Cellular With Dual SIM"))
                  .value("singlecellularsinglesim",L.tr("Single Cellular With Single SIM"));
                //============================General settings ==============================================
                        s.option(L.cbi.DummyValue, 'cellularmodem1', {
                                caption: L.tr('Cellular Modem 1'),
                        }).depends({'cellularconfig':'1'})
                        .depends({'CellularOperationMode' : 'dualcellularsinglesim','enablecellular':'1'})
                        .depends({'CellularOperationMode' : 'singlecellularsinglesim','enablecellular':'1'})
                        .depends({'CellularOperationMode' : 'singlecellulardualsim','enablecellular':'1'});

                         s.option(L.cbi.SubHeadingValue, 'sim1', { caption: '' })
                                .depends({ 'CellularOperationMode': 'singlecellularsinglesim', 'enablecellular': '1' })
                                .depends({ 'CellularOperationMode': 'singlecellulardualsim', 'enablecellular': '1' })
                                .ucivalue = function () {
                                        return 'SIM 1 Settings';
                                };
                        
                        s.option(L.cbi.ListValue, 'protocol1', {
                                caption: L.tr('Protocol'),
                        }).depends({'cellularconfig':'1'})
                          .depends({'CellularOperationMode' : 'dualcellularsinglesim','enablecellular':'1','cellularmodem1':'QuectelEC200T'})
                          .depends({'CellularOperationMode' : 'singlecellularsinglesim','enablecellular':'1','cellularmodem1':'QuectelEC200T'})
                          .depends({'CellularOperationMode' : 'singlecellulardualsim','enablecellular':'1','cellularmodem1':'QuectelEC200T'})
                          .value("none",L.tr("Choose Option"))
                          .value("cdcether",L.tr("CDC-ETHER"))
                          .value("ppp",L.tr("PPP"));
				
                        s.option(L.cbi.DummyValue, 'cellularmodem2', {
                                caption: L.tr('Cellular Modem 2'),
                        }).depends({'cellularconfig':'1'})
                          .depends({'CellularOperationMode' : 'dualcellularsinglesim','enablecellular':'1'})

                        s.option(L.cbi.ListValue, 'protocol2', {
                                caption: L.tr('Protocol 2'),
                        }).depends({'cellularconfig':'1'})
                          .depends({'CellularOperationMode' : 'dualcellularsinglesim','enablecellular':'1'})
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
                          .depends({'CellularOperationMode' : 'dualcellularsinglesim','modemenable':'1','enablecellular':'1'});
                
                        s.option(L.cbi.CheckboxValue, 'querymodematanalytics2', {
                                caption: L.tr('Modem Analytics 2'),
                                optional: true
                        }).depends({'cellularconfig':'1'})
                          .depends({'CellularOperationMode' : 'dualcellularsinglesim','modemenable':'1','enablecellular':'1'})
                        
                        s.option(L.cbi.CheckboxValue, 'datatestenable2', {
                                caption: L.tr('Data Test 2'),
                                caption: L.tr('Data Test 2'),
                                optional: true
                        }).depends({'cellularconfig':'1'})
                          .depends({'CellularOperationMode' : 'dualcellularsinglesim','modemenable':'1','enablecellular':'1'})
                        
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
                        }).depends({'cellularconfig':'1'})
                          .depends({'CellularOperationMode' : 'dualcellularsinglesim','modemenable':'1','enablecellular':'1'})
                          .depends({'CellularOperationMode' : 'singlecellularsinglesim','enablecellular':'1'})
                          .depends({'CellularOperationMode' : 'singlecellulardualsim','enablecellular':'1'});  

                        s.option(L.cbi.ListValue, 'Sim1type', {
                                caption: L.tr('Choose SIM1 Type')
			}).depends({'cellularconfig':'1'})
                          .depends({'CellularOperationMode' : 'singlecellulardualsim','modemenable':'1','dataenable' : '1','enablecellular':'1'})
			  .value('m2mesim', L.tr('M2M Esim'))                        
                          .value('normalsim', L.tr('Normal Sim'));
                
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
                          .value('IPV4', L.tr('IPv4'))                        
                          .value('IPV6', L.tr('IPv6'))                        
                          .value('IPV4V6', L.tr('IPv4v6')); 
                        
                        s.option(L.cbi.CheckboxValue, 'Enable464xlatSim1', {
                                caption: L.tr('Enable CLAT support for SIM1')
                        }).depends({'cellularconfig':'1'})
                          .depends({'CellularOperationMode' : 'dualcellularsinglesim','modemenable':'1','dataenable' : '1','enablecellular':'1','pdp':'IPV6'})
                          .depends({'CellularOperationMode' : 'singlecellularsinglesim','modemenable':'1','dataenable' : '1','enablecellular':'1','pdp':'IPV6'})
                          .depends({'CellularOperationMode' : 'singlecellulardualsim','modemenable':'1','dataenable' : '1','enablecellular':'1','pdp':'IPV6'});
        
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
                        
                        s.option(L.cbi.SubHeadingValue, 'sim2', { caption: '' })
                                .depends({ 'CellularOperationMode': 'singlecellulardualsim', 'enablecellular': '1', 'dataenable2': '1' })
                                .ucivalue = function () {
                                        return 'SIM 2 Settings';
                                };

			s.option(L.cbi.CheckboxValue, 'dataenable2', {
                                caption: L.tr('Data Service2'),
                                optional: true
                        }) .depends({'cellularconfig':'1'})
                           .depends({'CellularOperationMode' : 'dualcellularsinglesim','modemenable':'1','enablecellular':'1'});

                        s.option(L.cbi.ListValue, 'Sim2type', {
                                caption: L.tr('Choose SIM2 Type')
			}).depends({'cellularconfig':'1'})
                          .depends({'CellularOperationMode' : 'singlecellulardualsim','modemenable':'1','dataenable' : '1','enablecellular':'1'})
			  .value('m2mesim', L.tr('M2M Esim'))                        
                          .value('normalsim', L.tr('Normal Sim')); 
                 
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
                        }).depends({'cellularconfig' : '1'})
                          .depends({'CellularOperationMode' : 'singlecellulardualsim','modemenable':'1','dataenable':'1','enablecellular':'1','Sim2apntype':'manual'})
                          .depends({'CellularOperationMode' : 'dualcellularsinglesim','modemenable':'1','dataenable':'1','enablecellular':'1','Sim2apntype':'manual'});
                                
                        s.option(L.cbi.ListValue, 'sim2pdp', {
                                caption: L.tr('SIM 2 PDP Type')
                        }).depends({'cellularconfig' : '1'})
                          .depends({'CellularOperationMode' : 'singlecellulardualsim','modemenable':'1','dataenable':'1','enablecellular':'1'})
                          .depends({'CellularOperationMode' : 'dualcellularsinglesim','modemenable':'1','dataenable':'1','enablecellular':'1'})
                          .value('IPV4', L.tr('IPv4'))                        
                          .value('IPV6', L.tr('IPv6'))                        
                          .value('IPV4V6', L.tr('IPv4v6')); 
                                
                        s.option(L.cbi.CheckboxValue, 'Enable464xlatSim2', {
                                caption: L.tr('Enable CLAT support for SIM2')
                        }).depends({'cellularconfig':'1'})
                          .depends({'CellularOperationMode' : 'dualcellularsinglesim','modemenable':'1','dataenable' : '1','enablecellular':'1','sim2pdp':'IPV6'})
                          .depends({'CellularOperationMode' : 'singlecellulardualsim','modemenable':'1','dataenable' : '1','enablecellular':'1','sim2pdp':'IPV6'});
                        
                        s.option(L.cbi.InputValue, 'sim2username', {
                                caption: L.tr('SIM 2 Username'),
                                optional: true 
                        }).depends({'cellularconfig' : '1'})
                          .depends({'CellularOperationMode' : 'singlecellulardualsim','modemenable':'1','dataenable':'1','enablecellular':'1'})
                          .depends({'CellularOperationMode' : 'dualcellularsinglesim','modemenable':'1','dataenable':'1','enablecellular':'1'});
                                        
                        s.option(L.cbi.PasswordValue,'sim2password',{
                                caption: L.tr('SIM 2 Password'),
                                optional: true 
                        }).depends({'cellularconfig' : '1'})
                          .depends({'CellularOperationMode' : 'singlecellulardualsim','modemenable':'1','dataenable':'1','enablecellular':'1'})
                          .depends({'CellularOperationMode' : 'dualcellularsinglesim','modemenable':'1','dataenable':'1','enablecellular':'1'});
                        
                        s.option(L.cbi.ListValue, 'sim2auth', {
                                caption: L.tr('SIM 2 Authentication Protocol'),
                        }).depends({'cellularconfig' : '1'})
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
                        }).depends({'cellularconfig':'1'})
                          .depends({'CellularOperationMode' : 'singlecellulardualsim','modemenable':'1','dataenable':'1','enablecellular':'1'});   
                        
                        s.option(L.cbi.InputValue, 'primarysimswitchbacktime', {
                                caption: L.tr('Primary SIM Switchback Time (In Minutes)'),
                                optional: true 
                        }).depends({'cellularconfig' : '1'})
                          .depends({'CellularOperationMode' : 'singlecellulardualsim','modemenable':'1','dataenable':'1','primarysimswitchbackenable': '1','enablecellular':'1'}); 
                
                        m.insertInto('#section_cellular');
                //=================================GPS settings ========================================
                        var m = new L.cbi.Map('sysconfig', {
                        });     
                        var s = m.section(L.cbi.NamedSection, 'bandlock', {
                                caption:L.tr('Band & Operator Lock Settings')
                        });
    
		        s.option(L.cbi.ListValue, 'bandselectenable', {         
                                caption: L.tr('Band Lock Selection'), 
                                optional: true                   
                        }).depends({'CellularOperationMode' : 'dualcellularsinglesim','modemenable':'1','dataenable' : '1','enablecellular':'1','band':'1'})
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
                //=================================Band and Operator Lock ==============================================================================         
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
                //=================================SMS Setting==============================================================================         
                        var m5 = new L.cbi.Map('sysconfig', {
                        });     
                
                        var s5 = m5.section(L.cbi.NamedSection, 'smsconfig', {
                                caption:L.tr('SMS Settings')
                        });
    
                        s5.option(L.cbi.CheckboxValue, 'smsenable1', {
                                caption: L.tr('SMS Enable'),
                                optional: true
                        }).depends('smsconfig');
                 				
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

                         // ---------- SIM2 ORDER FIXED HERE ----------

                        self.GetUCISections("sysconfig", "sysconfig").then(function (rv) {
                                for (var key in rv) {
                                        if (!rv.hasOwnProperty(key)) continue;

                                        var obj = rv[key];

                                        if (obj.CellularOperationMode === 'singlecellulardualsim') {

                                        // FIRST  Checkbox
                                        s5.option(L.cbi.CheckboxValue, 'enable_smscenternosim2', {
                                                caption: L.tr('Enable SMS Center Number for Sim2'),
                                        }).depends({
                                                'smsenable1': '1',
                                                'CellularOperationMode': 'singlecellulardualsim'
                                        });

                                        // SECOND  SMSC input (shows only when checkbox=1)
                                        s5.option(L.cbi.InputValue, 'smscenternumber2', {
                                                caption: L.tr('SMS center number for Sim2'),
                                                description: L.tr('SMS center number in international format without +')
                                        }).depends({
                                                'modemenable': '1',
                                                'smsenable1': '1',
                                                'enable_smscenternosim2': '1',        // <— MUST BE 1
                                                'CellularOperationMode': 'singlecellulardualsim'
                                        });

                                        }
                                }
                        });


                        m5.insertInto('#section_sms');
                
                //  ************************SIM Switch Settings******************************************************************    
                        var m6 = new L.cbi.Map('simswitchconfig', {
                        });

                        var s6 = m6.section(L.cbi.NamedSection, 'simswitchconfig', {
                                caption: L.tr('SIM Switch Settings')
                        });

                        s6.tab({
                                id: 'cellularconfig',
                                caption: L.tr('Cellular Settings')
                        });

                        s6.taboption('cellularconfig', L.cbi.ListValue, 'simswitch', {
                                caption: L.tr('SIM Switch Based on'),
                        }).depends({ 'cellularconfig': '1' })
                                .value('none', L.tr('None'))
                                .value('signalstren', L.tr('Signal Strength'))
                                .value('datalim', L.tr('Data Limit'));


                        s6.taboption('cellularconfig',L.cbi.InputValue, 'threshrsrp', {
                                caption: L.tr('Threshold RSRP'),
                                description: L.tr('This Needs to be set appropriately. Incorrect setting may cause unnecessary SIM switching.( In General a BAD RSRP value range is -140 to -115 and FAIR RSRP value range is -115 to -105)'),
                                optional: true
                        }).depends({'cellularconfig' : '1'})
                          .depends({'simswitch' : 'signalstren' }); 

                        s6.taboption('cellularconfig',L.cbi.InputValue, 'threshsinr', {
                                caption: L.tr('Threshold SINR'),
                                description: L.tr('This Needs to be set appropriately. Incorrect setting may cause unnecessary SIM switching.( In General a BAD SNR value range is -20 to 0 and FAIR SNR value range is 0 to 13)'),
                                optional: true
                        }).depends({'cellularconfig' : '1'})
                          .depends({'simswitch' : 'signalstren' });

                        s6.taboption('cellularconfig',L.cbi.InputValue, 'sim1datausagelimit', {
                                caption: L.tr('SIM 1 Data Usage Limit (In MB)'),
                                optional: true 
                        }).depends({'cellularconfig' : '1'})
                          .depends({'simswitch' : 'datalim' })
			  .depends({'CellularOperationMode' : 'singlecellulardualsim','modemenable':'1','dataenable':'1','enablecellular':'1','cellulardataswitchlimitenable':'1'});

                        s6.taboption('cellularconfig',L.cbi.ListValue, 'cellulardatausagemanagerperiodicity', {
                               caption: L.tr('Periodicity'),
                        }).depends({'cellularconfig' : '1','CellularOperationMode' : 'singlecellulardualsim','CellularOperationMode' : 'dualcellularsinglesim','modemenable':'1','dataenable':'1'})
                          .depends({'cellularconfig' : '1'})
                          .depends({'simswitch' : 'datalim' })
                          .depends({'CellularOperationMode' : 'singlecellulardualsim','modemenable':'1','dataenable':'1','enablecellular':'1','cellulardataswitchlimitenable':'1'})
                          .value('monthly', L.tr('Monthly'))
                          .value('daily', L.tr('Daily')); 

                        var DaysVal = s6.taboption('cellularconfig', L.cbi.ListValue, 'dayofmonth', {
                                caption: L.tr('Day Of Month'),
                                optional: true,
                                listlimit: 31,
                                listcustom:false
                        }).depends({'simswitch' : 'datalim','cellulardatausagemanagerperiodicity':'monthly'})
                        .value('',L.tr('-- Please choose --'))
                                DaysVal.load = function(sid) {
                                var days = [ ];
                                for (var i = 1; i <= 31; i++)
                                        days.push(i);
                                days.sort();
                                for (var i = 1; i <= days.length; i++)
                                        DaysVal.value(i);
                                };
                        
                        s6.commit=function(){
                        }
                        return m6.insertInto('#section_sim');
    }
});
