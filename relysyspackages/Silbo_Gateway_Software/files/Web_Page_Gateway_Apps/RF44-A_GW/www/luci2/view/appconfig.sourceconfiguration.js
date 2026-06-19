L.ui.view.extend({
       title: L.tr('Source Configuration'),
       GetUCISections: L.rpc.declare({
              object: 'uci',
              method: 'get',
              params: ['config', 'type'],
              expect: { values: {} }
       }),
       execute: function () {
              var self = this;
              var m = new L.cbi.Map('sourceconfig', {
                     caption: L.tr('')
              });

              var s = m.section(L.cbi.NamedSection, 'sourceconfig', {
                     caption: L.tr('Source Settings')
              });

              s.option(L.cbi.CheckboxValue, 'EMeterRS485Line1DataSourceEnable', {
                     caption: L.tr('Enable RS485Line1')
              });


              s.option(L.cbi.InputValue, 'EMeterRS485Line1DataSourcePerPublishInterval', {
                     caption: L.tr('Overall Periodicity Of RS485 Line 1 Readings (In Seconds >=30)'),
                     datatype: 'uinteger',
              }).depends({ 'EMeterRS485Line1DataSourceEnable': '1' });


              /* s.option( L.cbi.CheckboxValue, 'EMeterRS485Line2DataSourceEnable', {
                caption: L.tr('Enable RS485Line2')
              });
       
               
               s.option(L.cbi.InputValue,'EMeterRS485Line2DataSourcePerPublishInterval',{
                      caption: L.tr('Overall Periodicity Of RS485 Line 2 Readings (In Seconds >= 60)'),
               }).depends({'EMeterRS485Line2DataSourceEnable':'1'});
               
               
               s.option( L.cbi.CheckboxValue, 'EMeterRS485Line3DataSourceEnable', {
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

              s.option(L.cbi.InputValue, 'SleepIntervalbetweensuccessiveEnergyMetersInMilliSec', {
                     caption: L.tr('Delay between each RS485 Readings (in Milliseconds)'),
                     datatype: 'uinteger',
              }).depends({ 'EMeterRS485Line1DataSourceEnable': '1' });

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

              //s.option(L.cbi.CheckboxValue, 'EMeterRS232Line1DataSourceEnable', {
                     //caption: L.tr('Enable RS232')

              //});

              //s.option(L.cbi.InputValue, 'EMeterRS232Line1DataSourcePerPublishInterval', {
                     //caption: L.tr('Overall Periodicity Of RS232 devices Readings (In Seconds >= 60)'),
                     //datatype: 'uintegerMultipleOf60'
              //}).depends({ 'EMeterRS232Line1DataSourceEnable': '1' });


              //s.option(L.cbi.InputValue, 'SleepIntervalbetweensuccessiveRS232MetersInMilliSec', {
                     //caption: L.tr('Delay between each RS232 device Readings (in Milliseconds)'),
                     //datatype: 'uinteger'
              //}).depends({ 'EMeterRS232Line1DataSourceEnable': '1' });

              //s.option(L.cbi.CheckboxValue, 'DIODataSourceEnable', {
                     //caption: L.tr('Enable DIO')
              //});

              //s.option(L.cbi.InputValue, 'DIODataSourcePerPublishInterval', {
                     //caption: L.tr('Overall Periodicity Of Digital input/output (In Seconds >= 60)'),
                     //datatype: 'uintegerMultipleOf60'
              //}).depends({ 'DIODataSourceEnable': '1' });

              //s.option(L.cbi.CheckboxValue, 'AIODataSourceEnable', {
                     //caption: L.tr('Enable AI')
              //});

              //s.option(L.cbi.InputValue, 'AIODataSourcePerPublishInterval', {
                     //caption: L.tr('Overall Periodicity Of Analog Input Readings (In Seconds >= 60)'),
                     //datatype: 'uintegerMultipleOf60'
              //}).depends({ 'AIODataSourceEnable': '1' });
              
              
           /*   s.option(L.cbi.CheckboxValue, 'SNMPDataSourceEnable', {
                     caption: L.tr('Enable SNMP')
              });

              s.option(L.cbi.InputValue, 'SNMPDataSourcePerPublishInterval', {
                     caption: L.tr('Overall Periodicity Of SNMP Readings (In Seconds >= 60)'),
                     datatype: 'uintegerMultipleOf60'
              }).depends({ 'SNMPDataSourceEnable': '1' });*/
              
              
             /* s.option(L.cbi.CheckboxValue, 'CustomLine1DataSourceEnable', {
                     caption: L.tr('Enable CUSTOM')
              });*/

             

             /* s.option(L.cbi.InputValue, 'CustomLine1DataSourcePerPublishInterval', {
                     caption: L.tr('Overall Periodicity Of Custom Input Readings (In Seconds >= 60)'),
                     datatype: 'uintegerMultipleOf60'
              }).depends({ 'CustomLine1DataSourceEnable': '1' });

              s.option(L.cbi.InputValue, 'NoOfCustomDataSources', {
                     caption: L.tr('NoOfCustomDataSources'),
              }).depends({ 'CustomLine1DataSourceEnable': '1' });

              s.option(L.cbi.InputValue, 'NoOfCustomDevicesInLine1', {
                     caption: L.tr('NoOfCustomDevicesInLine1'),
              }).depends({ 'CustomLine1DataSourceEnable': '1' });*/





              /*  s.option( L.cbi.CheckboxValue, 'TEMPERATUREDataSourceEnable', {
                 caption: L.tr('Enable Temperature Sensor')
               });
               
               s.option(L.cbi.InputValue,'TEMPERATUREDataSourcePerPublishInterval',{
                       caption: L.tr('Overall Periodicity Of Temperature Sensors Readings (In Seconds >= 120)'),
                       datatype: 'uintegerMultipleOf60',
                }).depends({'TEMPERATUREDataSourceEnable':'1'});*/

              self.GetUCISections("sourceconfig", "sourceconfig").then(function (rv) {
                     for (var key in rv) {
                            if (rv.hasOwnProperty(key)) {
                                   var obj = rv[key];
                                   console.log(obj)
                                   var rs485enable = obj.EMeterRS485Line1DataSourceEnable;
                                   var rs232enable = obj.EMeterRS232Line1DataSourceEnable;
                                   var aioenable = obj.AIODataSourceEnable;
                                   var dioenable = obj.DIODataSourceEnable;
                                   var temperatureenable = obj.TEMPERATUREDataSourceEnable;
                                   var snmpenable = obj.SNMPDataSourceEnable;
                                   var customenable = obj.CustomLine1DataSourceEnable;
                                   // var SessionTime = obj.sessiontimeout;
                                   localStorage.setItem("rs485enable", rs485enable)
                                   localStorage.setItem("rs232enable", rs232enable)
                                   localStorage.setItem("aioenable", aioenable)
                                   localStorage.setItem("dioenable", dioenable)
                                   localStorage.setItem("temperatureenable", temperatureenable)
                                   localStorage.setItem("snmpenable", snmpenable)
                                   localStorage.setItem("customenable", customenable)
                            }
                     }
              });

              m.insertInto('#map');
       }
})

