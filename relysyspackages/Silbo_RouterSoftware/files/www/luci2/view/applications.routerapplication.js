L.ui.view.extend({

    // title: L.tr('Monitor App'),
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
    
      updaterouterapplicationconfig: L.rpc.declare({
        object: 'rpc-updateRouterApplicationConfig',
        method: 'configure',
        params: ['application','action'],
        expect: { output: '' }
        }),
  
    execute:function() {
        var self = this;
        var m = new L.cbi.Map('routerapplicationconfig', {
        });
        
        var s = m.section(L.cbi.NamedSection, 'routerapplicationlocalconfig', {
            caption:L.tr('Modem Monitor Application Configuration')
        }); 
         
             
         s.option(L.cbi.CheckboxValue, 'enablerouterlocalpingapp', {
         caption: L.tr('Enable Ping Check Application'),
         });
          
		 s.option(L.cbi.InputValue, 'timeintervalforpingcheck', {
			caption: L.tr('Time Interval For Check (In minutes)'),
		}).depends({'enablerouterlocalpingapp':'1'});
		
	    //~ s.option( L.cbi.InputValue, 'ipaddress', {
		//~ caption: L.tr('IP Address'),
	    //~ datatype: 'ipaddr'
		//~ }).depends({'enablerouterlocalpingapp':'1'});
		
		s.option(L.cbi.ListValue, 'noofipaddress', {
            caption: L.tr('Select No of IPaddress to ping')
        }).depends({'enablerouterlocalpingapp':'1'})
	    .value("0",L.tr("Please select the option"))
	    .value("1",L.tr("1"))
	    .value("2",L.tr("2"))
		.value("3",L.tr("3"))
	    .value("4",L.tr("4"))
	    .value("5",L.tr("5"))
	    .value("6",L.tr("6"))
	    .value("7",L.tr("7"))
	    .value("8",L.tr("8"));       

        s.option(L.cbi.InputValue, 'ipaddress1', {
           caption: L.tr('IP address 1'),
		   optional: true,
        }).depends({'noofipaddress':'1','enablerouterlocalpingapp':'1'})
        .depends({'noofipaddress':'2','enablerouterlocalpingapp':'1'})
        .depends({'noofipaddress':'3','enablerouterlocalpingapp':'1'})
        .depends({'noofipaddress':'4','enablerouterlocalpingapp':'1'})
        .depends({'noofipaddress':'5','enablerouterlocalpingapp':'1'})
        .depends({'noofipaddress':'6','enablerouterlocalpingapp':'1'})
        .depends({'noofipaddress':'7','enablerouterlocalpingapp':'1'})
        .depends({'noofipaddress':'8','enablerouterlocalpingapp':'1'});  

	    s.option(L.cbi.InputValue, 'ipaddress2', {
           caption: L.tr('IP address 2'),
		   optional: true,
        }).depends({'noofipaddress':'2','enablerouterlocalpingapp':'1'})
        .depends({'noofipaddress':'3','enablerouterlocalpingapp':'1'})
        .depends({'noofipaddress':'4','enablerouterlocalpingapp':'1'})
        .depends({'noofipaddress':'5','enablerouterlocalpingapp':'1'})
        .depends({'noofipaddress':'6','enablerouterlocalpingapp':'1'})
        .depends({'noofipaddress':'7','enablerouterlocalpingapp':'1'})
        .depends({'noofipaddress':'8','enablerouterlocalpingapp':'1'});
                
        s.option(L.cbi.InputValue, 'ipaddress3', {
           caption: L.tr('IP address 3'),
		   optional: true,
        }).depends({'noofipaddress':'3','enablerouterlocalpingapp':'1'})
        .depends({'noofipaddress':'4','enablerouterlocalpingapp':'1'})
        .depends({'noofipaddress':'5','enablerouterlocalpingapp':'1'})
        .depends({'noofipaddress':'6','enablerouterlocalpingapp':'1'})
        .depends({'noofipaddress':'7','enablerouterlocalpingapp':'1'})
        .depends({'noofipaddress':'8','enablerouterlocalpingapp':'1'}); 

        s.option(L.cbi.InputValue, 'ipaddress4', {
           caption: L.tr('IP address 4'),
		   optional: true,
        }).depends({'noofipaddress':'4','enablerouterlocalpingapp':'1'})
        .depends({'noofipaddress':'5','enablerouterlocalpingapp':'1'})
        .depends({'noofipaddress':'6','enablerouterlocalpingapp':'1'})
        .depends({'noofipaddress':'7','enablerouterlocalpingapp':'1'})
        .depends({'noofipaddress':'8','enablerouterlocalpingapp':'1'});       

        s.option(L.cbi.InputValue, 'ipaddress5', {
           caption: L.tr('IP address 5'),
		   optional: true,
        }).depends({'noofipaddress':'5','enablerouterlocalpingapp':'1'})
        .depends({'noofipaddress':'6','enablerouterlocalpingapp':'1'})
        .depends({'noofipaddress':'7','enablerouterlocalpingapp':'1'})
        .depends({'noofipaddress':'8','enablerouterlocalpingapp':'1'});
                
        s.option(L.cbi.InputValue, 'ipaddress6', {
           caption: L.tr('IP address 6'),
		   optional: true,
        }).depends({'noofipaddress':'6','enablerouterlocalpingapp':'1'})
        .depends({'noofipaddress':'7','enablerouterlocalpingapp':'1'})
        .depends({'noofipaddress':'8','enablerouterlocalpingapp':'1'});
                
        s.option(L.cbi.InputValue, 'ipaddress7', {
           caption: L.tr('IP address 7'),
		   optional: true,
        }).depends({'noofipaddress':'7','enablerouterlocalpingapp':'1'})
        .depends({'noofipaddress':'8','enablerouterlocalpingapp':'1'});
                  
        s.option(L.cbi.InputValue, 'ipaddress8', {
           caption: L.tr('IP address 8'),
		   optional: true,
        }).depends({'noofipaddress':'8','enablerouterlocalpingapp':'1'});
		
		s.option( L.cbi.InputValue, 'noofretries', {
		caption: L.tr('No. of Retries'),
		}).depends({'enablerouterlocalpingapp':'1'});
		
		s.option( L.cbi.InputValue, 'failurecriteria', {
		caption: L.tr('Failure Criteria in (%)'),
	    }).depends({'enablerouterlocalpingapp':'1'}); 
	    
				s.option(L.cbi.ListValue, 'failureaction', {
				caption: L.tr('Action On Failure'),
		}).depends({'enablerouterlocalpingapp':'1'})
		.value("restart",L.tr("Restart Board"))
		.value("restartmodem",L.tr("Restart Modem"))
		.value("restartipsec",L.tr("Restart IPsec"));

           s.option(L.cbi.CheckboxValue, 'enablesecondlevel', {
	   caption: L.tr('Enable Second Level Action'),
	    });

		s.option( L.cbi.InputValue, 'secondlevelactionthreshold', {
		caption: L.tr('Second Level Action Threshold'),
		description: L.tr('Specify failure count of Router Ping Application to initiate second level action'),
		optional: true,
		}).depends({'enablesecondlevel':'1'});


		s.option(L.cbi.ListValue, 'secondlevelactiononfailure', {
		caption: L.tr('Second level Action'),
		}).depends({'enablesecondlevel':'1'})
		.value("restart",L.tr("Restart Board"));
		
		var r = m.section(L.cbi.NamedSection, 'routerapplicationRemoteconfig', {
            caption:L.tr('Router Monitor Application Configuration')
        }); 
         
             
        r.option(L.cbi.CheckboxValue, 'enablerouterremotepingapp', {
        caption: L.tr('Enable Router Remote Ping Check Application'),
        });
          
		r.option(L.cbi.InputValue, 'timeintervalforpingcheck', {
		caption: L.tr('Time Interval For Check (In minutes)'),
		}).depends({'enablerouterremotepingapp':'1'});
		
	    //~ r.option( L.cbi.InputValue, 'ipaddress', {
		//~ caption: L.tr('IP Address'),
	    //~ datatype: 'ipaddr'
		//~ }).depends({'enablerouterremotepingapp':'1'});
		
		r.option(L.cbi.ListValue, 'noofipaddress', {
            caption: L.tr('Select No of IPaddress to ping')
		}).depends({'enablerouterremotepingapp':'1'})
		  .value("0",L.tr("Please select the option"))
		  .value("1",L.tr("1"))
		  .value("2",L.tr("2"))
		  .value("3",L.tr("3"))
		  .value("4",L.tr("4"))
		  .value("5",L.tr("5"))
		  .value("6",L.tr("6"))
		  .value("7",L.tr("7"))
		  .value("8",L.tr("8"));       

		r.option(L.cbi.InputValue, 'ipaddress1', {
				caption: L.tr('IP address 1'),
				optional: true,
		}).depends({'noofipaddress':'1','enablerouterremotepingapp':'1'})
		  .depends({'noofipaddress':'2','enablerouterremotepingapp':'1'})
		  .depends({'noofipaddress':'3','enablerouterremotepingapp':'1'})
		  .depends({'noofipaddress':'4','enablerouterremotepingapp':'1'})
		  .depends({'noofipaddress':'5','enablerouterremotepingapp':'1'})
		  .depends({'noofipaddress':'6','enablerouterremotepingapp':'1'})
		  .depends({'noofipaddress':'7','enablerouterremotepingapp':'1'})
		  .depends({'noofipaddress':'8','enablerouterremotepingapp':'1'});  

		r.option(L.cbi.InputValue, 'ipaddress2', {
				caption: L.tr('IP address 2'),
				optional: true,
		}).depends({'noofipaddress':'2','enablerouterremotepingapp':'1'})
		  .depends({'noofipaddress':'3','enablerouterremotepingapp':'1'})
		  .depends({'noofipaddress':'4','enablerouterremotepingapp':'1'})
		  .depends({'noofipaddress':'5','enablerouterremotepingapp':'1'})
		  .depends({'noofipaddress':'6','enablerouterremotepingapp':'1'})
		  .depends({'noofipaddress':'7','enablerouterremotepingapp':'1'})
		  .depends({'noofipaddress':'8','enablerouterremotepingapp':'1'});
		
		r.option(L.cbi.InputValue, 'ipaddress3', {
				caption: L.tr('IP address 3'),
				optional: true,
		}).depends({'noofipaddress':'3','enablerouterremotepingapp':'1'})
		  .depends({'noofipaddress':'4','enablerouterremotepingapp':'1'})
		  .depends({'noofipaddress':'5','enablerouterremotepingapp':'1'})
		  .depends({'noofipaddress':'6','enablerouterremotepingapp':'1'})
		  .depends({'noofipaddress':'7','enablerouterremotepingapp':'1'})
		  .depends({'noofipaddress':'8','enablerouterremotepingapp':'1'}); 

		r.option(L.cbi.InputValue, 'ipaddress4', {
				caption: L.tr('IP address 4'),
				optional: true,
		}).depends({'noofipaddress':'4','enablerouterremotepingapp':'1'})
		  .depends({'noofipaddress':'5','enablerouterremotepingapp':'1'})
		  .depends({'noofipaddress':'6','enablerouterremotepingapp':'1'})
		  .depends({'noofipaddress':'7','enablerouterremotepingapp':'1'})
		  .depends({'noofipaddress':'8','enablerouterremotepingapp':'1'});       

		r.option(L.cbi.InputValue, 'ipaddress5', {
				caption: L.tr('IP address 5'),
				optional: true,
		}).depends({'noofipaddress':'5','enablerouterremotepingapp':'1'})
		  .depends({'noofipaddress':'6','enablerouterremotepingapp':'1'})
		  .depends({'noofipaddress':'7','enablerouterremotepingapp':'1'})
		  .depends({'noofipaddress':'8','enablerouterremotepingapp':'1'});
		
		r.option(L.cbi.InputValue, 'ipaddress6', {
				caption: L.tr('IP address 6'),
				optional: true,
		}).depends({'noofipaddress':'6','enablerouterremotepingapp':'1'})
		  .depends({'noofipaddress':'7','enablerouterremotepingapp':'1'})
		  .depends({'noofipaddress':'8','enablerouterremotepingapp':'1'});
		
		r.option(L.cbi.InputValue, 'ipaddress7', {
				caption: L.tr('IP address 7'),
				optional: true,
		}).depends({'noofipaddress':'7','enablerouterremotepingapp':'1'})
		  .depends({'noofipaddress':'8','enablerouterremotepingapp':'1'});
		  
		r.option(L.cbi.InputValue, 'ipaddress8', {
				caption: L.tr('IP address 8'),
				optional: true,
		}).depends({'noofipaddress':'8','enablerouterremotepingapp':'1'});
		
		r.option( L.cbi.InputValue, 'noofretries', {
		caption: L.tr('No. of Retries'),
		}).depends({'enablerouterremotepingapp':'1'});
		
		r.option( L.cbi.InputValue, 'failurecriteria', {
		caption: L.tr('Failure Criteria in (%)'),
	    }).depends({'enablerouterremotepingapp':'1'}); 
	    
		r.option(L.cbi.ListValue, 'failureaction', {
		caption: L.tr('Action On Failure'),
		}).depends({'enablerouterremotepingapp':'1'})
		.value("restart",L.tr("Restart Board"))
		.value("restartmodem",L.tr("Restart Modem"))
		.value("restartipsec",L.tr("Restart IPsec"));

           r.option(L.cbi.CheckboxValue, 'enablesecondlevel', {
	   caption: L.tr('Enable Second Level Action'),
	   });

			r.option( L.cbi.InputValue, 'secondlevelactionthreshold', {
			caption: L.tr('Second Level Action Threshold'),
			description: L.tr('Specify failure count of Router Ping Application to initiate second level action'),
			optional: true,
			}).depends({'enablesecondlevel':'1'});


			r.option(L.cbi.ListValue, 'secondlevelactiononfailure', {
			caption: L.tr('Second level Action'),
			}).depends({'enablesecondlevel':'1'})
			.value("restart",L.tr("Restart Board"));

               
       s.commit=function(){			
				self.updaterouterapplicationconfig('configure').then(function(rv) {              
                });
           }
           
       r.commit=function(){			
				self.updaterouterapplicationconfig('configure').then(function(rv) {              
                });
           }
                   
		                        
        return m.insertInto('#map');
    }
});
