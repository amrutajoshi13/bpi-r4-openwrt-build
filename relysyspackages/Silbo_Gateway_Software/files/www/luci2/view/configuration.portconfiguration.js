L.ui.view.extend({

  // title: L.tr('Port Configuration'),

  updateportconfig: L.rpc.declare({
    object: 'rpc-PortConfig',
    method: 'configure',
    params: ['application', 'action'],
    expect: { output: '' }
  }),

  renderport: function () {
    var self = this;
    var m = new L.cbi.Map('portconfig', {
    });
    var s = m.section(L.cbi.NamedSection, 'portconfig1', {
      caption: L.tr('Port Configuration')
    });
    s.option(L.cbi.ListValue, 'Ser2netEnable1', {
      caption: L.tr('Port Mode'),
      datatype: function (ev) {
        var enableTable1 = ev[0];
        document.getElementById('section_portconfig_tcpClient_1').style.display = "none";
        if (enableTable1 == "4") {
          document.getElementById('section_portconfig_tcpClient_1').style.display = "block";
        }
      }
    }).depends({ 'ser2netconfig1': '1' })
      .value("2", L.tr("None"))
      .value("1", L.tr("Transparent Serial to Remote Client"))
      .value("3", L.tr("Transparent Serial to Remote Server"))
      .value("0", L.tr("Modbus TCP Master to Modbus RTU Slave"))
      .value("4", L.tr("Modbus RTU Master to Modbus TCP Slave"));

    s.option(L.cbi.InputValue, 'remoteserverip1', {
      caption: L.tr('Remote Server IP'),
    }).depends({ 'ser2netconfig1': '1', 'Ser2netEnable1': '3' });

    s.option(L.cbi.InputValue, 'remoteserverport1', {
      caption: L.tr('Remote Server Port'),
    }).depends({ 'ser2netconfig1': '1', 'Ser2netEnable1': '3' });


    s.option(L.cbi.ListValue, 'portmode1', {
      caption: L.tr('Transparent Serial Port Mode'),
    }).depends({ 'ser2netconfig1': '1', 'Ser2netEnable1': '1' })
      .depends({ 'Ser2netEnable1': '3' })
      .value("raw", L.tr("raw"))
      .value("rawlp", L.tr("rawlp"))
      .value("telnet", L.tr("telnet"))
      .value("off", L.tr("off"));

    s.option(L.cbi.ListValue, 'timeout1', {
      caption: L.tr('Time Out'),
    }).depends({ 'ser2netconfig1': '1', 'Ser2netEnable1': '1' })
      .depends({ 'Ser2netEnable1': '3' })
      .value("0", L.tr("no time out"))
      .value("5", L.tr("5"))
      .value("10", L.tr("10"))
      .value("15", L.tr("15"));

    s.option(L.cbi.InputValue, 'LocalInterfaceIP1', {
      caption: L.tr('Local Listener Interface IP Address'),
      datatype: 'ip4addr'
    }).depends({ 'ser2netconfig1': '1', 'Ser2netEnable1': '1' })
      .depends({ 'ser2netconfig1': '1', 'Ser2netEnable1': '3' });

    s.option(L.cbi.InputValue, 'tcpport1', {
      caption: L.tr('Local Listener TCP Port'),
    }).depends({ 'ser2netconfig1': '1', 'Ser2netEnable1': '1' })
      .depends({ 'ser2netconfig1': '1', 'Ser2netEnable1': '3' });



    s.option(L.cbi.ListValue, 'Baudrate1', {
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

    s.option(L.cbi.ListValue, 'NoOfStopbits1', {
      caption: L.tr('No Of Stopbits'),
    }).depends({ 'ser2netconfig1': '1', 'Ser2netEnable1': '1' })
      .depends({ 'Ser2netEnable1': '3' })
      .value("1", L.tr("1"))
      .value("1.5", L.tr("1.5"))
      .value("2", L.tr("2"));

    s.option(L.cbi.ListValue, 'Databits1', {
      caption: L.tr('No Of Databits'),
    }).depends({ 'ser2netconfig1': '1', 'Ser2netEnable1': '1' })
      .depends({ 'Ser2netEnable1': '3' })
      .value("8", L.tr("8"))
      .value("5", L.tr("5"))
      .value("6", L.tr("6"))
      .value("7", L.tr("7"));

    s.option(L.cbi.ListValue, 'Parity1', {
      caption: L.tr('Parity'),
    }).depends({ 'ser2netconfig1': '1', 'Ser2netEnable1': '1' })
      .depends({ 'Ser2netEnable1': '3' })
      .value("NONE", L.tr("NONE"))
      .value("EVEN", L.tr("EVEN"))
      .value("ODD", L.tr("ODD"))
      .value("SPACE", L.tr("SPACE"))
      .value("MARK", L.tr("MARK"));

    s.option(L.cbi.ListValue, 'Flowcontrol1', {
      caption: L.tr('Flow Control')
    }).depends({ 'ser2netconfig1': '1', 'Ser2netEnable1': '1' })
      .depends({ 'Ser2netEnable1': '3' })
      .value("RTSCTS", L.tr("RTSCTS"))
      .value("NONE", L.tr("NONE"))
      .value("DTRDSR", L.tr("DTRDSR"))
      .value("XONXOFF", L.tr("XONXOFF"));

    s.option(L.cbi.CheckboxValue, 'readtraceenable1', {
      caption: L.tr('Read Trace'),
    }).depends({ 'ser2netconfig1': '1', 'Ser2netEnable1': '1' })
      .depends({ 'Ser2netEnable1': '3' });

    s.option(L.cbi.CheckboxValue, 'writetraceenable1', {
      caption: L.tr('Write Trace'),
    }).depends({ 'ser2netconfig1': '1', 'Ser2netEnable1': '1' })
      .depends({ 'Ser2netEnable1': '3' });


    /* Port 1 Modbus TCP to RTU settings */

    // s.option(L.cbi.DummyValue, 'modbusserialconfig', {
    //   caption: L.tr(''),
    //   //  caption: L.tr(a),
    // }).depends({ 'ser2netconfig1': '1', 'Ser2netEnable1': '0' })
    //   .depends({ 'Ser2netEnable1': '4' })
    //   .ucivalue = function () {
    //     var id = "<h3><b>&nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp Serial Configuration </b> </h3>";
    //     return id;
    //   };

    s.option(L.cbi.SubHeadingValue, 'modbusserialconfig', { caption: '' })
      .depends({ 'ser2netconfig1': '1', 'Ser2netEnable1': '0' })
      .depends({ 'Ser2netEnable1': '4' })
      .ucivalue = function () {
        return ' Serial Configuration';
      };


    s.option(L.cbi.ListValue, 'mbusdBaudrate1', {
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

    s.option(L.cbi.ListValue, 'mbusdParity1', {
      caption: L.tr('Parity'),
    }).depends({ 'ser2netconfig1': '1', 'Ser2netEnable1': '0' })
      .depends({ 'Ser2netEnable1': '4' })
      .value("0", L.tr("0:None"))
      .value("1", L.tr("1:Odd"))
      .value("2", L.tr("2:Even"));

    s.option(L.cbi.ListValue, 'mbusdNoOfStopbits1', {
      caption: L.tr('No of Stopbits'),
    }).depends({ 'ser2netconfig1': '1', 'Ser2netEnable1': '0' })
      .depends({ 'Ser2netEnable1': '4' })
      .value("1", L.tr("1"))
      .value("2", L.tr("2"));

    s.option(L.cbi.ListValue, 'mbusdDatabits1', {
      caption: L.tr('No of Databits'),
    }).depends({ 'ser2netconfig1': '1', 'Ser2netEnable1': '0' })
      .depends({ 'Ser2netEnable1': '4' })
      .value("7", L.tr("7"))
      .value("8", L.tr("8"));

    // s.option(L.cbi.DummyValue, 'modbustcpconfig1', {
    //   caption: L.tr(''),
    //   //  caption: L.tr(a),
    // }).depends({ 'ser2netconfig1': '1', 'Ser2netEnable1': '0' })
    //   .depends({ 'Ser2netEnable1': '4' })
    //   .ucivalue = function () {
    //     var id = "<h3><b>&nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp TCP Configuration </b> </h3>";
    //     return id;
    //   };
    s.option(L.cbi.SubHeadingValue, 'modbustcpconfig1', { caption: '' })
      .depends({ 'ser2netconfig1': '1', 'Ser2netEnable1': '0' })
      .depends({ 'Ser2netEnable1': '4' })
      .ucivalue = function () {
        return 'TCP Configuration';
      };



    s.option(L.cbi.InputValue, 'mbusdLocalInterfaceIP1', {
      caption: L.tr('Local Listener Interface IP Address'),
      datatype: 'ip4addr'
    }).depends({ 'ser2netconfig1': '1', 'Ser2netEnable1': '0' });

    s.option(L.cbi.InputValue, 'mbusdtcpport1', {
      caption: L.tr('TCP Port'),
      datatype: 'portrange'
    }).depends({ 'ser2netconfig1': '1', 'Ser2netEnable1': '0' });

    s.option(L.cbi.InputValue, 'mbusdmaxretries1', {
      caption: L.tr('Max. number retries'),
      datatype: 'uinteger'
    }).depends({ 'ser2netconfig1': '1', 'Ser2netEnable1': '0' })
      .depends({ 'Ser2netEnable1': '4' });

    s.option(L.cbi.InputValue, 'mbusddelaybetweeneachrequest1', {
      caption: L.tr('Delay between each request (In milliseconds)'),
      datatype: 'uinteger'
    }).depends({ 'ser2netconfig1': '1', 'Ser2netEnable1': '0' })
      .depends({ 'Ser2netEnable1': '4' });

    s.option(L.cbi.InputValue, 'mbusdresponsewaittime1', {
      caption: L.tr('Response wait time (In milliseconds)'),
      datatype: 'uinteger'
    }).depends({ 'ser2netconfig1': '1', 'Ser2netEnable1': '0' });

    s.option(L.cbi.InputValue, 'mbusdconnectiontimeout1', {
      caption: L.tr('Connection timeout (In seconds)'),
      datatype: 'uinteger'
    }).depends({ 'ser2netconfig1': '1', 'Ser2netEnable1': '0' });

    s.option(L.cbi.InputValue, 'mbusdinactivitytimeout1', {
      caption: L.tr('Inactivity timeout (In seconds)'),
      datatype: 'uinteger'
    }).depends({ 'ser2netconfig1': '1', 'Ser2netEnable1': '0' })
      .depends({ 'Ser2netEnable1': '4' });





    var t = m.section(L.cbi.TableSection, 'tcpClient_1', {
      caption: L.tr('TCP Remote Client Configuration: Port 1'),
      addremove: true,
      add_caption: L.tr('Add New Tcp Client for Port 1'),
      remove_caption: L.tr('Remove'),
      display: 'none'
    });

    t.option(L.cbi.InputValue, 'clientIP', {
      caption: L.tr('IP Address'),
      datatype: 'ip4addr',
      // width: "25%",
      optional: true
    });

    t.option(L.cbi.InputValue, 'clientPort', {
      caption: L.tr('Port'),
      datatype: 'uinteger',
      // width: "10%",
      optional: true
    });

    t.option(L.cbi.InputValue, 'SlaveID', {
      caption: L.tr('Slave ID'),
      datatype: 'uinteger',
      // width: "10%",
      optional: true
    });

    t.option(L.cbi.InputValue, 'ResponseWaitTime', {
      caption: "Response wait time <br>(In milliseconds)",
      datatype: 'uinteger',
      // width: "15%",
      optional: true
    });

    t.option(L.cbi.InputValue, 'ConnectionTimeout', {
      caption: "Connection timeout <br>(In seconds)",
      datatype: 'uinteger',
      // width: "15%",
      optional: true
    });

    t.commit = function () {
      self.updateportconfig('configure_port1').then(function (rv) {
        console.log('Port 1 Configuration Updated:', rv);
      });
    };

    m.insertInto('#section_port1');






    var self = this;
    var m2 = new L.cbi.Map('portconfig', {
    });
    var s1 = m2.section(L.cbi.NamedSection, 'portconfig2', {
      caption: L.tr('')
    });
    s1.option(L.cbi.ListValue, 'Ser2netEnable2', {
      caption: L.tr('Port Mode'),
      datatype: function (ev) {
        var enableTable1 = ev[0];
        document.getElementById('section_portconfig_tcpClient_2').style.display = "none";
        if (enableTable1 == "4") {
          document.getElementById('section_portconfig_tcpClient_2').style.display = "block";
        }
      }
    }).depends({ 'ser2netconfig2': '1' })
      .value("2", L.tr("None"))
      .value("1", L.tr("Transparent Serial to Remote Client"))
      .value("3", L.tr("Transparent Serial to Remote Server"))
      .value("0", L.tr("Modbus TCP Master to Modbus RTU Slave"))
      .value("4", L.tr("Modbus RTU Master to Modbus TCP Slave"));

    s1.option(L.cbi.InputValue, 'remoteserverip2', {
      caption: L.tr('Remote Server IP'),
    }).depends({ 'ser2netconfig2': '1', 'Ser2netEnable2': '3' });

    s1.option(L.cbi.InputValue, 'remoteserverport2', {
      caption: L.tr('Remote Server Port'),
    }).depends({ 'ser2netconfig2': '1', 'Ser2netEnable2': '3' });


    s1.option(L.cbi.ListValue, 'portmode2', {
      caption: L.tr('Transparent Serial Port Mode'),
    }).depends({ 'ser2netconfig2': '1', 'Ser2netEnable2': '1' })
      .depends({ 'Ser2netEnable2': '3' })
      .value("raw", L.tr("raw"))
      .value("rawlp", L.tr("rawlp"))
      .value("telnet", L.tr("telnet"))
      .value("off", L.tr("off"));

    s1.option(L.cbi.ListValue, 'timeout2', {
      caption: L.tr('Time Out'),
    }).depends({ 'ser2netconfig2': '1', 'Ser2netEnable2': '1' })
      .depends({ 'Ser2netEnable2': '3' })
      .value("0", L.tr("no time out"))
      .value("5", L.tr("5"))
      .value("10", L.tr("10"))
      .value("15", L.tr("15"));

    s1.option(L.cbi.InputValue, 'LocalInterfaceIP2', {
      caption: L.tr('Local Listener Interface IP Address'),
      datatype: 'ip4addr'
    }).depends({ 'ser2netconfig2': '1', 'Ser2netEnable2': '3' });

    s1.option(L.cbi.InputValue, 'tcpport2', {
      caption: L.tr('Local Listener TCP Port'),
    }).depends({ 'ser2netconfig2': '1', 'Ser2netEnable2': '1' })
      .depends({ 'Ser2netEnable2': '3' });



    s1.option(L.cbi.ListValue, 'Baudrate2', {
      caption: L.tr('Baud Rate'),
    }).depends({ 'ser2netconfig2': '1', 'Ser2netEnable2': '1' })
      .depends({ 'Ser2netEnable2': '3' })
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

    s1.option(L.cbi.ListValue, 'NoOfStopbits2', {
      caption: L.tr('No Of Stopbits'),
    }).depends({ 'ser2netconfig2': '1', 'Ser2netEnable2': '1' })
      .depends({ 'Ser2netEnable2': '3' })
      .value("1", L.tr("1"))
      .value("1.5", L.tr("1.5"))
      .value("2", L.tr("2"));

    s1.option(L.cbi.ListValue, 'Databits2', {
      caption: L.tr('No Of Databits'),
    }).depends({ 'ser2netconfig2': '1', 'Ser2netEnable2': '1' })
      .depends({ 'Ser2netEnable2': '3' })
      .value("8", L.tr("8"))
      .value("5", L.tr("5"))
      .value("6", L.tr("6"))
      .value("7", L.tr("7"));

    s1.option(L.cbi.ListValue, 'Parity2', {
      caption: L.tr('Parity'),
    }).depends({ 'ser2netconfig2': '1', 'Ser2netEnable2': '1' })
      .depends({ 'Ser2netEnable2': '3' })
      .value("NONE", L.tr("NONE"))
      .value("EVEN", L.tr("EVEN"))
      .value("ODD", L.tr("ODD"))
      .value("SPACE", L.tr("SPACE"))
      .value("MARK", L.tr("MARK"));

    s1.option(L.cbi.ListValue, 'Flowcontrol2', {
      caption: L.tr('Flow Control')
    }).depends({ 'ser2netconfig2': '1', 'Ser2netEnable2': '1' })
      .depends({ 'Ser2netEnable2': '3' })
      .value("RTSCTS", L.tr("RTSCTS"))
      .value("NONE", L.tr("NONE"))
      .value("DTRDSR", L.tr("DTRDSR"))
      .value("XONXOFF", L.tr("XONXOFF"));

    s1.option(L.cbi.CheckboxValue, 'readtraceenable2', {
      caption: L.tr('Read Trace'),
    }).depends({ 'ser2netconfig2': '1', 'Ser2netEnable2': '1' })
      .depends({ 'Ser2netEnable2': '3' });

    s1.option(L.cbi.CheckboxValue, 'writetraceenable2', {
      caption: L.tr('Write Trace'),
    }).depends({ 'ser2netconfig2': '1', 'Ser2netEnable2': '1' })
      .depends({ 'Ser2netEnable2': '3' });


    /* Port 1 Modbus TCP to RTU settings */

    s1.option(L.cbi.DummyValue, 'modbusserialconfig2', {
      caption: L.tr(''),
      //  caption: L.tr(a),
    }).depends({ 'ser2netconfig2': '1', 'Ser2netEnable2': '0' })
      .depends({ 'Ser2netEnable2': '4' })
      .ucivalue = function () {
        var id = "<h3><b>&nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp Serial Configuration </b> </h3>";
        return id;
      };

    s1.option(L.cbi.ListValue, 'mbusdBaudrate2', {
      caption: L.tr('Baud rate'),
    }).depends({ 'ser2netconfig2': '1', 'Ser2netEnable2': '0' })
      .depends({ 'Ser2netEnable2': '4' })
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

    s1.option(L.cbi.ListValue, 'mbusdParity2', {
      caption: L.tr('Parity'),
    }).depends({ 'ser2netconfig2': '1', 'Ser2netEnable2': '0' })
      .depends({ 'Ser2netEnable2': '4' })
      .value("0", L.tr("0:None"))
      .value("1", L.tr("1:Odd"))
      .value("2", L.tr("2:Even"));

    s1.option(L.cbi.ListValue, 'mbusdNoOfStopbits2', {
      caption: L.tr('No of Stopbits'),
    }).depends({ 'ser2netconfig2': '1', 'Ser2netEnable2': '0' })
      .depends({ 'Ser2netEnable2': '4' })
      .value("1", L.tr("1"))
      .value("2", L.tr("2"));

    s1.option(L.cbi.ListValue, 'mbusdDatabits2', {
      caption: L.tr('No of Databits'),
    }).depends({ 'ser2netconfig2': '1', 'Ser2netEnable2': '0' })
      .depends({ 'Ser2netEnable2': '4' })
      .value("7", L.tr("7"))
      .value("8", L.tr("8"));

    s1.option(L.cbi.DummyValue, 'modbustcpconfig2', {
      caption: L.tr(''),
      //  caption: L.tr(a),
    }).depends({ 'ser2netconfig2': '1', 'Ser2netEnable2': '0' })
      .depends({ 'Ser2netEnable2': '4' })
      .ucivalue = function () {
        var id = "<h3><b>&nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp TCP Configuration </b> </h3>";
        return id;
      };

    s1.option(L.cbi.InputValue, 'mbusdLocalInterfaceIP2', {
      caption: L.tr('Local Listener Interface IP Address'),
      datatype: 'ip4addr'
    }).depends({ 'ser2netconfig2': '1', 'Ser2netEnable2': '0' });

    s1.option(L.cbi.InputValue, 'mbusdtcpport2', {
      caption: L.tr('TCP Port'),
      datatype: 'portrange'
    }).depends({ 'ser2netconfig2': '1', 'Ser2netEnable2': '0' });

    s1.option(L.cbi.InputValue, 'mbusdmaxretries2', {
      caption: L.tr('Max. number retries'),
      datatype: 'uinteger'
    }).depends({ 'ser2netconfig2': '1', 'Ser2netEnable2': '0' })
      .depends({ 'Ser2netEnable2': '4' });

    s1.option(L.cbi.InputValue, 'mbusddelaybetweeneachrequest2', {
      caption: L.tr('Delay between each request (In milliseconds)'),
      datatype: 'uinteger'
    }).depends({ 'ser2netconfig2': '1', 'Ser2netEnable2': '0' })
      .depends({ 'Ser2netEnable2': '4' });

    s1.option(L.cbi.InputValue, 'mbusdresponsewaittime2', {
      caption: L.tr('Response wait time (In milliseconds)'),
      datatype: 'uinteger'
    }).depends({ 'ser2netconfig2': '1', 'Ser2netEnable2': '0' });

    s1.option(L.cbi.InputValue, 'mbusdconnectiontimeout2', {
      caption: L.tr('Connection timeout (In seconds)'),
      datatype: 'uinteger'
    }).depends({ 'ser2netconfig2': '1', 'Ser2netEnable2': '0' });

    s1.option(L.cbi.InputValue, 'mbusdinactivitytimeout2', {
      caption: L.tr('Inactivity timeout (In seconds)'),
      datatype: 'uinteger'
    }).depends({ 'ser2netconfig2': '1', 'Ser2netEnable2': '0' })
      .depends({ 'Ser2netEnable2': '4' });





    var t2 = m2.section(L.cbi.TableSection, 'tcpClient_2', {
      caption: L.tr('TCP Remote Client Configuration: Port 2'),
      addremove: true,
      add_caption: L.tr('Add New Tcp Client for Port 2'),
      remove_caption: L.tr('Remove'),
      display: 'none' // Initially hidden
    });

    t2.option(L.cbi.InputValue, 'clientIP2', {
      caption: L.tr('IP Address'),
      datatype: 'ip4addr',
      width: "25%",
      optional: true
    });

    t2.option(L.cbi.InputValue, 'clientPort2', {
      caption: L.tr('Port'),
      datatype: 'uinteger',
      width: "15%",
      optional: true
    });

    t2.option(L.cbi.InputValue, 'SlaveID2', {
      caption: L.tr('Slave ID'),
      datatype: 'uinteger',
      width: "15%",
      optional: true
    });

    t2.option(L.cbi.InputValue, 'ResponseWaitTime2', {
      caption: "Response wait time <br>(In milliseconds)",
      datatype: 'uinteger',
      width: "15%",
      optional: true
    });

    t2.option(L.cbi.InputValue, 'ConnectionTimeout2', {
      caption: "Connection timeout <br>(In seconds)",
      datatype: 'uinteger',
      width: "15%",
      optional: true
    });

    t2.commit = function () {
      self.updateportconfig('configure_port2').then(function (rv) {
        console.log('Port 2 Configuration Updated:', rv);
      });
    };

    m2.insertInto('#section_port2');





    //var self = this;
    //// document.getElementById('section_portconfig_tcpClient').style.display = "none";
    //// document.getElementById('section_portconfig_tcpClient2').style.display = "none";
    //// var m = new L.cbi.Map('portconfig', {});
    //var m = new L.cbi.Map('sysconfig', {
    //});     

    //var s = m.section(L.cbi.NamedSection, 'iii', {
    //caption:L.tr('')
    //});
    ////var m1 = new L.cbi.Map('portconfig', {
    ////});

    ////var s1 = m1.section(L.cbi.NamedSection, 'iiii', {
    ////caption: L.tr('')
    ////});

    //s.option(L.cbi.ListValue, 'Ser2netEnable2', {
    //caption: L.tr('Port Mode'),
    //datatype: function (ev) {
    //var enableTable1 = ev[0];
    //document.getElementById('section_sysconfig_tcpClient_2').style.display = "none";
    //if (enableTable1 == "4") {
    //document.getElementById('section_sysconfig_tcpClient_2').style.display = "block";
    //}
    //}
    //}).depends({ 'ser2netconfig2': '1' })
    //.value("2", L.tr("None"))
    //.value("1", L.tr("Transparent Serial to Remote Client"))
    //.value("3", L.tr("Transparent Serial to Remote Server"))
    //.value("0", L.tr("Modbus TCP Master to Modbus RTU Slave"))
    //.value("4", L.tr("Modbus RTU Master to Modbus TCP Slave"));


    //s.taboption('ser2netconfig2',L.cbi.InputValue,'remoteserverip1',{
    //caption: L.tr('Remote Server IP'),   
    //}).depends({'ser2netconfig2':'1','Ser2netEnable2':'3'});   

    //s.taboption('ser2netconfig2',L.cbi.InputValue,'remoteserverport1',{
    //caption: L.tr('Remote Server Port'),   
    //}).depends({'ser2netconfig2':'1','Ser2netEnable2':'3'});   


    //s.taboption('ser2netconfig2',L.cbi.ListValue,'portmode1',{                         
    //caption: L.tr('Transparent Serial Port Mode'),                         
    //}).depends({'ser2netconfig2':'1','Ser2netEnable2':'1'})
    //.depends({'ser2netconfig2':'3'})
    //.value("raw",L.tr("raw"))                                    
    //.value("rawlp",L.tr("rawlp"))                                    
    //.value("telnet",L.tr("telnet"))
    //.value("off",L.tr("off"));

    //s.taboption('ser2netconfig2',L.cbi.ListValue,'timeout1',{                         
    //caption: L.tr('Time Out'),                         
    //}).depends({'ser2netconfig2':'1','Ser2netEnable2':'1'})
    //.depends({'ser2netconfig2':'3'})
    //.value("0",L.tr("no time out"))                                    
    //.value("5",L.tr("5"))                                    
    //.value("10",L.tr("10"))
    //.value("15",L.tr("15"));

    //s.taboption('ser2netconfig2',L.cbi.InputValue,'LocalInterfaceIP1',{
    //caption: L.tr('Local Listener Interface IP Address'),
    //datatype:    'ip4addr'
    //}).depends({'ser2netconfig2':'1','Ser2netEnable2':'3'})
    //.depends({'ser2netconfig2':'1','Ser2netEnable2':'1'});


    //s.taboption('ser2netconfig2',L.cbi.InputValue,'tcpport1',{
    //caption: L.tr('Local Listener TCP Port'),   
    //}).depends({'ser2netconfig2':'1','Ser2netEnable2':'1'})
    //.depends({'Ser2netEnable2':'3'});          



    //s.taboption('ser2netconfig2',L.cbi.ListValue,'Baudrate1',{ 
    //caption: L.tr('Baud Rate'),   
    //}).depends({'ser2netconfig2':'1','Ser2netEnable2':'1'})
    //.depends({'ser2netconfig2':'3'})
    //.value("115200",L.tr("115200"))
    //.value("50",L.tr("50"))                                        
    //.value("75",L.tr("75"))                                        
    //.value("110",L.tr("110"))                                        
    //.value("134",L.tr("134"))                                        
    //.value("150",L.tr("150"))                                        
    //.value("300",L.tr("300"))                                        
    //.value("600",L.tr("600"))                                        
    //.value("1200",L.tr("1200"))                                        
    //.value("1800",L.tr("1800"))                                        
    //.value("2400",L.tr("2400"))                                        
    //.value("4800",L.tr("4800"))                                        
    //.value("7200",L.tr("7200"))                                        
    //.value("9600",L.tr("9600"))                                        
    //.value("19200",L.tr("19200"))                                        
    //.value("38400",L.tr("38400"))                                        
    //.value("57600",L.tr("57600"))                                                                                
    //.value("230.4k",L.tr("230.4k"))                                        
    //.value("460.8k",L.tr("460.8k"))                                        
    //.value("921.6k",L.tr("921.6k"));                                        

    //s.taboption('ser2netconfig2',L.cbi.ListValue,'NoOfStopbits1',{                                
    //caption: L.tr('No Of Stopbits'),                                  
    //}).depends({'ser2netconfig2':'1','Ser2netEnable2':'1'})
    //.depends({'ser2netconfig2':'3'})
    //.value("1",L.tr("1"))
    //.value("1.5",L.tr("1.5"))
    //.value("2",L.tr("2"));     

    //s.taboption('ser2netconfig2',L.cbi.ListValue,'Databits1',{                               
    //caption: L.tr('No Of Databits'),                            
    //}).depends({'ser2netconfig2':'1','Ser2netEnable2':'1'})
    //.depends({'Ser2netEnable2':'3'})
    //.value("8",L.tr("8"))                                             
    //.value("5",L.tr("5"))                                             
    //.value("6",L.tr("6"))                                             
    //.value("7",L.tr("7"));           

    //s.taboption('ser2netconfig2',L.cbi.ListValue,'Parity1',{                
    //caption: L.tr('Parity'),                  
    //}).depends({'ser2netconfig2':'1','Ser2netEnable2':'1'})
    //.depends({'Ser2netEnable2':'3'})
    //.value("NONE",L.tr("NONE"))                                    
    //.value("EVEN",L.tr("EVEN"))
    //.value("ODD",L.tr("ODD"))
    //.value("SPACE",L.tr("SPACE"))
    //.value("MARK",L.tr("MARK"));      

    //s.taboption('ser2netconfig2',L.cbi.ListValue,'Flowcontrol1' ,{                
    //caption: L.tr('Flow Control')                    
    //}).depends({'ser2netconfig2':'1','Ser2netEnable2':'1'})
    //.depends({'Ser2netEnable2':'3'})
    //.value("RTSCTS",L.tr("RTSCTS"))
    //.value("NONE",L.tr("NONE"))      
    //.value("DTRDSR",L.tr("DTRDSR"))      
    //.value("XONXOFF",L.tr("XONXOFF")); 

    //s.taboption('ser2netconfig2',L.cbi.CheckboxValue, 'readtraceenable1', {
    //caption:        L.tr('Read Trace'),         
    //}).depends({'ser2netconfig2':'1','Ser2netEnable2':'1'})
    //.depends({'Ser2netEnable2':'3'});

    //s.taboption('ser2netconfig2',L.cbi.CheckboxValue, 'writetraceenable1', {
    //caption:        L.tr('Write Trace'),         
    //}).depends({'ser2netconfig2':'1','Ser2netEnable2':'1'})
    //.depends({'Ser2netEnable2':'3'});


    ///* Port 1 Modbus TCP to RTU settings */

    //s.taboption('ser2netconfig2',L.cbi.DummyValue, 'modbusserialconfig', {
    //caption: L.tr(''),
    ////  caption: L.tr(a),
    //}).depends({'ser2netconfig2':'1','Ser2netEnable2':'0'})
    //.depends({'Ser2netEnable2':'4'})
    //.ucivalue=function()
    //{
    //var id="<h3><b>&nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp Serial Configuration </b> </h3>";
    //return id;
    //}; 

    //s.taboption('ser2netconfig2',L.cbi.ListValue,'mbusdBaudrate1',{ 
    //caption: L.tr('Baud rate'),   
    //}).depends({'ser2netconfig2':'1','Ser2netEnable2':'0'})
    //.depends({'Ser2netEnable2':'4'})
    //.value("110",L.tr("110"))                                  
    //.value("300",L.tr("300"))                                  
    //.value("600",L.tr("600"))                                  
    //.value("1200",L.tr("1200"))                                
    //.value("2400",L.tr("2400"))                                
    //.value("4800",L.tr("4800"))                                
    //.value("9600",L.tr("9600"))                                
    //.value("14400",L.tr("14400"))                              
    //.value("19200",L.tr("19200"))                              
    //.value("38400",L.tr("38400"))                              
    //.value("57600",L.tr("57600"))                              
    //.value("115200",L.tr("115200"))              
    //.value("128000",L.tr("128000"))              
    //.value("256000",L.tr("256000"));   

    //s.taboption('ser2netconfig2',L.cbi.ListValue,'mbusdParity1',{                
    //caption: L.tr('Parity'),                  
    //}).depends({'ser2netconfig2':'1','Ser2netEnable2':'0'})
    //.depends({'Ser2netEnable2':'4'})
    //.value("0",L.tr("0:None"))                                    
    //.value("1",L.tr("1:Odd"))
    //.value("2",L.tr("2:Even"));      

    //s.taboption('ser2netconfig2',L.cbi.ListValue,'mbusdNoOfStopbits1',{                                
    //caption: L.tr('No of Stopbits'),                                  
    //}).depends({'ser2netconfig2':'1','Ser2netEnable2':'0'})
    //.depends({'Ser2netEnable2':'4'})
    //.value("1",L.tr("1"))
    //.value("2",L.tr("2"));     

    //s.taboption('ser2netconfig2',L.cbi.ListValue,'mbusdDatabits1',{                               
    //caption: L.tr('No of Databits'),                            
    //}).depends({'ser2netconfig2':'1','Ser2netEnable2':'0'})
    //.depends({'Ser2netEnable2':'4'})
    //.value("7",L.tr("7"))                                             
    //.value("8",L.tr("8"));  

    //s.taboption('ser2netconfig2',L.cbi.DummyValue, 'modbustcpconfig1', {
    //caption: L.tr(''),
    ////  caption: L.tr(a),
    //}).depends({'ser2netconfig2':'1','Ser2netEnable2':'0'})
    //.depends({'Ser2netEnable2':'4'})
    //.ucivalue=function()
    //{
    //var id="<h3><b>&nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp TCP Configuration </b> </h3>";
    //return id;
    //};    

    //s.taboption('ser2netconfig2',L.cbi.InputValue,'mbusdtcpIP' ,{                            
    //caption: L.tr('TCP Slave Address'),
    //datatype:    'ip4addr'                                
    //}).depends({'ser2netconfig2':'1'})
    //.depends({'Ser2netEnable2':'4'}); 

    //s.taboption('ser2netconfig2',L.cbi.InputValue,'mbusdtcpslaveport1' ,{                            
    //caption: L.tr('TCP Slave Port'),
    //datatype:    'portrange'                                
    //}).depends({'ser2netconfig2':'1'})
    //.depends({'Ser2netEnable2':'4'});  

    //s.taboption('ser2netconfig2',L.cbi.InputValue,'mbusdLocalInterfaceIP1',{
    //caption: L.tr('Local Listener Interface IP Address'),
    //datatype:    'ip4addr'
    //}).depends({'ser2netconfig2':'1','Ser2netEnable2':'0'});

    //s.taboption('ser2netconfig2',L.cbi.InputValue,'mbusdtcpport2' ,{                            
    //caption: L.tr('TCP Port'),
    //datatype:    'portrange'                                
    //}).depends({'ser2netconfig2':'1','Ser2netEnable2':'0'});   

    //s.taboption('ser2netconfig2',L.cbi.InputValue,'mbusdmaxretries2' ,{                            
    //caption: L.tr('Max. number retries'),
    //datatype: 'uinteger'                                
    //}).depends({'ser2netconfig2':'1','Ser2netEnable2':'0'})
    //.depends({'Ser2netEnable2':'4'}); 

    //s.taboption('ser2netconfig2',L.cbi.InputValue,'mbusddelaybetweeneachrequest2' ,{                            
    //caption: L.tr('Delay between each request (In milliseconds)'),
    //datatype: 'uinteger'                               
    //}).depends({'ser2netconfig2':'1','Ser2netEnable2':'0'})
    //.depends({'Ser2netEnable2':'4'}); 

    //s.taboption('ser2netconfig2',L.cbi.InputValue,'mbusdresponsewaittime2' ,{                            
    //caption: L.tr('Response wait time (In milliseconds)'),
    //datatype: 'uinteger'                                
    //}).depends({'ser2netconfig2':'1','Ser2netEnable2':'0'})
    //.depends({'Ser2netEnable2':'4'}); 

    //s.taboption('ser2netconfig2',L.cbi.InputValue,'mbusdconnectiontimeout2' ,{                            
    //caption: L.tr('Connection timeout (In seconds)'),
    //datatype: 'uinteger'                                
    //}).depends({'ser2netconfig2':'1','Ser2netEnable2':'0'})
    //.depends({'Ser2netEnable2':'4'});  

    //s.taboption('ser2netconfig2',L.cbi.InputValue,'mbusdinactivitytimeout2' ,{                            
    //caption: L.tr('Inactivity timeout (In seconds)'),
    //datatype: 'uinteger'                                
    //}).depends({'ser2netconfig2':'1','Ser2netEnable2':'0'})
    //.depends({'Ser2netEnable2':'4'});  







    //// TCP Remote Client Configuration: Port 2
    //var t1 = m.section(L.cbi.TableSection, 'tcpClient_2', {
    //caption: L.tr('TCP Remote Client Configuration: Port 2'),
    //addremove: true,
    //add_caption: L.tr('Add New Tcp Client for Port 2'),
    //remove_caption: L.tr('Remove'),
    //display: 'none' // Initially hidden
    //});

    //t1.option(L.cbi.InputValue, 'clientIP2', {
    //caption: L.tr('IP Address'),
    //datatype: 'ip4addr',
    //width: "25%",
    //optional: true
    //});

    //t1.option(L.cbi.InputValue, 'clientPort2', {
    //caption: L.tr('Port'),
    //datatype: 'uinteger',
    //width: "15%",
    //optional: true
    //});

    //t1.option(L.cbi.InputValue, 'SlaveID2', {
    //caption: L.tr('Slave ID'),
    //datatype: 'uinteger',
    //width: "15%",
    //optional: true
    //});

    //t1.option(L.cbi.InputValue, 'ResponseWaitTime2', {
    //caption: "Response wait time <br>(In milliseconds)",
    //datatype: 'uinteger',
    //width: "15%",
    //optional: true
    //});

    //t1.option(L.cbi.InputValue, 'ConnectionTimeout2', {
    //caption: "Connection timeout <br>(In seconds)",
    //datatype: 'uinteger',
    //width: "15%",
    //optional: true
    //});

    //t1.commit = function () {
    //self.updateportconfig('configure_port2').then(function (rv) {
    //console.log('Port 2 Configuration Updated:', rv);
    //});
    //};


    //m.insertInto('#section_port2');


    s.commit = function () {
      self.updateportconfig('configure').then(function (rv) {

      });
    }
  },


  disableDIOPage: function () {
    var self = this
    console.log("Entred Disable state")
    const wrapper = document.getElementById("portContentWrapper");
    const overlay = document.getElementById("portDisabledOverlay");

    if (wrapper) wrapper.classList.add("port-blurred");
    if (overlay) overlay.style.display = "flex";
  },

  enableDIOPage: function () {
    var self = this
    const wrapper = document.getElementById("portContentWrapper");
    const overlay = document.getElementById("portDisabledOverlay");

    if (wrapper) wrapper.classList.remove("port-blurred");
    if (overlay) overlay.style.display = "none";
  },

  checkDeviceApplicationState: function () {

    var self = this;
    let params = window.location.href;
    let BaseURL = new URL(params).origin;

    //fetch(`https://mocki.io/v1/4dcb50ef-c948-4730-a29a-3f98db97cb11`)
    fetch(`${BaseURL}:30008/device/applications/`)
      .then(res => res.json())
      .then(apps => {
        const portApp = apps.find(app => app.id === 'modbus');

        if (portApp && portApp.state === 'disabled') {
          self.enableDIOPage();

        } else {
          self.disableDIOPage();
        }
      })
      .catch(err => {
        console.error('Execute API failed:', err);

      });
  },

  execute: function () {

    var self = this;

    self.checkDeviceApplicationState()
    self.renderport()
    // return m.insertInto('#map');
  }
});
