L.ui.view.extend({

    _deviceUIInitialized: false,
    // ADD THIS BLOCK RIGHT HERE ↓
    _datatypeOptionsHTML: `
        <option value="">Select</option>
        <option value="0">Hexadecimal</option>
        <option value="11">1-bit</option>
        <option value="22">Boolean</option>
        <option value="25">INT-8(Higher byte)</option>
        <option value="26">INT-8(Lower byte)</option>
        <option value="5">INT-16 (byte order 1,2)</option>
        <option value="6">INT-16 (byte order 2,1)</option>
        <option value="9">INT-32 (byte order 1,2,3,4)</option>
        <option value="10">INT-32 (byte order 4,3,2,1)</option>
        <option value="14">INT-32 (byte order 3,4,1,2)</option>
        <option value="15">INT-32 (byte order 2,1,4,3)</option>
        <option value="19">INT Long (byte order 1-8)</option>
        <option value="23">UINT-8(Higher byte)</option>
        <option value="24">UINT-8(Lower byte)</option>
        <option value="3">UINT-16 (byte order 1,2)</option>
        <option value="4">UINT-16 (byte order 2,1)</option>
        <option value="7">UINT-32 (byte order 1,2,3,4)</option>
        <option value="8">UINT-32 (byte order 4,3,2,1)</option>
        <option value="12">UINT-32 (byte order 3,4,1,2)</option>
        <option value="13">UINT-32 (byte order 2,1,4,3)</option>
        <option value="18">UINT Long (byte order 1-8)</option>
        <option value="1">Float (byte order 1,2,3,4)</option>
        <option value="16">Float (byte order 4,3,2,1)</option>
        <option value="2">Float (byte order 3,4,1,2)</option>
        <option value="17">Float (byte order 2,1,4,3)</option>
        <option value="20">Double (byte order 1-8)</option>
        <option value="21">Hex-String</option>
    `,

    _buildRegisterRow: function (i) {
        const wrapper = document.createElement('div');
        wrapper.innerHTML = `
            <div class="row" style="margin-top:5px;">
                <div class="col-md-2">
                    <label id="requiredfield">Register Name</label>
                    <input type="text" id="registername${i}" class="form-control inputbox" name="Register Name">
                </div>
                <div class="col-md-2">
                    <label id="requiredfield">Start Register</label>
                    <input type="number" id="startregister${i}" class="form-control inputbox" name="Start Register">
                </div>
                <div class="col-md-2">
                    <label id="requiredfield">Register Count</label>
                    <input type="number" id="registercount${i}" class="form-control inputbox" name="Register Count">
                </div>
                <div class="col-md-2">
                    <label id="requiredfield">Datatype</label>
                    <select id="Datatype${i}" class="form-control inputbox" name="Datatype" onchange="handleDatatypeCodeChange(${i})">
                        ${this._datatypeOptionsHTML}
                    </select>
                </div>
                <div class="col-md-1">
                    <label>Multifactor</label>
                    <input type="number" id="multifactor${i}" onblur="validatefcatory(this)" class="form-control">
                </div>
                <div class="col-md-1 text-center">
                    <label>Alarm</label>
                    <div style="margin-top:6px;">
                        <input type="checkbox" id="enableAlarm${i}" value="0" onchange="handleRegisterAlarmToggle(${i})">
                    </div>
                </div>
                <div class="col-md-1">
                    <button type="button" id="addAlarmBtn${i}" class="btn btn-success"
                        style="margin-top:22px;" onclick="openAlarmConfigForRegister(${i})" disabled>
                        Add
                    </button>
                </div>
                <div class="col-md-1">
                    <input type="button" value="Delete" id="RegisterremoveButton,${i}"
                        onclick="removeRegister(event)" class="btn btn-danger" style="margin-top:22px">
                </div>
            </div>`;
        return wrapper;
    },

    AddBlockSection: function () {
        if (this.CounterBlock > 20) {
            L.ui.showAlert("warning", "Limit reached", "Maximum block configurations allowed is 20 only.");
            return;
        }
        var self = this;
        if (typeof self.CounterBlock === 'undefined') {
            this.CounterBlock = 0;
        }
        var new_blocksection = document.createElement('div');
        new_blocksection.innerHTML = `
            <div class="row" style="margin-top:5px";>
                <div class="col-md-3">
                     <label id="requiredfield">Function Code</label>
                    <select id="functionCode${self.CounterBlock}" class="form-control inputbox" name="Function Code" onchange="handleFunctionBlockConfig(${self.CounterBlock})">
                        <option value="1">1_Read coils</option>
                        <option value="2">2_Read discrete inputs</option>
                        <option value="3">3_Read holding registers</option>
                        <option value="4">4_Read input registers</option>
                    </select>
                </div>
                <div class="col-md-3">
                  <label id="requiredfield">Start Register</label>
                    <input type="number" id="startRegister${self.CounterBlock}" class="form-control inputbox" name="Start Register" onchange="handleFunctionBlockConfig(${self.CounterBlock})">
                </div>
                <div class="col-md-3">
                  <label id="requiredfield">Count Register</label>
                    <input type="number" id="countRegister${self.CounterBlock}" class="form-control inputbox" name="Count Register">
                </div>
                <div class="col-md-2">
                    <input type="button" value="Delete"   id="BlockremoveButton,${self.CounterBlock}" onclick="removeBlock(event)" class="btn btn-danger" style="margin-top:22px";>
                </div>
            </div>`;
        // Append to Blockregistersection
        document.getElementById('Blockregistersection').appendChild(new_blocksection);
        this.CounterBlock++;
    },


    AddRegisterSection: function () {
        if (typeof this.CounterRegister === 'undefined') this.CounterRegister = 0;
        const container = document.getElementById('Registersection');
        if (container) {
            container.appendChild(this._buildRegisterRow(this.CounterRegister));
        }
        this.CounterRegister++;
    },
    CounterRegister: 0,

    editrows: function (registerRows) {
        const self = this;

        if (!Array.isArray(registerRows) || registerRows.length === 0) {
            console.warn('editrows: no register rows to render');
            return;
        }

        const regSection = document.getElementById('Registersection');
        if (!regSection) {
            console.error('editrows: Missing Registersection');
            return;
        }

        // Detach from DOM while building — prevents reflow on every append
        const parent = regSection.parentNode;
        const nextSibling = regSection.nextSibling;
        parent.removeChild(regSection);

        // Clear and reset
        regSection.innerHTML = '';
        self.CounterRegister = 0;

        // Build all rows into a DocumentFragment (completely off-DOM)
        const fragment = document.createDocumentFragment();

        registerRows.forEach((r, i) => {
            const rowEl = self._buildRegisterRow(i);

            // Fill values directly on the element before it touches the DOM
            const nameInput = rowEl.querySelector(`#registername${i}`);
            const startInput = rowEl.querySelector(`#startregister${i}`);
            const countInput = rowEl.querySelector(`#registercount${i}`);
            const typeSelect = rowEl.querySelector(`#Datatype${i}`);
            const mfInput = rowEl.querySelector(`#multifactor${i}`);
            const alarmChk = rowEl.querySelector(`#enableAlarm${i}`);
            const alarmBtn = rowEl.querySelector(`#addAlarmBtn${i}`);

            const regName = r.registerName ?? r.registername ?? '';
            const startReg = r.startRegister ?? r.startregister ?? '';
            const regCount = r.registerCount ?? r.registercount ?? '';
            const dataType = r.dataType ?? r.Datatype ?? '';
            const multiFactor = r.multiFactor ?? r.multifactor ?? '';
            const enableAlarmVal = r.enableAlarm ?? r.EnableAlarm ?? 0;

            if (nameInput) nameInput.value = regName;
            if (startInput) startInput.value = startReg;
            if (countInput) countInput.value = regCount;
            if (typeSelect && dataType !== '') typeSelect.value = String(dataType);
            if (mfInput) mfInput.value = multiFactor;

            if (alarmChk) {
                alarmChk.checked = (enableAlarmVal === 1 || enableAlarmVal === '1' || enableAlarmVal === true);
                alarmChk.value = alarmChk.checked ? '1' : '0';
            }
            if (alarmBtn) {
                alarmBtn.disabled = !alarmChk?.checked;
                if (alarmChk?.checked) alarmBtn.textContent = 'Edit';
            }

            fragment.appendChild(rowEl);
            self.CounterRegister++;
        });

        // Single DOM write — all 500 rows appended at once
        regSection.appendChild(fragment);

        // Re-attach section — only one reflow happens here
        if (nextSibling) {
            parent.insertBefore(regSection, nextSibling);
        } else {
            parent.appendChild(regSection);
        }
    },

    CounterBlock: 0,

    Blockeditrows: function (blockRows) {
        const self = this;

        if (!Array.isArray(blockRows) || blockRows.length === 0) {
            console.warn('Blockeditrows: no rows to render');
            return;
        }

        const blockSection = document.getElementById('Blockregistersection');
        const addBlockBtn = document.getElementById('AddBlock-btn');

        if (!blockSection || !addBlockBtn) {
            console.error('Blockeditrows: Missing Blockregistersection or AddBlock-btn');
            return;
        }

        // Clear existing UI + reset counter
        blockSection.innerHTML = '';
        self.CounterBlock = 0;

        blockRows.forEach((b) => {
            // Use your existing logic to create a new block row
            addBlockBtn.click();

            // After click, CounterBlock is incremented, so current row index is CounterBlock - 1
            const i = (typeof self.CounterBlock === 'number' && self.CounterBlock > 0)
                ? (self.CounterBlock - 1)
                : 0;

            const fnInput = document.getElementById('functionCode' + i);
            const startInput = document.getElementById('startRegister' + i);
            const countInput = document.getElementById('countRegister' + i);

            if (!fnInput || !startInput || !countInput) {
                console.warn('Blockeditrows: inputs not found for index', i);
                return;
            }

            // Normalize values from API JSON
            const functionCode = b.functionCode ?? b.FunctionCode ?? b.Code ?? '';
            const startRegister = b.startRegister ?? b.StartRegister ?? b.startReg ?? '';
            const countRegister = b.countRegister ?? b.CountRegister ?? b.noOfRegister ?? '';

            fnInput.value = functionCode;
            startInput.value = startRegister;
            countInput.value = countRegister;

        });
    },

    CounterAlarm: 0,

    Alarmeditrows: function (alarmRows, registerRows) {
        const self = this;

        if (!Array.isArray(alarmRows) || alarmRows.length === 0) {
            console.warn('Alarmeditrows: no alarm rows to map');
            return;
        }
        self.registerAlarms = self.registerAlarms || {};
        // Build name -> index map from the registerRows array directly
        // This avoids getElementById which fails on detached/not-yet-attached DOM nodes
        const nameToIndex = {};
        if (Array.isArray(registerRows)) {
            registerRows.forEach((r, i) => {
                const nm = (r.registerName ?? r.registername ?? '').trim();
                if (nm) nameToIndex[nm] = i;
            });
        } else {
            // Fallback: try DOM (only if registerRows not passed)
            for (let i = 0; i < self.CounterRegister; i++) {
                const nameInput = document.getElementById('registername' + i);
                if (!nameInput) continue;
                const nm = (nameInput.value || '').trim();
                if (nm) nameToIndex[nm] = i;
            }
        }

        alarmRows.forEach(al => {
            const regName = (al.registerName || '').trim();
            if (!regName) {
                console.warn('Alarm row without registerName, skipping:', al);
                return;
            }

            const idx = nameToIndex[regName];
            if (idx === undefined) {
                console.warn('No register row found for alarm registerName =', regName);
                return;
            }

            self.registerAlarms[idx] = {
                category: String(al.category ?? 1),
                status: String(al.status ?? 0),
                name: al.alarmName ?? '',
                upperThreshold: al.upperThreshold ?? '',
                lowerThreshold: al.lowerThreshold ?? '',
                upperHysteresis: al.upperHysteresis ?? '',
                lowerHysteresis: al.lowerHysteresis ?? '',
                dataType: String(al.dataType ?? '')
            };

            // Update checkbox + button in the DOM
            const chk = document.getElementById('enableAlarm' + idx);
            const btn = document.getElementById('addAlarmBtn' + idx);

            if (chk) {
                chk.checked = true;
                chk.value = '1';
                if (typeof handleRegisterAlarmToggle === 'function') handleRegisterAlarmToggle(idx);
            }
            if (btn) {
                btn.disabled = false;
                btn.textContent = 'Edit';
            }
        });
    },
    changemodbusprotocol: function () {
        var protocolSelect = document.getElementById('protocol');
        var tcpOptions = document.getElementById('TCP_Paramters');
        var RTU_Common_Options = document.getElementById('ModbusRTU_Common_Parameters');
        var RTUOptions = document.getElementById('ModbusRTU_Paramters');
        if (protocolSelect.value === 'TCP') {
            tcpOptions.style.display = 'block';
            RTU_Common_Options.style.display = 'none';
            RTUOptions.style.display = 'none';

        } else {
            tcpOptions.style.display = 'none';
            RTU_Common_Options.style.display = 'block';
            RTUOptions.style.display = 'block';
        }
    },

    /* ---- Register / Alarm validation helpers ---- */
    isEmptyString: function (val) {
        return val === undefined || val === null || String(val).trim() === "";
    },

    /* ---- validation helpers (replace existing ones) ---- */
    validateAlarmsFields: function (alarmArray, regTypeMap) {
        // regTypeMap: Map(registerName -> datatypeCode as string)
        if (!Array.isArray(alarmArray)) return true;
        for (let i = 0; i < alarmArray.length; i++) {
            const a = alarmArray[i] || {};
            const regName = a.registerName ? String(a.registerName).trim() : "";
            const category = a.category !== undefined && a.category !== null ? String(a.category) : null;

            // If user selected Event (category==2) for this alarm -> skip threshold checks
            if (category === '2') continue;

            // If registerName maps to 1-bit/boolean datatype, skip thresholds check
            const dtype = regTypeMap && regTypeMap.has(regName) ? String(regTypeMap.get(regName)) : null;
            const is1bitOrBoolean = (dtype === '11' || dtype === '22');

            if (is1bitOrBoolean) {
                // skip threshold/hysteresis validation entirely for this alarm
                continue;
            }

            // For other datatypes and non-Event category, require both upper and lower thresholds
            if (this.isEmptyString(a.upperThreshold) || this.isEmptyString(a.lowerThreshold)) {
                //alert("Please fill Upper Threshold and Lower Thresholds");
                L.ui.showAlert("warning", "Empty fields", `Please fill Upper Threshold and Lower Thresholds.`);
                return false;
            }
        }
        return true;
    },


    validateRegistersAndAlarms: function (registerArray, alarmArray) {
        // Build map of registerName -> datatypeCode (as string) for lookup
        const regTypeMap = new Map();
        if (Array.isArray(registerArray)) {
            for (let r of registerArray) {
                const rn = r && r.registerName ? String(r.registerName).trim() : "";
                const dt = r && (r.dataType !== undefined) ? String(r.dataType).trim() : null;
                if (rn) regTypeMap.set(rn, dt);
            }
        }

        // registers that have enableAlarm === 1 must have a matching alarm entry
        const registersNeedingAlarm = new Set();
        if (Array.isArray(registerArray)) {
            for (let r of registerArray) {
                const en = r && (r.enableAlarm === 1 || r.enableAlarm === "1" || r.enableAlarm === true);
                if (en) {
                    const rn = (r && r.registerName) ? String(r.registerName).trim() : "";
                    if (rn === "") {
                        //alert("A register with Enable Alarm checked has no name. Please name the Register or disable the checkbox.");
                        L.ui.showAlert("warning", "No Name", `A register with Enable Alarm checked has no name. Please name the Register or disable the checkbox.`);
                        return false;
                    }
                    registersNeedingAlarm.add(rn);
                }
            }
        }

        // Build alarm map by registerName
        const alarmByRegister = new Map();
        if (Array.isArray(alarmArray)) {
            for (let a of alarmArray) {
                const rn = (a && a.registerName) ? String(a.registerName).trim() : "";
                if (rn) alarmByRegister.set(rn, a);
            }
        }

        // Ensure each enabled register has an alarm entry
        for (let rn of registersNeedingAlarm) {
            if (!alarmByRegister.has(rn)) {
                //  alert(`Register "${rn}" has Enable Alarm checked but no Alarm created. Please add an Alarm or uncheck the checkbox.`);
                L.ui.showAlert("warning", "No Alarm", `Register "${rn}" has Enable Alarm checked but no Alarm created. Please add an Alarm or uncheck the checkbox.`);
                return false;
            }
        }

        // Validate alarm threshold fields, but pass regTypeMap so threshold checks skip 1-bit/boolean or Event category
        if (!this.validateAlarmsFields(Array.from(alarmByRegister.values()), regTypeMap)) return false;

        return true;
    },


    validateParameterConfiguration: function () {

        const protocol = document.getElementById('protocol').value;

        const deviceName = document.getElementById('devicename').value.trim();
        const meterId = document.getElementById('equipmentid').value.trim();
        const meterModel = document.getElementById('metermodel').value.trim();
        const slaveAddress = document.getElementById('serialslaveid').value.trim();

        // RTU fields
        const baudRate = document.getElementById('serialbaudrate')?.value;
        const parity = document.getElementById('serialparity')?.value;
        const databits = document.getElementById('serialdatabits')?.value;
        const stopbits = document.getElementById('serialstopbit')?.value;
        const port = document.getElementById('serialport1')?.value;

        // TCP fields
        const commIP = document.getElementById('CommIp')?.value.trim();
        const commPort = document.getElementById('CommPort')?.value.trim();
        const commTimeout = document.getElementById('commT')?.value.trim();

        //  COMMON REQUIRED
        if (!deviceName) {
            L.ui.showAlert("warning", "Missing Field", "Device Name is required.");
            return false;
        }

        if (!meterId) {
            L.ui.showAlert("warning", "Missing Field", "Meter ID is required.");
            return false;
        }

        if (!meterModel) {
            L.ui.showAlert("warning", "Missing Field", "Meter Model is required.");
            return false;
        }

        if (!slaveAddress) {
            L.ui.showAlert("warning", "Missing Field", "Slave Address is required.");
            return false;
        }

        // ================================
        //  RTU VALIDATION
        // ================================
        if (protocol === 'RTU') {

            if (!baudRate) {
                L.ui.showAlert("warning", "Missing Field", "Baud Rate is required.");
                return false;
            }

            if (!parity) {
                L.ui.showAlert("warning", "Missing Field", "Parity is required.");
                return false;
            }

            if (!databits) {
                L.ui.showAlert("warning", "Missing Field", "Data Bits is required.");
                return false;
            }

            if (!stopbits) {
                L.ui.showAlert("warning", "Missing Field", "Stop Bits is required.");
                return false;
            }

            if (!port) {
                L.ui.showAlert("warning", "Missing Field", "Port Number is required.");
                return false;
            }
        }

        // ================================
        //  TCP VALIDATION
        // ================================
        if (protocol === 'TCP') {

            const ipRegex = /^(25[0-5]|2[0-4]\d|1?\d?\d)(\.(25[0-5]|2[0-4]\d|1?\d?\d)){3}$/;

            if (!commIP) {
                L.ui.showAlert("warning", "Missing Field", "Comm IP is required.");
                return false;
            }

            if (!ipRegex.test(commIP)) {
                L.ui.showAlert("warning", "Invalid IP", "Enter a valid IPv4 address.");
                return false;
            }

            if (!commPort) {
                L.ui.showAlert("warning", "Missing Field", "Comm Port is required.");
                return false;
            }

            if (Number(commPort) < 1 || Number(commPort) > 65535) {
                L.ui.showAlert("warning", "Invalid Port", "Comm Port must be 1–65535.");
                return false;
            }

            if (!commTimeout) {
                L.ui.showAlert("warning", "Missing Field", "Comm Timeout is required.");
                return false;
            }
        }

        return true;
    },

    // Add this as a method alongside sendAlarmConfigAPI
    fetchWithTimeout: function (url, options, timeoutMs = 10000) {
        const controller = new AbortController();
        const timer = setTimeout(() => controller.abort(), timeoutMs);
        return fetch(url, { ...options, signal: controller.signal })
            .finally(() => clearTimeout(timer));
    },

    /* ---- end replacement ---- */
    catchingJSONData: function () {
        const self = this;

        //  document.getElementById('Modbus_Submit').addEventListener('click', async function (event) {
        document.getElementById('Modbus_Submit').onclick = async function (event) {
            event.preventDefault();

            const deviceName = document.getElementById('devicename').value.trim();
            // if (!deviceName) {
            //     L.ui.showAlert("error", "Error", "Device Name cannot be empty.");
            //     return;
            // }
            // FULL PARAMETER VALIDATION
            if (!self.validateParameterConfiguration()) {
                return;
            }
            const status = $('#Modbus_Submit').attr('name');
            const actionType = (status === 'UpdatedSubmit' || status === 'UpdateModbus') ? 'Edit' : 'Add';

            // Block duplicate device name on Add
            if (actionType === 'Add') {
                const existingRows = document.querySelectorAll('#DeviceConfigTable tbody tr');
                for (let row of existingRows) {
                    if (row.cells[1]?.textContent.trim() === deviceName) {
                        L.ui.showAlert("error", "Duplicate Device", `A device named "${deviceName}" already exists. Please use a different name.`);
                        return;
                    }
                }
            }
            const modbusProtocol = document.getElementById('protocol').value;
            const meterId = parseInt(document.getElementById('equipmentid').value || '0', 10);
            const meterModel = document.getElementById('metermodel').value.trim();
            const slaveAddress = parseInt(document.getElementById('serialslaveid').value || '0', 10);

            // Comm params (TCP/RTU)
            const commIP = document.getElementById('CommIp') ? document.getElementById('CommIp').value.trim() : '';
            const commPort = parseInt(document.getElementById('CommPort') ? document.getElementById('CommPort').value : '0', 10);
            const commTimeout = parseInt(document.getElementById('commT') ? document.getElementById('commT').value : '0', 10);

            // Serial params
            const baudRate = parseInt(document.getElementById('serialbaudrate') ? document.getElementById('serialbaudrate').value : '0', 10);
            const parity = document.getElementById('serialparity') ? document.getElementById('serialparity').value : '';
            const noOfDatabits = parseInt(document.getElementById('serialdatabits') ? document.getElementById('serialdatabits').value : '0', 10);
            const noOfStopbits = parseInt(document.getElementById('serialstopbit') ? document.getElementById('serialstopbit').value : '0', 10);
            const portnumber = parseInt(document.getElementById('serialport1') ? document.getElementById('serialport1').value : '0', 10);

            // stdModbusEnable depends on protocol (you already toggle stdModbusEnable / stdModbusEnable1)
            let stdModbusEnable = 0;
            if (modbusProtocol === 'TCP') {
                if (document.getElementById('stdModbusEnable1')) stdModbusEnable = parseInt(document.getElementById('stdModbusEnable1').value || '0', 10);
            } else {
                if (document.getElementById('stdModbusEnable')) stdModbusEnable = parseInt(document.getElementById('stdModbusEnable').value || '0', 10);
            }

            const blocks = [];

            for (let i = 0; i < self.CounterBlock; i++) {
                const fnEl = document.getElementById('functionCode' + i);
                const startEl = document.getElementById('startRegister' + i);
                const countEl = document.getElementById('countRegister' + i);

                // Row was deleted — skip
                if (!fnEl) continue;

                const functionCode = parseInt(fnEl.value, 10);
                const startRegister = startEl ? startEl.value.trim() : '';
                const countRegister = countEl ? countEl.value.trim() : '';

                if (startRegister === '' || countRegister === '') {
                    L.ui.showAlert("warning", "Empty field", `Please fill all fields for Block ${i + 1}.`);
                    return;
                }

                blocks.push({
                    functionCode: Number.isNaN(functionCode) ? 0 : functionCode,
                    startRegister: parseInt(startRegister, 10),
                    countRegister: parseInt(countRegister, 10)
                });
            }
            const registers = [];
            for (let i = 0; i < self.CounterRegister; i++) {
                const nameEl = document.getElementById('registername' + i);
                const startEl = document.getElementById('startregister' + i);
                const countEl = document.getElementById('registercount' + i);
                const dataTypeEl = document.getElementById('Datatype' + i);
                const mfEl = document.getElementById('multifactor' + i);
                const enableEl = document.getElementById('enableAlarm' + i);

                // Row was deleted — skip
                if (!nameEl) continue;

                const registerName = nameEl.value.trim();
                const startRegister = startEl ? startEl.value.trim() : '';
                const registerCountVal = countEl ? countEl.value.trim() : '';
                const dataType = dataTypeEl ? dataTypeEl.value.trim() : '';
                const multiFactor = mfEl ? mfEl.value.trim() : '';
                const enableAlarm = enableEl && enableEl.checked ? 1 : 0;

                if (!registerName || startRegister === '' || registerCountVal === '' || dataType === '') {
                    L.ui.showAlert("warning", "Empty field", `Please fill all fields for Register ${i + 1}.`);
                    return;
                }

                registers.push({
                    registerName,
                    startRegister,
                    registerCount: registerCountVal,
                    dataType,
                    multiFactor,
                    enableAlarm
                });
            }
            // Collect Alarms from per-register modal data
            const alarms = [];

            // Build name->alarmCfg map directly from self.registerAlarms
            // using the register names we already collected into registers[]
            // This avoids any DOM lookups and works correctly after row deletions
            const alarmsByName = {};
            if (self.registerAlarms) {
                // registers[] was built with the correct surviving rows in order
                // walk through CounterRegister DOM slots and match by name
                let registersIdx = 0;
                for (let domIdx = 0; domIdx < self.CounterRegister; domIdx++) {
                    const alarmCfg = self.registerAlarms[domIdx];
                    if (!alarmCfg) continue;
                    // find the surviving register that owns this DOM slot
                    const nameEl = document.getElementById('registername' + domIdx);
                    if (nameEl && nameEl.value.trim()) {
                        alarmsByName[nameEl.value.trim()] = alarmCfg;
                    }
                }
            }

            for (let i = 0; i < registers.length; i++) {
                const reg = registers[i];

                // reg.enableAlarm was already correctly read during register collection
                if (!reg.enableAlarm) continue;

                const alarmCfg = alarmsByName[reg.registerName] || null;
                if (!alarmCfg) {
                    L.ui.showAlert("warning", "Configure Alarm",
                        `Please configure alarm details for register "${reg.registerName || (i + 1)}" or uncheck Enable Alarm.`);
                    return;
                }
                if (!alarmCfg.name || alarmCfg.name.trim() === "") {
                    L.ui.showAlert("warning", "Empty field",
                        `Please enter Alarm Name for register "${reg.registerName}".`);
                    return;
                }

                alarms.push({
                    alarmName: alarmCfg.name || "",
                    registerName: reg.registerName || "",
                    category: parseInt(alarmCfg.category || "1", 10),
                    status: parseInt(alarmCfg.status || "1", 10),
                    upperThreshold: alarmCfg.upperThreshold,
                    lowerThreshold: alarmCfg.lowerThreshold,
                    upperHysteresis: alarmCfg.upperHysteresis,
                    lowerHysteresis: alarmCfg.lowerHysteresis
                });
            }
            // Replace previous arrays used for payload building
            const blockArray = blocks;
            const registerArray = registers;
            const alarmArray = alarms;

            if (!self.validateRegistersAndAlarms(registerArray, alarmArray)) {
                return; // stop submission if validation fails
            }

            // Cross validation: If there is at least one Block, then at least one Register is required
            if (blockArray.length > 0 && registerArray.length === 0) {
                L.ui.showAlert("warning", "Empty Row", `You must add at least one row in the Register Configuration section.`);
                return; // stop submit / update
            }

            if (modbusProtocol === 'TCP') {
                // rudimentary IP check
                const ipRegex = /^(25[0-5]|2[0-4]\d|1?\d?\d)(\.(25[0-5]|2[0-4]\d|1?\d?\d)){3}$/;
                if (!ipRegex.test(commIP)) {
                    L.ui.showAlert("error", "Invalid IP", "Please enter a valid IPv4 address for Comm IP.");
                    return;
                }
                if (!commPort || commPort < 1 || commPort > 65535) {
                    L.ui.showAlert("error", "Invalid Comm Port", "Please enter a valid Comm Port (1-65535).");
                    return;
                }
            }

            if (!Number.isInteger(meterId) || meterId < 0) {
                L.ui.showAlert("error", "Invalid Meter ID", "Please enter a valid Meter ID (integer).");
                return;
            }

            const parameterPayload = {
                actionType,
                deviceName,
                modbusProtocol,
                meterId,
                meterModel,
                slaveAddress,
                modbusCommIP: commIP || '',
                modbusCommPort: commPort || 0,
                modbusCommTimeout: commTimeout || 0,
                modbusEnable: stdModbusEnable ? 1 : 0,
                baudRate: baudRate || 0,
                parity: parity || 0,
                noOfDatabits: noOfDatabits || 0,
                noOfStopbits: noOfStopbits || 0,
                portNumber: portnumber || 0,
                registerLength: registerArray.length,
                blockLength: blockArray.length,
                alarmLength: alarmArray.length,
                devicetype: 'modbus'
            };

            // Prepare Blocks payload
            const blocksPayload = {
                deviceName,
                numberOfBlocks: blockArray.length,
                portNumber: portnumber || 0,
                Blocks: blockArray.map(b => ({
                    functionCode: parseInt(b.functionCode || b.FunctionCode || b.Code || 0, 10),
                    startRegister: parseInt(b.startRegister || b.StartRegister || 0, 10),
                    countRegister: parseInt(b.countRegister || b.CountRegister || b.countRegister || 0, 10)
                }))
            };

            const registersPayload = {
                deviceName,
                numberOfRegisters: registerArray.length,
                portNumber: portnumber || 0,
                Registers: registerArray.map(r => ({
                    registerName: r.registerName || '',
                    startRegister: parseInt(r.startRegister || '0', 10),
                    registerCount: parseInt(r.registerCount || '0', 10),
                    dataType: parseInt(r.dataType || '0', 10),
                    multiFactor: normalizeOptionalNumber(r.multiFactor),
                    enableAlarm: r.enableAlarm ? 1 : 0
                }))
            };

            function normalizeOptionalNumber(val) {
                if (val === undefined || val === null) return "";
                const s = String(val).trim();

                // empty string → send ""
                if (s === "") return "";

                const n = Number(s);
                // if not a valid number → send ""
                if (Number.isNaN(n)) return "";

                return n; // valid number
            }

            // new: normalize a value to either "" or a stringified number
            function normalizeOptionalNumberToString(val) {
                if (val === undefined || val === null) return "";
                const s = String(val).trim();
                if (s === "") return "";
                const n = Number(s);
                if (Number.isNaN(n)) return "";
                return String(n); // RETURN AS STRING
            }

            const alarmsPayload = {
                deviceName,
                numberOfAlarms: alarmArray.length,
                portNumber: portnumber || 0,
                Alarms: alarmArray.map(a => ({
                    alarmName: a.alarmName || '',
                    registerName: a.registerName || '',
                    category: parseInt(a.category || 1, 10),
                    status: parseInt(a.status || 0, 10),
                    upperThreshold: normalizeOptionalNumberToString(a.upperThreshold),
                    lowerThreshold: normalizeOptionalNumberToString(a.lowerThreshold),
                    upperHysteresis: normalizeOptionalNumberToString(a.upperHysteresis),
                    lowerHysteresis: normalizeOptionalNumberToString(a.lowerHysteresis)
                }))
            };


            for (let i = 0; i < blocksPayload.Blocks.length; i++) {
                const b = blocksPayload.Blocks[i];
                if (!Number.isInteger(b.functionCode) || isNaN(b.startRegister) || isNaN(b.countRegister)) {
                    L.ui.showAlert("warning", "Empty field", `Please fill all fields for Block ${i + 1}.`);
                    return;
                }
            }
            for (let i = 0; i < (registersPayload.Registers || []).length; i++) {
                const r = registersPayload.Registers[i];
                if (!r.registerName || r.startRegister === "" || r.registerCount === "") {
                    L.ui.showAlert("warning", "Empty field", `Please fill all fields for Register ${i + 1}.`);
                    return;
                }
            }
            for (let i = 0; i < (alarmsPayload.Alarms || []).length; i++) {
                const al = alarmsPayload.Alarms[i];

                const category = String(al.category || '1');
                // Look up dataType by register name from alarmsByName — never by index
                const alarmCfg = alarmsByName[al.registerName] || null;
                const dtype = alarmCfg ? String(alarmCfg.dataType || '') : '';

                const skipThreshold = category === '2' || dtype === '11' || dtype === '22';

                if (skipThreshold) {
                    al.upperThreshold = "";
                    al.lowerThreshold = "";
                    al.upperHysteresis = "";
                    al.lowerHysteresis = "";
                    continue;
                }

                const upper = Number(al.upperThreshold);
                const lower = Number(al.lowerThreshold);

                if (
                    al.upperThreshold !== "" &&
                    al.lowerThreshold !== "" &&
                    !Number.isNaN(upper) &&
                    !Number.isNaN(lower) &&
                    upper <= lower
                ) {
                    const registerName = al.registerName || `Row ${i + 1}`;
                    L.ui.showAlert("warning", "Invalid Alarm Threshold",
                        `For Register ${registerName}, the alarm's upper threshold must be greater than lower threshold.`);
                    return;
                }
            }

            // Show loading overlay (same element you used in SNMP)
            if (document.getElementById('loadingOverlay')) document.getElementById('loadingOverlay').style.display = 'flex';

            try {
                // Expect these functions to be implemented similar to SNMP's send* API functions
                await self.sendParameterConfigAPI(parameterPayload);

                await self.sendBlockConfigAPI(blocksPayload);

                await self.sendRegisterConfigAPI(registersPayload);

                await self.sendAlarmConfigAPI(alarmsPayload);

                // const cloudPayload = self.getCloudConfigFromForm(parameterPayload.deviceName);
                // await self.sendCloudConfigAPI(cloudPayload);

                // On success: toast, update table, hide modal, reload if desired (mirrors SNMP behavior)
                L.ui.showAlert("success", "Success", "Device saved successfully!");
                // attempt to update the table row or append new row using your existing function (if available)
                if (typeof self.addDeviceDataToTable === 'function') self.addDeviceDataToTable(parameterPayload, status !== 'submit');
                // hide modal (same id used elsewhere)
                $('#Modbus-Model').modal('hide');

                const tableBody = document.querySelector('#DeviceConfigTable tbody');
                const tableHead = document.querySelector('#DeviceConfigTable thead');
                const tableContainer = document.querySelector('.table-container');
                if (tableBody) tableBody.innerHTML = '';
                if (tableHead) tableHead.innerHTML = '';
                if (tableContainer) tableContainer.style.display = 'none';
                self.fetchDeviceConfigList();

            } catch (err) {
                console.error('Failed to save device configuration:', err);
                L.ui.showAlert("error", "Error", "Failed to save device!");
            } finally {
                if (document.getElementById('loadingOverlay')) document.getElementById('loadingOverlay').style.display = 'none';
            }
        };
    },
    // START
    // sendParameterConfigAPI: function (parameterConfig) {
    //     let params = window.location.href;
    //     let BaseURL = new URL(params).origin;

    //     return fetch(`${BaseURL}:30006/Device_post/`, {
    //         // return fetch(mockURL, {
    //         method: "POST",
    //         headers: { "Content-Type": "application/json" },
    //         body: JSON.stringify(parameterConfig)
    //     })
    //         .then(response => {
    //             if (!response.ok) {
    //                 return response.text().then(text => {
    //                     const msg = text || `Mock request failed (status ${response.status})`;
    //                     throw new Error(msg);
    //                 });
    //             }
    //             return response.text();
    //         })
    //         .then(text => {
    //             return text;
    //         });
    // },

    // sendBlockConfigAPI: function (blockConfig) {
    //     let params = window.location.href;
    //     let BaseURL = new URL(params).origin;

    //     return fetch(`${BaseURL}:30006/Block_post/`, {
    //         //return fetch(mockURL, {
    //         method: "POST",
    //         headers: { "Content-Type": "application/json" },
    //         body: JSON.stringify(blockConfig)
    //     })
    //         .then(response => {
    //             if (!response.ok) {
    //                 return response.text().then(text => {
    //                     const msg = text || `Mock Block request failed (status ${response.status})`;
    //                     throw new Error(msg);
    //                 });
    //             }
    //             return response.text();
    //         })
    //         .then(text => {
    //             return text;
    //         });
    // },

    // sendRegisterConfigAPI: function (registerConfig) {
    //     let params = window.location.href;
    //     let BaseURL = new URL(params).origin;

    //     return fetch(`${BaseURL}:30006/Register_post/`, {
    //         //return fetch(mockURL, {
    //         method: "POST",
    //         headers: { "Content-Type": "application/json" },
    //         body: JSON.stringify(registerConfig)
    //     })
    //         .then(response => {
    //             if (!response.ok) {
    //                 return response.text().then(text => {
    //                     const msg = text || `Register request failed (status ${response.status})`;
    //                     throw new Error(msg);
    //                 });
    //             }
    //             return response.text();
    //         })
    //         .then(text => {
    //             return text;
    //         });
    // },

    // sendAlarmConfigAPI: function (alarmConfig) {
    //     const BaseURL = new URL(window.location.href).origin;
    //     return this.fetchWithTimeout(`${BaseURL}:30006/Alarm_post/`, {
    //         method: 'POST',
    //         headers: { 'Content-Type': 'application/json' },
    //         body: JSON.stringify(alarmConfig)
    //     }).then(response => {
    //         if (!response.ok) {
    //             return response.text().then(text => {
    //                 throw new Error(text || `Alarm request failed (status ${response.status})`);
    //             });
    //         }
    //         return response.text();
    //     }).catch(err => {
    //         // ERR_EMPTY_RESPONSE or timeout — log but don't block save
    //         console.warn('sendAlarmConfigAPI failed (non-critical):', err.message);
    //     });
    // },

    sendParameterConfigAPI: function (parameterConfig) {
        let params = window.location.href;
        let BaseURL = new URL(params).origin;

        return fetch(`${BaseURL}:30006/Device_post/`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(parameterConfig)
        })
            .then(response => {
                if (!response.ok) {
                    return response.text().then(text => {
                        const msg = text || `Mock request failed (status ${response.status})`;
                        throw new Error(msg);
                    });
                }
                return response.json();
            })
            .then(json => {
                if (json.status !== "success") {
                    throw new Error("Save was not successful");
                }
                return json;
            });
    },

    sendBlockConfigAPI: function (blockConfig) {
        let params = window.location.href;
        let BaseURL = new URL(params).origin;

        return fetch(`${BaseURL}:30006/Block_post/`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(blockConfig)
        })
            .then(response => {
                if (!response.ok) {
                    return response.text().then(text => {
                        const msg = text || `Mock Block request failed (status ${response.status})`;
                        throw new Error(msg);
                    });
                }
                return response.json();
            })
            .then(json => {
                if (json.status !== "success") {
                    throw new Error("Save was not successful");
                }
                return json;
            });
    },

    sendRegisterConfigAPI: function (registerConfig) {
        let params = window.location.href;
        let BaseURL = new URL(params).origin;

        return fetch(`${BaseURL}:30006/Register_post/`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(registerConfig)
        })
            .then(response => {
                if (!response.ok) {
                    return response.text().then(text => {
                        const msg = text || `Register request failed (status ${response.status})`;
                        throw new Error(msg);
                    });
                }
                return response.json();
            })
            .then(json => {
                if (json.status !== "success") {
                    throw new Error("Save was not successful");
                }
                return json;
            });
    },

    sendAlarmConfigAPI: function (alarmConfig) {
        const BaseURL = new URL(window.location.href).origin;
        return this.fetchWithTimeout(`${BaseURL}:30006/Alarm_post/`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(alarmConfig)
        })
            .then(response => {
                if (!response.ok) {
                    return response.text().then(text => {
                        throw new Error(text || `Alarm request failed (status ${response.status})`);
                    });
                }
                return response.json();
            })
            .then(json => {
                if (json.status !== "success") {
                    throw new Error("Save was not successful");
                }
                return json;
            })
            .catch(err => {
                console.warn('sendAlarmConfigAPI failed (non-critical):', err.message);
            });
    },

    sendDeleteBlockAPI: function (deviceName, portNumber, index) {
        var self = this;
        let params = window.location.href;
        let BaseURL = new URL(params).origin;

        const payload = {
            deviceName: deviceName || "",
            portNumber: portNumber || 0,
            actionType: "deleteblock",
            index: String(index)
        };


        return fetch(`${BaseURL}:30006/DeleteBlock_post/`, {
            //return fetch(mockURL, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(payload)
        })
            .then(response => {
                if (!response.ok) {
                    return response.text().then(text => {
                        const msg = text || `Delete Block request failed (status ${response.status})`;
                        throw new Error(msg);
                    });
                }
                return response.text();
            })
            .then(text => {
                return text;
            });
    },


    // sendCloudConfigAPI: async function (cloudPayload) {
    //     const BaseURL = new URL(window.location.href).origin;
    //     try {
    //         const res = await this.fetchWithTimeout(`${BaseURL}:30006/Modbus_Cloud_Post/`, {
    //             method: 'POST',
    //             headers: { 'Content-Type': 'application/json' },
    //             body: JSON.stringify(cloudPayload)
    //         });
    //         if (!res.ok) {
    //             console.error('Cloud Config POST failed, status:', res.status);
    //         }
    //     } catch (err) {
    //         // ERR_EMPTY_RESPONSE or timeout — log but don't block save
    //         console.warn('sendCloudConfigAPI failed (non-critical):', err.message);
    //     }
    // },

    sendDeleteDeviceAPI: async function (deviceName, portNumber) {

        if (!deviceName) {
            console.error('sendDeleteDeviceAPI called without deviceName');
            throw new Error('Missing deviceName');
        }

        const BaseURL = new URL(window.location.href).origin;
        const endpoint = `${BaseURL}:30006/Device_post/`;

        const payload = {
            actionType: "Delete",
            deviceName: deviceName,
            portNumber: Number(portNumber)
        };

        const res = await fetch(endpoint, {
            method: 'POST', // backend expects POST
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(payload)
        });

        if (!res.ok) {
            const errorText = await res.text().catch(() => '');
            console.error('Delete device failed:', res.status, errorText);
            throw new Error(`Delete API failed with status ${res.status}`);
        }

        return await res.json(); // important for confirmation
    },


    // editDevice: async function (deviceName) {
    //     const self = this;
    //     if (!deviceName) {
    //         console.error('editDevice called without deviceName');
    //         return;
    //     }
    //     $('#Modbus_Submit').attr('name', 'UpdateModbus');
    //     $('#Modbus_Submit').text('Update');
    //     $('#Modbus-ModelLabel').text('Update Modbus Configuration');

    //     const paramForm = document.querySelector('#parameterconfig form');
    //     if (paramForm) paramForm.reset();

    //     // ---- Clear dynamic sections (Block / Register / Alarm) ----
    //     const blockSection = document.getElementById('Blockregistersection');
    //     const regSection = document.getElementById('Registersection');
    //     const alarmSection = document.getElementById('Alarm_Event_section');

    //     if (blockSection) blockSection.innerHTML = '';
    //     if (regSection) regSection.innerHTML = '';
    //     if (alarmSection) alarmSection.innerHTML = '';

    //     // Reset counters used while adding rows dynamically
    //     self.CounterBlock = 0;
    //     self.CounterRegister = 0;
    //     self.CounterAlarm = 0;

    //     // Device name fixed while editing
    //     const devNameInput = document.getElementById('devicename');
    //     if (devNameInput) {
    //         devNameInput.value = deviceName;
    //         devNameInput.readOnly = true;
    //     }

    //     // Show Parameter tab and open modal immediately (same UX as SNMP)
    //     $('#myTab a[href="#parameterconfig"]').tab('show');
    //     $('#Modbus-Model').modal('show');

    //     // Show loading overlay while all APIs are being fetched
    //     if (document.getElementById('loadingOverlay')) {
    //         document.getElementById('loadingOverlay').style.display = 'flex';
    //     }

    //     try {
    //         // Fetch all configs in parallel for this device
    //         const [
    //             paramConfig,
    //             blockRows,
    //             registerRows,
    //             alarmRows
    //            // cloudCfg
    //         ] = await Promise.all([
    //             self.fetchParameterConfigAPI(deviceName),  // returns single object or null
    //             self.fetchBlockConfigAPI(deviceName),      // returns array of blocks
    //             self.fetchRegisterConfigAPI(deviceName),   // returns array of registers
    //             self.fetchAlarmConfigAPI(deviceName),     // returns array of alarms
    //             //self.fetchCloudConfigAPI(deviceName)
    //         ]);
    //         if (paramConfig) {
    //             self.populateParameterConfigForm(paramConfig, deviceName);
    //         } else {
    //             console.warn('No Parameter Config returned for device:', deviceName);
    //         }

    //         // ---- Populate Block Configuration ----
    //         if (Array.isArray(blockRows) && blockRows.length) {
    //             // Blockeditrows should create the block rows in #Blockregistersection
    //             self.Blockeditrows(blockRows);
    //         } else {
    //         }

    //         if (Array.isArray(registerRows) && registerRows.length) {
    //             self.editrows(registerRows);
    //         }
    //         if (Array.isArray(alarmRows) && alarmRows.length) {
    //             self.Alarmeditrows(alarmRows, registerRows);  // pass registerRows too
    //         }
    //         // ---- Cloud ----
    //         if (cloudCfg) {
    //             self.populateCloudConfigForm(cloudCfg, deviceName);
    //         } else {
    //         }


    //     } catch (err) {
    //         console.error('Error while loading configs for device:', deviceName, err);
    //         // No toast here to avoid “Failed…” popup if just one of them fails
    //     } finally {
    //         if (document.getElementById('loadingOverlay')) {
    //             document.getElementById('loadingOverlay').style.display = 'none';
    //         }
    //     }
    // },
    editDevice: async function (deviceName) {
        const self = this;
        if (!deviceName) return;

        // Reset UI
        $('#Modbus_Submit').attr('name', 'UpdateModbus').text('Update');
        $('#Modbus-ModelLabel').text('Update Modbus Configuration');

        const blockSection = document.getElementById('Blockregistersection');
        const regSection = document.getElementById('Registersection');
        const alarmSection = document.getElementById('Alarm_Event_section');
        if (blockSection) blockSection.innerHTML = '';
        if (regSection) regSection.innerHTML = '';
        if (alarmSection) alarmSection.innerHTML = '';

        self.CounterBlock = 0;
        self.CounterRegister = 0;
        self.CounterAlarm = 0;
        self.registerAlarms = {};

        const devNameInput = document.getElementById('devicename');
        if (devNameInput) {
            devNameInput.value = deviceName;
            devNameInput.readOnly = true;
        }

        $('#myTab a[href="#parameterconfig"]').tab('show');

        // Wait for modal to be fully shown before fetching/rendering
        // .one() means this fires only once per open, not every time
        $('#Modbus-Model').one('shown.bs.modal', async function () {
            if (document.getElementById('loadingOverlay')) {
                document.getElementById('loadingOverlay').style.display = 'flex';
            }

            try {
                const [paramConfig, blockRows, registerRows, alarmRows] = await Promise.all([
                    self.fetchParameterConfigAPI(deviceName),
                    self.fetchBlockConfigAPI(deviceName),
                    self.fetchRegisterConfigAPI(deviceName),
                    self.fetchAlarmConfigAPI(deviceName),
                ]);

                if (paramConfig) self.populateParameterConfigForm(paramConfig, deviceName);
                if (Array.isArray(blockRows) && blockRows.length) self.Blockeditrows(blockRows);
                if (Array.isArray(registerRows) && registerRows.length) self.editrows(registerRows);
                if (Array.isArray(alarmRows) && alarmRows.length) self.Alarmeditrows(alarmRows, registerRows);

            } catch (err) {
                console.error('Error loading configs for device:', deviceName, err);
            } finally {
                if (document.getElementById('loadingOverlay')) {
                    document.getElementById('loadingOverlay').style.display = 'none';
                }
            }
        });

        $('#Modbus-Model').modal('show');
    },
    fetchParameterConfigAPI: async function (deviceName) {
        let params = window.location.href;
        let BaseURL = new URL(params).origin;

        try {
            const res = await fetch(`${BaseURL}:30006/Parameter_Configuration/${deviceName}`);
            //const res = await fetch(endpoint);

            if (!res.ok) {
                console.error(`Parameter config fetch failed (status ${res.status})`);
                return null;
            }

            const data = await res.json();
            let config = null;

            if (Array.isArray(data)) {
                // find the object that matches this deviceName
                config = data.find(d => d.deviceName === deviceName || d.devicename === deviceName) || null;
            } else if (data && (data.deviceName === deviceName || data.devicename === deviceName)) {
                config = data;
            }

            if (!config) {
                console.warn('No parameter config found for device:', deviceName);
                return null;
            }
            return config;
        } catch (err) {
            console.error('Error fetching Parameter Config:', err);
            return null;
        }
    },

    populateParameterConfigForm: function (config, requestedDeviceName) {
        if (!config) {
            console.warn('populateParameterConfigForm called with empty config');
            return;
        }

        // Prefer requestedDeviceName or current input value over config.deviceName
        const devNameInput = document.getElementById('devicename');
        const deviceName =
            requestedDeviceName ||
            (devNameInput ? devNameInput.value : '') ||
            config.deviceName ||
            config.devicename ||
            '';

        const modbusProtocol = config.modbusProtocol || config.Protocol || config.protocol || 'RTU';
        const meterId = config.meterId ?? config.MeterID ?? '';
        const meterModel = config.meterModel || '';
        const slaveAddress = config.slaveAddress ?? config.SlaveID ?? config.slaveID ?? '';

        const modbusCommIP = config.modbusCommIP || config.modbusCommIp || config['modbusCommIP:'] || '';
        const modbusCommPort = config.modbusCommPort ?? config['modbusCommPort:'] ?? '';
        const modbusCommTimeout = config.modbusCommTimeout ?? config['modbusCommTimeout:'] ?? '';

        const baudRate = config.baudRate ?? '';
        const parity = config.parity ?? '';
        const noOfDatabits = config.noOfDatabits ?? '';
        const noOfStopbits = config.noOfStopbits ?? '';
        const portNumber = config.portNumber ?? '';

        const modbusEnable = config.modbusEnable ?? 0;

        // ---- Set basic fields ----
        if (devNameInput) {
            devNameInput.value = deviceName;
            devNameInput.readOnly = true;
        }

        const protSel = document.getElementById('protocol');
        if (protSel) protSel.value = modbusProtocol;

        const meterIdInput = document.getElementById('equipmentid');
        if (meterIdInput) meterIdInput.value = meterId;

        const meterModelInput = document.getElementById('metermodel');
        if (meterModelInput) meterModelInput.value = meterModel;

        const slaveInput = document.getElementById('serialslaveid');
        if (slaveInput) slaveInput.value = slaveAddress;

        // ---- Serial params ----
        const baudSel = document.getElementById('serialbaudrate');
        if (baudSel && baudRate !== '') baudSel.value = String(baudRate);

        const paritySel = document.getElementById('serialparity');
        if (paritySel && parity !== '') paritySel.value = String(parity);

        const dataBitsSel = document.getElementById('serialdatabits');
        if (dataBitsSel && noOfDatabits !== '') dataBitsSel.value = String(noOfDatabits);

        const stopBitsSel = document.getElementById('serialstopbit');
        if (stopBitsSel && noOfStopbits !== '') stopBitsSel.value = String(noOfStopbits);

        const portSel = document.getElementById('serialport1');
        if (portSel && portNumber !== '') portSel.value = String(portNumber);

        // ---- TCP params ----
        const commIpInput = document.getElementById('CommIp');
        if (commIpInput) commIpInput.value = modbusCommIP;

        const commPortInput = document.getElementById('CommPort');
        if (commPortInput && modbusCommPort !== '') commPortInput.value = modbusCommPort;

        const commTInput = document.getElementById('commT');
        if (commTInput && modbusCommTimeout !== '') commTInput.value = modbusCommTimeout;

        // ---- RTU vs TCP sections ----
        const rtuParamsRow = document.getElementById('ModbusRTU_Paramters');
        const rtuCommonRow = document.getElementById('ModbusRTU_Common_Parameters');
        const tcpParamsRow = document.getElementById('TCP_Paramters');

        if (modbusProtocol === 'TCP') {
            if (rtuParamsRow) rtuParamsRow.style.display = 'none';
            if (rtuCommonRow) rtuCommonRow.style.display = 'none';
            if (tcpParamsRow) tcpParamsRow.style.display = 'flex';
        } else {
            if (rtuParamsRow) rtuParamsRow.style.display = 'flex';
            if (rtuCommonRow) rtuCommonRow.style.display = 'flex';
            if (tcpParamsRow) tcpParamsRow.style.display = 'none';
        }

        // ---- Standard Modbus Address Translation based on modbusEnable ----
        if (modbusProtocol === 'TCP') {
            const stdSel1 = document.getElementById('stdModbusEnable1');
            if (stdSel1) stdSel1.value = modbusEnable ? '1' : '0';
        } else {
            const stdSel = document.getElementById('stdModbusEnable');
            if (stdSel) stdSel.value = modbusEnable ? '1' : '0';
        }
    },


    fetchBlockConfigAPI: async function (deviceName) {
        let params = window.location.href;
        let BaseURL = new URL(params).origin;
        try {
            const res = await fetch(`${BaseURL}:30006/Block_Configuration/${deviceName}`);
            // const res = await fetch(endpoint);
            if (!res.ok) {
                console.error(`Block config fetch failed (status ${res.status})`);
                return [];
            }

            const data = await res.json();
            let cfg = null;

            if (Array.isArray(data)) {
                cfg = data.find(d =>
                    d.deviceName === deviceName ||
                    d.devicename === deviceName
                ) || null;
            } else {
                cfg = data;
                if (
                    cfg &&
                    (cfg.deviceName || cfg.devicename) &&
                    cfg.deviceName !== deviceName &&
                    cfg.devicename !== deviceName
                ) {
                    console.warn('Block config belongs to different device:', cfg.deviceName || cfg.devicename);
                    return [];
                }
            }

            if (!cfg) {
                console.warn('No Block config found for device:', deviceName);
                return [];
            }

            const rawBlocks = Array.isArray(cfg.Blocks) ? cfg.Blocks : [];

            // (so it works whether it uses FunctionCode/StartRegister or functionCode/startRegister)
            const blocks = rawBlocks.map(b => ({
                // both lower & upper camel just in case
                functionCode: b.functionCode ?? b.FunctionCode ?? b.Code ?? 0,
                FunctionCode: b.FunctionCode ?? b.functionCode ?? b.Code ?? 0,

                startRegister: b.startRegister ?? b.StartRegister ?? 0,
                StartRegister: b.StartRegister ?? b.startRegister ?? 0,

                countRegister: b.countRegister ?? b.CountRegister ?? b.noOfRegister ?? 0,
                CountRegister: b.CountRegister ?? b.countRegister ?? b.noOfRegister ?? 0
            }));

            return blocks; // this goes into self.Blockeditrows(blocks)
        } catch (err) {
            console.error('Error fetching Block Config:', err);
            return [];
        }
    },


    fetchRegisterConfigAPI: async function (deviceName) {
        let params = window.location.href;
        let BaseURL = new URL(params).origin;
        try {
            const res = await fetch(`${BaseURL}:30006/Register_Configuration/${deviceName}`);
            //const res = await fetch(endpoint);
            if (!res.ok) {
                console.error(`Register config fetch failed (status ${res.status})`);
                return [];
            }

            const data = await res.json();
            let cfg = null;

            // Could be array of device configs or a single object
            if (Array.isArray(data)) {
                cfg = data.find(d =>
                    d.deviceName === deviceName ||
                    d.devicename === deviceName
                ) || null;
            } else {
                cfg = data;
                if (
                    cfg &&
                    (cfg.deviceName || cfg.devicename) &&
                    cfg.deviceName !== deviceName &&
                    cfg.devicename !== deviceName
                ) {
                    console.warn('Register config belongs to different device:', cfg.deviceName || cfg.devicename);
                    return [];
                }
            }

            if (!cfg) {
                console.warn('No Register config found for device:', deviceName);
                return [];
            }

            const regs = Array.isArray(cfg.Registers)
                ? cfg.Registers
                : Array.isArray(cfg.registers)
                    ? cfg.registers
                    : [];
            return regs;
        } catch (err) {
            console.error('Error fetching Register Config:', err);
            return [];
        }
    },
    fetchAlarmConfigAPI: async function (deviceName) {
        let params = window.location.href;
        let BaseURL = new URL(params).origin;
        try {
            const res = await fetch(`${BaseURL}:30006/Alarm_Configuration/${deviceName}`);
            //const res = await fetch(endpoint);
            if (!res.ok) {
                console.error(`Alarm config fetch failed (status ${res.status})`);
                return [];
            }

            const data = await res.json();
            let cfg = null;
            if (Array.isArray(data)) {
                cfg = data.find(d =>
                    d.deviceName === deviceName ||
                    d.devicename === deviceName
                ) || null;
            } else {
                // single object
                // FIXED:
                const fetchedName = data.deviceName || data.devicename || '';
                if (!fetchedName || fetchedName === deviceName) {
                    cfg = data;  // accept if name matches OR if object has no name field
                } else {
                    console.warn('Alarm config belongs to different device:', fetchedName);
                    return [];
                }
            }

            if (!cfg) {
                console.warn('No Alarm config found for device:', deviceName);
                return [];
            }

            const alarms = Array.isArray(cfg.alarms) ? cfg.alarms
                : Array.isArray(cfg.Alarms) ? cfg.Alarms
                    : [];

            const normalized = alarms.map(al => ({
                registerName: al.registerName ?? al.regName ?? '',
                alarmName: al.alarmName ?? '',
                category: al.category ?? al.Category ?? 1,
                status: al.status ?? al.alarmEnabled ?? 0,
                upperThreshold: al.upperThreshold ?? '',
                lowerThreshold: al.lowerThreshold ?? '',
                upperHysteresis: al.upperHysteresis ?? '',
                lowerHysteresis: al.lowerHysteresis ?? ''
            }));

            return normalized;


        } catch (err) {
            console.error('Error fetching Alarm Config:', err);
            return [];
        }
    },

    getCloudConfigFromForm: function (deviceName) {
        const dsmSelect = document.getElementById('dataSendingMethod');
        const topic1Inp = document.getElementById('topicname');
        const topic2Inp = document.getElementById('topicnametwo');

        const enableHeader = document.getElementById('enableJsonHeaderKey');
        const headerKeyName = document.getElementById('jsonHeaderKeyName');

        const enableCF1 = document.getElementById('enableCustomField1');
        const jsonKeyName1 = document.getElementById('jsonKeyName1');
        const jsonKeyValue1 = document.getElementById('jsonKeyValue1');

        const enableCF2 = document.getElementById('enableCustomField2');
        const jsonKeyName2 = document.getElementById('jsonKeyName2');
        const jsonKeyValue2 = document.getElementById('jsonKeyValue2');

        const enableCF3 = document.getElementById('enableCustomField3');
        const jsonKeyName3 = document.getElementById('jsonKeyName3');
        const jsonKeyValue3 = document.getElementById('jsonKeyValue3');

        let dsmStr = 'Primary';
        if (dsmSelect) {
            if (dsmSelect.value === '2') dsmStr = 'Secondary';
            else if (dsmSelect.value === '3') dsmStr = 'Both';
        }

        const cloudJson = {
            deviceName: deviceName,
            "Data Sending Method": dsmStr,
            topic1: topic1Inp ? topic1Inp.value : '',
            topic2: topic2Inp ? topic2Inp.value : '',
            Cloud: [
                {
                    enableJSONHeaderKey: enableHeader && enableHeader.checked ? 1 : 0,
                    jsonKeyName: headerKeyName ? headerKeyName.value : '',
                    // No input for header value in UI, so keep empty or same as name if you want
                    // jsonKeyValue: ''
                },
                {
                    enableCustomField1: enableCF1 && enableCF1.checked ? 1 : 0,
                    jsonKeyName: jsonKeyName1 ? jsonKeyName1.value : '',
                    jsonKeyValue: jsonKeyValue1 ? jsonKeyValue1.value : ''
                },
                {
                    enableCustomField2: enableCF2 && enableCF2.checked ? 1 : 0,
                    jsonKeyName: jsonKeyName2 ? jsonKeyName2.value : '',
                    jsonKeyValue: jsonKeyValue2 ? jsonKeyValue2.value : ''
                },
                {
                    enableCustomField3: enableCF3 && enableCF3.checked ? 1 : 0,
                    jsonKeyName: jsonKeyName3 ? jsonKeyName3.value : '',
                    jsonKeyValue: jsonKeyValue3 ? jsonKeyValue3.value : ''
                }
            ]
        };

        return cloudJson;
    },

    populateCloudConfigForm: function (cfg, requestedDeviceName) {
        if (!cfg) {
            console.warn('populateCloudConfigForm called with empty cfg');
            return;
        }

        // ---- Data Sending Method + topics ----
        const dsmSelect = document.getElementById('dataSendingMethod');
        const topic1Inp = document.getElementById('topicname');
        const topic2Inp = document.getElementById('topicnametwo');

        if (dsmSelect) {
            const dsm = (cfg["Data Sending Method"] || '').toLowerCase();

            let val = '1'; // default Primary
            if (dsm === 'primary') val = '1';
            else if (dsm === 'secondary') val = '2';
            else if (dsm === 'both') val = '3';

            dsmSelect.value = val;
        }

        if (topic1Inp) topic1Inp.value = cfg.topic1 || '';
        if (topic2Inp) topic2Inp.value = cfg.topic2 || '';

        // ---- Cloud array (header + custom fields) ----
        const cloudArr = Array.isArray(cfg.Cloud) ? cfg.Cloud : [];

        const headerObj = cloudArr.find(c => 'enableJSONHeaderKey' in c) || {};
        const custom1Obj = cloudArr.find(c => 'enableCustomField1' in c) || {};
        const custom2Obj = cloudArr.find(c => 'enableCustomField2' in c) || {};
        const custom3Obj = cloudArr.find(c => 'enableCustomField3' in c) || {};

        const enableHeader = document.getElementById('enableJsonHeaderKey');
        const headerKeyName = document.getElementById('jsonHeaderKeyName');

        const enableCF1 = document.getElementById('enableCustomField1');
        const jsonKeyName1 = document.getElementById('jsonKeyName1');
        const jsonKeyValue1 = document.getElementById('jsonKeyValue1');

        const enableCF2 = document.getElementById('enableCustomField2');
        const jsonKeyName2 = document.getElementById('jsonKeyName2');
        const jsonKeyValue2 = document.getElementById('jsonKeyValue2');

        const enableCF3 = document.getElementById('enableCustomField3');
        const jsonKeyName3 = document.getElementById('jsonKeyName3');
        const jsonKeyValue3 = document.getElementById('jsonKeyValue3');

        // Header
        if (enableHeader) {
            enableHeader.checked = Number(headerObj.enableJSONHeaderKey || 0) === 1;
        }
        if (headerKeyName) headerKeyName.value = headerObj.jsonKeyName || '';

        // Custom Field 1
        if (enableCF1) {
            enableCF1.checked = Number(custom1Obj.enableCustomField1 || 0) === 1;
        }
        if (jsonKeyName1) jsonKeyName1.value = custom1Obj.jsonKeyName || '';
        if (jsonKeyValue1) jsonKeyValue1.value = custom1Obj.jsonKeyValue || '';

        // Custom Field 2
        if (enableCF2) {
            enableCF2.checked = Number(custom2Obj.enableCustomField2 || 0) === 1;
        }
        if (jsonKeyName2) jsonKeyName2.value = custom2Obj.jsonKeyName || '';
        if (jsonKeyValue2) jsonKeyValue2.value = custom2Obj.jsonKeyValue || '';

        // Custom Field 3
        if (enableCF3) {
            enableCF3.checked = Number(custom3Obj.enableCustomField3 || 0) === 1;
        }
        if (jsonKeyName3) jsonKeyName3.value = custom3Obj.jsonKeyName || '';
        if (jsonKeyValue3) jsonKeyValue3.value = custom3Obj.jsonKeyValue || '';

        // Finally, update Topic visibility
        if (typeof this.updateCloudTopicVisibility === 'function') {
            this.updateCloudTopicVisibility();
        }
    },

    // fetchCloudConfigAPI: async function (deviceName) {
    //     let params = window.location.href;
    //     let BaseURL = new URL(params).origin;
    //     try {
    //         const res = await fetch(`${BaseURL}:30006/Modbus_Cloud_Configuration/${deviceName}`);
    //         // const res = await fetch(endpoint);
    //         if (!res.ok) {
    //             console.error(`Cloud config fetch failed (status ${res.status})`);
    //             return null;
    //         }

    //         const data = await res.json();
    //         let cfg = null;

    //         if (Array.isArray(data)) {
    //             cfg = data.find(d =>
    //                 d.deviceName === deviceName ||
    //                 d.devicename === deviceName
    //             ) || null;
    //         } else {
    //             if ((data.deviceName || data.devicename) === deviceName) {
    //                 cfg = data;
    //             }
    //         }

    //         if (!cfg) {
    //             console.warn('No Cloud config found for device:', deviceName);
    //             return null;
    //         }
    //         return cfg;

    //     } catch (err) {
    //         console.error('Error fetching Cloud Config:', err);
    //         return null;
    //     }
    // },

    updateCloudTopicVisibility: function () {
        const methodSelect = document.getElementById('dataSendingMethod');
        const topic1Row = document.getElementById('topicNameField');
        const topic2Row = document.getElementById('topicNameTwoField');

        if (!methodSelect || !topic1Row || !topic2Row) {
            console.warn('Cloud config elements not found');
            return;
        }

        const value = methodSelect.value; // "1", "2", "3"

        // Hide all first
        topic1Row.style.display = 'none';
        topic2Row.style.display = 'none';

        if (value === '1') {
            // Primary → show Topic Name
            topic1Row.style.display = 'flex';   // or 'block' depending on your layout
        } else if (value === '2') {
            // Secondary → show Topic Name 2
            topic2Row.style.display = 'flex';
        } else if (value === '3') {
            // Both → show both
            topic1Row.style.display = 'flex';
            topic2Row.style.display = 'flex';
        }
    },

    addDeviceDataToTable: function (parameterPayload, isUpdate = false) {
        const self = this;
        const table = document.getElementById('DeviceConfigTable');            // table id you added
        let tableHeader = table.querySelector('thead');
        let tableBody = table.querySelector('tbody');
        const tableContainer = document.querySelector('.table-container');     // same container class as SNMP

        // Create header/body if missing
        if (!tableHeader) {
            tableHeader = document.createElement('thead');
            table.appendChild(tableHeader);
        }
        if (!tableBody) {
            tableBody = document.createElement('tbody');
            table.appendChild(tableBody);
        }

        // Ensure headers are present
        if (tableHeader.rows.length === 0) {
            const headerRow = document.createElement('tr');
            headerRow.innerHTML = `
            <th>Sl No</th>
            <th>Device Name</th>
            <th>Slave ID</th>
            <th>No.of Blocks</th>
            <th>No.of Register</th>
            <th>No.of Alarm/Event</th>
            <th>Update</th>
        `;
            tableHeader.appendChild(headerRow);
        }

        // if update: find row and update the cells
        if (isUpdate) {
            const rows = tableBody.querySelectorAll('tr');
            rows.forEach(row => {
                const existingDeviceName = row.cells[1]?.textContent.trim();
                if (existingDeviceName === parameterPayload.deviceName) {
                    // update slave id and counts
                    row.cells[2].textContent = parameterPayload.slaveAddress ?? parameterPayload.slaveaddress ?? parameterPayload.slaveID ?? '';
                    row.cells[3].textContent = parameterPayload.blockLength ?? parameterPayload.numberOfBlocks ?? 0;
                    row.cells[4].textContent = parameterPayload.registerLength ?? parameterPayload.numberOfRegisters ?? 0;
                    row.cells[5].textContent = parameterPayload.alarmLength ?? parameterPayload.numberOfAlarms ?? 0;
                }
            });
            return; // don't add a new row
        }

        // Create new row for a new device
        const newRow = document.createElement('tr');
        // compute sl no
        const snid = tableBody.getElementsByTagName('tr').length + 1;

        const slaveId = parameterPayload.slaveAddress ?? parameterPayload.slaveaddress ?? parameterPayload.slaveID ?? '';
        const blockCount = parameterPayload.blockLength ?? parameterPayload.numberOfBlocks ?? 0;
        const registerCount = parameterPayload.registerLength ?? parameterPayload.numberOfRegisters ?? 0;
        const alarmCount = parameterPayload.alarmLength ?? parameterPayload.numberOfAlarms ?? 0;

        newRow.innerHTML = `
        <td>${snid}</td>
        <td>${parameterPayload.deviceName}</td>
        <td>${slaveId}</td>
        <td>${blockCount}</td>
        <td>${registerCount}</td>
        <td>${alarmCount}</td>
        <td class="action-buttons">
            <button class="btn btn-sm btn-primary editBtn">Edit</button>
            <button class="btn btn-sm btn-danger deleteBtn">Delete</button>
        </td>
    `;
        if (tableContainer) tableContainer.style.display = 'block';

        tableBody.appendChild(newRow);
        newRow.querySelector('.editBtn').addEventListener('click', function () {
            // open modal and load data for editing
            if (typeof self.editDevice === 'function') {
                self.editDevice(parameterPayload.deviceName);
            } else {
                console.warn('editDevice function not found. Implement editDevice(deviceName) to fetch and populate modal.');
                // fallback: store device name and open modal (you should implement editDevice)
                localStorage.setItem('selectedDeviceName', parameterPayload.deviceName);
                $('#Modbus-Model').modal('show');
                $('#Modbus_Submit').attr('name', 'UpdateModbus');
            }
        });

        newRow.querySelector('.deleteBtn').addEventListener('click', function (ev) {
            ev.preventDefault();

            const deviceName = newRow.cells[1]?.textContent?.trim();
            if (!deviceName) {
                console.error("Error: Device name is missing or undefined.");
                return;
            }

            L.ui.confirmDelete(ev, async function (res) {
                if (!res) return;

                const portInput = document.getElementById('serialport1');
                const portNumber = portInput ? (portInput.value || '1') : '1';

                if (document.getElementById("loadingOverlay")) {
                    document.getElementById("loadingOverlay").style.display = "flex";
                }

                try {
                    // Call delete API
                    if (typeof self.sendDeleteDeviceAPI === 'function') {
                        await self.sendDeleteDeviceAPI(deviceName, portNumber);
                    } else {
                        console.warn('sendDeleteDeviceAPI not implemented; skipping server delete.');
                    }

                    // Success alert
                    L.ui.showAlert(
                        "success",
                        "Deleted",
                        `Device "${deviceName}" deleted successfully!`
                    );

                    // Remove row
                    tableBody.removeChild(newRow);

                    // Reindex Sl No
                    let index = 1;
                    tableBody.querySelectorAll('tr').forEach(row => {
                        row.cells[0].textContent = index++;
                    });

                    // Hide table if empty
                    if (tableBody.children.length === 0) {
                        tableHeader.innerHTML = '';
                        if (tableContainer) tableContainer.style.display = 'none';
                    }

                    // Optional refresh
                    setTimeout(() => location.reload(), 1200);

                } catch (error) {
                    console.error('Failed to delete device:', error);
                    L.ui.showAlert(
                        "error",
                        "Failed",
                        `Failed to delete device "${deviceName}".`
                    );
                } finally {
                    if (document.getElementById("loadingOverlay")) {
                        document.getElementById("loadingOverlay").style.display = "none";
                    }
                    if (typeof self.toggleSendConfigTabVisibility === 'function') {
                        self.toggleSendConfigTabVisibility();
                    }
                }
            });
        });

        // replicate SNMP behavior (toggle visibility / other UI)
        if (typeof self.toggleSendConfigTabVisibility === 'function') self.toggleSendConfigTabVisibility();
    },

    fetchDeviceConfigList: function () {
        const self = this;
        const params = window.location.href;
        const BaseURL = new URL(params).origin;
        fetch(`${BaseURL}:30006/Table_Configuration/`)
            //fetch(endpoint)
            .then(res => {
                if (!res.ok) throw new Error(`Fetch failed (status ${res.status})`);
                return res.json();
            })
            .then(data => {
                // Normalize to array
                const deviceArray = Array.isArray(data) ? data : (data && data.devices ? data.devices : []);
                const tableContainer = document.querySelector('.table-container');
                const table = document.getElementById('DeviceConfigTable');
                if (!deviceArray.length) {
                    if (tableContainer) tableContainer.style.display = 'none';
                    if (table) {
                        const thead = table.querySelector('thead');
                        const tbody = table.querySelector('tbody');
                        if (thead) thead.innerHTML = '';
                        if (tbody) tbody.innerHTML = '';
                    }
                    return;
                }

                if (tableContainer) tableContainer.style.display = 'block';

                deviceArray.forEach(device => {
                    const parameterPayload = {
                        deviceName: device.deviceName || device.devicename || '',
                        // map SlaveID -> slaveAddress (string or number)
                        slaveAddress: device.SlaveID ?? device.slaveID ?? device.slaveAddress ?? '',
                        // map NoofBlock -> blockLength
                        blockLength: Number(device.NoofBlock ?? 0),
                        registerLength: Number(device.NoofRegister ?? 0),
                        alarmLength: Number(device.NoofAlarm ?? 0),

                        portNumber: Number(device.portNumber ?? device.PortNumber ?? 0)
                    };

                    try {
                        self.addDeviceDataToTable(parameterPayload, false);
                    } catch (err) {
                        console.error('Error adding device to table:', err, parameterPayload);
                    }
                });
            })
            .catch(err => {
                console.error('Error fetching device config list:', err);
                L.ui.showAlert("error", "Error", "Failed to load devices.");
            });
    },

    // SEND CONFIGURATUION

    addSendConfigRow: function () {
        const self = this; // Capture correct context

        const fieldContent = document.getElementById('deviceFieldContentDropdown').value;
        const jsonKey = document.getElementById('deviceFieldJsonKey').value.trim();
        const value = document.getElementById('fieldJsonKeyValue')?.value.trim() || '';
        const tableBody = document.querySelector('#deviceSendConfigTable tbody');
        const tableContainer = document.getElementById('deviceSendConfigTableContainer');

        if (!fieldContent || !jsonKey) {
            L.ui.showAlert("error", "No value selected", "Please select a Field Content and enter a JSON Key Name.");
            return;
        }

        const row = document.createElement('tr');
        row.innerHTML = `
        <td></td>
        <td>${fieldContent}</td>
        <td>${jsonKey}</td>
        <td class="action-buttons">
            <button class="btn btn-primary btn-sm">Edit</button>
            <button class="btn btn-danger btn-sm">Delete</button>
        </td>
    `;

        row.querySelector('.btn-primary').addEventListener('click', () => {
            self.editingSendConfigRow = row;
            const field = row.cells[1].textContent;
            const jsonKey = row.cells[2].textContent;
            const value = row.getAttribute('data-json-key-value') || '';
            document.getElementById('deviceEditJsonKeyValue').value = '';

            document.getElementById('deviceEditFieldContent').value = field;
            document.getElementById('deviceEditFieldJsonKey').value = jsonKey;
            // document.getElementById('editJsonKeyValue').value = jsonKeyValue;

            const isCustom = field.startsWith('RS485Customfield');
            document.getElementById('deviceJsonKeyValueGroup').style.display = isCustom ? 'block' : 'none';
            // document.getElementById('editJsonKeyValue').value = jsonKeyValue;
            if (isCustom) {
                document.getElementById('deviceEditJsonKeyValue').value = value;
            }

            $('#deviceEditSendConfigModal').modal('show');
        });


        row.querySelector('.btn-danger').addEventListener('click', () => {
            row.remove();
            self.reindexSendConfigRows();

            // OPTIONAL: Hide table if empty
            if (tableBody.children.length === 0) {
                tableContainer.style.display = 'none';
            }
        });
        tableBody.appendChild(row);
        row.setAttribute('data-json-key-value', value);

        tableContainer.style.display = 'block';
        self.reindexSendConfigRows();

        // Clear inputs
        document.getElementById('deviceFieldContentDropdown').value = '';
        document.getElementById('deviceFieldJsonKey').value = '';
        document.getElementById('fieldJsonKeyValue').value = '';
        document.getElementById('jsonKeyValueGroupAdd').style.display = 'none';
    },

    reindexSendConfigRows: function () {
        const rows = document.querySelectorAll('#deviceSendConfigTable tbody tr');
        rows.forEach((row, index) => {
            row.cells[0].textContent = index + 1;
        });
        if (rows.length === 0) {
            document.getElementById('deviceSendConfigTableContainer').style.display = 'none';
        }
    },

    saveSendConfigChanges: function () {
        const fieldContent = document.getElementById('deviceEditFieldContent').value;
        const jsonKey = document.getElementById('deviceEditFieldJsonKey').value.trim();
        const value = document.getElementById('deviceEditJsonKeyValue').value.trim(); // new field

        if (!fieldContent || !jsonKey) {
            L.ui.showAlert("warning", "Empty fields", `Please fill both fields.`);
            return;
        }

        if (this.editingSendConfigRow) {
            this.editingSendConfigRow.cells[1].textContent = fieldContent;
            this.editingSendConfigRow.cells[2].textContent = jsonKey;
            // this.editingSendConfigRow.setAttribute('data-json-key-value', jsonKeyValue);

            const isCustomField = ['RS485Customfield1', 'RS485Customfield2', 'RS485Customfield3', 'RS485Customfield4', 'RS485Customfield5', 'RS485Customfield6', 'RS485Customfield7', 'RS485Customfield8', 'RS485Customfield9', 'RS485Customfield10'].includes(fieldContent);

            if (isCustomField) {
                this.editingSendConfigRow.setAttribute('data-json-key-value', value);
            } else {
                this.editingSendConfigRow.removeAttribute('data-json-key-value');
            }
        }

        $('#deviceEditSendConfigModal').modal('hide');
    },

    updateAllSendConfigs: function () {
        const self = this;
        let params = window.location.href;
        let BaseURL = new URL(params).origin;
        const tableRows = document.querySelectorAll('#deviceSendConfigTable tbody tr');

        if (tableRows.length === 0) {
            L.ui.showAlert("error", "Error", "No rows to update.");
            return;
        }

        const sendConfigs = [];

        tableRows.forEach(row => {
            const fieldContent = row.cells[1].textContent.trim();
            const jsonKey = row.cells[2].textContent.trim();
            const value = row.getAttribute('data-json-key-value') || '';

            if (fieldContent && jsonKey) {
                const config = { fieldContent, jsonKey };
                if (fieldContent.startsWith('RS485Customfield')) {
                    config.keyValue = value;
                }
                sendConfigs.push(config);
            }
        });

        // ? Ensure SNMPData is always last
        const snmpIndex = sendConfigs.findIndex(
            item => item.fieldContent.toLowerCase() === "snmpdata"
        );
        if (snmpIndex > -1) {
            const [snmpItem] = sendConfigs.splice(snmpIndex, 1);
            sendConfigs.push(snmpItem);
        }

        // ? Show loading overlay for Send Configuration
        document.getElementById("deviceSendConfigLoadingOverlay").style.display = "flex";

        fetch(`${BaseURL}:30005/POST_Selected_RS485_Configuration/`, {
            //fetch(`https://cors-anywhere.herokuapp.com/https://webhook.site/885711c7-8dd3-4c2e-8a2b-facbf4d9a18a`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(sendConfigs)
        })
            .then(response => {
                if (!response.ok) throw new Error("Network error");
                return response.text();
            })
            .then(responseText => {
                L.ui.showAlert("success", "Success", `Configuration updated successfully !`);
                setTimeout(() => {
                    location.reload();
                }, 1000);
            })
            .catch(error => {
                console.error("Send Config Update Failed:", error);
                L.ui.showAlert("error", "Error", "Failed to update send configurations");
            })
            .finally(() => {
                document.getElementById("deviceSendConfigLoadingOverlay").style.display = "none";
            });
    },

    disableDevicePage: function () {
        const wrapper = document.getElementById("deviceContentWrapper");
        const overlay = document.getElementById("deviceDisabledOverlay");

        if (wrapper) wrapper.classList.add("device-blurred");
        if (overlay) overlay.style.display = "flex";
    },

    enableDevicePage: function () {
        const wrapper = document.getElementById("deviceContentWrapper");
        const overlay = document.getElementById("deviceDisabledOverlay");

        if (wrapper) wrapper.classList.remove("device-blurred");
        if (overlay) overlay.style.display = "none";
    },

    checkDeviceApplicationState: function (retryCount) {
        const self = this;
        retryCount = retryCount || 0;
        const MAX_RETRIES = 3;
        const RETRY_DELAY_MS = 2000; // 2 seconds between retries

        let params = window.location.href;
        let BaseURL = new URL(params).origin;

        fetch(`${BaseURL}:30008/device/applications/`)
            .then(res => {
                if (!res.ok) throw new Error('Non-OK response: ' + res.status);
                return res.json();
            })
            .then(apps => {
                const deviceApp = apps.find(app => app.id === 'modbus');

                if (deviceApp && deviceApp.state === 'running') {
                    self.enableDevicePage();
                    self.loadDeviceUIAfterEnable();
                } else {
                    // API responded clearly: app is NOT running → disable page
                    self.disableDevicePage();
                }
            })
            .catch(err => {
                console.error('Execute API failed (attempt ' + (retryCount + 1) + '):', err);

                if (retryCount < MAX_RETRIES) {
                    // Retry after a delay instead of immediately disabling
                    setTimeout(function () {
                        self.checkDeviceApplicationState(retryCount + 1);
                    }, RETRY_DELAY_MS);
                } else {
                    // Only disable after all retries are exhausted
                    console.warn('Max retries reached. Disabling Modbus page.');
                    self.disableDevicePage();
                }
            });
    },
    bindModbusTiming: function () {
        const self = this;
        if (this._modbusTimingBound) return;
        this._modbusTimingBound = true;
        const periodicityInput = document.getElementById('deviceInput');
        const delayInput = document.getElementById('deviceDelay');

        if (!periodicityInput || !delayInput) return;

        // --- Periodicity ---
        periodicityInput.addEventListener('change', () => {
            const periodicity = parseInt(periodicityInput.value, 10);

            if (isNaN(periodicity) || periodicity < 5) {
                L.ui.showAlert("warning", "Value to Low", "Overall periodicity must be >= 5 seconds.");
                periodicityInput.value = 5;
                return;
            }

            self.postModbusTiming();
        });

        // --- Delay ---
        delayInput.addEventListener('change', () => {
            const delay = parseInt(delayInput.value, 10);

            if (isNaN(delay) || delay < 0) {
                L.ui.showAlert("warning", "Value to Low", "Delay must be 0 or greater.");
                delayInput.value = 0;
                return;
            }

            self.postModbusTiming();
        });
    },

    postModbusTiming: function () {
        const periodicity = parseInt(document.getElementById('deviceInput')?.value, 10);
        const delay = parseInt(document.getElementById('deviceDelay')?.value, 10);

        if (isNaN(periodicity) || periodicity < 5) return;

        let BaseURL = new URL(window.location.href).origin;

        // Optional overlay (reuse if you have one)
        const overlay = document.getElementById("loadingOverlay");
        if (overlay) overlay.style.display = "flex";

        fetch(`${BaseURL}:30008/RS485Line1_Source_post/`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                EnableRS485Line1Periodicity: periodicity,
                Delay: delay || 0
            })
        })
            .then(response => {
                if (!response.ok) {
                    throw new Error("Failed to apply RS485 timing");
                }
                return response.text();
            })
            .then(() => {
                //  SUCCESS ALERT
                L.ui.showAlert(
                    "success",
                    "Applied",
                    "Configuration applied successfully"
                );
                setTimeout(() => {
                    location.reload();
                }, 1000);
            })
            .catch(err => {
                console.error(" RS485 Modbus timing save failed:", err);
                L.ui.showAlert(
                    "error",
                    "Failed",
                    "Failed to apply configuration"
                );
            })
            .finally(() => {
                if (overlay) overlay.style.display = "none";
            });
    },


    fetchModbusTiming: function () {
        const periodicityInput = document.getElementById('deviceInput');
        const delayInput = document.getElementById('deviceDelay');

        if (!periodicityInput || !delayInput) return;

        let BaseURL = new URL(window.location.href).origin;

        fetch(`${BaseURL}:30008/RS485Line1_Enable/`)
            .then(res => {
                if (!res.ok) throw new Error("GET failed");
                return res.json();
            })
            .then(data => {
                periodicityInput.value =
                    data.EnableRS485Line1Periodicity ?? 60;

                delayInput.value =
                    data.Delay ?? 0;
            })
            .catch(err => {
                console.error(" Failed to fetch Modbus timing:", err);
            });
    },

    // Paste inside your main JS object (App / DeviceConfig object)
    loadDeviceUIAfterEnable: function () {
        var self = this;
        // if (self._deviceUIInitialized) {
        //     return; 
        // }
        self._deviceUIInitialized = true;
        self.fetchDeviceConfigList();
        self.fetchModbusTiming();
        self.bindModbusTiming();
        self.catchingJSONData();


        showUpdateMessage = function () {
            let SlaveIDChanage = "Yes";
            localStorage.setItem("SlaveIDchanage", SlaveIDChanage)
            let messageShown = false;
            if (!messageShown) {
                $("#updateMessage").text(" If you Change Slave ID, Please Configure Slave Id and Resgisters in PsuedoResgister Section also ")
                    .fadeIn()
                    .delay(5000)
                    .fadeOut();
                messageShown = true;
            }
        }

        let params = window.location.href;
        let BaseURL = new URL(params).origin;

        fetch(`${BaseURL}:30005/RS485_Available_Configuration/`)
            .then(res => res.json())
            .then(data => {
                const dropdown = document.getElementById('deviceFieldContentDropdown');
                const editDropdown = document.getElementById('deviceEditFieldContent');

                dropdown.innerHTML = '<option value="">Select Field Content</option>';
                editDropdown.innerHTML = '<option value="">Select Field Content</option>';

                data.forEach(item => {
                    const option = document.createElement('option');
                    option.value = item.fieldContent;
                    option.textContent = item.fieldContent;
                    dropdown.appendChild(option);

                    // also add to edit modal
                    const editOption = option.cloneNode(true);
                    editDropdown.appendChild(editOption);
                });
            })
            .catch(err => console.error("Error loading dropdown values:", err));

        fetch(`${BaseURL}:30005/RS485_Selected_Configuration/`)
            .then(res => res.json())
            .then(data => {
                const tableBody = document.querySelector('#deviceSendConfigTable tbody');
                const tableContainer = document.getElementById('deviceSendConfigTableContainer');

                if (Array.isArray(data) && data.length > 0) {
                    tableContainer.style.display = 'block';
                    data.forEach((item, index) => {
                        const row = document.createElement('tr');
                        row.innerHTML = `
                        <td>${index + 1}</td>
                        <td>${item.fieldContent}</td>
                        <td>${item.jsonKey}</td>
                        <td class="action-buttons">
                            <button class="btn btn-primary btn-sm">Edit</button>
                            <button class="btn btn-danger btn-sm">Delete</button>
                        </td>
                    `;

                        row.setAttribute('data-json-key-value', item.keyValue || '');

                        // Set up event listeners
                        row.querySelector('.btn-primary').addEventListener('click', () => {
                            self.editingSendConfigRow = row;

                            const field = row.cells[1].textContent.trim();
                            const jsonKey = row.cells[2].textContent.trim();
                            const value = row.getAttribute('data-json-key-value') || '';

                            document.getElementById('deviceEditFieldContent').value = field;
                            document.getElementById('deviceEditFieldJsonKey').value = jsonKey;

                            const isCustom = field.startsWith('RS485Customfield');
                            document.getElementById('deviceJsonKeyValueGroup').style.display = isCustom ? 'block' : 'none';
                            document.getElementById('deviceEditJsonKeyValue').value = isCustom ? value : '';

                            $('#deviceEditSendConfigModal').modal('show');
                        });
                        row.querySelector('.btn-danger').addEventListener('click', () => {
                            row.remove();
                            this.reindexSendConfigRows();
                            if (tableBody.children.length === 0) {
                                tableContainer.style.display = 'none';
                            }
                        });

                        tableBody.appendChild(row);
                    });
                }
            })
            .catch(err => console.error("Error loading table values:", err));
        document.getElementById('addSendConfigRow').addEventListener('click', function () {
            self.addSendConfigRow();
        });

        document.getElementById('saveSendConfigChanges').addEventListener('click', function () {
            self.saveSendConfigChanges();
        });

        document.getElementById('deviceEditFieldContent').addEventListener('change', function () {
            const selected = this.value;
            const isCustom = selected.startsWith('RS485Customfield');
            document.getElementById('deviceJsonKeyValueGroup').style.display = isCustom ? 'block' : 'none';
            if (!isCustom) {
                document.getElementById('deviceEditJsonKeyValue').value = '';
            }
        });

        const updateBtn = document.getElementById('deviceUpdateAllSendConfigsBtn');
        if (updateBtn) {
            updateBtn.addEventListener('click', (e) => {
                e.preventDefault();
                self.updateAllSendConfigs();
            });
        }
        removeBlock = function (event) {
            var button = event.target;
            var blockRow = button.closest('.row');
            if (blockRow) {
                blockRow.remove();
                var blockIndex = button.id.split(',')[1];
                // alert("Register_index", blockIndex)
                var _delete_index = parseInt(button.id.split(',')[1], 10);
                var _delete_count = _delete_index + 1;
                L.ui.showAlert("success", "Success", `Block config ${_delete_count} is deleted`);
                for (var i = parseInt(blockIndex) + 1; i < self.CounterBlock; i++) {
                    // Update the ID of each element
                    $("#functionCode" + i).attr("id", "functionCode" + (i - 1));
                    $("#startRegister" + i).attr("id", "startRegister" + (i - 1));
                    $("#countRegister" + i).attr("id", "countRegister" + (i - 1));
                    $("#BlockremoveButton," + i).attr("id", "BlockremoveButton," + (i - 1)); // Corrected selector
                }
                self.CounterBlock--;
            }
        };

        // removeRegister = function (event) {
        //     var button = event.target;
        //     var RegisterRow = button.closest('.row');
        //     if (!RegisterRow) return;

        //     // Get the index before removing
        //     var deletedIndex = parseInt(button.id.split(',')[1], 10);
        //     var deletedNumber = deletedIndex + 1;

        //     // Just remove the row — NO re-indexing loop needed
        //     RegisterRow.remove();

        //     L.ui.showAlert("success", "Success", `Register Config ${deletedNumber} is deleted`);

        //     // Fix alarm map — only shift entries, no DOM touching
        //     if (self.registerAlarms) {
        //         var newMap = {};
        //         for (var j = 0; j < self.CounterRegister; j++) {
        //             if (j === deletedIndex || !self.registerAlarms[j]) continue;
        //             var newIndex = j > deletedIndex ? j - 1 : j;
        //             newMap[newIndex] = self.registerAlarms[j];
        //         }
        //         self.registerAlarms = newMap;
        //     }

        //     if (typeof currentAlarmRegisterIndex === 'number') {
        //         if (currentAlarmRegisterIndex === deletedIndex) {
        //             currentAlarmRegisterIndex = null;
        //         } else if (currentAlarmRegisterIndex > deletedIndex) {
        //             currentAlarmRegisterIndex--;
        //         }
        //     }

        //     self.CounterRegister--;
        // };

        // removeAlarm = function (event) {
        //     var button = event.target;
        //     var Register_row = button.closest('.row');
        //     if (Register_row) {
        //         Register_row.remove();
        //         var alarm_index = button.id.split(',')[1];
        //         var _delete_index = parseInt(button.id.split(',')[1], 10);
        //         var _delete_count = _delete_index + 1;
        //         L.ui.showAlert("success", "Success", `Alarm/Event Config ${_delete_count} is deleted`);
        //         for (var i = parseInt(alarm_index) + 1; i < self.CounterAlarm; i++) {
        //             // Update the ID of each element
        //             $("#Category" + i).attr("id", "Category" + (i - 1));
        //             $("#alarmEnabled" + i).attr("id", "alarmEnabled" + (i - 1));
        //             $("#alarmName" + i).attr("id", "alarmName" + (i - 1));
        //             $("#Code" + i).attr("id", "Code" + (i - 1));
        //             $("#regAlarm" + i).attr("id", "regAlarm" + (i - 1));
        //             $("#alarmCount" + i).attr("id", "alarmCount" + (i - 1));
        //             $("#alarmDatatype" + i).attr("id", "alarmDatatype" + (i - 1));
        //             $("#uprThreshold" + i).attr("id", "uprThreshold" + (i - 1));
        //             $("#uprHysteresis" + i).attr("id", "uprHysteresis" + (i - 1));
        //             $("#lowerThreshold" + i).attr("id", "lowerThreshold" + (i - 1));
        //             $("#lowerHysteresis" + i).attr("id", "lowerHysteresis" + (i - 1));
        //             $("#AlarmremoveButton," + i).attr("id", "AlarmremoveButton," + (i - 1)); // Corrected selector


        //         }
        //         self.CounterAlarm--;
        //     }
        // };
        removeRegister = function (event) {
            var button = event.target;

            // Walk up to find the direct child of Registersection (the wrapper)
            // This avoids closest('.row') accidentally matching outer Bootstrap rows
            var registersection = document.getElementById('Registersection');
            if (!registersection) return;

            // Find which direct child of Registersection contains this button
            var wrapper = button.parentNode;
            while (wrapper && wrapper.parentNode !== registersection) {
                wrapper = wrapper.parentNode;
            }

            if (!wrapper) return;

            var deletedIndex = parseInt(button.id.split(',')[1], 10);
            var deletedNumber = deletedIndex + 1;

            // Remove the correct wrapper — exactly one row, nothing more
            wrapper.remove();

            L.ui.showAlert("success", "Success", `Register Config ${deletedNumber} is deleted`);

            // Fix alarm map — shift entries down
            if (self.registerAlarms) {
                var newMap = {};
                for (var j = 0; j < self.CounterRegister; j++) {
                    if (j === deletedIndex || !self.registerAlarms[j]) continue;
                    var newIndex = j > deletedIndex ? j - 1 : j;
                    newMap[newIndex] = self.registerAlarms[j];
                }
                self.registerAlarms = newMap;
            }

            if (typeof currentAlarmRegisterIndex === 'number') {
                if (currentAlarmRegisterIndex === deletedIndex) {
                    currentAlarmRegisterIndex = null;
                } else if (currentAlarmRegisterIndex > deletedIndex) {
                    currentAlarmRegisterIndex--;
                }
            }

            for (var i = deletedIndex + 1; i < self.CounterRegister; i++) {
                $("#registername" + i).attr("id", "registername" + (i - 1));
                $("#startregister" + i).attr("id", "startregister" + (i - 1));
                $("#registercount" + i).attr("id", "registercount" + (i - 1));
                $("#Datatype" + i).attr("id", "Datatype" + (i - 1));
                $("#multifactor" + i).attr("id", "multifactor" + (i - 1));
                $("#enableAlarm" + i).attr("id", "enableAlarm" + (i - 1));
                $("#addAlarmBtn" + i).attr("id", "addAlarmBtn" + (i - 1));
                $("#RegisterremoveButton," + i).attr("id", "RegisterremoveButton," + (i - 1));
            }
            self.CounterRegister--;
        };

        // 1 Attach change listener once DOM is ready
        const methodSelect = document.getElementById('dataSendingMethod');
        if (methodSelect) {
            methodSelect.addEventListener('change', function () {
                self.updateCloudTopicVisibility();
            });
        }
        const pseudoDsmSelect = document.getElementById('pseudoDataSendingMethod');
        if (pseudoDsmSelect) {
            // on change
            pseudoDsmSelect.addEventListener('change', () => {
                self.updatePseudoCloudTopicVisibility();
            });

            // initial (default) state when page loads / modal opens
            self.updatePseudoCloudTopicVisibility();
        }

        //  When the Modbus modal is opened, refresh visibility
        $('#Modbus-Model').off('shown.bs.modal.cloud').on('shown.bs.modal.cloud', function () {
            self.updateCloudTopicVisibility();
        });
        removePseudoRegister = function (event) {
            var button = event.target;
            var RegisterRow1 = button.closest('.row');
            if (RegisterRow1) {
                RegisterRow1.remove();
                var Pseudo_Register_index = button.id.split(',')[1];
                var _delete_index = parseInt(button.id.split(',')[1], 10);
                var _delete_count = _delete_index + 1;
                alert(`Pseudo Register config  ${_delete_count} is deleted`);
                L.ui.showAlert("success", "Success", `Pseudo Register config  ${_delete_count} is deleted`);
                for (var i = parseInt(Pseudo_Register_index) + 1; i < self.PseudoRegisterCounter; i++) {
                    // Update the ID of each element
                    $("#pseudoRegisterName" + i).attr("id", "pseudoRegisterName" + (i - 1));
                    $("#SlaveId" + i).attr("id", "SlaveId" + (i - 1));
                    $("#pseudoSlaveRegister" + i).attr("id", "pseudoSlaveRegister" + (i - 1));
                    $("#pseudoRemoveButton," + i).attr("id", "pseudoRemoveButton," + (i - 1)); // Corrected selector


                }
                self.PseudoRegisterCounter--;
            }
        };

        $("#AddNewModbus").off('click').on('click', function () {
            // document.getElementById("Blockregistersection").innerHTML = " "
            // document.getElementById("Registersection").innerHTML = " "
            // document.getElementById("Alarm_Event_section").innerHTML = " "
            // AFTER
            const _blockSec = document.getElementById("Blockregistersection");
            const _regSec = document.getElementById("Registersection");
            const _alarmSec = document.getElementById("Alarm_Event_section");

            if (_blockSec) _blockSec.innerHTML = '';
            if (_regSec) _regSec.innerHTML = '';
            if (_alarmSec) _alarmSec.innerHTML = '';
            self.CounterRegister = 0;
            self.CounterBlock = 0;
            self.CounterAlarm = 0;
            self.registerAlarms = {};
            $('#devicename').prop('disabled', false);
            $("#modbusserialconfig").css("display", "block");
            $(".modusregister").css("display", "block");
            $("#AddNewEvent").val("Add Device");
            $('#devicename').val("");
            $('#serialslaveid').val("");
            $('#serialport1').val("");
            $('#serialbaudrate').val("");
            $('#serialparity').val("");
            $('#protocol').val("");
            $('#CommIp').val("");
            $('#CommPort').val("");
            $('#metermodel').val("");
            $('#commT').val("");
            $('#equipmentid').val("");
            $('#optiondevice').val("");
            $('#modelname').val("");
            $('#serialstopbit').val("");
            $('#tagNameInput').val("");
            $('#TagDatatype').val("");
            $('#serialdatabits').val("");
            $('#Modbus-ModelLabel')
                .attr('name', 'add_modbus')
                .text('Add Modbus Configuration');
            $('#Modbus_Submit')
                .attr('name', 'submit')
                .removeClass()
                .addClass('btn btn-primary') // Change the name attribute
                .text('Submit');
            $('#stdModbusEnable').val("")
            $('#topicname').val("")
            $('#topicnametwo').val("")
            $('#jsonHeaderKeyName').val('');
            $('#jsonKeyName1').val('');
            $('#jsonKeyValue1').val('');
            $('#jsonKeyName2').val('');
            $('#jsonKeyValue2').val('');
            $('#jsonKeyName3').val('');
            $('#jsonKeyValue3').val('');
            $('#dataSendingMethod').val('');
            $('#enableJsonHeaderKey').prop('checked', false);
            $('#enableCustomField1').prop('checked', false);
            $('#enableCustomField2').prop('checked', false);
            $('#enableCustomField3').prop('checked', false);
            $("#TextBoxesGroup").css("display", "block")
            $("#jsoninfo").val("")
            $("#jsoninfo").css("display", "none")
            self.changemodbusprotocol()
        })


        $("#AddNewPseudo").off('click').on('click', function () {
            self.PseudoRegisterCounter = 0;
            $('#Pseudo-ModelLabel')
                .attr('name', 'Add_pseudo')
                .text('Add Pseudo Configuration');
            $('#Pseudo_Submit')
                .attr('name', 'submit')
                .removeClass()
                .addClass('btn btn-primary')
                .text('Submit');

            document.getElementById("PseudoRegisterSection").innerHTML = " "

            $('#pseudoDeviceName').prop('disabled', false);
            $('#pseudoDeviceName').val("")
            $('#pseudoSlaveID').val("")
            $('#pseudoSlaveDataStatus').val("")
            $('#pseudoSlaveCloudStatus').val("")
            $('#pseudoDataSendingMethod').val("")
            $('#pseudoTopicName').val("")
            $('#pseudoTopicNameTwo').val("")
            $('#pseudoJsonHeaderKeyStatus').val("").prop('checked', false);
            $('#pseudoJsonHeaderKeyName').val("")
            $('#pseudoCustomFieldStatus1').val("").prop('checked', false);
            $('#pseudoJsonKeyName1').val("")
            $('#pseudoJsonKeyValue1').val("")
            $('#pseudoJsonKeyName2').val("")
            $('#pseudoJsonKeyValue2').val("")
            $('#pseudoCustomFieldStatus2').val("").prop('checked', false);
            $('#pseudoCustomFieldStatus3').val("").prop('checked', false);
            $('#pseudoJsonKeyName3').val("")
            $('#pseudoJsonKeyValue3').val("")
            $("#PseudoTextBoxesGroup").css("display", "block")
            self.PseudoModbusDropdowns();
        })


        var arr = [];
        var arrTwo = [];
        var arrThree = [];
        var Parr = [];
        $('#Pseudo_Submit').off('click').on('click', function () {

            const buttonName = $(this).attr('name');

            if (buttonName === 'UpdatedSubmit') {
                var _old_count = parseInt(localStorage.getItem("_previous_count"), 10);
                var SlaveID_Changed = localStorage.getItem('SlaveIDchanage')
                var _new_count = self.PseudoRegisterCounter;

                if (!isNaN(_old_count) && !isNaN(_new_count)) {
                    if ((_old_count - _new_count > 0) || (_old_count - _new_count < 0) || (SlaveID_Changed === "Yes")) {

                        self.deletedatabase('configure').then(function (rv) {
                            alert("You will lose the old data, and it will be updated with the latest edited data.");
                            localStorage.removeItem('SlaveIDchanage');

                        });
                    }
                }
            }

            Parr = [];
            for (var i = 0; i < self.PseudoRegisterCounter; i++) {
                Parr.push({
                    "pseudoRegisterName": $('#pseudoRegisterName' + i).val(),
                    "SlaveId": $('#SlaveId' + i).val(),
                    "pseudoSlaveRegister": $('#pseudoSlaveRegister' + i).val(),
                })
            }

            var formData = {};
            var isEmptyField;
            $('.inputbox:visible').each(function () {
                var fieldName = $(this).attr('name');
                var fieldValue = $(this).val().trim();

                // Check if the field value is empty
                if (fieldValue === '') {
                    L.ui.showAlert("error", "Error", "Please fill in " + fieldName);
                    isEmptyField = true;
                    return false; // Exit the loop if any field is empty
                }
                isEmptyField = $('.inputbox:visible').filter(function () {
                    return $(this).val().trim() === '';
                }).length > 0;
            });
            if (!isEmptyField) {
                self.PseudoSectionAdd();
                self.PseudoModbusDropdowns();
            }
        });

        var jsondata = [];
        var Request_data = {};
        let isJsonVisible = false;
        var checkbox2 = document.getElementById("addJButton");

        showJson = function () {
            const jsonBox = document.getElementById('jsoninfo');
            if (!jsonBox) return;

            //  If it is currently visible → hide and clear
            if (isJsonVisible) {
                jsonBox.style.display = 'none';
                jsonBox.value = '';
                isJsonVisible = false;
                return;
            }

            //  Rebuild JSON from current register rows
            Request_data = {};

            // Find all register name inputs like registername0, registername1, ...
            const nameInputs = document.querySelectorAll('input[id^="registername"]');

            nameInputs.forEach(input => {
                const id = input.id;             // e.g. "registername0"
                const index = id.replace('registername', '');
                const registerName = input.value.trim();
                if (!registerName) return;

                const dataTypeEl = document.getElementById('Datatype' + index);
                const dataTypeValue = dataTypeEl ? dataTypeEl.value : "";
                let packedValue;

                if (dataTypeValue === "0") {
                    packedValue = "AF";
                } else if (dataTypeValue === "1" || dataTypeValue === "2") {
                    packedValue = 255.14;
                } else if (dataTypeValue === "11") {
                    packedValue = 1;
                } else {
                    packedValue = 120;
                }

                Request_data[registerName] = packedValue;
            });

            //  Show JSON in textarea
            jsonBox.style.display = 'block';
            jsonBox.value = JSON.stringify(Request_data, null, 2);
            isJsonVisible = true;
        };




        toggleParity = function () {
            self.changemodbusprotocol();

        }


        $('#AddBlock-btn').off('click').on('click', function () {
            self.AddBlockSection()

        });

        $('#AddRegister-btn').off('click').on('click', function () {
            self.AddRegisterSection();
        });
        // $('#AddAlarm-btn').click(function () {
        //     self.AddAlarmSection()
        // });
        $('#AddPsedoRegister-btn').off('click').on('click', function () {
            self.AddPseudoRegistersection()
            self.PseudoModbusDropdowns()
        });


        registerdata = function () {
            return arr;
        }
        blockdata = function () {
            return arrTwo;
        }
        alarmdata = function () {
            return arrThree;
        }
        pseudoRegisterData = function () {
            return Parr;
        }

    },

    handleModbusExcelRows: function (rows) {
        const self = this;

        // REMOVE EMPTY EXCEL ROWS
        rows = rows.filter(row =>
            row.registerName && String(row.registerName).trim() !== ""
        );

        const registerList = [];
        const alarmList = [];

        rows.forEach(row => {
            registerList.push({
                registername: row.registerName,
                startregister: row.startRegister,
                registercount: row.registerCount,
                Datatype: row.dataType,
                multifactor: row.multiFactor,
                enableAlarm: row.enableAlarm ? 1 : 0
            });

            if (String(row.enableAlarm) === "1") {
                alarmList.push({
                    registerName: row.registerName,
                    category: row.category || 1,
                    status: row.status || 1,
                    alarmName: row.alarmName,
                    upperThreshold: row.upperThreshold,
                    lowerThreshold: row.lowerThreshold,
                    upperHysteresis: row.upperHysteresis,
                    lowerHysteresis: row.lowerHysteresis,
                    alarmDatatype: row.dataType
                });
            }
        });

        self.editrows(registerList);
        // self.Alarmeditrows(alarmList);
        self.Alarmeditrows(alarmList, registerList);

        L.ui.showAlert(
            "success",
            "Excel Upload",
            `${rows.length} registers imported`
        );
    },

    getCurrentRegisterRows: function () {
        const rows = [];

        // Find all register name inputs dynamically
        const registerNameInputs = document.querySelectorAll(
            'input[id^="registername"]'
        );

        registerNameInputs.forEach(input => {
            const index = input.id.replace("registername", "");
            if (!input.value.trim()) return;

            rows.push({
                registerName: input.value.trim(),
                startRegister: document.getElementById(`startregister${index}`)?.value || "",
                registerCount: document.getElementById(`registercount${index}`)?.value || "",
                dataType: document.getElementById(`Datatype${index}`)?.value || "",
                multiFactor: document.getElementById(`multifactor${index}`)?.value || "",
                enableAlarm: document.getElementById(`enableAlarm${index}`)?.checked ? 1 : 0
            });
        });

        return rows;
    },


    getCurrentAlarmRows: function () {
        return this.registerAlarms || {};
    },

    buildExcelRows: function () {
        const registers = this.getCurrentRegisterRows();
        const alarms = this.getCurrentAlarmRows();

        return registers.map((reg, index) => {
            const alarm = alarms[index] || {};

            return {
                registerName: reg.registerName,
                startRegister: reg.startRegister,
                registerCount: reg.registerCount,
                dataType: reg.dataType,
                multiFactor: reg.multiFactor,
                enableAlarm: reg.enableAlarm,
                alarmName: alarm.name || "",
                category: alarm.category || "",
                status: alarm.status || "",
                upperThreshold: alarm.upperThreshold || "",
                lowerThreshold: alarm.lowerThreshold || "",
                upperHysteresis: alarm.upperHysteresis || "",
                lowerHysteresis: alarm.lowerHysteresis || ""
            };
        });
    },


    execute: function () {
        const self = this;
        self.checkDeviceApplicationState();

        document.getElementById("modbusExcelUpload").addEventListener("change", function (e) {
            const file = e.target.files[0];
            if (!file) return;

            const reader = new FileReader();
            reader.onload = function (evt) {
                const data = new Uint8Array(evt.target.result);
                const workbook = XLSX.read(data, { type: "array" });
                const sheet = workbook.Sheets[workbook.SheetNames[0]];
                const rows = XLSX.utils.sheet_to_json(sheet);

                self.handleModbusExcelRows(rows);
            };
            reader.readAsArrayBuffer(file);
        });

        document.getElementById("downloadSampleExcel").addEventListener("click", function () {

            // Sample rows (exact keys your code expects)
            const sampleData = [
                {
                    registerName: "Voltage_L1",
                    startRegister: 40001,
                    registerCount: 2,
                    dataType: 1,
                    multiFactor: 0.1,
                    enableAlarm: 1,
                    alarmName: "High Voltage",
                    category: 1,
                    status: 1,
                    upperThreshold: 260,
                    lowerThreshold: 180,
                    upperHysteresis: 5,
                    lowerHysteresis: 5
                },
                {
                    registerName: "Current_L1",
                    startRegister: 40003,
                    registerCount: 2,
                    dataType: 1,
                    multiFactor: 0.01,
                    enableAlarm: 1,
                    alarmName: "Over Current",
                    category: 1,
                    status: 1,
                    upperThreshold: 50,
                    lowerThreshold: 5,
                    upperHysteresis: 2,
                    lowerHysteresis: 2
                },
                {
                    registerName: "Breaker_Status",
                    startRegister: 40005,
                    registerCount: 1,
                    dataType: 22,
                    multiFactor: "",
                    enableAlarm: 0
                },
                {
                    registerName: "Energy_Total",
                    startRegister: 40010,
                    registerCount: 2,
                    dataType: 7,
                    multiFactor: 1,
                    enableAlarm: 0
                }
            ];

            // Create worksheet
            const worksheet = XLSX.utils.json_to_sheet(sampleData);

            // Create workbook
            const workbook = XLSX.utils.book_new();
            XLSX.utils.book_append_sheet(workbook, worksheet, "Register_Config");

            // Download
            XLSX.writeFile(workbook, "Modbus_Register_Sample.xlsx");
        });

        document.getElementById("downloadCurrentExcel").addEventListener("click", function () {

            const excelData = self.buildExcelRows();

            if (!excelData.length) {
                L.ui.showAlert("warning", "No Data", "No register rows available to download");
                return;
            }

            const worksheet = XLSX.utils.json_to_sheet(excelData);
            const workbook = XLSX.utils.book_new();
            XLSX.utils.book_append_sheet(workbook, worksheet, "Register_Config");

            XLSX.writeFile(workbook, "Modbus_Register_Current.xlsx");
        });

        // openAlarmConfigForRegister = function (index) {
        //     currentAlarmRegisterIndex = index;

        //     // A. Fill Register Name in modal from that row
        //     var regInput = document.getElementById('registername' + index);
        //     var regName = regInput ? (regInput.value || '').trim() : '';
        //     var regNameModal = document.getElementById('alarmRegisterNameModal');
        //     if (regNameModal) {
        //         regNameModal.value = regName;
        //     }

        //     var dt = getRegisterDatatype(index);
        //     if (!dt) {
        //         L.ui.showAlert("warning", "No Datatype selected", 'Please select Datatype for this register before configuring alarm.');
        //         return;
        //     }

        //     var existing = self.registerAlarms[index];
        //     if (existing) {
        //         document.getElementById('RegisterAlarmModalLabel').textContent = 'Edit';
        //         document.getElementById('alarmCategoryModal').value = existing.category || '1';
        //         document.getElementById('alarmStatusModal').value = existing.status || '1';
        //         document.getElementById('alarmNameModal').value = existing.name || '';

        //         document.getElementById('alarmUpperThresholdModal').value = existing.upperThreshold || '';
        //         document.getElementById('alarmUpperHysModal').value = existing.upperHysteresis || '';
        //         document.getElementById('alarmLowerThresholdModal').value = existing.lowerThreshold || '';
        //         document.getElementById('alarmLowerHysModal').value = existing.lowerHysteresis || '';
        //     } else {
        //         document.getElementById('RegisterAlarmModalLabel').textContent = 'Add Alarm';
        //         document.getElementById('alarmCategoryModal').value = '1';
        //         document.getElementById('alarmStatusModal').value = '1';
        //         document.getElementById('alarmNameModal').value = '';

        //         document.getElementById('alarmUpperThresholdModal').value = '';
        //         document.getElementById('alarmUpperHysModal').value = '';
        //         document.getElementById('alarmLowerThresholdModal').value = '';
        //         document.getElementById('alarmLowerHysModal').value = '';
        //     }

        //     updateAlarmModalVisibility(dt);

        //     $('#RegisterAlarmModal').modal('show');
        // }
        openAlarmConfigForRegister = function (index) {
            currentAlarmRegisterIndex = index;

            // Always clear all fields first — prevents ANY stale data from previous opens
            document.getElementById('RegisterAlarmModalLabel').textContent = 'Add Alarm';
            document.getElementById('alarmCategoryModal').value = '1';
            document.getElementById('alarmStatusModal').value = '1';
            document.getElementById('alarmNameModal').value = '';
            document.getElementById('alarmUpperThresholdModal').value = '';
            document.getElementById('alarmUpperHysModal').value = '';
            document.getElementById('alarmLowerThresholdModal').value = '';
            document.getElementById('alarmLowerHysModal').value = '';

            // Fill Register Name
            var regInput = document.getElementById('registername' + index);
            var regName = regInput ? (regInput.value || '').trim() : '';
            var regNameModal = document.getElementById('alarmRegisterNameModal');
            if (regNameModal) regNameModal.value = regName;

            var dt = getRegisterDatatype(index);
            if (!dt) {
                L.ui.showAlert("warning", "No Datatype selected", 'Please select Datatype for this register before configuring alarm.');
                return;
            }

            // Now fill with existing alarm data if present
            var existing = self.registerAlarms[index];
            if (existing) {
                document.getElementById('RegisterAlarmModalLabel').textContent = 'Edit';
                document.getElementById('alarmCategoryModal').value = existing.category ?? '1';
                document.getElementById('alarmStatusModal').value = existing.status ?? '1';
                document.getElementById('alarmNameModal').value = existing.name ?? '';

                // Use ?? instead of || so that 0 is treated as a valid value, not falsy
                document.getElementById('alarmUpperThresholdModal').value = existing.upperThreshold ?? '';
                document.getElementById('alarmUpperHysModal').value = existing.upperHysteresis ?? '';
                document.getElementById('alarmLowerThresholdModal').value = existing.lowerThreshold ?? '';
                document.getElementById('alarmLowerHysModal').value = existing.lowerHysteresis ?? '';
            }

            updateAlarmModalVisibility(dt);
            $('#RegisterAlarmModal').modal('show');
        }
        handleFunctionBlockConfig = function (index) {
            //  If called without index (from stdModbusEnable change), just exit safely
            if (typeof index === 'undefined') {
                return;
            }

            // Get current protocol (RTU / TCP)
            const modeType = document.getElementById("protocol")?.value || "RTU";

            // Get Standard Modbus Address Translation value
            let translation = "0";
            if (modeType === "TCP") {
                const sel = document.getElementById('stdModbusEnable1');
                if (sel) translation = sel.value;
            } else {
                const sel = document.getElementById('stdModbusEnable');
                if (sel) translation = sel.value;
            }


            const fnSelect = document.getElementById('functionCode' + index);
            const regInput = document.getElementById('startRegister' + index);

            if (!fnSelect || !regInput) {
                console.warn('handleFunctionBlockConfig: missing elements for index', index);
                return;
            }

            const functionCode = fnSelect.value;

            // Apply validation only if translation is "1" (Yes)
            if (translation === "1") {
                let min, max;
                switch (functionCode) {
                    case "1":
                        min = 1;
                        max = 9999;
                        break;
                    case "2":
                        min = 10001;
                        max = 19999;
                        break;
                    case "3":
                        min = 40001;
                        max = 49999;
                        break;
                    case "4":
                        min = 30001;
                        max = 39999;
                        break;
                    default:
                        L.ui.showAlert("error", "Error", `Invalid Function Code`);
                        regInput.value = '';
                        return;
                }

                regInput.min = min;
                regInput.max = max;

                // Validate the value
                let regVal = parseInt(regInput.value, 10);
                if (isNaN(regVal)) {
                    regInput.value = '';
                    return;
                }

                if (regVal < min || regVal > max) {
                    L.ui.showAlert("warning", "Not in the specific range", `For Function Code ${functionCode}, Start Reg must be between ` +
                        `${min.toString().padStart(5, '0')} and ${max.toString().padStart(5, '0')}.`);
                    regInput.value = '';
                } else {
                    regInput.value = regVal.toString().padStart(5, '0');
                }
            } else {
                // If translation is "0" (No), skip validation
                regInput.min = '';
                regInput.max = '';
            }
        }

        validateDeviceName = function () {
            var inputField = document.getElementById("devicename");
            var value = inputField.value;


            var regex = /^[A-Za-z0-9]+$/;

            if (!regex.test(value)) {
                L.ui.showAlert("error", "Invalid Device Name", `Invalid Device Name! Only letters and numbers are allowed (no spaces or special characters).`);
                inputField.value = value.replace(/[^A-Za-z0-9]/g, '');
            }
        }

        validatefcatory = function (inputElement) {
            if (!inputElement) return;
            const value = inputElement.value;
            if (value && !value.includes('.')) {
                L.ui.showAlert("warning", "No Decimal Value", `Please enter a decimal value for Multiplication factor (e.g., 1.23)`);
                inputElement.value = '';
            }
        }

        handleRegisterAlarmToggle = function (index) {
            var chk = document.getElementById('enableAlarm' + index);
            var btn = document.getElementById('addAlarmBtn' + index);

            if (!chk || !btn) return;

            if (chk.checked) {
                chk.value = '1';        // for API
                btn.disabled = false;   // enable Add alarm
            } else {
                chk.value = '0';
                btn.disabled = true;    // disable Add alarm
            }
        }

        // === Alarm-per-register globals ===
        var currentAlarmRegisterIndex = null;   // which register's alarm are we editing
        self.registerAlarms = {};                // registerIndex -> alarm config object



        getRegisterDatatype = function (index) {
            var el = document.getElementById('Datatype' + index);
            return el ? String(el.value) : '';
        }

        isOneBitDatatype = function (code) {
            return code === '11' || code === '22';
        }


        handleDatatypeCodeChange = function (i) {
            var DataType = document.getElementById('Datatype' + i).value;
            var Multifactor = document.getElementById('multifactor' + i);

            // Multifactor visibility logic
            if (Multifactor) {
                if (DataType === '0' || DataType === '11' || DataType === '22') {
                    Multifactor.style.display = 'none';
                } else {
                    Multifactor.style.display = 'block';
                }
            }

            // If the Alarm modal is open for this register, update visibility live
            if (currentAlarmRegisterIndex === i) {
                updateAlarmModalVisibility(DataType);
            }
        }


        updateAlarmModalVisibility = function (datatypeCode) {
            // read current category from modal select/input (existing id in your page)
            var category = (document.getElementById('alarmCategoryModal') || {}).value;
            var rowUpperTh = document.getElementById('rowAlarmUpperThreshold');
            var rowLowerTh = document.getElementById('rowAlarmLowerThreshold');
            var rowUpperHys = document.getElementById('rowAlarmUpperHys');
            var rowLowerHys = document.getElementById('rowAlarmLowerHys');

            // If category is Event (2) -> hide ALL threshold/hysteresis regardless of datatype
            if (String(category) === '2') {
                if (rowUpperTh) rowUpperTh.style.display = 'none';
                if (rowLowerTh) rowLowerTh.style.display = 'none';
                if (rowUpperHys) rowUpperHys.style.display = 'none';
                if (rowLowerHys) rowLowerHys.style.display = 'none';
                return;
            }

            // Otherwise, if datatype is 1-bit or Boolean -> hide all
            var is1bitOrBoolean = (datatypeCode === '11' || datatypeCode === '22');
            if (is1bitOrBoolean) {
                if (rowUpperTh) rowUpperTh.style.display = 'none';
                if (rowLowerTh) rowLowerTh.style.display = 'none';
                if (rowUpperHys) rowUpperHys.style.display = 'none';
                if (rowLowerHys) rowLowerHys.style.display = 'none';
                return;
            }

            // Default: show all
            if (rowUpperTh) rowUpperTh.style.display = 'block';
            if (rowLowerTh) rowLowerTh.style.display = 'block';
            if (rowUpperHys) rowUpperHys.style.display = 'block';
            if (rowLowerHys) rowLowerHys.style.display = 'block';
        }
        handleAlarmCategoryChange = function () {
            if (currentAlarmRegisterIndex == null) return;
            var dt = getRegisterDatatype(currentAlarmRegisterIndex);
            updateAlarmModalVisibility(dt);
        }
        var saveBtn = document.getElementById('saveRegisterAlarmBtn');
        if (saveBtn) {
            saveBtn.addEventListener('click', function () {

                if (currentAlarmRegisterIndex == null) {
                    alert('No register selected for alarm.');
                    return;
                }

                var idx = currentAlarmRegisterIndex;

                //  ADD THIS LINE (important)
                self.registerAlarms = self.registerAlarms || {};

                //  ALWAYS overwrite with latest modal values
                self.registerAlarms[idx] = {
                    category: document.getElementById('alarmCategoryModal').value,
                    status: document.getElementById('alarmStatusModal').value,
                    name: document.getElementById('alarmNameModal').value.trim(),

                    upperThreshold: document.getElementById('alarmUpperThresholdModal').value,
                    upperHysteresis: document.getElementById('alarmUpperHysModal').value,
                    lowerThreshold: document.getElementById('alarmLowerThresholdModal').value,
                    lowerHysteresis: document.getElementById('alarmLowerHysModal').value,

                    dataType: getRegisterDatatype(idx)
                };

                // Update button text
                var addBtn = document.getElementById('addAlarmBtn' + idx);
                if (addBtn) addBtn.textContent = 'Edit';

                $('#RegisterAlarmModal').modal('hide');
            });
        }
    },
});