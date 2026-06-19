L.ui.view.extend({
	title: L.tr('Import / Export Gateway Configuration'),


	RebootSystem: L.rpc.declare({
        object: 'rpc-importexportgateway',
        method: 'rebootsys',
        expect: { output: '' }
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
		params: [ 'data' ]
	}),

	listBackup: L.rpc.declare({
		object: 'luci2.system',
		method: 'backup_list',
		expect: { files: [ ] }
	}),

	testReset: L.rpc.declare({
		object: 'luci2.system',
		method: 'reset_test',
		expect: { supported: false }
	}),
	
	 
    TestArchive: L.rpc.declare({
			object: 'rpc-importexportgateway',
			method: 'testarchive',
			params: ['archive'],
			expect: { output: '' }
	}),

	startReset: L.rpc.declare({
		object: 'luci2.system',
		method: 'reset_start'
	}),
	
	 
    ResetGateway: L.rpc.declare({
			object: 'rpc-importexportgateway',
			method: 'resetgateway',
			expect: { output: '' }
	}),



	handleBackupUpload: function() {
		var self = this;
		L.ui.upload(
			L.tr('Backup restore'),
			L.tr('Select the backup archive to restore and click "%s" to proceed.').format(L.tr('Ok')), {
				filename: '/tmp/backup.txt',
				success: function(info) {
					self.handleBackupVerify(info);
				}
			}
		);
	},

	handleBackupVerify: function(info) {
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
				confirm: function(info) {
					self.handleBackupRestore(info);
				}
			}
		);
	},

	handleBackupRestore: function(info) {
		var self = this;
		var archive=$('[name=filename]').val();

		//self.restoreBackup().then(function(res) {
		self.TestArchive().then(function(TestArchiveOutput){
			
			var res=TestArchiveOutput.localeCompare("")
			
			if (res == 0)
			{
				L.ui.dialog(
					L.tr('Backup restore'), [
						$('<p />').text(L.tr('The backup was successfully restored, it is advised to reboot the system after 2 minutes in order to apply all configuration changes.')),
						$('<input />')
							.addClass('cbi-button')
							.attr('type', 'button')
							.attr('value', L.tr('Reboot system'))
							.click(function() {								
								//alert('Rebooting the system...'); 
								self.RebootSystem().then(function(rv) {
								//alert(rv);
				                   });
							})
					], {
						style: 'close',
						close: function() {
							self.cleanBackup().then(function() {
								L.ui.dialog(false);
							});
						}
					}
				);
			}
			else
			{
				L.ui.dialog(
					L.tr('Backup restore'), [
						$('<p />').text(L.tr('Invalid Archive.Please upload valid archive.')),
						$('<pre />')
							.addClass('alert-message')
							.text(res.stdout || res.stderr),
						//$('<p />').text(L.tr('Backup restoration failed with code %d.').format(res.code))
					], {
						style: 'close',
						close: function() {
							self.cleanBackup().then(function() {
								L.ui.dialog(false);
							});
						}
					}
				);
			}
		});
	},

	handleBackupDownload: function() {
		var form = $('#btn_backup').parent();

		form.find('[name=sessionid]').val(L.globals.sid);
		form.submit();
	},

	handleReset: function() {
		var self = this;
		L.ui.dialog(L.tr('Really reset all changes?'), L.tr('This will reset the system to its initial configuration, all changes made since the initial flash will be lost!'), {
			style: 'confirm',
			confirm: function() {
				self.startReset().then(function() {
					L.ui.reconnect();
				});

				//alert('Reset...');
			}
		});
	},
	
	
	
		//handleResetGateway: function() {
		//var self = this;
		//L.ui.dialog(L.tr('Really reset all changes?'), L.tr('This will reset the system to its initial configuration, all changes made since the initial flash will be lost!'), {
			//style: 'confirm',
			//confirm: function() {
				//self.startResetGateway().then(function() {
					//L.ui.reconnect();
				//});

				////alert('Reset...');
			//}
		//});
	//},
	
	
	
	
	
	handleResetGateway: function(info) {
		var self = this;
		

		//self.restoreBackup().then(function(res) {
		self.ResetGateway().then(function(ResetGateway){
			
		
			
				L.ui.dialog(
					L.tr('Reset Gateway'), [
						$('<p />').text(L.tr('Reset Gateway Configurations done successfully.')),
						//$('<input />')
							//.addClass('cbi-button')
							//.attr('type', 'button')
							//.attr('value', L.tr('Reset Gateway'))
							//.click(function() {								
								////alert('Reset the system...'); 
								//self.ResetGateway().then(function(rv) {
								////alert(rv);
				                   //});
							//})
					], {
						  style: 'close',
							
							close: function() {
								self.ResetGateway().then(function() {
									L.ui.dialog(false);
								});
							} 
						}
					);
				});
			},
				
	
		//handleResetGateway: function() {
		//var self = this;
		//L.ui.dialog(L.tr('Really reset all changes?'), L.tr('This will reset the system to its initial configuration, all changes made since the initial flash will be lost!'), {
			//style: 'confirm',
			//confirm: function() {
				//self.startResetGateway().then(function() {
					//L.ui.reconnect();
				//});

				////alert('Reset...');
			//}
		//});
	//},
	
	
	
	

	execute: function() {
		var self = this;

		self.testReset().then(function(reset_avail) {
			if (!reset_avail) {
				$('#btn_reset').prop('disabled', true);
			}

			if (!self.options.acls.backup) {
				$('#btn_restore, #btn_save, textarea').prop('disabled', true);
			}
			else {
				$('#btn_backup').click(function() { self.handleBackupDownload(); });
				$('#btn_restore').click(function() { self.handleBackupUpload(); });
			}

			if (!self.options.acls.upgrade) {
				$('#btn_flash, #btn_reset','#btn_retainconfig_flash').prop('disabled', true);
			}
			else {
				
				$('#btn_reset').click(function() { self.handleReset(); });
				
			}

			return self.getBackupConfig();
		}).then(function(config) {
			$('textarea')
				.attr('rows', (config.match(/\n/g) || [ ]).length + 1)
				.val(config);

			$('#btn_save')
				.click(function() {
					var data = ($('textarea').val() || '').replace(/\r/g, '').replace(/\n?$/, '\n');
					L.ui.loading(true);
					self.setBackupConfig(data).then(function() {
						$('textarea')
							.attr('rows', (data.match(/\n/g) || [ ]).length + 1)
							.val(data);

						L.ui.loading(false);
					});
				});

			$('#btn_list')
				.click(function() {
					L.ui.loading(true);
					self.listBackup().then(function(list) {
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
		
//		 return m.insertInto('#map');

   $('#btn_reset').click(function() { self.handleResetGateway(); });
   
//});
   

	}
});

