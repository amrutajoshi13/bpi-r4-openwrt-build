L.ui.view.extend({
     
  fGetUCISections: L.rpc.declare({
		object: 'uci',
		method: 'get',
		params: [ 'config', 'type' ],
		expect: { values: {} }
	}),
	
	GetUCISections: L.rpc.declare({
    object: 'uci',
    method: 'get',
    params: ['config', 'type'],
    expect: { values: {} }
  }),
	
	fCreateUCISection:  L.rpc.declare({
		object: 'uci',
		method: 'add',
		params: [ 'config', 'type', 'name', 'values' ]
	}),
	
	drfCreateUCISection:  L.rpc.declare({
		object: 'uci',
		method: 'add',
		params: [ 'config', 'type', 'values' ]
	}),
	
	fDeleteUCISection:  L.rpc.declare({
		object: 'uci',
		method: 'delete',
		params: [ 'config','type','section' ]
	}),
	
	fCommitUCISection:  L.rpc.declare({
		object: 'uci',
		method: 'commit',
		params: [ 'config' ]
	}),

  MiscUtilRunDiagnostic: L.rpc.declare({
    object: 'rpc-diagnosticutilities',
    method: 'run',
    params: ['utility', 'action', 'section', 'usrinputs']
  }),
    
  updateinterfaceconfig: L.rpc.declare({
    object: 'rpc-updatewirelessconfig',
    method: 'configure',
    params: ['application','action'],
    expect: { output: '' }
  }),
 
	wifi_enable_disable:true,

  parseSSIDs: function (output) {
    var self = this;
    var ssids = [];
    var seen = {};
    self._ssidSecurityMap = {};

    var lines = output.split('\n');

    for (var i = 0; i < lines.length; i++) {

      var line = lines[i].trim();

      // Skip junk
      if (!line || line === 'NO' || line.indexOf('get_site_survey') !== -1)
        continue;

      // Skip header
      if (line.startsWith('Ch'))
        continue;

      // Split columns (2+ spaces)
      var cols = line.split(/\s{2,}/);

      if (cols.length < 4)
        continue;

      var ssid = cols[1].trim();
      var security = cols[3].trim();

      // Skip hidden SSID
      if (!ssid)
        continue;

      // Skip BSSID accidentally captured
      if (ssid.indexOf(':') !== -1)
        continue;

      if (!seen[ssid]) {
        seen[ssid] = true;
        ssids.push(ssid);

        self._ssidSecurityMap[ssid] = self.parseSecurity(security);
      }
    }

    return ssids;
  },

  parseSecurity: function (security) {
    var self = this;
    var auth = 'OPEN';
    var enc = 'NONE';

    if (security && security !== 'NONE') {
      var parts = security.split('/');
      auth = parts[0] ? parts[0].trim() : 'OPEN';
      enc = parts[1] ? parts[1].trim() : 'NONE';
    }

    return {
      auth: auth,
      enc: enc
    };
  },
  
  runWifiScan: function () {
    var self = this;

    // L.ui.loading(true);
    L.ui.showAlert(
      'info',
      'SSID Scan Started',
      'Scanning for available Wi-Fi networks…'
    );

    self.MiscUtilRunDiagnostic(
      "Wi-Fi Scan",
      "GET",
      "MiscUtilities4",
      "0"
    ).then(function (res) {
      // var res = 'res'
      // L.ui.loading(false);
      if (!res || !res.output) {
        L.ui.showAlert(
          'error',
          'SSID Scan Failed',
          'Unable to scan for Wi-Fi networks. Please try again.'
        );

        return;
      }

      var ssids = self.parseSSIDs(res.output);

      self.ssidList.choices = [];
      self.ssidList.has_empty = true;

      self.ssidList.value('', L.tr('-- Select SSID --'));

      for (var i = 0; i < ssids.length; i++) {
        self.ssidList.value(ssids[i], ssids[i]);
      }
      self.ssidList.ownerSection.ownerMap.redraw();
      self._scanCompleted = true;
      L.ui.showAlert(
        'success',
        'SSID Scan Completed',
        'Scan completed. Please select an SSID.'
      );

    });
  },
	
  execute:function() {              	
	  var self = this;

    L.ui.createNote(
      'NOTE',
      'After editing or deleting, please click the Update button to apply the saved configuration.',
      { type: 'warn', variant: 'inline', appendTo: '#Update-Note-WiFi' }
    );

    $('#btn_update_wireless').click(function () {
      L.ui.loading(true);
      self.updateinterfaceconfig('Update', 'updateinterface').then(function (rv) {
        L.ui.loading(false);
        L.ui.showAlert("success", "Updated", "WiFi configurations have been successfully updated.");
        setTimeout(function () {
          location.reload();
        }, 1500);
      });
    });

		if (!self.wifi_enable_disable) {
        document.getElementById('sectiontab_wifi').style.display = 'none';
        document.getElementById('sectiontab_guestwifi').style.display = 'none';
        document.getElementById('sectiontab_wireless').style.display = 'none';
		} else if (self.wifi_enable_disable) { 
		    var m2 = new L.cbi.Map('sysconfig', {
				});     
        ///////////////////////////////////// Main Wireless Configuration  ////////////////////////////////////////////
	      var s2 = m2.section(L.cbi.NamedSection, 'wificonfig', {
			    caption:L.tr('Main Wireless Configuration')
		    });
    
       //Wifi Devices
        s2.option(L.cbi.ListValue, 'wifi1protocol', {
		      caption:	L.tr('Radio 0 Protocol'),
		    }).depends({'wificonfig':'1'})
		    .value('none', L.tr('Please choose'))
		    .value('IEEE802.11b/g/n', L.tr('IEEE 802.11 b/g/n'));
      
        s2.option(L.cbi.ListValue, 'CountryCode', {
		      caption:	L.tr('Country Code'),
	    	}).depends({'wificonfig':'1'})
		      .value('none', L.tr('Please choose'))
		      .value('AF', L.tr('Afghanistan'))
          .value('AX', L.tr('Åland Islands'))
          .value('AL', L.tr('ALBANIA'))    
          .value('AS', L.tr('American Samoa'))  
          .value('AD', L.tr('Andorra'))  
          .value('AO', L.tr('Angola'))  
          .value('AI', L.tr('Anguilla')) 
          .value('AQ', L.tr('Antarctica')) 
          .value('AG', L.tr('Antigua and Barbuda')) 
          .value('AR', L.tr('ARGENTINA'))  
          .value('AM', L.tr('ARMENIA'))  
          .value('AW', L.tr('Aruba'))  
          .value('AU', L.tr('AUSTRALIA'))  
          .value('AT', L.tr('AUSTRIA'))  
          .value('AZ', L.tr('AZERBAIJAN'))  
          .value('BH', L.tr('BAHRAIN'))  
          .value('BD', L.tr('Bangladesh'))  
          .value('BB', L.tr('Barbados'))  
          .value('BY', L.tr('BELARUS'))  
          .value('BE', L.tr('BELGIUM'))  
          .value('BZ', L.tr('BELIZE'))  
          .value('BJ', L.tr('Benin'))  
          .value('BM', L.tr('Bermuda'))  
          .value('BT', L.tr('Bhutan'))  
          .value('BO', L.tr('BOLIVIA'))  
          .value('BQ', L.tr('Bonaire'))  
          .value('BQ', L.tr('Sint Eustatius'))  
          .value('BQ', L.tr('Saba'))  
          .value('BA', L.tr('Bosnia and Herzegovina'))  
          .value('BW', L.tr('Botswana'))    
          .value('BV', L.tr('Bouvet Island'))  
          .value('BR', L.tr('BRAZIL'))  
          .value('IO', L.tr('British Indian Ocean Territory'))  
          .value('BN', L.tr('BRUNEI DARUSSALAM'))  
          .value('BG', L.tr('BULGARIA'))  
          .value('BF', L.tr('Burkina Faso'))  
          .value('BI', L.tr('Burundi'))  
          .value('CV', L.tr('Cabo Verde'))  
          .value('KH', L.tr('Cambodia'))  
          .value('CM', L.tr('Cameroon'))  
          .value('CA', L.tr('CANADA'))  
          .value('KY', L.tr('Cayman Islands '))  
          .value('CF', L.tr('Central African Republic'))  
          .value('TD', L.tr('Chad'))  
          .value('CL', L.tr('CHILE'))  
          .value('CN', L.tr('CHINA'))  
          .value('CX', L.tr('Christmas Island'))  
          .value('CC', L.tr('Cocos (Keeling) Islands (the)'))  
          .value('CO', L.tr('COLOMBIA'))  
          .value('KM', L.tr('Comoros'))  
          .value('CD', L.tr('Congo(the Democratic Republic of the)'))  
          .value('CG', L.tr('Congo'))  
          .value('CK', L.tr('Cook Islands'))    
          .value('CR', L.tr('COSTA RICA'))  
          .value('CI', L.tr('Côte dIvoire'))  
          .value('HR', L.tr('CROATIA'))  
          .value('CU', L.tr('Cuba'))  
          .value('CW', L.tr('Curaçao'))  
          .value('CY', L.tr('CYPRUS'))  
          .value('CZ', L.tr('CZECH REPUBLIC'))  
          .value('DK', L.tr('DENMARK'))  
          .value('DJ', L.tr('Djibouti'))  
          .value('DM', L.tr('Dominica'))  
          .value('DO', L.tr('DOMINICAN REPUBLIC'))  
          .value('EC', L.tr('ECUADOR'))  
          .value('EG', L.tr('EGYPT'))  
          .value('SV', L.tr('EL SALVADOR'))  
          .value('GQ', L.tr('Equatorial Guinea'))  
          .value('ER', L.tr('Eritrea'))  
          .value('EE', L.tr('ESTONIA'))  
          .value('ET', L.tr('Ethiopia'))  
          .value('FK', L.tr('Falkland Islands'))  
          .value('FO', L.tr('Faroe Islands'))  
          .value('FJ', L.tr('Fiji'))  
          .value('FI', L.tr('FINLAND'))  
          .value('FR', L.tr('FRANCE'))  
          .value('GF', L.tr('French Guiana'))  
          .value('PF', L.tr('French Polynesia'))  
          .value('TF', L.tr('French Southern Territories'))  
          .value('GA', L.tr('Gabon'))  
          .value('GM', L.tr('Gambia'))  
          .value('GE', L.tr('GEORGIA'))  
          .value('DE', L.tr('GERMANY'))  
          .value('GH', L.tr('Ghana'))  
          .value('GI', L.tr('Gibraltar'))  
          .value('GR', L.tr('GREECE'))  
          .value('GL', L.tr('Greenland'))  
          .value('GD', L.tr('Grenada'))  
          .value('GP', L.tr('Guadeloupe'))  
          .value('GU', L.tr('Guam'))  
          .value('GT', L.tr('GUATEMALA'))  
          .value('GG', L.tr('Guernsey'))  
          .value('GW', L.tr('Guinea-Bissau'))  
          .value('GY', L.tr('Guyana'))  
          .value('HT', L.tr('Haiti'))  
          .value('HM', L.tr('Heard Island and McDonald Islands'))  
          .value('VA', L.tr('Holy See'))  
          .value('HN', L.tr('HONDURAS'))  
          .value('HK', L.tr('HONG KONG'))  
          .value('HU', L.tr('HUNGARY'))  
          .value('IS', L.tr('ICELAND'))  
          .value('IN', L.tr('INDIA'))  
          .value('ID', L.tr('INDONESIA'))  
          .value('IR', L.tr('IRAN'))  
          .value('IQ', L.tr('Iraq'))  
          .value('IE', L.tr('IRELAND'))  
          .value('IL', L.tr('ISRAEL'))  
          .value('IT', L.tr('ITALY'))  
          .value('JM', L.tr('Jamaica'))  
          .value('JP', L.tr('JAPAN'))  
          .value('JE', L.tr('Jersey'))  
          .value('JO', L.tr('JORDAN'))  
          .value('KZ', L.tr('KAZAKHSTAN'))  
          .value('KE', L.tr('Kenya'))  
          .value('KI', L.tr('Kiribati'))  
          .value('KP', L.tr('KOREA DEMOCRATIC'))  
          .value('KR', L.tr('REPUBLIC OF KOREA '))  
          .value('KW', L.tr('KUWAIT'))  
          .value('KG', L.tr('Kyrgyzstan'))  
          .value('LA', L.tr('Lao People Democratic Republic'))  
          .value('LV', L.tr('LATVIA'))  
          .value('LB', L.tr('LEBANON'))  
          .value('LS', L.tr('Lesotho'))  
          .value('LR', L.tr('Liberia'))  
          .value('LY', L.tr('Libya'))  
          .value('LI', L.tr('LIECHTENSTEIN'))  
          .value('LT', L.tr('LITHUANIA'))  
          .value('LU', L.tr('LUXEMBOURG'))  
          .value('MO', L.tr('MACAO'))  
          .value('MK', L.tr('MACEDONIA'))  
          .value('MG', L.tr('Madagascar'))  
          .value('MW', L.tr('Malawi'))  
          .value('MY', L.tr('MALAYSIA'))  
          .value('MV', L.tr('Maldives'))  
          .value('ML', L.tr('Mali'))  
          .value('MT', L.tr('Malta'))  
          .value('MH', L.tr('Marshall Islands'))  
          .value('MQ', L.tr('Martinique'))  
          .value('MR', L.tr('Mauritania'))  
          .value('MU', L.tr('Mauritius'))  
          .value('YT', L.tr('Mayotte'))  
          .value('MX', L.tr('MEXICO'))  
          .value('FM', L.tr('Micronesia'))  
          .value('MD', L.tr('Moldova'))  
          .value('MC', L.tr('MONACO'))  
          .value('MN', L.tr('Mongolia'))  
          .value('ME', L.tr('Montenegro'))  
          .value('MS', L.tr('Montserrat'))  
          .value('MA', L.tr('MOROCCO'))  
          .value('MZ', L.tr('Mozambique'))  
          .value('MM', L.tr('Myanmar'))  
          .value('NA', L.tr('Namibia'))  
          .value('NR', L.tr('Nauru'))  
          .value('NP', L.tr('Nepal'))  
          .value('NL', L.tr('NETHERLANDS'))  
          .value('NC', L.tr('New Caledonia '))  
          .value('NZ', L.tr('NEW ZEALAND'))   
          .value('NI', L.tr('Nicaragua'))  
          .value('NE', L.tr('Niger'))  
          .value('NG', L.tr('Nigeria'))  
          .value('NU', L.tr('Niue'))  
          .value('NF', L.tr('Norfolk Island'))  
          .value('MP', L.tr('Northern Mariana Islands'))  
          .value('NO', L.tr('NORWAY')) 
          .value('OM', L.tr('OMAN'))  
          .value('PK', L.tr('PAKISTAN'))  
          .value('PW', L.tr('Palau'))  
          .value('PS', L.tr('Palestine'))  
          .value('PA', L.tr('PANAMA'))  
          .value('PG', L.tr('Papua New Guinea'))  
          .value('PY', L.tr('Paraguay'))  
          .value('PE', L.tr('PERU'))  
          .value('PH', L.tr('PHILIPPINES'))  
          .value('PN', L.tr('Pitcairn'))  
          .value('PL', L.tr('POLAND'))  
          .value('PT', L.tr('PORTUGAL'))  
          .value('PR', L.tr('PUERTO RICO'))  
          .value('QA', L.tr('QATAR'))  
          .value('RE', L.tr('Réunion'))  
          .value('RO', L.tr('ROMANIA'))  
          .value('RU', L.tr('RUSSIA FEDERATION'))  
          .value('RW', L.tr('Rwanda'))  
          .value('BL', L.tr('Saint Barthélemy'))  
          .value('SH', L.tr('Saint Helena'))  
          .value('SH', L.tr('Ascension Island'))  
          .value('SH', L.tr('Tristan da Cunha'))  
          .value('KN', L.tr('Saint Kitts and Nevis'))  
          .value('LC', L.tr('Saint Lucia'))  
          .value('MF', L.tr('Saint Martin '))  
          .value('PM', L.tr('Saint Pierre and Miquelon'))  
          .value('VC', L.tr('Saint Vincent and the Grenadines'))  
          .value('WS', L.tr('Samoa'))  
          .value('SM', L.tr('San Marino'))  
          .value('ST', L.tr('Sao Tome and Principe'))  
          .value('SA', L.tr('SAUDI ARABIA'))  
          .value('SN', L.tr('Senegal'))  
          .value('RS', L.tr('Serbia'))  
          .value('SC', L.tr('Seychelles'))  
          .value('SL', L.tr('Sierra Leone'))  
          .value('SG', L.tr('SINGAPORE'))  
          .value('SX', L.tr('Sint Maarten'))  
          .value('SK', L.tr('SLOVAKIA'))  
          .value('SI', L.tr('SLOVENIA'))  
          .value('SB', L.tr('Solomon Islands'))  
          .value('SO', L.tr('Somalia'))  
          .value('ZA', L.tr('SOUTH AFRICA'))  
          .value('GS', L.tr('South Georgia and the South Sandwich Islands'))  
          .value('SS', L.tr('South Sudan'))  
          .value('ES', L.tr('SPAIN'))  
          .value('LK', L.tr('Sri Lanka'))  
          .value('SD', L.tr('Sudan'))  
          .value('SR', L.tr('Suriname'))  
          .value('SJ', L.tr('Svalbard'))  
          .value('SJ', L.tr('Jan Mayen'))  
          .value('SE', L.tr('SWEDEN'))  
          .value('CH', L.tr('SWITZERLAND'))  
          .value('SY', L.tr('SYRIAN ARAB REPUBLIC'))  
          .value('TW', L.tr('TAIWAN'))  
          .value('TJ', L.tr('Tajikistan'))  
          .value('TZ', L.tr('Tanzania'))  
          .value('TH', L.tr('THAILAND'))  
          .value('TL', L.tr('Timor-Leste'))  
          .value('TG', L.tr('Togo'))  
          .value('TK', L.tr('Tokelau'))  
          .value('TO', L.tr('Tonga'))  
          .value('TT', L.tr('TRINIDAD AND TOBAGO'))  
          .value('TN', L.tr('TUNISIA'))  
          .value('TR', L.tr('TURKEY'))  
          .value('TM', L.tr('Turkmenistan'))  
          .value('TC', L.tr('Turks and Caicos Islands'))  
          .value('TV', L.tr('Tuvalu'))  
          .value('UG', L.tr('Uganda'))  
          .value('UA', L.tr('UKRAINE'))  
          .value('AE', L.tr('UNITED ARAB EMIRATES'))  
          .value('GB', L.tr('UNITED KINGDOM'))  
          .value('US', L.tr('UNITED STATES'))  
          .value('UY', L.tr('URUGUAY'))  
          .value('UZ', L.tr('UZBEKISTAN'))  
          .value('VU', L.tr('Vanuatu'))  
          .value('VE', L.tr('VENEZUELA'))  
          .value('VN', L.tr('VIET NAM'))  
          .value('VG', L.tr('Virgin Islands'))  
          .value('WF', L.tr('Wallis and Futuna'))  
          .value('EH', L.tr('Western Sahara '))  
          .value('YE', L.tr('YEMEN'))  
          .value('ZM', L.tr('Zambia'))  
          .value('ZW', L.tr('ZIMBABWE')); 
        
        
        s2.option(L.cbi.ListValue, 'wifideviceschannel', {
			    caption:	L.tr('Channel')
		    }).depends({'wificonfig':'1'})
          .value('1', L.tr('1'))
          .value('2', L.tr('2'))
          .value('3', L.tr('3'))
          .value('4', L.tr('4'))
          .value('5', L.tr('5'))
          .value('6', L.tr('6'))
          .value('7', L.tr('7'))
          .value('8', L.tr('8'))
          .value('9', L.tr('9'))
          .value('10', L.tr('10'))
          .value('11', L.tr('11'))
          .value('12', L.tr('12'))
          .value('13', L.tr('13'))
          .value('14', L.tr('14'))
          .value('auto', L.tr('auto'));
         
        s2.option(L.cbi.InputValue, 'TxPower', {
		      caption:	L.tr('TX Power'),
		      datatype:'rangelength(0,100)',
		    }).depends({'wificonfig':'1'});
		
		    s2.option(L.cbi.ListValue, 'channelwidth', {
		      caption:	L.tr('Channel width'),
		    }).depends({'wificonfig':'1'})
		      .value('0', L.tr('20 MHz'))
		      .value('1', L.tr('20/40 MHz')); 
		    
        s2.option(L.cbi.CheckboxValue, 'wifi1enable', {
          caption:	L.tr('Enable Radio'),
          optional: true,
        });
		
        s2.option(L.cbi.ListValue, 'wifi1mode', {
          caption:	L.tr('Radio Mode'),
        }).depends({'wifi1enable':'1'})
          .value('ap', L.tr('Access Point'))
          .value('sta', L.tr('Client only'))
          .value('apsta', L.tr('Access Point and Client'));
				       
        s2.option(L.cbi.InputValue, 'wifi1ssid', {
          caption:	'Radio SSID',
          datatype: 'rt_alphanumericsplchar',
        }).depends({'wifi1enable' : '1','wifi1mode':'ap'})
          .depends({'wifi1enable' : '1','wifi1mode':'apsta'});
		
        s2.option(L.cbi.ListValue, 'wifi1authentication', {
          caption:	L.tr('Radio Authentication'),
          initial:	'none'
        }).depends({'wificonfig':'1','wifi1enable' : '1','wifi1mode':'ap'})
          .depends({'wificonfig':'1','wifi1enable' : '1','wifi1mode':'apsta'})
          .value('OPEN', L.tr('No Authentication'))
          .value('WPAPSK', L.tr('WPA Personal (PSK)'))
          .value('WPA2PSK', L.tr('WPA2 Personal (PSK)'))
          .value('WPAPSKWPA2PSK', L.tr('WPAPSK/WPA2PSK mixed mode'))
          .value('WPA3PSK', L.tr('WPA3 Personal(PSK)'))
          .value('WPA2PSKWPA3PSK', L.tr('WPA2PSK/WPA3PSK mixed mode'));
        
        s2.option(L.cbi.ListValue, 'wifi1encryption', {
          caption:	L.tr('Radio Encryption'),
          initial:	'none'
        }).depends({'wificonfig':'1','wifi1enable' : '1','wifi1mode':'ap'})
          .depends({'wificonfig':'1','wifi1enable' : '1','wifi1mode':'apsta'})
          .value('NONE', L.tr('NONE'))
          .value('TKIP', L.tr('TKIP'))
          .value('TKIPAES', L.tr('TKIPAES'))
          .value('AES', L.tr('AES'));

        s2.option(L.cbi.PasswordValue, 'wifi1key', {
          caption:	L.tr('Radio Passphrase'),
          datatype:'rangelength(8,11)',
          optional:	true
        }).depends({'wificonfig':'1','wifi1enable' : '1','wifi1mode':'ap'})
          .depends({'wificonfig':'1','wifi1enable' : '1','wifi1mode':'apsta'});
		
        s2.option(L.cbi.InputValue, 'radio0dhcpip', {
            caption: L.tr('Radio DHCP Server IP'), 
            datatype: 'ip4addr',
        }).depends({'wificonfig':'1','wifi1enable' : '1','wifi1mode':'ap'})
          .depends({'wificonfig':'1','wifi1enable' : '1','wifi1mode':'apsta'});
        
                
        s2.option(L.cbi.InputValue, 'Radio0DHCPrange', {
            caption: L.tr('Radio DHCP Start Address'), 
            datatype: 'uinteger',
        }).depends({'wificonfig':'1','wifi1enable' : '1','wifi1mode':'ap'})
		      .depends({'wificonfig':'1','wifi1enable' : '1','wifi1mode':'apsta'});
        
        s2.option(L.cbi.InputValue, 'Radio0DHCPlimit', {
            caption: L.tr('Radio DHCP Limit'), 
            datatype: 'uinteger',
        }).depends({'wificonfig':'1','wifi1enable' : '1','wifi1mode':'ap'})
		      .depends({'wificonfig':'1','wifi1enable' : '1','wifi1mode':'apsta'});
		  
        s2.option(L.cbi.CheckboxValue, 'WmmEnable', {
           caption: L.tr('WMM Enable'), 
        }).depends({'wificonfig':'1','wifi1enable' : '1','wifi1mode':'ap'})
		      .depends({'wificonfig':'1','wifi1enable' : '1','wifi1mode':'apsta'});
     
        //////////////////////////////////////////////////////
        
       s2.option(L.cbi.CheckboxValue, 'EnableDhcpRelay', {
          caption:	L.tr('Enable DHCP Relay'),
       }).depends({'wificonfig':'1','wifi1enable' : '1','wifi1mode':'sta'})
        .depends({'wificonfig':'1','wifi1enable' : '1','wifi1mode':'apsta'});
		
		   s2.option(L.cbi.InputValue, 'WifiRelayServerIP', {
           caption: L.tr('Relay Server IP'), 
           datatype: 'ip4addr',
       }).depends({'wificonfig':'1','wifi1enable' : '1','wifi1mode':'sta','EnableDhcpRelay':'1'})
		     .depends({'wificonfig':'1','wifi1enable' : '1','wifi1mode':'apsta','EnableDhcpRelay':'1'});
        
		   s2.option(L.cbi.InputValue, 'WifiRelayLocalIP', {
        caption: L.tr('Relay Local IP'), 
        datatype: 'ip4addr',
       }).depends({'wificonfig':'1','wifi1enable' : '1','wifi1mode':'sta','EnableDhcpRelay':'1'});
 
        /////////////////////////////////////////////////////////////////


        self.ssidList = s2.option(L.cbi.custom_Value, 'wifi1stassid', {
          caption: L.tr('Client SSID'),
          optional: true,
          listcustom: true,
          datatype: function (ev) {
            var selectedSSID = ev && ev.join ? ev.join('') : String(ev || '');
            if (!self._scanCompleted)
              return true;

            if (!selectedSSID || !self._ssidSecurityMap)
              return true;
            var sec = self._ssidSecurityMap[selectedSSID];
            if (!sec)
              return true;
            $('#field_sysconfig_wificonfig_wificonfig_wifistaauth').val(sec.auth);
            $('#field_sysconfig_wificonfig_wificonfig_wifistaencryption').val(sec.enc);
            return true;
          }

        });
        self.ssidList.depends({ wificonfig: '1', wifi1enable: '1', wifi1mode: 'apsta' });
        self.ssidList.depends({ wificonfig: '1', wifi1enable: '1', wifi1mode: 'sta' });
        self.ssidList.value('', L.tr('-- Select SSID --'));


        /* ================================
        * Scan WiFi Button
        * ================================ */
        var scanBtn = s2.option(L.cbi.ButtonValue, '_scan_wifi', {
          label: L.tr('Scan SSID')
        });

        scanBtn.depends({ wificonfig: '1', wifi1enable: '1', wifi1mode: 'apsta' });
        scanBtn.depends({ wificonfig: '1', wifi1enable: '1', wifi1mode: 'sta' });




        scanBtn.events = {
          click: function () {


            self.runWifiScan();

          }
        };


         /* ================================
          * Authentication
          * ================================ */
          self.staAuth = s2.option(L.cbi.InputValue, 'wifistaauth', {
            caption: L.tr('Client Authentication'),
            optional: true
          });
          self.staAuth.depends({ wificonfig: '1', wifi1enable: '1', wifi1mode: 'apsta' });
          self.staAuth.depends({ wificonfig: '1', wifi1enable: '1', wifi1mode: 'sta' });


          /* ================================
          * Encryption
          * ================================ */
          self.staEnc = s2.option(L.cbi.InputValue, 'wifi1staencryption', {
            caption: L.tr('Client Encryption'),
            optional: true
          });
          self.staEnc.depends({ wificonfig: '1', wifi1enable: '1', wifi1mode: 'apsta' });
          self.staEnc.depends({ wificonfig: '1', wifi1enable: '1', wifi1mode: 'sta' });











        
      //  s2.option(L.cbi.InputValue, 'wifi1stassid', {
			//   caption:	'Client SSID'
		  //  }).depends({'wificonfig':'1','wifi1enable' : '1','wifi1mode':'sta'})
		  //    .depends({'wificonfig':'1','wifi1enable' : '1','wifi1mode':'apsta'});

		  //  s2.option(L.cbi.ListValue, 'wifi1staencryption', {
			//   caption:	L.tr('Client Encryption'),
			//   initial:	'none'
		  //  }).depends({'wificonfig':'1','wifi1enable' : '1','wifi1mode':'sta'})
		  //    .depends({'wificonfig':'1','wifi1enable' : '1','wifi1mode':'apsta'})
      //    .value('none', L.tr('No encryption'))
      //    .value('psk', L.tr('WPA Personal (PSK)'))
      //    .value('psk2', L.tr('WPA2 Personal (PSK)'))
      //    .value('mixed-psk', L.tr('WPA/WPA2 Personal (PSK) mixed'));

		   s2.option(L.cbi.PasswordValue, 'wifi1stakey', {
			    caption:	L.tr('Client Passphrase'),
			    optional:	true
       }).depends({'wificonfig':'1','wifi1enable' : '1','wifi1mode':'sta'})
         .depends({'wificonfig':'1','wifi1enable' : '1','wifi1mode':'apsta'});
    
       m2.insertInto('#section_wifi');  

        var m3 = new L.cbi.Map('sysconfig', {
        });     
        
            
        ///////////////////////////////////// Guest Wireless Configuration  ////////////////////////////////////////////


        var s3 = m3.section(L.cbi.NamedSection, 'guestwifi', {
         caption: L.tr('Guest Wireless Configuration')            // change by vijay
        });
    
        s3.option(L.cbi.CheckboxValue, 'guestwifienable', {
			    caption:	L.tr('Enable Guest Wifi'),
			    optional: true
		    }).depends({'wificonfig':'1','wifi1enable':'1','wifi1mode':'ap'});
		  		
        s3.option(L.cbi.InputValue, 'guestwifissid', {
			    caption:	'SSID'
		    }).depends({'wifi1enable' : '1','wifi1mode':'ap','guestwifi':'1','guestwifienable':'1'})
		
        s3.option(L.cbi.ListValue, 'guestwifi1authentication', {
          caption:	L.tr('Radio Authentication'),
          initial:	'none'
        }).depends({'wifi1enable' : '1','wifi1mode':'ap','guestwifi':'1','guestwifienable':'1'})
        .value('OPEN', L.tr('No Authentication'))
        .value('WPAPSK', L.tr('WPA Personal (PSK)'))
        .value('WPA2PSK', L.tr('WPA2 Personal (PSK)'))
        .value('WPAPSKWPA2PSK', L.tr('WPAPSK/WPA2PSK mixed mode'))
        .value('WPA3PSK', L.tr('WPA3 Personal(PSK)'))
        .value('WPA2PSKWPA3PSK', L.tr('WPA2PSK/WPA3PSK mixed mode'));
		
        s3.option(L.cbi.ListValue, 'guestwifi1encryption', {
          caption:	L.tr('Radio Encryption'),
          initial:	'none'
        }).depends({'wifi1enable' : '1','wifi1mode':'ap','guestwifi':'1','guestwifienable':'1'})
            .value('NONE', L.tr('NONE'))
        .value('TKIP', L.tr('TKIP'))
        .value('TKIPAES', L.tr('TKIPAES'))
        .value('AES', L.tr('AES'));
		
        s3.option(L.cbi.PasswordValue, 'guestwifikey', {
          caption:	L.tr('Passphrase'),
          datatype:'rangelength(8,11)',
          optional:	true
        }).depends({'wifi1enable' : '1','wifi1mode':'ap','guestwifi':'1','guestwifienable':'1'})
      
        s3.option(L.cbi.InputValue, 'guestradio0dhcpip', {
           caption: L.tr('Server IP'), 
           datatype: 'ip4addr',
        }).depends({'wifi1enable' : '1','wifi1mode':'ap','guestwifi':'1','guestwifienable':'1'})
          
        s3.option(L.cbi.InputValue, 'guestRadio0DHCPrange', {
           caption: L.tr('Start Address'), 
            datatype: 'uinteger',
        }).depends({'wifi1enable' : '1','wifi1mode':'ap','guestwifi':'1','guestwifienable':'1'})
        
        s3.option(L.cbi.InputValue, 'guestRadio0DHCPlimit', {
           caption: L.tr('DHCP Limit'), 
            datatype: 'uinteger',
        }).depends({'wifi1enable' : '1','wifi1mode':'ap','guestwifi':'1','guestwifienable':'1'})
            
        m3.insertInto('#section_guestwifi');  


        ///////////////////////////////////////////// Wifi Schedule Settings ///////////////////////////////////////////////
		
        var m4 = new L.cbi.Map('sysconfig', {
        });     
   
        var s4 = m4.section(L.cbi.NamedSection, 'wirelessconfig', {
           caption: L.tr('Wifi Schedule Settings')    // change by vijay
        });
        
        s4.load = function(sid) {
			var wifi1mode = L.uci.get('sysconfig', 'wificonfig', 'wifi1mode');
			console.log("wifi1mode:", wifi1mode);
			    
			    
		    if (wifi1mode == 'sta')
			{
				var note = s4.option(L.cbi.DummyValue, '_note', {
                caption: L.tr('Note')
	            });
	
	            note.ucivalue = function() {
	                return '<span style="color:red;">Wifi schedule is available only when Radio Mode is ap or apsta in WiFi Settings.</span>';
	            };
			}
			else
			{
					s4.option(L.cbi.CheckboxValue, 'ScheduledOnOff', {
				    caption: L.tr('Scheduled Wifi Off'),
				    optional: true
				});
			
		
		        s4.option(L.cbi.DynamicList, 'DayOfWeek', {
		          caption: L.tr('Day Of Week'),
		          optional: true,
		          listlimit: 12,
		          listcustom:false
		        }).depends({'wificonfig':'1','wifi1enable':'1','wificonfigschedule':'1','ScheduledOnOff':'1'})
		          .value('*', L.tr('All'))
		          .value('0', L.tr('Sunday'))
		          .value('1', L.tr('Monday'))
		          .value('2', L.tr('Tuesday'))
		          .value('3', L.tr('Wednesday'))
		          .value('4', L.tr('Thursday'))
		          .value('5', L.tr('Friday'))
		          .value('6', L.tr('Saturday'));
		  
		        s4.option(L.cbi.SubHeadingValue, '_from_label', {
		          caption: L.tr(''),
		        }).depends({ 'ScheduledOnOff': '1' })
		          .ucivalue = function () {
		            return '<strong>From</strong>';
		          };
		
				    var fromHourVal = s4.option(L.cbi.DynamicList, 'fromHours', {
		            caption: L.tr('Hours'),
		            optional: true,
		            listlimit: 24,
		            listcustom:false,
		        }).depends({'wificonfig':'1','wifi1enable':'1','wificonfigschedule':'1','ScheduledOnOff':'1'})
		          .value('',L.tr('-- Please choose --'))
		          .value('*', L.tr('All'));
		
		        fromHourVal.load = function(sid) {
		          var hours = [ ];
		            for (var i = 0; i < 24; i++)
		                hours.push(i);
		                hours.sort();
		            for (var i = 0; i < hours.length; i++)
		                fromHourVal.value(i);
		        };
		
				    var fromMinuteVal = s4.option(L.cbi.DynamicList, 'fromMinutes', {
		            caption: L.tr('Minutes'),
		            optional: true,
		            listlimit: 60,
		            listcustom: false
		        }).depends({'wificonfig':'1','wifi1enable':'1','wificonfigschedule':'1','ScheduledOnOff':'1'})
		          .value('',L.tr('-- Please choose --'))
		          .value('*', L.tr('All'));
		
		        fromMinuteVal.load = function(sid) {
		          var minutes = [ ];
		          for (var i = 0; i < 60; i++)
		            minutes.push(i);
		            minutes.sort();
		          for (var i = 0; i < minutes.length; i++)
		            fromMinuteVal.value(i);
		        };
		
		        s4.option(L.cbi.SubHeadingValue, '_to_label', {
		          caption: L.tr(''),
		        }).depends({ 'ScheduledOnOff': '1' })
		          .ucivalue = function () {
		            return '<strong>To</strong>';
		          };
		        
		        var HourVal = s4.option(L.cbi.DynamicList, 'toHours', {
		          caption: L.tr('Hours'),
		          optional: true,
		          listlimit: 24,
		          listcustom:false,
		        }).depends({'wificonfig':'1','wifi1enable':'1','wificonfigschedule':'1','ScheduledOnOff':'1'})
		          .value('',L.tr('-- Please choose --'))
		          .value('*', L.tr('All'));
		
		        HourVal.load = function(sid) {
		            var hours = [ ];
		            for (var i = 0; i < 24; i++)
		                hours.push(i);
		            hours.sort();
		            for (var i = 0; i < hours.length; i++)
		                HourVal.value(i);
		        };
				
				    var MinuteVal = s4.option( L.cbi.DynamicList, 'toMinutes', {
		          caption: L.tr('Minutes'),
		          optional: true,
		          listlimit: 60,
		          listcustom: false
		        }).depends({'wificonfig':'1','wifi1enable':'1','wificonfigschedule':'1','ScheduledOnOff':'1'})
		          .value('',L.tr('-- Please choose --'))
		          .value('*', L.tr('All'));
		
		        MinuteVal.load = function(sid) {
		          var minutes = [ ];
		          for (var i = 0; i < 60; i++)
		              minutes.push(i);
		             minutes.sort();
		          for (var i = 0; i < minutes.length; i++)
		                MinuteVal.value(i);
		        };
					
			}
		}
		   		
		m4.insertInto('#section_wireless');
		    
    }  
  }
});
