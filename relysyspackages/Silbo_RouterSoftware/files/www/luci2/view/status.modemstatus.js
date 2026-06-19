L.ui.view.extend({
     
    getLastWANStatus:L.rpc.declare({
        object:'interfacemanager',
        method:'laststatus',
        params : ['interface']
    }),
    
    getCurrentWANStatus:L.rpc.declare({
        object:'interfacemanager',
        method:'currentstatus',
        params : ['interface']
    }),
    
    msGetUCISections: L.rpc.declare({
        object: 'uci',
        method: 'get',
        params: [ 'config', 'type' ],
        expect: { values: {} }
    }),
    
    updatefirewallconfig: L.rpc.declare({
        object: 'rpc-querymodemstatus',
        method: 'configure',
        expect: { output: '' }
    }),
    
    updateinterfacestatus: L.rpc.declare({
        object: 'rpc-querymodemstatus',
        method: 'check',
        expect: { output: '' }
    }),
  
    DispModemStatus: function (ModemConfig) {

        var self = this;

        $.each(ModemConfig, function (key) {

            if (ModemConfig.hasOwnProperty(key)) {
                var obj = ModemConfig[key];
                var ModemEnable   = obj.modemenable;
                var MonitorEnable = obj.monitorenable;

                if ( ModemEnable == 1 && MonitorEnable == 1) 
                {

                    self.updateinterfacestatus('check').then(function (rv) {

                        var parentDiv = $('<div/>', { class: 'cbi-section modem-card' });
                        var headingDiv = $('<div/>', { class: 'modem-panel-heading' });
                        var h3 = $('<h3/>', { class: 'panel-title', text: 'Modem Status' });
                        headingDiv.append(h3);
                        var bodyDiv = $('<div/>', { class: 'cbi-section-node modem-status-list' });
                        parentDiv.append(headingDiv).append(bodyDiv);
                        $('#map').append(parentDiv);

                        if (rv == "1") {
                            bodyDiv.append(
                                $('<div/>', {
                                    class: 'modem-state-msg modem-down',
                                    text: L.tr('Cellular WAN interface is Down')
                                })
                            );
                        } else if (rv == "2") {
                            bodyDiv.append(
                                $('<div/>', {
                                    class: 'modem-state-msg modem-disabled',
                                    text: L.tr('Cellular interface is disabled')
                                })
                            );
                        } else { 
                            self.updatefirewallconfig('configure').then(function (rv) {
                                var str = rv.split(',');

                                function addRow(label, value) {
                                    var row = $('<div/>', { class: 'modem-status-row' });
                                    row.append($('<div/>', {
                                        class: 'modem-status-label',
                                        text: label
                                    }));
                                    row.append($('<div/>', {
                                        class: 'modem-status-value',
                                        text: value || 'NA'
                                    }));
                                    bodyDiv.append(row);
                                }

                                addRow('Network Operator', str[0]);
                                addRow('Network Technology', str[1]);
                                addRow('Network Mode', str[2]);
                                addRow('Mobile Country Code', str[3]);
                                addRow('Mobile Network Code', str[4]);
                                addRow('Location Area Code', str[5]);
                                addRow('Cell ID', str[6]);
                                addRow('BSIC / PCI', str[7]);
                                addRow('RF Channel Number', str[8]);
                                addRow('Frequency Band', str[9]);
                                addRow('Upload Bandwidth', str[10]);
                                addRow('Download Bandwidth', str[11]);
                                addRow('Tracking Area Code', str[12]);
                                addRow('Reference Signal Received Power (dBm)', str[13]);
                                addRow('Reference Signal Received Quality (dBm)', str[14]);
                                addRow('Received signal strength indication (dB)', str[15]);
                                addRow('Signal to Noise Ratio (dB)', str[16]);
                            });
                        }
                    });

                }

            }
        });
    },

    execute: function() {
        var self = this;
        
        L.ui.loading(true);
             
        self.msGetUCISections("modem","interface").then(function(ModemConfig,rv) {
                self.DispModemStatus(ModemConfig,rv);
			});

        L.ui.createNote(
			'NOTE',
			'Please click the refresh button for latest Cellular WAN interfaces',
			{ type: 'info', variant: 'inline', appendTo: '#Modem-Note' }
		);

		$('#ModemRefresh-btn').click(function () {
			var $refresh = $('#ModemRefresh-btn');
			$refresh.addClass('is-loading').attr('aria-busy', 'true');
			document.getElementById('map').innerHTML = '';
			     self.msGetUCISections("modem","interface").then(function(ModemConfig,rv) {
                self.DispModemStatus(ModemConfig,rv);
			});
			L.ui.showAlert("info", "Updated", "Latest Modem status is updated");
			$refresh.removeClass('is-loading').attr('aria-busy', 'false');


		});
		
    }
});

