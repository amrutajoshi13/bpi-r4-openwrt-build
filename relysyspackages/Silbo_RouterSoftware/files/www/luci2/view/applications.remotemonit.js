L.ui.view.extend({

        //  title: L.tr('Remote Management System'),
      RunUdev:L.rpc.declare({
        object:'command',
        method:'exec',
        params : ['command','args'],
    }),
    
    
     fGetUCISections: L.rpc.declare({
        object: 'uci',
        method: 'get',
        params: [ 'config', 'type']  
       
    }),
    
    
    ////////////////////////////////////////
    
        GetUCISections: L.rpc.declare({
                object: 'uci',
                method: 'get',
                params: [ 'config', 'type' ],
                expect: { values: {} }
        }),
        
        
        nmsGetUCISections: L.rpc.declare({
                object: 'uci',
                method: 'get',
                params: ['config', 'type'],
                expect: { values: {} }
        }),   
    
        deletekeyfile: L.rpc.declare({
		object: 'rpc-updateremoteconfig',
		method: 'delete',
		expect: { output: '' }
	}),
	
	countkeyfiles: L.rpc.declare({
		object: 'rpc-updateremoteconfig',
		method: 'countkeyfiles',
		expect: { output: '' }
	}),
    
        updateinterfaceconfig: L.rpc.declare({
                object: 'rpc-updateremoteconfig',
                method: 'configure',
                params: ['application','action'],
                expect: { output: '' }
        }),
                
        updatetrconfig: L.rpc.declare({
                object: 'rpc-updateremoteconfig',
                method: 'trconfigure',
                params: ['application','action'],
                expect: { output: '' }
        }),
        
        updatenmsdisableconfig: L.rpc.declare({
                object: 'rpc-updateremoteconfig',
                method: 'update',
                params: ['application','action'],
                expect: { output: '' }
        }),
        
        updatenmsstatusconfig: L.rpc.declare({
                object: 'rpc-updateremoteconfig',
                method: 'configurestatus',
                params: ['application','action'],
                expect: { output: '' }
	}),

        
        countkeys: L.rpc.declare({
		object: 'updateremoteconfig',
		method: 'countkeyfiles',
		expect: { output: '' }
	}),
        
	TestArchive: L.rpc.declare({
                object: 'rpc-updateremoteconfig',
                method: 'testarchive',
                params: ['archive'],
        }),

        TestArchive: L.rpc.declare({
                object: 'rpc-updateremoteconfig',
                method: 'testarchive',
                params: ['archive'],
	}),
        
        handleArchiveUpload : function() {
        var self = this;  
        L.ui.archiveUpload(
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
	       L.ui.loading(true);
                self.TestArchive(archive).then(function(TestArchiveOutput) {
				
		       self.updateinterfaceconfig('configure').then(function (rv) {

                        });
                        L.ui.dialog(false)
                        L.ui.showAlert(
                                'success',
                                'Certificate Upload',
                                'NMS Certificate uploaded successfully'
                        );
                        L.ui.loading(false); 
		});
                localStorage.removeItem('nmsinfo');

                const now = new Date();
                const FileName = archive.split('/').pop();
                const formatted = now.toLocaleString();
                const nms_info = `File name- ${FileName}<br> Date- ${formatted}`;
                localStorage.setItem('nmsinfo', nms_info);
                $('#last-upload').html(nms_info);       

	},
	
		
        NMSStatusRenderContents: function (rv) {

                var self = this;

                var tableContainer = $('#section_routing_status');
                var noteContainer  = $('#NMS-Note'); // icon section always visible
                tableContainer.empty(); // clear old table
                // var heading = $('<div />')
                //         .addClass('cbi-section-title')
                //         .text(L.tr('NMS Overview'));
                //         tableContainer.append(heading);

                var len = Object.keys(rv).length;
                        
                if (len === 0) {
                        var list = new L.ui.table({
                        columns: [
                                {
                                caption: '',
                                width: '100%',
                                align: 'center',
                                format: function(v,n) {
                                        return $('<span />').text(L.tr('No NMS Overview configurations found. Please add a configuration to get started.')).css({
                                        'font-style': 'italic',
                                        'color': '#999',
                                        'display': 'block',
                                        'text-align': 'center'
                                        });
                                }
                                }
                        ]
                        });
                        list.row(['']); 
                        tableContainer.append(list.render());
                } else {
                        var list = new L.ui.table({
                                columns: [
                                        {
                                                caption: L.tr('RMS'),
                                                width: '14%',
                                                align: 'left',
                                                format: function (v, n) {
                                                        var div = $('<p />').attr('id', 'NMSNeighbor_%s'.format(n));
                                                        return div.append('<strong>' + v + '</strong>');
                                                }
                                        },
                                        {
                                                caption: L.tr('Interface Name'),
                                                width: '20%',
                                                align: 'left',
                                                format: function (v, n) {
                                                        var div = $('<p />').attr('id', 'NMSUptime_%s'.format(n));
                                                        return div.append(v);
                                                }
                                        },
                                        {
                                                caption: L.tr('Status'),
                                                width: '20%',
                                                align: 'left',
                                                format: function (v, n) {
                                                        var div = $('<p />').attr('id', 'NMSTime_%s'.format(n));
                                                        // return div.append('<strong>' + v + '</strong>');
                                                        return div.append(v);
                                                }
                                        },
                                        {
                                                caption: L.tr('IP Address'),
                                                width: '20%',
                                                align: 'left',
                                                format: function (v, n) {
                                                        var div = $('<p />').attr('id', 'NMSLocalAS_%s'.format(n));
                                                        return div.append(v);
                                                }
                                        },
                                        {
                                                caption: L.tr('Uptime'),
                                                width: '20%',
                                                align: 'left',
                                                format: function (v, n) {
                                                        var div = $('<p />').attr('id', 'NMSConnectTime_%s'.format(n));
                                                        return div.append(v);
                                                }
                                        },
                                ]
                        });

                        for (var key in rv) {
                                        if (rv.hasOwnProperty(key)) {
                                                var obj = rv[key];
                                                var name = obj.name;
                                                var status = obj.status;
                                                var trackingstatus = obj.trackingstatus;
                                                var ipaddress =obj.ipaddress
                                                var uptime = obj.time;

                                                var INV;

                                                if (status === "online") {
                                                        INV = `<div style="border-radius: 5px; border: 2px solid #90EE90; border-left: 7px solid green; padding-left: 9px; width: 74px;">
                                                                                <b>Online</b><br />
                                                                                </div>`;
                                                }
                                                else if (status === "offline") {
                                                        INV = `<div style="border-radius: 5px; border: 2px solid #FF6B6B; border-left: 7px solid red; padding-left: 9px; width: 74px;">
                                                                                        <b>Offline</b><br />
                                                                                        </div>`;
                                                }
                                                else if (status === "error") {
                                                        INV = `<div style="border-radius: 5px; border: 2px solid #ffbc41; border-left: 7px solid #ffbc41; padding-left: 9px; width: 74px;">
                                                                                <b>Error</b><br />
                                                                                </div>`;
                                                }
                                                else if (status === "disabled") {
                                                        INV = `<div style="border-radius: 5px; border: 2px solid #FF6B6B; border-left: 7px solid red; padding-left: 9px; width: 74px;">
                                                                                <b>Disabled</b><br />
                                                                                </div>`;
                                                }



                                                list.row([name,trackingstatus, INV, ipaddress,uptime, key]);

                                        }
                        }
                        
                        tableContainer.append(list.render()); 
                }         
        },


        execute:function()
        {
			
                var self = this;
                const info = localStorage.getItem('nmsinfo')
                        $('#last-upload').html(info);
                var m = new L.cbi.Map('remoteconfig', {
                });
        
				
                var s = m.section(L.cbi.NamedSection, 'general', {
		                caption: L.tr('Remote Management System')
		        });
				
		       var o_rms = s.option(L.cbi.ListValue, 'rmsoption', {
				    caption: L.tr('Choose the RMS')
				});
				
				o_rms.value("none", "None");
				o_rms.value("tr069", "TR-069");
				o_rms.value("nms", "NMS");
		
		      m.handleSave = function(ev) {

				var rms = o_rms.formvalue('general');
				console.log("Selected RMS:", rms);
				
				    var nms_enable = L.uci.get('remoteconfig', 'nms', 'nmsenable') || "0";
				    console.log("nms_enable",nms_enable);
				    var tr_enable  = L.uci.get('remoteconfig', 'tr069', 'trenable') || "0";
				    console.log("tr_enable",tr_enable);
				
				    if (rms === "tr069" && nms_enable === "1") {
				        L.ui.showAlert(
				            'error',
				            'Configuration Error',
				            'NMS is already enabled. Disable it before selecting TR-069.'
				        );
				         setTimeout(function () {
                                location.reload(true);
                        }, 5000)
				        return;
				    }
				
				    if (rms === "nms" && tr_enable === "1") {
				        L.ui.showAlert(
				            'error',
				            'Configuration Error',
				            'TR-069 is already enabled. Disable it before selecting NMS.'
				        );
				         setTimeout(function () {
                                location.reload(true);
                        }, 5000)
				        return;
				    }
				
				    return L.cbi.Map.prototype.handleSave.apply(this, [ev]);
				};
		
		        m.insertInto('#section_vpn_general');  
       
                var m1 = new L.cbi.Map('remoteconfig', {
                                                        });
                
                var s1 = m1.section(L.cbi.NamedSection, 'tr069', {
                  caption: L.tr('TR-069 Configurations')
                });
                        
                s1.option(L.cbi.CheckboxValue, 'trenable', {
                        caption: L.tr('Enable TR-069'),
                        optional: true
                        });
                                        
                s1.option(L.cbi.CheckboxValue, 'periodic_enable', {
                        caption: L.tr('Periodic Enable'),
                        optional: true
                        }).depends({'tr069':'1','trenable' :'1'});   
                        
                s1.option(L.cbi.CheckboxValue, 'Server_request_enable', {
                        caption: L.tr('Accept Server Request'),
                        optional: true
                        }).depends({'tr069':'1','trenable' :'1' });               
                
                s1.option(L.cbi.InputValue, 'periodic_interval', {
                                caption: L.tr('Serving Interval'),
                                optional: true 
                        }).depends({'tr069':'1','trenable' :'1'});
                
                s1.option(L.cbi.InputValue, 'interface', {
                                caption: L.tr('Interface'),
                                optional: true 
                        }).depends({'tr069':'1','trenable' :'1'});        
                
                s1.option(L.cbi.InputValue, 'username', {
                                caption: L.tr('Username'),
                                optional: true 
                        }).depends({ 'tr069':'1', 'trenable' :'1'});
                        
                s1.option(L.cbi.PasswordValue, 'password', {
                                caption: L.tr('Password'),
                                optional: true 
                        }).depends({'tr069':'1' , 'trenable':'1'});        
                        
                
                s1.option(L.cbi.InputValue, 'url', {
                                caption: L.tr('URL'),
                                placeholder: 'https://ServerIP:Portnumber',
                                optional: true 
                        }).depends({'tr069':'1', 'trenable':'1'});
        
                        self.updatetrconfig('trconfigure').then(function (rv) {
                        });
                        
                m1.insertInto('#section_tr'); 
    
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////   
      
		var self = this;

                self.GetUCISections("remoteconfigstatus", "remote").then(function (rv) {       
                                self.updatenmsstatusconfig('configurestatus').then(function (rv) {
                                });

                                self.NMSStatusRenderContents(rv);

                });


                $('#btn_nmsstatus_refresh').click(function () {

                        L.ui.loading(true);
                        self.updatenmsstatusconfig('configurestatus').then(function (rv) {
                                L.ui.loading(false);
                                L.ui.showAlert(
                                        'success',
                                        'Update NMS configuration',
                                        rv || 'Configuration updated successfully'
                                );

                                // setTimeout(() => location.reload(), 3000);
                        });
                });

                $('#btn_nmsstatus_refresh').show();	

                L.ui.createNote(
                'NOTE',
                'Please click the refresh button for latest NMS status.',
                { type: 'info', variant: 'inline', appendTo: '#NMS-Note' }
                );
		
       
    //////////////////////////////////////////////////////////////////////////////////////////////////////////   
        var m2 = new L.cbi.Map('remoteconfig', {
        });
        
        var s2 = m2.section(L.cbi.NamedSection, 'nms', {
            caption:L.tr('NMS Configurations')
        }); 

        
             
                s2.option(L.cbi.CheckboxValue, 'nmsenable', {
                         caption: L.tr('Enable NMS'),
                         optional: true
                 });

                s2.option(L.cbi.ListValue, 'nmstunneltype', {
                        caption: L.tr('NMS Tunnel Type'),
                }).depends({ 'nmsenable': '1' })
			.value("none", L.tr('Please choose'))
                        .value("openvpn", L.tr('Openvpn'))
                        .value("wireguard", L.tr('Wireguard'));

                s2.option(L.cbi.InputValue, 'httpurl', {
                        caption: L.tr('URL'),
                        placeholder: 'https://example.com or https://IP',
                }).depends({ 'nmsenable': '1' })
                   
             
             
                self.GetUCISections("remoteconfig", "remoteconfig").then(function (rv) {

                        for (var key in rv) {
                                if (rv.hasOwnProperty(key)) {
                                        var obj = rv[key];
                                        var running = obj.nmsenable;
                                        if (running == '0') {
                                                document.getElementById('No-NMS-Config').innerHTML = 'The NMS Certificate section is disabled. Please enable NMS and save the Configurations to view the certificate section.'
                                                $('.cards').hide();

                                        }

                                        if (running == '1') {
                                                $('.cards').show();
                                                $('#No-NMS-Config').hide();
                                        }
                                }
                        }
                });

                $('#Upload-NMS').click(function () {
                        self.handleArchiveUpload();

                });

       
                s2.commit=function(){
		        self.updatenmsdisableconfig('update').then(function(rv) {		               
                        });
                }
         
                m2.insertInto('#section_config_nms');         
		
		
}  
   
});

