L.ui.view.extend({
    title: L.tr('Router Software Install-Uninstall'),
    
	installapp: L.rpc.declare({
		object: 'rpc-routerswinstalluninstall',
		method: 'install',
		expect: { output: '' }
	}),
 
    uninstallapp: L.rpc.declare({
		object: 'rpc-routerswinstalluninstall',
		method: 'uninstall',
		expect: { output: '' }
	}),
	
    TestArchive: L.rpc.declare({
			object: 'rpc-applicationmanager',
			method: 'testarchive',
			params: ['archive'],
	}),
 
    GetUCISections: L.rpc.declare({
        object: 'uci',
        method: 'get',
        params: [ 'config', 'type' ],
        expect: { values: {} }
    }),
    
    InstalledVersion:  L.rpc.declare({
        object: 'rpc-upgradeversioninfo',
        method: 'installedversion',
    }),
    
     
    handleArchiveUpload : function() {
        var self = this;  
        L.ui.archiveUpload(
            L.tr('Archive Upload'),
            L.tr('Select the archive and click on "%s" button to proceed.').format(L.tr('Apply')), {
			    success: function(info) {
		          self.handleArchiveVerify(info);
		        }
			}
	    );
	},

	handleArchiveVerify : function(info)
	{
		var self = this;
        var checksumval = $('#checksum').val();
        var sizeval = $('#size').val();
        var archive=$('[name=filename]').val();
        
        if((checksumval == info.checksum) &&(sizeval == info.size)) {
			L.ui.loading(true);
            self.TestArchive(archive).then(function(TestArchiveOutput) {
			    L.ui.loading(false);
		    	L.ui.dialog(
						L.tr('TestArchive'), [
						$('<p />').text(L.tr('Success')),
						$('<pre />')
				
						.addClass('alert-success')
						.text("file uploaded successfully")	
					],{
							style: 'close',
							close: function() {
								location.reload();
							}
						}
			    );
				L.ui.loading(true);   
			    /*self.applicationmanagerupgrade('ReAPapps','upgrade').then(function(rv) { 
				    L.ui.loading(false);
					L.ui.dialog(
						L.tr('Upgrade Status'), [
						$('<p />').text(L.tr('Status')),
						$('<pre />')
						.addClass('alert-success')
						.text(rv)
					    ],{
							style: 'close',
							close: function() {
								location.reload();
							}
						}
				    );
				});*/
		    });
		}
        else
	    {  
	        if((checksumval != info.checksum) &&(sizeval != info.size)) {
	                RPCErrorMsg="Archive checksum and size verification failed";
	        }
	        else if(checksumval != info.checksum) {
	                RPCErrorMsg="Archive Checksum verification failed";
	        }
	        else if(sizeval != info.size) {
	                RPCErrorMsg="Archive size verification failed";
	        }
	        
			L.ui.dialog(
				L.tr('verification failed'), [
					$('<p />').text(L.tr('Please enter the valid checksum and size!')),
					$('<pre />')
					.addClass('alert-danger')
					.text(RPCErrorMsg),
				], {
					style: 'close',
					close: function() {
						location.reload();
					}
				}
			);
		}
        
	},
	
    InstalledPkgsRenderContents : function(rv) {
        var self = this;
        var heading=$('<h3/>', {
            text: 'Installed Package:'
        });
        
        var list = new L.ui.table({
            columns: [
                {
                    caption: L.tr('Package'),
                    width:'50%',
                    align: 'left',
                    format: function(v,n) {
                        var div = $('<p />').attr('id', 'packageName_%s'.format(n));
                        return div.append('<strong>'+v+'</strong>');
                    }
                },{
                    caption: L.tr('Version'),
                    align: 'left',
                    width:'50%',
                    format: function(v, n) {
                        var div = $('<small />').attr('id', 'package_date_%s'.format(n));
                        return div.append(v);
                    }
                }
            ]
        });

       var firmwareversion=rv['FirmwareVersion'];
        FirmwareReleasedVersion=firmwareversion.ReleasedVersion;
        
        var ipkversion=rv['IPKVersion'];
       // var ipkversion=parseFloat(1.10);
        
        IPKReleasedVersion=ipkversion.ReleasedVersion;
        
        list.row([' Application',  FirmwareReleasedVersion]);
        list.row([' IPK',   IPKReleasedVersion]);
       
         
        
        $('#map')
		.append(heading)
		.append(list.render());
    },
    
    
    execute : function() {
        var self = this;

	    $('#btn_upload').click(function() {
		    var checksumval = $('#checksum').val();
            var sizeval = $('#size').val();
            
            self.GetUCISections("applist_config","command").then(function(rv) {
                var obj = rv["appconfig"];
                if ((typeof rv === "undefined") || (typeof obj === "undefined" )) {
                    if((checksumval=="") && (sizeval=="")) {
                        alert("Please enter the valid checksum and size");
                    }
                    else if(checksumval=="") {
                        alert("Please enter the checksum");
                    }
                    else if(sizeval=="") {
                        alert("Please enter the size");
                    }
                    else {
                        self.handleArchiveUpload();
                    }
                }
                else {
                    var obj = rv["appconfig"];
                    var AppRunning = obj.running;
                
                    if (AppRunning == 1) {
                        alert("Please stop the applications before upgrading");
                        return ;
                    }
                    else {
                        if((checksumval=="") && (sizeval=="")) {
                            alert("Please enter the valid checksum and size");
                        }
                        else if(checksumval=="") {
                            alert("Please enter the checksum");
                        }
                        else if(sizeval=="") {
                            alert("Please enter the size");
                        }
                        else {
                            self.handleArchiveUpload();
                        }
                    }
                }
            });
        });
   

        
        //self.InstalledVersion().then(function(rv) {
           // self.InstalledPkgsRenderContents(rv); 
			self.GetUCISections("applist_config","command").then(function(rv){
				for(var key in rv) {
					if(rv.hasOwnProperty(key)) {
						var obj=rv[key];
						var AppStatus=obj.running;
						if (AppStatus != 0) {
							var ErrorMsg="Please stop the applications before upgrading";
							$("#UploadDiv").empty().show();
							$("#UploadDiv").append(ErrorMsg);
						}
						else {
						    $("#UploadDiv").show();
						}
					}
				}
			});     
	 //   });
	 
	 //Install Button
	 $('#btn_install').click(function() {
            L.ui.loading(true);
            self.installapp('install').then(function(rv) {
				//alert(rv);
                L.ui.loading(false);
                    L.ui.dialog(
                        L.tr('Install Software'),[
                            $('<pre />')
                            .addClass('alert alert-success')
                            .text(rv)
                        ],
                        { style: 'close'}
                    );
                    
                   });
            });
     
     //Uninstall Button
     
      $('#btn_uninstall').click(function() {
            L.ui.loading(true);
            self.uninstallapp('uninstall').then(function(rv) {
				//alert(rv);
                L.ui.loading(false);
                    L.ui.dialog(
                        L.tr('Uninstall Software'),[
                            $('<pre />')
                            .addClass('alert alert-success')
                            .text(rv)
                        ],
                        { style: 'close'}
                    );
                    
                   });
            });
                   
            
            
            
	}
});
