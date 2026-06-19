L.ui.view.extend({
        title: L.tr('Digital IO Configuration'),

        execute: function() {
                var m = new L.cbi.Map('digitalinputconfig', {
                        caption: L.tr('')
                });

                var s = m.section(L.cbi.NamedSection, 'digitalinputconfig', {
                       caption: L.tr('Digital IO Configuration')
                });
                
                /* DI1 */
                
                s.tab({
               id: 'DI1',
               caption: L.tr('Digital IO 1')
               });
                
               s.taboption('DI1', L.cbi.CheckboxValue, 'DInput1Enable', {
                 caption: L.tr('Enable Digital IO 1')
               }).depends({'DI1':'1'});
               
               s.taboption('DI1',L.cbi.ListValue,'DIOMode1',{ 
                        caption: L.tr('Digital IO 1 Mode'),   
                }).depends({'DI1':'1','DInput1Enable':'1'})
                  .value("0",L.tr("Input"))                                  
                  .value("1",L.tr("Output")); 
                
                s.taboption('DI1',L.cbi.ListValue,'DInput1AlarmActiveState',{ 
                        caption: L.tr('Digital IO 1 Alarm Active State'),   
                }).depends({'DI1':'1','DInput1Enable':'1'})
                  .value("0",L.tr("0"))                                  
                  .value("1",L.tr("1"));   
                
                s.taboption('DI1',L.cbi.InputValue,'DInput1AlarmActiveFilterTimeInMilliSeconds',{
                        caption: L.tr('Digital IO 1 Alarm Active Filter Time (InMilliSeconds)'),   
                }).depends({'DInput1Enable':'1'});
                
                s.taboption('DI1',L.cbi.InputValue,'DInput1AlarmDeActiveFilterTimeInMilliSeconds',{
                        caption: L.tr('Digital IO 1 Alarm DeActive Filter Time (InMilliSeconds)'),   
                }).depends({'DInput1Enable':'1'});
                
                s.taboption('DI1',L.cbi.CheckboxValue, 'DInput1TimeDependency', {
                 caption: L.tr('Digital IO 1 Time Dependency'),
                 }).depends({'DInput1Enable':'1'});
               
               s.taboption('DI1',L.cbi.InputValue,'DInput1AlarmStartTime',{
                        caption: L.tr('Digital IO 1 Alarm Start Time'),
                        datatype: 'rt_time_hh_mm_ss',   
                }).depends({'DInput1Enable':'1','DInput1TimeDependency':'1'});
                
               s.taboption('DI1',L.cbi.InputValue,'DInput1AlarmStopTime',{
                        caption: L.tr('Digital IO 1 Alarm Stop Time'),
                         datatype: 'rt_time_hh_mm_ss',   
                }).depends({'DInput1Enable':'1','DInput1TimeDependency':'1'}); 
                
                s.taboption('DI1',L.cbi.ListValue,'DInput1MaskValue',{ 
                        caption: L.tr('Digital IO 1 MaskValue'),   
                }).depends({'DInput1Enable':'1'})
                  .value("0",L.tr("0"))                                  
                  .value("1",L.tr("1"));
                  
                s.taboption('DI1',L.cbi.ListValue,'DInput1AlarmSetNotifyVal',{ 
                        caption: L.tr('Digital IO 1 Alarm Set Notify Value'),   
                }).depends({'DInput1Enable':'1'})
                  .value("0",L.tr("0"))                                  
                  .value("1",L.tr("1"));
                  
                s.taboption('DI1',L.cbi.ListValue,'DInput1AlarmResetNotifyVal',{ 
                        caption: L.tr('Digital IO 1 Alarm Alarm Reset Notify Value'),   
                }).depends({'DInput1Enable':'1'})
                  .value("0",L.tr("0"))                                  
                  .value("1",L.tr("1"));  
                  
                
                /* DI2 */
                s.tab({
               id: 'DI2',
               caption: L.tr('Digital IO 2')
               });
                
                          s.taboption('DI2',L.cbi.CheckboxValue, 'DInput2Enable', {
                 caption: L.tr('Enable Digital IO 2')
               });
               
                s.taboption('DI2',L.cbi.ListValue,'DIOMode2',{ 
                        caption: L.tr('Digital IO 2 Mode'),   
                }).depends({'DI2':'1','DInput2Enable':'1'})
                  .value("0",L.tr("Input"))                                  
                  .value("1",L.tr("Output")); 
                
                s.taboption('DI2',L.cbi.ListValue,'DInput2AlarmActiveState',{ 
                        caption: L.tr('Digital IO 2 Alarm Active State'),   
                }).depends({'DInput2Enable':'1'})
                  .value("0",L.tr("0"))                                  
                  .value("1",L.tr("1"));   
                
                s.taboption('DI2',L.cbi.InputValue,'DInput2AlarmActiveFilterTimeInMilliSeconds',{
                        caption: L.tr('Digital IO 2 Alarm Active Filter Time (InMilliSeconds)'),   
                }).depends({'DInput2Enable':'1'});
                
                s.taboption('DI2',L.cbi.InputValue,'DInput2AlarmDeActiveFilterTimeInMilliSeconds',{
                        caption: L.tr('Digital IO 2 Alarm DeActive Filter Time (InMilliSeconds)'),   
                }).depends({'DInput2Enable':'1'});
                
                s.taboption('DI2',L.cbi.CheckboxValue, 'DInput2TimeDependency', {
                 caption: L.tr('Digital IO 2 Time Dependency'),
                 }).depends({'DInput2Enable':'1'});
               
               s.taboption('DI2',L.cbi.InputValue,'DInput2AlarmStartTime',{
                        caption: L.tr('Digital IO 2 Alarm Start Time'),
                        datatype: 'rt_time_hh_mm_ss',   
                }).depends({'DInput2Enable':'1','DInput2TimeDependency':'1'});
                
               s.taboption('DI2',L.cbi.InputValue,'DInput2AlarmStopTime',{
                        caption: L.tr('Digital IO 2 Alarm Stop Time'),
                         datatype: 'rt_time_hh_mm_ss',   
                }).depends({'DInput2Enable':'1','DInput2TimeDependency':'1'}); 
                
                s.taboption('DI2',L.cbi.ListValue,'DInput2MaskValue',{ 
                        caption: L.tr('Digital IO 2 MaskValue'),   
                }).depends({'DInput2Enable':'1'})
                  .value("0",L.tr("0"))                                  
                  .value("1",L.tr("1"));
                  
                s.taboption('DI2',L.cbi.ListValue,'DInput2AlarmSetNotifyVal',{ 
                        caption: L.tr('Digital IO 2 Alarm Set Notify Value'),   
                }).depends({'DInput2Enable':'1'})
                  .value("0",L.tr("0"))                                  
                  .value("1",L.tr("1"));
                  
                s.taboption('DI2',L.cbi.ListValue,'DInput2AlarmResetNotifyVal',{ 
                        caption: L.tr('Digital IO 2 Alarm Alarm Reset Notify Value'),   
                }).depends({'DInput2Enable':'1'})
                  .value("0",L.tr("0"))                                  
                  .value("1",L.tr("1")); 
                  
                  ///* DI3 */
               //s.tab({
               //id: 'DI3',
               //caption: L.tr('Digital IO 3')
               //});
                
                          //s.taboption('DI3', L.cbi.CheckboxValue, 'DInput3Enable', {
                 //caption: L.tr('Enable Digital IO 3')
               //});
               
               //s.taboption('DI3',L.cbi.ListValue,'DIOMode3',{ 
                        //caption: L.tr('Digital IO 3 Mode'),   
                //}).depends({'DI3':'1','DInput3Enable':'1'})
                  //.value("0",L.tr("Input"))                                  
                  //.value("1",L.tr("Output")); 
                
                //s.taboption('DI3',L.cbi.ListValue,'DInput3AlarmActiveState',{ 
                        //caption: L.tr('Digital IO 3 Alarm Active State'),   
                //}).depends({'DInput3Enable':'1'})
                  //.value("0",L.tr("0"))                                  
                  //.value("1",L.tr("1"));   
                
                //s.taboption('DI3',L.cbi.InputValue,'DInput3AlarmActiveFilterTimeInMilliSeconds',{
                        //caption: L.tr('Digital IO 3 Alarm Active Filter Time (InMilliSeconds)'),   
                //}).depends({'DInput3Enable':'1'});
                
                //s.taboption('DI3',L.cbi.InputValue,'DInput3AlarmDeActiveFilterTimeInMilliSeconds',{
                        //caption: L.tr('Digital IO 3 Alarm DeActive Filter Time (InMilliSeconds)'),   
                //}).depends({'DInput3Enable':'1'});
                
                //s.taboption('DI3',L.cbi.CheckboxValue, 'DInput3TimeDependency', {
                 //caption: L.tr('Digital IO 3 Time Dependency'),
                 //}).depends({'DInput3Enable':'1'});
               
               //s.taboption('DI3',L.cbi.InputValue,'DInput3AlarmStartTime',{
                        //caption: L.tr('Digital IO 3 Alarm Start Time'),
                        //datatype: 'rt_time_hh_mm_ss',   
                //}).depends({'DInput3Enable':'1','DInput3TimeDependency':'1'});
                
               //s.taboption('DI3',L.cbi.InputValue,'DInput3AlarmStopTime',{
                        //caption: L.tr('Digital IO 3 Alarm Stop Time'),
                         //datatype: 'rt_time_hh_mm_ss',   
                //}).depends({'DInput3Enable':'1','DInput3TimeDependency':'1'}); 
                
                //s.taboption('DI3',L.cbi.ListValue,'DInput3MaskValue',{ 
                        //caption: L.tr('Digital IO 3 MaskValue'),   
                //}).depends({'DInput3Enable':'1'})
                  //.value("0",L.tr("0"))                                  
                  //.value("1",L.tr("1"));
                  
                //s.taboption('DI3',L.cbi.ListValue,'DInput3AlarmSetNotifyVal',{ 
                        //caption: L.tr('Digital IO 3 Alarm Set Notify Value'),   
                //}).depends({'DInput3Enable':'1'})
                  //.value("0",L.tr("0"))                                  
                  //.value("1",L.tr("1"));
                  
                //s.taboption('DI3',L.cbi.ListValue,'DInput3AlarmResetNotifyVal',{ 
                        //caption: L.tr('Digital IO 3 Alarm Alarm Reset Notify Value'),   
                //}).depends({'DInput3Enable':'1'})
                  //.value("0",L.tr("0"))                                  
                  //.value("1",L.tr("1"));  
                  
                ///* DI4 */
                 //s.tab({
               //id: 'DI4',
               //caption: L.tr('Digital IO 4')
               //});
                
                          //s.taboption('DI4',L.cbi.CheckboxValue, 'DInput4Enable', {
                 //caption: L.tr('Enable Digital IO 4')
               //});
               
               //s.taboption('DI4',L.cbi.ListValue,'DIOMode4',{ 
                        //caption: L.tr('Digital IO 4 Mode'),   
                //}).depends({'DI4':'1','DInput4Enable':'1'})
                  //.value("0",L.tr("Input"))                                  
                  //.value("1",L.tr("Output")); 
                
                //s.taboption('DI4',L.cbi.ListValue,'DInput4AlarmActiveState',{ 
                        //caption: L.tr('Digital IO 4 Alarm Active State'),   
                //}).depends({'DInput4Enable':'1'})
                  //.value("0",L.tr("0"))                                  
                  //.value("1",L.tr("1"));   
                
                //s.taboption('DI4',L.cbi.InputValue,'DInput4AlarmActiveFilterTimeInMilliSeconds',{
                        //caption: L.tr('Digital IO 4 Alarm Active Filter Time (InMilliSeconds)'),   
                //}).depends({'DInput4Enable':'1'});
                
                //s.taboption('DI4',L.cbi.InputValue,'DInput4AlarmDeActiveFilterTimeInMilliSeconds',{
                        //caption: L.tr('Digital IO 4 Alarm DeActive Filter Time (InMilliSeconds)'),   
                //}).depends({'DInput4Enable':'1'});
                
                //s.taboption('DI4',L.cbi.CheckboxValue, 'DInput4TimeDependency', {
                 //caption: L.tr('Digital IO 4 Time Dependency'),
                 //}).depends({'DInput4Enable':'1'});
               
               //s.taboption('DI4',L.cbi.InputValue,'DInput4AlarmStartTime',{
                        //caption: L.tr('Digital IO 4 Alarm Start Time'),
                        //datatype: 'rt_time_hh_mm_ss',   
                //}).depends({'DInput4Enable':'1','DInput4TimeDependency':'1'});
                
               //s.taboption('DI4',L.cbi.InputValue,'DInput4AlarmStopTime',{
                        //caption: L.tr('Digital IO 4 Alarm Stop Time'),
                         //datatype: 'rt_time_hh_mm_ss',   
                //}).depends({'DInput4Enable':'1','DInput4TimeDependency':'1'}); 
                
                //s.taboption('DI4',L.cbi.ListValue,'DInput4MaskValue',{ 
                        //caption: L.tr('Digital IO 4 MaskValue'),   
                //}).depends({'DInput4Enable':'1'})
                  //.value("0",L.tr("0"))                                  
                  //.value("1",L.tr("1"));
                  
                //s.taboption('DI4',L.cbi.ListValue,'DInput4AlarmSetNotifyVal',{ 
                        //caption: L.tr('Digital IO 4 Alarm Set Notify Value'),   
                //}).depends({'DInput4Enable':'1'})
                  //.value("0",L.tr("0"))                                  
                  //.value("1",L.tr("1"));
                  
                //s.taboption('DI4',L.cbi.ListValue,'DInput4AlarmResetNotifyVal',{ 
                        //caption: L.tr('Digital IO 4 Alarm Alarm Reset Notify Value'),   
                //}).depends({'DInput4Enable':'1'})
                  //.value("0",L.tr("0"))                                  
                  //.value("1",L.tr("1"));       
              
                m.insertInto('#map');
        }
})

