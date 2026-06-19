L.ui.view.extend({

  title: L.tr('Port Configuration'),

  updateportconfig: L.rpc.declare({
    object: 'rpc-PortConfig',
    method: 'configure',
    params: ['application', 'action'],
    expect: { output: '' }
  }),

  execute: function () {
    var self = this;
    var m = new L.cbi.Map('portconfig', {
    });

    var enableTable = "";

    var s = m.section(L.cbi.NamedSection, 'portconfig', {
      caption: L.tr('Serial Port Configuration')
    });

    var t = m.section(L.cbi.TableSection, 'tcpClient', {
      caption: L.tr('TCP Remote Client Configuration'),
      addremove: true,
      add_caption: L.tr('Add New Tcp Client'),
      remove_caption: L.tr('Remove'),
      display: 'none'
    });


    t.option(L.cbi.InputValue, 'clientIP', {
      caption: L.tr('IP Address'),
      datatype: 'ip4addr',
      width: "25%",
      optional: true
    });

    t.option(L.cbi.InputValue, 'clientPort', {
      caption: L.tr('Port'),
      datatype: 'uinteger',
      width: "15%",
      optional: true
    });

    t.option(L.cbi.InputValue, 'SlaveID', {
      caption: L.tr('Slave ID'),
      datatype: 'uinteger',
      width: "15%",
      optional: true
    });

    t.option(L.cbi.InputValue, 'ResponseWaitTime', {
      caption: "Response wait time <br>(In milliseconds)",
      datatype: 'uinteger',
      width: "15%",
      optional: true
    });

    t.option(L.cbi.InputValue, 'ConnectionTimeout', {
      caption: "Connection timeout <br>(In seconds)",
      datatype: 'uinteger',
      width: "15%",
      optional: true
    });

    t.commit = function () {
      self.updateportconfig('configure').then(function (rv) {

      });
    };

    for (var i = 1; i < 2; i++) {
      s.tab({
        id: `ser2netconfig${i}`,
        caption: L.tr(`Port${i} Settings`)
      });

      /* Port 1 Transparent Mode settings */
      //s.taboption('ser2netconfig1',L.cbi.CheckboxValue,'Ser2netEnable1',{
      //caption: L.tr('Enable Transparent Serial Port 1 Settings')
      //}); 
      s.taboption('ser2netconfig1', L.cbi.ListValue, 'Ser2netEnable1', {
        caption: L.tr('Port Mode'),
        datatype: function (ev) {
          enableTable = ev[0];
          if (enableTable == "4") {
            document.getElementById('section_portconfig_tcpClient').style.display = "block";
          }
          else {
            document.getElementById('section_portconfig_tcpClient').style.display = "none";
          }
        }
      }).depends({ 'ser2netconfig1': '1' })
        .value("2", L.tr("None"))
        .value("1", L.tr("Transparent Serial to Remote Client"))
        .value("3", L.tr("Transparent Serial to Remote Server"))
        .value("0", L.tr("Modbus TCP Master to Modbus RTU Slave"))
        .value("4", L.tr("Modbus RTU Master to Modbus TCP Slave"));

      /*  s.taboption('ser2netconfig1',L.cbi.ListValue, 'InternalPort1', {
              caption: L.tr('Serial Port'),
                           optional: 'true'
      }).depends({'ser2netconfig1':'1','Ser2netEnable1':'1'})
        .value("/dev/ttyS1",L.tr("Port1"));*/

      s.taboption('ser2netconfig1', L.cbi.InputValue, 'remoteserverip1', {
        caption: L.tr('Remote Server IP'),
      }).depends({ 'ser2netconfig1': '1', 'Ser2netEnable1': '3' });

      s.taboption('ser2netconfig1', L.cbi.InputValue, 'remoteserverport1', {
        caption: L.tr('Remote Server Port'),
      }).depends({ 'ser2netconfig1': '1', 'Ser2netEnable1': '3' });


      s.taboption('ser2netconfig1', L.cbi.ListValue, 'portmode1', {
        caption: L.tr('Transparent Serial Port Mode'),
      }).depends({ 'ser2netconfig1': '1', 'Ser2netEnable1': '1' })
        .depends({ 'Ser2netEnable1': '3' })
        .value("raw", L.tr("raw"))
        .value("rawlp", L.tr("rawlp"))
        .value("telnet", L.tr("telnet"))
        .value("off", L.tr("off"));

      s.taboption('ser2netconfig1', L.cbi.ListValue, 'timeout1', {
        caption: L.tr('Time Out'),
      }).depends({ 'ser2netconfig1': '1', 'Ser2netEnable1': '1' })
        .depends({ 'Ser2netEnable1': '3' })
        .value("0", L.tr("no time out"))
        .value("5", L.tr("5"))
        .value("10", L.tr("10"))
        .value("15", L.tr("15"));

      s.taboption('ser2netconfig1', L.cbi.InputValue, 'tcpport1', {
        caption: L.tr('Local Listener TCP Port'),
      }).depends({ 'ser2netconfig1': '1', 'Ser2netEnable1': '1' })
        .depends({ 'Ser2netEnable1': '3' });



      s.taboption('ser2netconfig1', L.cbi.ListValue, 'Baudrate1', {
        caption: L.tr('Baud Rate'),
      }).depends({ 'ser2netconfig1': '1', 'Ser2netEnable1': '1' })
        .depends({ 'Ser2netEnable1': '3' })
        .value("115200", L.tr("115200"))
        .value("50", L.tr("50"))
        .value("75", L.tr("75"))
        .value("110", L.tr("110"))
        .value("134", L.tr("134"))
        .value("150", L.tr("150"))
        .value("300", L.tr("300"))
        .value("600", L.tr("600"))
        .value("1200", L.tr("1200"))
        .value("1800", L.tr("1800"))
        .value("2400", L.tr("2400"))
        .value("4800", L.tr("4800"))
        .value("7200", L.tr("7200"))
        .value("9600", L.tr("9600"))
        .value("19200", L.tr("19200"))
        .value("38400", L.tr("38400"))
        .value("57600", L.tr("57600"))
        .value("230.4k", L.tr("230.4k"))
        .value("460.8k", L.tr("460.8k"))
        .value("921.6k", L.tr("921.6k"));

      s.taboption('ser2netconfig1', L.cbi.ListValue, 'NoOfStopbits1', {
        caption: L.tr('No Of Stopbits'),
      }).depends({ 'ser2netconfig1': '1', 'Ser2netEnable1': '1' })
        .depends({ 'Ser2netEnable1': '3' })
        .value("1", L.tr("1"))
        .value("1.5", L.tr("1.5"))
        .value("2", L.tr("2"));

      s.taboption('ser2netconfig1', L.cbi.ListValue, 'Databits1', {
        caption: L.tr('No Of Databits'),
      }).depends({ 'ser2netconfig1': '1', 'Ser2netEnable1': '1' })
        .depends({ 'Ser2netEnable1': '3' })
        .value("8", L.tr("8"))
        .value("5", L.tr("5"))
        .value("6", L.tr("6"))
        .value("7", L.tr("7"));

      s.taboption('ser2netconfig1', L.cbi.ListValue, 'Parity1', {
        caption: L.tr('Parity'),
      }).depends({ 'ser2netconfig1': '1', 'Ser2netEnable1': '1' })
        .depends({ 'Ser2netEnable1': '3' })
        .value("NONE", L.tr("NONE"))
        .value("EVEN", L.tr("EVEN"))
        .value("ODD", L.tr("ODD"))
        .value("SPACE", L.tr("SPACE"))
        .value("MARK", L.tr("MARK"));

      s.taboption('ser2netconfig1', L.cbi.ListValue, 'Flowcontrol1', {
        caption: L.tr('Flow Control')
      }).depends({ 'ser2netconfig1': '1', 'Ser2netEnable1': '1' })
        .depends({ 'Ser2netEnable1': '3' })
        .value("RTSCTS", L.tr("RTSCTS"))
        .value("NONE", L.tr("NONE"))
        .value("DTRDSR", L.tr("DTRDSR"))
        .value("XONXOFF", L.tr("XONXOFF"));

      s.taboption('ser2netconfig1', L.cbi.CheckboxValue, 'readtraceenable1', {
        caption: L.tr('Read Trace'),
      }).depends({ 'ser2netconfig1': '1', 'Ser2netEnable1': '1' })
        .depends({ 'Ser2netEnable1': '3' });

      s.taboption('ser2netconfig1', L.cbi.CheckboxValue, 'writetraceenable1', {
        caption: L.tr('Write Trace'),
      }).depends({ 'ser2netconfig1': '1', 'Ser2netEnable1': '1' })
        .depends({ 'Ser2netEnable1': '3' });


      /* Port 1 Modbus TCP to RTU settings */

      s.taboption('ser2netconfig1', L.cbi.DummyValue, 'modbusserialconfig', {
        caption: L.tr(''),
        //  caption: L.tr(a),
      }).depends({ 'ser2netconfig1': '1', 'Ser2netEnable1': '0' })
        .depends({ 'Ser2netEnable1': '4' })
        .ucivalue = function () {
          var id = "<h3><b>&nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp Serial Configuration </b> </h3>";
          return id;
        };

      s.taboption('ser2netconfig1', L.cbi.ListValue, 'mbusdBaudrate1', {
        caption: L.tr('Baud rate'),
      }).depends({ 'ser2netconfig1': '1', 'Ser2netEnable1': '0' })
        .depends({ 'Ser2netEnable1': '4' })
        .value("110", L.tr("110"))
        .value("300", L.tr("300"))
        .value("600", L.tr("600"))
        .value("1200", L.tr("1200"))
        .value("2400", L.tr("2400"))
        .value("4800", L.tr("4800"))
        .value("9600", L.tr("9600"))
        .value("14400", L.tr("14400"))
        .value("19200", L.tr("19200"))
        .value("38400", L.tr("38400"))
        .value("57600", L.tr("57600"))
        .value("115200", L.tr("115200"))
        .value("128000", L.tr("128000"))
        .value("256000", L.tr("256000"));

      s.taboption('ser2netconfig1', L.cbi.ListValue, 'mbusdParity1', {
        caption: L.tr('Parity'),
      }).depends({ 'ser2netconfig1': '1', 'Ser2netEnable1': '0' })
        .depends({ 'Ser2netEnable1': '4' })
        .value("0", L.tr("0:None"))
        .value("1", L.tr("1:Odd"))
        .value("2", L.tr("2:Even"));

      s.taboption('ser2netconfig1', L.cbi.ListValue, 'mbusdNoOfStopbits1', {
        caption: L.tr('No of Stopbits'),
      }).depends({ 'ser2netconfig1': '1', 'Ser2netEnable1': '0' })
        .depends({ 'Ser2netEnable1': '4' })
        .value("1", L.tr("1"))
        .value("2", L.tr("2"));

      s.taboption('ser2netconfig1', L.cbi.ListValue, 'mbusdDatabits1', {
        caption: L.tr('No of Databits'),
      }).depends({ 'ser2netconfig1': '1', 'Ser2netEnable1': '0' })
        .depends({ 'Ser2netEnable1': '4' })
        .value("7", L.tr("7"))
        .value("8", L.tr("8"));

      s.taboption('ser2netconfig1', L.cbi.DummyValue, 'modbustcpconfig1', {
        caption: L.tr(''),
        //  caption: L.tr(a),
      }).depends({ 'ser2netconfig1': '1', 'Ser2netEnable1': '0' })
        .depends({ 'Ser2netEnable1': '4' })
        .ucivalue = function () {
          var id = "<h3><b>&nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp TCP Configuration </b> </h3>";
          return id;
        };

      s.taboption('ser2netconfig1', L.cbi.InputValue, 'mbusdLocalInterfaceIP1', {
        caption: L.tr('Local Listener Interface IP Address'),
        datatype: 'ip4addr'
      }).depends({ 'ser2netconfig1': '1', 'Ser2netEnable1': '0' });

      s.taboption('ser2netconfig1', L.cbi.InputValue, 'mbusdtcpport1', {
        caption: L.tr('TCP Port'),
        datatype: 'portrange'
      }).depends({ 'ser2netconfig1': '1', 'Ser2netEnable1': '0' });

      s.taboption('ser2netconfig1', L.cbi.InputValue, 'mbusdmaxretries1', {
        caption: L.tr('Max. number retries'),
        datatype: 'uinteger'
      }).depends({ 'ser2netconfig1': '1', 'Ser2netEnable1': '0' })
        .depends({ 'Ser2netEnable1': '4' });

      s.taboption('ser2netconfig1', L.cbi.InputValue, 'mbusddelaybetweeneachrequest1', {
        caption: L.tr('Delay between each request (In milliseconds)'),
        datatype: 'uinteger'
      }).depends({ 'ser2netconfig1': '1', 'Ser2netEnable1': '0' })
        .depends({ 'Ser2netEnable1': '4' });

      s.taboption('ser2netconfig1', L.cbi.InputValue, 'mbusdresponsewaittime1', {
        caption: L.tr('Response wait time (In milliseconds)'),
        datatype: 'uinteger'
      }).depends({ 'ser2netconfig1': '1', 'Ser2netEnable1': '0' });

      s.taboption('ser2netconfig1', L.cbi.InputValue, 'mbusdconnectiontimeout1', {
        caption: L.tr('Connection timeout (In seconds)'),
        datatype: 'uinteger'
      }).depends({ 'ser2netconfig1': '1', 'Ser2netEnable1': '0' });

      s.taboption('ser2netconfig1', L.cbi.InputValue, 'mbusdinactivitytimeout1', {
        caption: L.tr('Inactivity timeout (In seconds)'),
        datatype: 'uinteger'
      }).depends({ 'ser2netconfig1': '1', 'Ser2netEnable1': '0' })
        .depends({ 'Ser2netEnable1': '4' });
    }

    s.commit = function () {
      self.updateportconfig('configure').then(function (rv) {

      });
    }

    return m.insertInto('#map');
  }
});
