L.ui.view.extend({
        title: L.tr('Application Manager'),

        applicationmanagerinit: L.rpc.declare({
                object: 'rpc-applicationmanager',
                method: 'init',
                params: ['application','action'],
                expect: { output: '' }
        }),

        applicationmanagerconfig: L.rpc.declare({
                object: 'rpc-applicationmanager',
                method: 'configure',
                params: ['application','action'],
                expect: { output: '' }
        }),
        
        InstalledVersion:  L.rpc.declare({
		        object: 'rpc-upgradeversioninfo',
		        method: 'installedversion',
        }),

        GetUCISections: L.rpc.declare({
                object: 'uci',
                method: 'get',
                params: [ 'config', 'type' ],
                expect: { values: {} }
        }),

        execute: function() {
                var self = this;
                
                self.GetUCISections("applist_config","command").then(function(rv) {
                        for (var key in rv) 
                        {
                                if (rv.hasOwnProperty(key)) 
                                {
                                        var obj = rv[key];
                                        var running = obj.running;
                                        if(running=='0')
                                        {
                                                var AppstartCreateButton=$('<button/>', {
                                                        class: 'btn btn-primary',
                                                        text: 'Start',
                                                        id: 'start',
                                                        title: 'Start the Apps',
                                                        style: 'width:110px',
                                                        on : {
                                                                click: function(e) {
                                                                        L.ui.loading(true);
                                                                        self.applicationmanagerinit('ReAPapps','start').then(function(rv) {
                                                                                L.ui.loading(false);
                                                                                L.ui.dialog(
                                                                                        L.tr('Started the app'),[
                                                                                               $('<p />').text(L.tr('Output')),
                                                                                                $('<pre />')
                                                                                                        .addClass('alert alert-info')
                                                                                                        .text(rv),
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
                                                             }
                                                });
                                                $("#btn-group").append(AppstartCreateButton);
                                        }
                                        
                                        if(running=='1')
                                        {
                                                var AppStopCreateButton=$('<button/>', {
                                                        class: 'btn btn-danger',
                                                        text: 'Stop',
                                                        title: 'Stop the Apps',
                                                        style: 'width:110px',
                                                        on : {
                                                                click: function(e) {
                                                                         L.ui.loading(true);
                                                                        self.applicationmanagerinit('ReAPapps','stop').then(function(rv) {
                                                                                L.ui.loading(false);
                                                                                L.ui.dialog(
                                                                                        L.tr('Stopped the app'),[
                                                                                                $('<pre />')
                                                                                                        .addClass('alert alert-danger')
                                                                                                        .text(rv),
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
                                                        }
                                                });
                                                $("#btn-group").append(AppStopCreateButton);
                                        }
                                }
                        }
                });
                
            self.GetUCISections("applist_config","command").then(function(rv){                                                    
	            for(var key in rv)                                                                                                      
	            {                                                                                                                       
	                if(rv.hasOwnProperty(key))                                                                                          
	                {                                                                                                                   
	                    var obj=rv[key];                                                                                                
	                    var AppStatus=obj.running;                                                                                      
		                    if (AppStatus != '0')                                                                                             
		                    {                                                                                                               
		                        var ErrorMsg="Stop Applications";                        
		                         $("#update").empty().show();                                                                    
		                         $("#update").append(ErrorMsg);                                                                   
		                    }                                                                                                               
	                        else                                                                                                            
	                        {                                                                                                           
			                    $('#update').click(function() {
			                        L.ui.loading(true);
			                        self.applicationmanagerconfig('ReAPapps','updateconfig').then(function(rv) {
			                                L.ui.loading(false);
			                                L.ui.dialog(
			                                        L.tr('update configuration'),[
			                                                $('<pre />')
	                                                        .addClass('alert alert-success')
	                                                        .text(rv)
			                                                ],
		                                                    { style: 'close'}
		                                    );
		                            });
		                        });
	                        }
	                }
	            }
            });
            
                $('#default').click(function() {
                        L.ui.loading(true);
                        self.applicationmanagerconfig('ReAPapps','defaultconfig').then(function(rv) {
                                L.ui.loading(false);
                                L.ui.dialog(
                                        L.tr('default configuration'),[
                                                $('<pre />')
                                                        .addClass('alert alert-success')
                                                        .text(rv)
                                        ],
                                        { style: 'close'}
                                );
                       });
                });

                $('#enable').click(function() {
                        L.ui.loading(true);
                        self.applicationmanagerinit('ReAPapps','enable').then(function(rv) {
                                L.ui.loading(false);
                                L.ui.dialog(
                                        L.tr('Enabled the app'),[
                                                $('<pre />')
                                                        .addClass('alert alert-success')
                                                        .text(rv)
                                        ],
                                        { style: 'close'}
                                );
                       });
                });

                $('#disable').click(function() {
                        L.ui.loading(true);
                        self.applicationmanagerinit('ReAPapps','disable').then(function(rv) {
                                L.ui.loading(false);
                                L.ui.dialog(
                                        L.tr('Disabled the app'),[
                                                $('<pre />')
                                                        .addClass('alert alert-warning')
                                                        .text(rv),
                                        ],
                                        { style: 'close'}
                                );
                       });
                });
              
                $('#restart').click(function() {
                        L.ui.loading(true);
                        self.applicationmanagerinit('ReAPapps','restart').then(function(rv) {
                                L.ui.loading(false);
                                L.ui.dialog(
                                        L.tr('Restarted the app'),[
                                                $('<pre />')
                                                        .addClass('alert alert-success')
                                                        .text(rv),
                                        ],
                                        { style: 'close'}
                                );
                       });
                });

                $('#reload').click(function() {
                        L.ui.loading(true);
                        self.applicationmanagerinit('ReAPapps','reload').then(function(rv) {
                                L.ui.loading(false);
                                L.ui.dialog(
                                        L.tr('Reloaded the app'),[
                                                $('<pre />')
                                                        .addClass('alert alert-info')
                                                        .text(rv),
                                        ],
                                        { style: 'close'}
                                );
                       });
                });
                //self.InstalledVersion().then(function(rv) {
                    //self.InstalledPkgsRenderContents(rv);
                //});
        },

        InstalledPkgsRenderContents : function(rv)
        {
                var self = this;

                var heading=$('<h3/>', {
                        text: 'Installed Package:'
                });

                var list = new L.ui.table({
					columns: [
                        {
							//caption: L.tr('Package'),
							width:'25%',
							align: 'left',
							format: function(v,n) {
									var div = $('<p />').attr('id', 'packageName_%s'.format(n));
									return div.append('<strong>'+v+'</strong>');
							}
                        },{
						//	caption: L.tr('Version'),
							align: 'left',
							width:'25%',
							format: function(v, n) {
									var div = $('<small />').attr('id', 'version_%s'.format(n));
									return div.append(v);
							}
                        }
					]
                });

				var firmwareversion=rv['FirmwareVersion'];
				FirmwareReleasedVersion=firmwareversion.ReleasedVersion;
		
		        var ipkversion=rv['IPKVersion'];
		        IPKReleasedVersion=ipkversion.ReleasedVersion;
		        
		       // list.row([' Application',  FirmwareReleasedVersion]);
		        list.row([' Package version',   IPKReleasedVersion]);
		        
		
		        $('#map')
				.append(heading)
				.append(list.render());
        },
});

