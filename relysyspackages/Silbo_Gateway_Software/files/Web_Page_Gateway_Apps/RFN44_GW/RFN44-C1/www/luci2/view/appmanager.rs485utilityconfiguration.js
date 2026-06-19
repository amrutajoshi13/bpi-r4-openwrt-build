L.ui.view.extend({

        RunUdev: L.rpc.declare({
                object: 'command',
                method: 'exec',
                params: ['command', 'args'],
        }),

        fGetUCISections: L.rpc.declare({
                object: 'uci',
                method: 'get',
                params: ['config', 'type', 'section']
        }),

        updateinterfaceconfig: L.rpc.declare({
                object: 'rpc-rs485utilityupdate',
                method: 'configure',
                params: ['application', 'action'],
                expect: { output: '' }
        }),
        MiscUtilGetUCISections: L.rpc.declare({
                object: 'uci',
                method: 'get',
                params: ['config', 'type'],
                expect: { values: {} }
        }),

        title: L.tr('Modbus Utility Configuration'),

        execute: function () {
                var self = this;

                self.MiscUtilGetUCISections("applist_config", "command").then(function (rv) {
                        for (var key in rv) {
                                if (rv.hasOwnProperty(key)) {
                                        var obj = rv[key];
                                        var AppStatus = obj.running;
                                        if (AppStatus != 0) {
                                                var ErrorMsg = "Please stop the applications before running the modbus utility";
                                                document.getElementById('addButton').style.display = 'none'
                                                document.getElementById('map').style.display = 'none'
                                                $("#modbus_utility_output").empty().show();
                                                $("#modbus_utility_output").append(ErrorMsg);

                                        }
                                }
                        }
                });

                var m = new L.cbi.Map('RS485UtilityConfigGeneric', {
                        caption: L.tr('')
                });

                var s = m.section(L.cbi.NamedSection, 'rs485utilityconfig', {
                        caption: L.tr('Modbus  Utility Configuration Settings')
                });

                s.option(L.cbi.InputValue, 'Slaveid', {
                        caption: L.tr('Slave ID'),
                        placeholder: '0',
                        optional: true
                });


                s.option(L.cbi.ListValue, 'ModbusProtocol', {
                        caption: L.tr('Modbus Protocol'),
                }).value("RTU", L.tr("RTU"))
                        .value("TCP", L.tr("TCP"));


                s.option(L.cbi.ListValue, 'Mode', {
                        caption: L.tr('Mode'),
                }).value("1", L.tr("Read"))
                        .value("2", L.tr("Write"))
                        .depends({ 'ModbusProtocol': 'RTU' });

                s.option(L.cbi.CheckboxValue, 'StdModbusEnable', {
                        caption: L.tr('Standard Modbus Address Translation Enable')
                });

                s.option(L.cbi.InputValue, 'StartRegister', {
                        caption: L.tr('Start Register'),
                });

                s.option(L.cbi.InputValue, 'NumberOfRegisters', {
                        caption: L.tr('No of Register'),
                });

                s.option(L.cbi.ListValue, 'FunctionalCode', {
                        caption: L.tr('Read Function code'),
                }).value("1", L.tr("1-Read Coils"))
                        .value("2", L.tr("2-Read Discrete Inputs"))
                        .value("3", L.tr("3-Read Holding Registers"))
                        .value("4", L.tr("4-Read Input Registers"))
                        .depends({ 'Mode': '1' });




                s.option(L.cbi.ListValue, 'FunctionalCode1', {
                        caption: L.tr('Write Function code'),
                }).value("5", L.tr("5-Write Single Coil"))
                        .value("6", L.tr("6-Write Single Register"))
                        .value("15", L.tr("15-Write Multiple Coils"))
                        .value("16", L.tr("16-Write Multiple Registers"))
                        .depends({ 'Mode': '2' });

                s.option(L.cbi.InputValue, 'DataForMode2', {
                        caption: L.tr('Data To Write'),
                }).depends({ 'ModbusProtocol': 'RTU', 'Mode': '2' });






                /*  s.option(L.cbi.ListValue,'ModbusProtocol' ,{
                         caption: L.tr('Modbus Protocol'),
                      }).value("RTU",L.tr("RTU"))
                        .value("TCP",L.tr("TCP"));*/

                s.option(L.cbi.InputValue, 'modbusCommip', {
                        caption: L.tr('Modbus Communication IP'),
                }).depends({ 'ModbusProtocol': 'TCP' });

                s.option(L.cbi.InputValue, 'modbusCommport', {
                        caption: L.tr('Modbus Communication Port'),
                }).depends({ 'ModbusProtocol': 'TCP' });

                s.option(L.cbi.InputValue, 'modbusCommtimeout', {
                        caption: L.tr('Modbus Communication Timeout'),
                }).depends({ 'ModbusProtocol': 'TCP' });



                s.option(L.cbi.ListValue, 'Baudrate', {
                        caption: L.tr('Baud rate'),
                }).value("110", L.tr("110"))
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
                        .value("256000", L.tr("256000"))
                        .depends({ 'ModbusProtocol': 'RTU' });

                s.option(L.cbi.ListValue, 'Stopbits', {
                        caption: L.tr('No of Stopbits'),
                }).value("1", L.tr("1"))
                        .value("2", L.tr("2"))
                        .depends({ 'ModbusProtocol': 'RTU' });

                s.option(L.cbi.ListValue, 'Databits', {
                        caption: L.tr('No of Databits'),
                }).value("7", L.tr("7"))
                        .value("8", L.tr("8"))
                        .depends({ 'ModbusProtocol': 'RTU' });

                s.option(L.cbi.ListValue, 'Parity', {
                        caption: L.tr('Parity'),
                }).value("0", L.tr("0-None"))
                        .value("1", L.tr("1-Odd"))
                        .value("2", L.tr("2-Even"))
                        .depends({ 'ModbusProtocol': 'RTU' });

                s.option(L.cbi.ListValue, 'SerialPort', {
                        caption: L.tr('Serial Port')
                }).value("/dev/ttyS1", L.tr("RS485 Port-1"))
                        .value("/dev/ttyS2", L.tr("RS485 Port-2"))
                        .depends({ 'ModbusProtocol': 'RTU' });


                s.option(L.cbi.ListValue, 'DataType', {
                        caption: L.tr('Data Type'),
                }).value("0", L.tr("Hexadecimal"))
                        .value("11", L.tr("1-bit"))
                        .value("22", L.tr("Boolean"))
                        .value("25", L.tr("INT-8 (Higher byte)"))
                        .value("26", L.tr("INT-8 (Lower byte)"))
                        .value("5", L.tr("INT-16 (byte order 1,2)"))
                        .value("6", L.tr("INT-16 (byte order 2,1)"))
                        .value("9", L.tr("INT-32 (byte order 1,2,3,4)"))
                        .value("10", L.tr("INT-32 (byte order 4,3,2,1)"))
                        .value("14", L.tr("INT-32 (byte order 3,4,1,2)"))
                        .value("15", L.tr("INT-32 (byte order 2,1,4,3)"))
                        .value("19", L.tr("INT Long (byte order 1-8)"))
                        .value("23", L.tr("UINT-8 (Higher byte)"))
                        .value("24", L.tr("UINT-8 (Lower byte)"))
                        .value("3", L.tr("UINT-16 (byte order 1,2)"))
                        .value("4", L.tr("UINT-16 (byte order 2,1)"))
                        .value("7", L.tr("UINT-32 (byte order 1,2,3,4)"))
                        .value("8", L.tr("UINT-32 (byte order 4,3,2,1)"))
                        .value("12", L.tr("UINT-32 (byte order 3,4,1,2)"))
                        .value("13", L.tr("UINT-32 (byte order 2,1,4,3)"))
                        .value("18", L.tr("UINT Long (byte order 1-8)"))
                        .value("1", L.tr("Float (byte order 1,2,3,4)"))
                        .value("16", L.tr("Float (byte order 4,3,2,1)"))
                        .value("2", L.tr("Float (byte order 3,4,1,2)"))
                        .value("17", L.tr("Float (byte order 2,1,4,3)"))
                        .value("20", L.tr("Double (byte order 1-8)"))
                        .value("21", L.tr("Hex-String"));





                s.commit = function () {
                        self.fGetUCISections('RS485UtilityConfigGeneric', 'rs485utilityconfig').then(function (rv) {

                        });

                }

                $("#addButton").click(function () {
                        $("#rs485info").css("display", "none");
                        self.updateinterfaceconfig('Update', 'updateinterface').then(function (rv) {

                                $("#rs485info").css("display", "block");
                                fetch('/RS485_utility.txt')
                                        .then(response => {
                                                if (!response.ok) {
                                                        throw new Error('Failed to load the text file');
                                                }
                                                return response.text(); // Use text() to handle plain text
                                        })
                                        .then(data => {
                                                $("#rs485info").css("display", "block");
                                                $("#rs485info").val(data); // Display the text data
                                        })
                                        .catch(error => {
                                                console.error('Error:', error);
                                                $("#rs485info").css("display", "block");
                                                $("#rs485info").val("Failed to load text file: " + error.message);
                                        });
                        });
                });

                return m.insertInto('#map');




        }
})

