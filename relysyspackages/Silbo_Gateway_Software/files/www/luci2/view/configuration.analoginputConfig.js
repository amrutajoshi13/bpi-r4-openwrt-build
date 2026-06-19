L.ui.view.extend({

    generateAnalogIOSections: function (totalIOs) {
        const self = this;
        const tabsNav = document.getElementById("tabs-nav");
        const tabsContainer = document.getElementById("tabs");

        tabsNav.innerHTML = "";
        tabsContainer.innerHTML = "";

        for (let i = 1; i <= totalIOs; i++) {
            let tabItem = document.createElement("li");
            tabItem.innerHTML = `<span class="tab-label">Analog Input ${i}</span>`;
            tabItem.id = `tab-link-${i}`;
            tabItem.onclick = () => self.showTab(i);
            tabsNav.appendChild(tabItem);

            let section = document.createElement("div");
            section.id = `tab${i}`;
            section.className = "analog-io-section";
            section.innerHTML = `
            <label class="analog-io-label">
                <input type="checkbox" id="enableAnalogOutput${i}" class="analog-io-checkbox">
                Enable Analog Output ${i}
            </label>

            <div id="analogOutputSection${i}" class="config-section" style="display: none;">

           <!-- Mode Dropdown -->
            <label class="analog-io-label">Mode:
              <select id="modeSelect${i}" class="analog-io-select">
                <option value="Normal">Normal</option>
                <option value="Multiply">Multiply</option>
                <option value="Scale">Scale</option>
              </select>
            </label>
                    
            <!-- Multiplication Factor (shown only if mode = Multiply) -->
            <label class="analog-io-label" id="multiplicationFactorInputBox${i}" style="display: none;">
              Multiplication Factor:
              <input type="number" id="multiplicationFactor${i}" class="analog-io-input">
            </label>

            <!-- Scale Fields (shown only if mode = Scale) -->
            <div id="scaleFieldsSection${i}" style="display: none;">
              <label class="analog-io-label">Transducer Max:
                <input type="number" id="transducerMax${i}" class="analog-io-input">
              </label>
              <label class="analog-io-label">Transducer Min:
                <input type="number" id="transducerMin${i}" class="analog-io-input">
              </label>
              <label class="analog-io-label">Raw Max:
                <input type="number" id="rawMax${i}" class="analog-io-input">
              </label>
              <label class="analog-io-label">Raw Min:
                <input type="number" id="rawMin${i}" class="analog-io-input">
              </label>

              <label class="analog-io-label">
                <input type="checkbox" id="clampEnable${i}" class="analog-io-checkbox">
                Clamp Values Enable
              </label>
              <div id="clampFields${i}" style="display: none;">
                <label class="analog-io-label">Clamp Max Value:
                  <input type="number" id="clampMax${i}" class="analog-io-input">
                </label>
                <label class="analog-io-label">Clamp Min Value:
                  <input type="number" id="clampMin${i}" class="analog-io-input">
                </label>
              </div>
            </div>


            <!-- Alarm Enable -->
            <label class="analog-io-label">
            <input type="checkbox" id="alarmEnable${i}" class="analog-io-checkbox">
            Alarm Enable
            </label>

            <!-- Time Dependency -->
            <div id="alarmDependencySection${i}" style="display: none;">
            <label class="analog-io-label">
                <input type="checkbox" id="timeDependency${i}" class="analog-io-checkbox">
                Time Dependency
            </label>
            <label class="analog-io-label" id="alarmStartTime${i}" style="display: none;">
                Alarm Start Time:
                <input type="time" id="startTime${i}" class="analog-io-input" step="1">
            </label>
            <label class="analog-io-label" id="alarmStopTime${i}" style="display: none;">
                Alarm Stop Time:
                <input type="time" id="stopTime${i}" class="analog-io-input" step="1">
            </label>

          <label class="analog-io-label">
             <input type="checkbox" id="dayDependency${i}" class="analog-io-checkbox">
              Day Dependency
         </label>

        <label class="analog-io-label" id="dayDropdown${i}" style="display: none;">
            Select Day:
            <select class="analog-io-select" id="daySelect${i}">
                <option value="">-- Select Day --</option>
                <option value="0">Monday</option>
                <option value="1">Tuesday</option>
                <option value="2">Wednesday</option>
                <option value="3">Thursday</option>
                <option value="4">Friday</option>
                <option value="5">Saturday</option>
                <option value="6">Sunday</option>
            </select>
        </label>
    </div>

            <!-- Upper Threshold -->
            <label class="analog-io-label">
            <input type="checkbox" id="upperThresholdEnable${i}" class="analog-io-checkbox">
            Upper Threshold Enable
            </label>
            <div id="upperThresholdSection${i}" style="display: none;">
            <label class="analog-io-label">Upper Threshold Name:
                <input type="text" id="upperThresholdName${i}" class="analog-io-input">
            </label>
            <label class="analog-io-label" id="upperThresholdLevelLabel${i}" style="display: none;">Upper Threshold Level:
                <input type="number" id="upperThresholdLevel${i}" class="analog-io-input">
            </label>
            <label class="analog-io-label" id="upperHysteresisLabel${i}" style="display: none;">Upper Hysteresis:
                <input type="number" id="upperHysteresis${i}" class="analog-io-input">
            </label>
            </div>

            <!-- Lower Threshold -->
            <label class="analog-io-label">
            <input type="checkbox" id="lowerThresholdEnable${i}" class="analog-io-checkbox">
            Lower Threshold Enable
            </label>
            <div id="lowerThresholdSection${i}" style="display: none;">
            <label class="analog-io-label">Lower Threshold Name:
                <input type="text" id="lowerThresholdName${i}" class="analog-io-input">
            </label>
            <label class="analog-io-label" id="lowerThresholdLevelLabel${i}" style="display: none;">Lower Threshold Level:
                <input type="number" id="lowerThresholdLevel${i}" class="analog-io-input">
            </label>
            <label class="analog-io-label" id="lowerHysteresisLabel${i}" style="display: none;">Lower Hysteresis:
                <input type="number" id="lowerHysteresis${i}" class="analog-io-input">
            </label>
            </div>

        </div>`;
            tabsContainer.appendChild(section);
            const outputCheckbox = document.getElementById(`enableAnalogOutput${i}`);
            const outputSection = document.getElementById(`analogOutputSection${i}`);
            const modeSelect = document.getElementById(`modeSelect${i}`);
            const multiplicationBox = document.getElementById(`multiplicationFactorInputBox${i}`);
            const scaleFields = document.getElementById(`scaleFieldsSection${i}`);
            const clampCheckbox = document.getElementById(`clampEnable${i}`);
            const clampFields = document.getElementById(`clampFields${i}`);

            outputCheckbox.addEventListener("change", function () {
                outputSection.style.display = this.checked ? "block" : "none";
            });

            modeSelect.addEventListener("change", function () {
                const mode = this.value;
                multiplicationBox.style.display = mode === "Multiply" ? "block" : "none";
                scaleFields.style.display = mode === "Scale" ? "block" : "none";
            });

            clampCheckbox.addEventListener("change", function () {
                clampFields.style.display = this.checked ? "block" : "none";
            });

            // Event listener: Enable Analog Output
            document.getElementById(`enableAnalogOutput${i}`).addEventListener("change", function () {
                const section = document.getElementById(`analogOutputSection${i}`);
                section.style.display = this.checked ? "block" : "none";
                self.updateErrorCountForTab(i);
            });
            // Alarm Enable
            document.getElementById(`alarmEnable${i}`).addEventListener("change", function () {
                const depSection = document.getElementById(`alarmDependencySection${i}`);
                depSection.style.display = this.checked ? "block" : "none";
                // Dynamically also trigger threshold labels
                const upperCheck = document.getElementById(`upperThresholdEnable${i}`).checked;
                document.getElementById(`upperThresholdLevelLabel${i}`).style.display = this.checked && upperCheck ? "block" : "none";
                document.getElementById(`upperHysteresisLabel${i}`).style.display = this.checked && upperCheck ? "block" : "none";

                const lowerCheck = document.getElementById(`lowerThresholdEnable${i}`).checked;
                document.getElementById(`lowerThresholdLevelLabel${i}`).style.display = this.checked && lowerCheck ? "block" : "none";
                document.getElementById(`lowerHysteresisLabel${i}`).style.display = this.checked && lowerCheck ? "block" : "none";
                self.updateErrorCountForTab(i);
            });

            // Time Dependency
            document.getElementById(`timeDependency${i}`).addEventListener("change", function () {
                const start = document.getElementById(`alarmStartTime${i}`);
                const stop = document.getElementById(`alarmStopTime${i}`);
                const visible = this.checked ? "block" : "none";
                start.style.display = visible;
                stop.style.display = visible;
                document.getElementById(`startTime${i}`).dispatchEvent(new Event("blur"));
                document.getElementById(`stopTime${i}`).dispatchEvent(new Event("blur"));
                self.updateErrorCountForTab(i);
            });

            // Day Dependency
            document.getElementById(`dayDependency${i}`).addEventListener("change", function () {
                const days = document.getElementById(`dayDropdown${i}`);
                days.style.display = this.checked ? "block" : "none";

                self.updateErrorCountForTab(i);
            });

            // Upper Threshold Enable
            document.getElementById(`upperThresholdEnable${i}`).addEventListener("change", function () {
                const section = document.getElementById(`upperThresholdSection${i}`);
                section.style.display = this.checked ? "block" : "none";

                const level = document.getElementById(`upperThresholdLevelLabel${i}`);
                const hyst = document.getElementById(`upperHysteresisLabel${i}`);
                const alarm = document.getElementById(`alarmEnable${i}`).checked;
                level.style.display = alarm && this.checked ? "block" : "none";
                hyst.style.display = alarm && this.checked ? "block" : "none";

                // Manually trigger validation so all fields are marked visually
                document.getElementById(`upperThresholdName${i}`).dispatchEvent(new Event("blur"));
                document.getElementById(`upperThresholdLevel${i}`).dispatchEvent(new Event("blur"));
                document.getElementById(`upperHysteresis${i}`).dispatchEvent(new Event("blur"));

                self.updateErrorCountForTab(i);
            });

            // Lower Threshold Enable
            document.getElementById(`lowerThresholdEnable${i}`).addEventListener("change", function () {
                const section = document.getElementById(`lowerThresholdSection${i}`);
                section.style.display = this.checked ? "block" : "none";
                self.updateErrorCountForTab(i);

                // Optional: Show these only if Alarm is also checked
                const level = document.getElementById(`lowerThresholdLevelLabel${i}`);
                const hyst = document.getElementById(`lowerHysteresisLabel${i}`);
                const alarm = document.getElementById(`alarmEnable${i}`).checked;
                level.style.display = alarm && this.checked ? "block" : "none";
                hyst.style.display = alarm && this.checked ? "block" : "none";

                // Manually trigger validation so all fields are marked visually
                document.getElementById(`lowerThresholdName${i}`).dispatchEvent(new Event("blur"));
                document.getElementById(`lowerThresholdLevel${i}`).dispatchEvent(new Event("blur"));
                document.getElementById(`lowerHysteresis${i}`).dispatchEvent(new Event("blur"));
                self.updateErrorCountForTab(i);
            });
            setTimeout(() => {
                self.addValidation(`multiplicationFactor${i}`, () => document.getElementById(`modeSelect${i}`).value === "Multiply", i);
                self.addValidation(`transducerMax${i}`, () => document.getElementById(`modeSelect${i}`).value === "Scale", i);
                self.addValidation(`transducerMin${i}`, () => document.getElementById(`modeSelect${i}`).value === "Scale", i);
                self.addValidation(`rawMax${i}`, () => document.getElementById(`modeSelect${i}`).value === "Scale", i);
                self.addValidation(`rawMin${i}`, () => document.getElementById(`modeSelect${i}`).value === "Scale", i);
                self.addValidation(`clampMax${i}`, () => document.getElementById(`modeSelect${i}`).value === "Scale" && document.getElementById(`clampEnable${i}`).checked, i);
                self.addValidation(`clampMin${i}`, () => document.getElementById(`modeSelect${i}`).value === "Scale" && document.getElementById(`clampEnable${i}`).checked, i);

                self.addValidation(`upperThresholdName${i}`, `upperThresholdEnable${i}`, i);
                self.addValidation(`upperThresholdLevel${i}`, `upperThresholdEnable${i}`, i);
                self.addValidation(`upperHysteresis${i}`, `upperThresholdEnable${i}`, i);
                self.addValidation(`lowerThresholdName${i}`, `lowerThresholdEnable${i}`, i);
                self.addValidation(`lowerThresholdLevel${i}`, `lowerThresholdEnable${i}`, i);
                self.addValidation(`lowerHysteresis${i}`, `lowerThresholdEnable${i}`, i);
                self.addValidation(`startTime${i}`, `timeDependency${i}`, i);
                self.addValidation(`stopTime${i}`, `timeDependency${i}`, i);
                self.updateErrorCountForTab(i);
            }, 0);
        }
    },

    showTab: function (tabNumber) {
        const target = document.getElementById(`tab${tabNumber}`);
        if (!target) return;
        // Hide all sections
        document.querySelectorAll('.analog-io-section')
            .forEach(tab => tab.style.display = 'none');
        // Show selected section
        target.style.display = 'block';
        // Update active tab
        document.querySelectorAll('#tabs-nav li')
            .forEach(tab => tab.classList.remove('active-tab'));

        const activeTab = document.getElementById(`tab-link-${tabNumber}`);
        if (activeTab) activeTab.classList.add('active-tab');
    },

    collectAndSendAnalogIOConfig: function () {
        //const totalIOs = 2; // Since you said 2 tabs
        const totalIOs = document.querySelectorAll('#tabs-nav li').length;
        const self = this;
        const analogConfig = {
            AInputBurstMode: "0",
            NoOfInputs: String(totalIOs),
            ChannelTypes: {
                ChannelType1: "1",
                ChannelType2: "2",
                ChannelType3: "1",
                ChannelType4: "1"
            }
        };

        for (let i = 1; i <= totalIOs; i++) {
            const enable = document.getElementById(`enableAnalogOutput${i}`).checked ? "1" : "0";
            const alarmEnable = document.getElementById(`alarmEnable${i}`).checked ? "1" : "0";
            const upperEnable = document.getElementById(`upperThresholdEnable${i}`).checked ? "1" : "0";
            const lowerEnable = document.getElementById(`lowerThresholdEnable${i}`).checked ? "1" : "0";
            const timeDep = document.getElementById(`timeDependency${i}`).checked ? "1" : "0";
            const dayDep = document.getElementById(`dayDependency${i}`).checked ? "1" : "0";
            const clampEnable = document.getElementById(`clampEnable${i}`)?.checked ? "1" : "0";

            const data = {
                Enable: enable,
                Mode: document.getElementById(`modeSelect${i}`)?.value || "Normal",
                MultiplicationFactor: document.getElementById(`multiplicationFactor${i}`)?.value || "",
                TransducerMax: document.getElementById(`transducerMax${i}`)?.value || "",
                TransducerMin: document.getElementById(`transducerMin${i}`)?.value || "",
                RawMax: document.getElementById(`rawMax${i}`)?.value || "",
                RawMin: document.getElementById(`rawMin${i}`)?.value || "",
                ClampEnable: clampEnable,
                ClampMax: document.getElementById(`clampMax${i}`)?.value || "",
                ClampMin: document.getElementById(`clampMin${i}`)?.value || "",
                AlarmActiveState: alarmEnable,
                UpperThresholdEnable: upperEnable,
                UpperThresholdName: document.getElementById(`upperThresholdName${i}`)?.value || "",
                UpperThreshold: document.getElementById(`upperThresholdLevel${i}`)?.value || "",
                UpperHysteresis: document.getElementById(`upperHysteresis${i}`)?.value || "",
                LowerThresholdEnable: lowerEnable,
                LowerThresholdName: document.getElementById(`lowerThresholdName${i}`)?.value || "",
                LowerThreshold: document.getElementById(`lowerThresholdLevel${i}`)?.value || "",
                LowerHysteresis: document.getElementById(`lowerHysteresis${i}`)?.value || "",
                TimeDependency: timeDep,
                AlarmStartTime: document.getElementById(`startTime${i}`)?.value || "",
                AlarmStopTime: document.getElementById(`stopTime${i}`)?.value || "",
                DayDependency: dayDep,
                DayDependencyValue: document.getElementById(`daySelect${i}`)?.value || ""
            };

            analogConfig[`AInput${i}`] = data;
        }
        const payload = {
            analoginputconfig: analogConfig
        };
        //  Now send the payload
        self.sendAnalogInputConfig(payload);
    },

    sendAnalogInputConfig: function (data) {
        let params = window.location.href;
        let BaseURL = new URL(params).origin;
        const overlay = document.getElementById("aioLoadingOverlay");
        const toast = document.getElementById("aioToast");
        const toastText = document.getElementById("aioToastText");

        // Show loading overlay
        overlay.style.display = "flex";
        fetch(`${BaseURL}:30004/AI_Post/`, {
            //fetch("https://cors-anywhere.herokuapp.com/https://webhook.site/b586ea75-e0a0-4cc1-b20b-cfbba37afd9b", {
            method: "POST",
            headers: {
                "Content-Type": "application/json"
            },
            body: JSON.stringify(data)
        })
            .then(response => {
                if (!response.ok) throw new Error("Network response was not ok");
                return response.text();
            })
            .then(text => {
                L.ui.showAlert("success", "Saved", "Configuration saved successfully!");
                setTimeout(() => {
                    location.reload();
                }, 1000);
            })
            .catch(error => {
                console.error("Error:", error);
                L.ui.showAlert("error", "Failed", "Failed to save configuration!");
            })
            .finally(() => {
                overlay.style.display = "none";
            });
    },

    populateAnalogIOConfigFromAPI: function () {
        let params = window.location.href;
        let BaseURL = new URL(params).origin;
        const self = this;
        fetch(`${BaseURL}:30004/AI_Configuration/`)
            //  fetch("https://mocki.io/v1/33ab0bde-55f1-45c2-970c-d4f0a4997e4b")
            .then(response => response.json())
            .then(data => {
                const analogConfig = data.analoginputconfig;
                const totalIOs = parseInt(analogConfig.NoOfInputs || "1", 10);

                //  build tabs dynamically from backend value
                self.generateAnalogIOSections(totalIOs);


                for (let i = 1; i <= totalIOs; i++) {
                    const config = analogConfig[`AInput${i}`];
                    if (!config) continue;

                    // Set checkbox states
                    document.getElementById(`enableAnalogOutput${i}`).checked = config.Enable === "1";
                    document.getElementById(`alarmEnable${i}`).checked = config.AlarmActiveState === "1";
                    document.getElementById(`upperThresholdEnable${i}`).checked = config.UpperThresholdEnable === "1";
                    document.getElementById(`lowerThresholdEnable${i}`).checked = config.LowerThresholdEnable === "1";
                    document.getElementById(`timeDependency${i}`).checked = config.TimeDependency === "1";
                    document.getElementById(`dayDependency${i}`).checked = config.DayDependency === "1";

                    // Set input values
                    document.getElementById(`upperThresholdLevel${i}`).value = config.UpperThreshold || "";
                    document.getElementById(`upperHysteresis${i}`).value = config.UpperHysteresis || "";
                    document.getElementById(`lowerThresholdLevel${i}`).value = config.LowerThreshold || "";
                    document.getElementById(`lowerHysteresis${i}`).value = config.LowerHysteresis || "";
                    document.getElementById(`multiplicationFactor${i}`).value = config.MultiplicationFactor || "";
                    document.getElementById(`upperThresholdName${i}`).value = config.UpperThresholdName || "";
                    document.getElementById(`lowerThresholdName${i}`).value = config.LowerThresholdName || "";
                    document.getElementById(`startTime${i}`).value = config.AlarmStartTime || "";
                    document.getElementById(`stopTime${i}`).value = config.AlarmStopTime || "";
                    document.getElementById(`daySelect${i}`).value = config.DayDependencyValue || "";

                    // NEW FIELDS: Mode, Scale, Clamp
                    document.getElementById(`modeSelect${i}`).value = config.Mode || "Normal";
                    document.getElementById(`transducerMax${i}`).value = config.TransducerMax || "";
                    document.getElementById(`transducerMin${i}`).value = config.TransducerMin || "";
                    document.getElementById(`rawMax${i}`).value = config.RawMax || "";
                    document.getElementById(`rawMin${i}`).value = config.RawMin || "";
                    document.getElementById(`clampEnable${i}`).checked = config.ClampEnable === "1";
                    document.getElementById(`clampMax${i}`).value = config.ClampMax || "";
                    document.getElementById(`clampMin${i}`).value = config.ClampMin || "";

                    // Trigger change event for checkboxes to toggle visibility
                    document.getElementById(`enableAnalogOutput${i}`).dispatchEvent(new Event('change'));
                    document.getElementById(`alarmEnable${i}`).dispatchEvent(new Event('change'));
                    document.getElementById(`timeDependency${i}`).dispatchEvent(new Event('change'));
                    document.getElementById(`dayDependency${i}`).dispatchEvent(new Event('change'));
                    document.getElementById(`upperThresholdEnable${i}`).dispatchEvent(new Event('change'));
                    document.getElementById(`lowerThresholdEnable${i}`).dispatchEvent(new Event('change'));

                    document.getElementById(`modeSelect${i}`).dispatchEvent(new Event('change'));
                    document.getElementById(`clampEnable${i}`).dispatchEvent(new Event('change'));

                    //  Attach listeners so count updates even if user unchecks checkboxes
                    // document.getElementById(`multiplicationFactorEnable${i}`).addEventListener("change", () => {
                    //     self.updateErrorCountForTab(i);
                    // });
                    document.getElementById(`upperThresholdEnable${i}`).addEventListener("change", () => {
                        self.updateErrorCountForTab(i);
                    });
                    document.getElementById(`lowerThresholdEnable${i}`).addEventListener("change", () => {
                        self.updateErrorCountForTab(i);
                    });
                    document.getElementById(`timeDependency${i}`).addEventListener("change", () => {
                        self.updateErrorCountForTab(i);
                    });


                    setTimeout(() => {
                        self.addValidation(`multiplicationFactor${i}`, () => document.getElementById(`modeSelect${i}`).value === "Multiply", i);
                        self.addValidation(`transducerMax${i}`, () => document.getElementById(`modeSelect${i}`).value === "Scale", i);
                        self.addValidation(`transducerMin${i}`, () => document.getElementById(`modeSelect${i}`).value === "Scale", i);
                        self.addValidation(`rawMax${i}`, () => document.getElementById(`modeSelect${i}`).value === "Scale", i);
                        self.addValidation(`rawMin${i}`, () => document.getElementById(`modeSelect${i}`).value === "Scale", i);
                        self.addValidation(`clampMax${i}`, () => document.getElementById(`modeSelect${i}`).value === "Scale" && document.getElementById(`clampEnable${i}`).checked, i);
                        self.addValidation(`clampMin${i}`, () => document.getElementById(`modeSelect${i}`).value === "Scale" && document.getElementById(`clampEnable${i}`).checked, i);
                        self.addValidation(`upperThresholdName${i}`, `upperThresholdEnable${i}`, i);
                        self.addValidation(`upperThresholdLevel${i}`, `upperThresholdEnable${i}`, i);
                        self.addValidation(`upperHysteresis${i}`, `upperThresholdEnable${i}`, i);
                        self.addValidation(`lowerThresholdName${i}`, `lowerThresholdEnable${i}`, i);
                        self.addValidation(`lowerThresholdLevel${i}`, `lowerThresholdEnable${i}`, i);
                        self.addValidation(`lowerHysteresis${i}`, `lowerThresholdEnable${i}`, i);
                        self.addValidation(`startTime${i}`, `timeDependency${i}`, i);
                        self.addValidation(`stopTime${i}`, `timeDependency${i}`, i);
                        self.updateErrorCountForTab(i);
                    }, 0);
                }
                requestAnimationFrame(() => {
                    self.showTab(1);
                });
            })
            .catch(error => console.error("Error loading configuration:", error));
    },

    addValidation: function (inputId, conditionFn, tabNumber) {
        const self = this;
        const input = document.getElementById(inputId);

        if (!input) return;

        const validate = function () {
            const errorId = `${inputId}-error`;
            let existingError = document.getElementById(errorId);

            if (conditionFn() && input.value.trim() === "") {
                input.style.border = '1px solid red';

                if (!existingError) {
                    const error = document.createElement('div');
                    error.id = errorId;
                    error.style.color = 'red';
                    error.style.fontSize = '12px';
                    error.innerText = "Input field must not be empty";
                    input.parentNode.appendChild(error);
                }
            } else {
                input.style.border = '';
                if (existingError) {
                    existingError.remove();
                }
            }
            self.updateErrorCountForTab(tabNumber);
        };
        input.addEventListener('blur', validate);
        input.addEventListener('input', validate);
    },

    updateErrorCountForTab: function (tabNumber) {
        let errorCount = 0;

        const isAnalogEnabled = document.getElementById(`enableAnalogOutput${tabNumber}`).checked;
        if (!isAnalogEnabled) {
            // If the section is disabled, skip all checks and remove error badge
            const tab = document.getElementById(`tab-link-${tabNumber}`);
            const label = `Analog Input ${tabNumber}`;
            tab.innerHTML = `<span class="tab-label">${label}</span>`;
            return;
        }

        const alarmChecked = document.getElementById(`alarmEnable${tabNumber}`).checked;

        const checkField = (fieldId, shouldCheck) => {
            const input = document.getElementById(fieldId);
            if (shouldCheck && input && input.value.trim() === "") {
                errorCount++;
            }
        };
        const mode = document.getElementById(`modeSelect${tabNumber}`).value;
        checkField(`multiplicationFactor${tabNumber}`, mode === "Multiply");
        checkField(`transducerMax${tabNumber}`, mode === "Scale");
        checkField(`transducerMin${tabNumber}`, mode === "Scale");
        checkField(`rawMax${tabNumber}`, mode === "Scale");
        checkField(`rawMin${tabNumber}`, mode === "Scale");
        const clampChecked = document.getElementById(`clampEnable${tabNumber}`).checked;
        checkField(`clampMax${tabNumber}`, mode === "Scale" && clampChecked);
        checkField(`clampMin${tabNumber}`, mode === "Scale" && clampChecked);
        // Upper Threshold
        const upperChecked = document.getElementById(`upperThresholdEnable${tabNumber}`).checked;
        checkField(`upperThresholdName${tabNumber}`, upperChecked);
        checkField(`upperThresholdLevel${tabNumber}`, upperChecked && alarmChecked);
        checkField(`upperHysteresis${tabNumber}`, upperChecked && alarmChecked);
        // Lower Threshold
        const lowerChecked = document.getElementById(`lowerThresholdEnable${tabNumber}`).checked;
        checkField(`lowerThresholdName${tabNumber}`, lowerChecked);
        checkField(`lowerThresholdLevel${tabNumber}`, lowerChecked && alarmChecked);
        checkField(`lowerHysteresis${tabNumber}`, lowerChecked && alarmChecked);
        // Time Dependency
        const timeChecked = document.getElementById(`timeDependency${tabNumber}`).checked;
        checkField(`startTime${tabNumber}`, timeChecked);
        checkField(`stopTime${tabNumber}`, timeChecked);

        // Update tab badge
        const tab = document.getElementById(`tab-link-${tabNumber}`);
        const label = `Analog Input ${tabNumber}`;
        tab.innerHTML = `<span class="tab-label">${label}${errorCount > 0 ? `<span class="error-badge">${errorCount}</span>` : ''}</span>`;
    },

    addSendConfigRow: function () {
        const self = this; // Capture correct context
        const fieldContent = document.getElementById('fieldContentDropdown').value;
        const jsonKey = document.getElementById('fieldJsonKey').value.trim();
        const value = document.getElementById('fieldJsonKeyValue')?.value.trim() || '';
        const tableBody = document.querySelector('#sendConfigTable tbody');
        const tableContainer = document.getElementById('sendConfigTableContainer');

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
            document.getElementById('editJsonKeyValue').value = '';
            document.getElementById('editFieldContent').value = field;
            document.getElementById('editFieldJsonKey').value = jsonKey;
            // document.getElementById('editJsonKeyValue').value = jsonKeyValue;
            const isCustom = field.startsWith('AIOCustomfield');
            document.getElementById('jsonKeyValueGroup').style.display = isCustom ? 'block' : 'none';
            // document.getElementById('editJsonKeyValue').value = jsonKeyValue;
            if (isCustom) {
                document.getElementById('editJsonKeyValue').value = value;
            }
            $('#editSendConfigModal').modal('show');
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
        document.getElementById('fieldContentDropdown').value = '';
        document.getElementById('fieldJsonKey').value = '';
        document.getElementById('fieldJsonKeyValue').value = '';
        document.getElementById('jsonKeyValueGroupAdd').style.display = 'none';
    },

    reindexSendConfigRows: function () {
        const rows = document.querySelectorAll('#sendConfigTable tbody tr');
        rows.forEach((row, index) => {
            row.cells[0].textContent = index + 1;
        });
        if (rows.length === 0) {
            document.getElementById('sendConfigTableContainer').style.display = 'none';
        }
    },

    saveSendConfigChanges: function () {
        const fieldContent = document.getElementById('editFieldContent').value;
        const jsonKey = document.getElementById('editFieldJsonKey').value.trim();
        const value = document.getElementById('editJsonKeyValue').value.trim(); // new field

        if (!fieldContent || !jsonKey) {
            L.ui.showAlert("error", "Empty field", "Please fill both fields.");
            return;
        }

        if (this.editingSendConfigRow) {
            this.editingSendConfigRow.cells[1].textContent = fieldContent;
            this.editingSendConfigRow.cells[2].textContent = jsonKey;
            // this.editingSendConfigRow.setAttribute('data-json-key-value', jsonKeyValue);

            //Save the JSON key value only for SNMPCustomfield1
            const isCustomField = ['AIOCustomfield1', 'AIOCustomfield2', 'AIOCustomfield3', 'AIOCustomfield4', 'AIOCustomfield5'].includes(fieldContent);

            if (isCustomField) {
                this.editingSendConfigRow.setAttribute('data-json-key-value', value);
            } else {
                this.editingSendConfigRow.removeAttribute('data-json-key-value');
            }
        }

        $('#editSendConfigModal').modal('hide');
    },

    updateAllSendConfigs: function () {
        const self = this;
        let params = window.location.href;
        let BaseURL = new URL(params).origin;
        const tableRows = document.querySelectorAll('#sendConfigTable tbody tr');

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
                if (fieldContent.startsWith('AIOCustomfield')) {
                    config.keyValue = value;
                }
                sendConfigs.push(config);
            }
        });

        // Ensure SNMPData is always last
        const snmpIndex = sendConfigs.findIndex(
            item => item.fieldContent.toLowerCase() === "snmpdata"
        );
        if (snmpIndex > -1) {
            const [snmpItem] = sendConfigs.splice(snmpIndex, 1);
            sendConfigs.push(snmpItem);
        }

        // Show loading overlay for Send Configuration
        document.getElementById("sendConfigLoadingOverlay").style.display = "flex";

        fetch(`${BaseURL}:30005/POST_Selected_AIO_Configuration/`, {
            //fetch(`https://cors-anywhere.herokuapp.com/https://webhook.site/b586ea75-e0a0-4cc1-b20b-cfbba37afd9b`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(sendConfigs)
        })
            .then(response => {
                if (!response.ok) throw new Error("Network error");
                return response.text();
            })
            .then(responseText => {
                L.ui.showAlert("success", "Update Complete", "Device updated successfully !");
                setTimeout(() => {
                    location.reload();
                }, 1000);
            })
            .catch(error => {
                console.error("Send Config Update Failed:", error);
                L.ui.showAlert("error", "Update Failed", "Failed to update send configurations!");
            })
            .finally(() => {
                document.getElementById("sendConfigLoadingOverlay").style.display = "none";
            });
    },

    bindAIOPeriodicity: function () {
        const aioInput = document.getElementById('aioInput');
        if (!aioInput) return;

        aioInput.addEventListener('change', () => {
            const AIOPeriodicity = parseInt(aioInput.value, 10);

            if (isNaN(AIOPeriodicity) || AIOPeriodicity < 60) {
                L.ui.showAlert(
                    "warning",
                    "Invalid Value",
                    "Overall periodicity must be >= 60 seconds."
                );
                aioInput.value = 60;
                return;
            }

            let BaseURL = new URL(window.location.href).origin;

            // Optional: show loading overlay
            const overlay = document.getElementById("aioLoadingOverlay");
            if (overlay) overlay.style.display = "flex";

            fetch(`${BaseURL}:30008/AIO_Source_post/`, {
                //  fetch("https://cors-anywhere.herokuapp.com/https://webhook.site/b586ea75-e0a0-4cc1-b20b-cfbba37afd9b", {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    AIOInputPeriodicity: AIOPeriodicity
                })
            })
                .then(response => {
                    if (!response.ok) {
                        throw new Error("Failed to apply configuration");
                    }
                    return response.text();
                })
                .then(() => {
                    // SUCCESS ALERT
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
                    console.error(" Periodicity save failed:", err);
                    L.ui.showAlert(
                        "error",
                        "Failed",
                        "Failed to apply configuration"
                    );
                })
                .finally(() => {
                    if (overlay) overlay.style.display = "none";
                });
        });
    },

    disableAIOPage: function () {
        const wrapper = document.getElementById("aioContentWrapper");
        const overlay = document.getElementById("aioDisabledOverlay");

        if (wrapper) wrapper.classList.add("aio-blurred");
        if (overlay) overlay.style.display = "flex";
    },

    enableAIOPage: function () {
        const wrapper = document.getElementById("aioContentWrapper");
        const overlay = document.getElementById("aioDisabledOverlay");

        if (wrapper) wrapper.classList.remove("aio-blurred");
        if (overlay) overlay.style.display = "none";
    },

    loadAIOPage: function () {
        const self = this;
        let params = window.location.href;
        let BaseURL = new URL(params).origin;
        // dropdwon list API
        fetch(`${BaseURL}:30005/AIO_Available_Configuration/`)
            // fetch(`https://mocki.io/v1/f0a5dafb-6740-4bcf-878f-72b652849734`)
            .then(res => res.json())
            .then(data => {
                const dropdown = document.getElementById('fieldContentDropdown');
                const editDropdown = document.getElementById('editFieldContent');

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

        // Populate Existing Table Rows
        //fetch('https://mocki.io/v1/bd556857-5e1f-4ca8-ac29-2a48fa2ebed5')
        fetch(`${BaseURL}:30005/AIO_Selected_Configuration/`)
            .then(res => res.json())
            .then(data => {
                const tableBody = document.querySelector('#sendConfigTable tbody');
                const tableContainer = document.getElementById('sendConfigTableContainer');

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
                        row.querySelector('.btn-primary').addEventListener('click', () => {
                            self.editingSendConfigRow = row;
                            const field = row.cells[1].textContent.trim();
                            const jsonKey = row.cells[2].textContent.trim();
                            const value = row.getAttribute('data-json-key-value') || '';
                            document.getElementById('editFieldContent').value = field;
                            document.getElementById('editFieldJsonKey').value = jsonKey;
                            const isCustom = field.startsWith('AIOCustomfield');
                            document.getElementById('jsonKeyValueGroup').style.display = isCustom ? 'block' : 'none';
                            document.getElementById('editJsonKeyValue').value = isCustom ? value : '';
                            $('#editSendConfigModal').modal('show');
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

        document.getElementById('editFieldContent').addEventListener('change', function () {
            const selected = this.value;
            const isCustom = selected.startsWith('AIOCustomfield');
            document.getElementById('jsonKeyValueGroup').style.display = isCustom ? 'block' : 'none';
            if (!isCustom) {
                document.getElementById('editJsonKeyValue').value = '';
            }
        });
        document.getElementById("saveButton").addEventListener("click", () => {
            self.collectAndSendAnalogIOConfig();
        });
        // wire Update button
        const updateBtn = document.getElementById('updateAllSendConfigsBtn');
        if (updateBtn) {
            updateBtn.addEventListener('click', (e) => {
                e.preventDefault();
                self.updateAllSendConfigs();
            });
        }
        self.populateAnalogIOConfigFromAPI();
    },
    loadAIOPeriodicity: function () {
        const aioInput = document.getElementById('aioInput');
        if (!aioInput) return;

        let BaseURL = new URL(window.location.href).origin;

        fetch(`${BaseURL}:30008/AIO_Enable/`)
            .then(res => res.json())
            .then(data => {
                if (data.AIOInputPeriodicity !== undefined) {
                    aioInput.value = data.AIOInputPeriodicity;
                }
            })
            .catch(err => console.error("Failed to load AIO periodicity", err));
    },

    execute: function () {
        const self = this;
        let BaseURL = new URL(window.location.href).origin;

        function checkState(retryCount) {
            retryCount = retryCount || 0;
            const MAX_RETRIES = 3;
            const RETRY_DELAY_MS = 2000;

            fetch(`${BaseURL}:30008/device/applications/`)
                .then(res => {
                    if (!res.ok) throw new Error('Non-OK response: ' + res.status);
                    return res.json();
                })
                .then(apps => {
                    const aioApp = apps.find(app => app.id === "aio");

                    if (aioApp && aioApp.state === "running") {
                        self.enableAIOPage();
                        self.loadAIOPage();
                        self.loadAIOPeriodicity();
                        self.bindAIOPeriodicity();
                    } else {
                        self.disableAIOPage();
                    }
                })
                .catch(err => {
                    console.error('Execute API failed (attempt ' + (retryCount + 1) + '):', err);

                    if (retryCount < MAX_RETRIES) {
                        setTimeout(function () {
                            checkState(retryCount + 1);
                        }, RETRY_DELAY_MS);
                    } else {
                        console.warn('Max retries reached. Disabling AIO page.');
                        self.disableAIOPage();
                    }
                });
        }

        checkState(0);
    }
});