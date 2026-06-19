L.ui.view.extend({

	updateinterfaceconfig: L.rpc.declare({
		object: 'rpc-Allutilityupdate',
		method: 'configure',
		params: ['type', 'jsonData'],
		expect: { output: '' }
	}),

	SNMPMIBFileUpload: L.rpc.declare({
		object: 'rpc-snmpmibupload',
		method: 'configure',
		expect: { output: '' }
	}),
	UpdateDOcount: L.rpc.declare({
		object: 'rpc-updatedocount',
		method: 'configure',
		expect: { output: {} }
	}),


	RS485Config: function () {
		var self = this;
		debugger

		const mode = document.getElementById('mode').value;

		const RS485Data = {
			slaveid: document.getElementById('slaveid').value,
			functioncode: document.getElementById('functioncode').value,
			Mode: mode,
			DataWrite: mode == "1" ? "0" : document.getElementById('datawrite').value,
			ModbusEnable: document.getElementById('StdModbusEnable').checked ? "1" : "0",
			DataType: document.getElementById('data_type').value,
			StartRegister: document.getElementById('StartRegister').value,
			NoofRegister: document.getElementById('NoofRegister').value,
			baudrate: document.getElementById('baudrate').value,
			Stopbits: document.getElementById('Stopbits').value,
			Databits: document.getElementById('Databits').value,
			parity: document.getElementById('parity').value,
			portnumber: document.getElementById('portnumber').value,
			Protocal: document.getElementById('connectiontype').value,
			CommunicationIP: document.getElementById('CommunicationIP').value,
			CommunicationPort: document.getElementById('CommunicationPort').value,
			Communicationtimeout: document.getElementById('Communicationtimeout').value
		};


		const type = "RS485";
		const jsonData = JSON.stringify(RS485Data);
		console.log(jsonData);
		L.ui.loading(true)


		var RS485_utility_output = document.getElementById('RS485_utility_output');
		var RS485_utilit_section = document.getElementById('rs485section');


		// download the content of the pre element
		downloadPreContent = function () {
			var textContent = RS485_utility_output.textContent;
			var blob = new Blob([textContent], { type: 'text/plain' });
			var url = window.URL.createObjectURL(blob);
			var a = document.createElement('a');
			a.style.display = 'none';
			a.href = url;
			a.download = 'RS485_Utility_Response.txt';
			document.body.appendChild(a);
			a.click();
			window.URL.revokeObjectURL(url);
			document.body.removeChild(a);
		}


		self.updateinterfaceconfig(type, jsonData)
			.then(function (rv) {

				L.ui.loading(false)
				console.log('RPC call successful:', rv);

				RS485_utility_output.textContent = (rv);
				RS485_utility_output.classList.add('success-state');
				RS485_utility_output.classList.remove('failure-state');
				RS485_utility_output.style.display = "block";

			})

		rs485utilityresponse.style.display = 'block';
		RS485_utilit_section.style.display = 'block';
		$('#rs485utilityresponse').off('click').on('click', function () {
			downloadPreContent();
		});
	},



	RS232Config: function () {
		var self = this;
		debugger

		const RS232Data = {
			slaveid: document.getElementById('RS232slaveid').value,
			StartRegister: document.getElementById('RS232StartRegister').value,
			NoofRegister: document.getElementById('RS232NoofRegister').value,
			baudrate: document.getElementById('RS232baudrate').value,
			Stopbits: document.getElementById('RS232Stopbits').value,
			Databits: document.getElementById('RS232Databits').value,
			Flowcontrol: document.getElementById('RS232flowcontrol').value,
			functioncode: document.getElementById('RS232functioncode').value,
			parity: document.getElementById('RS232parity').value,
			portnumber: document.getElementById('RS232portnumber').value,
			Protocal: document.getElementById('controllertype').value,
			ListenTime: document.getElementById('listeningtime').value
		};
		const type = "RS232";
		const jsonData = JSON.stringify(RS232Data);
		console.log(jsonData);
		L.ui.loading(true)

		var RS232_utility_output = document.getElementById('RS232_utility_output');
		var RS232_utilit_section = document.getElementById('rs232section');

		downloadPreContent = function () {
			var textContent = RS232_utility_output.textContent;
			var blob = new Blob([textContent], { type: 'text/plain' });
			var url = window.URL.createObjectURL(blob);
			var a = document.createElement('a');
			a.style.display = 'none';
			a.href = url;
			a.download = 'RS232_Utility_Response.txt';
			document.body.appendChild(a);
			a.click();
			window.URL.revokeObjectURL(url);
			document.body.removeChild(a);
		}


		self.updateinterfaceconfig(type, jsonData)
			.then(function (rv) {
				L.ui.loading(false)
				console.log('RPC call successful:', rv);
				RS232_utility_output.textContent = (rv); // Format JSON response
				RS232_utility_output.classList.add('success-state');
				RS232_utility_output.classList.remove('failure-state');
				RS232_utility_output.style.display = "block";

			});

		rs232utilityresponse.style.display = 'block';
		RS232_utilit_section.style.display = 'block';
		$('#rs232utilityresponse').off('click').on('click', function () {
			downloadPreContent();
		});
	},


	//SNMP Section

	SNMPConfig: function () {
		var self = this;
		debugger

		const SNMPData = {

			SNMPIPAddress: document.getElementById('SNMPIPaddress').value,
			SNMPversion: document.getElementById('SNMPversion').value,
			SNMPCommunityString: document.getElementById('SNMPCommunityString').value,
			SNMPportnumber: document.getElementById('SNMPportnumber').value,
			SNMPoid: document.getElementById('SNMPoid').value,
			SNMPEnterpriseid: document.getElementById('SNMPEnterpriseid').value,
			MIBFileName: document.getElementById('mibfilename').value,
			Protocal: document.getElementById('SNMPtype').value


		};

		const type = "SNMP";
		const jsonData = JSON.stringify(SNMPData);
		console.log(jsonData);
		L.ui.loading(true)


		var SNMP_utility_output = document.getElementById('SNMP_utility_output');
		var SNMP_utility_section = document.getElementById('snmpsection');
		downloadPreContent = function () {
			var textContent = SNMP_utility_output.textContent;
			var blob = new Blob([textContent], { type: 'text/plain' });
			var url = window.URL.createObjectURL(blob);
			var a = document.createElement('a');
			a.style.display = 'none';
			a.href = url;
			a.download = 'SNMP_Utility_Response.txt';
			document.body.appendChild(a);
			a.click();
			window.URL.revokeObjectURL(url);
			document.body.removeChild(a);
		}

		self.updateinterfaceconfig(type, jsonData)
			.then(function (rv) {
				var P = document.getElementById('SNMPtype').value
				console.log(rv)
				L.ui.loading(false)
				if (P === '1') {
					fetch('/cgi-bin/ReadFileData')
						.then(res => {
							if (!res.ok) throw new Error("File not found");
							return res.text();
						})
						.then(text => {
							if (text) {
								// document.getElementById('fileContent').textContent = text;
								console.log('RPC call successful:', rv);
								SNMP_utility_output.textContent = (text);
								SNMP_utility_output.classList.add('success-state');
								SNMP_utility_output.classList.remove('failure-state');
								SNMP_utility_output.style.display = "block";

							} else {
								// document.getElementById('fileContent').textContent = text;
								console.log('RPC call successful:', rv);
								SNMP_utility_output.textContent = (rv);
								SNMP_utility_output.classList.add('success-state');
								SNMP_utility_output.classList.remove('failure-state');
								SNMP_utility_output.style.display = "block";
							}

						});

				} else {
					console.log('RPC call successful:', rv);
					SNMP_utility_output.textContent = (rv);
					SNMP_utility_output.classList.add('success-state');
					SNMP_utility_output.classList.remove('failure-state');
					SNMP_utility_output.style.display = "block";

				}




			});
		snmputilityresponse.style.display = 'block';
		SNMP_utility_section.style.display = 'block';
		$('#snmputilityresponse').off('click').on('click', function () {
			downloadPreContent();
		});
	},


	//MIB File Upload
	handleArchiveUpload: function () {
		var self = this;
		L.ui.SNMPMibFileUpload(
			L.tr('File Upload'),
			L.tr('Select the file and click on "%s" button to proceed.').format(L.tr('Apply')), {
			// filename: '/root/custom_image/custom_logo.svg',
			success: function (info) {
				self.handleArchiveVerify(info);
			}
		}
		);
	},

	handleArchiveVerify: function (info) {
		var self = this;
		var archive = $('[name=filename]').val();
		L.ui.loading(true);
		L.ui.dialog(
			L.tr('File'), [
			$('<p />').text(L.tr('Success')),
			$('<pre />')
				.addClass('alert-success')
				.text("File uploaded successfully"),
			self.SNMPMIBFileUpload('configure').then(function (TestArchiveOutput) {

			})

		], {
			style: 'close',

		}
		);
		L.ui.loading(false);
	},



	DIUtilityConfig: function () {
		var self = this;
		debugger
		const type = "DI_Utility";
		const jsonData = JSON.stringify("0");
		console.log(jsonData);
		L.ui.loading(true)


		var Device_utility_output = document.getElementById('Device_utility_output');
		var Device_utility_section = document.getElementById('deviceiutiitesection');
		downloadPreContent = function () {
			var textContent = Device_utility_output.textContent;
			var blob = new Blob([textContent], { type: 'text/plain' });
			var url = window.URL.createObjectURL(blob);
			var a = document.createElement('a');
			a.style.display = 'none';
			a.href = url;
			a.download = 'DI_Utility_Response.txt';
			document.body.appendChild(a);
			a.click();
			window.URL.revokeObjectURL(url);
			document.body.removeChild(a);
		}

		self.updateinterfaceconfig(type, jsonData)
			.then(function (rv) {
				console.log(rv)
				L.ui.loading(false)
				console.log('RPC call successful:', rv);
				Device_utility_output.textContent = (rv);
				Device_utility_output.classList.add('success-state');
				Device_utility_output.classList.remove('failure-state');
				Device_utility_output.style.display = "block";


			});
		deviceutilityresponse.style.display = 'block';
		Device_utility_section.style.display = 'block';
		$('#deviceutilityresponse').off('click').on('click', function () {
			downloadPreContent();
		});
	},


	AIUtilityConfig: function () {
		var self = this;
		debugger
		const type = "AI_Utility";
		const jsonData = JSON.stringify("0");
		console.log(jsonData);
		L.ui.loading(true)


		var Device_utility_output = document.getElementById('Device_utility_output');
		var Device_utility_section = document.getElementById('deviceiutiitesection');
		downloadPreContent = function () {
			var textContent = Device_utility_output.textContent;
			var blob = new Blob([textContent], { type: 'text/plain' });
			var url = window.URL.createObjectURL(blob);
			var a = document.createElement('a');
			a.style.display = 'none';
			a.href = url;
			a.download = 'AI_Utility_Response.txt';
			document.body.appendChild(a);
			a.click();
			window.URL.revokeObjectURL(url);
			document.body.removeChild(a);
		}

		self.updateinterfaceconfig(type, jsonData)
			.then(function (rv) {
				console.log(rv)
				L.ui.loading(false)
				console.log('RPC call successful:', rv);
				Device_utility_output.textContent = (rv);
				Device_utility_output.classList.add('success-state');
				Device_utility_output.classList.remove('failure-state');
				Device_utility_output.style.display = "block";


			});
		deviceutilityresponse.style.display = 'block';
		Device_utility_section.style.display = 'block';
		$('#deviceutilityresponse').off('click').on('click', function () {
			downloadPreContent();
		});


	},

	DOUtilityConfig: function () {
		var self = this;
		debugger
		const type = "DO_Utility";
		const jsonData = JSON.stringify("0");
		console.log(jsonData);
		L.ui.loading(true)


		var Device_utility_output = document.getElementById('Device_utility_output');
		var Device_utility_section = document.getElementById('deviceiutiitesection');
		downloadPreContent = function () {
			var textContent = Device_utility_output.textContent;
			var blob = new Blob([textContent], { type: 'text/plain' });
			var url = window.URL.createObjectURL(blob);
			var a = document.createElement('a');
			a.style.display = 'none';
			a.href = url;
			a.download = 'DO_Utility_Response.txt';
			document.body.appendChild(a);
			a.click();
			window.URL.revokeObjectURL(url);
			document.body.removeChild(a);
		}

		self.updateinterfaceconfig(type, jsonData)
			.then(function (rv) {
				console.log(rv)
				L.ui.loading(false)
				console.log('RPC call successful:', rv);
				Device_utility_output.textContent = (rv);
				Device_utility_output.classList.add('success-state');
				Device_utility_output.classList.remove('failure-state');
				Device_utility_output.style.display = "block";


			});
		deviceutilityresponse.style.display = 'block';
		Device_utility_section.style.display = 'block';
		$('#deviceutilityresponse').off('click').on('click', function () {
			downloadPreContent();
		});


	},

	TempUtilityConfig: function () {
		var self = this;
		debugger
		const type = "Temp_Utility";
		const jsonData = JSON.stringify("0");
		console.log(jsonData);
		L.ui.loading(true)


		var Device_utility_output = document.getElementById('Device_utility_output');
		var Device_utility_section = document.getElementById('deviceiutiitesection');
		downloadPreContent = function () {
			var textContent = Device_utility_output.textContent;
			var blob = new Blob([textContent], { type: 'text/plain' });
			var url = window.URL.createObjectURL(blob);
			var a = document.createElement('a');
			a.style.display = 'none';
			a.href = url;
			a.download = 'Temp_Utility_Response.txt';
			document.body.appendChild(a);
			a.click();
			window.URL.revokeObjectURL(url);
			document.body.removeChild(a);
		}

		self.updateinterfaceconfig(type, jsonData)
			.then(function (rv) {
				console.log(rv)
				L.ui.loading(false)
				console.log('RPC call successful:', rv);
				Device_utility_output.textContent = (rv);
				Device_utility_output.classList.add('success-state');
				Device_utility_output.classList.remove('failure-state');
				Device_utility_output.style.display = "block";


			});
		deviceutilityresponse.style.display = 'block';
		Device_utility_section.style.display = 'block';
		$('#deviceutilityresponse').off('click').on('click', function () {
			downloadPreContent();
		});


	},

	DO_Write_UtilityConfig: function () {
		var self = this;
		debugger
		const DO_WriteData = {

			DOPinNumber: document.getElementById('dopinsnumber').value,
			DOPinAction: document.getElementById('dopinaction').value,
		};
		const type = "DO_Write_Utility";
		const jsonData = JSON.stringify(DO_WriteData);
		$('#do_setModal').modal('hide');
		console.log(jsonData);
		L.ui.loading(true)


		var Device_utility_output = document.getElementById('Device_utility_output');
		var Device_utility_section = document.getElementById('deviceiutiitesection');
		downloadPreContent = function () {
			var textContent = Device_utility_output.textContent;
			var blob = new Blob([textContent], { type: 'text/plain' });
			var url = window.URL.createObjectURL(blob);
			var a = document.createElement('a');
			a.style.display = 'none';
			a.href = url;
			a.download = 'DO_Utility_Response.txt';
			document.body.appendChild(a);
			a.click();
			window.URL.revokeObjectURL(url);
			document.body.removeChild(a);
		}

		self.updateinterfaceconfig(type, jsonData)
			.then(function (rv) {
				console.log(rv)
				L.ui.loading(false)
				console.log('RPC call successful:', rv);
				Device_utility_output.textContent = (rv);
				Device_utility_output.classList.add('success-state');
				Device_utility_output.classList.remove('failure-state');
				Device_utility_output.style.display = "block";


			});

		deviceutilityresponse.style.display = 'block';
		Device_utility_section.style.display = 'block';
		$('#deviceutilityresponse').off('click').on('click', function () {
			downloadPreContent();
		});


	},



	hideUtility: function (id) {
		var el = document.getElementById(id);
		if (el) el.closest('.containerUtility').style.display = "none";
	},

	hideTab: function (id) {
		var el = document.getElementById(id);
		if (el) el.closest('.nav-item').style.display = "none";
	},

	handleutilites: function () {
		var self = this;
		let params = window.location.href;
		let BaseURL = new URL(params).origin;

		return fetch(`${BaseURL}:30005/AppmanagerConfig/`)
			.then(res => res.json())
			.then(data => {
				console.log(data);
				var x = data.applications;

				if (x.modbus_enabled === 0) {
					self.hideTab('pills-rs485-tab');
				}
				if (x.rs232_enabled === 0) {
					self.hideTab('pills-rs232-tab');
				}
				if (x.snmp_enabled === 0) {
					self.hideTab('pills-snmp-tab');
				}

				if (x.dio_enabled === 0) {
					self.hideUtility('doutility');
					self.hideUtility('do_set_utility');
					self.hideUtility('diutility');
				}
				if (x.aio_enabled === 0) {
					self.hideUtility('aiutility');
				}
			});
	},





	execute: function () {
		var self = this;
		// webpageAudit(node)

		// $('.dropdown-menu.navbar-inverse li').each(function () {
		// 	const listItemValue = $(this).text().trim();
		// 	const listItemHref = $(this).find('a').attr('href');

		// 	if (listItemHref === window.location.href) {
		// 		console.log(listItemValue); // Display the current page info
		// 	}
		// });

		self.handleutilites()


		self.UpdateDOcount('configure').then(function (rv) {
			const button = document.getElementById('do_set_utility');
			const container = button.closest('.containerUtility');
			const select = document.getElementById("dopinsnumber");

			if (!select) {
				console.error("Dropdown #dopinsnumber not found");
				return;
			}
			select.innerHTML = "";
			if (!rv || !rv.NoOfDO || rv.NoOfDO === 0) {
				container.style.display = "none";
				return;
			}
			container.style.display = "";
			Object.keys(rv).forEach(function (key) {

				if (key !== "NoOfDO") {

					const option = document.createElement("option");
					option.value = rv[key];
					option.textContent = key;

					select.appendChild(option);
				}
			});

		});




		$('#rs485utility').click(function () {
			self.RS485Config();
		})
		$('#RS232utility').click(function () {
			self.RS232Config();
		})
		$('#SNMPFileUploda').click(function () {
			self.handleArchiveUpload();
		});
		$('#SNMPutility').click(function () {
			self.SNMPConfig();
		});
		$('#diutility').click(function () {
			self.DIUtilityConfig();
		});
		$('#aiutility').click(function () {
			self.AIUtilityConfig();
		});
		$('#doutility').click(function () {
			self.DOUtilityConfig();
		});
		$('#Temputility').click(function () {
			self.TempUtilityConfig();
		});
		$('#GPSutility').click(function () {
			self.GPSUtilityConfig();
		});
		$('#dopinssumbit').click(function () {
			self.DO_Write_UtilityConfig();
		});
		$('#acmeterutility').click(function () {
			self.AC_Utility()
		});
		$('#dcmeterutility').click(function () {
			self.DC_Utility();
		});
		$('#deepseautility').click(function () {
			self.DeepSea_Utility();
		});
		$('#microsensorutility').click(function () {
			self.Micro_Utility();
		});


		//RS485 Section
		document.getElementById('connectiontype').addEventListener('change', function (e) {
			e.preventDefault();
			e.stopPropagation();
			let value = e.target.value;
			if (value === 'TCP') {
				TCPInputs.style.display = 'block';
				RTUinputs.style.display = 'none';
			} else {
				TCPInputs.style.display = 'none';
				RTUinputs.style.display = 'block';
			}
		});

		var x = document.getElementById('WriteData');
		var connectionType = document.getElementById('connectiontype');

		document.getElementById('mode').addEventListener('change', function () {

			if ((connectionType.value === 'RTU' || connectionType.value === 'TCP') && (this.value === '2')) {
				x.style.display = 'block';
			} else {
				x.style.display = 'none';
			}
		})

		//RS232 Section
		document.getElementById('controllertype').addEventListener('change', function (e) {
			e.preventDefault();
			e.stopPropagation();
			let value = e.target.value;
			if (value === '1') {

				CommandInput.style.display = 'block';
				ListenTime.style.display = 'none';

			} else {
				CommandInput.style.display = 'none';
				ListenTime.style.display = 'block';

			}
		});

		//SNMP Section
		document.getElementById('SNMPtype').addEventListener('change', function (e) {
			e.preventDefault();
			e.stopPropagation();
			let value = e.target.value;
			if (value === '1') {

				SNMPGetInputs.style.display = 'none';
				SNMPWalkInput.style.display = 'block';

			} else {
				SNMPGetInputs.style.display = 'block';
				SNMPWalkInput.style.display = 'none';

			}
		});
	}

});
