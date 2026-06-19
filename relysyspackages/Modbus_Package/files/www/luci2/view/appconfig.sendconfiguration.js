L.ui.view.extend({
	
	title: L.tr('Data Sender Configuration'),
	description: L.tr(''),	
	
	SGetUCISections: L.rpc.declare({
		object: 'uci',
		method: 'get',
		params: [ 'config', 'type' ],
		expect: { values: {} }
	}),
	
	SCreateUCISection:  L.rpc.declare({
		object: 'uci',
		method: 'add',
		params: [ 'config', 'type', 'values' ]
	}),


	configTypeAddsection:L.rpc.declare({
		object: 'uci',
		method: 'add',
		params: [ 'config', 'type','name', 'values' ]
	}),
		
	
	SDeleteUCISection:  L.rpc.declare({
		object: 'uci',
		method: 'delete',
		params: [ 'config','type','section' ]
	}),
	
	
	SCommitUCISection:  L.rpc.declare({
		object: 'uci',
		method: 'commit',
		params: [ 'config' ]
	}),
	
	SCreateForm: function(mapwidget, fSectionID, fSectionType)
	{
		var self = this;
		
		if (!mapwidget)
			mapwidget = L.cbi.Map;
		
		// if(fSectionType == "Dredirect") {
		// 	var FormContent = self.pfCreateFormCallback;
		// }else if(fSectionType == "Sredirect") {
		// 	var FormContent = self.snCreateFormCallback;
		// }else if(fSectionType == "Drule") {
		// 	var FormContent =self.rlCreateFormCallback;
		// }else if(fSectionType == "Srule") {
		// 	var FormContent =self.pcCreateFormCallback;
		if(fSectionType == "Modbus") {
			var FormContent =self.SMCreateFormCallback;
		}
        else if(fSectionType == "Dio") {
				var FormContent =self.SDCreateFormCallback;
		}
		else if(fSectionType == "Ai") {
			var FormContent =self.SACreateFormCallback;
		}
		else if(fSectionType == "RS232") {
			var FormContent =self.RS232CreateFormCallback;
		}
		else if(fSectionType == "snmp") {
			var FormContent =self.SNMPCreateFormCallback;
		}
		else if(fSectionType == "Tmp") {
			var FormContent =self.STCreateFormCallback;
		}
		var map = new mapwidget('Jsonconfig', {
			prepare:    FormContent,
			fSection:   fSectionID
		});
		
		return map;
	},
	
	SSectionEdit: function(ev) {
		var self = ev.data.self;
		var fSectionID = ev.data.fSectionID;
		var fSectionType = ev.data.fSectionType;
		
		return self.SCreateForm(L.cbi.Modal, fSectionID, fSectionType).show();
	},

	// //////////////////////////MDS///////////////////////////////////

	SMCreateFormCallback: function()
	{
		var map = this;
		var fSectionID = map.options.fSection;
		
		map.options.caption = L.tr('Zone Forwarding');
		
		var s = map.section(L.cbi.SingleSection, fSectionID, {
			anonymous:   true,
			 tabbed:      true
		});
	
		
		
		s.option(L.cbi.ListValue, 'ModbusParameter', {
			caption:     L.tr('Field Content'),
		}) .value("SiteID",L.tr("SiteID"))                                  
		.value("ReadTimeStamp",L.tr("ReadTimeStamp"))                                  
		.value("EpochTimeStamp",L.tr("EpochTimeStamp"))                                  
		.value("EMeterRS485RecordNumber",L.tr("RecordNumber"))                                
		.value("RecordType",L.tr("RecordType"))                                
		.value("EMeterRS485RequestId",L.tr("RequestId"))                                
		.value("EMeterRS485InterfaceId",L.tr("SerialPortNumber"))                                
		.value("EMeterRS485CommIP",L.tr("TCPCommIP"))                                
		.value("EMeterRS485MeterID",L.tr("EquipmentID"))                              
		.value("EMeterRS485MeterModel",L.tr("EquipmentModel"))                              
		.value("EMeterRS485SlaveID",L.tr("SlaveID"))                              
		.value("FunctionCodeUsed",L.tr("FunctionCode"))                              
		.value("EMeterRS485ResponseCode",L.tr("EquipmentCommStatus"))              
		.value("StartingRS485RegisterAddress",L.tr("StartRegister"))              
		.value("NoOfRegisters",L.tr("NoOfRegisters"))
		.value("EMeterREG2",L.tr("EquipmentData"))
		.value("AlarmStatus",L.tr("AlarmStatus"))
		.value("EventStatus",L.tr("EventStatus"))
		.value("NetworkOperator",L.tr("NetworkOperator"))
		.value("NetworkMode",L.tr("NetworkMode"))
		.value("signalstrength",L.tr("SignalStrength"))
		.value("imei",L.tr("IMEI"))
        .value("SerialNumber",L.tr("SerialNumber"))
		.value("RS485Customfield1",L.tr("ModbusCustomfield1"))
		.value("RS485Customfield2",L.tr("ModbusCustomfield2"))
		.value("RS485Customfield3",L.tr("ModbusCustomfield3"))
		.value("RS485Customfield4",L.tr("ModbusCustomfield4"))
		.value("RS485Customfield5",L.tr("ModbusCustomfield5"))
		.value("RS485Customfield6",L.tr("ModbusCustomfield6"))
		.value("RS485Customfield7",L.tr("ModbusCustomfield7"))
		.value("RS485Customfield8",L.tr("ModbusCustomfield8"))
		.value("RS485Customfield9",L.tr("ModbusCustomfield9"))
		.value("RS485Customfield10",L.tr("ModbusCustomfield10"));

		
		s.option(L.cbi.InputValue,'Parameterkey' ,{                            
			caption: L.tr('Field JSON Key Name')                                
	    });
	    
	    s.option(L.cbi.InputValue,'Parametervalue' ,{                            
			caption: L.tr('Field JSON Key Value')                                
	    }).depends({'ModbusParameter':'RS485Customfield1'})
	     .depends({'ModbusParameter':'RS485Customfield2'})
	     .depends({'ModbusParameter':'RS485Customfield3'})
	     .depends({'ModbusParameter':'RS485Customfield4'})
	     .depends({'ModbusParameter':'RS485Customfield5'})
	     .depends({'ModbusParameter':'RS485Customfield6'})
	     .depends({'ModbusParameter':'RS485Customfield7'})
	     .depends({'ModbusParameter':'RS485Customfield8'})
	     .depends({'ModbusParameter':'RS485Customfield9'})
	     .depends({'ModbusParameter':'RS485Customfield10'});
	     
	    //s.option(L.cbi.InputValue,'RS485CustomParam1' ,{                            
			//caption: L.tr('Field JSON Key Value')                                
	    //}).depends({'ModbusParameter':'RS485Customfield1'});
	    //s.option(L.cbi.InputValue,'RS485CustomParam2' ,{                            
			//caption: L.tr('Field JSON Key Value')                                
	    //}).depends({'ModbusParameter':'RS485Customfield2'});
	     
	    //s.option(L.cbi.InputValue,'RS485CustomParam3' ,{                            
			//caption: L.tr('Field JSON Key Value')                                
	    //}).depends({'ModbusParameter':'RS485Customfield3'});
	     
	    //s.option(L.cbi.InputValue,'RS485CustomParam4' ,{                            
			//caption: L.tr('Field JSON Key Value')                                
	    //}).depends({'ModbusParameter':'RS485Customfield4'});
	     
	    //s.option(L.cbi.InputValue,'RS485CustomParam5' ,{                            
			//caption: L.tr('Field JSON Key Value')                                
	    //}).depends({'ModbusParameter':'RS485Customfield5'});
	     
	},
		
	SMRenderContents: function(rv)
	{
		var self = this;

		var list2 = new L.ui.table({
				columns: [{
					caption: L.tr('Fieldnumber'),
					align: 'left',
					format: function(v, n) {
							var div = $('<p />').attr('id', 'RS485DeviceSerialNo_%s'.format(n));
							var serialNo=n+1;
		                    return div.append('<strong>'+serialNo+'<strong>');
					}
				 },  			
			
			{ 
				caption: L.tr('Field Content'),
				format:  function(v,n) {
					var div = $('<small />').attr('id', 'zfSource_%s'.format(n));
					return div.append(v);
				}
			},{ 
				caption: L.tr('JSON Key Name'),
				format:  function(v,n) {
					var div = $('<small />').attr('id', 'zfDestination_%s'.format(n));
					return div.append(v);
				}
			},{
				caption: L.tr('Actions'),
				format:  function(v, n) {
					return $('<div />')
						.addClass('btn-group btn-group-sm')
						.append(L.ui.button(L.tr('Edit'), 'primary', L.tr('Edit Configuration'))
							.click({ self: self, fSectionID: v, fSectionType: "Modbus" }, self.SSectionEdit))
						.append(L.ui.button(L.tr('Delete'), 'danger', L.tr('Delete Configuration'))
							.click({ self: self, fSectionID: v }, self.SMSectionRemove));
				}
			}]
		});
		
		for (var key in rv) {                                                                           
			if (rv.hasOwnProperty(key)) {            
				var obj = rv[key];                                                
				var Modbus = obj.ModbusParameter;
				var Parameter = obj.Parameterkey;

				var data = {
					"SiteID": "SiteID",
					"ReadTimeStamp": "ReadTimeStamp",
					"EpochTimeStamp": "EpochTimeStamp",
					"EMeterRS485RecordNumber": "RecordNumber",
					"RecordType": "RecordType",
					"EMeterRS485RequestId": "RequestId",
					"EMeterRS485InterfaceId": "SerialPortNumber",
					"EMeterRS485CommIP": "TCPCommIP",
					"EMeterRS485MeterID": "EquipmentID",
					"EMeterRS485MeterModel": "EquipmentModel",
					"EMeterRS485SlaveID": "SlaveID",
					"FunctionCodeUsed": "FunctionCode",
					"EMeterRS485ResponseCode": "EquipmentCommStatus",
					"StartingRS485RegisterAddress": "StartRegister",
					"NoOfRegisters": "NoOfRegisters",
					"EMeterREG2": "EquipmentData",
					"AlarmStatus": "AlarmStatus",
					"EventStatus": "EventStatus",
					"NetworkOperator": "NetworkOperator",
					"NetworkMode": "NetworkMode",
					"signalstrength": "SignalStrength",
					"imei": "IMEI",
                    "SerialNumber": "SerialNumber",                                                                 
					"RS485Customfield1": "ModbusCustomfield1",
					"RS485Customfield2": "ModbusCustomfield2",
					"RS485Customfield3": "ModbusCustomfield3",
					"RS485Customfield4": "ModbusCustomfield4",
					"RS485Customfield5": "ModbusCustomfield5",
					"RS485Customfield6": "ModbusCustomfield6",
					"RS485Customfield7": "ModbusCustomfield7",
					"RS485Customfield8": "ModbusCustomfield8",
					"RS485Customfield9": "ModbusCustomfield9",
					"RS485Customfield10": "ModbusCustomfield10"
					
				};
				list2.row([key,data[Modbus],Parameter, key ]);
			}                                                                   
		
		
		}
		$('#section_firewall_zonefor').
			append(list2.render());		
		
	},

	SMSectionRemove: function(ev) {
		var self = ev.data.self;
		var zfSectionID = ev.data.fSectionID;
		
		
		self.SDeleteUCISection("Jsonconfig","JsonRs485Indexconfig",zfSectionID).then(function(rv){
			if(rv == 0){

				self.SCommitUCISection("Jsonconfig").then(function(res){
					if (res != 0){
						alert("Error: Delete Zone Forwarding");
					}
					else {
						document.cookie="LastActiveTab=TabZf";
						document.cookie="LastAction=delete";
						location.reload();
					}
					
				});
			};
		});
	},
	
	SMSectionAdd: function () 
	{
		var self = this;
		var zfSource = $('#field_firewall_zone_newZone_src').val();
		var zfDestination = $('#field_firewall_zone_newZone_destzone').val();
		var serialNumber = $('#section_firewall_zonefor tr').length + 0;
		// var AsrTocheck=false;

		if (zfDestination)
		{
        var SectionOptions = {SerialNumber: serialNumber,ModbusParameter:zfSource,Parameterkey:zfDestination};
		this.SCreateUCISection("Jsonconfig","JsonRs485Indexconfig",SectionOptions).then(function(rv){
			if(rv){
				if (rv.section){
					self.SCommitUCISection("Jsonconfig").then(function(res){
						if (res != 0) {
							alert("Error: New Zone Forwarding");
						}
						else {
							document.cookie="LastActiveTab=TabZf";
							document.cookie="LastAction=add";
							location.reload();
						}
					});
					
				};
			};
		});
	}
	else
	{
		alert("Please Enter JsonKey")
	}
		
	},

	// //////////////////////////DIO///////////////////////////////////

	SDCreateFormCallback: function()
	{
		var map = this;
		var fSectionID = map.options.fSection;
		
		map.options.caption = L.tr('Dio Forwarding');
		
		var s = map.section(L.cbi.SingleSection, fSectionID, {
			anonymous:   true,
			 tabbed:      true
		});
	
		
		
		s.option(L.cbi.ListValue, 'ModbusParameter', {
			caption:     L.tr('Field Content'),
		}) .value("SiteID",L.tr("SiteID"))                                  
		.value("ReadTimeStamp",L.tr("ReadTimeStamp"))                                  
		.value("EpochTimeStamp",L.tr("EpochTimeStamp"))                                  
		.value("DIRecordNumber",L.tr("RecordNumber"))                                
		.value("DIRequestId",L.tr("RequestId"))                                
		.value("DIRecordType",L.tr("Recordtype"))                                
		.value("DIValues1",L.tr("DIInput1"))                                
		.value("DIValues2",L.tr("DIInput2"))                              
		.value("DIValues3",L.tr("DIInput3"))                              
		.value("DIValues4",L.tr("DIInput4"))
		.value("DIOCustomfield1",L.tr("DIOCustomfield1"))
		.value("DIOCustomfield2",L.tr("DIOCustomfield2"))
		.value("DIOCustomfield3",L.tr("DIOCustomfield3"))
		.value("DIOCustomfield4",L.tr("DIOCustomfield4"))
		.value("DIOCustomfield5",L.tr("DIOCustomfield5"));
		                         
		
		
		s.option(L.cbi.InputValue,'Parameterkey' ,{                            
			caption: L.tr('Field JSON Key Name')                                
	    });
	    
	    
	      s.option(L.cbi.InputValue,'Parametervalue' ,{                            
			caption: L.tr('Field JSON Key Value')                                
	    }).depends({'ModbusParameter':'DIOCustomfield1'})
	     .depends({'ModbusParameter':'DIOCustomfield2'})
	     .depends({'ModbusParameter':'DIOCustomfield3'})
	     .depends({'ModbusParameter':'DIOCustomfield4'})
	     .depends({'ModbusParameter':'DIOCustomfield5'});
	     
	
	},
		
	SDRenderContents: function(rv)
	{
		var self = this;

		var list3 = new L.ui.table({
				columns: [{
					caption: L.tr('Fieldnumber'),
					align: 'left',
					format: function(v, n) {
							var div = $('<p />').attr('id', 'RS485DeviceSerialNo_%s'.format(n));
							var serialNo=n+1;
		                    return div.append('<strong>'+serialNo+'<strong>');
					}
				 },  			
			
			{ 
				caption: L.tr('Field Content'),
				format:  function(v,n) {
					var div = $('<small />').attr('id', 'zfSource_%s'.format(n));
					return div.append(v);
				}
			},{ 
				caption: L.tr('JSON Key Name'),
				format:  function(v,n) {
					var div = $('<small />').attr('id', 'zfDestination_%s'.format(n));
					return div.append(v);
				}
			},{
				caption: L.tr('Actions'),
				format:  function(v, n) {
					return $('<div />')
						.addClass('btn-group btn-group-sm')
						.append(L.ui.button(L.tr('Edit'), 'primary', L.tr('Edit Configuration'))
							.click({ self: self, fSectionID: v, fSectionType: "Dio" }, self.SSectionEdit))
						.append(L.ui.button(L.tr('Delete'), 'danger', L.tr('Delete Configuration'))
							.click({ self: self, fSectionID: v }, self.SDSectionRemove));
				}
			}]
		});
		
		for (var key in rv) {                                                                           
			if (rv.hasOwnProperty(key)) {            
				var obj = rv[key];                                                
				var Modbus1 = obj.ModbusParameter;
				var Parameter1 = obj.Parameterkey;

				var data = {
					"SiteID": "SiteID",
					"ReadTimeStamp": "ReadTimeStamp",
					"EpochTimeStamp": "EpochTimeStamp",
					"DIRecordNumber": "RecordNumber",
					"DIRequestId": "RequestId",
					"DIRecordType": "Recordtype",
					"DIValues1": "DIInput1",
					"DIValues2": "DIInput2",
					"DIValues3": "DIInput3",
					"DIValues4": "DIInput4",
					"DIOCustomfield1": "DIOCustomfield1",
					"DIOCustomfield2": "DIOCustomfield2",
					"DIOCustomfield3": "DIOCustomfield3",
					"DIOCustomfield4": "DIOCustomfield4",
					"DIOCustomfield5": "DIOCustomfield5"
					
				};
				list3.row([key,data[Modbus1],Parameter1, key ]);
			}                                                                   
		
		
		}
		$('#sectiontab_dio_sender').
			append(list3.render());		
		
	},

	SDSectionRemove: function(ev) {
		var self = ev.data.self;
		var dfSectionID = ev.data.fSectionID;
		
		
		self.SDeleteUCISection("Jsonconfig","DioIndexconfig",dfSectionID).then(function(rv){
			if(rv == 0){

				self.SCommitUCISection("Jsonconfig").then(function(res){
					if (res != 0){
						alert("Error: Delete Zone Forwarding");
					}
					else {
						document.cookie="LastActiveTab=Tabdf";
						document.cookie="LastAction=delete";
						location.reload();
					}
					
				});
			};
		});
	},
	
	SDSectionAdd: function () 
	{
		var self = this;
		var dfSource = $('#field_dio_sender_zone_src').val();
		var dfDestination = $('#field_dio_sender_zone_destzone').val();
		//var serialNumber = $('#section_firewall_zonefor tr').length + 0;
		// var AsrTocheck=false;

		if (dfDestination)
		{
        var SectionOptions = {ModbusParameter:dfSource,Parameterkey:dfDestination};
		this.SCreateUCISection("Jsonconfig","DioIndexconfig",SectionOptions).then(function(rv){
			if(rv){
				if (rv.section){
					self.SCommitUCISection("Jsonconfig").then(function(res){
						if (res != 0) {
							alert("Error: New Zone Forwarding");
						}
						else {
							document.cookie="LastActiveTab=Tabdf";
							document.cookie="LastAction=add";
							location.reload();
						}
					});
					
				};
			};
		});
	}
	else
	{
		alert("Please Enter JsonKey")
	}
		
	},

	// //////////////////////////AI Sender///////////////////////////////////

	SACreateFormCallback: function()
	{
		var map = this;
		var fSectionID = map.options.fSection;
		
		map.options.caption = L.tr('AI Forwarding');
		
		var s = map.section(L.cbi.SingleSection, fSectionID, {
			anonymous:   true,
			 tabbed:      true
		});
	
		
		
		s.option(L.cbi.ListValue, 'ModbusParameter', {
			caption:     L.tr('Field Content'),
		}) .value("SiteID",L.tr("SiteID"))                                  
		.value("ReadTimeStamp",L.tr("ReadTimeStamp"))
		.value("EpochTimeStamp",L.tr("EpochTimeStamp"))                                   
		.value("AIRecordNumber",L.tr("RecordNumber"))                                  
		.value("AIRequestId",L.tr("RequestId"))                                
		.value("AIRecordType",L.tr("Recordtype"))                                
		.value("AIValues1",L.tr("AIInput1"))                                
		.value("AIValues2",L.tr("AIInput2"))
		.value("AIOCustomfield1",L.tr("AIOCustomfield1"))
		.value("AIOCustomfield2",L.tr("AIOCustomfield2"))
		.value("AIOCustomfield3",L.tr("AIOCustomfield3"))
		.value("AIOCustomfield4",L.tr("AIOCustomfield4"))
		.value("AIOCustomfield5",L.tr("AIOCustomfield5"));
		                          
		
		
		s.option(L.cbi.InputValue,'Parameterkey' ,{                            
			caption: L.tr('Field JSON Key Name')                                
	    });
	    
	    
	      s.option(L.cbi.InputValue,'Parametervalue' ,{                            
			caption: L.tr('Field JSON Key Value')                                
	    }).depends({'ModbusParameter':'AIOCustomfield1'})
	     .depends({'ModbusParameter':'AIOCustomfield2'})
	     .depends({'ModbusParameter':'AIOCustomfield3'})
	     .depends({'ModbusParameter':'AIOCustomfield4'})
	     .depends({'ModbusParameter':'AIOCustomfield5'});
	     
	
	},
	SARenderContents: function(rv)
	{
		var self = this;

		var list4 = new L.ui.table({
				columns: [{
					caption: L.tr('Fieldnumber'),
					align: 'left',
					format: function(v, n) {
							var div = $('<p />').attr('id', 'RS485DeviceSerialNo_%s'.format(n));
							var serialNo=n+1;
		                    return div.append('<strong>'+serialNo+'<strong>');
					}
				 },  			
			
			{ 
				caption: L.tr('Field Content'),
				format:  function(v,n) {
					var div = $('<small />').attr('id', 'zfSource_%s'.format(n));
					return div.append(v);
				}
			},{ 
				caption: L.tr('JSON Key Name'),
				format:  function(v,n) {
					var div = $('<small />').attr('id', 'zfDestination_%s'.format(n));
					return div.append(v);
				}
			},{
				caption: L.tr('Actions'),
				format:  function(v, n) {
					return $('<div />')
						.addClass('btn-group btn-group-sm')
						.append(L.ui.button(L.tr('Edit'), 'primary', L.tr('Edit Configuration'))
							.click({ self: self, fSectionID: v, fSectionType: "Ai" }, self.SSectionEdit))
						.append(L.ui.button(L.tr('Delete'), 'danger', L.tr('Delete Configuration'))
							.click({ self: self, fSectionID: v }, self.SASectionRemove));
				}
			}]
		});
		
		for (var key in rv) {                                                                           
			if (rv.hasOwnProperty(key)) {            
				var obj = rv[key];                                                
				var Modbus2 = obj.ModbusParameter;
				var Parameter2 = obj.Parameterkey;

				var data = {
					"SiteID": "SiteID",
					"ReadTimeStamp": "ReadTimeStamp",
					"EpochTimeStamp": "EpochTimeStamp",
					"AIRecordNumber": "RecordNumber",
					"AIRequestId": "RequestId",
					"AIRecordType": "Recordtype",
					"AIValues1": "AIInput1",
					"AIValues2": "AIInput2",
					"AIOCustomfield1": "AIOCustomfield1",
					"AIOCustomfield2": "AIOCustomfield2",
					"AIOCustomfield3": "AIOCustomfield3",
					"AIOCustomfield4": "AIOCustomfield4",
					"AIOCustomfield5": "AIOCustomfield5"
					
				};
				list4.row([key,data[Modbus2],Parameter2, key ]);
			}                                                                   
		
		
		}
		$('#sectiontab_ai_sender').
			append(list4.render());		
		
	},
	SASectionRemove: function(ev) {
		var self = ev.data.self;
		var afSectionID = ev.data.fSectionID;
		
		
		self.SDeleteUCISection("Jsonconfig","AIIndexconfig",afSectionID).then(function(rv){
			if(rv == 0){

				self.SCommitUCISection("Jsonconfig").then(function(res){
					if (res != 0){
						alert("Error: Delete Zone Forwarding");
					}
					else {
						document.cookie="LastActiveTab=Tabaf";
						document.cookie="LastAction=delete";
						location.reload();
					}
					
				});
			};
		});
	},
	SASectionAdd: function () 
	{
		var self = this;
		var afSource = $('#field_ai_sender_zone_src').val();
		var afDestination = $('#field_ai_sender_zone_destzone').val();
		//var serialNumber = $('#section_firewall_zonefor tr').length + 0;
		// var AsrTocheck=false;

		if (afDestination)
		{
        var SectionOptions = {ModbusParameter:afSource,Parameterkey:afDestination};
		this.SCreateUCISection("Jsonconfig","AIIndexconfig",SectionOptions).then(function(rv){
			if(rv){
				if (rv.section){
					self.SCommitUCISection("Jsonconfig").then(function(res){
						if (res != 0) {
							alert("Error: New Zone Forwarding");
						}
						else {
							document.cookie="LastActiveTab=Tabaf";
							document.cookie="LastAction=add";
							location.reload();
						}
					});
					
				};
			};
		});
	}
	else
	{
		alert("Please Enter JsonKey")
	}
		
	},


	////////////////////////////RS232 Sender///////////////////////////////////

	RS232CreateFormCallback: function()
	{
		var map = this;
		var fSectionID = map.options.fSection;
		
		map.options.caption = L.tr('RS232 Forwarding');
		
		var s = map.section(L.cbi.SingleSection, fSectionID, {
			anonymous:   true,
			 tabbed:      true
		});
	
		s.option(L.cbi.ListValue, 'ModbusParameter', {
			caption:     L.tr('Field Content'),
		}) .value("SiteID",L.tr("SiteID"))                                  
		.value("ReadTimeStamp",L.tr("ReadTimeStamp"))                                  
		.value("EpochTimeStamp",L.tr("EpochTimeStamp"))                                  
		.value("EMeterRS232RecordNumber",L.tr("RecordNumber"))                                  
		.value("EMeterRS232RequestId",L.tr("RequestId"))                                
		.value("EMeterRS232InterfaceId",L.tr("SerialPortNumber"))                                
		.value("EMeterRS232MeterID",L.tr("EquipmentID"))                                
		.value("EMeterRS232MeterModel",L.tr("EquipmentModel"))                                
		.value("EMeterRS232SlaveID",L.tr("SlaveID"))                                                           
		.value("FunctionCodeUsed",L.tr("FunctionCode"))                              
		.value("EMeterRS232ResponseCode",L.tr("EquipmentCommStatus"))              
		.value("StartingRS232RegisterAddress",L.tr("StartRegister"))              
		.value("NoOfRegisters",L.tr("NoOfRegisters"))
		.value("RS232EMeterREG2",L.tr("EquipmentData"))
		.value("RS232Customfield1",L.tr("RS232Customfield1"))
		.value("RS232Customfield2",L.tr("RS232Customfield2"))
		.value("RS232Customfield3",L.tr("RS232Customfield3"))
		.value("RS232Customfield4",L.tr("RS232Customfield4"))
		.value("RS232Customfield5",L.tr("RS232Customfield5"));

		
		s.option(L.cbi.InputValue,'Parameterkey' ,{                            
			caption: L.tr('Field JSON Key Name')                                
	    });
	    
	    
	    
	    
	      s.option(L.cbi.InputValue,'Parametervalue' ,{                            
			caption: L.tr('Field JSON Key Value')                                
	    }).depends({'ModbusParameter':'RS232Customfield1'})
	      .depends({'ModbusParameter':'RS232Customfield2'})
	      .depends({'ModbusParameter':'RS232Customfield3'})
	      .depends({'ModbusParameter':'RS232Customfield4'})
	      .depends({'ModbusParameter':'RS232Customfield5'});
	     
	
	},
	RS232RenderContents: function(rv)
	{
		var self = this;

		var list5 = new L.ui.table({
				columns: [{
					caption: L.tr('Fieldnumber'),
					align: 'left',
					format: function(v, n) {
							var div = $('<p />').attr('id', 'RS485DeviceSerialNo_%s'.format(n));
							var serialNo=n+1;
		                    return div.append('<strong>'+serialNo+'<strong>');
					}
				 },  			
			
			{ 
				caption: L.tr('Field Content'),
				format:  function(v,n) {
					var div = $('<small />').attr('id', 'zfSource_%s'.format(n));
					return div.append(v);
				}
			},{ 
				caption: L.tr('JSON Key Name'),
				format:  function(v,n) {
					var div = $('<small />').attr('id', 'zfDestination_%s'.format(n));
					return div.append(v);
				}
			},{
				caption: L.tr('Actions'),
				format:  function(v, n) {
					return $('<div />')
						.addClass('btn-group btn-group-sm')
						.append(L.ui.button(L.tr('Edit'), 'primary', L.tr('Edit Configuration'))
							.click({ self: self, fSectionID: v, fSectionType: "RS232" }, self.SSectionEdit))
						.append(L.ui.button(L.tr('Delete'), 'danger', L.tr('Delete Configuration'))
							.click({ self: self, fSectionID: v }, self.RS232SectionRemove));
				}
			}]
		});
		
		for (var key in rv) {                                                                           
			if (rv.hasOwnProperty(key)) {            
				var obj = rv[key];                                                
				var Modbus4 = obj.ModbusParameter;
				var Parameter4 = obj.Parameterkey;

				var data = {
					"SiteID": "SiteID",
					"ReadTimeStamp": "ReadTimeStamp",
					"EpochTimeStamp": "EpochTimeStamp",
					"EMeterRS232RecordNumber": "RecordNumber",
					"EMeterRS232RequestId": "RequestId",
					"EMeterRS232InterfaceId": "SerialPortNumber",
					"EMeterRS232MeterID": "EquipmentID",
					"EMeterRS232MeterModel": "EquipmentModel",
					"EMeterRS232SlaveID": "SlaveID",
					"FunctionCodeUsed": "FunctionCode",
					"EMeterRS232ResponseCode": "EquipmentCommStatus",
					"StartingRS232RegisterAddress": "StartRegister",
					"NoOfRegisters": "NoOfRegisters",
					"RS232EMeterREG2": "EquipmentData",
					"RS232Customfield1": "RS232Customfield1",
					"RS232Customfield2": "RS232Customfield2",
					"RS232Customfield3": "RS232Customfield3",
					"RS232Customfield4": "RS232Customfield4",
					"RS232Customfield5": "RS232Customfield5"
				};
				list5.row([key,data[Modbus4],Parameter4, key ]);
			}                                                                   
		
		
		}
		$('#sectiontab_rs_rs232').
			append(list5.render());		
		
	},
	RS232SectionRemove: function(ev) {
		var self = ev.data.self;
		var rsSectionID = ev.data.fSectionID;
		
		
		self.SDeleteUCISection("Jsonconfig","RS232Indexconfig",rsSectionID).then(function(rv){
			if(rv == 0){

				self.SCommitUCISection("Jsonconfig").then(function(res){
					if (res != 0){
						alert("Error: Delete Zone Forwarding");
					}
					else {
						document.cookie="LastActiveTab=Tabrs";
						document.cookie="LastAction=delete";
						location.reload();
					}
					
				});
			};
		});
	},
	RS232SectionAdd: function () 
	{
		var self = this;
		var rsSource = $('#field_rs232_sender_zone_src').val();
		var rsDestination = $('#field_rs232_sender_zone_destzone').val();

		if (rsDestination)
		{
        var SectionOptions = {ModbusParameter:rsSource,Parameterkey:rsDestination};
		this.SCreateUCISection("Jsonconfig","RS232Indexconfig",SectionOptions).then(function(rv){
			if(rv){
				if (rv.section){
					self.SCommitUCISection("Jsonconfig").then(function(res){
						if (res != 0) {
							alert("Error: New Zone Forwarding");
						}
						else {
							document.cookie="LastActiveTab=Tabrs";
							document.cookie="LastAction=add";
							location.reload();
						}
					});
					
				};
			};
		});
	}
	else
	{
		alert("Please Enter JsonKey")
	}
		
	},

	////////////////////////////SNMP Sender///////////////////////////////////

		SNMPCreateFormCallback: function()
		{
			var map = this;
			var fSectionID = map.options.fSection;
			
			map.options.caption = L.tr('SNMP Forwarding');
			
			var s = map.section(L.cbi.SingleSection, fSectionID, {
				anonymous:   true,
				 tabbed:      true
			});
		
			s.option(L.cbi.ListValue, 'ModbusParameter', {
				caption:     L.tr('Field Content'),
			}) .value("SiteID",L.tr("SiteID"))                                  
			.value("ReadTimeStamp",L.tr("ReadTimeStamp"))
			.value("EpochTimeStamp",L.tr("EpochTimeStamp"))                                   
			.value("SNMPRecordNumber",L.tr("RecordNumber"))                                  
			.value("SNMPRequestId",L.tr("RequestId"))                                
			.value("SNMPInterfaceId",L.tr("InterfaceId"))                                
			.value("SNMPDeviceIPAddress",L.tr("DeviceIPAddress"))                                
			.value("SNMPDevicePortNumber",L.tr("DevicePortNumber"))                                
			.value("SNMPDeviceType",L.tr("DeviceType"))                                                           
			.value("SNMPDeviceName",L.tr("DeviceName"))                              
			.value("SNMPDeviceResponseCode",L.tr("DeviceResponseCode"))              
			.value("SNMPData",L.tr("Data"))
			.value("SNMPCustomfield1",L.tr("SNMPCustomfield1"))
			.value("SNMPCustomfield2",L.tr("SNMPCustomfield2"))
			.value("SNMPCustomfield3",L.tr("SNMPCustomfield3"))
			.value("SNMPCustomfield4",L.tr("SNMPCustomfield4"))
			.value("SNMPCustomfield5",L.tr("SNMPCustomfield5"));
	
			
			s.option(L.cbi.InputValue,'Parameterkey' ,{                            
				caption: L.tr('Field JSON Key Name')                                
			});
			
			
			
			  s.option(L.cbi.InputValue,'Parametervalue' ,{                            
			caption: L.tr('Field JSON Key Value')                                
	    }).depends({'ModbusParameter':'SNMPCustomfield1'})
	      .depends({'ModbusParameter':'SNMPCustomfield2'})
	      .depends({'ModbusParameter':'SNMPCustomfield3'})
	      .depends({'ModbusParameter':'SNMPCustomfield4'})
	      .depends({'ModbusParameter':'SNMPCustomfield5'});
	     
		
		},
		SNMPRenderContents: function(rv)
		{
			var self = this;
	
			var list6 = new L.ui.table({
					columns: [{
						caption: L.tr('Fieldnumber'),
						align: 'left',
						format: function(v, n) {
								var div = $('<p />').attr('id', 'RS485DeviceSerialNo_%s'.format(n));
								var serialNo=n+1;
								return div.append('<strong>'+serialNo+'<strong>');
						}
					 },  			
				
				{ 
					caption: L.tr('Field Content'),
					format:  function(v,n) {
						var div = $('<small />').attr('id', 'zfSource_%s'.format(n));
						return div.append(v);
					}
				},{ 
					caption: L.tr('JSON Key Name'),
					format:  function(v,n) {
						var div = $('<small />').attr('id', 'zfDestination_%s'.format(n));
						return div.append(v);
					}
				},{
					caption: L.tr('Actions'),
					format:  function(v, n) {
						return $('<div />')
							.addClass('btn-group btn-group-sm')
							.append(L.ui.button(L.tr('Edit'), 'primary', L.tr('Edit Configuration'))
								.click({ self: self, fSectionID: v, fSectionType: "snmp" }, self.SSectionEdit))
							.append(L.ui.button(L.tr('Delete'), 'danger', L.tr('Delete Configuration'))
								.click({ self: self, fSectionID: v }, self.SNMPSectionRemove));
					}
				}]
			});
			
			for (var key in rv) {                                                                           
				if (rv.hasOwnProperty(key)) {            
					var obj = rv[key];                                                
					var Modbus5 = obj.ModbusParameter;
					var Parameter5 = obj.Parameterkey;
	
					var data = {
						"SiteID": "SiteID",
						"ReadTimeStamp": "ReadTimeStamp",
						"EpochTimeStamp": "EpochTimeStamp",
						"SNMPRecordNumber": "RecordNumber",
						"SNMPRequestId": "RequestId",
						"SNMPInterfaceId": "InterfaceId",
						"SNMPDeviceIPAddress": "DeviceIPAddress",
						"SNMPDevicePortNumber": "DevicePortNumber",
						"SNMPDeviceType": "DeviceType",
						"SNMPDeviceName": "DeviceName",
						"SNMPDeviceResponseCode": "DeviceResponseCode",
						"SNMPData": "Data",
						"SNMPCustomfield1": "SNMPCustomfield1",
						"SNMPCustomfield2": "SNMPCustomfield2",
						"SNMPCustomfield3": "SNMPCustomfield3",
						"SNMPCustomfield4": "SNMPCustomfield4",
						"SNMPCustomfield5": "SNMPCustomfield5"
					};
					list6.row([key,data[Modbus5],Parameter5, key ]);
				}                                                                   
			
			
			}
			$('#sectiontab_snmp_sender').
				append(list6.render());		
			
		},
		SNMPSectionRemove: function(ev) {
			var self = ev.data.self;
			var snmpSectionID = ev.data.fSectionID;
			
			
			self.SDeleteUCISection("Jsonconfig","SNMPIndexconfig",snmpSectionID).then(function(rv){
				if(rv == 0){
	
					self.SCommitUCISection("Jsonconfig").then(function(res){
						if (res != 0){
							alert("Error: Delete Zone Forwarding");
						}
						else {
							document.cookie="LastActiveTab=Tabsnmp";
							document.cookie="LastAction=delete";
							location.reload();
						}
						
					});
				};
			});
		},
		SNMPSectionAdd: function () 
		{
			var self = this;
			var snmpSource = $('#field_snmp_sender_zone_src').val();
			var snmpDestination = $('#field_snmp_sender_zone_destzone').val();
	
			if (snmpDestination)
			{
			var SectionOptions = {ModbusParameter:snmpSource,Parameterkey:snmpDestination};
			this.SCreateUCISection("Jsonconfig","SNMPIndexconfig",SectionOptions).then(function(rv){
				if(rv){
					if (rv.section){
						self.SCommitUCISection("Jsonconfig").then(function(res){
							if (res != 0) {
								alert("Error: New Zone Forwarding");
							}
							else {
								document.cookie="LastActiveTab=Tabsnmp";
								document.cookie="LastAction=add";
								location.reload();
							}
						});
						
					};
				};
			});
		}
		else
		{
			alert("Please Enter JsonKey")
		}
			
		},

	////////////////////////////TMP Sender///////////////////////////////////

	STCreateFormCallback: function()
	{
		var map = this;
		var fSectionID = map.options.fSection;
		
		map.options.caption = L.tr('TMP Forwarding');
		
		var s = map.section(L.cbi.SingleSection, fSectionID, {
			anonymous:   true,
			 tabbed:      true
		});
	
		
		
		s.option(L.cbi.ListValue, 'ModbusParameter', {
			caption:     L.tr('Field Content'),
		}) .value("SiteID",L.tr("SiteID"))                                  
		.value("ReadTimestamp",L.tr("ReadTimeStamp"))
		.value("EpochTimeStamp",L.tr("EpochTimeStamp"))                                   
		.value("TemperatureRecordNumber",L.tr("RecordNumber"))                                  
		.value("TemperatureRequestId",L.tr("RequestId"))                                
		.value("TemperatureValues1",L.tr("Temperature1"))                                
		.value("TemperatureValues2",L.tr("Temperature2"))                                
		.value("TemperatureValues3",L.tr("Temperature3"))                                
		.value("TemperatureValues4",L.tr("Temperature4"))                              
		.value("TemperatureValues5",L.tr("Temperature5"))                              
		.value("TemperatureValues6",L.tr("Temperature6"))                              
		.value("TemperatureValues7",L.tr("Temperature7"))                              
		.value("TemperatureValues8",L.tr("Temperature8"))          
		.value("TemperatureCustomfield1",L.tr("TemperatureCustomfield1"))          
		.value("TemperatureCustomfield2",L.tr("TemperatureCustomfield2"))          
		.value("TemperatureCustomfield3",L.tr("TemperatureCustomfield3"))          
		.value("TemperatureCustomfield4",L.tr("TemperatureCustomfield4"))          
		.value("TemperatureCustomfield5",L.tr("TemperatureCustomfield5"));          
		

		
		s.option(L.cbi.InputValue,'Parameterkey' ,{                            
			caption: L.tr('Field JSON Key Name')                                
	    });
	    
	    
	    
	    	  s.option(L.cbi.InputValue,'Parametervalue' ,{                            
			caption: L.tr('Field JSON Key Value')                                
	    }).depends({'ModbusParameter':'TemperatureCustomfield1'})
	      .depends({'ModbusParameter':'TemperatureCustomfield2'})
	      .depends({'ModbusParameter':'TemperatureCustomfield3'})
	      .depends({'ModbusParameter':'TemperatureCustomfield4'})
	      .depends({'ModbusParameter':'TemperatureCustomfield5'});
	     
	
	},
	STRenderContents: function(rv)
	{
		var self = this;

		var list5 = new L.ui.table({
				columns: [{
					caption: L.tr('Fieldnumber'),
					align: 'left',
					format: function(v, n) {
							var div = $('<p />').attr('id', 'RS485DeviceSerialNo_%s'.format(n));
							var serialNo=n+1;
		                    return div.append('<strong>'+serialNo+'<strong>');
					}
				 },  			
			
			{ 
				caption: L.tr('Field Content'),
				format:  function(v,n) {
					var div = $('<small />').attr('id', 'zfSource_%s'.format(n));
					return div.append(v);
				}
			},{ 
				caption: L.tr('JSON Key Name'),
				format:  function(v,n) {
					var div = $('<small />').attr('id', 'zfDestination_%s'.format(n));
					return div.append(v);
				}
			},{
				caption: L.tr('Actions'),
				format:  function(v, n) {
					return $('<div />')
						.addClass('btn-group btn-group-sm')
						.append(L.ui.button(L.tr('Edit'), 'primary', L.tr('Edit Configuration'))
							.click({ self: self, fSectionID: v, fSectionType: "Tmp" }, self.SSectionEdit))
						.append(L.ui.button(L.tr('Delete'), 'danger', L.tr('Delete Configuration'))
							.click({ self: self, fSectionID: v }, self.STSectionRemove));
				}
			}]
		});
		
		for (var key in rv) {                                                                           
			if (rv.hasOwnProperty(key)) {            
				var obj = rv[key];                                                
				var Modbus3 = obj.ModbusParameter;
				var Parameter3 = obj.Parameterkey;

				var data = {
					"SiteID": "SiteID",
					"ReadTimestamp": "ReadTimeStamp",
					"EpochTimeStamp": "EpochTimeStamp",
					"TemperatureRecordNumber": "RecordNumber",
					"TemperatureRequestId": "RequestId",
					"TemperatureValues1": "Temperature1",
					"TemperatureValues2": "Temperature2",
					"TemperatureValues3": "Temperature3",
					"TemperatureValues4": "Temperature4",
					"TemperatureValues5": "Temperature5",
					"TemperatureValues6": "Temperature6",
					"TemperatureValues7": "Temperature7",
					"TemperatureValues8": "Temperature8",
					"TemperatureCustomfield1": "TemperatureCustomfield1",
					"TemperatureCustomfield2": "TemperatureCustomfield2",
					"TemperatureCustomfield3": "TemperatureCustomfield3",
					"TemperatureCustomfield4": "TemperatureCustomfield4",
					"TemperatureCustomfield5": "TemperatureCustomfield5"
					
				};
				list5.row([key,data[Modbus3],Parameter3, key ]);
			}                                                                   
		
		
		}
		$('#sectiontab_tmp_sender').
			append(list5.render());		
		
	},
	STSectionRemove: function(ev) {
		var self = ev.data.self;
		var tfSectionID = ev.data.fSectionID;
		
		
		self.SDeleteUCISection("Jsonconfig","TmpIndexconfig",tfSectionID).then(function(rv){
			if(rv == 0){

				self.SCommitUCISection("Jsonconfig").then(function(res){
					if (res != 0){
						alert("Error: Delete Zone Forwarding");
					}
					else {
						document.cookie="LastActiveTab=Tabtf";
						document.cookie="LastAction=delete";
						location.reload();
					}
					
				});
			};
		});
	},
	STSectionAdd: function () 
	{
		var self = this;
		var tfSource = $('#field_tmp_sender_zone_src').val();
		var tfDestination = $('#field_tmp_sender_zone_destzone').val();
		//var serialNumber = $('#section_firewall_zonefor tr').length + 0;
		// var AsrTocheck=false;

		if (tfDestination)
		{
        var SectionOptions = {ModbusParameter:tfSource,Parameterkey:tfDestination};
		this.SCreateUCISection("Jsonconfig","TmpIndexconfig",SectionOptions).then(function(rv){
			if(rv){
				if (rv.section){
					self.SCommitUCISection("Jsonconfig").then(function(res){
						if (res != 0) {
							alert("Error: New Zone Forwarding");
						}
						else {
							document.cookie="LastActiveTab=Tabtf";
							document.cookie="LastAction=add";
							location.reload();
						}
					});
					
				};
			};
		});
	}
	else
	{
		alert("Please Enter JsonKey")
	}
		
	},

	execute: function() {		
		var self = this;
		
		handlechange = function (evt) {
            counter = 1;
            $('div[id*="TextBoxDiv"]').html("");
            var id = evt.target.id;
            var configvalue;
            if (id == "json") {
                $("#displayfixedpocket").css("display", "none");
                $("#senderconfig").css("display", "block");
                configvalue="1"


            }
            else if (id == "csv") {
                $('#devicename').val("")
                $("#displayfixedpocket").css("display", "block");
                $("#senderconfig").css("display", "none");
                configvalue="0"

            }

			var SectionOptions = {configType:configvalue};
			self.configTypeAddsection("Jsonconfig","configType","Type", SectionOptions).then(function(rv){
				if(rv){
					if (rv.section){
						self.SCommitUCISection("Jsonconfig").then(function(res){
							if (res != 0) {
								alert("Error: New Zone Forwarding");
							}
							else {
								// location.reload();
							}
						});
						
					};
				};
			});

        }
        
        
        
        self.SGetUCISections("Jsonconfig","configType").then(function(rv){
			console.log(rv)
		  let value=rv.Type.configType
		  
		  let json=document.getElementById("json");
		  
		  let csv=document.getElementById("csv");
		  if(value==0){
			  csv.checked=true;
			   json.checked=false;
			  
       $("#senderconfig").css("display", "none");
		$("#displayfixedpocket").css("display", "block");
		  }
		  else{
			  json.checked=true;
			   csv.checked=false;
			    $("#senderconfig").css("display", "block");
		$("#displayfixedpocket").css("display", "none");
		  }
			
		});
        
        
	
		this.SGetUCISections("Jsonconfig","JsonRs485Indexconfig").then(function(rv) {
			self.SMRenderContents(rv);
		});
		
		$('#AddNewzoneForwarding').click(function() {          
			self.SMSectionAdd();
		});

		this.SGetUCISections("Jsonconfig","DioIndexconfig").then(function(rv) {
			self.SDRenderContents(rv);
		});
		
		$('#AddNewdiosenderconfiguration').click(function() {          
			self.SDSectionAdd();
		});

		this.SGetUCISections("Jsonconfig","AIIndexconfig").then(function(rv) {
			self.SARenderContents(rv);
		});
		
		$('#AddNewaisenderconfiguration').click(function() {          
			self.SASectionAdd();
		});

		this.SGetUCISections("Jsonconfig","RS232Indexconfig").then(function(rv) {
			self.RS232RenderContents(rv);
		});
		
		$('#AddNewrs232senderconfiguration').click(function() {          
			self.RS232SectionAdd();
		});

		this.SGetUCISections("Jsonconfig","SNMPIndexconfig").then(function(rv) {
			self.SNMPRenderContents(rv);
		});
		
		$('#AddNewsnmpsenderconfiguration').click(function() {          
			self.SNMPSectionAdd();
		});
		

		this.SGetUCISections("Jsonconfig","TmpIndexconfig").then(function(rv) {
			self.STRenderContents(rv);
		});
		
		$('#AddNewtmpsenderconfiguration').click(function() {          
			self.STSectionAdd();
		});

		var m = new L.cbi.Map('FixedPacketConfigGeneric', {
			caption: L.tr('')
		});

			var s = m.section(L.cbi.NamedSection, 'fixedpacketconfig', {
				caption: L.tr('Fixed  Packet Configuration Settings')
			});
			
			// s.option(L.cbi.CheckboxValue,'SiteIDEnable',{
			// 	caption: L.tr('Site ID Enable')
			// });

			// s.option(L.cbi.InputValue,'SiteID',{
			// 	caption: L.tr('Site ID'),
			// }).depends('SiteIDEnable');

			// s.option(L.cbi.CheckboxValue,'DeviceIDEnable',{
			// 	caption: L.tr('Device ID Enable')
			// });

			s.option(L.cbi.InputValue,'DeviceID',{
				caption: L.tr('Device ID'),
			});
		
		/* s.option(L.cbi.CheckboxValue,'IMEINoEnable',{
				caption: L.tr('IMEI No Enable')
			});

			s.option(L.cbi.DummyValue,'IMEINo',{
				caption: L.tr('IMEI No')
			}).depends('IMEINoEnable');*/

		/*  s.option(L.cbi.CheckboxValue,'OverallSeparatorEnable',{
				caption: L.tr('Overall Separator Enable')
			});*/

			s.option(L.cbi.InputValue,'OverallRecordstartmark',{
				caption: L.tr('Record Start Mark'),
				datatype: 'preventComma'
			});

			s.option(L.cbi.InputValue,'OverallRecordendmark',{
				caption: L.tr('Record End Mark'),
				datatype: 'preventComma'
			});

		/* s.option(L.cbi.CheckboxValue,'IndividualSeparatorEnable',{
				caption: L.tr('Individual Separator Enable')
			});*/

			s.option(L.cbi.InputValue,'Registerstartmark',{
				caption: L.tr('Register Start Mark'),
				datatype: 'preventComma'
			});

			s.option(L.cbi.InputValue,'Registerendmark',{
				caption: L.tr('Register End Mark'),
				datatype: 'preventComma'
			});
			
			s.option(L.cbi.InputValue,'InvalidDataCharacter',{
				caption: L.tr('Invalid Data Character')
			});
			
			s.option(L.cbi.InputValue,'FailureDataCharacter',{
				caption: L.tr('Failure Data Character')
			});
			
			   //s.option(L.cbi.CheckboxValue,'MultiblockEnable',{
                       //caption: L.tr('Multiblock Enable')                   
                //});                                                
                                                                    
                //s.option(L.cbi.InputValue,'BlockSeperatorCharacter',{
                       //caption: L.tr('Block Seperator Character'),       
                       //datatype: 'preventComma'                  
                //}).depends('MultiblockEnable');   


			/*s.option(L.cbi.ListValue, 'EnableJSON', {
		                 caption:     L.tr('Publish Type'),
		                }).value("0", L.tr('CSV'))
		                  .value("1", L.tr('JSON'));*/

		// 	s.option(L.cbi.DummyValue, 'warning', {
		// 	caption: L.tr(''),
		// 	//  caption: L.tr(a),
		// 	}).ucivalue=function()
		// 	{
		// 		var id="<h4><b>You will lose Data on disabling Data storage on eMMC, if the same has been already enabled. </b> </h4>";
		// 		return id;
		// 	}; 
			
		// 	s.option(L.cbi.CheckboxValue,'eMCCEnable',{
		// 		caption: L.tr('Enable Data Storage on eMMC')
		// 	});
			
		// 	s.option(L.cbi.ListValue, 'storagesize', {
		//                  caption:     L.tr('Storage Size'),
		//                 }).value("4GB", L.tr('4GB'))
		//                   .value("8GB", L.tr('8GB'));

			
		// /*     s.option(L.cbi.InputValue,'MaxNumberofRegisters',{
		// 		caption: L.tr('Max.No.of Registers'),
		// 		datatype: 'uinteger'
		// 	});*/
			
		// /*  s.option(L.cbi.CheckboxValue,'RecordSeparatorEnable',{
		// 		caption: L.tr('Record Separator Enable')       
		// 	});*/                                                       
																	
		// /*s.option(L.cbi.CheckboxValue,'UserPassEnable',{
		// 		caption: L.tr('Username and Password')
		// 	});*/
			
			
		m.insertInto('#fixedpocket');                   



		
	}
});
