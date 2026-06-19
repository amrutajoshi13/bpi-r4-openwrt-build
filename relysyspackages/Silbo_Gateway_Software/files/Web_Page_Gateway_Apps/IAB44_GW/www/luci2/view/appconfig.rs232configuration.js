L.ui.view.extend({
        title: L.tr('RS232 Configuration'),
        description: L.tr(''),
        
        RS485GetUCISections: L.rpc.declare({
                object: 'uci',
                method: 'get',
                params: [ 'config', 'type'],
                expect: { values: {} }
        }),
        
        RS485CreateUCISection:  L.rpc.declare({
                object: 'uci',
                method: 'add',
                params: [ 'config', 'type', 'name', 'values' ]
        }),
        
        RS485CommitUCISection:  L.rpc.declare({
                object: 'uci',
                method: 'commit',
                params: [ 'config' ]
        }),
        
        RS485DeleteUCISection:  L.rpc.declare({
		object: 'uci',
		method: 'delete',
		params: [ 'config','type','section' ]
	}),
			
        RS485FormCallback: function() 
        {
                var map = this;
                var RS485ConfigSectionName = map.options.RS485ConfigSection;
                var numericExpression = /^[0-9]+$/;
                
                map.options.caption = L.tr(RS485ConfigSectionName+' Configuration');
                
                var s = map.section(L.cbi.NamedSection, RS485ConfigSectionName, {
                        collabsible: true
                });
               
               s.option(L.cbi.InputValue,'MeterID' ,{                           
                       caption: L.tr('Meter ID')                                
               }); 
               
               s.option(L.cbi.InputValue,'Model' ,{                           
                       caption: L.tr('Meter Model')                                
               });  
               
                s.option(L.cbi.InputValue,'SlaveAddress',{
                        caption: L.tr('Slave Address'),   
                });               

                s.option(L.cbi.InputValue,'StartRegister',{
                        caption: L.tr('Start Register'),   
                });   

                s.option(L.cbi.InputValue,'NoOfRegister',{ 
                        caption: L.tr('No of Register'),  
                        datatype: function divalid(num) { 
                        var CDINo = parseInt(num);
                            if(CDINo==0|| (! num.match(numericExpression)))
                            return L.tr(' Input number must be a natural number');
                            return false;   
                        }    
                });  
               
                s.option(L.cbi.ListValue,'Baudrate',{ 
                        caption: L.tr('Baud rate'),   
                }).value("110",L.tr("110"))                                  
                  .value("300",L.tr("300"))                                  
                  .value("600",L.tr("600"))                                  
                  .value("1200",L.tr("1200"))                                
                  .value("2400",L.tr("2400"))                                
                  .value("4800",L.tr("4800"))                                
                  .value("9600",L.tr("9600"))                                
                  .value("14400",L.tr("14400"))                              
                  .value("19200",L.tr("19200"))                              
                  .value("38400",L.tr("38400"))                              
                  .value("57600",L.tr("57600"))                              
                  .value("115200",L.tr("115200"))              
                  .value("128000",L.tr("128000"))              
                  .value("256000",L.tr("256000"));        
 
                s.option(L.cbi.ListValue,'NoOfStopbits',{                                
                        caption: L.tr('No of Stopbits'),                                  
                }).value("1",L.tr("1"))
                  .value("2",L.tr("2"));     
                
                s.option(L.cbi.ListValue,'Databits',{                               
                        caption: L.tr('No of Databits'),                            
                }).value("7",L.tr("7"))                                             
                  .value("8",L.tr("8"));           

                s.option(L.cbi.ListValue,'FunctionalCode',{                         
                        caption: L.tr('Function Code'),                         
                }).value("3",L.tr("3"))                                    
                  .value("4",L.tr("4"));

                s.option(L.cbi.ListValue,'ModbusProtocol' ,{
	               caption: L.tr('Modbus Protocol')
	            }).value("RTU",L.tr("RTU"));
                
                s.option(L.cbi.ListValue,'Parity',{                
                        caption: L.tr('Parity'),                  
                }).value("0",L.tr("0"))                                    
                  .value("1",L.tr("1"))
                  .value("2",L.tr("2"));      
        
               //s.option(L.cbi.ListValue,'USBFilename' ,{                
                       //caption: L.tr('USB Filename')                    
               //}).value("/dev/ttyUSB3",L.tr("/dev/ttyUSB3"));
                 //.value("/dev/ttyUSB4",L.tr("/dev/ttyUSB4")); 
                 //.value("/dev/ttyS2",L.tr("/dev/ttyS2"));      

               s.option(L.cbi.DummyValue,'InterfaceID' ,{                            
                       caption: L.tr('Port Number')                                
               });
               
               s.option(L.cbi.ListValue,'FlowControl',{                
                        caption: L.tr('FlowControl'),                  
                }).value("0",L.tr("0 - No"))                                    
                  .value("1",L.tr("1 - Hardware"))
                  .value("2",L.tr("2 - Software"));
               
               s.option(L.cbi.InputValue,'Delay',{
                        caption: L.tr('Delay (In Milliseconds)'),   
                }); 

                
           },
		
        RS485ConfigCreateForm: function(mapwidget,RS485ConfigSectionName) 
        {
                var self = this;
                
                if (!mapwidget)
                        mapwidget = L.cbi.Map;
                
                var map = new mapwidget('RS232DeviceConfigGeneric', {
                        prepare: self.RS485FormCallback,
                        RS485ConfigSection: RS485ConfigSectionName
                });
                return map;
        },
        
        RS485RenderContents: function(rv) 
        {
                var self = this;

                var list = new L.ui.table({
                        columns: [{
                                caption: L.tr('Sl No'),
                                align: 'left',
                                format: function(v, n) {
                                        var div = $('<p />').attr('id', 'RS485DeviceSerialNo_%s'.format(n));
                                        var serialNo=n+1;
					return div.append('<strong>'+serialNo+'<strong>');
                                }
                             },  
                             
                                                             
					                                               
                            {
                                caption: L.tr('Name'),
                                        width:'30%',
                                align: 'left',
                                format: function(v,n) {
                                        var div = $('<p />').attr('id', 'RS485DeviceEventName_%s'.format(n));
                                        return div.append('<strong>'+v+'</strong>');
                                }
                        },
                        
                        
								
                        { 
									caption: L.tr('Port Number'),
									format:  function(v,n) {
										var div = $('<b />').attr('id', 'InterfaceID_%s'.format(n));
										return div.append('<strong>'+v+'</strong>');
									}
								}, 
								
								 { 
									caption: L.tr('MeterID'),
									format:  function(v,n) {
										var div = $('<b />').attr('id', 'MeterID_%s'.format(n));
										return div.append('<strong>'+v+'</strong>');
									}
								},
								
								{ 
									caption: L.tr('Config'),
									format:  function(v,n) {
										var div = $('<b />').attr('id', 'Config_%s'.format(n));
										return div.append('<strong>'+v+'</strong>');
									}
								},  
                         
                        {
                                caption: L.tr('Update'),
                                align: 'left',
                                format: function(v, n) {
                                        return $('<div />')
                                                .addClass('btn-group btn-group-sm')
                                                .append(L.ui.button(L.tr('Edit'),'primary', L.tr('Configure'))
                                                .click({ self: self, RS485ConfigSectionName: v }, self.RS485ConfigSectionEdit))
                                                .append(L.ui.button(L.tr('Delete'), 'danger', L.tr('Delete Event'))
                                                .click({ self: self, RS485ConfigSectionName: v }, self.RS485ConfigSectionRemove));
                                }
                        }]
                });
                
                for (var key in rv) 
                {
                        if (rv.hasOwnProperty(key)) 
                        {
                                var obj = rv[key];
                                var InterfaceID=obj.InterfaceID;
                                //alert(InterfaceID);
                                var MeterID=obj.MeterID;
                                var SlaveID=obj.SlaveAddress;
                                var Baudrate=obj.Baudrate;
                                var FunctionCode=obj.FunctionalCode;
                                var Parity=obj.Parity;
                                var Databits=obj.Databits;
                                var Stopbits=obj.NoOfStopbits;
                                
                                let Config = `Sl:${SlaveID} B:${Baudrate} F:${FunctionCode} P:${Parity} D:${Databits} St:${Stopbits}`;
                                                               
                                //alert(MeterID);
                              //  list.row([obj.name,InterfaceID,MeterID,key]); 
                               list.row([key,key,InterfaceID,MeterID,Config,key]);
                             //   list.row([key,key,InterfaceID,Config,key]); 
                        }
                }
                        
                $('#map').
                        append(list.render());		
        },
		
        RS485ConfigSectionAdd: function () 
        {
                var self = this;
                var RS485ConfigSectionName = $('#field_NewEvent_name').val();
                var RS485ConfigSectionInterfaceID = $('#field_NewEvent_InterfaceID').val();
              //  var RS485ConfigSectionMeterID = $('#field_NewEvent_MeterID').val();
                var sensorSectionOptions = {EEnable:0,InterfaceID:RS485ConfigSectionInterfaceID};
               
                this.RS485GetUCISections("RS232DeviceConfigGeneric","RS232Config").then(function(rv) {
                        var keys = Object.keys(rv);
                        var keysLength=keys.length;
                        if(keysLength>=10)
                        {
                                alert("Only 10 meters can be configured");
                        }
                        else
                        {
                                self.RS485CreateUCISection("RS232DeviceConfigGeneric","RS232Config",RS485ConfigSectionName,sensorSectionOptions).then(function(rv){
                                        if(rv)
                                        {
                                                if (rv.section)
                                                {
                                                        self.RS485CommitUCISection("RS232DeviceConfigGeneric").then(function(res){
                                                              	
								if (res != 0) 
                                                                {
									alert("Error:New Event Configuration");
                                                                }
                                                                else 
                                                                {
                                                                        location.reload();
                                                                }
                                                        });
                                                };
                                        };
                                }); 
                        }
                });
        },
        
        RS485ConfigSectionRemove: function(ev) 
        {
		var self = ev.data.self;
		var RS485ConfigSectionName = ev.data.RS485ConfigSectionName;
		self.RS485DeleteUCISection("RS232DeviceConfigGeneric","RS232Config",RS485ConfigSectionName).then(function(rv){
			if(rv == 0){
				self.RS485CommitUCISection("RS232DeviceConfigGeneric").then(function(res){
					if (res != 0)
                                        {
						alert("Error: Delete Sensor Configuration");
					}
					else 
                                        {
						location.reload();
					}
				});
			};
		});
	},
        
        RS485ConfigSectionEdit: function(ev) 
        {
                var self = ev.data.self;
                var RS485ConfigSectionName = ev.data.RS485ConfigSectionName;
                return self.RS485ConfigCreateForm(L.cbi.Modal,RS485ConfigSectionName).show();
        },
        
        execute:function()
        {
                var self = this;
                $('#AddNewEvent').click(function() {  
                        self.RS485ConfigSectionAdd();
                });
                self.RS485GetUCISections("RS232DeviceConfigGeneric","RS232Config").then(function(rv) {
                        self.RS485RenderContents(rv);
                });
        }
});
