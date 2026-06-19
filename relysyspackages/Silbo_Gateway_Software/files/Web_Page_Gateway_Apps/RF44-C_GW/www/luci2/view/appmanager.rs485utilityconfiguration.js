L.ui.view.extend({
	
    RunUdev:L.rpc.declare({
        object:'command',
        method:'exec',
        params : ['command','args'],
    }),
    
    fGetUCISections: L.rpc.declare({
        object: 'uci',
        method: 'get',
        params: [ 'config', 'type', 'section']  
    }),
    
    updateinterfaceconfig: L.rpc.declare({
        object: 'rpc-rs485utilityupdate',
        method: 'configure',
        params: ['application','action'],
        expect: { output: '' }
    }),
    		
        title: L.tr('Modbus Utility Configuration'),

        execute: function() {
                 var self = this;
                var m = new L.cbi.Map('RS485UtilityConfigGeneric', {
                        caption: L.tr('')
                });

                var s = m.section(L.cbi.NamedSection, 'rs485utilityconfig', {
                       caption: L.tr('Modbus  Utility Configuration Settings')
                });
                 
                   
                 s.option(L.cbi.ListValue,'Mode' ,{
	               caption: L.tr('Mode'),
	            }).value("1",L.tr("Read"))
	              .value("2",L.tr("Write"))
	              .depends({'ModbusProtocol':'RTU'});  
	              
                 
                 
                s.option(L.cbi.InputValue,'StartRegister',{
                        caption: L.tr('Start Register'),   
                });   

                s.option(L.cbi.InputValue,'NumberOfRegisters',{ 
                        caption: L.tr('No of Register'),   
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
                                                         
                s.option(L.cbi.ListValue,'Stopbits',{                                
                        caption: L.tr('No of Stopbits'),                                  
                }).value("1",L.tr("1"))
                  .value("2",L.tr("2"));     
                
                s.option(L.cbi.ListValue,'Databits',{                               
                        caption: L.tr('No of Databits'),                            
                }).value("7",L.tr("7"))                                             
                  .value("8",L.tr("8"));   
                  
                         
                     
                         
                          

                s.option(L.cbi.ListValue,'FunctionalCode',{                         
                        caption: L.tr('Read Function code'),                         
                }).value("1",L.tr("1"))                                    
                  .value("2",L.tr("2"))
                  .value("3",L.tr("3"))
                  .value("4",L.tr("4"))
                 .depends({'ModbusProtocol':'RTU','Mode':'1'});
                  
                  
                  
                  
                  s.option(L.cbi.ListValue,'FunctionalCode1',{                         
                        caption: L.tr('Write Function code'),                         
                }).value("5",L.tr("5"))                                    
                  .value("6",L.tr("6"))
                   .value("15",L.tr("15"))
                    .value("16",L.tr("16"))
                  .depends({'ModbusProtocol':'RTU','Mode':'2'});

                  s.option(L.cbi.InputValue,'DataForMode2',{
                       caption: L.tr('Data To Write'),                       
                }) .depends({'ModbusProtocol':'RTU','Mode':'2'});  
                   
             
                s.option(L.cbi.ListValue,'ModbusProtocol' ,{
	               caption: L.tr('Modbus Protocol'),
	            }).value("RTU",L.tr("RTU"))
	              .value("TCP",L.tr("TCP"));
	              
	             s.option(L.cbi.InputValue,'modbusCommip',{
					caption: L.tr('Modbus Communication IP'),                       
                }).depends({'ModbusProtocol':'TCP'});
                
                 s.option(L.cbi.InputValue,'modbusCommport',{
                       caption: L.tr('Modbus Communication Port'),                       
                }).depends({'ModbusProtocol':'TCP'});
                
                 s.option(L.cbi.InputValue,'modbusCommtimeout',{
                       caption: L.tr('Modbus Communication Timeout'),                       
                }).depends({'ModbusProtocol':'TCP'});      
                   
                                                                      
                
                s.option(L.cbi.ListValue,'Parity',{                
                        caption: L.tr('Parity'),                  
                }).value("0",L.tr("0-None"))                                    
                  .value("1",L.tr("1-Odd"))
                  .value("2",L.tr("2-Even"));      
        
               s.option(L.cbi.ListValue,'SerialPort' ,{                
                       caption: L.tr('Serial Port')                    
               }).value("/dev/ttyS1",L.tr("RS485 Port-1"))
                 .value("/dev/ttyS2",L.tr("RS485 Port-2"));   
                    
                s.commit=function(){      
                        self.fGetUCISections('RS485UtilityConfigGeneric','rs485utilityconfig').then(function(rv) {  
                        self.updateinterfaceconfig('Update','updateinterface').then(function(rv) {
                });
            });
                
			} 
            
            return   m.insertInto('#map');                   
                                      
         }                           
})                             

