L.ui.view.extend({
        // title: L.tr('Storage Configuration'),

        execute: function () {
                L.ui.createNote(
                        'NOTE',
                        'Disabling eMMC once it has been earlier enabled, will result in previous data loss.',
                        { type: 'warn', variant: 'inline', appendTo: '#Note-Storage' }
                );
                var m = new L.cbi.Map('Storageconfig', {
                        caption: L.tr('')
                });

                var s = m.section(L.cbi.NamedSection, 'Storageconfig', {
                        caption: L.tr('Storage Configuration Settings')
                });

                s.option(L.cbi.CheckboxValue, 'eMCCEnable', {
                        caption: L.tr('Enable Data Storage on eMMC')
                });

                // s.option(L.cbi.DummyValue, 'warning', {
                //         caption: L.tr(''),
                //         //  caption: L.tr(a),
                // })
                //         .depends('eMCCEnable')
                //         .ucivalue = function () {
                //                 var id = "<h4><b>NOTE : Disabling eMMC once it has been earlier enabled, will result in previous data loss</b> </h4>";
                //                 return id;
                //         };




                s.option(L.cbi.ListValue, 'storagesize', {
                        caption: L.tr('Storage Size'),
                }).depends('eMCCEnable')
                        .value("4GB", L.tr('4GB'))
                        .value("8GB", L.tr('8GB'));

                //    var s = m.section(L.cbi.NamedSection, 'Storageconfig', {
                //        caption: L.tr('<b>NOTE: - </b>Disabling eMMC once it has been earlier enabled, will result in previous data loss') 
                //    });


                m.insertInto('#map');

        }
})

