L.ui.view.extend({

    title: L.tr('Cloud Configuration'),

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
    
    GetUCISections: L.rpc.declare({
                object: 'uci',
                method: 'get',
                params: [ 'config', 'type' ],
                expect: { values: {} }
        }),
    
	 deletekeyfile: L.rpc.declare({
	object: 'rpc-cloudconfig',
	method: 'delete',
	expect: { output: '' }
	}),
	
    countcertficates: L.rpc.declare({
		object: 'rpc-cloudconfig',
		method: 'countkeyfiles',
		expect: { output: '' }
	 }),
    
	updatecloudconfig: L.rpc.declare({
	object: 'rpc-cloudconfig',
	method: 'configure',
	params: ['application','action'],
	expect: { output: '' }
	}),
        
	updatenmsdisableconfig: L.rpc.declare({
	object: 'rpc-cloudconfig',
	method: 'update',
	params: ['application','action'],
	expect: { output: '' }
	}),
	
	countkeys: L.rpc.declare({
	object: 'rpc-cloudconfig',
	method: 'countkeyfiles',
	expect: { output: '' }
    }),
        
	TestArchive: L.rpc.declare({
	object: 'rpc-cloudconfig',
	method: 'testarchive',
	params: ['archive'],
    }),
   
    GetUCISections: L.rpc.declare({
    object: 'uci',
    method: 'get',
    params: [ 'config', 'type' ],
    expect: { values: {} }
    }),

      
     handleArchiveUpload : function() {
        var self = this;  
        L.ui.archiveUploadcertstls(
            L.tr('File Upload'),
            L.tr('Select the file and click on "%s" button to proceed.').format(L.tr('Apply')), {
			    success: function(info) {
		        self.handleArchiveVerify(info);
		        }
			}
	    );
	},

	handleArchiveVerify : function(info)
	{
		var self = this;
              var archive=$('[name=filename]').val();
        
       // if((checksumval == info.checksum) &&(sizeval == info.size)) {
			L.ui.loading(true);
            self.TestArchive(archive).then(function(TestArchiveOutput) {
				    
		    	L.ui.dialog(
						L.tr('TestArchive'), [
						$('<p />').text(L.tr('Success')),
						$('<pre />')
						.addClass('alert-success')
						.text("file uploaded successfully")	
					],{
							style: 'close',
							
						}
			    );
				L.ui.loading(false);   
		    });
		//}
               
	},


   
    execute:function() {
        var self = this;
        var m = new L.cbi.Map('cloudconfig', {
        });
        
        var s = m.section(L.cbi.NamedSection, 'cloudconfig', {
            caption:L.tr('Cloud Configuration')
        }); 
    

                s.option(L.cbi.InputValue,'SiteID',{
                    caption: L.tr('Site ID'),
                });
						
	            s.option(L.cbi.ListValue, 'cloudprotocol', {
				 caption:     L.tr('Cloud / Protocol'),
				}).value("http", L.tr('HTTP'))
				  .value("mqtt", L.tr('MQTT'))	
				  .value("azure", L.tr('Azure'));	
				  
				/* Azure */  
				  
				s.option(L.cbi.ListValue, 'Selectprotocol', {
				 caption:     L.tr('Protocol'),
                       
                }).depends({'cloudprotocol':'azure'})
				  .value("MQTT_Protocol", L.tr('MQTT'))
				  .value("HTTP_Protocol", L.tr('HTTP'));
				  
                
                s.option(L.cbi.InputValue,'connectionstring',{
                       caption: L.tr('Connection String'),

                }).depends({'cloudprotocol':'azure'});
				  
				  /* HTTP */
                
                s.option(L.cbi.InputValue,'HTTPServerURL',{
                       caption: L.tr('HTTP URL'),
                       
                }).depends({'cloudprotocol':'http'});
                
                s.option(L.cbi.InputValue,'HTTPServerPort',{
                       caption: L.tr('HTTP Port (Optional)'),
                       optional:      'true',
                }).depends({'cloudprotocol':'http'});
               
                s.option(L.cbi.ListValue, 'httpauthenable', {
				 caption:     L.tr('Enable Authentication'),
				}).depends({'cloudprotocol':'http'})
				  .value("0", L.tr('No Authentication'))
				  .value("1", L.tr('Username/Password'))
				  .value("2", L.tr('Bearer Token'));
               
                s.option(L.cbi.InputValue,'username',{
                       caption: L.tr('Username'),                       
                }).depends({'cloudprotocol':'http','httpauthenable':'1'});
                
                s.option(L.cbi.PasswordValue,'password',{
                       caption: L.tr('Password'),                       
                }).depends({'cloudprotocol':'http','httpauthenable':'1'});
                
                  s.option(L.cbi.InputValue,'entertoken',{
                     caption: L.tr('Token'),                       
                }).depends({'cloudprotocol':'http','httpauthenable':'2'});
                
                 s.option( L.cbi.CheckboxValue, 'serverresponsevalidationenable', {
                 caption: L.tr('Enable Server Response Validation')
                 }).depends({'cloudprotocol':'http'});
               
                 s.option(L.cbi.ComboBox, 'serverresponsestring', {
				 caption:     L.tr('Server Response'),
			    }).depends({'cloudprotocol':'http','serverresponsevalidationenable':'1'})
				  .value("none", L.tr('--please choose--'))
				  .value("Recordid", L.tr('RecordID'));
				  
			     s.option(L.cbi.ListValue, 'HTTPMethod', {
				 caption:     L.tr('Method'),
				}).depends({'cloudprotocol':'http'})
				  .value("0", L.tr('Post'))
				  .value("1", L.tr('Get'));	  
             
          
       /* MQTT */
         
             
              s.option(L.cbi.InputValue,'host',{
                       caption: L.tr('MQTT Host'),
                       
              }).depends({'cloudprotocol':'mqtt'});
              
               s.option(L.cbi.InputValue,'mqttport',{
                       caption: L.tr('MQTT Port'),
                       optional:      'true',
                }).depends({'cloudprotocol':'mqtt'});
                
               s.option(L.cbi.ListValue, 'mqttauthmode', {
				 caption:     L.tr('Authentication Mode'),
				}).depends({'cloudprotocol':'mqtt'})
				  .value("3", L.tr('No Authentication'))
				  .value("2", L.tr('Username/Password'))
                  .value("1", L.tr('User Name & Password with CA certificate'))
				  .value("0", L.tr('TLS'));	  
               
                  s.option(L.cbi.InputValue, 'mqttusername', {
                    caption: L.tr('Username'),
                }).depends({'cloudprotocol': 'mqtt', 'mqttauthmode': '1'})
                  .depends({'cloudprotocol': 'mqtt', 'mqttauthmode': '2'});
                
                s.option(L.cbi.PasswordValue, 'mqttpassword', {
                    caption: L.tr('Password'),
                }).depends({'cloudprotocol': 'mqtt', 'mqttauthmode': '1'})
                  .depends({'cloudprotocol': 'mqtt', 'mqttauthmode': '2'});

                 s.option( L.cbi.CheckboxValue, 'enablepublishoverlan', {
                 caption: L.tr('Enable Publish Over LAN')
                 }).depends({'cloudprotocol':'mqtt'});
            

self.GetUCISections("sourceconfig", "sourceconfig").then(function(rv) {
    for (var key in rv) {
        if (rv.hasOwnProperty(key)) {
            var obj = rv[key]; 
            

        

        if (obj.EMeterRS485Line1DataSourceEnable === '1') {
            enablers485 = true;
        }

        if (obj.EMeterRS232Line1DataSourceEnable === '1') {
            enablers232 = true;
        }
         if (obj.AIODataSourceEnable === '1') {
            enableaio = true;
        }
         if (obj.DIODataSourceEnable === '1') {
            enabledio = true;
        }
        if (obj.TEMPERATUREDataSourceEnable === '1') {
            enabletemperature = true;
        }
    }
}

	
});	
        
               
               
    self.GetUCISections("sourceconfig", "sourceconfig").then(function(rv) {
    
    
    for (var key in rv) {
        if (rv.hasOwnProperty(key)) {
            var obj = rv[key];
            var rs485enable = obj.EMeterRS485Line1DataSourceEnable;
            var rs232enable = obj.EMeterRS232Line1DataSourceEnable;
            var aioenable = obj.AIODataSourceEnable;
            var dioenable = obj.DIODataSourceEnable;
            var temperatureenable = obj.TEMPERATUREDataSourceEnable;
            
            var depends = {'cloudprotocol': 'mqtt'};

            if (rs485enable === '1') {
                depends['EMeterRS485Line1DataSourceEnable'] = '1';
                s.option(L.cbi.InputValue, 'rs485topic', {
                    caption: L.tr('RS485 Topic (Optional)'),
                    optional:      'true',
                    datatype: 'string',
                }).depends(depends);
            }

            if (rs232enable === '1') {
                depends['EMeterRS232Line1DataSourceEnable'] = '1';
                s.option(L.cbi.InputValue, 'rs232topic', {
                    caption: L.tr('RS232 Topic (Optional)'),
                    optional:      'true',
                    datatype: 'string',
                }).depends(depends);
            }

            
            if (aioenable === '1') {
                 depends['AIODataSourceEnable'] = '1';
                s.option(L.cbi.InputValue, 'aiotopic', {
                    caption: L.tr('AIO Topic (Optional)'),
                    optional:      'true',
                    datatype: 'string',
                }).depends(depends);
            }
            
             if (dioenable === '1') {
                 depends['DIODataSourceEnable'] = '1';
                s.option(L.cbi.InputValue, 'diotopic', {
                    caption: L.tr('DIO Topic (Optional)'),
                    optional:      'true',
                    datatype: 'string',
                }).depends(depends);
            }
            
            if (temperatureenable === '1') {
                depends['TEMPERATUREDataSourceEnable'] = '1';
                s.option(L.cbi.InputValue, 'temperaturetopic', {
                    caption: L.tr('Temperature Topic (Optional)'),
                    optional:      'true',
                    datatype: 'string',
                }).depends(depends);
            }
            
             s.option(L.cbi.InputValue, 'commandrequesttopic', {
                    caption: L.tr('Command Request Topic (Optional)'),
                    optional:      'true',
                    datatype: 'string',
                }).depends(depends);
                
             s.option(L.cbi.InputValue, 'commandresponsetopic', {
                    caption: L.tr('Command Response Topic (Optional)'),
                    optional:      'true',
                    datatype: 'string',
                }).depends(depends);    
           
        }
    }
});
           
  	
       /* Added for testing */
       
           self.GetUCISections("cloudconfig","cloudconfig").then(function(rv) {
                        for (var key in rv) 
                        {
                                if (rv.hasOwnProperty(key)) 
                                {
                                        var obj = rv[key];
                                        var enabletls = obj.mqttauthmode;
                                        var cloudprotocol = obj.cloudprotocol
                                        if(cloudprotocol == 'mqtt')
                                        { 
	                                        if(enabletls == '2' || enabletls == '3')
	                                        {
	                                               var ErrorMsg="TLS & CA not selected";                        
			                                        $("#btn_upload").empty().show();                                                                    
			                                        $("#btn_upload").append(ErrorMsg);
			                                        
			                                        $("#btn_delete").empty().show();                                                                    
			                                        $("#btn_delete").append(ErrorMsg);
			                                                                                             
	                                        }
	                                        
										if(enabletls == '0' || enabletls == '1')
										{
													$('#btn_upload').click(function() {													
																 //self.handleArchiveUpload();
																 
													self.countcertficates().then(function(rv) {
							
						
						
												//alert(rv);
												var count = '1';
												 if(rv < '1')
												 {
													 $('#btn_upload').click(function() {													
														self.handleArchiveUpload();																		
										            });	
												  }
												  else 
												  {
													 L.ui.loading(false);
														L.ui.dialog(
							
																L.tr('Upload Certificates error'),[
																	   $('<p />').text(L.tr('Output')),
																		$('<pre />')
																				.addClass('alert alert-danger')
																				.text("Please click on Delete button to delete existing files and then click on upload button"),
																],
																{ style: 'close',
																		close:function()
																		{
																				location.reload();
																		}
																}
														); 
														
														
														
													}
							
												});																			
										            });	
										            
													
		                                                                                  
		                                        }
	                                    }
	                                   else
	                                   {
										   var ErrorMsg="Invalid Config";                        
			                               $("#btn_upload").empty().show();                                                                    
			                               $("#btn_upload").append(ErrorMsg);
			                                
			                               $("#btn_delete").empty().show();                                                                    
			                               $("#btn_delete").append(ErrorMsg); 
									   }     
                                }
                        }
                });
            
            
            /* Test purpose end */
             
             $('#btn_delete').click(function() 
             {
				self.GetUCISections("cloudconfig","cloudconfig").then(function(rv) {
				for (var key in rv) 
				{
						if (rv.hasOwnProperty(key)) 
						{
							var obj = rv[key];
							var enabledelete = obj.enabledelete;
							var cloudprotocol = obj.cloudprotocol
							var mqttauthmode = obj.mqttauthmode;
							//alert(enabledelete);
							//alert(cloudprotocol);
							
							if(cloudprotocol == 'mqtt' && enabledelete == '1' || mqttauthmode == '0')
							{  
				 			    self.deletekeyfile().then(function(rv) {
									//alert(rv);
																				
											L.ui.loading(false);
											L.ui.dialog(
				
													L.tr('Delete certificates'),[
														   $('<p />').text(L.tr('Output')),
															$('<pre />')
																	.addClass('alert alert-info')
																	.text("certificates Deleted"),
													],
													{ style: 'close',
															close:function()
															{
																	location.reload();
															}
													}
											);
								 });
							}
							else
							{
								var ErrorMsg="Invalid Config";                        
                                $("#btn_upload").empty().show();                                                                    
                                $("#btn_upload").append(ErrorMsg);
                                
                                $("#btn_delete").empty().show();                                                                    
                                $("#btn_delete").append(ErrorMsg); 
							}
						}
					}																
		    });	
          });     
                  		     		
       return m.insertInto('#map');
    }
    
   
});               
