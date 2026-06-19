L.ui.view.extend({
        title: L.tr('Source Configuration'),

        execute: function() {
                var m = new L.cbi.Map('sourceconfig', {
                        caption: L.tr('')
                });

                var s = m.section(L.cbi.NamedSection, 'sourceconfig', {
                       caption: L.tr('Source Settings')
                });
                
                 s.option( L.cbi.CheckboxValue, 'EMeterRS485Line1DataSourceEnable', {
                 caption: L.tr('Enable RS485Line1')
               });
        
                
                s.option(L.cbi.InputValue,'EMeterRS485Line1DataSourcePerPublishInterval',{
                       caption: L.tr('Overall Periodicity Of RS485 Line 1 Readings (In Seconds >=30)'),
                       datatype: 'uinteger',
                }).depends({'EMeterRS485Line1DataSourceEnable':'1'});
                
                
                s.option( L.cbi.CheckboxValue, 'EMeterRS485Line2DataSourceEnable', {
                 caption: L.tr('Enable RS485Line2')
               });
        
                
                s.option(L.cbi.InputValue,'EMeterRS485Line2DataSourcePerPublishInterval',{
                       caption: L.tr('Overall Periodicity Of RS485 Line 2 Readings (In Seconds >= 60)'),
                }).depends({'EMeterRS485Line2DataSourceEnable':'1'});
                
                
             /*   s.option( L.cbi.CheckboxValue, 'EMeterRS485Line3DataSourceEnable', {
                 caption: L.tr('Enable RS485Line3')
               });
        
                
                s.option(L.cbi.InputValue,'EMeterRS485Line3DataSourcePerPublishInterval',{
                       caption: L.tr('Overall Periodicity Of RS485 Line 3 Readings (In Seconds >= 60)'),
                }).depends({'EMeterRS485Line3DataSourceEnable':'1'});
                
                
                s.option( L.cbi.CheckboxValue, 'EMeterRS485Line4DataSourceEnable', {
                 caption: L.tr('Enable RS485Line4')
               });
        
                
                s.option(L.cbi.InputValue,'EMeterRS485Line4DataSourcePerPublishInterval',{
                       caption: L.tr('Overall Periodicity Of RS485 Line 4 Readings (In Seconds >= 60)'),
                }).depends({'EMeterRS485Line4DataSourceEnable':'1'});*/
                
                s.option(L.cbi.InputValue,'SleepIntervalbetweensuccessiveEnergyMetersInMilliSec',{
                       caption: L.tr('Delay between each RS485 Readings (in Milliseconds)'),
                       datatype: 'uinteger',
                }).depends({'EMeterRS485Line1DataSourceEnable':'1'});
               /* s.option(L.cbi.InputValue,'HTTPPeriodicPublishInterval',{
                       caption: L.tr('Periodic Data HTTP Interval'),
                       datatype:'integer',
                       description: L.tr('in  seconds')
                });
                
                s.option(L.cbi.InputValue,'HealthPeriodicPublishInterval',{
                       caption: L.tr('Periodic HTTP Health  Interval'),
                       datatype:'integer',
                       description: L.tr('in  seconds')
                });*/
                
                s.option( L.cbi.CheckboxValue, 'EMeterRS232Line1DataSourceEnable', {
                 caption: L.tr('Enable RS232')
                
               });
               
               s.option(L.cbi.InputValue,'EMeterRS232Line1DataSourcePerPublishInterval',{
                       caption: L.tr('Overall Periodicity Of RS232 devices Readings (In Seconds >= 60)'),
                       datatype: 'uinteger',
                }).depends({'EMeterRS232Line1DataSourceEnable':'1'});
                
                
                s.option(L.cbi.InputValue,'SleepIntervalbetweensuccessiveRS232MetersInMilliSec',{
                       caption: L.tr('Delay between each RS232 device Readings (in Milliseconds)'),
                       datatype: 'uinteger',                       
                }).depends({'EMeterRS232Line1DataSourceEnable':'1'});
                
               s.option( L.cbi.CheckboxValue, 'DIODataSourceEnable', {
                 caption: L.tr('Enable DIO')
               });
               
               s.option(L.cbi.InputValue,'DIODataSourcePerPublishInterval',{
                       caption: L.tr('Overall Periodicity Of Digital input/output (In Seconds >= 60)'),
                       datatype: 'uinteger',
                }).depends({'DIODataSourceEnable':'1'});
                
                
                
                s.option( L.cbi.CheckboxValue, 'TEMPERATUREDataSourceEnable', {
                 caption: L.tr('Enable Temperature Sensor')
               });
               
               s.option(L.cbi.InputValue,'TEMPERATUREDataSourcePerPublishInterval',{
                       caption: L.tr('Overall Periodicity Of Temperature Sensors Readings (In Seconds >= 60)'),
                       datatype: 'uinteger',
                }).depends({'TEMPERATUREDataSourceEnable':'1'});
               
              
                m.insertInto('#map');
        }
})

