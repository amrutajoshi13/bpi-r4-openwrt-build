L.ui.view.extend({

    title: L.tr('TCP Slave Configuration'),
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
    
      updateinterfaceconfig: L.rpc.declare({
        object: 'rpc-updatemacconfig',
        method: 'configure',
        params: ['application','action'],
        expect: { output: '' }
        }),
        
StartStopService: L.rpc.declare({
        object: 'luci',
        method: 'setInitAction',
        params: ['name', 'action'],
        expect: { '': {} }
    }),


        handleBackupDownload: function() {
          var form = $('#btn_backup').parent();
      
          form.find('[name=sessionid]').val(L.globals.sid);
          form.submit();
        },
  
    execute:function() {
        var self = this;
        var m = new L.cbi.Map('tcpconfig', {
        });
        
        var s = m.section(L.cbi.NamedSection, 'tcpconfig', {
            caption:L.tr('Tcp slave Configuration')
        });
        
        
        s.option(L.cbi.CheckboxValue, 'enabletcp', {
                            caption: L.tr('TCP Enable'),
                            optional: true
                  });
                  
                  
         s.option(L.cbi.ListValue, 'tcpportmode', {
                     caption: L.tr('RS485 Port'),
                   }).depends({'enabletcp':'1'})
                    // .value("none",L.tr("Choose Option"))
                     .value("eth0.1",L.tr("1"))
                     .value("eth0.2",L.tr("2"))
                     .value("eth0.3",L.tr("3"));
                     
                     
          s.option(L.cbi.InputValue, 'portslave', {
                     caption: L.tr('Port'),
                     placeholder: '512',
                   }).depends({'enabletcp':'1'});
                   
                   
          s.option(L.cbi.InputValue, 'slaveid', {
                     caption: L.tr('TCP Slave'),
                     placeholder: '1',
                   }).depends({'enabletcp':'1'});


          // s.option(L.cbi.ButtonValue, 'downloadButton', {
          //           caption: L.tr('Download Files'),
          //           width: '110%',
          //           inputname: 'download_button'
          //         }).depends({'enabletcp':'1'});

          $('#btn_backup').click(function() { self.handleBackupDownload(); });
		s.commit=function(){
        //self.updateinterfaceconfig('Update','updateinterface').then(function(rv) {
			self.fGetUCISections('tcpconfig','genericonfig').then(function (rv) {
				var enableKey = "start";
				for(var key in rv) {
					if(rv.hasOwnProperty)
					{
						if(rv[key].enabletcp == "0")
						{
							enableKey = "stop";
						}
						self.StartStopService('tcpslave',enableKey).then(function(res) {
			  			 });
					}
				}
			});
               // });
        }
		                        
        return m.insertInto('#map');
        
   }     

});




