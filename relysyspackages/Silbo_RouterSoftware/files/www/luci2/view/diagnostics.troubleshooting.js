L.ui.view.extend({




  fGetUCISections: L.rpc.declare({
    object: 'uci',
    method: 'get',
    // params: [ 'config', 'type', 'section']  
    params: ['config', 'type']

  }),

  updateinterfaceconfig: L.rpc.declare({
    object: 'rpc-tcpdumpupdate',
    method: 'configure',
    expect: { output: '' }
  }),



  handleBackupDownload: function () {
    var form = $('#btn_backup').parent();

    form.find('[name=sessionid]').val(L.globals.sid);
    form.submit();
  },


  execute: function () {
    var self = this;
    var m = new L.cbi.Map('tcpdumpconfig', {
    });

    var s = m.section(L.cbi.NamedSection, 'tcpdump', {
      caption: L.tr('TCP Dump Configuration')
    });

    s.option(L.cbi.ListValue, 'tcpdump_mode', {
      caption: L.tr('Select Tcpdump Mode'),
      optional: true
    }).value('enabled', L.tr('Standard Command'))
      .value('customenabled', L.tr('Custom Command'));


    s.option(L.cbi.InputValue, 'customtcp_command', {
      caption: L.tr('Custom Command'),
      placeholder: 'tcpdump -nvv -i eth0.5 src 192.168.1.120 and not arp',
    }).depends({ 'tcpdump_mode': 'enabled', 'tcpdump_mode': 'customenabled' });

    s.option(L.cbi.Ifname_List, 'interface', {
      caption: L.tr('Interfaces'),
      optional: true,
    }).depends({ 'tcpdump_mode': 'enabled' })
      .value("any", "Any");

    s.option(L.cbi.InputValue, 'port', {
      caption: L.tr('Port'),
      datatype: 'uinteger_digit',
      placeholder: '80',
      optional: true,
    }).depends({ 'tcpdump_mode': 'enabled' });

    s.option(L.cbi.ComboBox, 'proto', {
      caption: L.tr('Protocol'),
    }).depends({ 'tcpdump_mode': 'enabled' })
      .value('all', L.tr('ALL'))
      .value('icmp', L.tr('ICMP'))
      .value('udp', L.tr('UDP'))
      .value('tcp', L.tr('TCP'))
      .value('arp', L.tr('ARP'));

    s.option(L.cbi.InputValue, 'timeout', {
      caption: L.tr('Time in seconds (Sec)'),
      //description: L.tr('Time should be formatted in seconds'),
      datatype: 'uinteger_digit',
      placeholder: '30',
    }).depends({ 'tcpdump_mode': 'enabled' })
      .depends({ 'tcpdump_mode': 'customenabled' });

    s.option(L.cbi.ListValue, 'tcp_inout', {
      caption: L.tr('Packet direction'),
    }).depends({ 'tcpdump_mode': 'enabled' })
      .value('inout', L.tr('Incoming/Outgoing'))
      .value('in', L.tr('Incoming'))
      .value('out', L.tr('Outgoing'));


    s.option(L.cbi.ListValue, 'ipaddress', {
      caption: L.tr('IP Address'),
    }).value("none", L.tr('Please choose'))
      .value("hostip", L.tr('Host IP'))
      .value("subnetip", L.tr('Subnet IP'))
      .depends({ 'tcpdump_mode': 'enabled' });


    s.option(L.cbi.InputValue, 'tcp_host', {
      caption: L.tr('Host IP'),
      optional: true,
      datatype: 'ip4addr',
      placeholder: '192.168.1.1',
    }).depends({ ipaddress: 'hostip', 'tcpdump_mode': 'enabled' });


    s.option(L.cbi.InputValue, 'tcp_subnet', {
      caption: L.tr('Subnet IP'),
      datatype: 'cidr4',
      optional: true,
      placeholder: '192.168.1.0/24',
    }).depends({ ipaddress: 'subnetip', 'tcpdump_mode': 'enabled' });


    download_data = function (data) {
      var timeout = parseInt(data, 10);
      document.getElementById('progress-container').style.display = 'block'
      document.getElementById('couter_lable').style.display = 'block'
      document.getElementsByClassName("transfer-container")[0].style.display = 'block';
      var P_bar = document.getElementById('progress-bar');
      var P_Label = document.getElementById('progress-label');
      var C_Label = document.getElementById('couter_lable');
      var T_Width = 100;
      var C_Width = 1;
      var interval = T_Width / timeout;

      if (s.progressInterval) clearInterval(s.progressInterval);
      s.progressInterval = setInterval(function () {
        if (C_Width >= T_Width) {
          clearInterval(s.progressInterval);
          document.getElementById('progress-label').style.display = 'block'
          document.getElementById('progress-container').style.display = 'none'
          document.getElementById('couter_lable').style.display = 'none'
          document.getElementsByClassName("transfer-container")[0].style.display = 'none';
          P_Label.textContent = `PCAP TCP Dump completed after ${timeout} seconds. Click Download button to get the file.`;
          document.getElementById('btn_backup').style.display = 'block'
          return;
        }
        C_Width += interval;
        P_bar.style.width = C_Width + '%';
        C_Label.textContent = `${Math.round((C_Width / T_Width) * timeout)} seconds`;
      }, 1000);

    }

    $('#btn_backup').click(function () { self.handleBackupDownload(); });

    s.commit = function () {
      self.fGetUCISections('tcpdumpconfig', 'tcpdump').then(function (rv) {
        var timeout = rv.values.tcpdump.timeout;
        var tcpdump_mode = rv.values.tcpdump.tcpdump_mode;

        localStorage.setItem('tcp_dump_Timeout', timeout);
        localStorage.setItem('tcp_dump_status', tcpdump_mode);

      })
    };


    $("#btn_run").click(function () {
      document.getElementById('progress-container').style.display = 'none'
      document.getElementById('progress-label').style.display = 'none'
      document.getElementById('couter_lable').style.display = 'none'
      document.getElementById('btn_backup').style.display = 'none'
      document.getElementsByClassName("transfer-container")[0].style.display = 'none';
      const enabled = localStorage.getItem('tcp_dump_status')
      const loadingIndicator = document.getElementById('loading');

      if (enabled === 'customenabled') {
        loadingIndicator.style.display = "block";
        self.updateinterfaceconfig('configure').then(function (rv) {
          loadingIndicator.style.display = "none";
          const isSuccessResponse = rv.includes('SUCCESS');
          const isSuccessListeningResponse = rv.includes('SUCCESS: tcpdump: listening');
          if (isSuccessListeningResponse) {
            const Timeout = localStorage.getItem('tcp_dump_Timeout');
            download_data(Timeout);
          } else if (isSuccessResponse) {
            rv = rv.replace('SUCCESS', 'Error Message');
            const errorLabel = document.getElementById('Error-label');
            if (errorLabel) {
              errorLabel.style.display = "block";
              errorLabel.innerHTML = rv;
            }
          }
        })
      } else if (enabled === 'enabled') {
        const Timeout = localStorage.getItem('tcp_dump_Timeout');
        download_data(Timeout);
        self.updateinterfaceconfig('configure').then(function (rv) {
        })
      }
    });
    return m.insertInto('#map');

  }
});
