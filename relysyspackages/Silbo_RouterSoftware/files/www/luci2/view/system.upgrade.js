L.ui.view.extend({

	uciGet: L.rpc.declare({
		object: 'uci',
		method: 'get',
		params: ['config', 'section', 'option'],
		expect: { value: "" }
	}),

	watchdogdisable: L.rpc.declare({
		object: 'rpc-watchdogdisable',
		method: 'disable',
		expect: { output: '' }
	}),

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

	factoryresetfun: L.rpc.declare({
		object: 'rpc-sysupgrade',
		method: 'factoryreset',
		expect: { output: '' }
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

	startReset: L.rpc.declare({
		object: 'luci2.system',
		method: 'reset_start'
	}),


	extractVersion: function (filename) {
		// Split the filename by hyphens
		var parts = filename.split('-');

		// Iterate through the parts to find the version number
		for (var i = 0; i < parts.length; i++) {
			// Check if the part is in the format of a version number (e.g., 1.08)
			if (/^\d+\.\d+$/.test(parts[i])) {
				return parts[i];
			}
		}

		return 'No version number found';
	},



	handleFlashUpload: function (currentVersion) {
		var self = this;
		L.ui.firmwareUpload(
			L.tr('Firmware upload'),
			L.tr('Select the sysupgrade image to flash and click "%s" to proceed.').format(L.tr('Apply')), {
			uploadedFileName: 'true',
			filename: '/tmp/firmware.bin',
			success: function (info, fileName) {
				console.log(fileName);
				var fileVersion = self.extractVersion(fileName);
				console.log("current : " + currentVersion + " file : " + fileVersion);
				if (currentVersion == fileVersion) {
					L.ui.dialog(false)
					showDialog(null, 'info', 'Same Version',
						"This is the same version of the file! Please click on 'OK' to continue",
						'OK', null,
						function (ok) {
							if (ok === 1) self.handleFlashVerify(info);
						}
					);

				}
				else if (currentVersion < fileVersion) {

					L.ui.dialog(false)
					showDialog(null,
						'info',
						'Upgrade',
						"The file will be upgraded! Please click on 'OK' to continue",
						'OK',
						'Cancel',
						function (ok) {
							if (ok === 1)
								self.handleFlashVerify(info);
						}
					);

				}
				else {

					L.ui.dialog(false)
					showDialog(null, 'warning', 'Downgrade Confirmation',
						"This is the lower version! Are you sure you want to downgrade? Please click on 'Yes, Downgrade' to confirm.",
						'Yes, Downgrade', 'Cancel',
						function (ok) {
							if (ok === 1) {
								self.handleFlashVerify(info);
							} else {
								// cancel path: cleanup/abort
								self.cleanUpgrade().then(function () {
									L.ui.dialog(false);
									location.reload();
								});
							}
						}
					);



					// return ;
				}
			}

		}
		);
	},
	handleFlashUploadRetainConfig: function () {
		var self = this;
		L.ui.firmwareUpload(
			L.tr('Firmware upload'),
			L.tr('Select the sysupgrade image to flash and click "%s" to proceed.').format(L.tr('Apply')), {
			filename: '/tmp/firmware.bin',
			success: function (info) {
				console.log(info);
				self.handleFlashVerifyRetainConfig(info);
			}
		}
		);
	},

	handleFlashVerify: function (info) {
		var self = this;
		// self.watchdogdisable().then(function (res) {
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
								.append('%1024mB'.format(info.size)))
					], {
						style: 'confirm',
						confirm: function () {
							self.startUpgrade().then(function () {
								L.ui.reconnect();
							});

							L.ui.showAlert(
								'success',
								'Flashed',
								'Firmware image flashed successfully.'
							);
						}
					}
					);
					// L.ui.dialog(false)
					// L.ui.showAlert(
					// 	'success',
					// 	'Flashed',
					// 	'Firmware image flashed successfully.'
					// );
				}
				else {
					L.ui.dialog(
						L.tr('Invalid image'), [
						$('<p />').text(L.tr('Firmware image verification failed, the "sysupgrade" command responded with the message below:')),
						$('<pre />')
							.addClass('alert error')
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
		// });
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

						L.ui.showAlert(
							'success',
							'Flashed',
							'Firmware image flashed successfully.'
						);
					}
				}
				);

			}
			else {
				L.ui.dialog(
					L.tr('Invalid image'), [
					$('<p />').text(L.tr('Firmware image verification failed, the "sysupgrade" command responded with the message below:')),
					$('<pre />')
						.addClass('alert error')
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
			L.tr('Select the backup archive to restore and click "%s" to proceed.').format(L.tr('Ok')), {
			filename: '/tmp/backup.tar.gz',
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
			$('<p />').text(L.tr('The backup archive was uploaded completely. Please verify the checksum and file size below, then click "%s" to restore the archive.').format(L.tr('Ok'))),
			$('<ul />')
				.append($('<li />')
					.append($('<strong />').text(L.tr('Checksum') + ': '))
					.append(info.checksum))
				.append($('<li />')
					.append($('<strong />').text(L.tr('Size') + ': '))
					.append('%1024mB'.format(info.size)))
		], {
			style: 'confirm',
			confirm: function () {
				self.handleBackupRestore();
			}
		}
		);
	},

	handleBackupRestore: function () {
		var self = this;
		self.restoreBackup().then(function (res) {
			if (res.code == 0) {
				L.ui.dialog(
					L.tr('Backup restore'), [
					$('<p />').text(L.tr('The backup was successfully restored, it is advised to reboot the system now in order to apply all configuration changes.')),
					$('<input />')
						.addClass('cbi-button')
						.attr('type', 'button')
						.attr('value', L.tr('Reboot system'))
						.click(function () { alert('Reboot...'); })
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
			else {
				L.ui.dialog(
					L.tr('Backup restore'), [
					$('<p />').text(L.tr('Backup restoration failed, the "sysupgrade" command responded with the message below:')),
					$('<pre />')
						.addClass('alert error')
						.text(res.stdout || res.stderr),
					$('<p />').text(L.tr('Backup restoration failed with code %d.').format(res.code))
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
	},

	handleReset: function () {
		var self = this;
		L.ui.dialog(L.tr('Really reset all changes?'), L.tr('This will reset the system to its initial configuration, all changes made since the initial flash will be lost!'), {
			style: 'confirm',
			confirm: function () {
				self.startReset().then(function () {
					L.ui.reconnect();
				});

				L.ui.showAlert(
					'success',
					'Reset Complete',
					'Settings reset successfully.'
				);

			}

		});


	},

	execute: function () {
		var self = this;
		var currentVersion = "1.00";
		self.uciGet("boardconfig", "board", "FirmwareVer").then(function (value) {
			currentVersion = value;
		});

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
				$('#btn_flash, #btn_reset', '#btn_retainconfig_flash', 'btn_factory_reset').prop('disabled', true);
			}
			else {
				$('#btn_flash').click(function () { self.handleFlashUpload(currentVersion); });
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

		$('#btn_factory_reset').click(function () {
			showDialog(
				null, 'warning',
				'Factory Reset',
				"This will Reset device to factory defaults.! Are you sure you want to Reset? Please click on 'Yes' to confirm.",
				'Yes',
				'Cancel',
				function (ok) {
					if (ok === 1)
						self.factoryresetfun().then(function (rv) {
							//alert("Factory reset fun");
							L.ui.loading(false);
							// L.ui.dialog(
							// 	L.tr('Show Status'), [
							// 	$('<pre />')
							// 		.addClass('alert alert-success')
							// 		.text(rv)
							// ],

							// 	{
							// 		style: 'close',
							// 		close: function () {
							// 			location.reload();
							// 		}
							// 	}

							// );
							// L.ui.dialog(false)
							L.ui.showAlert(
								'success',
								'Reset Complete',
								'Settings reset successfully.'
							);

						});
				}
			);
		});



		showDialog = function (ev, type, title, message, confirmText, cancelText, callback) {
			try { if (ev && ev.preventDefault) ev.preventDefault(); } catch (e) { }

			// allow skipping some args: if message is function, it's callback
			if (typeof message === 'function') {
				callback = message;
				message = title;
				title = type;
				type = 'info';
			}

			L.ui.showAlert(
				type || 'info',
				L.tr(title || 'Confirm'),
				L.tr(message || 'Are you sure?'),
				{
					sticky: true,
					confirmText: L.tr(confirmText || 'OK'),
					cancelText: cancelText ? L.tr(cancelText) : undefined,

					confirm: function () {
						if (typeof callback === 'function') callback(1);
					},

					cancel: function () {
						// cancel: show cancelled message (optional) and call callback with 0
						L.ui.showAlert('info', L.tr('Cancelled'), L.tr('Action aborted.'));
						if (typeof callback === 'function') callback(0);
					}
				}
			);
		};

	}
});
