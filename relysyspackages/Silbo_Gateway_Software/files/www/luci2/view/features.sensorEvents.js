L.ui.view.extend({
	title: "",
	description: L.tr(''),

	sensorGetUCISections: L.rpc.declare({
		object: 'uci',
		method: 'get',
		params: ['config', 'type'],
		expect: { values: {} }
	}),

	sensorCreateUCISection: L.rpc.declare({
		object: 'uci',
		method: 'add',
		params: ['config', 'type', 'values', 'name']
	}),

	sensorCommitUCISection: L.rpc.declare({
		object: 'uci',
		method: 'commit',
		params: ['config']
	}),

	sensorDeleteUCISection: L.rpc.declare({
		object: 'uci',
		method: 'delete',
		params: ['config', 'type', 'section']
	}),

	//empty all values in side the given div 'divId' 
	emptyAllValuesInDiv: function (divId) {
		// Get the specific div by its ID
		const div = document.getElementById(divId);
		if (!div) {
			console.warn(`Div with ID ${divId} not found.`);
			return;
		}

		// Get all input elements inside the div
		const inputs = div.querySelectorAll('input');
		inputs.forEach(input => {
			switch (input.type) {
				case 'text':
				case 'password':
				case 'email':
				case 'number':
				case 'search':
				case 'tel':
				case 'url':
					input.value = '';
					break;
				case 'checkbox':
				case 'radio':
					input.checked = false;
					input.value = "0"
					break;
				default:
					break;
			}
		});

		// Get all textarea elements inside the div
		const textareas = div.querySelectorAll('textarea');
		textareas.forEach(textarea => {
			textarea.value = '';
		});

		// Clear the inner text of all elements with a specific class inside the div
		const displayBlocksToBeHiddenByDefault = div.querySelectorAll('.hideBlock');
		displayBlocksToBeHiddenByDefault.forEach(element => {
			element.style.display = 'none';
		});

		const checkBoxesToBeCheckedByDefault = div.querySelectorAll('.defaultChecked');
		checkBoxesToBeCheckedByDefault.forEach(element => {
			element.checked = true;
			element.value = "1";
		});
	},

	//removes all the badges with class '.badge-container' in given dev 'id'
	removeBadgesInDiv: function (id) {
		var div = document.getElementById(id);

		var element = div.querySelectorAll(".badge-container");
		for (var i = 0; i < element.length; i++) {
			element[i].remove();
		}
	},

	//checks whether the particular event is already added or not
	checkForDuplicates: function (type, name, oldValue) {
		var newValue = type + ":" + name;

		var div = document.getElementById('actionEventsList');

		if (div.style.display != "none") {
			var element = div.querySelectorAll(".badge-container");

			for (var i = 0; i < element.length; i++) {
				if ((element[i].getAttribute('value') == newValue) && (newValue != oldValue)) {
					return -1;
				}
				else if (element[i].getAttribute('value') == oldValue) {
					element[i].setAttribute('value', newValue);
					element[i].querySelector(".badge-text").textContent = name;
					return 1;
				}
			}
		}
		return 0;
	},

	//creates a badge container for a responsible event in action modal
	createBadgeContainer: function (name, type, eventList) {
		var self = this;
		var value = type + ":" + name;

		var actionEventsList = document.getElementById('actionEventsList');

		var div = document.createElement('div');
		div.classList.add("badge-container");
		div.setAttribute('value', value);

		var badgeText = document.createElement('span');
		badgeText.classList.add("badge-text");
		badgeText.textContent = name;

		var badgeButttons = document.createElement('span');
		badgeButttons.classList.add("badge-buttons");

		var editButton = document.createElement('button');
		editButton.classList.add("btn", "btn-light", "btn-sm", "edit-icon");
		editButton.textContent = "Edit";
		editButton.setAttribute('value', value);
		editButton.setAttribute('onclick', "handleActionEventEditSave(event)");

		var deleteButton = document.createElement('button');
		deleteButton.classList.add("btn", "btn-light", "btn-sm", "delete-icon");
		deleteButton.textContent = "Delete";
		deleteButton.addEventListener('click', function (event) {
			div.remove();
			var main = document.getElementById('actionEventsList');
			var element = main.querySelectorAll(".badge-container");
			if (element.length == 0) {
				document.getElementById('actionEventsList').style.display = "none";
				document.getElementById('actionEventsNone').style.display = "block";
			}
		});

		badgeButttons.append(editButton);
		badgeButttons.append(deleteButton);

		div.append(badgeText);
		div.append(badgeButttons);

		actionEventsList.append(div);
		actionEventsList.style.display = "block";
		document.getElementById('actionEventsNone').style.display = "none";
	},

	//populate the action modal with all the data provided in 'modalData'
	populateActionAddModal: function (modalData) {
		var self = this;

		if (modalData['type'] == "DIO") {
			document.getElementById('actionType').value = "DIO";
			if (modalData['data1'] != "null") {
				document.getElementById('enableAlarmActiveStateDIO').value = 1;
				document.getElementById('enableAlarmActiveStateDIO').checked = true;
				document.getElementById('alarmActiveStateDIONumber').value = modalData['data1'];
				document.getElementById('alarmActiveStateDIOAction').value = modalData['data2'].split('-')[0];
				document.getElementById('alarmActiveStateOnTime').value = modalData['data2'].split('-')[1];
				document.getElementById('alarmActiveStateOffTime').value = modalData['data2'].split('-')[2];
				document.getElementById('alarmActiveStateDIOConfig').style.display = "block";
				self.handleDIOActionChange(modalData['data2'].split('-')[0], 'Active');
			}
			if (modalData['data3'] != "null") {
				document.getElementById('enableAlarmInactiveStateDIO').value = 1;
				document.getElementById('enableAlarmInactiveStateDIO').checked = true;
				document.getElementById('alarmInactiveStateDIONumber').value = modalData['data3'];
				document.getElementById('alarmInactiveStateDIOAction').value = modalData['data4'].split('-')[0];
				document.getElementById('alarmInactiveStateOnTime').value = modalData['data4'].split('-')[1];
				document.getElementById('alarmInactiveStateOffTime').value = modalData['data4'].split('-')[2];
				document.getElementById('alarmInactiveStateDIOConfig').style.display = "block";
				self.handleDIOActionChange(modalData['data4'].split('-')[0], 'Inactive');
			}
		}
		else if (modalData['type'] == "sms") {
			document.getElementById('actionType').value = "sms";
			if (modalData['data1'] != "null") {
				document.getElementById('enableAlarmActiveStateSms').value = 1;
				document.getElementById('enableAlarmActiveStateSms').checked = true;
				document.getElementById('alarmActiveStateSmsConfig').style.display = "block";
				console.log(document.getElementById('alarmActiveStateSmsConfig'));
				document.getElementById('alarmActiveStateSmsNumber').value = modalData['data1'];
				var ids = ["selectDeviceSerialNumber", "selectActionName", "selectState", "selectValue", "selectTimestamp"];

				for (var i = 0; i < 5; i++) {
					document.getElementById(ids[i]).value = modalData['data2'].split('-')[i];
					if (modalData['data2'].split('-')[i] == "1") {
						document.getElementById(ids[i]).checked = true;
					}
				}
				if (modalData['data2'].split('-')[5] == "undefined") {
					document.getElementById('alarmActiveStateCustomtext').value = "";
				}
				else {
					document.getElementById('alarmActiveStateCustomtext').value = modalData['data2'].split('-')[5];
				}

			}
			if (modalData['data3'] != "null") {
				document.getElementById('enableAlarmInactiveStateSms').value = 1;
				document.getElementById('enableAlarmInactiveStateSms').checked = true;
				document.getElementById('alarmInactiveStateSmsConfig').style.display = "block";
				document.getElementById('alarmInactiveStateSmsNumber').value = modalData['data3'];
				var ids = ["inactiveDeviceSerialNumber", "inactiveActionName", "inactiveState", "inactiveValue", "inactiveTimestamp"];

				for (var i = 0; i < 5; i++) {
					document.getElementById(ids[i]).value = modalData['data4'].split('-')[i];
					if (modalData['data4'].split('-')[i] == "1") {
						document.getElementById(ids[i]).checked = true;
					}
				}
				if (modalData['data4'].split('-')[5] == "undefined") {
					document.getElementById('inactiveCustomtext').value = "";
				}
				else {
					document.getElementById('inactiveCustomtext').value = modalData['data4'].split('-')[5];
				}
			}
		}
		else if (modalData['type'] == "email") {
			document.getElementById('actionType').value = "email";
			if (modalData['data1'] != "null") {
				console.log("alarmActiveStateEmailConfig");
				document.getElementById('enableAlarmActiveStateEmail').value = 1;
				document.getElementById('enableAlarmActiveStateEmail').checked = true;
				document.getElementById('alarmActiveStateEmailId').value = modalData['data1'];
				var ids = ["emailDeviceSerialNumber", "emailActionName", "emailState", "emailValue", "emailTimestamp"];

				for (var i = 0; i < 5; i++) {
					document.getElementById(ids[i]).value = modalData['data2'].split('-')[i];
					if (modalData['data2'].split('-')[i] == "1") {
						console.log(ids[i]);
						document.getElementById(ids[i]).checked = true;
					}
				}
				if (modalData['data2'].split('-')[5] == "undefined") {
					document.getElementById('alarmActiveStateEmailCustomtext').value = "";
				}
				else {
					document.getElementById('alarmActiveStateEmailCustomtext').value = modalData['data2'].split('-')[5];
				}
				document.getElementById('alarmActiveStateSubject').value = modalData['data2'].split('-')[6];
			}
			if (modalData['data3'] != "null") {
				document.getElementById('enableAlarmInactiveStateEmail').value = 1;
				document.getElementById('enableAlarmInactiveStateEmail').checked = true;
				document.getElementById('alarmInactiveStateEmailID').value = modalData['data3'];
				var ids = ["inactiveEmailDeviceSerialNumber", "inactiveEmailActionName", "inactiveEmailState", "inactiveEmailValue", "inactiveEmailTimestamp"];

				for (var i = 0; i < 5; i++) {
					document.getElementById(ids[i]).value = modalData['data4'].split('-')[i];
					if (modalData['data4'].split('-')[i] == "1") {
						document.getElementById(ids[i]).checked = true;
					}
				}
				if (modalData['data4'].split('-')[5] == "undefined") {
					document.getElementById('inactiveEmailCustomtext').value = "";
				}
				else {
					document.getElementById('inactiveEmailCustomtext').value = modalData['data4'].split('-')[5];
				}
			}
			document.getElementById('alarmInactiveStateSubject').value = modalData['data4'].split('-')[6];
		}
		self.handleAddActionType(modalData['type']);
	},

	//creates a badge for an action with 'type' and 'data'
	createActionBadge: function (type, data, value) {
		var self = this;

		var actionList = document.getElementById('actionActionsList');

		var div = document.createElement('div');
		div.classList.add("badge-container");
		div.setAttribute('value', type);
		div.setAttribute('data-additional', data);

		var badgeText = document.createElement('span');
		badgeText.classList.add("badge-text");
		badgeText.textContent = type;

		var badgeButttons = document.createElement('span');
		badgeButttons.classList.add("badge-buttons");

		var editButton = document.createElement('button');
		editButton.classList.add("btn", "btn-light", "btn-sm", "edit-icon");
		editButton.textContent = "Edit";
		editButton.setAttribute('value', type);
		editButton.setAttribute('data-additional', data);
		editButton.setAttribute('onclick', "handleActionActionEditSave(event)");

		var deleteButton = document.createElement('button');
		deleteButton.classList.add("btn", "btn-light", "btn-sm", "delete-icon");
		deleteButton.textContent = "Delete";
		deleteButton.addEventListener('click', function (event) {
			div.remove();
			var main = document.getElementById('actionEventsList');
			var element = main.querySelectorAll(".badge-container");
			if (element.length == 0) {
				document.getElementById('actionActionsList').style.display = "none";
				document.getElementById('actionActionsNone').style.display = "block";
			}
		});

		badgeButttons.append(editButton);
		badgeButttons.append(deleteButton);

		div.append(badgeText);
		div.append(badgeButttons);

		actionList.append(div);
		actionList.style.display = "block";
		document.getElementById('actionActionsNone').style.display = "none";
	},

	//populates the options in select box 'id' with 'options' array
	populateSelectElementOptions: function (id, options) {

		$("#" + id).empty();

		for (var key of options) {
			$('<option />')
				.attr('value', key)
				.text(key)
				.appendTo("#" + id);
		}
	},

	//handles the population of data into add events modal
	populateAddEventForm: function (webOptions) {
		var self = this;
		document.getElementById('addEventButton').value = "null";
		document.getElementById('eventName').style.display = 'block';
		document.getElementById('readOnlyEventName').style.display = 'none';


		$("#sensorType").empty();
		$("#sensorNumber").empty();

		$('<option />')
			.attr('value', "")
			.text("Please Choose an Option")
			.appendTo("#sensorType");

		for (var key in webOptions['sensorType']) {
			if (webOptions['sensorType'].hasOwnProperty(key) && key.charAt(0) !== '.') {
				if (webOptions['sensorType'][key] != 0) {
					$('<option />')
						.attr('value', key)
						.text(key)
						.appendTo("#sensorType");
				}

				if (key == "DIO") {
					var n = webOptions['sensorType'][key];
					for (var i = 1; i <= n; i++) {
						$('<option />')
							.attr('value', i)
							.text(i)
							.appendTo("#sensorNumber");
					}
				}
			}
		}
	},

	//populates data into add actions modal
	populateAddActionsForm: function (webOptions) {
		var self = this;
		document.getElementById('actionEventsAdd').value = "null";
	},

	//handles display and hiding functionality in events modal
	handleAddEventSensorType: function (value) {
		if (value == 'DIO') {
			document.getElementById('DIOOptions').style.display = 'block';
			document.getElementById('scheduledEventsOptions').style.display = 'none';
		}
		else if (value == 'scheduledEvent') {
			document.getElementById('DIOOptions').style.display = 'none';
			document.getElementById('scheduledEventsOptions').style.display = 'block';
		}
		else {
			document.getElementById('DIOOptions').style.display = 'none';
			document.getElementById('scheduledEventsOptions').style.display = 'none';
		}
	},

	//handles the DIO on time and off time action add events modal in action section
	handleDIOActionChange: function (value, mode) {
		var idOnTime = 'alarm' + mode + 'OnTime';
		var idOffTime = 'alarm' + mode + 'OffTime';

		if (value < 3) {
			document.getElementById(idOffTime).style.display = "none";
		}
		else {
			document.getElementById(idOffTime).style.display = "block";
		}

		if (value == '0' || value == '1' || value == '3') {
			document.getElementById(idOnTime).style.display = "none";
		}
		else {
			document.getElementById(idOnTime).style.display = "block";
		}
	},

	//handles the hide and display functionality for action type
	handleAddActionType: function (value) {
		var displayBlock = value + "Action";
		var actionForm = document.getElementById('ActionAddForm');
		var Blocks = actionForm.querySelectorAll('.displayBlock');

		for (var key of Blocks) {
			if (key.id == displayBlock) {
				key.style.display = "block";
			}
			else {
				key.style.display = "none";
			}
		}
	},

	//handles the options in select box 'actionEventAddName' on change in even type
	handleActionEventTypeChange: function (value, webOptionsData, modbusEventList, AioEventList, tempEvent) {
		var self = this;
		var option = [];
		$('#actionEventAddName').empty();
		if (value == "DIO") {
			for (var key in webOptionsData) {
				if (webOptionsData[key][".type"] == "event" && webOptionsData[key].sensorType == "DIO") {
					option.push(webOptionsData[key].eventName);
				}
			}
			document.getElementById('actionEventAddStateDiv').style.display = "block";

		}
		else if (value == "scheduledEvent") {
			for (var key in webOptionsData) {
				if (webOptionsData[key][".type"] == "event" && webOptionsData[key].sensorType == "scheduledEvent") {
					option.push(webOptionsData[key].eventName);
				}
			}
			document.getElementById('actionEventAddStateDiv').style.display = "none";
		}
		else if (value == "Modbus") {
			for (var key of modbusEventList) {
				option.push(key);
			}
			document.getElementById('actionEventAddStateDiv').style.display = "block";
		}
		else if (value == "AIO") {
			for (var key of AioEventList) {
				option.push(key);
			}
			document.getElementById('actionEventAddStateDiv').style.display = "block";
		}
		else if (value == "Temperature") {
			for (var key of tempEvent) {
				option.push(key);
			}
			document.getElementById('actionEventAddStateDiv').style.display = "block";
		}
		console.log(option);
		self.populateSelectElementOptions('actionEventAddName', option);
	},

	//this handles the updation/saving to the config file
	updateSection: function (config, type, name, values, errorMsg, successMsg) {
		var self = this;
		L.ui.loading(true);
		// self.sensorDeleteUCISection(config, type, name).then(function (rv) {
		// 	console.log(rv);
		self.sensorCreateUCISection(config, type, values, name).then(function (rv) {
			if (rv) {
				L.ui.loading(false);
				if (rv.section) {
					self.sensorCommitUCISection(config).then(function (res) {
						if (res != 0) {
							alert("error");
							if (errorMsg) {
								L.ui.showAlert("Error", "Error", errorMsg);
							}
							return false;
						}
						else {
							L.ui.showAlert("success", "Success", "Configuration applied Successfully");
							setTimeout(() => {
								location.reload();
							}, 2000);
						}
					});
				};
			};
		});
		// });
	},

	//handles the functionality of enable and disable button
	enableDisableConfig: function (ev) {
		var self = ev.data.self;
		var sectionName = ev.data.sectionName;
		var index = ev.data.index;
		var sectionType = ev.data.sectionType;
		var enableStatus = {};

		var enable = document.getElementById('enableDisableSwitch' + index).checked;

		if (enable == true) {
			enableStatus = { enable: '1' };
		}
		else {
			enableStatus = { enable: '0' };
		}

		self.updateSection("eventConfig", sectionType, sectionName, enableStatus);
	},

	//populates the data in events modal for edit event functionality
	populateEventsModal: function (sectionName, sectionData) {
		var obj = sectionData[sectionName];
		document.getElementById('eventName').style.display = 'none';
		document.getElementById('readOnlyEventName').style.display = 'block';
		document.getElementById('readOnlyEventName').innerText = obj.eventName;
		document.getElementById('sensorType').value = obj.sensorType;
		if (obj.sensorType == "DIO") {
			document.getElementById('sensorNumber').value = obj.sensorNumber;
		}
		else if (obj.sensorType == "scheduledEvent") {
			document.getElementById('enableTimeRange').value = obj.enableTimeRange;
			document.getElementById('startHour').value = obj.startTime.split(":")[0];
			document.getElementById('startMin').value = obj.startTime.split(":")[1];
			document.getElementById('endHour').value = obj.endTime.split(":")[0];
			document.getElementById('endMin').value = obj.endTime.split(":")[1];
			document.getElementById('enableDayDependency').value = obj.enableDayDependency;

			if (obj.enableTimeRange == "1") {
				document.getElementById('enableTimeRange').checked = true;
				document.getElementById('timeRangeOptions').style.display = "block";
			}
			else {
				document.getElementById('enableTimeRange').checked = false;
				document.getElementById('timeRangeOptions').style.display = "none";
			}

			if (obj.enableDayDependency == "1") {
				document.getElementById('enableDayDependency').checked = true;
				document.getElementById('dayDependencyOptions').style.display = "block";
				var daysOftheWeek = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
				for (var key of daysOftheWeek) {
					document.getElementById(key).value = "0";
					document.getElementById(key).checked = false;
				}

				var days = obj.dayDependency.split(" ");
				for (var key of days) {
					document.getElementById(key).value = "1";
					document.getElementById(key).checked = true;
				}
			}
			else {
				document.getElementById('enableDayDependency').checked = false;
				document.getElementById('dayDependencyOptions').style.display = "none";
			}
		}
		document.getElementById('addEventButton').value = sectionName;
	},

	//populates the data in events modal for edit action functionality
	populateActionsModal: function (sectionName, sectionData) {
		var self = this;
		var obj = sectionData[sectionName];
		var numberOfEvents = obj.numberOfEvents;
		var numberOfActions = obj.numberOfActions;

		document.getElementById('actionName').value = obj.actionName;


		for (var i = 0; i < numberOfEvents; i++) {
			var j = i + 1;
			var type = "event" + j + "_type";
			var eventType = obj[type];
			var name = "event" + j + "_name";
			var eventName = obj[name];
			var state = "event" + j + "_state";
			var eventState = obj[state];
			if (eventType != "scheduledEvent") {
				eventName = eventName + ":" + eventState;
			}
			self.createBadgeContainer(eventName, eventType);
		}

		for (var i = 0; i < numberOfActions; i++) {
			var j = i + 1;
			var type = "action" + j + "_type";
			var actionType = obj[type];
			var data = "";
			var temp = "";
			if (actionType == "DIO") {
				temp = "action" + j + "_triggerSensorNumber";
				data = obj[temp] + ";";
				temp = "action" + j + "_triggerAction";
				var action = obj[temp];
				temp = "action" + j + "_triggerOnTime";
				var onTime = obj[temp];
				temp = "action" + j + "_triggerOffTime";
				var offTime = obj[temp];
				data = data + action + "-" + onTime + "-" + offTime + ";";

				//Normal Action
				temp = "action" + j + "_normalSensorNumber";
				data = data + obj[temp] + ";";
				temp = "action" + j + "_normalAction";
				console.log(temp);
				action = obj[temp];
				temp = "action" + j + "_normalOnTime";
				onTime = obj[temp];
				temp = "action" + j + "_normalOffTime";
				offTime = obj[temp];
				data = data + action + "-" + onTime + "-" + offTime + ";";
			}
			else if (actionType == "sms" || actionType == "email") {
				temp = "action" + j + "_triggerPhoneNumber";
				data = obj[temp] + ";";
				temp = "action" + j + "_triggerSerialNumber";
				var serialNumber = obj[temp];
				temp = "action" + j + "_triggerActionName";
				var actionName = obj[temp];
				temp = "action" + j + "_triggerState";
				var state = obj[temp];
				temp = "action" + j + "_triggerValue";
				var value = obj[temp];
				temp = "action" + j + "_triggerTimestamp";
				var timeStamp = obj[temp];
				temp = "action" + j + "_triggerCustomText";
				var customText = obj[temp];
				if (actionType == "email") {
					temp = "action" + j + "_triggerSubject";
					var subject = obj[temp];
					data = data + serialNumber + "-" + actionName + "-" + state + "-" + value + "-" + timeStamp + "-" + customText + "-" + subject + ";";
				}
				else {
					data = data + serialNumber + "-" + actionName + "-" + state + "-" + value + "-" + timeStamp + "-" + customText + ";";
				}
				//normal Action
				temp = "action" + j + "_normalPhoneNumber";
				data = data + obj[temp] + ";";
				temp = "action" + j + "_normalSerialNumber";
				serialNumber = obj[temp];
				temp = "action" + j + "_normalActionName";
				actionName = obj[temp];
				temp = "action" + j + "_normalState";
				state = obj[temp];
				temp = "action" + j + "_normalValue";
				value = obj[temp];
				temp = "action" + j + "_normalTimestamp";
				timeStamp = obj[temp];
				temp = "action" + j + "_normalCustomText";
				customText = obj[temp];
				if (actionType == "email") {
					temp = "action" + j + "_normalSubject";
					var subject = obj[temp];
					data = data + serialNumber + "-" + actionName + "-" + state + "-" + value + "-" + timeStamp + "-" + customText + "-" + subject + ";";
				}
				else {
					data = data + serialNumber + "-" + actionName + "-" + state + "-" + value + "-" + timeStamp + "-" + customText + ";";
				}
			}
			self.createActionBadge(actionType, data);
		}
	},

	//function to carry out edit functionality for event and actions
	sectionEdit: function (ev) {
		var self = ev.data.self;
		var sectionName = ev.data.sectionName;
		var sectionData = ev.data.sectionData;
		var sensorType = sectionData[sectionName].sensorType;
		var type = ev.data.type;
		console.log(type);
		if (type == 'event') {
			self.emptyAllValuesInDiv('addEventsForm');
			self.populateAddEventForm(sectionData);
			self.populateEventsModal(sectionName, sectionData);
			self.handleAddEventSensorType(sensorType);

			$('#addEvents').modal('show');
		}
		else if (type == 'action') {
			document.getElementById('addActionButton').value = sectionName;
			self.emptyAllValuesInDiv('addActionsForm');
			self.removeBadgesInDiv('actionEventsList');
			document.getElementById('actionEventsList').style.display = "none";
			document.getElementById('actionEventsNone').style.display = "block";
			self.removeBadgesInDiv('actionActionsList');
			document.getElementById('actionActionsList').style.display = "none";
			document.getElementById('actionActionsNone').style.display = "block";
			self.populateActionsModal(sectionName, sectionData);
			$('#addActions').modal('show');
		}
	},

	//handles the deletion of event and action in config file
	// sectionRemove: function (ev) {
	// 	var self = ev.data.self;
	// 	var sectionName = ev.data.sectionName;
	// 	var type = ev.data.type;

	// 	if (type == "event") {
	// 		var eventName = ev.data.actionData[sectionName].eventName;
	// 		for (var key in ev.data.actionData) {
	// 			if (ev.data.actionData.hasOwnProperty && ev.data.actionData[key][".type"] == "action") {
	// 				var obj = ev.data.actionData[key];
	// 				var actionName = obj.actionName;
	// 				var numberOfEvents = obj.numberOfEvents;
	// 				var deleteEnable = 1;

	// 				for (var i = 0; i < numberOfEvents; i++) {
	// 					var j = i + 1;
	// 					var name = "event" + j + "_name";
	// 					if (eventName == obj[name]) {
	// 						deleteEnable = 0;
	// 						//alert("This Event is already Configured for '" + actionName + "' Action");
	// 						L.ui.showAlert("warning", "Warning", "This Event is already Configured for '" + actionName + "' Action");
	// 						return;
	// 					}
	// 				}

	// 			}
	// 		}
	// 		L.ui.loading(true);
	// 		self.sensorDeleteUCISection("eventConfig", type, sectionName).then(function (rv) {
	// 			L.ui.loading(false);
	// 			if (rv == 0) {
	// 				self.sensorCommitUCISection("eventConfig").then(function (res) {
	// 					if (res != 0) {
	// 						alert("Error: Delete Configuration");
	// 					}
	// 					else {
	// 						location.reload();
	// 					}
	// 				});
	// 			};
	// 		});
	// 	}
	// 	else {
	// 		L.ui.loading(true);
	// 		self.sensorDeleteUCISection("eventConfig", type, sectionName).then(function (rv) {
	// 			L.ui.loading(false);
	// 			if (rv == 0) {
	// 				self.sensorCommitUCISection("eventConfig").then(function (res) {
	// 					if (res != 0) {
	// 						alert("Error: Delete Configuration");
	// 					}
	// 					else {
	// 						location.reload();
	// 					}
	// 				});
	// 			};
	// 		});
	// 	}
	// },

	sectionRemove: function (ev) {
		var self = ev.data.self;
		var sectionName = ev.data.sectionName;
		var type = ev.data.type;

		// ⭐ ADD THIS WRAPPER
		L.ui.confirmDelete(ev, function (res) {
			if (!res) return;

			// 👉 your original logic starts here

			if (type == "event") {
				var eventName = ev.data.actionData[sectionName].eventName;

				for (var key in ev.data.actionData) {
					if (ev.data.actionData.hasOwnProperty &&
						ev.data.actionData[key][".type"] == "action") {

						var obj = ev.data.actionData[key];
						var actionName = obj.actionName;
						var numberOfEvents = obj.numberOfEvents;

						for (var i = 0; i < numberOfEvents; i++) {
							var j = i + 1;
							var name = "event" + j + "_name";

							if (eventName == obj[name]) {
								L.ui.showAlert(
									"warning",
									"Warning",
									"This Event is already Configured for '" + actionName + "' Action"
								);
								return;
							}
						}
					}
				}

				L.ui.loading(true);
				self.sensorDeleteUCISection("eventConfig", type, sectionName).then(function (rv) {
					L.ui.loading(false);

					if (rv == 0) {
						self.sensorCommitUCISection("eventConfig").then(function (res) {
							if (res != 0) {
								L.ui.showAlert("error", "Error", "Delete Configuration failed");
							} else {
								L.ui.showAlert("success", "Deleted", "Configuration deleted successfully");

								setTimeout(() => location.reload(), 1500);
							}
						});
					}
				});

			} else {
				// 👉 action delete

				L.ui.loading(true);
				self.sensorDeleteUCISection("eventConfig", type, sectionName).then(function (rv) {
					L.ui.loading(false);

					if (rv == 0) {
						self.sensorCommitUCISection("eventConfig").then(function (res) {
							if (res != 0) {
								L.ui.showAlert("error", "Error", "Delete Configuration failed");
							} else {
								L.ui.showAlert("success", "Deleted", "Configuration deleted successfully");

								setTimeout(() => location.reload(), 1500);
							}
						});
					}
				});
			}
		});
	},

	//renders the event status
	// renderEventsStatus: function (rv) {
	// 	var self = this;
	// 	var count = 0;

	// 	for (var key in rv) {
	// 		if (rv.hasOwnProperty && rv[key][".type"] == "eventStatus") {
	// 			var obj = rv[key];
	// 			count++;
	// 			var name = obj.name;
	// 			var status = obj.state;
	// 			if (status == "1") {
	// 				status = "Alarm";
	// 				color = "red";
	// 			}
	// 			else {
	// 				status = "Normal";
	// 				color = "green";
	// 			}

	// 			var addEvent = document.createElement('div');
	// 			addEvent.className = 'row';
	// 			addEvent.style.color = color;

	// 			var eventName = document.createElement('div');
	// 			eventName.className = 'col-sm-7';
	// 			var p1 = document.createElement('p');
	// 			p1.innerHTML = "<strong>" + name + "<strong>";
	// 			eventName.appendChild(p1);

	// 			var eventStatus = document.createElement('div');
	// 			eventStatus.className = 'col-sm-2';
	// 			var p2 = document.createElement('p');
	// 			p2.innerHTML = status;
	// 			eventStatus.appendChild(p2);

	// 			addEvent.appendChild(eventName);
	// 			addEvent.appendChild(eventStatus);
	// 			$('#eventStatusDisplay').append(addEvent);
	// 		}
	// 	}
	// 	if (count == 0) {
	// 		var noteContainer = document.createElement('div');

	// 		var display = document.createElement('p');
	// 		display.className = "note";
	// 		display.textContent = "Events monitoring application is not running";

	// 		noteContainer.appendChild(display);

	// 		$('#eventStatusDisplay').append(noteContainer);
	// 	}
	// },

	renderEventsStatus: function (rv) {
		var self = this;
		var count = 0;

		$('#eventStatusDisplay').empty(); // important

		for (var key in rv) {
			if (rv.hasOwnProperty && rv[key][".type"] == "eventStatus") {

				var obj = rv[key];
				count++;

				var name = obj.name;
				var status = obj.state === "1" ? "Alarm" : "Normal";

				//  main row
				var addEvent = document.createElement('div');
				addEvent.className = 'event-status-row';

				//  name
				var eventName = document.createElement('div');
				eventName.className = 'event-status-name';
				eventName.textContent = name;

				//  status badge
				var eventStatus = document.createElement('div');
				eventStatus.className =
					'status-badge ' +
					(status === "Alarm" ? "status-alarm" : "status-normal");
				eventStatus.textContent = status;

				addEvent.appendChild(eventName);
				addEvent.appendChild(eventStatus);

				$('#eventStatusDisplay').append(addEvent);
			}
		}

		//  empty state
		if (count == 0) {
			var noteContainer = document.createElement('div');
			var display = document.createElement('p');
			display.className = "note";
			display.textContent = "Events monitoring application is not running";
			noteContainer.appendChild(display);
			$('#eventStatusDisplay').append(noteContainer);
		}
	},

	//renders the configured events 
	renderEventsTable: function (rv) {
		var self = this;
		var count = 0;

		var list = new L.ui.table({
			columns: [{
				caption: L.tr('Sl no.'),
				format: function (v, n) {
					var serialNumber = n + 1;
					var div = $('<p />').attr('id', 'slNo%s'.format(n));
					return div.append('<strong>' + serialNumber + '</strong>');
				}
			}, {
				caption: L.tr('Event Name'),
				format: function (v, n) {
					var div = $('<p />').attr('id', 'eventName%s'.format(n));
					return div.append(v);
				}
			}, {
				caption: "Event Type",
				format: function (v, n) {
					var div = $('<p />').attr('id', 'eventType%s'.format(n));
					return div.append(v);
				}
			}, {
				caption: "Description",
				format: function (v, n) {
					var div = $('<p />').attr('id', 'description%s'.format(n));
					return div.append(v);
				}
			}, {
				caption: L.tr('Enable/Disable'),
				width: '14%',
				align: 'center',
				format: function (v, n) {
					var myArray = v.split(",")
					var mode = myArray[0];
					var key = myArray[1];
					if (mode == 1) {
						mode = true;
					}
					else {
						mode = false;
					}
					var checkbox = $('<input />')
						.attr('type', 'checkbox')
						.attr('id', 'enableDisableSwitchEvent%s'.format(n))
						.attr('checked', mode)
						.addClass('slider round')
						.click({ self: self, sectionName: key, sectionType: "event", index: "Event" + n }, self.enableDisableConfig);

					var span = $('<span />')
						.addClass('slider round');

					return $('<label />')
						.addClass('switch')
						.append(checkbox)
						.append(span);

				}

			}, {
				caption: L.tr('Actions'),
				format: function (v, n) {
					return $('<div />')
						.addClass('btn-group btn-group-sm')
						.append(L.ui.button(L.tr('Edit'), 'primary', L.tr('Edit Configuration'))
							.click({ self: self, sectionName: v, sectionData: rv, type: 'event' }, self.sectionEdit))
						.append(L.ui.button(L.tr('Delete'), 'danger', L.tr('Delete Configuration'))
							.click({ self: self, sectionName: v, actionData: rv, type: 'event' }, self.sectionRemove));
				}
			}]
		});

		for (var key in rv) {
			if (rv.hasOwnProperty && rv[key][".type"] == "event") {
				count++;
				var obj = rv[key];
				var enable = obj.enable;
				var eventName = obj.eventName;
				var sensorType = obj.sensorType;
				var description = "";
				var eventType = "";

				if (sensorType == "DIO") {
					var sensorNumber = obj.sensorNumber;
					eventType = sensorType + sensorNumber;
					description = "Alarm Active State : " + eventType;
				}
				else if (sensorType == "scheduledEvent") {
					eventType = "Scheduled Event";
					var enableTimeRange = obj.enableTimeRange;
					var enableDayDependency = obj.enableDayDependency;
					description = "Scheduled Time : ";
					if (enableTimeRange == "1") {
						description += "<br>Duration : " + obj.startTime + " to " + obj.endTime;
					}
					else {
						description += "<br>Duration : 24-hr";
					}
					if (enableDayDependency == "1") {
						description += "<br>On : " + obj.dayDependency;
					}
					else {
						description += "<br>On : All Days";
					}
				}
				// list.row([index, target, status, enableSlider, resetDelet]);
				list.row([key, eventName, eventType, description, enable + "," + key, key]);

			}
		}
		if (count == 0) {
			var emptyDiv = document.createElement('div');
			emptyDiv.className = "no-configurations";
			emptyDiv.innerHTML = "No Events Configured...";

			$('#renderEventsTable').append(emptyDiv);
		}
		else {
			$('#renderEventsTable').append(list.render());
		}
	},

	//renders the configured actions
	renderActionsTable: function (rv) {
		var self = this;
		var count = 0;

		var list = new L.ui.table({
			columns: [{
				caption: L.tr('Sl no.'),
				format: function (v, n) {
					var serialNumber = n + 1;
					var div = $('<p />').attr('id', 'slNo%s'.format(n));
					return div.append('<strong>' + serialNumber + '</strong>');
				}
			}, {
				caption: L.tr('Name'),
				format: function (v, n) {
					var div = $('<p />').attr('id', 'actionName%s'.format(n));
					return div.append(v);
				}
			}, {
				caption: "Event List",
				format: function (v, n) {
					var div = $('<p />').attr('id', 'eventList%s'.format(n));
					return div.append(v);
				}
			}, {
				caption: "Action List",
				format: function (v, n) {
					var div = $('<p />').attr('id', 'actionList%s'.format(n));
					return div.append(v);
				}
			}, {
				caption: L.tr('Enable/Disable'),
				width: '14%',
				align: 'center',
				format: function (v, n) {
					var myArray = v.split(",")
					var mode = myArray[0];
					var key = myArray[1];
					if (mode == 1) {
						mode = true;
					}
					else {
						mode = false;
					}
					var checkbox = $('<input />')
						.attr('type', 'checkbox')
						.attr('id', 'enableDisableSwitchAction%s'.format(n))
						.attr('checked', mode)
						.addClass('slider round')
						.click({ self: self, sectionName: key, sectionType: "action", index: "Action" + n }, self.enableDisableConfig);

					var span = $('<span />')
						.addClass('slider round');

					return $('<label />')
						.addClass('switch')
						.append(checkbox)
						.append(span);
				}

			}, {
				caption: L.tr('Actions'),
				format: function (v, n) {
					return $('<div />')
						.addClass('btn-group btn-group-sm')
						.append(L.ui.button(L.tr('Edit'), 'primary', L.tr('Edit Configuration'))
							.click({ self: self, sectionName: v, sectionData: rv, type: "action" }, self.sectionEdit))
						.append(L.ui.button(L.tr('Delete'), 'danger', L.tr('Delete Configuration'))
							.click({ self: self, sectionName: v, type: "action" }, self.sectionRemove));
				}
			}]
		});

		for (var key in rv) {
			if (rv.hasOwnProperty && rv[key][".type"] == "action") {
				count++;
				var obj = rv[key];
				var enable = obj.enable;
				var actionName = obj.actionName;
				var numberOfEvents = obj.numberOfEvents;
				var eventList = "";
				var numberOfActions = obj.numberOfActions;
				var actionList = "";

				for (var i = 0; i < numberOfEvents; i++) {
					var j = i + 1;
					var type = "event" + j + "_type";
					var eventType = obj[type];
					var name = "event" + j + "_name";
					var eventName = obj[name];
					eventList = eventList + eventType + " - " + eventName + "</br>";
				}

				for (var i = 0; i < numberOfActions; i++) {
					var j = i + 1;
					var type = "action" + j + "_type";
					var actionType = obj[type];
					actionList = actionList + actionType + "</br>";
				}

				// list.row([index, target, status, enableSlider, resetDelet]);
				list.row([key, actionName, eventList, actionList, enable + "," + key, key]);
			}
		}
		if (count == 0) {
			var emptyDiv = document.createElement('div');
			emptyDiv.className = "no-configurations";
			emptyDiv.innerHTML = "No Actions Configured...";

			$('#renderActionsTable').append(emptyDiv);
		}
		else {

			$('#renderActionsTable').append(list.render());
		}
	},

	execute: function () {
		var self = this;
		var webOptionsData;
		var modbusEventList = [];
		var AioEventList = [];
		var tempEvent = [];


		//checks whether entered input is valid phone number or not
		isValidPhoneNumber = function (ev) {
			var phoneNumber = ev.target.value;
			var element = ev.srcElement.id;
			element = element + "Validate";

			const phoneRegex = /^\+\d{12}$/;
			if (phoneRegex.test(phoneNumber)) {
				document.getElementById(element).style.display = 'none';
			}
			else {
				document.getElementById(element).style.display = 'block';
			}
		};

		//checks whether entered input is valid E-mail or not
		isValidEmail = function (ev) {
			var email = ev.target.value;
			var element = ev.srcElement.id;
			element = element + "Validate";
			// Basic email pattern based on common RFC requirements
			const emailRegex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
			if (emailRegex.test(email)) {
				document.getElementById(element).style.display = 'none';
			}
			else {
				document.getElementById(element).style.display = 'block';
			}
		};

		//to validate the custom text entered by the user
		validateInput = function (ev) {
			const errorMsg = document.getElementById("error-msg");
			const specialCharPattern = /[-,]/;
			var value = ev.target.value;
			var textarea = ev.srcElement.id;

			if (specialCharPattern.test(value)) {
				errorMsg.style.display = 'block';
			} else {
				errorMsg.style.display = 'none';
			}
		}

		/*accordion to hide and show logic in trigger and normal action in 
		  actionAddActionsModal */
		var acc = document.getElementsByClassName("accordion");
		var i;

		for (i = 0; i < acc.length; i++) {
			console.log(i);
			acc[i].addEventListener("click", function (event) {
				event.preventDefault();
				/* Toggle between adding and removing the "active" class,
				to highlight the button that controls the panel */
				this.classList.toggle("active");


				/* Toggle between hiding and showing the active panel */
				// var value = this.getAttribute('value');
				// var panel = document.getElementById(value);
				var panel = this.nextElementSibling;
				if (panel.style.display === "block") {
					panel.style.display = "none";
				} else {
					panel.style.display = "block";
				}
			});
		}


		/*to fetch data from config files 'eventConfig' and 'alarmconfig'[]AIO
		 and calling functions to render/display the details*/
		self.sensorGetUCISections("eventConfig").then(function (rv) {
			console.log(rv);
			webOptionsData = rv;
			self.sensorGetUCISections("temperatureconfig").then(function (temp) {

				for (var key in temp) {
					if (temp.hasOwnProperty(key) && temp[key][".type"] == "TemperatureConfig") {
						var obj = temp[key];
						var enable = obj.UpperThresholdAlarmEnable;
						var lowerEnable = obj.LowerThresholdAlarmEnable;

						if (enable == "1") {
							tempEvent.push(obj.UpperThresholdAlarmName);
						}
						if (lowerEnable == "1") {
							tempEvent.push(obj.LowerThresholdAlarmName);
						}

					}
				}


				//for (var key in temp) {
				//if (temp.hasOwnProperty(key) && temp[key][".type"] === "TemperatureConfig") {
				//var obj = temp[key];
				//var upperEnable = obj.UpperThresholdAlarmEnable;
				//var lowerEnable = obj.LowerThresholdAlarmEnable;

				//if (upperEnable === "1") {
				//tempEvent.push(obj.UpperThresholdAlarmName);
				//}

				//if (lowerEnable === "1") {
				//tempEvent.push(obj.LowerThresholdAlarmName);
				//}
				//}
				//}


				self.sensorGetUCISections("analoginputconfig").then(function (ev) {

					for (var key in ev) {
						if (ev.hasOwnProperty(key) && ev[key][".type"] == "analoginputconfig") {
							var obj = ev[key];

							// Define the alarm names and their corresponding keys
							var alarmEnable = [
								'AI1UpperThresholdEnable',
								'AI1LowerThresholdEnable',
								'AI2UpperThresholdEnable',
								'AI2LowerThresholdEnable'
							];
							var alarmNames = [
								'AI1UpperThresholdName',
								'AI1LowerThresholdName',
								'AI2UpperThresholdName',
								'AI2LowerThresholdName'
							];

							// Push the alarms into AioEventList with the names as defined
							for (var i = 0; i < alarmNames.length; i++) {
								var enable = obj[alarmEnable[i]];
								if (enable == '1') {
									var name = alarmNames[i];
									if (obj.hasOwnProperty(name)) {
										AioEventList.push(obj[name]);
									}
								}
							}
							//}
							//}

							//console.log(AioEventList);


							self.sensorGetUCISections("alarmconfig").then(function (ev) {

								for (var key in ev) {
									if (ev.hasOwnProperty(key) && ev[key][".type"] == "alarmconfig") {
										var obj = ev[key];
										var counter = 0;
										var alarmEnabled = 'alarmEnabled_0';

										while (obj[alarmEnabled]) {
											var alarmName = `alarmName_${counter}`;
											if (obj[alarmName]) {
												modbusEventList.push(obj[alarmName]);
											}
											counter++;
											alarmEnabled = `alarmEnabled_${counter}`;
										}
									}
								}
								console.log(modbusEventList);

							});
						}

						console.log(AioEventList);
					}



					self.renderEventsStatus(rv);
					self.renderEventsTable(rv);
					//const combinedEventList = [...modbusEventList, ...AioEventList];
					self.renderActionsTable(rv);


					//self.renderActionsTable(rv, modbusEventList);
					//self.renderActionsTable(rv, AioEventList);
				});
				console.log(tempEvent);

			});
		});



		//creating a form to add new event 
		populateEventForm = function () {
			self.emptyAllValuesInDiv('addEventsForm');
			self.populateAddEventForm(webOptionsData);
		};

		//creating a form to add new action
		populateActionForm = function () {
			self.emptyAllValuesInDiv('addActionsForm');
			self.removeBadgesInDiv('actionEventsList');
			document.getElementById('actionEventsList').style.display = "none";
			document.getElementById('actionEventsNone').style.display = "block";
			self.removeBadgesInDiv('actionActionsList');
			document.getElementById('actionActionsList').style.display = "none";
			document.getElementById('actionActionsNone').style.display = "block";
			self.populateAddActionsForm(webOptionsData);
		};

		//adding the event to config file 
		AddEditEvent = function () {
			var sectionData = {};
			var sectionName = document.getElementById('addEventButton').value;
			document.getElementById('addEventButton').value = "null";
			if (sectionName == "null") {
				sectionName = null;
				sectionData['enable'] = '1';
				sectionData['eventName'] = document.getElementById('eventName').value;
			}
			else {
				sectionData['enable'] = webOptionsData[sectionName].enable;
				sectionData['eventName'] = document.getElementById('readOnlyEventName').innerText;

			}
			sectionData['sensorType'] = document.getElementById('sensorType').value;
			sensorType = document.getElementById('sensorType').value;
			if (sensorType == 'DIO') {
				sectionData['sensorNumber'] = document.getElementById('sensorNumber').value;
			}
			else if (sensorType == 'scheduledEvent') {
				var enableTimeRange = document.getElementById('enableTimeRange').value;
				var enableDayDependency = document.getElementById('enableDayDependency').value;
				var startTime = "Any";
				var endTime = "Any";
				var dayDependency = "";
				if (enableTimeRange == "1") {
					startTime = document.getElementById('startHour').value + ":" + document.getElementById('startMin').value + ":00";
					endTime = document.getElementById('endHour').value + ":" + document.getElementById('endMin').value + ":00";
				}
				else {
					startTime = "Any";
					endTime = "Any";
				}

				if (enableDayDependency == "1") {
					day = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
					for (var key of day) {
						var dayEnable = document.getElementById(key).value;
						if (dayEnable == "1") {
							dayDependency += key + " ";
						}
					}
					if (dayDependency.length > 1) {
						dayDependency = dayDependency.slice(0, -1);
					}
				}
				else {
					dayDependency = "All";
				}
				sectionData['enableTimeRange'] = document.getElementById('enableTimeRange').value;
				sectionData['startTime'] = startTime;
				sectionData['endTime'] = endTime;
				sectionData['enableDayDependency'] = document.getElementById('enableDayDependency').value;
				sectionData['dayDependency'] = dayDependency;
			}

			if (sectionData['eventName'] == '' || sectionData['sensorType'] == '') {
				//alert("Please Fill all the mandatory fields")
				L.ui.showAlert("warning", "Empty field", "Please Fill all the mandatory fields");

			}
			else {
				self.updateSection("eventConfig", "event", sectionName, sectionData);
			}
		};

		//handles all the checkbox related display and hide logics(for all check boxes)
		enableTimeRangeOptions = function (ev) {
			var element = ev.srcElement.id;
			var value = ev.target.value;
			var option = 'timeRangeOptions';
			var flag = 0;
			if (element == 'enableDayDependency') {
				option = 'dayDependencyOptions';
			}
			else if (element == 'enableAlarmInactiveStateSms') {
				option = 'alarmInactiveStateSmsConfig';
			}
			else if (element == 'enableAlarmInactiveStateEmail') {
				option = 'alarmInactiveStateEmailConfig';
			}
			else if (element == 'enableAlarmInactiveStateDIO') {
				option = 'alarmInactiveStateDIOConfig';
			}
			else if (element == 'enableAlarmActiveStateDIO') {
				option = 'alarmActiveStateDIOConfig';
			}
			else if (element == 'enableAlarmActiveStateSms') {
				option = 'alarmActiveStateSmsConfig';
			}
			else if (element == 'enableAlarmActiveStateEmail') {
				option = 'alarmActiveStateEmailConfig';
			}
			if (element == 'enableDayDependency' || element == 'enableTimeRange' || element == 'enableAlarmInactiveStateSms' || element == 'enableAlarmInactiveStateEmail' || element == 'enableAlarmInactiveStateDIO' || element == 'enableAlarmActiveStateDIO' || element == 'enableAlarmActiveStateSms' || element == 'enableAlarmActiveStateEmail') {
				if (value == "1") {
					document.getElementById(element).value = 0;
					document.getElementById(option).style.display = "none";
				}
				else {
					document.getElementById(element).value = 1;
					document.getElementById(option).style.display = "block";
				}
			}
			else {
				if (value == "1") {
					document.getElementById(element).value = 0;
				}
				else {
					document.getElementById(element).value = 1;
				}
			}
		};

		/*handles all the display and hide blocks logics
		 for all the input selects*/
		handleOptionChange = function (ev) {
			var element = ev.srcElement.id;
			var value = ev.target.value;

			if (element == 'sensorType') {
				self.handleAddEventSensorType(value);
			}
			else if (element == 'actionEventAddType') {
				self.handleActionEventTypeChange(value, webOptionsData, modbusEventList, AioEventList, tempEvent);
			}
			else if (element == 'actionType') {
				self.handleAddActionType(value);
			}
			else if (element == 'alarmActiveStateDIOAction') {
				self.handleDIOActionChange(value, 'Active');
			}
			else if (element == 'alarmInactiveStateDIOAction') {
				self.handleDIOActionChange(value, 'Inactive');
			}
		};

		//handles creation of new modal for adding responsible events in action modal
		actionEventsAddFunction = function (event) {
			var setionName = event.target.value;
			var actionName = document.getElementById('actionName').value;
			document.getElementById('ActionEventAddHeader').innerText = "Add Events for " + actionName + "";
			document.getElementById('actionEventAddSave').value = setionName;
			$("#actionEventAddType").empty();
			$("#actionEventAddName").empty();

			$('<option />')
				.attr('value', "")
				.text("Please Choose an Option")
				.appendTo("#actionEventAddType");

			for (var key in webOptionsData['actionEventAddType']) {
				if (webOptionsData['actionEventAddType'].hasOwnProperty(key) && key.charAt(0) !== '.') {
					if (webOptionsData['actionEventAddType'][key] != 0) {
						console.log(webOptionsData['actionEventAddType'][key]);
						$('<option />')
							.attr('value', key)
							.text(webOptionsData['actionEventAddType'][key])
							.appendTo("#actionEventAddType");
					}
				}
			}

			//appending options for events
			//$('<option />')
			//.attr('value', "active")
			//.text("Active")
			//.appendTo("#actionEventAddState");

			//$('<option />')
			//.attr('value', "inactive")
			//.text("Inactive")
			//.appendTo("#actionEventAddState");

			$('#actionAddEventsModal').modal('show');
		};

		//handles creation of new modal for modifying the existing responsible event in action modal
		handleActionEventEditSave = function (event) {
			event.preventDefault();
			var setionName = event.target.value;
			var actionName = document.getElementById('actionName').value;
			document.getElementById('ActionEventAddHeader').innerText = "Add Events for " + actionName + "";
			document.getElementById('actionEventAddSave').value = setionName;
			$("#actionEventAddType").empty();
			$("#actionEventAddName").empty();

			$('<option />')
				.attr('value', "")
				.text("Please Choose an Option")
				.appendTo("#actionEventAddType");

			for (var key in webOptionsData['actionEventAddType']) {
				if (webOptionsData['actionEventAddType'].hasOwnProperty(key) && key.charAt(0) !== '.') {
					if (webOptionsData['actionEventAddType'][key] != 0) {
						console.log(webOptionsData['actionEventAddType'][key]);
						$('<option />')
							.attr('value', key)
							.text(webOptionsData['actionEventAddType'][key])
							.appendTo("#actionEventAddType");
					}
				}
			}

			//appending options for events
			//$('<option />')
			//.attr('value', "active")
			//.text("Active")
			//.appendTo("#actionEventAddState");

			//$('<option />')
			//.attr('value', "inactive")
			//.text("Inactive")
			//.appendTo("#actionEventAddState");

			var type = setionName.split(':')[0];
			var name = setionName.split(':')[1];
			var state = setionName.split(':')[2];
			self.handleActionEventTypeChange(type, webOptionsData, modbusEventList, AioEventList, tempEvent);
			document.getElementById('actionEventAddType').value = type;
			document.getElementById('actionEventAddName').value = name;
			document.getElementById('actionEventAddState').value = state;
			document.getElementById('actionEventAddSave').value = setionName;
			$('#actionAddEventsModal').modal('show');
		};

		//handles creation of new modal for adding new task/actions in action modal
		actionActionsAddFunction = function (event) {
			self.emptyAllValuesInDiv('ActionAddForm');
			var setionName = event.target.value;
			var actionName = document.getElementById('actionName').value;
			document.getElementById('ActionAddHeader').innerText = "Add Action for '" + actionName + "'";
			document.getElementById('actionAddSave').value = setionName;
			$("#actionType").empty();
			$("#alarmActiveStateDIONumber").empty();
			$("#alarmInactiveStateDIONumber").empty();

			for (var key in webOptionsData['actionType']) {
				if (webOptionsData['actionType'].hasOwnProperty(key) && key.charAt(0) !== '.') {
					if (webOptionsData['actionType'][key] != 0) {
						$('<option />')
							.attr('value', key)
							.text(key)
							.appendTo("#actionType");
					}
				}
			}

			var numberOfDIO = webOptionsData["sensorType"]["DIO"];
			for (var i = 1; i <= numberOfDIO; i++) {
				$('<option />')
					.attr('value', i)
					.text(i)
					.appendTo("#alarmActiveStateDIONumber");

				$('<option />')
					.attr('value', i)
					.text(i)
					.appendTo("#alarmInactiveStateDIONumber");

			}
			self.handleAddActionType('DIO');
			$('#actionAddActionsModal').modal('show');
		};

		//handles creation of new modal for modifying task/action in action modal
		handleActionActionEditSave = function (event) {
			event.preventDefault();
			self.emptyAllValuesInDiv('ActionAddForm');
			var setionName = event.target.value;
			var actionName = document.getElementById('actionName').value;
			document.getElementById('ActionAddHeader').innerText = "Add Action for '" + actionName + "'";
			document.getElementById('actionAddSave').value = setionName;
			$("#actionType").empty();
			$("#alarmActiveStateDIONumber").empty();
			$("#alarmInactiveStateDIONumber").empty();

			for (var key in webOptionsData['actionType']) {
				if (webOptionsData['actionType'].hasOwnProperty(key) && key.charAt(0) !== '.') {
					if (webOptionsData['actionType'][key] != 0) {
						$('<option />')
							.attr('value', key)
							.text(key)
							.appendTo("#actionType");
					}
				}
			}

			var numberOfDIO = webOptionsData["sensorType"]["DIO"];
			for (var i = 1; i <= numberOfDIO; i++) {
				$('<option />')
					.attr('value', i)
					.text(i)
					.appendTo("#alarmActiveStateDIONumber");

				$('<option />')
					.attr('value', i)
					.text(i)
					.appendTo("#alarmInactiveStateDIONumber");

			}
			self.handleAddActionType(setionName);
			var data = event.target.dataset.additional;
			var actionModalData = {};
			actionModalData['type'] = setionName;
			actionModalData['data1'] = data.split(";")[0];
			actionModalData['data2'] = data.split(";")[1];
			actionModalData['data3'] = data.split(";")[2];
			actionModalData['data4'] = data.split(";")[3];
			self.populateActionAddModal(actionModalData);
			if (actionModalData['data1'] != "null") {
				if (setionName == "DIO") {
					document.getElementById("alarmActiveStateDIOConfig").style.display = "block";
				}
				else if (setionName == "sms") {
					document.getElementById("alarmActiveStateSmsConfig").style.display = "block";
				} else if (setionName == "email") {
					document.getElementById("alarmActiveStateEmailConfig").style.display = "block";
				}
			}
			if (actionModalData['data3'] != "null") {
				if (setionName == "DIO") {
					document.getElementById("alarmInactiveStateDIOConfig").style.display = "block";
				}
				else if (setionName == "sms") {
					document.getElementById("alarmInactiveStateSmsConfig").style.display = "block";
				} else if (setionName == "email") {
					document.getElementById("alarmInactiveStateEmailConfig").style.display = "block";
				}
			}
			document.getElementById('actionAddSave').value = setionName;
			$('#actionAddActionsModal').modal('show');
		};

		//creates a new badge for the added/modified event in action modal
		handleActionEventAddSave = function (ev) {
			var value = ev.target.value;
			var type = document.getElementById('actionEventAddType').value;
			var name = document.getElementById('actionEventAddName').value;
			var state = document.getElementById('actionEventAddState').value;

			if (name == "") {
				//alert("Please Choose an Event");
				L.ui.showAlert("warning", "Empty field", "Please Choose an Event");
				return;
			}
			if (type != "scheduledEvent") {
				name = name + ":" + state;
			}
			var returnValue = self.checkForDuplicates(type, name, value);
			if (returnValue == -1) {
				//alert("The current event is already Configured");
				L.ui.showAlert("warning", "Event Configured", "The current event is already Configured");
				return;
			}
			else if (returnValue == 0) {
				self.createBadgeContainer(name, type);
				$('#actionAddEventsModal').modal('hide');
			}
			else if (returnValue == 1) {
				$('#actionAddEventsModal').modal('hide');
			}
		};

		//creates a new badge for the added/modified action in action modal
		handleActionAddSave = function (ev) {
			var value = ev.target.value;
			var type = document.getElementById('actionType').value;
			var specialCharPattern = /[-,]/;
			var alarmActiveValue1 = "null";
			var alarmActiveValue2 = "null";
			var alarmInactiveValue1 = "null";
			var alarmInactiveValue2 = "null";
			var enable1 = "0";
			var enable2 = "0";

			if (type == "") {
				//alert("Please Choose an Action Type");
				L.ui.showAlert("warning", "Empty Action Type", "Please Choose an Action Type");
				return;
			}
			else if (type == "DIO") {
				enable1 = document.getElementById('enableAlarmActiveStateDIO').value;
				if (enable1 == "1") {
					alarmActiveValue1 = document.getElementById('alarmActiveStateDIONumber').value;
					alarmActiveValue2 = document.getElementById('alarmActiveStateDIOAction').value;
					var alarmActiveOnTime = document.getElementById('alarmActiveStateOnTime').value;
					var alarmActiveOffTime = document.getElementById('alarmActiveStateOffTime').value;
					alarmActiveValue2 = alarmActiveValue2 + "-" + alarmActiveOnTime + "-" + alarmActiveOffTime;
				}
				enable2 = document.getElementById('enableAlarmInactiveStateDIO').value;
				if (enable2 == "1") {
					alarmInactiveValue1 = document.getElementById('alarmInactiveStateDIONumber').value;
					alarmInactiveValue2 = document.getElementById('alarmInactiveStateDIOAction').value;
					var alarmInactiveOnTime = document.getElementById('alarmInactiveStateOnTime').value;
					var alarmInactiveOffTime = document.getElementById('alarmInactiveStateOffTime').value;
					alarmInactiveValue2 = alarmInactiveValue2 + "-" + alarmInactiveOnTime + "-" + alarmInactiveOffTime;
				}
			}
			else if (type == "sms") {

				enable1 = document.getElementById('enableAlarmActiveStateSms').value;
				if (enable1 == "1") {
					alarmActiveValue1 = document.getElementById('alarmActiveStateSmsNumber').value;
					const phoneRegex = /^\+\d{12}$/;
					if (!phoneRegex.test(alarmActiveValue1)) {
						///alert("Enter a Valid Phone Number");
						L.ui.showAlert("error", "Invalid Phone Number", "Please enter a valid Phone Number");
						return;
					}
					var activeSerialNumber = document.getElementById('selectDeviceSerialNumber').value;
					var activeActionName = document.getElementById('selectActionName').value;
					var activeState = document.getElementById('selectState').value;
					var activeValue = document.getElementById('selectValue').value;
					var activeTimestamp = document.getElementById('selectTimestamp').value;
					var activeCustomText = document.getElementById('alarmActiveStateCustomtext').value;
					if (activeCustomText == "undefined") {
						activeCustomText = "";
					}
					else if (specialCharPattern.test(activeCustomText)) {
						//alert("Using '-' and ',' is restricted in Custom Text");
						L.ui.showAlert("error", "Restricted", "Using '-' and ',' is restricted in Custom Text");
						return;
					}
					alarmActiveValue2 = activeSerialNumber + "-" + activeActionName + "-" + activeState + "-" + activeValue + "-" + activeTimestamp + "-" + activeCustomText;
				}
				enable2 = document.getElementById('enableAlarmInactiveStateSms').value;
				if (enable2 == "1") {
					alarmInactiveValue1 = document.getElementById('alarmInactiveStateSmsNumber').value;
					const phoneRegex = /^\+\d{12}$/;
					if (!phoneRegex.test(alarmInactiveValue1)) {
						//alert("Enter a Valid Phone Number");
						L.ui.showAlert("error", "Invalid Phone Number", "Please enter a valid Phone Number");
						return;
					}
					var InactiveSerialNumber = document.getElementById('inactiveDeviceSerialNumber').value;
					var InactiveActionName = document.getElementById('inactiveActionName').value;
					var InactiveState = document.getElementById('inactiveState').value;
					var InactiveValue = document.getElementById('inactiveValue').value;
					var InactiveTimestamp = document.getElementById('inactiveTimestamp').value;
					var InactiveCustomText = document.getElementById('inactiveCustomtext').value;
					if (InactiveCustomText == "undefined") {
						InactiveCustomText = "";
					}
					else if (specialCharPattern.test(InactiveCustomText)) {
						//alert("Using '-' and ',' is restricted in Custom Text");
						L.ui.showAlert("error", "Restricted", "Using '-' and ',' is restricted in Custom Text");
						return;
					}
					alarmInactiveValue2 = InactiveSerialNumber + "-" + InactiveActionName + "-" + InactiveState + "-" + InactiveValue + "-" + InactiveTimestamp + "-" + InactiveCustomText;
				}
			}
			else if (type == "email") {
				enable1 = document.getElementById('enableAlarmActiveStateEmail').value;
				if (enable1 == "1") {
					alarmActiveValue1 = document.getElementById('alarmActiveStateEmailId').value;
					const emailRegex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
					if (!emailRegex.test(alarmActiveValue1)) {
						//alert("Enter a valid E-mail");
						L.ui.showAlert("error", "Invalid Email", "Please enter a valid E-mail");
						return;
					}
					var activeSerialNumber = document.getElementById('emailDeviceSerialNumber').value;
					var activeActionName = document.getElementById('emailActionName').value;
					var activeState = document.getElementById('emailState').value;
					var activeValue = document.getElementById('emailValue').value;
					var activeTimestamp = document.getElementById('emailTimestamp').value;
					var activeCustomText = document.getElementById('alarmActiveStateEmailCustomtext').value;
					var activeSubject = document.getElementById('alarmActiveStateSubject').value;
					if (activeCustomText == "undefined") {
						activeCustomText = "";
					}
					else if (specialCharPattern.test(activeCustomText)) {
						//alert("Using '-' and ',' is restricted in Custom Text");
						L.ui.showAlert("error", "Restricted", "Using '-' and ',' is restricted in Custom Text");
						return;
					}
					alarmActiveValue2 = activeSerialNumber + "-" + activeActionName + "-" + activeState + "-" + activeValue + "-" + activeTimestamp + "-" + activeCustomText + "-" + activeSubject;
				}
				enable2 = document.getElementById('enableAlarmInactiveStateEmail').value;
				if (enable2 == "1") {
					alarmInactiveValue1 = document.getElementById('alarmInactiveStateEmailID').value;
					const emailRegex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
					if (!emailRegex.test(alarmInactiveValue1)) {
						//alert("Enter a valid E-mail");
						L.ui.showAlert("error", "Invalid Email", "Please enter a valid E-mail");
						return;
					}
					var InactiveSerialNumber = document.getElementById('inactiveEmailDeviceSerialNumber').value;
					var InactiveActionName = document.getElementById('inactiveEmailActionName').value;
					var InactiveState = document.getElementById('inactiveEmailState').value;
					var InactiveValue = document.getElementById('inactiveEmailValue').value;
					var InactiveTimestamp = document.getElementById('inactiveEmailTimestamp').value;
					var InactiveCustomText = document.getElementById('inactiveEmailCustomtext').value;
					var InactiveSubject = document.getElementById('alarmInactiveStateSubject').value;
					if (InactiveCustomText == "undefined") {
						InactiveCustomText = "";
					}
					else if (specialCharPattern.test(InactiveCustomText)) {
						//alert("Using '-' and ',' is restricted in Custom Text");
						L.ui.showAlert("error", "Restricted", "Using '-' and ',' is restricted in Custom Text");
						return;
					}
					alarmInactiveValue2 = InactiveSerialNumber + "-" + InactiveActionName + "-" + InactiveState + "-" + InactiveValue + "-" + InactiveTimestamp + "-" + InactiveCustomText + "-" + InactiveSubject;
				}
			}

			var data = alarmActiveValue1 + ";" + alarmActiveValue2 + ";" + alarmInactiveValue1 + ";" + alarmInactiveValue2;
			var div = document.getElementById('actionActionsList');
			var flag = true;

			if (div.style.display != "none") {
				var element = div.querySelectorAll(".badge-container");
				console.log(type + ":" + value);
				for (var i = 0; i < element.length; i++) {
					if ((element[i].getAttribute('value') == type) && (type != value)) {
						//alert("The current Action Type is already Configured");
						L.ui.showAlert("warning", "Already Configured", "The current Action Type is already Configured");
						return;
					}
					else if (element[i].getAttribute('value') == value) {
						element[i].setAttribute('value', type);
						element[i].querySelector(".badge-text").textContent = type;
						element[i].setAttribute('data-additional', data);
						$('#actionAddActionsModal').modal('hide');
						return;
					}
				}
			}
			self.createActionBadge(type, data, value);
			$('#actionAddActionsModal').modal('hide');

		};

		//saves the action data into config file
		AddEditAction = function () {
			var sectionData = {};
			var sectionName = document.getElementById('addActionButton').value;
			document.getElementById('addActionButton').value = "null";
			if (sectionName == "null") {
				sectionName = null;
				sectionData['enable'] = "1";
			}
			else {
				sectionData['enable'] = webOptionsData[sectionName].enable;
			}

			sectionData['actionName'] = document.getElementById('actionName').value;
			var eventsList = document.getElementById('actionEventsList');
			sectionData['numberOfEvents'] = "0";
			if (eventsList.style.display != "none") {
				var element = eventsList.querySelectorAll(".badge-container");
				sectionData['numberOfEvents'] = element.length;
				for (var i = 0; i < element.length; i++) {
					let j = i + 1;
					sectionData['event' + j + '_type'] = element[i].getAttribute('value').split(':')[0];
					sectionData['event' + j + '_name'] = element[i].getAttribute('value').split(':')[1];
					sectionData['event' + j + '_state'] = element[i].getAttribute('value').split(':')[2];
				}
			}
			else {
				//alert("Please Add atleast one Event");
				L.ui.showAlert("warning", "Empty Event", "Please Add atleast one Event");
				return;
			}

			var actionList = document.getElementById('actionActionsList');
			sectionData['numberOfActions'] = "0";
			if (actionList.style.display != "none") {
				var element = actionList.querySelectorAll(".badge-container");
				sectionData['numberOfActions'] = element.length;
				for (var i = 0; i < element.length; i++) {
					let j = i + 1;
					var data = element[i].getAttribute('data-additional');
					var value1 = data.split(';')[0];
					var value2 = data.split(';')[1];
					var value3 = data.split(';')[2];
					var value4 = data.split(';')[3];
					var type = element[i].getAttribute('value');
					if (type == "DIO") {
						sectionData['action' + j + '_type'] = "DIO";
						sectionData['action' + j + '_triggerSensorNumber'] = value1;
						sectionData['action' + j + '_triggerAction'] = value2.split('-')[0];
						sectionData['action' + j + '_triggerOnTime'] = value2.split('-')[1];
						sectionData['action' + j + '_triggerOffTime'] = value2.split('-')[2];
						//normal state
						sectionData['action' + j + '_normalSensorNumber'] = value3;
						sectionData['action' + j + '_normalAction'] = value4.split('-')[0];
						sectionData['action' + j + '_normalOnTime'] = value4.split('-')[1];
						sectionData['action' + j + '_normalOffTime'] = value4.split('-')[2];
					}
					else if (type == "sms") {
						sectionData['action' + j + '_type'] = "sms";
						sectionData['action' + j + '_triggerPhoneNumber'] = value1;
						sectionData['action' + j + '_triggerSerialNumber'] = value2.split('-')[0];
						sectionData['action' + j + '_triggerActionName'] = value2.split('-')[1]
						sectionData['action' + j + '_triggerState'] = value2.split('-')[2];
						sectionData['action' + j + '_triggerValue'] = value2.split('-')[3];
						sectionData['action' + j + '_triggerTimestamp'] = value2.split('-')[4];
						sectionData['action' + j + '_triggerCustomText'] = value2.split('-')[5];
						//normal state
						sectionData['action' + j + '_normalPhoneNumber'] = value3;
						sectionData['action' + j + '_normalSerialNumber'] = value4.split('-')[0];
						sectionData['action' + j + '_normalActionName'] = value4.split('-')[1]
						sectionData['action' + j + '_normalState'] = value4.split('-')[2];
						sectionData['action' + j + '_normalValue'] = value4.split('-')[3];
						sectionData['action' + j + '_normalTimestamp'] = value4.split('-')[4];
						sectionData['action' + j + '_normalCustomText'] = value4.split('-')[5];
					}
					else if (type == "email") {
						sectionData['action' + j + '_type'] = "email";
						sectionData['action' + j + '_triggerPhoneNumber'] = value1;
						sectionData['action' + j + '_triggerSerialNumber'] = value2.split('-')[0];
						sectionData['action' + j + '_triggerActionName'] = value2.split('-')[1]
						sectionData['action' + j + '_triggerState'] = value2.split('-')[2];
						sectionData['action' + j + '_triggerValue'] = value2.split('-')[3];
						sectionData['action' + j + '_triggerTimestamp'] = value2.split('-')[4];
						sectionData['action' + j + '_triggerCustomText'] = value2.split('-')[5];
						sectionData['action' + j + '_triggerSubject'] = value2.split('-')[6];
						//normal state
						sectionData['action' + j + '_normalPhoneNumber'] = value3;
						sectionData['action' + j + '_normalSerialNumber'] = value4.split('-')[0];
						sectionData['action' + j + '_normalActionName'] = value4.split('-')[1]
						sectionData['action' + j + '_normalState'] = value4.split('-')[2];
						sectionData['action' + j + '_normalValue'] = value4.split('-')[3];
						sectionData['action' + j + '_normalTimestamp'] = value4.split('-')[4];
						sectionData['action' + j + '_normalCustomText'] = value4.split('-')[5];
						sectionData['action' + j + '_normalSubject'] = value4.split('-')[6];
					}
				}
			}
			else {
				//alert("Please Add atleast one Action");
				L.ui.showAlert("warning", "Empty Action", "Please Add atleast one Action");
				return;
			}

			if (sectionData['actionName'] == '') {
				//alert("Please Fill all the mandatory fields")
				L.ui.showAlert("warning", "Empty field", "Please Fill all the mandatory fields");
			}
			else {
				self.updateSection("eventConfig", "action", sectionName, sectionData);
			}
		};
	}
});
