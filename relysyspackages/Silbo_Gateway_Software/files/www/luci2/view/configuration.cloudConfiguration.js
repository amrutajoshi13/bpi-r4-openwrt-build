L.ui.view.extend({

  deletekeyfile: L.rpc.declare({
    object: 'rpc-cloudconfig',
    method: 'delete',
    params: ['serverNumber'],
    expect: { output: '' }
  }),

  countkeys: L.rpc.declare({
    object: 'rpc-cloudconfig',
    method: 'countkeyfiles',
    expect: { output: '' }
  }),

  TestArchive: L.rpc.declare({
    object: 'rpc-cloudconfig',
    method: 'testarchive',
    params: ['archive', 'serverNumber'],
  }),

  countcertficates: L.rpc.declare({
    object: 'rpc-cloudconfig',
    method: 'countkeyfiles',
    params: ['serverNumber'],
    expect: { output: '' }
  }),
  getvalues: L.rpc.declare({
    object: 'rpc-cloudconfig',
    method: 'getvalue',
    params: ['serverNumber'],
    expect: { output: '' }
  }),
  countcertficates2: L.rpc.declare({
    object: 'rpc-cloudconfig',
    method: 'countkeyfiles',
    expect: { output: '' }
  }),



  handleArchiveUpload: function () {
    var self = this;
    L.ui.archiveUploadcertstls(
      L.tr('File Upload'),
      L.tr('Select the file and click on "%s" button to proceed.').format(L.tr('Apply')), {
      path: "/root/SenderAppComponent/etc/certs/",
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
    self.TestArchive(archive, "server1").then(function (TestArchiveOutput) {
      L.ui.dialog(
        L.tr('TestArchive'), [
        $('<p />').text(L.tr('Success')),
        $('<pre />')
          .addClass('alert-success')
          .text("file uploaded successfully")
      ], {
        style: 'close',
      }
      );
      try {
        if (document.getElementById('primaryCertName')) document.getElementById('primaryCertName').textContent = archive || 'No file chosen';
        if (document.getElementById('cmdCertName')) document.getElementById('cmdCertName').textContent = archive || 'No file chosen';
      } catch (e) {
        console.warn('sync UI after primary upload failed', e);
      }
      L.ui.loading(false);
    });
  },


  handleArchiveUpload1: function () {
    var self = this;
    L.ui.archiveUploadcertstls2(
      L.tr('File Upload'),
      L.tr('Select the file and click on "%s" button to proceed.').format(L.tr('Apply')), {
      path: "/root/SenderAppComponent/etc/certs2/",
      success: function (info) {
        self.handleArchiveVerify1(info);
      }
    }
    );
  },

  handleArchiveVerify1: function (info) {
    var self = this;
    var archive = $('[name=filename]').val();
    L.ui.loading(true);
    self.TestArchive(archive, "server2").then(function (TestArchiveOutput) {

      L.ui.dialog(
        L.tr('TestArchive'), [
        $('<p />').text(L.tr('Success')),
        $('<pre />')
          .addClass('alert-success')
          .text("file uploaded successfully")
      ], {
        style: 'close',
      }
      );
      try {
        if (document.getElementById('secondaryCertName')) document.getElementById('secondaryCertName').textContent = archive || 'No file chosen';
      } catch (e) { console.warn('sync UI after secondary upload failed', e); }

      L.ui.loading(false);
    });
  },

  handleArchiveUpload2: function () {
    var self = this;
    L.ui.archiveUploadcertshttps(
      L.tr('File Upload'),
      L.tr('Select the file and click on "%s" button to proceed.').format(L.tr('Apply')), {
      path: "/etc/ssl/certs/",
      success: function (info) {
        self.handleArchiveVerify2(info);
      }
    }
    );
  },

  handleArchiveVerify2: function (info) {
    var self = this;
    var archive = $('[name=filename]').val();
    console.log(archive);

    // if((checksumval == info.checksum) &&(sizeval == info.size)) {
    L.ui.loading(true);
    self.TestArchive(archive, "server1").then(function (TestArchiveOutput) {

      L.ui.dialog(
        L.tr('TestArchive'), [
        $('<p />').text(L.tr('Success')),
        $('<pre />')
          .addClass('alert-success')
          .text("file uploaded successfully")
      ], {
        style: 'close',

      }
      );
      L.ui.loading(false);
    });
    //}

  },

  handleArchiveUpload3: function () {
    var self = this;
    L.ui.archiveUploadcertshttps2(
      L.tr('File Upload'),
      L.tr('Select the file and click on "%s" button to proceed.').format(L.tr('Apply')), {
      path: "/etc/ssl/certs/",
      success: function (info) {
        self.handleArchiveVerify3(info);
      }
    }
    );
  },

  handleArchiveVerify3: function (info) {
    var self = this;
    var archive = $('[name=filename]').val();
    console.log(archive);

    // if((checksumval == info.checksum) &&(sizeval == info.size)) {
    L.ui.loading(true);
    self.TestArchive(archive, "server1").then(function (TestArchiveOutput) {

      L.ui.dialog(
        L.tr('TestArchive'), [
        $('<p />').text(L.tr('Success')),
        $('<pre />')
          .addClass('alert-success')
          .text("file uploaded successfully")
      ], {
        style: 'close',

      }
      );
      L.ui.loading(false);
    });
    //}

  },
  // ... keep your RPC declarations and other helpers above unchanged ...

  setupServerCard: function (prefix) {
    const $ = id => document.getElementById(`${prefix}${id}`);

    // Protocol + label
    const protocolEl = $('Protocol');
    const protocolLabel = document.getElementById(`${prefix}ProtocolLabel`) || null;

    // HTTP
    const contentType = $('ContentType');
    const customContentDiv = document.getElementById(`${prefix}CustomContentTypeDiv`);
    const authSelect = $('Auth');
    const authFields = document.getElementById(`${prefix}AuthFields`);
    const enableServerResp = $('EnableServerResp');
    const serverRespDiv = document.getElementById(`${prefix}ServerRespDiv`);
    const serverResp = $('ServerResp');
    const customServerRespDiv = document.getElementById(`${prefix}CustomServerRespDiv`);

    // MQTT
    const mqttFieldsContainer = document.getElementById(`${prefix}MqttFields`);
    const httpFieldsContainer = document.getElementById(`${prefix}HttpFields`);
    const mqttAuthMode = $('MqttAuthMode');
    const mqttAuthFields = document.getElementById(`${prefix}MqttAuthFields`);
    const mqttCertArea = document.getElementById(`${prefix}MqttCertArea`);
    const certUploadBtn = document.getElementById(`${prefix}CertUploadBtn`);
    const certDeleteBtn = document.getElementById(`${prefix}CertDeleteBtn`);
    const certFile = document.getElementById(`${prefix}MqttCertFile`);
    const certNameSpan = document.getElementById(`${prefix}CertName`);
    const enableClientId = $('EnableClientId');
    const clientIdField = document.getElementById(`${prefix}ClientIdField`);
    const enableSubscribe = $('EnableSubscribeTopic');
    const subscribeSection = document.getElementById(`${prefix}SubscribeSection`);
    function applyProtocolView() {
      const protoVal = protocolEl ? protocolEl.value : 'http';
      if (protocolLabel) protocolLabel.textContent = protoVal.toUpperCase();
      const httpsCertArea = document.getElementById(`${prefix}HttpsCertArea`);
      // locate mqtt-cmd checkbox and its container (if present)
      const mqttCmdField = document.getElementById(`${prefix}EnableMqttCmdField`);
      const mqttCmdCheckbox = document.getElementById(`${prefix}EnableMqttCmd`);

      // When switching to MQTT protocol:
      //  - save current mqtt-cmd checked state to a data attribute
      //  - hide the checkbox field (we don't allow enabling cmd cloud while protocol != http)
      //  - uncheck the checkbox and dispatch change so any dependent UI (MQTT Command Cloud card) updates
      if (protoVal === 'mqtt') {
        if (mqttCmdCheckbox) {
          // save state so it can be restored when returning to HTTP
          mqttCmdCheckbox.dataset._savedChecked = mqttCmdCheckbox.checked ? '1' : '0';
          // uncheck and dispatch change to hide mqtt cmd card
          mqttCmdCheckbox.checked = false;
          mqttCmdCheckbox.dispatchEvent(new Event('change'));
        }
        if (mqttCmdField) mqttCmdField.style.display = 'none';

        if (mqttFieldsContainer) mqttFieldsContainer.style.display = '';
        if (httpFieldsContainer) httpFieldsContainer.style.display = 'none';
        if (httpsCertArea) httpsCertArea.style.display = 'none';
      } else {
        // When switching to HTTP protocol:
        //  - show the mqtt-cmd checkbox field again
        //  - restore previous checked state (if any) from data attribute; otherwise leave as-is
        //  - dispatch change so dependent UI updates
        if (mqttCmdField) mqttCmdField.style.display = 'flex';
        if (mqttCmdCheckbox) {
          // restore previous value if we had saved one
          if (typeof mqttCmdCheckbox.dataset._savedChecked !== 'undefined') {
            mqttCmdCheckbox.checked = mqttCmdCheckbox.dataset._savedChecked === '1';
          }
          // ensure any UI that depends on this checkbox updates
          mqttCmdCheckbox.dispatchEvent(new Event('change'));
        }

        if (mqttFieldsContainer) mqttFieldsContainer.style.display = 'none';
        if (httpFieldsContainer) httpFieldsContainer.style.display = '';
        if (httpsCertArea) {
          httpsCertArea.style.display = (protoVal === 'https') ? 'flex' : 'none';
        }
      }
    }

    if (protocolEl) protocolEl.addEventListener('change', applyProtocolView);

    // HTTP content type -> show custom field
    if (contentType && customContentDiv) {
      contentType.addEventListener('change', function () {
        customContentDiv.style.display = contentType.value === 'custom' ? 'block' : 'none';
      });
    }
    if (authSelect && authFields) {
      authSelect.addEventListener('change', function () {
        // find static pieces
        const userpassDiv = document.getElementById(`${prefix}AuthUserPass`);
        const bearerDiv = document.getElementById(`${prefix}AuthBearer`);

        // default hide both
        if (userpassDiv) userpassDiv.style.display = 'none';
        if (bearerDiv) bearerDiv.style.display = 'none';

        if (authSelect.value === '1') {
          // show username/password
          if (userpassDiv) userpassDiv.style.display = 'block';
          authFields.style.display = 'block';
        } else if (authSelect.value === '2') {
          // show bearer
          if (bearerDiv) bearerDiv.style.display = 'block';
          authFields.style.display = 'block';
        } else {
          // hide entire auth area
          authFields.style.display = 'none';
        }
      });
      // initialize visibility on load
      authSelect.dispatchEvent(new Event('change'));
    }

    // Server response toggle (unchanged)
    if (enableServerResp && serverRespDiv) {
      enableServerResp.addEventListener('change', function () {
        serverRespDiv.style.display = enableServerResp.checked ? 'block' : 'none';
      });
      if (serverResp) {
        serverResp.addEventListener('change', function () {
          if (customServerRespDiv) customServerRespDiv.style.display = serverResp.value === 'custom' ? 'block' : 'none';
        });
      }
    }

    // MQTT auth mode handling (unchanged)
    function applyMqttAuthMode() {
      const mode = mqttAuthMode ? mqttAuthMode.value : '3';
      if (mqttAuthFields) mqttAuthFields.style.display = ['1', '2', '4'].includes(mode) ? 'block' : 'none';
      if (mqttCertArea) mqttCertArea.style.display = ['1', '0', '4'].includes(mode) ? 'flex' : 'none';
    }
    if (mqttAuthMode) mqttAuthMode.addEventListener('change', applyMqttAuthMode);

    // Certificate upload/delete UI (display filename only) - unchanged
    if (certUploadBtn && certFile && certNameSpan) {
      certUploadBtn.addEventListener('click', function () { certFile.click(); });
      certFile.addEventListener('change', function (ev) {
        const f = ev.target.files && ev.target.files[0];
        certNameSpan.textContent = f ? f.name : 'No file chosen';
      });
    }
    if (certDeleteBtn && certFile && certNameSpan) {
      certDeleteBtn.addEventListener('click', function () {
        certFile.value = '';
        certNameSpan.textContent = 'No file chosen';
      });
    }

    // Client ID toggle - unchanged
    if (enableClientId && clientIdField) {
      enableClientId.addEventListener('change', function () {
        clientIdField.style.display = enableClientId.checked ? 'flex' : 'none';
      });
    }

    // Subscribe section toggle - unchanged
    if (enableSubscribe && subscribeSection) {
      enableSubscribe.addEventListener('change', function () {
        subscribeSection.style.display = enableSubscribe.checked ? 'block' : 'none';
      });
    }

    // Initialize states (run once)
    if (protocolEl) applyProtocolView();
    if (contentType) contentType.dispatchEvent(new Event('change'));
    if (authSelect) authSelect.dispatchEvent(new Event('change'));
    if (mqttAuthMode) applyMqttAuthMode();
    if (enableClientId) enableClientId.dispatchEvent(new Event('change'));
    if (enableSubscribe) enableSubscribe.dispatchEvent(new Event('change'));
    if (enableServerResp) enableServerResp.dispatchEvent(new Event('change'));
  }, // end setupServerCard

  // setupServers: function () {
  //   this.setupServerCard('primary');
  //   this.setupServerCard('secondary');
  // },
  setupServers: function () {
    this.setupServerCard('primary');
    this.setupServerCard('secondary');
  },


  setupServerSelectToggle: function () {
    const serverSelect = document.getElementById('serverSelect');
    const secondaryCard = document.getElementById('secondaryCard');
    const primaryCard = document.getElementById('primaryCard');

    function apply() {
      const val = serverSelect ? serverSelect.value : 'primary';
      if (primaryCard) primaryCard.style.display = (val === 'primary' || val === 'both' || val === 'fallback') ? 'block' : 'none';
      if (secondaryCard) secondaryCard.style.display = (val === 'both' || val === 'fallback') ? 'block' : 'none';
    }

    if (serverSelect) serverSelect.addEventListener('change', apply);
    apply();
  },

  setupCollapsibles: function () {
    document.querySelectorAll('.server-header').forEach(function (header) {
      const btn = header.querySelector('.toggle-icon');
      const card = header.closest('.server-card');
      header.addEventListener('click', function () {
        card.classList.toggle('collapsed');
        if (btn) btn.textContent = card.classList.contains('collapsed') ? '▸' : '▾';
      });
    });
  },

  setupMqttCommandCloud: function () {
    // (keep the existing implementation that copies from primary/secondary into cmd fields)
    // ... (the function remains the same as in your original file, unchanged) ...
    const primaryEnable = document.getElementById('primaryEnableMqttCmd');
    const mqttCard = document.getElementById('mqttCommandCloudCard');

    // command-cloud fields (IDs must match your HTML)
    const cmdHost = document.getElementById('cmdMqttHost');
    const cmdPort = document.getElementById('cmdMqttPort');
    const cmdAuthMode = document.getElementById('cmdMqttAuthMode');
    const cmdAuthFields = document.getElementById('cmdMqttAuthFields');
    const cmdCertArea = document.getElementById('cmdMqttCertArea');
    const cmdCertName = document.getElementById('cmdCertName'); // span
    const cmdUser = document.getElementById('cmdMqttUser');
    const cmdPass = document.getElementById('cmdMqttPass');
    const cmdEnableClientId = document.getElementById('cmdEnableClientId');
    const cmdClientIdField = document.getElementById('cmdClientIdField');
    const cmdClientId = document.getElementById('cmdClientId');
    const cmdEnableSubscribe = document.getElementById('cmdEnableSubscribeTopic');
    const cmdSubscribeSection = document.getElementById('cmdSubscribeSection');
    const cmdSubscribeQos = document.getElementById('cmdSubscribeQos');
    const cmdReq = document.getElementById('cmdCommandRequest');
    const cmdRes = document.getElementById('cmdCommandResponse');

    function refreshVisibility() {
      const primaryEnable = document.getElementById('primaryEnableMqttCmd');
      const mqttCard = document.getElementById('mqttCommandCloudCard');
      if (!mqttCard) return;
      mqttCard.style.display = (primaryEnable && primaryEnable.checked) ? 'block' : 'none';
    }
    document.getElementById('primaryEnableMqttCmd')?.addEventListener('change', refreshVisibility);
    refreshVisibility();


    function fillCmdMqttFrom(prefix) {
      if (!prefix) return;
      function s(id) { return document.getElementById(prefix + id); }

      function copyVal(srcEl, destEl) {
        if (!destEl) return;
        if (!srcEl) {
          if (destEl.tagName === 'SPAN') destEl.textContent = 'No file chosen';
          else destEl.value = '';
          destEl.dispatchEvent(new Event('change'));
          return;
        }
        if (destEl.tagName === 'SPAN') {
          destEl.textContent = srcEl.textContent || srcEl.value || '';
        } else if (srcEl.tagName === 'SELECT') {
          destEl.value = srcEl.value || '';
          destEl.dispatchEvent(new Event('change'));
        } else {
          destEl.value = srcEl.value || '';
          destEl.dispatchEvent(new Event('input'));
          destEl.dispatchEvent(new Event('change'));
        }
      }

      const mapping = [
        { serverId: 'MqttHost', destEl: cmdHost },
        { serverId: 'MqttPort', destEl: cmdPort },
        { serverId: 'MqttAuthMode', destEl: cmdAuthMode },
        { serverId: 'MqttUser', destEl: cmdUser },
        { serverId: 'MqttPass', destEl: cmdPass },
        { serverId: 'CertName', destEl: cmdCertName },
        { serverId: 'ClientId', destEl: cmdClientId },
        { serverId: 'SubscribeQos', destEl: cmdSubscribeQos },
        { serverId: 'CommandRequest', destEl: cmdReq },
        { serverId: 'CommandResponse', destEl: cmdRes }
      ];

      mapping.forEach(function (m) {
        const src = s(m.serverId);
        copyVal(src, m.destEl);
      });

      const sEnableClient = s('EnableClientId');
      if (sEnableClient && cmdEnableClientId) {
        cmdEnableClientId.checked = !!sEnableClient.checked;
        cmdEnableClientId.dispatchEvent(new Event('change'));
      }

      const sEnableSub = s('EnableSubscribeTopic');
      if (sEnableSub && cmdEnableSubscribe) {
        cmdEnableSubscribe.checked = !!sEnableSub.checked;
        cmdEnableSubscribe.dispatchEvent(new Event('change'));
      }

      if (cmdAuthMode) cmdAuthMode.dispatchEvent(new Event('change'));
    }

    const btnLoadPrimary = document.getElementById('loadPrimaryMqtt');
    const btnLoadSecondary = document.getElementById('loadSecondaryMqtt');
    if (btnLoadPrimary) btnLoadPrimary.addEventListener('click', function () { fillCmdMqttFrom('primary'); });
    if (btnLoadSecondary) btnLoadSecondary.addEventListener('click', function () { fillCmdMqttFrom('secondary'); });

    function wireCmdAuthAndToggles() {
      if (cmdAuthMode) {
        cmdAuthMode.addEventListener('change', function () {
          const mode = cmdAuthMode.value;
          if (cmdAuthFields) cmdAuthFields.style.display = ['1', '2', '4'].includes(mode) ? 'block' : 'none';
          if (cmdCertArea) cmdCertArea.style.display = ['1', '0', '4'].includes(mode) ? 'flex' : 'none';
        });
      }
      if (cmdEnableClientId && cmdClientIdField) {
        cmdEnableClientId.addEventListener('change', function () {
          cmdClientIdField.style.display = cmdEnableClientId.checked ? 'flex' : 'none';
        });
      }
      if (cmdEnableSubscribe && cmdSubscribeSection) {
        cmdEnableSubscribe.addEventListener('change', function () {
          cmdSubscribeSection.style.display = cmdEnableSubscribe.checked ? 'block' : 'none';
        });
      }

      if (cmdAuthMode) cmdAuthMode.dispatchEvent(new Event('change'));
      if (cmdEnableClientId) cmdEnableClientId.dispatchEvent(new Event('change'));
      if (cmdEnableSubscribe) cmdEnableSubscribe.dispatchEvent(new Event('change'));
    }
    wireCmdAuthAndToggles();

    // file upload UI for command-cloud (keep same approach)
    (function setupCmdUploads() {
      // Use the existing Primary upload flow instead of a separate hidden file input.
      const primUploadBtn = document.getElementById('cmdCertUploadBtn');
      const primDeleteBtn = document.getElementById('cmdCertDeleteBtn');
      const primNameSpan = document.getElementById('cmdCertName');

      // When user clicks Command-Cloud Upload -> trigger Primary upload flow
      if (primUploadBtn) {
        primUploadBtn.addEventListener('click', function (ev) {
          ev && ev.preventDefault && ev.preventDefault();
          // If primary has certificate upload handler, call it (this will open the same popup)
          try {
            if (typeof window.self !== 'undefined' && typeof self.handleArchiveUpload === 'function') {
              // If code's context has self, call it; otherwise fallback to clicking primary button
              self.handleArchiveUpload();
              return;
            }
          } catch (e) {
            // ignore and fallback
          }
          // fallback: trigger the existing primary upload button (same popup)
          const primaryBtn = document.getElementById('btn_upload1');
          if (primaryBtn) primaryBtn.click();
        });
      }

      // When user clicks Command-Cloud Delete -> trigger Primary Delete button click
      // (this reuses the same POST/delete behavior already implemented for primary)
      if (primDeleteBtn) {
        primDeleteBtn.addEventListener('click', function (ev) {
          ev && ev.preventDefault && ev.preventDefault();
          // Simply delegate to the primary delete button's existing handler so POST payload is correct
          const primaryDeleteBtn = document.getElementById('btn_delete1');
          if (primaryDeleteBtn) primaryDeleteBtn.click();
          else {
            // As a last-resort UX fallback, clear UI locally
            if (primNameSpan) primNameSpan.textContent = 'No file chosen';
          }
        });
      }

      // Keep the visual update for cmd span when user picks a local file via other flows:
      // (we'll update this span after a successful upload in handleArchiveVerify — see step 3)
    })();

  }, // end setupMqttCommandCloud

  // --- Fetch config from server and populate the UI ---
  fetchConfig: async function (url = ':30005/Cloud_Sender_Configuration/') {
    // fetchConfig: async function (url = 'https://mocki.io/v1/18e7c120-df64-433d-9e2a-5216656b2cba') {
    try {
      L.ui.loading(true);
      let params = window.location.href;
      let BaseURL = new URL(params).origin;
      const res = await fetch(`${BaseURL}${url}`);
      // const res = await fetch(`${url}`);
      const data = await res.json();
      // Top-level
      if (document.getElementById('siteId')) document.getElementById('siteId').value = data.SiteID || '';
      if (document.getElementById('serverSelect')) document.getElementById('serverSelect').value = data.server || 'primary';
      //if (document.getElementById('enablePerSlave')) document.getElementById('enablePerSlave').checked = (data.slaveDataSending === '1');

      // --- Primary ---
      const p = data.primaryserver || {};
      if (document.getElementById('primaryProtocol')) document.getElementById('primaryProtocol').value = p.cloudprotocol || 'http';
      if (document.getElementById('primaryHttpUrl')) document.getElementById('primaryHttpUrl').value = p.HTTPServerURL || '';
      if (document.getElementById('primaryHttpPort')) document.getElementById('primaryHttpPort').value = p.HTTPServerPort || '';

      if (document.getElementById('primaryContentType')) document.getElementById('primaryContentType').value = p.contentType || 'application/json';
      document.getElementById('primaryContentType')?.dispatchEvent(new Event('change'));
      if (document.getElementById('primaryCustomContentType')) document.getElementById('primaryCustomContentType').value = p.customContentType || '';
      // HTTP auth select (0/1/2)
      if (document.getElementById('primaryAuth')) document.getElementById('primaryAuth').value = p.httpauthenable || '0';
      // trigger change so static auth fields appear/hide
      document.getElementById('primaryAuth')?.dispatchEvent(new Event('change'));

      // populate static auth fields (they exist in DOM now)
      if (document.getElementById('primaryUsername')) document.getElementById('primaryUsername').value = p.username || '';
      if (document.getElementById('primaryPassword')) document.getElementById('primaryPassword').value = p.password || '';
      if (document.getElementById('primaryBearerToken')) document.getElementById('primaryBearerToken').value = p.entertoken || '';

      if (document.getElementById('primaryEnableServerResp')) document.getElementById('primaryEnableServerResp').checked = Number(p.serverresponsevalidationenable) === 1;
      document.getElementById('primaryEnableServerResp')?.dispatchEvent(new Event('change'));
      if (document.getElementById('primaryServerResp')) document.getElementById('primaryServerResp').value = p.serverresponsestring || 'recordId';
      document.getElementById('primaryServerResp')?.dispatchEvent(new Event('change'));
      if (document.getElementById('primaryCustomServerResp')) document.getElementById('primaryCustomServerResp').value = p.servercustomresponsestring || '';

      if (document.getElementById('primaryMethod')) document.getElementById('primaryMethod').value = p.HTTPMethod || '0';
      // enable mqtt cmd checkbox (primary)
      if (document.getElementById('primaryEnableMqttCmd')) {
        document.getElementById('primaryEnableMqttCmd').checked = Number(p.EnableMQTTCommand === 1);
        document.getElementById('primaryEnableMqttCmd').dispatchEvent(new Event('change'));
      }

      // Primary MQTT (populate fields)
      if (document.getElementById('primaryMqttHost')) document.getElementById('primaryMqttHost').value = p.host || '';
      if (document.getElementById('primaryMqttPort')) document.getElementById('primaryMqttPort').value = p.mqttport || '';
      if (document.getElementById('primaryMqttAuthMode')) {
        document.getElementById('primaryMqttAuthMode').value = p.mqttauthmode ?? '3';
        document.getElementById('primaryMqttAuthMode').dispatchEvent(new Event('change'));
      }
      if (document.getElementById('primaryMqttUser')) document.getElementById('primaryMqttUser').value = p.mqttusername || '';
      if (document.getElementById('primaryMqttPass')) document.getElementById('primaryMqttPass').value = p.mqttpassword || '';

      if (document.getElementById('primaryEnableSubscribeTopic')) document.getElementById('primaryEnableSubscribeTopic').checked = Number(p.enable_subcribe_topic === 1);
      if (document.getElementById('primaryEnableClientId')) document.getElementById('primaryEnableClientId').checked = Number(p.enable_clientID === 1);
      if (document.getElementById('primaryClientId')) document.getElementById('primaryClientId').value = p.ClientID || '';
      if (document.getElementById('primarySubscribeQos')) document.getElementById('primarySubscribeQos').value = p.subqos ?? '2';
      if (document.getElementById('primaryPublishQos')) document.getElementById('primaryPublishQos').value = p.qos ?? '2';

      if (document.getElementById('primaryCommandRequest')) document.getElementById('primaryCommandRequest').value = p.commandrequesttopic || '';
      if (document.getElementById('primaryCommandResponse')) document.getElementById('primaryCommandResponse').value = p.commandresponsetopic || '';

      // topics (populate static topic fields)
      if (document.getElementById('primaryModbusTopic')) document.getElementById('primaryModbusTopic').value = p.rs485topic || '';
      if (document.getElementById('primaryRs232Topic')) document.getElementById('primaryRs232Topic').value = p.rs232topic || '';
      if (document.getElementById('primaryAioTopic')) document.getElementById('primaryAioTopic').value = p.aiotopic || '';
      if (document.getElementById('primaryDioTopic')) document.getElementById('primaryDioTopic').value = p.diotopic || '';
      // if (document.getElementById('primaryCustomTopic')) document.getElementById('primaryCustomTopic').value = p.customtopic || '';

      // enable publish over lan
      if (document.getElementById('primaryEnablePublishOverLan')) document.getElementById('primaryEnablePublishOverLan').checked = (p.enablepublishoverlan === '1');

      // --- Command Cloud (cmd fields) - fill if present in primary payload ---
      if (document.getElementById('cmdMqttHost')) document.getElementById('cmdMqttHost').value = p.host || '';
      if (document.getElementById('cmdMqttPort')) document.getElementById('cmdMqttPort').value = p.mqttport || '';
      if (document.getElementById('cmdMqttAuthMode')) document.getElementById('cmdMqttAuthMode').value = p.mqttauthmode || '3';
      document.getElementById('cmdMqttAuthMode')?.dispatchEvent(new Event('change'));
      if (document.getElementById('cmdMqttUser')) document.getElementById('cmdMqttUser').value = p.mqttusername || '';
      if (document.getElementById('cmdMqttPass')) document.getElementById('cmdMqttPass').value = p.mqttpassword || '';
      if (document.getElementById('cmdEnableSubscribeTopic')) document.getElementById('cmdEnableSubscribeTopic').checked = Number(p.enable_subcribe_topic === 1);
      if (document.getElementById('cmdEnableClientId')) document.getElementById('cmdEnableClientId').checked = Number(p.enable_clientID === 1);
      if (document.getElementById('cmdClientId')) document.getElementById('cmdClientId').value = p.ClientID || '';
      if (document.getElementById('cmdSubscribeQos')) document.getElementById('cmdSubscribeQos').value = p.subqos ?? '2';
      if (document.getElementById('cmdPublishQos')) document.getElementById('cmdPublishQos').value = p.qos ?? '2';
      if (document.getElementById('cmdCommandRequest')) document.getElementById('cmdCommandRequest').value = p.commandrequesttopic || '';
      if (document.getElementById('cmdCommandResponse')) document.getElementById('cmdCommandResponse').value = p.commandresponsetopic || '';

      // --- Secondary ---
      const s = data.secondaryserver || {};
      if (document.getElementById('secondaryProtocol')) document.getElementById('secondaryProtocol').value = s.cloudprotocol2 || 'http';
      if (document.getElementById('secondaryHttpUrl')) document.getElementById('secondaryHttpUrl').value = s.HTTPServerURL2 || '';
      if (document.getElementById('secondaryHttpPort')) document.getElementById('secondaryHttpPort').value = s.HTTPServerPort2 || '';
      if (document.getElementById('secondaryContentType')) document.getElementById('secondaryContentType').value = s.contentType2 || 'application/json';

      if (document.getElementById('secondaryCustomContentType')) document.getElementById('secondaryCustomContentType').value = s.customContentType2 || '';

      document.getElementById('secondaryContentType')?.dispatchEvent(new Event('change'));

      if (document.getElementById('secondaryAuth')) document.getElementById('secondaryAuth').value = s.httpauthenable2 || '0';
      document.getElementById('secondaryAuth')?.dispatchEvent(new Event('change'));
      if (document.getElementById('secondaryUsername')) document.getElementById('secondaryUsername').value = s.username2 || '';
      if (document.getElementById('secondaryPassword')) document.getElementById('secondaryPassword').value = s.password2 || '';
      if (document.getElementById('secondaryBearerToken')) document.getElementById('secondaryBearerToken').value = s.entertoken2 || '';

      if (document.getElementById('secondaryEnableServerResp')) document.getElementById('secondaryEnableServerResp').checked = Number(s.serverresponsevalidationenable2 === 1);

      if (document.getElementById('secondaryServerResp')) document.getElementById('secondaryServerResp').value = s.serverresponsestring2 || 'recordId';
      document.getElementById('secondaryEnableServerResp')?.dispatchEvent(new Event('change'));
      document.getElementById('secondaryServerResp')?.dispatchEvent(new Event('change'));
      if (document.getElementById('secondaryCustomServerResp')) document.getElementById('secondaryCustomServerResp').value = s.servercustomresponsestring2 || '';
      if (document.getElementById('secondaryMethod')) document.getElementById('secondaryMethod').value = s.HTTPMethod2 || '0';

      // secondary mqtt population
      if (document.getElementById('secondaryMqttHost')) document.getElementById('secondaryMqttHost').value = s.host2 || '';
      if (document.getElementById('secondaryMqttPort')) document.getElementById('secondaryMqttPort').value = s.mqttport2 || '';
      if (document.getElementById('secondaryMqttAuthMode')) {
        document.getElementById('secondaryMqttAuthMode').value = s.mqttauthmode2 ?? '3';
        document.getElementById('secondaryMqttAuthMode').dispatchEvent(new Event('change'));
      }
      if (document.getElementById('secondaryMqttUser')) document.getElementById('secondaryMqttUser').value = s.mqttusername2 || '';
      if (document.getElementById('secondaryMqttPass')) document.getElementById('secondaryMqttPass').value = s.mqttpassword2 || '';

      if (document.getElementById('secondaryEnableSubscribeTopic')) document.getElementById('secondaryEnableSubscribeTopic').checked = Number(s.enable_subcribe_topic_1 === 1);
      if (document.getElementById('secondaryEnableClientId')) document.getElementById('secondaryEnableClientId').checked = Number(s.enable_clientID_1 === 1);
      if (document.getElementById('secondaryClientId')) document.getElementById('secondaryClientId').value = s.ClientID_1 || '';
      if (document.getElementById('secondaryPublishQos')) document.getElementById('secondaryPublishQos').value = s.qos2 ?? '2';
      if (document.getElementById('secondarySubscribeQos')) document.getElementById('secondarySubscribeQos').value = s.subqos2 ?? '2';


      // secondary topics
      if (document.getElementById('secondaryModbusTopic')) document.getElementById('secondaryModbusTopic').value = s.rs485topic2 || '';
      if (document.getElementById('secondaryRs232Topic')) document.getElementById('secondaryRs232Topic').value = s.rs232topic2 || '';
      if (document.getElementById('secondaryAioTopic')) document.getElementById('secondaryAioTopic').value = s.aiotopic2 || '';
      if (document.getElementById('secondaryDioTopic')) document.getElementById('secondaryDioTopic').value = s.diotopic2 || '';
      //if (document.getElementById('secondaryCustomTopic')) document.getElementById('secondaryCustomTopic').value = s.customtopic2 || '';
      if (document.getElementById('secondaryCommandRequest')) document.getElementById('secondaryCommandRequest').value = s.commandrequesttopic2 || '';
      if (document.getElementById('secondaryCommandResponse')) document.getElementById('secondaryCommandResponse').value = s.commandresponsetopic2 || '';

      if (document.getElementById('secondaryEnablePublishOverLan')) document.getElementById('secondaryEnablePublishOverLan').checked = (s.enablepublishoverlan2 === '1');

      // ensure dynamically dependent listeners see updated values
      const triggers = [
        'serverSelect',
        'primaryProtocol', 'secondaryProtocol',
        'primaryContentType', 'secondaryContentType', 'primaryCustomContentType', 'secondaryCustomContentType',
        'primaryAuth', 'secondaryAuth', 'primaryServerResp',
        'primaryMqttAuthMode', 'secondaryMqttAuthMode',
        'primaryEnableClientId', 'secondaryEnableClientId',
        'primaryEnableSubscribeTopic', 'secondaryEnableSubscribeTopic',
        'primaryEnableServerResp', 'secondaryEnableServerResp',
        'primaryEnableMqttCmd', 'cmdMqttAuthMode', 'cmdEnableClientId', 'cmdEnableSubscribeTopic'
      ];
      triggers.forEach(function (id) {
        const el = document.getElementById(id);
        if (el) {
          el.dispatchEvent(new Event('change'));
          if (el.type === 'checkbox') el.dispatchEvent(new Event('input'));
        }
      });

      const inputIds = [
        'siteId', 'primaryHttpUrl', 'primaryHttpPort', 'secondaryHttpUrl', 'secondaryHttpPort',
        'primaryMqttHost', 'primaryMqttPort', 'secondaryMqttHost', 'secondaryMqttPort',
        'cmdMqttHost', 'cmdMqttPort', 'primaryClientId', 'secondaryClientId', 'cmdClientId',
        'primaryCommandRequest', 'primaryCommandResponse', 'secondaryCommandRequest', 'secondaryCommandResponse',
        'cmdCommandRequest', 'cmdCommandResponse', 'primaryCustomContentType', 'secondaryCustomContentType',
        'primaryBearerToken', 'secondaryBearerToken', 'primaryUsername', 'primaryPassword', 'secondaryUsername', 'secondaryPassword'
      ];
      inputIds.forEach(id => {
        const el = document.getElementById(id);
        if (el) {
          el.dispatchEvent(new Event('input'));
          el.dispatchEvent(new Event('change'));
        }
      });

    } catch (e) {
      console.error('fetchConfig error', e);
      L.ui.loading(false);
    }
  },

  // --- Build payload and POST on Save ---

  saveConfig: async function (postUrl = ':30005/Sender_Post/') {
    // saveConfig: async function (postUrl = 'https://cors-anywhere.herokuapp.com/https://webhook.site/87efc33d-b080-44a1-a100-e38a76232f71') {
    try {
      L.ui.loading(true);
      const val = (id) => {
        const el = document.getElementById(id);
        if (!el) return '';
        if (el.type === 'checkbox') return el.checked ? '1' : '0';
        return el.value ?? '';
      };

      const primaryProtocol = document.getElementById('primaryProtocol') ? document.getElementById('primaryProtocol').value : 'http';
      const primaryEnableMqttCmd = document.getElementById('primaryEnableMqttCmd') ? document.getElementById('primaryEnableMqttCmd').checked : false;
      //const useCmdCloudForPrimaryMqtt = (primaryProtocol === 'http' && primaryEnableMqttCmd === true);
      const useCmdCloudForPrimaryMqtt =
        ((primaryProtocol === 'http' || primaryProtocol === 'https')
          && primaryEnableMqttCmd === true);

      const pick = (primaryId, cmdId) => {
        if (useCmdCloudForPrimaryMqtt && cmdId) {
          return val(cmdId) || '';
        }
        return val(primaryId) || '';
      };

      const payload = {
        SiteID: val('siteId'),
        server: val('serverSelect'),
        primaryserver: {
          cloudprotocol: primaryProtocol,
          HTTPServerURL: val('primaryHttpUrl'),
          HTTPServerPort: val('primaryHttpPort'),
          contentType: val('primaryContentType'),
          customContentType: val('primaryCustomContentType'),
          httpauthenable: val('primaryAuth'),
          entertoken: document.getElementById('primaryBearerToken') ? document.getElementById('primaryBearerToken').value : '',
          username: document.getElementById('primaryUsername') ? document.getElementById('primaryUsername').value : '',
          password: document.getElementById('primaryPassword') ? document.getElementById('primaryPassword').value : '',
          serverresponsevalidationenable: val('primaryEnableServerResp'),
          serverresponsestring: val('primaryServerResp'),
          servercustomresponsestring: val('primaryCustomServerResp'),
          HTTPMethod: val('primaryMethod'),
          EnableMQTTCommand: val('primaryEnableMqttCmd'),

          // MQTT fields: pick from cmd if override active
          host: pick('primaryMqttHost', 'cmdMqttHost'),
          mqttport: pick('primaryMqttPort', 'cmdMqttPort'),
          enable_subcribe_topic: (useCmdCloudForPrimaryMqtt ? val('cmdEnableSubscribeTopic') : val('primaryEnableSubscribeTopic')),
          enable_clientID: (useCmdCloudForPrimaryMqtt ? val('cmdEnableClientId') : val('primaryEnableClientId')),
          ClientID: pick('primaryClientId', 'cmdClientId'),
          subqos: (useCmdCloudForPrimaryMqtt ? val('cmdSubscribeQos') : val('primarySubscribeQos')),
          qos: (useCmdCloudForPrimaryMqtt ? val('cmdPublishQos') : val('primaryPublishQos')),
          mqttauthmode: (useCmdCloudForPrimaryMqtt ? val('cmdMqttAuthMode') : val('primaryMqttAuthMode')),
          mqttusername: (useCmdCloudForPrimaryMqtt ? val('cmdMqttUser') : val('primaryMqttUser')),
          mqttpassword: (useCmdCloudForPrimaryMqtt ? val('cmdMqttPass') : val('primaryMqttPass')),
          commandrequesttopic: pick('primaryCommandRequest', 'cmdCommandRequest'),
          commandresponsetopic: pick('primaryCommandResponse', 'cmdCommandResponse'),

          // publish topics & other topics from primary card
          enablepublishoverlan: val('primaryEnablePublishOverLan') || '',
          rs485topic: val('primaryModbusTopic') || '',
          rs232topic: val('primaryRs232Topic') || '',
          aiotopic: val('primaryAioTopic') || '',
          diotopic: val('primaryDioTopic') || '',
          //customtopic: val('primaryCustomTopic') || ''
        },
        secondaryserver: {
          cloudprotocol2: val('secondaryProtocol'),
          HTTPServerURL2: val('secondaryHttpUrl'),
          HTTPServerPort2: val('secondaryHttpPort'),
          contentType2: val('secondaryContentType'),
          customContentType2: val('secondaryCustomContentType'),
          httpauthenable2: val('secondaryAuth'),
          entertoken2: document.getElementById('secondaryBearerToken') ? document.getElementById('secondaryBearerToken').value : '',
          username2: document.getElementById('secondaryUsername') ? document.getElementById('secondaryUsername').value : '',
          password2: document.getElementById('secondaryPassword') ? document.getElementById('secondaryPassword').value : '',
          serverresponsevalidationenable2: val('secondaryEnableServerResp'),
          serverresponsestring2: val('secondaryServerResp'),
          servercustomresponsestring2: val('secondaryCustomServerResp'),
          //serverresponsestring2: (document.getElementById('secondaryServerResp') ? document.getElementById('secondaryServerResp').value : ''),
          HTTPMethod2: val('secondaryMethod'),
          EnableMQTTCommand2: val('secondaryEnableMqttCmd') || '0',
          host2: val('secondaryMqttHost'),
          mqttport2: val('secondaryMqttPort'),
          enable_subcribe_topic_1: val('secondaryEnableSubscribeTopic'),
          enable_clientID_1: val('secondaryEnableClientId'),
          ClientID_1: val('secondaryClientId'),
          subqos2: val('secondarySubscribeQos'),
          qos2: val('secondaryPublishQos'),
          mqttauthmode2: val('secondaryMqttAuthMode'),
          mqttusername2: val('secondaryMqttUser'),
          mqttpassword2: val('secondaryMqttPass'),
          commandrequesttopic2: val('secondaryCommandRequest'),
          commandresponsetopic2: val('secondaryCommandResponse'),
          enablepublishoverlan2: val('secondaryEnablePublishOverLan') || '',
          rs485topic2: val('secondaryModbusTopic') || '',
          rs232topic2: val('secondaryRs232Topic') || '',
          aiotopic2: val('secondaryAioTopic') || '',
          diotopic2: val('secondaryDioTopic') || '',
          // customtopic2: val('secondaryCustomTopic') || ''
        }
      };
      let params = window.location.href;
      let BaseURL = new URL(params).origin;
      const response = await fetch(`${BaseURL}${postUrl}`, {
        // const response = await fetch(`${postUrl}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload)
      });

      if (!response.ok) throw new Error('Failed to save configuration: ' + response.status);

      let respJson = {};
      try { respJson = await response.json(); } catch (e) { /* ignore */ }
      L.ui.showAlert("success", "Saved", "Configuration saved successfully !");
      L.ui.loading(false);
      //  reload after short delay
      setTimeout(() => {
        location.reload();
      }, 1000);


    } catch (e) {
      console.error('saveConfig error', e);
      L.ui.loading(false);
      L.ui.showAlert("error", "Failed", "Failed to save configuration!");
    }
  },

  initPasswordToggles: function () {
    // Select all password inputs (e.g., primaryPassword, secondaryPassword, mqtt passwords)
    document.querySelectorAll("input[type='password']").forEach(input => {
      // Avoid adding duplicate toggle
      if (input.parentElement.classList.contains("password-wrapper")) return;

      // Create wrapper div
      const wrapper = document.createElement("div");
      wrapper.className = "password-wrapper";
      wrapper.style.position = "relative";
      wrapper.style.display = "flex";
      wrapper.style.alignItems = "center";

      // Insert wrapper before the input, then move input inside
      input.parentNode.insertBefore(wrapper, input);
      wrapper.appendChild(input);

      // Create the toggle icon
      const toggle = document.createElement("span");
      toggle.className = "toggle-password";
      toggle.innerHTML = "&#128065;"; // Unicode eye symbol
      toggle.style.cursor = "pointer";
      toggle.style.position = "absolute";
      toggle.style.right = "10px";
      toggle.style.color = "#666";
      toggle.style.userSelect = "none";

      // Append toggle to wrapper
      wrapper.appendChild(toggle);

      // Toggle password visibility
      toggle.addEventListener("click", () => {
        const showing = input.type === "text";
        input.type = showing ? "password" : "text";
        toggle.style.color = showing ? "#666" : "#000";
      });
    });
  },

  // --- Certificate delete handlers ---
  // Place this immediately after the #btn_upload1 / #btn_upload2 bindings inside execute()
  wireCertificateDeletes: function () {
    const primaryPayload = {
      deleteCertificate: 'primary',
      path: '/root/SenderAppComponent/etc/certs/'
    };
    const secondaryPayload = {
      deleteCertificate: 'secondary',
      path: '/root/SenderAppComponent/etc/certs2/'
    };

    // change to your real endpoint if different
    const deleteUrl = 'https://cors-anywhere.herokuapp.com/https://webhook.site/3cb26b3a-8e29-4be7-b2e5-0fd72e99359f';

    function handleDelete(payload, label) {
      return async function (ev) {
        ev && ev.preventDefault && ev.preventDefault();

        if (!confirm(`Are you sure you want to delete the ${label} certificate?`)) return;

        L.ui.loading(true);

        try {
          const res = await fetch(deleteUrl, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(payload)
          });

          if (!res.ok) {
            const txt = await res.text().catch(() => res.statusText || '');
            throw new Error(`Server error ${res.status}: ${txt}`);
          }

          // Try to read response text for logging only — don't rely on it for UI
          let respText = null;
          try {
            const text = await res.text();
            if (text && text.trim().length) respText = text;
          } catch (e) {
            respText = null;
          }

          // Simple success popup (no {"ok":true} shown)
          L.ui.dialog(
            L.tr('Delete Certificate'),
            [
              $('<p />').text(L.tr('Deleted successfully.'))
            ],
            {
              style: 'close',
              close: function () {
                try {
                  // if primary was deleted, clear cmd UI too
                  if (label === 'primary') {
                    if (document.getElementById('cmdCertName')) document.getElementById('cmdCertName').textContent = 'No file chosen';
                  }
                } catch (e) { console.error('clear cmdCertName error', e); }
                // refresh UI (same pattern used elsewhere in your file)
                location.reload();
              }
            }
          );

          // optional: log server response for debugging without showing to users
          if (respText) console.info('delete response:', respText);

        } catch (err) {
          console.error('delete certificate error', err);
          L.ui.dialog(
            L.tr('Delete Error'),
            [
              $('<p />').text(L.tr('Failed to delete certificate:') + ' ' + (err.message || err.toString()))
            ],
            { style: 'close' }
          );
        } finally {
          L.ui.loading(false);
        }
      };
    }

    // Primary delete button (id exists in your HTML)
    // $('#btn_delete1').off('click').on('click', handleDelete(primaryPayload, 'primary'));

    // // Secondary delete button
    // $('#btn_delete2').off('click').on('click', handleDelete(secondaryPayload, 'secondary'));
  },

  getApplicationsStatus: async function () {
    let BaseURL = new URL(window.location.href).origin;
    try {
      const res = await fetch(`${BaseURL}:30005/device/applications/`);
      const data = await res.json();

      // convert array to flags based on state === 'running'
      this.appFlags = {};
      data.forEach(function (app) {
        this.appFlags[app.id] = app.state === 'running' ? 1 : 0;
      }.bind(this));

    } catch (err) {
      console.warn('Applications API failed – showing all topic fields', err);
      this.appFlags = {
        modbus: 1,
        rs232: 1,
        aio: 1,
        dio: 1
      };
    }
    return this.appFlags;
  },


  //getApplicationsStatus: async function () {
  //let BaseURL = new URL(window.location.href).origin;

  //// ===== MOCK: change to false when deploying to device =====
  //const MOCK = true;
  //if (MOCK) {
  //const mockData = [
  //{ id: 'aio', state: 'disabled' },
  //{ id: 'dio', state: 'disabled' },
  //{ id: 'modbus', state: 'running' },
  //{ id: 'rs232', state: 'running' }
  //];
  //this.appFlags = {};
  //mockData.forEach(function (app) {
  //this.appFlags[app.id] = app.state === 'running' ? 1 : 0;
  //}.bind(this));
  //console.log('appFlags (mock):', this.appFlags);
  //return this.appFlags;
  //}
  //// ==========================================================

  //try {
  //const res = await fetch(`${BaseURL}:30005/device/applications/`);
  //const data = await res.json();
  //this.appFlags = {};
  //data.forEach(function (app) {
  //this.appFlags[app.id] = app.state === 'running' ? 1 : 0;
  //}.bind(this));
  //} catch (err) {
  //console.warn('Applications API failed – showing all topic fields', err);
  //this.appFlags = { modbus: 1, rs232: 1, aio: 1, dio: 1 };
  //}
  //return this.appFlags;
  //},

  isAppEnabled: function (key) {
    return Number(this.appFlags?.[key]) === 1;
  },

  applyTopicVisibility: function () {
    var self = this;
    var topicMap = [
      ['modbus', 'primaryModbusTopicField', 'secondaryModbusTopicField'],
      ['rs232', 'primaryRs232TopicField', 'secondaryRs232TopicField'],
      ['aio', 'primaryAioTopicField', 'secondaryAioTopicField'],
      ['dio', 'primaryDioTopicField', 'secondaryDioTopicField']
    ];

    topicMap.forEach(function (entry) {
      var show = self.isAppEnabled(entry[0]);
      var primEl = document.getElementById(entry[1]);
      var secEl = document.getElementById(entry[2]);
      if (primEl) primEl.style.display = show ? '' : 'none';
      if (secEl) secEl.style.display = show ? '' : 'none';
    });

    ['primaryMqttTopicRow1', 'primaryMqttTopicRow2',
      'secondaryMqttTopicRow1', 'secondaryMqttTopicRow2'].forEach(function (rowId) {
        var row = document.getElementById(rowId);
        if (!row) return;
        var anyVisible = Array.from(row.querySelectorAll('.field'))
          .some(function (f) { return f.style.display !== 'none'; });
        row.style.display = anyVisible ? '' : 'none';
      });
  },
  // ---------------- Execute ----------------
  execute: async function () {
    var self = this;
    let BaseURL = new URL(window.location.href).origin;


    // server cards
    this.setupServers();

    // server select toggle
    this.setupServerSelectToggle();

    // collapsibles
    this.setupCollapsibles();
    self.initPasswordToggles();
    self.wireCertificateDeletes();

    // mqtt command cloud
    this.setupMqttCommandCloud();
    const saveBtn = document.querySelector('.save');
    if (saveBtn) {
      saveBtn.addEventListener('click', (ev) => {
        ev.preventDefault();
        this.saveConfig();
      });
    }

    // fetch config and wait for it to populate before firing triggers
    await this.fetchConfig();
    await this.getApplicationsStatus();
    this.applyTopicVisibility();
    // trigger change events to correctly initialize dynamic fields AFTER fetchConfig completes
    const triggers = [
      'serverSelect',
      'primaryProtocol', 'secondaryProtocol',
      'primaryContentType', 'secondaryContentType',
      'primaryAuth', 'secondaryAuth', 'primaryServerResp',
      'primaryMqttAuthMode', 'secondaryMqttAuthMode',
      'primaryEnableClientId', 'secondaryEnableClientId',
      'primaryEnableSubscribeTopic', 'secondaryEnableSubscribeTopic',
      'primaryEnableServerResp', 'secondaryEnableServerResp',
      'primaryEnableMqttCmd', 'cmdMqttAuthMode', 'cmdEnableClientId', 'cmdEnableSubscribeTopic'
    ];
    triggers.forEach(function (id) {
      const el = document.getElementById(id);
      if (el) {
        el.dispatchEvent(new Event('change'));
        if (el.type === 'checkbox') el.dispatchEvent(new Event('input'));
      }
    });

    // dispatch input events for text fields set by fetch
    const inputIds = [
      'siteId', 'primaryHttpUrl', 'primaryHttpPort', 'secondaryHttpUrl', 'secondaryHttpPort',
      'primaryMqttHost', 'primaryMqttPort', 'secondaryMqttHost', 'secondaryMqttPort',
      'cmdMqttHost', 'cmdMqttPort', 'primaryClientId', 'secondaryClientId', 'cmdClientId',
      'primaryCommandRequest', 'primaryCommandResponse', 'secondaryCommandRequest', 'secondaryCommandResponse',
      'cmdCommandRequest', 'cmdCommandResponse', 'primaryCustomContentType', 'secondaryCustomContentType',
      'primaryBearerToken', 'secondaryBearerToken', 'primaryUsername', 'primaryPassword', 'secondaryUsername', 'secondaryPassword'
    ];
    inputIds.forEach(id => {
      const el = document.getElementById(id);
      if (el) {
        el.dispatchEvent(new Event('input'));
        el.dispatchEvent(new Event('change'));
      }
    });

    // update collapsible icons
    document.querySelectorAll('.server-header').forEach(function (header) {
      const btn = header.querySelector('.toggle-icon');
      const card = header.closest('.server-card');
      if (card && btn) btn.textContent = card.classList.contains('collapsed') ? '▸' : '▾';
    });

    $('#btn_upload1').off('click').on('click', function () {
      self.countcertficates('server1').then(function (certCount) {
        console.log("count", certCount)
        if (certCount < 1) {
          // No certificates, allow upload
          self.handleArchiveUpload();
        } else {
          // Show error: certificates already exist
          L.ui.loading(false);
          L.ui.dialog(
            L.tr('Upload Certificates Error'), [
            $('<p />').text(L.tr('Output')),
            $('<pre />')
              .addClass('alert alert-danger')
              .text("Please click on Delete button to delete existing files and then click on upload button")
          ],
            {
              style: 'close',
              close: function () {
                location.reload();
              }
            }
          );
        }
      });
    });


    $('#btn_upload2').off('click').on('click', function () {
      self.countcertficates('server2').then(function (certCount) {
        if (certCount < '1') {

          // Directly call the upload function (no need to re-bind the click)
          self.handleArchiveUpload1();

        } else {
          L.ui.loading(false);
          L.ui.dialog(
            L.tr('Upload Certificates Error'), [
            $('<p />').text(L.tr('Output')),
            $('<pre />')
              .addClass('alert alert-danger')
              .text("Please click on Delete button to delete existing files and then click on upload button"),
          ],
            {
              style: 'close',
              close: function () {
                location.reload();
              }
            }
          );
        }
      });
    });

    $('#btn_upload_https1').off('click').on('click', function () {
      // allow only when protocol is HTTPS
      if (document.getElementById('primaryProtocol')?.value !== 'https') return;

      self.countcertficates('server1').then(function (certCount) {
        console.log("certscount", certCount)
        if (certCount < 1) {
          self.handleArchiveUpload2();
        } else {
          L.ui.loading(false);
          L.ui.dialog(
            L.tr('Upload Certificates Error'), [
            $('<p />').text(L.tr('Output')),
            $('<pre />')
              .addClass('alert alert-danger')
              .text("Please click on Delete button to delete existing files and then click on upload button")
          ],
            {
              style: 'close',
              close: function () {
                location.reload();
              }
            }
          );
        }
      });
    });

    $('#btn_upload_https2').off('click').on('click', function () {
      if (document.getElementById('secondaryProtocol')?.value !== 'https') return;

      self.countcertficates('server2').then(function (certCount) {
        if (certCount < 1) {
          self.handleArchiveUpload3();
        } else {
          L.ui.loading(false);
          L.ui.dialog(
            L.tr('Upload Certificates Error'), [
            $('<p />').text(L.tr('Output')),
            $('<pre />')
              .addClass('alert alert-danger')
              .text("Please click on Delete button to delete existing files and then click on upload button")
          ],
            {
              style: 'close',
              close: function () {
                location.reload();
              }
            }
          );
        }
      });
    });



    $('#btn_delete1').click(function () {
      self.getvalues('server1').then(function (rv) {
        var value = rv;
        if (value === '1') {
          self.deletekeyfile("server1").then(function (rv) {
            //alert(rv);
            L.ui.loading(false);
            L.ui.dialog(
              L.tr('Delete certificates'), [
              $('<p />').text(L.tr('Output')),
              $('<pre />')
                .addClass('alert alert-info')
                .text("certificates Deleted"),
            ],
              {
                style: 'close',
                close: function () {
                  location.reload();
                }
              }
            );
          });
        } else {
          L.ui.dialog(
            L.tr('Delete certificates Error'), [
            $('<p />').text(L.tr('Output')),
            $('<pre />')
              .addClass('alert alert-info')
              .text("No certificates to Delete"),
          ],
            {
              style: 'close',
              close: function () {
                location.reload();
              }
            }
          );
          // alert('Deleted or No Certificate for 1')
        }
      })

    });
    $('#btn_delete2').click(function () {
      self.getvalues('server2').then(function (rv) {
        var value = rv.enabledelete_2
        if (value === '1') {
          self.deletekeyfile("server2").then(function (rv) {
            //alert(rv);
            L.ui.loading(false);
            L.ui.dialog(
              L.tr('Delete certificates'), [
              $('<p />').text(L.tr('Output')),
              $('<pre />')
                .addClass('alert alert-info')
                .text("certificates Deleted"),
            ],
              {
                style: 'close',
                close: function () {
                  location.reload();
                }
              }
            );
          });
        } else {
          L.ui.dialog(
            L.tr('Delete certificates Error'), [
            $('<p />').text(L.tr('Output')),
            $('<pre />')
              .addClass('alert alert-info')
              .text("No certificates to Delete"),
          ],
            {
              style: 'close',
              close: function () {
                location.reload();
              }
            }
          );
        }
      })

    });
    $('#btn_delete_https1').click(function () {
      self.getvalues('server3').then(function (rv) {
        var value = rv;
        if (value === '1') {
          self.deletekeyfile("server1").then(function (rv) {
            //alert(rv);
            L.ui.loading(false);
            L.ui.dialog(
              L.tr('Delete certificates'), [
              $('<p />').text(L.tr('Output')),
              $('<pre />')
                .addClass('alert alert-info')
                .text("certificates Deleted"),
            ],
              {
                style: 'close',
                close: function () {
                  location.reload();
                }
              }
            );
          });
        } else {
          L.ui.dialog(
            L.tr('Delete certificates Error'), [
            $('<p />').text(L.tr('Output')),
            $('<pre />')
              .addClass('alert alert-info')
              .text("No certificates to Delete"),
          ],
            {
              style: 'close',
              close: function () {
                location.reload();
              }
            }
          );
          // alert('Deleted or No Certificate for 1')
        }
      })

    });
    $('#btn_delete_https2').click(function () {
      self.getvalues('server4').then(function (rv) {
        var value = rv;
        if (value === '1') {
          self.deletekeyfile("server2").then(function (rv) {
            //alert(rv);
            L.ui.loading(false);
            L.ui.dialog(
              L.tr('Delete certificates'), [
              $('<p />').text(L.tr('Output')),
              $('<pre />')
                .addClass('alert alert-info')
                .text("certificates Deleted"),
            ],
              {
                style: 'close',
                close: function () {
                  location.reload();
                }
              }
            );
          });
        } else {
          L.ui.dialog(
            L.tr('Delete certificates Error'), [
            $('<p />').text(L.tr('Output')),
            $('<pre />')
              .addClass('alert alert-info')
              .text("No certificates to Delete"),
          ],
            {
              style: 'close',
              close: function () {
                location.reload();
              }
            }
          );
          // alert('Deleted or No Certificate for 1')
        }
      })

    });
  } // end execute
});
