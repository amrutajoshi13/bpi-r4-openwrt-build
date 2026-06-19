L.ui.view.extend({
        title: L.tr('Fixed Packet Configuration'),

        execute: function() {
                var m = new L.cbi.Map('FixedPacketConfigGeneric', {
                        caption: L.tr('')
                });

                var s = m.section(L.cbi.NamedSection, 'fixedpacketconfig', {
                       caption: L.tr('Fixed  Packet Configuration Settings')
                });
                 
                //s.option(L.cbi.CheckboxValue,'SiteIDEnable',{
                       //caption: L.tr('Site ID Enable')
                //});

                //s.option(L.cbi.InputValue,'SiteID',{
                       //caption: L.tr('Site ID'),
                //}).depends('SiteIDEnable');

                //s.option(L.cbi.CheckboxValue,'DeviceIDEnable',{
                       //caption: L.tr('Device ID Enable')
                //});

                s.option(L.cbi.InputValue,'DeviceID',{
                       caption: L.tr('Device ID'),
                }).depends('DeviceIDEnable');
              
               /* s.option(L.cbi.CheckboxValue,'IMEINoEnable',{
                       caption: L.tr('IMEI No Enable')
                });

                s.option(L.cbi.DummyValue,'IMEINo',{
                       caption: L.tr('IMEI No')
                }).depends('IMEINoEnable');*/

              /*  s.option(L.cbi.CheckboxValue,'OverallSeparatorEnable',{
                       caption: L.tr('Overall Separator Enable')
                });*/

                s.option(L.cbi.InputValue,'OverallRecordstartmark',{
                       caption: L.tr('Record Start Mark'),
                       datatype: 'preventComma'
                });

                s.option(L.cbi.InputValue,'OverallRecordendmark',{
                       caption: L.tr('Record End Mark'),
                       datatype: 'preventComma'
                });

               /* s.option(L.cbi.CheckboxValue,'IndividualSeparatorEnable',{
                       caption: L.tr('Individual Separator Enable')
                });*/

                s.option(L.cbi.InputValue,'Registerstartmark',{
                       caption: L.tr('Register Start Mark'),
                       datatype: 'preventComma'
                });

                s.option(L.cbi.InputValue,'Registerendmark',{
                       caption: L.tr('Register End Mark'),
                       datatype: 'preventComma'
                });
                
                s.option(L.cbi.InputValue,'InvalidDataCharacter',{
                       caption: L.tr('Invalid Data Character')
                });
                
                s.option(L.cbi.InputValue,'FailureDataCharacter',{
                       caption: L.tr('Failure Data Character')
                });
                
                 s.option(L.cbi.CheckboxValue,'MultiblockEnable',{
                       caption: L.tr('Multiblock Enable')                   
                });                                                
                                                                    
                s.option(L.cbi.InputValue,'BlockSeperatorCharacter',{
                       caption: L.tr('Block Seperator Character'),       
                       datatype: 'preventComma'                  
                }).depends('MultiblockEnable');   


                s.option(L.cbi.ListValue, 'EnableJSON', {
                 caption:     L.tr('Publish Type'),
                }).value("0", L.tr('CSV'))
                  .value("1", L.tr('JSON'));

                s.option(L.cbi.DummyValue, 'warning', {
				  caption: L.tr(''),
				//  caption: L.tr(a),
		        }).ucivalue=function()
		          {
		            var id="<h4><b>You will lose Data on disabling Data storage on eMMC, if the same has been already enabled. </b> </h4>";
		            return id;
		          }; 
                
                //s.option(L.cbi.CheckboxValue,'eMCCEnable',{
                       //caption: L.tr('Enable Data Storage on eMMC')
                //});
                
                  //s.option(L.cbi.ListValue, 'storagesize', {
//                 caption:     L.tr('Storage Size'),
//                }).value("4GB", L.tr('4GB'))
//                  .value("8GB", L.tr('8GB'));

                
            /*     s.option(L.cbi.InputValue,'MaxNumberofRegisters',{
                       caption: L.tr('Max.No.of Registers'),
                       datatype: 'uinteger'
                });*/
                
              /*  s.option(L.cbi.CheckboxValue,'RecordSeparatorEnable',{
                       caption: L.tr('Record Separator Enable')       
                });*/                                                       
                                                                          
               /*s.option(L.cbi.CheckboxValue,'UserPassEnable',{
                       caption: L.tr('Username and Password')
                });*/
                
                
               m.insertInto('#map');                   
                                      
         }                           
})                             

