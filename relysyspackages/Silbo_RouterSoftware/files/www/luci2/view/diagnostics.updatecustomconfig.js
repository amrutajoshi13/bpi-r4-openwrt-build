L.ui.view.extend({

	GetUCISections: L.rpc.declare({
		object: 'uci',
		method: 'get',
		params: ['config', 'type'],
		expect: { values: {} }
	}),

	TestArchive: L.rpc.declare({
		object: 'rpc-updateVPNConfig',
		method: 'testarchive',
		params: ['archive'],
	}),

	updatecustomconfig: L.rpc.declare({
		object: 'rpc-updatecustomimageconfig',
		method: 'configure',
		expect: { output: '' }
	}),

	handleArchiveUpload: function () {
		var self = this;
		L.ui.ImageUpload(
			L.tr('File Upload'),
			L.tr('Select the file and click on "%s" button to proceed.').format(L.tr('Apply')), {
			filename: '/root/custom_image/custom_logo.svg',
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
		self.updatecustomconfig('configure').then(function (TestArchiveOutput) {
			L.ui.dialog(false)
			L.ui.showAlert(
				'success',
				'Logo Upload',
				'Custom Logo uploaded successfully'
			);
			L.ui.loading(false);
		});
		localStorage.removeItem('logoinfo');

		const now = new Date();
		const FileName = archive.split('/').pop();
		const formatted = now.toLocaleString();
		const logo_info = `File name- ${FileName}<br> Date- ${formatted}`;
		localStorage.setItem('logoinfo', logo_info);
		$('#last-upload-logo').html(logo_info);
	},



	execute: function () {
		var self = this;
		const infologo = localStorage.getItem('logoinfo')
		$('#last-upload-logo').html(infologo);
		var m = new L.cbi.Map('customconfig', {
		});

		var s = m.section(L.cbi.NamedSection, 'customconfig', {
			caption: L.tr('Custom Logo Configuration')
		});

		s.option(L.cbi.InputValue, 'manufacturer', {
			caption: L.tr('Manufacturer Name'),
		});

		s.option(L.cbi.InputValue, 'manufacturer_url', {
			caption: L.tr('Manufacturer Url'),
		});

		s.option(L.cbi.InputValue, 'CustomModelname', {
			caption: L.tr('Model Name'),
		});

		$('#btn_upload').click(function () {
			self.handleArchiveUpload();
		});
		m.insertInto('#map');

		s.commit = function () {
		}
	}
});


