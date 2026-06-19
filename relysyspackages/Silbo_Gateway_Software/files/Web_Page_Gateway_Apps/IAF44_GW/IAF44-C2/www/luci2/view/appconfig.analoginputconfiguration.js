L.ui.view.extend({
	
	
	
	     fGetUCISections: L.rpc.declare({
        object: 'uci',
        method: 'get',
       // params: [ 'config', 'type', 'section']  
              params: [ 'config', 'type']  
       
    }),
        updateinterfaceconfig: L.rpc.declare({
        object: 'rpc-UpdateAIOConfig',
        method: 'configure',
        params: ['application','action'],
        expect: { output: '' }
    }),

    
        title: L.tr('Analog Input Configuration'),



        execute: function() {
                var m = new L.cbi.Map('analoginputconfig', {
                        caption: L.tr('')
                });

                var s = m.section(L.cbi.NamedSection, 'analoginputconfig', {
                       caption: L.tr('Analog Input Configuration')
                });
                
                
                /* Mode Configuration */
                
              /*  s.tab({
               id: 'AIMode',
               caption: L.tr('Mode Configuration')
               });
               
               	s.taboption('AIMode', L.cbi.DummyValue,'ModeSelect',{
				caption: L.tr('Select Mode (Burst/Normal AI)'),
				}).depends({'AIMode':'1'});
				
				
				s.taboption('AIMode', L.cbi.ListValue,'AInputBurstMode', {
                        caption: L.tr('Mode Selection'),
                        optional: true,
                        listlimit: 2,
                        listcustom:false
                }).depends({'AIMode':'1'})
                .value('0', L.tr('Normal AI Mode'))
                .value('1', L.tr('Burst Mode')); */


               
                
                /* AI1 */
                
                s.tab({
               id: 'AI1',
               caption: L.tr('Analog Input 1')
               });
               
                
               s.taboption('AI1', L.cbi.CheckboxValue, 'AInput1Enable', {
                 caption: L.tr('Enable Analog Output 1')
               }).depends({'AI1':'1'});
               
				//s.taboption('AI1',L.cbi.CheckboxValue,'AInput1MultiplicationFactorEnable',{ 
                        //caption: L.tr('MultiplicationFactorEnable'),   
                //}).depends({'AI1':'1','AInput1Enable':'1','AInputBurstMode':'0'});
                
                s.taboption('AI1', L.cbi.ListValue,'AInput1MultiplicationFactorEnable', {
                        caption: L.tr('Mode'),
                        //optional: true,
                        listlimit: 3,
                        listcustom:false
                }).depends({'AI1':'1','AInput1Enable':'1','AInputBurstMode':'0'})
                .value('0', L.tr('Normal'))
                .value('1', L.tr('Multiply'))
                .value('2', L.tr('Scale'));
                
                 s.taboption('AI1',L.cbi.InputValue,'AInput1Transducermax',{ 
                        caption: L.tr('Transducer Max'), 
                        datatype: 'rt_float',  
                }).depends({'AI1':'1','AInput1Enable':'1','AInputBurstMode':'0','AInput1MultiplicationFactorEnable':'2'});
  
				s.taboption('AI1',L.cbi.InputValue,'AInput1Transducermin',{ 
									caption: L.tr('Transducer Min'), 
									datatype: 'rt_float',  
							}).depends({'AI1':'1','AInput1Enable':'1','AInputBurstMode':'0','AInput1MultiplicationFactorEnable':'2'});
				
				s.taboption('AI1',L.cbi.InputValue,'AInput1Rawmax',{ 
									caption: L.tr('Raw Max'),  
									datatype: 'rt_float', 
							}).depends({'AI1':'1','AInput1Enable':'1','AInputBurstMode':'0','AInput1MultiplicationFactorEnable':'2'});
				
				s.taboption('AI1',L.cbi.InputValue,'AInput1Rawmin',{ 
							caption: L.tr('Raw Min'), 
							datatype: 'rt_float',  
							}).depends({'AI1':'1','AInput1Enable':'1','AInputBurstMode':'0','AInput1MultiplicationFactorEnable':'2'});
							
				s.taboption('AI1',L.cbi.CheckboxValue,'AInput1ClampEnable',{ 
						caption: L.tr('Clamp Values Enable'),   
						}).depends({'AI1':'1','AInput1Enable':'1','AInputBurstMode':'0','AInput1MultiplicationFactorEnable':'2'});
						
				s.taboption('AI1',L.cbi.InputValue,'AInput1ClampMax',{ 
				caption: L.tr('Clamp Max Value'),   
				datatype: 'rt_float',
                }).depends({'AI1':'1','AInput1Enable':'1','AInputBurstMode':'0','AInput1MultiplicationFactorEnable':'2','AInput1ClampEnable':'1'});
  
                 s.taboption('AI1',L.cbi.InputValue,'AInput1ClampMin',{ 
                        caption: L.tr('Clamp Min Value'), 
                        datatype: 'rt_float',  
                }).depends({'AI1':'1','AInput1Enable':'1','AInputBurstMode':'0','AInput1MultiplicationFactorEnable':'2','AInput1ClampEnable':'1'});
  
								  
				                
				s.taboption('AI1',L.cbi.InputValue,'AInput1MultiplicationFactor',{ 
                        caption: L.tr('MultiplicationFactor'),   
                }).depends({'AI1':'1','AInput1Enable':'1','AInputBurstMode':'0','AInput1MultiplicationFactorEnable':'1'});
  
				           
                s.taboption('AI1',L.cbi.CheckboxValue,'AInput1AlarmActiveState',{ 
                        caption: L.tr('Alarm Enable'),   
                }).depends({'AI1':'1','AInput1Enable':'1','AInputBurstMode':'0'});

                    s.taboption('AI1',L.cbi.CheckboxValue,'AI1UpperThresholdEnable',{ 
                        caption: L.tr('Upper Threshold Enable'),   
                }).depends({'AI1':'1','AInput1Enable':'1','AInputBurstMode':'0'});
  
                    s.taboption('AI1',L.cbi.InputValue,'AI1UpperThresholdName',{ 
                        caption: L.tr('Upper Threshold Name'),   
                }).depends({'AI1':'1','AInput1Enable':'1','AInputBurstMode':'0','AI1UpperThresholdEnable':'1'});
  
                  
  
               s.taboption('AI1',L.cbi.InputValue, 'AInput1UpperThreshold', {
                        caption: L.tr('Upper Threshold Level'),
                        datatype:'rt_float'
                }).depends({'AInput1Enable':'1','AInputBurstMode':'0','AInput1AlarmActiveState':'1','AI1UpperThresholdEnable':'1'});  
                
                s.taboption('AI1',L.cbi.InputValue, 'AInput1UpperHysteresis', {
                        caption: L.tr('Upper Hysteresis'),
                        datatype:'rt_float'
                }).depends({'AInput1Enable':'1','AInputBurstMode':'0','AInput1AlarmActiveState':'1','AI1UpperThresholdEnable':'1'});
                
                  s.taboption('AI1',L.cbi.CheckboxValue,'AI1LowerThresholdEnable',{ 
                        caption: L.tr('Lower Threshold Enable'),   
                }).depends({'AI1':'1','AInput1Enable':'1','AInputBurstMode':'0'});
                
                  s.taboption('AI1',L.cbi.InputValue,'AI1LowerThresholdName',{ 
                        caption: L.tr('Lower Threshold Name'),   
                }).depends({'AI1':'1','AInput1Enable':'1','AInputBurstMode':'0','AI1LowerThresholdEnable':'1'});
                
                s.taboption('AI1',L.cbi.InputValue, 'AInput1LowerThreshold', {
                        caption: L.tr('Lower Threshold Level'),
                        datatype:'rt_float'
                }).depends({'AInput1Enable':'1','AInputBurstMode':'0','AInput1AlarmActiveState':'1','AI1LowerThresholdEnable':'1'}); 
                
                s.taboption('AI1',L.cbi.InputValue, 'AInput1LowerHysteresis', {
                        caption: L.tr('Lower Hysteresis'),
                        datatype:'rt_float'
                }).depends({'AInput1Enable':'1','AInputBurstMode':'0','AInput1AlarmActiveState':'1','AI1LowerThresholdEnable':'1'});
               
                s.taboption('AI1',L.cbi.CheckboxValue, 'AInput1TimeDependency', {
                 caption: L.tr('Time Dependency'),
                 }).depends({'AInput1Enable':'1','AInputBurstMode':'0','AInput1AlarmActiveState':'1'});
               
               s.taboption('AI1',L.cbi.InputValue,'AInput1AlarmStartTime',{
                        caption: L.tr('Alarm Start Time'),
                        datatype: 'rt_time_hh_mm_ss',   
                }).depends({'AInput1Enable':'1','AInput1TimeDependency':'1','AInputBurstMode':'0','AInput1AlarmActiveState':'1'});
                
               s.taboption('AI1',L.cbi.InputValue,'AInput1AlarmStopTime',{
                        caption: L.tr('Alarm Stop Time'),
                         datatype: 'rt_time_hh_mm_ss',   
                }).depends({'AInput1Enable':'1','AInput1TimeDependency':'1','AInputBurstMode':'0','AInput1AlarmActiveState':'1'}); 
                
                s.taboption('AI1', L.cbi.CheckboxValue,'AInput1DayDependency', {
                        caption: L.tr('Day Dependency'),
                        optional: true
                }).depends({'AInput1Enable':'1','AInputBurstMode':'0','AInput1AlarmActiveState':'1'});
			
                s.taboption('AI1', L.cbi.ListValue,'AInput1DayDependencyValue', {
                        caption: L.tr('Weekly Holidays'),
                        optional: true,
                        listlimit: 7,
                        listcustom:false
                }).depends({'AInput1Enable':'1','AInput1DayDependency':'1','AInputBurstMode':'0','AInput1AlarmActiveState':'1'})
                .value('0', L.tr('Monday'))
                .value('1', L.tr('Tuesday'))
                .value('2', L.tr('Wednesday'))
                .value('3', L.tr('Thursday'))
                .value('4', L.tr('Friday'))
                .value('5',L.tr('Saturday'))
                .value('6', L.tr('Sunday'));
               
                  
                
                /* AI2 */
                s.tab({
               id: 'AI2',
               caption: L.tr('Analog Input 2')
               });
               
               
               s.taboption('AI2', L.cbi.CheckboxValue, 'AInput2Enable', {
                 caption: L.tr('Enable Analog Output 2')
               }).depends({'AI2':'1'});
               
          s.taboption('AI2', L.cbi.ListValue,'AInput2MultiplicationFactorEnable', {
                        caption: L.tr('Mode'),
                        //optional: true,
                        listlimit: 3,
                        listcustom:false
                }).depends({'AI2':'1','AInput2Enable':'1','AInputBurstMode':'0'})
                .value('0', L.tr('Normal'))
                .value('1', L.tr('Multiply'))
                .value('2', L.tr('Scale'));
                
                 s.taboption('AI2',L.cbi.InputValue,'AInput2Transducermax',{ 
                        caption: L.tr('Transducer Max'),   
                }).depends({'AI2':'1','AInput2Enable':'1','AInputBurstMode':'0','AInput2MultiplicationFactorEnable':'2'});
  
				s.taboption('AI2',L.cbi.InputValue,'AInput2Transducermin',{ 
									caption: L.tr('Transducer Min'),   
							}).depends({'AI2':'1','AInput2Enable':'1','AInputBurstMode':'0','AInput2MultiplicationFactorEnable':'2'});
				
				s.taboption('AI2',L.cbi.InputValue,'AInput2Rawmax',{ 
									caption: L.tr('Raw Max'),   
							}).depends({'AI2':'1','AInput2Enable':'1','AInputBurstMode':'0','AInput2MultiplicationFactorEnable':'2'});
				
				s.taboption('AI2',L.cbi.InputValue,'AInput2Rawmin',{ 
									caption: L.tr('Raw Min'),   
							}).depends({'AI2':'1','AInput2Enable':'1','AInputBurstMode':'0','AInput2MultiplicationFactorEnable':'2'});
				
				s.taboption('AI2',L.cbi.CheckboxValue,'AInput2ClampEnable',{ 
						caption: L.tr('Clamp Values Enable'),   
						}).depends({'AI2':'1','AInput2Enable':'1','AInputBurstMode':'0','AInput2MultiplicationFactorEnable':'2'});
						
				s.taboption('AI2',L.cbi.InputValue,'AInput2ClampMax',{ 
				caption: L.tr('Clamp Max Value'),   
                }).depends({'AI2':'1','AInput2Enable':'1','AInputBurstMode':'0','AInput2MultiplicationFactorEnable':'2','AInput2ClampEnable':'1'});
  
                 s.taboption('AI2',L.cbi.InputValue,'AInput2ClampMin',{ 
                        caption: L.tr('Clamp Min Value'),   
                }).depends({'AI2':'1','AInput2Enable':'1','AInputBurstMode':'0','AInput2MultiplicationFactorEnable':'2','AInput2ClampEnable':'1'});
  		  
                
				s.taboption('AI2',L.cbi.InputValue,'AInput2MultiplicationFactor',{ 
                        caption: L.tr('MultiplicationFactor'),   
                }).depends({'AI2':'1','AInput2Enable':'1','AInputBurstMode':'0','AInput2MultiplicationFactorEnable':'1'});
  

           
                s.taboption('AI2',L.cbi.CheckboxValue,'AInput2AlarmActiveState',{ 
                        caption: L.tr('Alarm Enable'),   
                }).depends({'AI2':'1','AInput2Enable':'1','AInputBurstMode':'0'});

                  
               s.taboption('AI2',L.cbi.CheckboxValue,'AI2UpperThresholdEnable',{ 
                        caption: L.tr('Upper Threshold Enable'),   
                }).depends({'AI2':'1','AInput2Enable':'1','AInputBurstMode':'0'});
  
               s.taboption('AI2',L.cbi.InputValue,'AI2UpperThresholdName',{ 
                        caption: L.tr('Upper Threshold Name'),   
                }).depends({'AI2':'1','AInput2Enable':'1','AInputBurstMode':'0','AI2UpperThresholdEnable':'1'});
  
                  
                  
                s.taboption('AI2',L.cbi.InputValue, 'AInput2UpperThreshold', {
                        caption: L.tr('Upper Threshold Level'),
                        datatype:'rt_float'
                }).depends({'AInput2Enable':'1','AInputBurstMode':'0','AInput2AlarmActiveState':'1','AI2UpperThresholdEnable':'1'});  
                
                s.taboption('AI2',L.cbi.InputValue, 'AInput2UpperHysteresis', {
                        caption: L.tr('Upper Hysteresis'),
                        datatype:'rt_float'
                }).depends({'AInput2Enable':'1','AInputBurstMode':'0','AInput2AlarmActiveState':'1','AI2UpperThresholdEnable':'1'});
                
                
                     
               s.taboption('AI2',L.cbi.CheckboxValue,'AI2LowerThresholdEnable',{ 
                        caption: L.tr('Lower Threshold Enable'),   
                }).depends({'AI2':'1','AInput2Enable':'1','AInputBurstMode':'0'});
  
                
               s.taboption('AI2',L.cbi.InputValue,'AI2LowerThresholdName',{ 
                        caption: L.tr('Lower Threshold Name'),   
                }).depends({'AI2':'1','AInput2Enable':'1','AInputBurstMode':'0','AI2LowerThresholdEnable':'1'});
  
                
                s.taboption('AI2',L.cbi.InputValue, 'AInput2LowerThreshold', {
                        caption: L.tr('Lower Threshold Level'),
                        datatype:'rt_float'
                }).depends({'AInput2Enable':'1','AInputBurstMode':'0','AInput2AlarmActiveState':'1','AI2LowerThresholdEnable':'1'}); 
                
                s.taboption('AI2',L.cbi.InputValue, 'AInput2LowerHysteresis', {
                        caption: L.tr('Lower Hysteresis'),
                        datatype:'rt_float'
                }).depends({'AInput2Enable':'1','AInputBurstMode':'0','AInput2AlarmActiveState':'1','AI2LowerThresholdEnable':'1'});   
               
                s.taboption('AI2',L.cbi.CheckboxValue, 'AInput2TimeDependency', {
                 caption: L.tr('Time Dependency'),
                 }).depends({'AInput2Enable':'1','AInputBurstMode':'0','AInput2AlarmActiveState':'1'});
               
               s.taboption('AI2',L.cbi.InputValue,'AInput2AlarmStartTime',{
                        caption: L.tr('Alarm Start Time'),
                        datatype: 'rt_time_hh_mm_ss',   
                }).depends({'AInput2Enable':'1','AInput2TimeDependency':'1','AInputBurstMode':'0','AInput2AlarmActiveState':'1'});
                
               s.taboption('AI2',L.cbi.InputValue,'AInput2AlarmStopTime',{
                        caption: L.tr('Alarm Stop Time'),
                         datatype: 'rt_time_hh_mm_ss',   
                }).depends({'AInput2Enable':'1','AInput2TimeDependency':'1','AInputBurstMode':'0','AInput2AlarmActiveState':'1'}); 
                
				s.taboption('AI2', L.cbi.CheckboxValue,'AInput2DayDependency', {
                        caption: L.tr('Day Dependency'),
                        optional: true
                }).depends({'AInput2Enable':'1','AInputBurstMode':'0','AInput2AlarmActiveState':'1'});
			
                s.taboption('AI2', L.cbi.ListValue,'AInput2DayDependencyValue', {
                        caption: L.tr('Weekly Holidays'),
                        optional: true,
                        listlimit: 7,
                        listcustom:false
                }).depends({'AInput2Enable':'1','AInput2DayDependency':'1','AInputBurstMode':'0','AInput2AlarmActiveState':'1'})
                .value('0', L.tr('Monday'))
                .value('1', L.tr('Tuesday'))
                .value('2', L.tr('Wednesday'))
                .value('3', L.tr('Thursday'))
                .value('4', L.tr('Friday'))
                .value('5',L.tr('Saturday'))
                .value('6', L.tr('Sunday'));
                
                
                
                
                
                
                
                
                                /* AI3 */
                
                s.tab({
               id: 'AI3',
               caption: L.tr('Analog Input 3')
               });
               
                
               s.taboption('AI3', L.cbi.CheckboxValue, 'AInput3Enable', {
                 caption: L.tr('Enable Analog Output 3')
               }).depends({'AI3':'1'});
               
				s.taboption('AI3', L.cbi.ListValue,'AInput3MultiplicationFactorEnable', {
                        caption: L.tr('Mode'),
                        //optional: true,
                        listlimit: 3,
                        listcustom:false
                }).depends({'AI3':'1','AInput3Enable':'1','AInputBurstMode':'0'})
                .value('0', L.tr('Normal'))
                .value('1', L.tr('Multiply'))
                .value('2', L.tr('Scale'));
                
                 s.taboption('AI3',L.cbi.InputValue,'AInput3Transducermax',{ 
                        caption: L.tr('Transducer Max'),   
                }).depends({'AI3':'1','AInput3Enable':'1','AInputBurstMode':'0','AInput3MultiplicationFactorEnable':'2'});
  
				s.taboption('AI3',L.cbi.InputValue,'AInput3Transducermin',{ 
									caption: L.tr('Transducer Min'),   
							}).depends({'AI3':'1','AInput3Enable':'1','AInputBurstMode':'0','AInput3MultiplicationFactorEnable':'2'});
				
				s.taboption('AI3',L.cbi.InputValue,'AInput3Rawmax',{ 
									caption: L.tr('Raw Max'),   
							}).depends({'AI3':'1','AInput3Enable':'1','AInputBurstMode':'0','AInput3MultiplicationFactorEnable':'2'});
				
				s.taboption('AI3',L.cbi.InputValue,'AInput3Rawmin',{ 
									caption: L.tr('Raw Min'),   
							}).depends({'AI3':'1','AInput3Enable':'1','AInputBurstMode':'0','AInput3MultiplicationFactorEnable':'2'});
						  
                s.taboption('AI3',L.cbi.CheckboxValue,'AInput3ClampEnable',{ 
						caption: L.tr('Clamp Values Enable'),   
						}).depends({'AI3':'1','AInput3Enable':'1','AInputBurstMode':'0','AInput3MultiplicationFactorEnable':'2'});
						
				s.taboption('AI3',L.cbi.InputValue,'AInput3ClampMax',{ 
				caption: L.tr('Clamp Max Value'),   
                }).depends({'AI3':'1','AInput3Enable':'1','AInputBurstMode':'0','AInput3MultiplicationFactorEnable':'2','AInput3ClampEnable':'1'});
  
                 s.taboption('AI3',L.cbi.InputValue,'AInput3ClampMin',{ 
                        caption: L.tr('Clamp Min Value'),   
                }).depends({'AI3':'1','AInput3Enable':'1','AInputBurstMode':'0','AInput3MultiplicationFactorEnable':'2','AInput3ClampEnable':'1'});
  
				s.taboption('AI3',L.cbi.InputValue,'AInput3MultiplicationFactor',{ 
                        caption: L.tr('MultiplicationFactor'),   
                }).depends({'AI3':'1','AInput1Enable':'1','AInputBurstMode':'0','AInput3MultiplicationFactorEnable':'1'});
  
				
           
                s.taboption('AI3',L.cbi.CheckboxValue,'AInput3AlarmActiveState',{ 
                        caption: L.tr('Alarm Enable'),   
                }).depends({'AI3':'1','AInput3Enable':'1','AInputBurstMode':'0'});

                    s.taboption('AI3',L.cbi.CheckboxValue,'AI3UpperThresholdEnable',{ 
                        caption: L.tr('Upper Threshold Enable'),   
                }).depends({'AI3':'1','AInput3Enable':'1','AInputBurstMode':'0'});
  
                    s.taboption('AI3',L.cbi.InputValue,'AI3UpperThresholdName',{ 
                        caption: L.tr('Upper Threshold Name'),   
                }).depends({'AI3':'1','AInput3Enable':'1','AInputBurstMode':'0','AI3UpperThresholdEnable':'1'});
  
                  
  
               s.taboption('AI3',L.cbi.InputValue, 'AInput3UpperThreshold', {
                        caption: L.tr('Upper Threshold Level'),
                        datatype:'rt_float'
                }).depends({'AInput3Enable':'1','AInputBurstMode':'0','AInput3AlarmActiveState':'1','AI3UpperThresholdEnable':'1'});  
                
                s.taboption('AI3',L.cbi.InputValue, 'AInput3UpperHysteresis', {
                        caption: L.tr('Upper Hysteresis'),
                        datatype:'rt_float'
                }).depends({'AInput3Enable':'1','AInputBurstMode':'0','AInput3AlarmActiveState':'1','AI3UpperThresholdEnable':'1'});
                
                  s.taboption('AI3',L.cbi.CheckboxValue,'AI3LowerThresholdEnable',{ 
                        caption: L.tr('Lower Threshold Enable'),   
                }).depends({'AI3':'1','AInput3Enable':'1','AInputBurstMode':'0'});
                
                  s.taboption('AI3',L.cbi.InputValue,'AI3LowerThresholdName',{ 
                        caption: L.tr('Lower Threshold Name'),   
                }).depends({'AI3':'1','AInput3Enable':'1','AInputBurstMode':'0','AI3LowerThresholdEnable':'1'});
                
                s.taboption('AI3',L.cbi.InputValue, 'AInput3LowerThreshold', {
                        caption: L.tr('Lower Threshold Level'),
                        datatype:'rt_float'
                }).depends({'AInput3Enable':'1','AInputBurstMode':'0','AInput3AlarmActiveState':'1','AI3LowerThresholdEnable':'1'}); 
                
                s.taboption('AI3',L.cbi.InputValue, 'AInput3LowerHysteresis', {
                        caption: L.tr('Lower Hysteresis'),
                        datatype:'rt_float'
                }).depends({'AInput3Enable':'1','AInputBurstMode':'0','AInput3AlarmActiveState':'1','AI3LowerThresholdEnable':'1'});
               
                s.taboption('AI3',L.cbi.CheckboxValue, 'AInput3TimeDependency', {
                 caption: L.tr('Time Dependency'),
                 }).depends({'AInput3Enable':'1','AInputBurstMode':'0','AInput3AlarmActiveState':'1'});
               
               s.taboption('AI3',L.cbi.InputValue,'AInput3AlarmStartTime',{
                        caption: L.tr('Alarm Start Time'),
                        datatype: 'rt_time_hh_mm_ss',   
                }).depends({'AInput3Enable':'1','AInput3TimeDependency':'1','AInputBurstMode':'0','AInput3AlarmActiveState':'1'});
                
               s.taboption('AI3',L.cbi.InputValue,'AInput3AlarmStopTime',{
                        caption: L.tr('Alarm Stop Time'),
                         datatype: 'rt_time_hh_mm_ss',   
                }).depends({'AInput3Enable':'1','AInput3TimeDependency':'1','AInputBurstMode':'0','AInput3AlarmActiveState':'1'}); 
                
                s.taboption('AI3', L.cbi.CheckboxValue,'AInput3DayDependency', {
                        caption: L.tr('Day Dependency'),
                        optional: true
                }).depends({'AInput3Enable':'1','AInputBurstMode':'0','AInput3AlarmActiveState':'1'});
			
                s.taboption('AI3', L.cbi.ListValue,'AInput3DayDependencyValue', {
                        caption: L.tr('Weekly Holidays'),
                        optional: true,
                        listlimit: 7,
                        listcustom:false
                }).depends({'AInput3Enable':'1','AInput3DayDependency':'1','AInputBurstMode':'0','AInput3AlarmActiveState':'1'})
                .value('0', L.tr('Monday'))
                .value('1', L.tr('Tuesday'))
                .value('2', L.tr('Wednesday'))
                .value('3', L.tr('Thursday'))
                .value('4', L.tr('Friday'))
                .value('5',L.tr('Saturday'))
                .value('6', L.tr('Sunday'));
               
                  
                
                // AI4 
                s.tab({
               id: 'AI4',
               caption: L.tr('Analog Input 4')
               });
               
               
               s.taboption('AI4', L.cbi.CheckboxValue, 'AInput4Enable', {
                 caption: L.tr('Enable Analog Output 4')
               }).depends({'AI4':'1'});
               
              s.taboption('AI4', L.cbi.ListValue,'AInput4MultiplicationFactorEnable', {
                        caption: L.tr('Mode'),
                        //optional: true,
                        listlimit: 3,
                        listcustom:false
                }).depends({'AI4':'1','AInput4Enable':'1','AInputBurstMode':'0'})
                .value('0', L.tr('Normal'))
                .value('1', L.tr('Multiply'))
                .value('2', L.tr('Scale'));
                
                 s.taboption('AI4',L.cbi.InputValue,'AInput4Transducermax',{ 
                        caption: L.tr('Transducer Max'),   
                }).depends({'AI4':'1','AInput4Enable':'1','AInputBurstMode':'0','AInput4MultiplicationFactorEnable':'2'});
  
				s.taboption('AI4',L.cbi.InputValue,'AInput4Transducermin',{ 
									caption: L.tr('Transducer Min'),   
							}).depends({'AI4':'1','AInput4Enable':'1','AInputBurstMode':'0','AInput4MultiplicationFactorEnable':'2'});
				
				s.taboption('AI4',L.cbi.InputValue,'AInput4Rawmax',{ 
									caption: L.tr('Raw Max'),   
							}).depends({'AI4':'1','AInput4Enable':'1','AInputBurstMode':'0','AInput4MultiplicationFactorEnable':'2'});
				
				s.taboption('AI4',L.cbi.InputValue,'AInput4Rawmin',{ 
									caption: L.tr('Raw Min'),   
							}).depends({'AI4':'1','AInput4Enable':'1','AInputBurstMode':'0','AInput4MultiplicationFactorEnable':'2'});
				
				s.taboption('AI4',L.cbi.CheckboxValue,'AInput4ClampEnable',{ 
						caption: L.tr('Clamp Values Enable'),   
						}).depends({'AI4':'1','AInput4Enable':'1','AInputBurstMode':'0','AInput4MultiplicationFactorEnable':'2'});
						
				s.taboption('AI4',L.cbi.InputValue,'AInput4ClampMax',{ 
				caption: L.tr('Clamp Max Value'),   
                }).depends({'AI4':'1','AInput4Enable':'1','AInputBurstMode':'0','AInput4MultiplicationFactorEnable':'2','AInput4ClampEnable':'1'});
  
                 s.taboption('AI4',L.cbi.InputValue,'AInput4ClampMin',{ 
                        caption: L.tr('Clamp Min Value'),   
                }).depends({'AI4':'1','AInput4Enable':'1','AInputBurstMode':'0','AInput4MultiplicationFactorEnable':'2','AInput4ClampEnable':'1'});
  		  
                
				s.taboption('AI4',L.cbi.InputValue,'AInput4MultiplicationFactor',{ 
                        caption: L.tr('MultiplicationFactor'),   
                }).depends({'AI4':'1','AInput4Enable':'1','AInputBurstMode':'0','AInput4MultiplicationFactorEnable':'1'});
  

           
                s.taboption('AI4',L.cbi.CheckboxValue,'AInput4AlarmActiveState',{ 
                        caption: L.tr('Alarm Enable'),   
                }).depends({'AI4':'1','AInput4Enable':'1','AInputBurstMode':'0'});

                  
               s.taboption('AI4',L.cbi.CheckboxValue,'AI4UpperThresholdEnable',{ 
                        caption: L.tr('Upper Threshold Enable'),   
                }).depends({'AI4':'1','AInput4Enable':'1','AInputBurstMode':'0'});
  
               s.taboption('AI4',L.cbi.InputValue,'AI4UpperThresholdName',{ 
                        caption: L.tr('Upper Threshold Name'),   
                }).depends({'AI4':'1','AInput4Enable':'1','AInputBurstMode':'0','AI4UpperThresholdEnable':'1'});
  
                  
                  
                s.taboption('AI4',L.cbi.InputValue, 'AInput4UpperThreshold', {
                        caption: L.tr('Upper Threshold Level'),
                        datatype:'rt_float'
                }).depends({'AInput4Enable':'1','AInputBurstMode':'0','AInput4AlarmActiveState':'1','AI4UpperThresholdEnable':'1'});  
                
                s.taboption('AI4',L.cbi.InputValue, 'AInput4UpperHysteresis', {
                        caption: L.tr('Upper Hysteresis'),
                        datatype:'rt_float'
                }).depends({'AInput4Enable':'1','AInputBurstMode':'0','AInput4AlarmActiveState':'1','AI4UpperThresholdEnable':'1'});
                
                
                     
               s.taboption('AI4',L.cbi.CheckboxValue,'AI4LowerThresholdEnable',{ 
                        caption: L.tr('Lower Threshold Enable'),   
                }).depends({'AI4':'1','AInput4Enable':'1','AInputBurstMode':'0'});
  
                
               s.taboption('AI4',L.cbi.InputValue,'AI4LowerThresholdName',{ 
                        caption: L.tr('Lower Threshold Name'),   
                }).depends({'AI4':'1','AInput4Enable':'1','AInputBurstMode':'0','AI4LowerThresholdEnable':'1'});
  
                
                s.taboption('AI4',L.cbi.InputValue, 'AInput4LowerThreshold', {
                        caption: L.tr('Lower Threshold Level'),
                        datatype:'rt_float'
                }).depends({'AInput4Enable':'1','AInputBurstMode':'0','AInput4AlarmActiveState':'1','AI4LowerThresholdEnable':'1'}); 
                
                s.taboption('AI4',L.cbi.InputValue, 'AInput4LowerHysteresis', {
                        caption: L.tr('Lower Hysteresis'),
                        datatype:'rt_float'
                }).depends({'AInput4Enable':'1','AInputBurstMode':'0','AInput4AlarmActiveState':'1','AI4LowerThresholdEnable':'1'});   
               
                s.taboption('AI4',L.cbi.CheckboxValue, 'AInput4TimeDependency', {
                 caption: L.tr('Time Dependency'),
                 }).depends({'AInput4Enable':'1','AInputBurstMode':'0','AInput4AlarmActiveState':'1'});
               
               s.taboption('AI4',L.cbi.InputValue,'AInput4AlarmStartTime',{
                        caption: L.tr('Alarm Start Time'),
                        datatype: 'rt_time_hh_mm_ss',   
                }).depends({'AInput4Enable':'1','AInput4TimeDependency':'1','AInputBurstMode':'0','AInput4AlarmActiveState':'1'});
                
               s.taboption('AI4',L.cbi.InputValue,'AInput4AlarmStopTime',{
                        caption: L.tr('Alarm Stop Time'),
                         datatype: 'rt_time_hh_mm_ss',   
                }).depends({'AInput4Enable':'1','AInput4TimeDependency':'1','AInputBurstMode':'0','AInput4AlarmActiveState':'1'}); 
                
				s.taboption('AI4', L.cbi.CheckboxValue,'AInput4DayDependency', {
                        caption: L.tr('Day Dependency'),
                        optional: true
                }).depends({'AInput4Enable':'1','AInputBurstMode':'0','AInput4AlarmActiveState':'1'});
			
                s.taboption('AI4', L.cbi.ListValue,'AInput4DayDependencyValue', {
                        caption: L.tr('Weekly Holidays'),
                        optional: true,
                        listlimit: 7,
                        listcustom:false
                }).depends({'AInput4Enable':'1','AInput4DayDependency':'1','AInputBurstMode':'0','AInput4AlarmActiveState':'1'})
                .value('0', L.tr('Monday'))
                .value('1', L.tr('Tuesday'))
                .value('2', L.tr('Wednesday'))
                .value('3', L.tr('Thursday'))
                .value('4', L.tr('Friday'))
                .value('5',L.tr('Saturday'))
                .value('6', L.tr('Sunday'));
                
       //s.commit=function(){      
                        //self.fGetUCISections('analoginputconfig','analoginputconfig').then(function(rv) {  
                        //self.updateinterfaceconfig('Update','updateinterface').then(function(rv) {
                //});
            //});
                
			//} 
							 m.insertInto('#map');
var self = this; // Assign `this` to `self` in the outer scope

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
                
        }
})


