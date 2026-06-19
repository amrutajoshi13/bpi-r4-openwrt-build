L.ui.view.extend({

    // title: L.tr('DMZ'),
    //  description: L.tr('<b>Please click on update after saving any changes. Also for using this feature, create a VLAN as required.</b>'),
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
    
    updatedmzconfig: L.rpc.declare({
        object: 'rpc-updatedmzconfig',
        method: 'configure',
        expect: { output: '' }
    }),

    execute:function() {
            var self = this;
            L.ui.createNote(
                'NOTE',
                'Please click on update after saving any changes. Also for using this feature, create a VLAN as required.',
                { type: 'warn', variant: 'inline', appendTo: '#Update-Note-DMZ' }
            ); 

            $('#btn_update').click(function() {
                    L.ui.loading(true);
                    self.updatedmzconfig('configure').then(function(rv){
                        L.ui.loading(false);
                        L.ui.showAlert("success", "Update Complete", "Updated interface configuration successfully.");
                        setTimeout(function () {
                            location.reload();
                        }, 1500);                
                    });
            });

            var m = new L.cbi.Map('dmzconfig', {
            });
                
            var s = m.section(L.cbi.NamedSection, 'dmzconfig', {
                caption:L.tr('DMZ')
            });

            s.option(L.cbi.CheckboxValue, 'enabledmz', {
                caption: L.tr('Enable DMZ'),
                optional: true
            });
            
            s.option(L.cbi.InputValue, 'host_ip', {
                caption: L.tr('Host IP Address'),
                datatype: 'ip4addr',
            }).depends({'enabledmz' : '1'});
            
            s.option(L.cbi.ListValue,'proto',{          
                caption:L.tr('Protocol'),                    
            }).depends({'enabledmz' : '1'})
                .value("none", L.tr('Please choose')) 
                .value("tcp", L.tr('TCP')) 
                .value("udp", L.tr('UDP'))
                .value("icmp", L.tr('ICMP'))
                .value("all", L.tr('All')); 
                
            s.option(L.cbi.CheckboxValue, 'allow_http', {
                caption: L.tr('Allow HTTP'),
                optional: true
            }).depends({'enabledmz' : '1'});
            
            s.option(L.cbi.InputValue, 'int_port_http', {
                caption: L.tr('Internal Port'),
                placeholder: '80',
            }).depends({'enabledmz' : '1', 'allow_http' : '1'});
            
            s.option(L.cbi.InputValue, 'ext_port_http', {
                caption: L.tr('External Port'),
                placeholder: '80',
            }).depends({'enabledmz' : '1', 'allow_http' : '1'});
            
            s.option(L.cbi.CheckboxValue, 'allow_https', {
                caption: L.tr('Allow HTTPS'),
                optional: true
            }).depends({'enabledmz' : '1'});
            
            s.option(L.cbi.InputValue, 'int_port_https', {
                caption: L.tr('Internal Port'),
                placeholder: '443',
            }).depends({'enabledmz' : '1','allow_https' : '1'});
            
            s.option(L.cbi.InputValue, 'ext_port_https', {
                caption: L.tr('External Port'),
                placeholder: '443',
            }).depends({'enabledmz' : '1','allow_https' : '1'});
            
            s.option(L.cbi.CheckboxValue, 'allow_ssh', {
                caption: L.tr('Allow SSH'),
                optional: true
            }).depends({'enabledmz' : '1'});
            
            s.option(L.cbi.InputValue, 'int_port_ssh', {
                caption: L.tr('Internal Port'),
                placeholder: '52434',
            }).depends({'enabledmz' : '1','allow_ssh' : '1'});
            
            s.option(L.cbi.InputValue, 'ext_port_ssh', {
                caption: L.tr('External Port'),
                placeholder: '52434',
            }).depends({'enabledmz' : '1','allow_ssh' : '1'});
            
            s.option(L.cbi.CheckboxValue, 'allow_ftp', {
                caption: L.tr('Allow FTP'),
                optional: true
            }).depends({'enabledmz' : '1'});
            
            s.option(L.cbi.InputValue, 'int_port_ftp', {
                caption: L.tr('Internal Port'),
                placeholder: '21/20',
            }).depends({'enabledmz' : '1','allow_ftp' : '1'});
            
            s.option(L.cbi.InputValue, 'ext_port_ftp', {
                caption: L.tr('External Port'),
                placeholder: '21/20',
            }).depends({'enabledmz' : '1','allow_ftp' : '1'});
                
            s.option(L.cbi.CheckboxValue, 'allow_dns', {
                caption: L.tr('Allow DNS'),
                optional: true
            }).depends({'enabledmz' : '1'});    
            
            s.option(L.cbi.InputValue, 'int_port_dns', {
                caption: L.tr('Internal Port'),
                placeholder: '53',
            }).depends({'enabledmz' : '1','allow_dns' : '1'});
            
            s.option(L.cbi.InputValue, 'ext_port_dns', {
                caption: L.tr('External Port'),
                placeholder: '53',
            }).depends({'enabledmz' : '1','allow_dns' : '1'});
                        
            s.commit=function(){
            }
		                        
            return m.insertInto('#map');
    }

});
