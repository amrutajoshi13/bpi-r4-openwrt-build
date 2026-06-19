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
        object: 'rpc-rs232utilityupdate',
        method: 'configure',
        params: ['application','action'],
        expect: { output: '' }
    }),
    		
        title: L.tr('RS232 Utility Configuration'),

        execute: function() {
                 var self = this;
                var m = new L.cbi.Map('RS232UtilityConfigGeneric', {
                        caption: L.tr('')
                });

                var s = m.section(L.cbi.NamedSection, 'rs232utilityconfig', {
                       caption: L.tr('RS232  Utility Configuration Settings')
                });
                 
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
                        caption: L.tr('Function Code'),                         
                }).value("3",L.tr("3"))                                    
                  .value("4",L.tr("4"));

                //s.option(L.cbi.ListValue,'ModbusProtocol' ,{
	               //caption: L.tr('Modbus Protocol')
	            //}).value("RTU",L.tr("RTU"));
                
                s.option(L.cbi.ListValue,'Parity',{                
                        caption: L.tr('Parity'),                  
                }).value("0",L.tr("0"))                                    
                  .value("1",L.tr("1"))
                  .value("2",L.tr("2"));
                  
               s.option(L.cbi.ListValue,'flow_control',{                
                        caption: L.tr('Flow Control'),                  
                }).value("0",L.tr("0 - No"))                                    
                  .value("1",L.tr("1 - Hardware"))
                  .value("2",L.tr("2 - Software"));
               
                s.option(L.cbi.InputValue,'delay',{ 
                        caption: L.tr('Delay(In milliseconds)'),   
                });          
        
               //s.option(L.cbi.ListValue,'SerialPort' ,{                
                       //caption: L.tr('USB Filename')                    
               //}).value("/dev/ttyUSB3",L.tr("/dev/ttyUSB3"));   
                    
                s.commit=function(){      
                        self.fGetUCISections('RS232UtilityConfigGeneric','rs232utilityconfig').then(function(rv) {  
                        self.updateinterfaceconfig('Update','updateinterface').then(function(rv) {
                });
            });
                
			} 
            
            return   m.insertInto('#map');                   
                                      
         }                           
})                             

