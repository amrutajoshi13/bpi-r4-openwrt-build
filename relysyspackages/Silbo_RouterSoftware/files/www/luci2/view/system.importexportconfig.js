L.ui.view.extend({

	testUpgrade: L.rpc.declare({
		object: 'luci2.system',
		method: 'upgrade_test',
		expect: { '': {} }
	}),

	startUpgrade: L.rpc.declare({
		object: 'luci2.system',
		method: 'upgrade_start',
		params: ['keep']
	}),

	RetainConfigstartUpgrade: L.rpc.declare({
		object: 'rpc-sysupgrade',
		method: 'upgrade',
		expect: { output: '' }
	}),

	RebootSystem: L.rpc.declare({
		object: 'rpc-importexport',
		method: 'rebootsys',
		expect: { output: '' }
	}),

	Updateftp: L.rpc.declare({
		object: 'rpc-importexport',
		method: 'updateftp'
	}),

	cleanUpgrade: L.rpc.declare({
		object: 'luci2.system',
		method: 'upgrade_clean'
	}),

	restoreBackup: L.rpc.declare({
		object: 'luci2.system',
		method: 'backup_restore'
	}),

	cleanBackup: L.rpc.declare({
		object: 'luci2.system',
		method: 'backup_clean'
	}),

	getBackupConfig: L.rpc.declare({
		object: 'luci2.system',
		method: 'backup_config_get',
		expect: { config: '' }
	}),

	setBackupConfig: L.rpc.declare({
		object: 'luci2.system',
		method: 'backup_config_set',
		params: ['data']
	}),

	listBackup: L.rpc.declare({
		object: 'luci2.system',
		method: 'backup_list',
		expect: { files: [] }
	}),

	testReset: L.rpc.declare({
		object: 'luci2.system',
		method: 'reset_test',
		expect: { supported: false }
	}),


	TestArchive: L.rpc.declare({
		object: 'rpc-importexport',
		method: 'testarchive',
		params: ['archive'],
		expect: { output: '' }
	}),

	startReset: L.rpc.declare({
		object: 'luci2.system',
		method: 'reset_start'
	}),

	handleFlashUpload: function () {
		var self = this;
		L.ui.upload(
			L.tr('Firmware upload'),
			L.tr('Select the sysupgrade image to flash and click "%s" to proceed.').format(L.tr('Ok')), {
			filename: '/tmp/firmware.bin',
			success: function (info) {
				self.handleFlashVerify(info);
			}
		}
		);
	},

	handleFlashUploadRetainConfig: function () {
		var self = this;
		L.ui.upload(
			L.tr('Firmware upload'),
			L.tr('Select the sysupgrade image to flash and click "%s" to proceed.').format(L.tr('Ok')), {
			filename: '/tmp/firmware.bin',
			success: function (info) {
				self.handleFlashVerifyRetainConfig(info);
			}
		}
		);
	},

	handleFlashVerify: function (info) {
		var self = this;
		self.testUpgrade().then(function (res) {
			if (res.code == 0) {
				L.ui.dialog(
					L.tr('Verify firmware'), [
					$('<p />').text(L.tr('The firmware image was uploaded completely. Please verify the checksum and file size below, then click "%s" to start the flash procedure.').format(L.tr('Ok'))),
					$('<ul />')
						.append($('<li />')
							.append($('<strong />').text(L.tr('Checksum') + ': '))
							.append(info.checksum))
						.append($('<li />')
							.append($('<strong />').text(L.tr('Size') + ': '))
							.append('%1024mB'.format(info.size))),
				], {
					style: 'confirm',
					confirm: function () {
						self.startUpgrade().then(function () {
							L.ui.reconnect();
						});

						alert('Flash...');
					}
				}
				);
			}
			else {
				L.ui.dialog(
					L.tr('Invalid image'), [
					$('<p />').text(L.tr('Firmware image verification failed, the "sysupgrade" command responded with the message below:')),
					$('<pre />')
						.addClass('alert-message')
						.text(res.stdout || res.stderr),
					$('<p />').text(L.tr('Image verification failed with code %d.').format(res.code))
				], {
					style: 'close',
					close: function () {
						self.cleanUpgrade().then(function () {
							L.ui.dialog(false);
						});
					}
				}
				);
			}
		});
	},

	handleFlashVerifyRetainConfig: function (info) {
		var self = this;
		self.testUpgrade().then(function (res) {
			if (res.code == 0) {
				L.ui.dialog(
					L.tr('Verify firmware'), [
					$('<p />').text(L.tr('The firmware image was uploaded completely. Please verify the checksum and file size below, then click "%s" to start the flash procedure.').format(L.tr('Ok'))),
					$('<ul />')
						.append($('<li />')
							.append($('<strong />').text(L.tr('Checksum') + ': '))
							.append(info.checksum))
						.append($('<li />')
							.append($('<strong />').text(L.tr('Size') + ': '))
							.append('%1024mB'.format(info.size))),
				], {
					style: 'confirm',
					confirm: function () {
						self.RetainConfigstartUpgrade().then(function () {
							L.ui.reconnect();
						});

						alert('Flash...');
					}
				}
				);
			}
			else {
				L.ui.dialog(
					L.tr('Invalid image'), [
					$('<p />').text(L.tr('Firmware image verification failed, the "sysupgrade" command responded with the message below:')),
					$('<pre />')
						.addClass('alert-message')
						.text(res.stdout || res.stderr),
					$('<p />').text(L.tr('Image verification failed with code %d.').format(res.code))
				], {
					style: 'close',
					close: function () {
						self.cleanUpgrade().then(function () {
							L.ui.dialog(false);
						});
					}
				}
				);
			}
		});
	},

	handleBackupUpload: function () {
		var self = this;
		L.ui.upload(
			L.tr('Backup restore'),
			L.tr('Select the backup archive to restore and click "%s" to proceed.').format(L.tr('Apply')), {
			filename: '/tmp/backup.txt',
			success: function (info) {
				self.handleBackupVerify(info);
			}
		}
		);
	},

	handleBackupVerify: function (info) {
		var self = this;
		L.ui.dialog(
			L.tr('Backup restore'), [
			$('<p />').text(L.tr('The backup archive was uploaded completely. Please verify the checksum and file size below, then click "%s" to restore the archive.').format(L.tr('Apply'))),
			$('<ul />')
				.append($('<li />')
					.append($('<strong />').text(L.tr('Checksum') + ': '))
					.append(info.checksum))
				.append($('<li />')
					.append($('<strong />').text(L.tr('Size') + ': '))
					.append('%1024mB'.format(info.size)))
		], {
			style: 'confirm',
			confirm: function (info) {
				self.handleBackupRestore(info);
			}
		}
		);
	},

	handleBackupRestore: function (info) {
		var self = this;
		var archive = $('[name=filename]').val();

		//self.restoreBackup().then(function(res) {
		self.TestArchive(archive).then(function (TestArchiveOutput) {

			var res = TestArchiveOutput.localeCompare("")

			if (res == 0) {



				L.ui.dialog(
					L.tr('TestArchive'),
					[
						$('<p />').text(L.tr('Imported Successfully')),
						// $('<p />').text(
						// 	L.tr('The backup has been successfully restored. Please wait for the board to reboot.')
						// ),
						$('<pre />')
							.addClass('alert success')
							.text(
								L.tr('File imported successfully. The board is rebooting — please wait a few minutes...')
							),
						$('<div />')
							.addClass('loading-spinner')
							.append($('<div />'))
							.append($('<div />'))
							.append($('<div />'))

					],

				);
				localStorage.removeItem('importinfo');
				const now = new Date();
				// const FileName = archive.split('/').pop();
				const FileName = 'config.txt';
				const formatted = now.toLocaleString();
				const import_info = `File name- ${FileName}<br> Date- ${formatted}`;
				localStorage.setItem('importinfo', import_info);
				$('#last-import').html(import_info);
			}
			else {
				L.ui.dialog(
					L.tr('Backup restore'), [
					$('<p />').text(L.tr('Invalid Archive.Please upload valid archive.')),
					$('<pre />')
						.addClass('alert error')
						.text(res.stdout || res.stderr),
					//$('<p />').text(L.tr('Backup restoration failed with code %d.').format(res.code))
				], {
					style: 'close',
					close: function () {
						self.cleanBackup().then(function () {
							L.ui.dialog(false);
						});
					}
				}
				);
			}
		});
	},

	handleBackupDownload: function () {
		var form = $('#btn_backup').parent();

		form.find('[name=sessionid]').val(L.globals.sid);
		form.submit();
		localStorage.removeItem('exportinfo');
		const now = new Date();
		// const FileName = archive.split('/').pop();
		const FileName = 'config.txt';
		const formatted = now.toLocaleString();
		const export_info = `File name- ${FileName}<br> Date- ${formatted}`;
		localStorage.setItem('exportinfo', export_info);
		$('#last-export').html(export_info);
	},

	handleReset: function () {
		var self = this;
		L.ui.dialog(L.tr('Really reset all changes?'), L.tr('This will reset the system to its initial configuration, all changes made since the initial flash will be lost!'), {
			style: 'confirm',
			confirm: function () {
				self.startReset().then(function () {
					L.ui.reconnect();
				});

				alert('Reset...');
			}
		});
	},

	execute: function () {
		var self = this;

		const exportinfo = localStorage.getItem('exportinfo')
		$('#last-export').html(exportinfo);
		const importinfo = localStorage.getItem('importinfo')
		$('#last-import').html(importinfo);

		var m = new L.cbi.Map('importexportconfig', {
		});

		var s = m.section(L.cbi.NamedSection, 'ftpconfig', {
			caption: L.tr('FTP Server Configurations')
		});

		s.option(L.cbi.CheckboxValue, 'enableftp', {
			caption: L.tr('Enable FTP Server'),
			optional: true
		});


		s.option(L.cbi.InputValue, 'serverurl', {
			caption: L.tr('Server URL'),
			optional: true
		}).depends({ 'enableftp': '1' });

		s.option(L.cbi.InputValue, 'username', {
			caption: L.tr('Username'),
			placeholder: "User",
			optional: true,
		}).depends({ 'enableftp': '1' });

		s.option(L.cbi.PasswordValue, 'password', {
			caption: L.tr('Password'),
			placeholder: "*******",
			optional: true,
		}).depends({ 'enableftp': '1' });

		s.option(L.cbi.ListValue, 'interval', {
			caption: L.tr('Upload Frequency'),
		}).value("none", L.tr('Please choose'))
			.value("daily", L.tr('Daily'))
			.value("weekly", L.tr('Weekly'))
			.depends({ 'enableftp': '1' });

		s.option(L.cbi.DateValue_week, 'week', {
			caption: L.tr('Day Of the Week'),
			optional: true
		}).depends({ 'enableftp': '1', 'interval': 'weekly' });

		s.option(L.cbi.TimeValue_min, 'time', {
			caption: L.tr('Time (HH:MM)'),
			placeholder: "HH:MM",
			optional: true
		}).depends({ 'enableftp': '1', 'interval': 'daily' })
			.depends({ 'enableftp': '1', 'interval': 'weekly' });




		self.testReset().then(function (reset_avail) {
			if (!reset_avail) {
				$('#btn_reset').prop('disabled', true);
			}

			if (!self.options.acls.backup) {
				$('#btn_restore, #btn_save, textarea').prop('disabled', true);
			}
			else {
				$('#btn_backup').click(function () { self.handleBackupDownload(); });
				$('#btn_restore').click(function () { self.handleBackupUpload(); });
			}

			if (!self.options.acls.upgrade) {
				$('#btn_flash, #btn_reset', '#btn_retainconfig_flash').prop('disabled', true);
			}
			else {
				$('#btn_flash').click(function () { self.handleFlashUpload(); });
				$('#btn_reset').click(function () { self.handleReset(); });
				$('#btn_retainconfig_flash').click(function () { self.handleFlashUploadRetainConfig(); });
			}

			return self.getBackupConfig();
		}).then(function (config) {
			$('textarea')
				.attr('rows', (config.match(/\n/g) || []).length + 1)
				.val(config);

			$('#btn_save')
				.click(function () {
					var data = ($('textarea').val() || '').replace(/\r/g, '').replace(/\n?$/, '\n');
					L.ui.loading(true);
					self.setBackupConfig(data).then(function () {
						$('textarea')
							.attr('rows', (data.match(/\n/g) || []).length + 1)
							.val(data);

						L.ui.loading(false);
					});
				});

			$('#btn_list')
				.click(function () {
					L.ui.loading(true);
					self.listBackup().then(function (list) {
						L.ui.loading(false);
						L.ui.dialog(
							L.tr('Backup file list'),
							$('<textarea />')
								.css('width', '100%')
								.attr('rows', list.length)
								.prop('readonly', true)
								.addClass('form-control')
								.val(list.join('\n')),
							{ style: 'close' }
						);
					});
				});
		});

		s.commit = function () {
			self.Updateftp('updateftp').then(function (rv) {
			});


		}

		return m.insertInto('#map');

		//		 return m.insertInto('#map');

	}
});
