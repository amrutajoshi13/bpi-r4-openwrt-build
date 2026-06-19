L.ui.view.extend({



  updateinterfaceconfig: L.rpc.declare({
    object: 'rpc-snmptrapupdate',
    method: 'configure',
    params: ['application', 'action'],
    expect: { output: '' }
  }),

  execute: function () {
    var self = this;
    var m = new L.cbi.Map('snmptrapconfig', {
    });

    var s = m.section(L.cbi.NamedSection, 'snmptrapconfig', {
      caption: L.tr('SNMP Trap Configuration')
    });


    s.option(L.cbi.CheckboxValue, 'enablesnmptrap', {
      caption: L.tr('Enable SNMP Trap'),
      optional: true
    });

    s.option(L.cbi.InputValue, 'host', {
      caption: L.tr('Host'),
      optional: true
    }).depends({ 'enablesnmptrap': '1' })
    // .value("none",L.tr("Choose Option"))
    // .value('invendis.com', L.tr('invendis.com')); 

    s.option(L.cbi.InputValue, 'porttrap', {
      caption: L.tr('Port'),
      placeholder: '162',
    }).depends({ 'enablesnmptrap': '1' });


    s.option(L.cbi.InputValue, 'community', {
      caption: L.tr('Community'),
      placeholder: 'Public',
    }).depends({ 'enablesnmptrap': '1' })


    s.option(L.cbi.CheckboxValue, 'enablesignalstrengthtrap', {
      caption: L.tr('Enable Signal Strength Trap'),
      optional: true
    }).depends({ 'enablesnmptrap': '1' });


    s.option(L.cbi.InputValue, 'signalstrength', {
      caption: L.tr('Signal Strength'),
      placeholder: '-115',
    }).depends({ 'enablesnmptrap': '1', 'enablesignalstrengthtrap': '1' })

    s.option(L.cbi.CheckboxValue, 'enablenetworktypetrap', {
      caption: L.tr('Enable Network Type Trap'),
      optional: true
    }).depends({ 'enablesnmptrap': '1' });

    //  s.option(L.cbi.CheckboxValue, 'enablegsmtrap', {
    //             caption: L.tr('Enable GSM Trap'),
    //               optional: true
    //             }).depends({'enablesnmptrap':'1'});

    //   s.option(L.cbi.InputValue, 'signalstrength', {
    //               caption: L.tr('Signal Strength'),
    //               placeholder: '20',
    //             }).depends({'enablegsmtrap' : '1','enablesnmptrap':'1'});

    //  s.option(L.cbi.InputValue, 'network', {
    //               caption: L.tr('Network Type'),
    //               placeholder: '3G',
    //             }).depends({'enablegsmtrap' : '1','enablesnmptrap':'1'});

    //s.option(L.cbi.CheckboxValue, 'enableiotrap', {
    //caption: L.tr('Enable Input/Output Trap'),
    //optional: true
    //}).depends({'enablesnmptrap':'1'});



    //s.option(L.cbi.CheckboxValue, 'version3', {
    //caption: L.tr('Version-3'),
    //optional: true
    //}).depends({'enablesnmptrap':'1'});

    //s.option(L.cbi.ListValue, 'snmptrapsecurity', {
    //caption: L.tr('Security'),
    //}).depends({'version3' : '1','enablesnmp':'1'})
    //.value("none",L.tr("Choose Option"))
    //.value('1', L.tr('NoAuthNoPriv')) 
    //.value('2', L.tr('AuthNoPriv'))
    //.value('3', L.tr('AuthPriv'));



    //s.option(L.cbi.InputValue, 'username', {
    //caption: L.tr('User Name'),
    //placeholder: 'admin',
    //}).depends({'snmptrapsecurity' : '1','version3' : '1','enablesnmptrap':'1'})
    //.depends({'snmptrapsecurity' : '2','version3' : '1','enablesnmptrap':'1'})
    //.depends({'snmptrapsecurity' : '3','version3' : '1','enablesnmptrap':'1'});


    //s.option(L.cbi.InputValue, 'authenticationpassword', {
    //caption: L.tr('Authentication Password:'),
    //placeholder: 'Authentication Password',
    //}) 
    //.depends({'snmptrapsecurity' : '2','version3' : '1','enablesnmptrap':'1'})
    //.depends({'snmptrapsecurity' : '3','version3' : '1','enablesnmptrap':'1'});

    //s.option(L.cbi.InputValue, 'privacypassword', {       
    //caption: L.tr('Privacy Password:'),                              
    //placeholder: 'Privacy Password',                             
    //}).depends({'snmptrapsecurity':'3','version3' : '1','enablesnmptrap':'1'}); 


    s.commit = function () {
      self.updateinterfaceconfig('Update', 'updateinterface').then(function (rv) {

      });
    }

    return m.insertInto('#map');

  }

});


