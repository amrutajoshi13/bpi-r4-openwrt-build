(function () {
	var ui_class = {
		saveScrollTop: function () {
			this._scroll_top = $(document).scrollTop();
		},
		sessionUserName: {
			userName: "confirm"
		},

		restoreScrollTop: function () {
			if (typeof (this._scroll_top) == 'undefined')
				return;

			$(document).scrollTop(this._scroll_top);

			delete this._scroll_top;
		},

		loading: function (enable) {
			var win = $(window);
			var body = $('body');

			var state = this._loading || (this._loading = {
				modal: $('<div />')
					.css('z-index', 2000)
					.addClass('modal fade')
					.append($('<div />')
						.addClass('modal-dialog')
						.append($('<div />')
							.addClass('modal-content luci2-modal-loader')
							.append($('<div />')
								.addClass('modal-body')
								.text(L.tr('Loading data...')))))
					.appendTo(body)
					.modal({
						backdrop: 'static',
						keyboard: false
					})
			});

			state.modal.modal(enable ? 'show' : 'hide');
		},

		dialog: function (title, content, options) {
			var win = $(window);
			var body = $('body');
			var self = this;

			var state = this._dialog || (this._dialog = {
				dialog: $('<div />')
					.addClass('modal fade')
					.append($('<div />')
						.addClass('modal-dialog loginpopup')
						.append($('<div />')
							.addClass('modal-content')
							.append($('<div />')
								.addClass('modal-header')
								.append('<img src="/luci2/icons/custom_logo.svg"/>')
								.addClass('modal-title'))
							.append($('<div />')
								.addClass('modal-body'))
							.append($('<div />')
								.addClass('modal-footer')
								.append(self.button(L.tr('Close'), 'primary')
									.click(function () {
										$(this).parents('div.modal').modal('hide');
									})))))
					.appendTo(body)
			});

			if (typeof (options) != 'object')
				options = {};

			if (title === false) {
				state.dialog.modal('hide');

				return state.dialog;
			}

			var cnt = state.dialog.children().children().children('div.modal-body');
			var ftr = state.dialog.children().children().children('div.modal-footer');

			ftr.empty().show();

			if (options.style == 'confirm') {
				ftr.append(L.ui.button(L.tr('Apply'), 'primary')
					.click(options.confirm || function () { L.ui.dialog(false) }));

				ftr.append(L.ui.button(L.tr('Cancel'), 'default')
					.click(options.cancel || function () { L.ui.dialog(false) }));
			}
			else if (options.style == 'close') {
				ftr.append(L.ui.button(L.tr('Close'), 'primary')
					.click(options.close || function () { L.ui.dialog(false) }));
			}
			else if (options.style == 'wait') {
				ftr.append(L.ui.button(L.tr('Close'), 'primary')
					.attr('disabled', true));
			}

			if (options.wide) {
				state.dialog.addClass('wide');
			}
			else {
				state.dialog.removeClass('wide');
			}

			state.dialog.find('h4:first').text(title);
			state.dialog.modal('show');

			cnt.empty().append(content);

			return state.dialog;
		},





		updateinterfaceconfig: L.rpc.declare({
			object: 'rpc-routeractions',
			method: 'configure',
			params: ['type', 'jsonData'],
			expect: { output: '' }
		}),

		routeractions: function (rv) {
			var self = this;
			L.ui.loading(true)
			var type = rv
			if (type === 'reboot') {
				L.ui.loading(false)
				L.ui.showAlert(
					'success',
					'Router Rebooted',
					'SUCCESS: The router has been rebooted successfully!'
				);
			}
			self.updateinterfaceconfig(type).then(function (rv) {
				L.ui.loading(false)
				if (type === 'network') {
					L.ui.showAlert(
						'success',
						'Network Restarted',
						rv
					);
				}
			})
		},




		initActions: function () {
			const actionsTrigger = document.getElementById('actionsTrigger') || document.getElementById('actionTrigger');
			const actionsPanel = document.getElementById('actionsPanel');
			const closeActionsBtn = document.getElementById('closeActions');

			if (!actionsTrigger || !actionsPanel) return;
			if (actionsPanel.__actionsInit) return;              // already initialized
			actionsPanel.__actionsInit = true;

			function openActionsPanel() {
				const rect = actionsTrigger.getBoundingClientRect();
				actionsPanel.style.display = 'block';
				const rightPx = Math.max(12, Math.round(window.innerWidth - rect.right + 12));
				actionsPanel.style.right = rightPx + 'px';
				actionsPanel.style.top = (rect.bottom + 1) + 'px';
				requestAnimationFrame(() => actionsPanel.classList.add('show'));
				actionsPanel.setAttribute('aria-hidden', 'false');

				// focus first action for keyboard users
				const first = actionsPanel.querySelector('.action-item');
				if (first) first.focus();
			}

			function closeActionsPanel() {
				actionsPanel.classList.remove('show');
				setTimeout(() => {
					if (!actionsPanel.classList.contains('show')) actionsPanel.style.display = 'none';
				}, 180);
				actionsPanel.setAttribute('aria-hidden', 'true');
				try { actionsTrigger.focus(); } catch (e) { /* ignore */ }
			}
			if (actionsPanel.classList.contains('show')) closeActionsPanel();
			else openActionsPanel();
			// toggle on trigger
			actionsTrigger.addEventListener('click', (e) => {
				e.stopPropagation();
				if (actionsPanel.classList.contains('show')) closeActionsPanel();
				else openActionsPanel();
			});

			// close button
			closeActionsBtn && closeActionsBtn.addEventListener('click', (e) => {
				e.stopPropagation();
				closeActionsPanel();
			});

			// click outside closes
			document.addEventListener('click', (e) => {
				if (actionsPanel.classList.contains('show') &&
					!actionsPanel.contains(e.target) &&
					!actionsTrigger.contains(e.target)) {
					closeActionsPanel();
				}
			});

			// keyboard: Enter/Space on trigger opens; Esc closes
			actionsTrigger.addEventListener('keydown', (e) => {
				if (e.key === 'Enter' || e.key === ' ') { e.preventDefault(); actionsTrigger.click(); }
			});
			document.addEventListener('keydown', (e) => {
				if ((e.key === 'Escape' || e.key === 'Esc') && actionsPanel.classList.contains('show')) closeActionsPanel();
			});


			// Keyboard support for .action-item
			document.addEventListener('keydown', (e) => {
				const item = e.target.closest('.action-item');
				if (!item) return;
				if (e.key === 'Enter' || e.key === ' ') {
					e.preventDefault();
					item.querySelector('.icon-btn')?.click();
					return;
				}
				if (e.key === 'ArrowDown' || e.key === 'ArrowUp') {
					e.preventDefault();
					const items = Array.from(document.querySelectorAll('.action-item'));
					const i = items.indexOf(item);
					const nextIndex = e.key === 'ArrowDown'
						? Math.min(i + 1, items.length - 1)
						: Math.max(i - 1, 0);
					items[nextIndex]?.focus();
				}
			});


			// clicking an action - item
			actionsPanel.addEventListener('click', (e) => {
				if (e.target.closest('.icon-btn')) return;
				const item = e.target.closest('.action-item');
				if (!item) return;
				const btn = item.querySelector('.icon-btn');
				if (btn) btn.click();
			});
		},




		actionsPanel: function () {
			var body = $("body");


			var state = this._actionsPanel || (this._actionsPanel = {
				container: $("<div/>").appendTo(body)
			});


			if (state.panel) {
				return state.panel;
			}

			//  create an icon with an img tag
			function iconImg(src, alt) {
				return $('<div/>').addClass('ai-icon').append(
					$('<img/>').attr({ src: src, alt: alt, draggable: false })
				);
			}


			var panel = $('<div />')
				.attr('id', 'actionsPanel')
				.addClass('actions-card')
				.attr('role', 'dialog')
				.attr('aria-modal', 'false')
				.attr('aria-labelledby', 'actionsTitle')
				.css({
					display: 'none',
					right: '10px',
					top: '45px'
				})

				// Header
				.append(
					$('<div />').addClass('card-header')
						.append(
							$('<div />')
								.append($('<h6 />').attr('id', 'actionsTitle').text('Router Actions'))
								.append($('<div />')
									.addClass('sub')
									.text('Quick controls — reboot, restart, logout')
									.attr('style', 'font-size:11px;color:rgba(255,255,255,0.95);margin-top:4px'))
						)
						.append(
							$('<div />').css('margin-left', 'auto')
								.append($('<button />')
									.addClass('btn-close btn-close-white')
									.attr('id', 'closeActions')
									.attr('aria-label', 'Close actions')
									.attr('style', 'filter:brightness(2) invert(1);')
								)
						)
				)

				// Body
				.append(
					$('<div />').addClass('card-body')

						// Reboot (first)
						.append(
							$('<div />').addClass('action-item').attr({ tabindex: 0, 'data-action': 'reboot', id: 'rebootBtn', title: 'Reboot' })
								.append(iconImg('/luci2/icons/power-off.svg', 'power off'))
								.append(
									$('<div />').addClass('ai-text')
										.append($('<div />').addClass('title').text('Reboot Router'))
										.append($('<div />').addClass('desc').text('Restart the router (brief disconnect).'))
								)
						)

						// Restart Network (second)
						.append(
							$('<div />').addClass('action-item').attr({ tabindex: 0, 'data-action': 'restart', id: 'netRestartBtn', title: 'Restart' })
								.append(iconImg('/luci2/icons/network-wired.svg', 'network'))
								.append(
									$('<div />').addClass('ai-text')
										.append($('<div />').addClass('title').text('Restart Network'))
										.append($('<div />').addClass('desc').text('Restart interfaces & apply changes.'))
								)
						)

						// Change Password (third)
						.append(
							$('<div />').addClass('action-item').attr({ tabindex: 0, 'data-action': 'password', id: 'passwordBtn', title: 'Change password' })
								.append(
									// keep inline style you had for this icon (blue-ish)
									$('<div/>').addClass('ai-icon').attr('style', 'background:linear-gradient(180deg,#eef6ff,#eaf3ff); color:#135fb4;')
										.append($('<img/>').attr({ src: '/luci2/icons/key-solid.svg', alt: 'key', draggable: false }))
								)
								.append(
									$('<div />').addClass('ai-text')
										.append($('<div />').addClass('title').text('Change Password'))
										.append($('<div />').addClass('desc').text('Update your admin login credentials.'))
								)
						)

						// Logout (fourth)
						.append(
							$('<div />').addClass('action-item').attr({ tabindex: 0, 'data-action': 'logout', id: 'logoutBtn', title: 'Logout' })
								.append(iconImg('/luci2/icons/right-from-bracket.svg', 'logout'))
								.append(
									$('<div />').addClass('ai-text')
										.append($('<div />').addClass('title').text('Logout'))
										.append($('<div />').addClass('desc').text('Sign out of admin.'))
								)
						)
				)


				.append(
					$('<div />').addClass('card-footer')
						.append($('<div />').css({ 'font-size': '12.5px', color: 'var(--muted)' })
							.html(' <span id="serverTime"></span>'))
				);

			panel.appendTo('#router_actions');
			state.panel = panel;
			var info = localStorage.getItem('login_info');
			$('#serverTime').html(info);
			return panel;
		},


		attachHelpTooltip: function ($group) {
			try {
				var $cols = $group.find('> .col-lg-5');
				if (!$cols.length) return;
				var $desc = $($cols[$cols.length - 1]);
				var text = $.trim($desc.text());
				if (!text) return;
				if ($group.data('_fancyAttached')) return;
				$group.data('_fancyAttached', true);

				$desc.empty().addClass('fancy-inline');


				var $icons = $('<div class="luci-fancy-icons" aria-hidden="false"></div>');
				var $infoBtn = $('<button type="button" class="luci-fancy-btn" aria-haspopup="true" aria-label="Details"></button>');

				var svgInfo = '<svg width="16" height="16" viewBox="0 0 24 24" aria-hidden="true" xmlns="http://www.w3.org/2000/svg">'
					+ '<circle cx="12" cy="12" r="10" fill="currentColor"/>'
					+ '<rect x="11" y="6.5" width="2" height="2" rx="0.4" fill="#fff"/>'
					+ '<rect x="11" y="10" width="2" height="6" rx="0.4" fill="#fff"/>'
					+ '</svg>';

				$infoBtn.html(svgInfo);
				$icons.append($infoBtn);
				$desc.append($icons);

				var $tip = $('<div class="luci-fancy-tip" role="dialog" aria-hidden="true"></div>').appendTo('body');

				function showTip($btn) {
					$tip.empty();
					$('<h4/>').text($group.find('label.control-label').text() || 'Info').appendTo($tip);
					$('<div/>').text(text).appendTo($tip);
					// $('<div class="luci-fancy-meta"/>').text('Hover or tap outside to dismiss.').appendTo($tip);
					positionTip($btn);
					$tip.addClass('show').attr('aria-hidden', 'false');
				}
				function hideTip() { $tip.removeClass('show').attr('aria-hidden', 'true'); }
				function positionTip($btn) {
					if (window.matchMedia('(max-width:640px)').matches) {
						$tip.css({ top: '', left: '', right: '', bottom: '18px', position: 'fixed' });
						return;
					}
					var off = $btn.offset();
					var top = off.top + $btn.outerHeight() + 8;
					var left = off.left;
					$tip.css({ top: top + 'px', left: left + 'px', position: 'absolute' });
					var tw = $tip.outerWidth(), winW = $(window).width();
					if (left + tw > winW - 12) left = Math.max(winW - tw - 12, 8), $tip.css({ left: left + 'px' });
				}

				var pointerFine = window.matchMedia('(pointer:fine)').matches;
				if (pointerFine) {
					$infoBtn.on('mouseenter focus', function () { showTip($(this)); });
					$infoBtn.on('mouseleave blur', function () { hideTip(); });
				}
				$infoBtn.on('click', function (e) {
					e.stopPropagation();
					if ($tip.hasClass('show')) hideTip(); else showTip($(this));
				});

				$infoBtn.on('keydown', function (e) { if (e.key === 'Enter' || e.key === ' ') { e.preventDefault(); $(this).click(); } });
				$(document).on('click.fancyTip', function (e) { if (!$(e.target).closest('.luci-fancy-tip, .luci-fancy-btn').length) hideTip(); });
				$(document).on('keydown.fancyTip', function (e) { if (e.key === 'Escape') hideTip(); });
				$(window).on('resize.fancyTip scroll.fancyTip', function () { if ($tip.hasClass('show')) positionTip($infoBtn); });

			} catch (err) {
				console && console.warn && console.warn('attachFancyTooltip error', err);
			}
		},

		upload: function (title, content, options) {
			var state = L.ui._upload || (L.ui._upload = {
				form: $('<form />')
					.attr('method', 'post')
					.attr('action', '/cgi-bin/luci-upload')
					.attr('enctype', 'multipart/form-data')
					.attr('target', 'cbi-fileupload-frame')
					.append($('<p />'))
					.append($('<input />')
						.attr('type', 'hidden')
						.attr('name', 'sessionid'))
					.append($('<input />')
						.attr('type', 'hidden')
						.attr('name', 'filename'))
					.append($('<input />')
						.attr('type', 'file')
						.attr('name', 'filedata')
						.addClass('cbi-input-file'))
					.append($('<div />')
						.css('width', '100%')
						.addClass('progress progress-striped active')
						.append($('<div />')
							.addClass('progress-bar')
							.css('width', '100%')))
					.append($('<iframe />')
						.addClass('pull-right')
						.attr('name', 'cbi-fileupload-frame')
						.css('width', '1px')
						.css('height', '1px')
						.css('visibility', 'hidden')),

				finish_cb: function (ev) {
					$(this).off('load');

					var body = (this.contentDocument || this.contentWindow.document).body;
					if (body.firstChild.tagName.toLowerCase() == 'pre')
						body = body.firstChild;

					var json;
					try {
						json = $.parseJSON(body.innerHTML);
					} catch (e) {
						json = {
							message: L.tr('Invalid server response received'),
							error: [-1, L.tr('Invalid data')]
						};
					};

					if (json.error) {
						L.ui.dialog(L.tr('File upload'), [
							$('<p />').text(L.tr('The file upload failed with the server response below:')),
							$('<pre />').addClass('alert-message').text(json.message || json.error[1]),
							$('<p />').text(L.tr('In case of network problems try uploading the file again.'))
						], { style: 'close' });
					}
					else if (typeof (state.success_cb) == 'function') {
						state.success_cb(json);
					}
				},

				confirm_cb: function () {
					var f = state.form.find('.cbi-input-file');
					var b = state.form.find('.progress');
					var p = state.form.find('p');

					if (!f.val())
						return;

					state.form.find('iframe').on('load', state.finish_cb);
					state.form.submit();

					f.hide();
					b.show();
					p.text(L.tr('File upload in progress'));

					state.form.parent().parent().find('button').prop('disabled', true);
				}
			});

			state.form.find('.progress').hide();
			state.form.find('.cbi-input-file').val('').show();
			state.form.find('p').text(content || L.tr('Select the file to upload and press "%s" to proceed.').format(L.tr('Ok')));

			state.form.find('[name=sessionid]').val(L.globals.sid);
			state.form.find('[name=filename]').val(options.filename);

			state.success_cb = options.success;

			L.ui.dialog(title || L.tr('File upload'), state.form, {
				style: 'confirm',
				confirm: state.confirm_cb
			});
		},

		firmwareUpload: function (title, content, options) {
			var state = L.ui._upload || (L.ui._upload = {
				form: $('<form />')
					.attr('method', 'post')
					.attr('action', '/cgi-bin/luci-upload')
					.attr('enctype', 'multipart/form-data')
					.attr('target', 'cbi-fileupload-frame')
					.append($('<p />'))
					.append($('<input />')
						.attr('type', 'hidden')
						.attr('name', 'sessionid'))
					.append($('<input />')
						.attr('type', 'hidden')
						.attr('name', 'filename'))
					.append($('<input />')
						.attr('type', 'file')
						.attr('name', 'filedata')
						.addClass('cbi-input-file'))
					.append($('<div />')
						.css('width', '100%')
						.addClass('progress progress-striped active')
						.append($('<div />')
							.addClass('progress-bar')
							.css('width', '100%')))
					.append($('<iframe />')
						.addClass('pull-right')
						.attr('name', 'cbi-fileupload-frame')
						.css('width', '1px')
						.css('height', '1px')
						.css('visibility', 'hidden')),

				finish_cb: function (ev) {
					$(this).off('load');
					var body = (this.contentDocument || this.contentWindow.document).body;
					if (body.firstChild.tagName.toLowerCase() == 'pre')
						body = body.firstChild;

					var json;
					try {
						json = $.parseJSON(body.innerHTML);
					} catch (e) {
						json = {
							message: L.tr('Invalid server response received'),
							error: [-1, L.tr('Invalid data')]
						};
					};

					if (json.error) {
						L.ui.dialog(L.tr('File upload'), [
							$('<p />').text(L.tr('The file upload failed with the server response below:')),
							$('<pre />').addClass('alert-message').text(json.message || json.error[1]),
							$('<p />').text(L.tr('In case of network problems try uploading the file again.'))
						], { style: 'close' });
					}
					else if (typeof (state.success_cb) == 'function') {
						state.success_cb(json, options.uploadedFileName);
					}
				},

				confirm_cb: function () {
					var f = state.form.find('.cbi-input-file');
					var b = state.form.find('.progress');
					var p = state.form.find('p');

					if (!f.val())
						return;

					state.form.find('iframe').on('load', state.finish_cb);
					state.form.submit();

					f.hide();
					b.show();
					p.text(L.tr('File upload in progress'));

					state.form.parent().parent().find('button').prop('disabled', true);
				}
			});

			state.form.find('.progress').hide();
			state.form.find('.cbi-input-file').val('').show();
			state.form.find('p').text(content || L.tr('Select the file to upload and press "%s" to proceed.').format(L.tr('Ok')));

			state.form.find('[name=sessionid]').val(L.globals.sid);
			state.form.find('[name=filename]').val(options.filename);

			state.success_cb = options.success;

			L.ui.dialog(title || L.tr('File upload'), state.form, {
				style: 'confirm',
				confirm: state.confirm_cb
			});

			$('input[type="file"]').change(function (e) {
				options.uploadedFileName = e.target.files[0].name;
				// ~ alert('The file "' + fileName +  '" has been selected.');

			});
		},


		//SNMP MIB Upload For Gateway 
		archiveSNMPUpload: function (title, content, options) {
			var state = L.ui._applicationUpload || (L.ui._applicationUpload = {

				form: $('<form />')
					.attr('method', 'post')
					.attr('action', '/cgi-bin/luci-upload')
					.attr('enctype', 'multipart/form-data')
					.attr('target', 'cbi-fileupload-frame')
					.append($('<p />'))
					.append($('<input />')
						.attr('type', 'hidden')
						.attr('name', 'sessionid'))
					.append($('<input />')
						.attr('type', 'hidden')
						.attr('name', 'filename'))
					.append($('<input />')
						.attr('type', 'file')
						.attr('name', 'filedata')
						.addClass('cbi-input-file'))
					.append($('<div />')
						.css('width', '100%')
						.addClass('progress progress-striped active')
						.append($('<div />')
							.addClass('progress-bar')
							.css('width', '100%')))
					.append($('<iframe />')
						.addClass('pull-right')
						.attr('name', 'cbi-fileupload-frame')
						.css('width', '1px')
						.css('height', '1px')
						.css('visibility', 'hidden')),

				finish_cb: function (ev) {
					$(this).off('load');

					var body = (this.contentDocument || this.contentWindow.document).body;
					if (body.firstChild.tagName.toLowerCase() == 'pre')
						body = body.firstChild;

					var json;
					try {
						json = $.parseJSON(body.innerHTML);
					} catch (e) {
						json = {
							message: L.tr('Invalid server response received'),
							error: [-1, L.tr('Invalid data')]
						};
					};

					if (json.error) {
						L.ui.dialog(L.tr('File upload'), [
							$('<p />').text(L.tr('The file upload failed with the server response below:')),
							$('<pre />').addClass('alert-message').text(json.message || json.error[1]),
							$('<p />').text(L.tr('In case of network problems try uploading the file again.'))
						], { style: 'close' });
					}
					else if (typeof (state.success_cb) == 'function') {
						state.success_cb(json);
					}
				},

				confirm_cb: function () {

					var f = state.form.find('.cbi-input-file');
					var b = state.form.find('.progress');
					var p = state.form.find('p');

					if (!f.val())
						return;

					state.form.find('iframe').on('load', state.finish_cb);
					state.form.submit();

					f.hide();
					b.show();
					p.text(L.tr('File upload in progress '));

					state.form.parent().parent().find('button').prop('disabled', true);
				}
			});

			state.form.find('.progress').hide();
			state.form.find('.cbi-input-file').val('').show();
			state.form.find('p').text(content || L.tr('Select the file to upload and press "%s" to proceed.').format(L.tr('Ok')));

			state.form.find('[name=sessionid]').val(L.globals.sid);

			state.success_cb = options.success;

			L.ui.dialog(title || L.tr('File upload'), state.form, {
				style: 'confirm',
				confirm: state.confirm_cb
			});

			$('input[type="file"]').change(function (e) {
				var fileName = e.target.files[0].name;
				//~ alert('The file "' + fileName +  '" has been selected.');
				state.form.find('[name=filename]').val("/usr/share/snmp/mibs/" + fileName);
			});
		},


		SNMPMibFileUpload: function (title, content, options) {
			var state = L.ui._applicationUpload || (L.ui._applicationUpload = {

				form: $('<form />')
					.attr('method', 'post')
					.attr('action', '/cgi-bin/luci-upload')
					.attr('enctype', 'multipart/form-data')
					.attr('target', 'cbi-fileupload-frame')
					.append($('<p />'))
					.append($('<input />')
						.attr('type', 'hidden')
						.attr('name', 'sessionid'))
					.append($('<input />')
						.attr('type', 'hidden')
						.attr('name', 'filename'))
					.append($('<input />')
						.attr('type', 'file')
						.attr('name', 'filedata')
						.addClass('cbi-input-file'))
					.append($('<div />')
						.css('width', '100%')
						.addClass('progress progress-striped active')
						.append($('<div />')
							.addClass('progress-bar')
							.css('width', '100%')))
					.append($('<iframe />')
						.addClass('pull-right')
						.attr('name', 'cbi-fileupload-frame')
						.css('width', '1px')
						.css('height', '1px')
						.css('visibility', 'hidden')),

				finish_cb: function (ev) {
					$(this).off('load');

					var body = (this.contentDocument || this.contentWindow.document).body;
					if (body.firstChild.tagName.toLowerCase() == 'pre')
						body = body.firstChild;

					var json;
					try {
						json = $.parseJSON(body.innerHTML);
					} catch (e) {
						json = {
							message: L.tr('Invalid server response received'),
							error: [-1, L.tr('Invalid data')]
						};
					};

					if (json.error) {
						L.ui.dialog(L.tr('File upload'), [
							$('<p />').text(L.tr('The file upload failed with the server response below:')),
							$('<pre />').addClass('alert-message').text(json.message || json.error[1]),
							$('<p />').text(L.tr('In case of network problems try uploading the file again.'))
						], { style: 'close' });
					}
					else if (typeof (state.success_cb) == 'function') {
						state.success_cb(json);
					}
				},

				confirm_cb: function () {

					var f = state.form.find('.cbi-input-file');
					var b = state.form.find('.progress');
					var p = state.form.find('p');

					if (!f.val())
						return;

					state.form.find('iframe').on('load', state.finish_cb);
					state.form.submit();

					f.hide();
					b.show();
					p.text(L.tr('File upload in progress '));

					state.form.parent().parent().find('button').prop('disabled', true);
				}
			});

			state.form.find('.progress').hide();
			state.form.find('.cbi-input-file').val('').show();
			state.form.find('p').text(content || L.tr('Select the file to upload and press "%s" to proceed.').format(L.tr('Ok')));

			state.form.find('[name=sessionid]').val(L.globals.sid);

			state.success_cb = options.success;

			L.ui.dialog(title || L.tr('File upload'), state.form, {
				style: 'confirm',
				confirm: state.confirm_cb
			});

			$('input[type="file"]').change(function (e) {
				var fileName = e.target.files[0].name;
				//~ alert('The file "' + fileName +  '" has been selected.');
				state.form.find('[name=filename]').val("/usr/share/snmp/mibs/" + fileName);
			});
		},


		ImageUpload: function (title, content, options) {
			var state = L.ui._applicationUpload || (L.ui._applicationUpload = {

				form: $('<form />')
					.attr('method', 'post')
					.attr('action', '/cgi-bin/luci-upload')
					.attr('enctype', 'multipart/form-data')
					.attr('target', 'cbi-fileupload-frame')
					.append($('<p />'))
					.append($('<input />')
						.attr('type', 'hidden')
						.attr('name', 'sessionid'))
					.append($('<input />')
						.attr('type', 'hidden')
						.attr('name', 'filename'))
					.append($('<input />')
						.attr('type', 'file')
						.attr('name', 'filedata')
						.addClass('cbi-input-file'))
					.append($('<div />')
						.css('width', '100%')
						.addClass('progress progress-striped active')
						.append($('<div />')
							.addClass('progress-bar')
							.css('width', '100%')))
					.append($('<iframe />')
						.addClass('pull-right')
						.attr('name', 'cbi-fileupload-frame')
						.css('width', '1px')
						.css('height', '1px')
						.css('visibility', 'hidden')),

				finish_cb: function (ev) {
					$(this).off('load');

					var body = (this.contentDocument || this.contentWindow.document).body;
					if (body.firstChild.tagName.toLowerCase() == 'pre')
						body = body.firstChild;

					var json;
					try {
						json = $.parseJSON(body.innerHTML);
					} catch (e) {
						json = {
							message: L.tr('Invalid server response received'),
							error: [-1, L.tr('Invalid data')]
						};
					};

					if (json.error) {
						L.ui.dialog(L.tr('File upload'), [
							$('<p />').text(L.tr('The file upload failed with the server response below:')),
							$('<pre />').addClass('alert-message').text(json.message || json.error[1]),
							$('<p />').text(L.tr('In case of network problems try uploading the file again.'))
						], { style: 'close' });
					}
					else if (typeof (state.success_cb) == 'function') {
						state.success_cb(json);
					}
				},

				confirm_cb: function () {

					var f = state.form.find('.cbi-input-file');
					var b = state.form.find('.progress');
					var p = state.form.find('p');

					if (!f.val())
						return;

					state.form.find('iframe').on('load', state.finish_cb);
					state.form.submit();

					f.hide();
					b.show();
					p.text(L.tr('File upload in progress '));

					state.form.parent().parent().find('button').prop('disabled', true);
				}
			});

			state.form.find('.progress').hide();
			state.form.find('.cbi-input-file').val('').show();
			state.form.find('p').text(content || L.tr('Select the file to upload and press "%s" to proceed.').format(L.tr('Ok')));

			state.form.find('[name=sessionid]').val(L.globals.sid);

			state.success_cb = options.success;

			L.ui.dialog(title || L.tr('File upload'), state.form, {
				style: 'confirm',
				confirm: state.confirm_cb
			});

			$('input[type="file"]').change(function (e) {
				var fileName = e.target.files[0].name;
				//~ alert('The file "' + fileName +  '" has been selected.');
				state.form.find('[name=filename]').val("/root/custom_image/" + fileName);
			});
		},



		archiveUploadCustom: function (title, content, options) {
			var state = L.ui._applicationUpload || (L.ui._applicationUpload = {

				form: $('<form />')
					.attr('method', 'post')
					.attr('action', '/cgi-bin/luci-upload')
					.attr('enctype', 'multipart/form-data')
					.attr('target', 'cbi-fileupload-frame')
					.append($('<p />'))
					.append($('<input />').attr('type', 'hidden').attr('name', 'sessionid'))
					.append($('<input />').attr('type', 'hidden').attr('name', 'filename'))
					.append($('<input />').attr('type', 'file').attr('name', 'filedata').addClass('cbi-input-file'))
					.append($('<div />').css('width', '100%').addClass('progress progress-striped active')
						.append($('<div />').addClass('progress-bar').css('width', '100%')))
					.append($('<iframe />').addClass('pull-right').attr('name', 'cbi-fileupload-frame')
						.css('width', '1px').css('height', '1px').css('visibility', 'hidden')),

				finish_cb: function (ev) {
					$(this).off('load');

					var body = (this.contentDocument || this.contentWindow.document).body;
					if (body.firstChild && body.firstChild.tagName &&
						body.firstChild.tagName.toLowerCase() == 'pre') body = body.firstChild;

					var json;
					try {
						json = $.parseJSON(body.innerHTML);
					} catch (e) {
						json = {
							message: L.tr('Invalid server response received'),
							error: [-1, L.tr('Invalid data')]
						};
					}

					if (json.error) {
						L.ui.dialog(L.tr('File upload'), [
							$('<p />').text(L.tr('The file upload failed with the server response below:')),
							$('<pre />').addClass('alert-message').text(json.message || json.error[1]),
							$('<p />').text(L.tr('In case of network problems try uploading the file again.'))
						], { style: 'close' });
					} else if (typeof (state.success_cb) == 'function') {
						state.success_cb(json);
					}
				},

				confirm_cb: function () {
					var f = state.form.find('.cbi-input-file');
					var b = state.form.find('.progress');
					var p = state.form.find('p');

					if (!f.val()) return;

					state.form.find('iframe').on('load', state.finish_cb);
					state.form.submit();

					f.hide();
					b.show();
					p.text(L.tr('File upload in progress '));

					state.form.parent().parent().find('button').prop('disabled', true);
				}
			});

			state.form.find('.progress').hide();
			state.form.find('.cbi-input-file').val('').show();
			state.form.find('p').text(content || L.tr('Select the file to upload and press "%s" to proceed.').format(L.tr('Ok')));
			state.form.find('[name=sessionid]').val(L.globals.sid);
			state.success_cb = options.success;

			L.ui.dialog(title || L.tr('File upload'), state.form, {
				style: 'confirm',
				confirm: state.confirm_cb
			});

			state.form.find('.cbi-input-file').off('change').on('change', function (e) {
				var fileInput = e.target;
				if (!fileInput || !fileInput.files || fileInput.files.length === 0) {
					return;
				}
				var file = fileInput.files[0];
				var fileName = file.name || '';
				if (fileName !== 'frr.conf') {
					state.form.find('.cbi-input-file').val(''); // reset input
					L.ui.dialog(false);
					L.ui.showAlert(
						'error',
						L.tr('Invalid File Name'),
						L.tr('Only the file named "frr.conf" is allowed. Please upload the correct configuration file.')
					);
					return;
				}
				state.form.find('[name=filename]').val("/tmp/" + fileName);
			});
		},
		archiveUpload: function (title, content, options) {
			var state = L.ui._applicationUpload || (L.ui._applicationUpload = {

				form: $('<form />')
					.attr('method', 'post')
					.attr('action', '/cgi-bin/luci-upload')
					.attr('enctype', 'multipart/form-data')
					.attr('target', 'cbi-fileupload-frame')
					.append($('<p />'))
					.append($('<input />')
						.attr('type', 'hidden')
						.attr('name', 'sessionid'))
					.append($('<input />')
						.attr('type', 'hidden')
						.attr('name', 'filename'))
					.append($('<input />')
						.attr('type', 'file')
						.attr('name', 'filedata')
						.addClass('cbi-input-file'))
					.append($('<div />')
						.css('width', '100%')
						.addClass('progress progress-striped active')
						.append($('<div />')
							.addClass('progress-bar')
							.css('width', '100%')))
					.append($('<iframe />')
						.addClass('pull-right')
						.attr('name', 'cbi-fileupload-frame')
						.css('width', '1px')
						.css('height', '1px')
						.css('visibility', 'hidden')),

				finish_cb: function (ev) {
					$(this).off('load');

					var body = (this.contentDocument || this.contentWindow.document).body;
					if (body.firstChild.tagName.toLowerCase() == 'pre')
						body = body.firstChild;

					var json;
					try {
						json = $.parseJSON(body.innerHTML);
					} catch (e) {
						json = {
							message: L.tr('Invalid server response received'),
							error: [-1, L.tr('Invalid data')]
						};
					};

					if (json.error) {
						L.ui.dialog(L.tr('File upload'), [
							$('<p />').text(L.tr('The file upload failed with the server response below:')),
							$('<pre />').addClass('alert-message').text(json.message || json.error[1]),
							$('<p />').text(L.tr('In case of network problems try uploading the file again.'))
						], { style: 'close' });
					}
					else if (typeof (state.success_cb) == 'function') {
						state.success_cb(json);
					}
				},

				confirm_cb: function () {

					var f = state.form.find('.cbi-input-file');
					var b = state.form.find('.progress');
					var p = state.form.find('p');

					if (!f.val())
						return;

					state.form.find('iframe').on('load', state.finish_cb);
					state.form.submit();

					f.hide();
					b.show();
					p.text(L.tr('File upload in progress '));

					state.form.parent().parent().find('button').prop('disabled', true);
				}
			});

			state.form.find('.progress').hide();
			state.form.find('.cbi-input-file').val('').show();
			state.form.find('p').text(content || L.tr('Select the file to upload and press "%s" to proceed.').format(L.tr('Ok')));

			state.form.find('[name=sessionid]').val(L.globals.sid);

			state.success_cb = options.success;

			L.ui.dialog(title || L.tr('File upload'), state.form, {
				style: 'confirm',
				confirm: state.confirm_cb
			});

			$('input[type="file"]').change(function (e) {
				var fileName = e.target.files[0].name;
				// ~ alert('The file "' + fileName +  '" has been selected.');
				state.form.find('[name=filename]').val("/tmp/" + fileName);
			});
		},




		archiveUploadcerts: function (title, content, options) {
			var state = L.ui._applicationUpload || (L.ui._applicationUpload = {
				form: $('<form />')
					.attr('method', 'post')
					.attr('action', '/cgi-bin/luci-upload')
					.attr('enctype', 'multipart/form-data')
					.attr('target', 'cbi-fileupload-frame')
					.append($('<p />'))
					.append($('<input />')
						.attr('type', 'hidden')
						.attr('name', 'sessionid'))
					.append($('<input />')
						.attr('type', 'hidden')
						.attr('name', 'filename'))
					.append($('<input />')
						.attr('type', 'file')
						.attr('name', 'filedata')
						.addClass('cbi-input-file'))
					.append($('<div />')
						.css('width', '100%')
						.addClass('progress progress-striped active')
						.append($('<div />')
							.addClass('progress-bar')
							.css('width', '100%')))
					.append($('<iframe />')
						.addClass('pull-right')
						.attr('name', 'cbi-fileupload-frame')
						.css('width', '1px')
						.css('height', '1px')
						.css('visibility', 'hidden')),

				finish_cb: function (ev) {
					$(this).off('load');

					var body = (this.contentDocument || this.contentWindow.document).body;
					if (body.firstChild.tagName.toLowerCase() == 'pre')
						body = body.firstChild;

					var json;
					try {
						json = $.parseJSON(body.innerHTML);
					} catch (e) {
						json = {
							message: L.tr('Invalid server response received'),
							error: [-1, L.tr('Invalid data')]
						};
					};

					if (json.error) {
						L.ui.dialog(L.tr('File upload'), [
							$('<p />').text(L.tr('The file upload failed with the server response below:')),
							$('<pre />').addClass('alert-message').text(json.message || json.error[1]),
							$('<p />').text(L.tr('In case of network problems try uploading the file again.'))
						], { style: 'close' });
					}
					else if (typeof (state.success_cb) == 'function') {
						state.success_cb(json);
					}
				},

				confirm_cb: function () {
					var f = state.form.find('.cbi-input-file');
					var b = state.form.find('.progress');
					var p = state.form.find('p');

					if (!f.val())
						return;

					state.form.find('iframe').on('load', state.finish_cb);
					state.form.submit();

					f.hide();
					b.show();
					p.text(L.tr('File upload in progress '));

					state.form.parent().parent().find('button').prop('disabled', true);
				}
			});

			state.form.find('.progress').hide();
			state.form.find('.cbi-input-file').val('').show();
			state.form.find('p').text(content || L.tr('Select the file to upload and press "%s" to proceed.').format(L.tr('Ok')));

			state.form.find('[name=sessionid]').val(L.globals.sid);

			state.success_cb = options.success;

			L.ui.dialog(title || L.tr('File upload'), state.form, {
				style: 'confirm',
				confirm: state.confirm_cb
			});

			$('input[type="file"]').change(function (e) {
				var fileName = e.target.files[0].name;
				//~ alert('The file "' + fileName +  '" has been selected.');
				state.form.find('[name=filename]').val("/etc/openvpn/" + fileName);
			});
		},
		archiveUploadcertshttps: function (title, content, options) {
			var state = L.ui._applicationUpload || (L.ui._applicationUpload = {

				form: $('<form />')
					.attr('method', 'post')
					.attr('action', '/cgi-bin/luci-upload')
					.attr('enctype', 'multipart/form-data')
					.attr('target', 'cbi-fileupload-frame')
					.append($('<p />'))
					.append($('<input />')
						.attr('type', 'hidden')
						.attr('name', 'sessionid'))
					.append($('<input />')
						.attr('type', 'hidden')
						.attr('name', 'filename'))
					.append($('<input />')
						.attr('type', 'file')
						.attr('name', 'filedata')
						.addClass('cbi-input-file'))
					.append($('<div />')
						.css('width', '100%')
						.addClass('progress progress-striped active')
						.append($('<div />')
							.addClass('progress-bar')
							.css('width', '100%')))
					.append($('<iframe />')
						.addClass('pull-right')
						.attr('name', 'cbi-fileupload-frame')
						.css('width', '1px')
						.css('height', '1px')
						.css('visibility', 'hidden')),

				finish_cb: function (ev) {
					$(this).off('load');

					var body = (this.contentDocument || this.contentWindow.document).body;
					if (body.firstChild.tagName.toLowerCase() == 'pre')
						body = body.firstChild;

					var json;
					try {
						json = $.parseJSON(body.innerHTML);
					} catch (e) {
						json = {
							message: L.tr('Invalid server response received'),
							error: [-1, L.tr('Invalid data')]
						};
					};

					if (json.error) {
						L.ui.dialog(L.tr('File upload'), [
							$('<p />').text(L.tr('The file upload failed with the server response below:')),
							$('<pre />').addClass('alert-message').text(json.message || json.error[1]),
							$('<p />').text(L.tr('In case of network problems try uploading the file again.'))
						], { style: 'close' });
					}
					else if (typeof (state.success_cb) == 'function') {
						state.success_cb(json);
					}
				},

				confirm_cb: function () {

					var f = state.form.find('.cbi-input-file');
					var b = state.form.find('.progress');
					var p = state.form.find('p');

					if (!f.val())
						return;

					state.form.find('iframe').on('load', state.finish_cb);
					state.form.submit();

					f.hide();
					b.show();
					p.text(L.tr('File upload in progress '));

					state.form.parent().parent().find('button').prop('disabled', true);
				}
			});

			state.form.find('.progress').hide();
			state.form.find('.cbi-input-file').val('').show();
			state.form.find('p').text(content || L.tr('Select the file to upload and press "%s" to proceed.').format(L.tr('Ok')));

			state.form.find('[name=sessionid]').val(L.globals.sid);

			state.success_cb = options.success;

			L.ui.dialog(title || L.tr('File upload'), state.form, {
				style: 'confirm',
				confirm: state.confirm_cb
			});

			$('input[type="file"]').change(function (e) {
				var fileName = e.target.files[0].name;
				//~ alert('The file "' + fileName +  '" has been selected.');
				state.form.find('[name=filename]').val("/etc/ssl/certs/" + fileName);
			});
		},

		archiveUploadcertshttps2: function (title, content, options) {
			var state = L.ui._applicationUpload || (L.ui._applicationUpload = {

				form: $('<form />')
					.attr('method', 'post')
					.attr('action', '/cgi-bin/luci-upload')
					.attr('enctype', 'multipart/form-data')
					.attr('target', 'cbi-fileupload-frame')
					.append($('<p />'))
					.append($('<input />')
						.attr('type', 'hidden')
						.attr('name', 'sessionid'))
					.append($('<input />')
						.attr('type', 'hidden')
						.attr('name', 'filename'))
					.append($('<input />')
						.attr('type', 'file')
						.attr('name', 'filedata')
						.addClass('cbi-input-file'))
					.append($('<div />')
						.css('width', '100%')
						.addClass('progress progress-striped active')
						.append($('<div />')
							.addClass('progress-bar')
							.css('width', '100%')))
					.append($('<iframe />')
						.addClass('pull-right')
						.attr('name', 'cbi-fileupload-frame')
						.css('width', '1px')
						.css('height', '1px')
						.css('visibility', 'hidden')),

				finish_cb: function (ev) {
					$(this).off('load');

					var body = (this.contentDocument || this.contentWindow.document).body;
					if (body.firstChild.tagName.toLowerCase() == 'pre')
						body = body.firstChild;

					var json;
					try {
						json = $.parseJSON(body.innerHTML);
					} catch (e) {
						json = {
							message: L.tr('Invalid server response received'),
							error: [-1, L.tr('Invalid data')]
						};
					};

					if (json.error) {
						L.ui.dialog(L.tr('File upload'), [
							$('<p />').text(L.tr('The file upload failed with the server response below:')),
							$('<pre />').addClass('alert-message').text(json.message || json.error[1]),
							$('<p />').text(L.tr('In case of network problems try uploading the file again.'))
						], { style: 'close' });
					}
					else if (typeof (state.success_cb) == 'function') {
						state.success_cb(json);
					}
				},

				confirm_cb: function () {

					var f = state.form.find('.cbi-input-file');
					var b = state.form.find('.progress');
					var p = state.form.find('p');

					if (!f.val())
						return;

					state.form.find('iframe').on('load', state.finish_cb);
					state.form.submit();

					f.hide();
					b.show();
					p.text(L.tr('File upload in progress '));

					state.form.parent().parent().find('button').prop('disabled', true);
				}
			});

			state.form.find('.progress').hide();
			state.form.find('.cbi-input-file').val('').show();
			state.form.find('p').text(content || L.tr('Select the file to upload and press "%s" to proceed.').format(L.tr('Ok')));

			state.form.find('[name=sessionid]').val(L.globals.sid);

			state.success_cb = options.success;

			L.ui.dialog(title || L.tr('File upload'), state.form, {
				style: 'confirm',
				confirm: state.confirm_cb
			});

			$('input[type="file"]').change(function (e) {
				var fileName = e.target.files[0].name;
				//~ alert('The file "' + fileName +  '" has been selected.');
				state.form.find('[name=filename]').val("/etc/ssl/certs/" + fileName);
			});
		},
		archiveUploadtestapp: function (title, content, options) {
			var state = L.ui._applicationUpload || (L.ui._applicationUpload = {

				form: $('<form />')
					.attr('method', 'post')
					.attr('action', '/cgi-bin/luci-upload')
					.attr('enctype', 'multipart/form-data')
					.attr('target', 'cbi-fileupload-frame')
					.append($('<p />'))
					.append($('<input />')
						.attr('type', 'hidden')
						.attr('name', 'sessionid'))
					.append($('<input />')
						.attr('type', 'hidden')
						.attr('name', 'filename'))
					.append($('<input />')
						.attr('type', 'file')
						.attr('name', 'filedata')
						.addClass('cbi-input-file'))
					.append($('<div />')
						.css('width', '100%')
						.addClass('progress progress-striped active')
						.append($('<div />')
							.addClass('progress-bar')
							.css('width', '100%')))
					.append($('<iframe />')
						.addClass('pull-right')
						.attr('name', 'cbi-fileupload-frame')
						.css('width', '1px')
						.css('height', '1px')
						.css('visibility', 'hidden')),

				finish_cb: function (ev) {
					$(this).off('load');

					var body = (this.contentDocument || this.contentWindow.document).body;
					if (body.firstChild.tagName.toLowerCase() == 'pre')
						body = body.firstChild;

					var json;
					try {
						json = $.parseJSON(body.innerHTML);
					} catch (e) {
						json = {
							message: L.tr('Invalid server response received'),
							error: [-1, L.tr('Invalid data')]
						};
					};

					if (json.error) {
						L.ui.dialog(L.tr('File upload'), [
							$('<p />').text(L.tr('The file upload failed with the server response below:')),
							$('<pre />').addClass('alert-message').text(json.message || json.error[1]),
							$('<p />').text(L.tr('In case of network problems try uploading the file again.'))
						], { style: 'close' });
					}
					else if (typeof (state.success_cb) == 'function') {
						state.success_cb(json);
					}
				},

				confirm_cb: function () {

					var f = state.form.find('.cbi-input-file');
					var b = state.form.find('.progress');
					var p = state.form.find('p');

					if (!f.val())
						return;

					state.form.find('iframe').on('load', state.finish_cb);
					state.form.submit();

					f.hide();
					b.show();
					p.text(L.tr('File upload in progress'));

					state.form.parent().parent().find('button').prop('disabled', true);
				}
			});

			state.form.find('.progress').hide();
			state.form.find('.cbi-input-file').val('').show();
			state.form.find('p').text(content || L.tr('Select the file to upload and press "%s" to proceed.').format(L.tr('Ok')));

			state.form.find('[name=sessionid]').val(L.globals.sid);

			state.success_cb = options.success;

			L.ui.dialog(title || L.tr('File upload'), state.form, {
				style: 'confirm',
				confirm: state.confirm_cb
			});

			$('input[type="file"]').change(function (e) {
				var fileName = e.target.files[0].name;
				//~ alert('The file "' + fileName +  '" has been selected.');
				state.form.find('[name=filename]').val("/root/Test_APP/" + fileName);
			});
		},

		archiveUploadcertstlshealth: function (title, content, options) {
			var state = L.ui._applicationUpload || (L.ui._applicationUpload = {

				form: $('<form />')
					.attr('method', 'post')
					.attr('action', '/cgi-bin/luci-upload')
					.attr('enctype', 'multipart/form-data')
					.attr('target', 'cbi-fileupload-frame')
					.append($('<p />'))
					.append($('<input />')
						.attr('type', 'hidden')
						.attr('name', 'sessionid'))
					.append($('<input />')
						.attr('type', 'hidden')
						.attr('name', 'filename'))
					.append($('<input />')
						.attr('type', 'file')
						.attr('name', 'filedata')
						.addClass('cbi-input-file'))
					.append($('<div />')
						.css('width', '100%')
						.addClass('progress progress-striped active')
						.append($('<div />')
							.addClass('progress-bar')
							.css('width', '100%')))
					.append($('<iframe />')
						.addClass('pull-right')
						.attr('name', 'cbi-fileupload-frame')
						.css('width', '1px')
						.css('height', '1px')
						.css('visibility', 'hidden')),

				finish_cb: function (ev) {
					$(this).off('load');

					var body = (this.contentDocument || this.contentWindow.document).body;
					if (body.firstChild.tagName.toLowerCase() == 'pre')
						body = body.firstChild;

					var json;
					try {
						json = $.parseJSON(body.innerHTML);
					} catch (e) {
						json = {
							message: L.tr('Invalid server response received'),
							error: [-1, L.tr('Invalid data')]
						};
					};

					if (json.error) {
						L.ui.dialog(L.tr('File upload'), [
							$('<p />').text(L.tr('The file upload failed with the server response below:')),
							$('<pre />').addClass('alert-message').text(json.message || json.error[1]),
							$('<p />').text(L.tr('In case of network problems try uploading the file again.'))
						], { style: 'close' });
					}
					else if (typeof (state.success_cb) == 'function') {
						state.success_cb(json);
					}
				},

				confirm_cb: function () {

					var f = state.form.find('.cbi-input-file');
					var b = state.form.find('.progress');
					var p = state.form.find('p');

					if (!f.val())
						return;

					state.form.find('iframe').on('load', state.finish_cb);
					state.form.submit();

					f.hide();
					b.show();
					p.text(L.tr('File upload in progress '));

					state.form.parent().parent().find('button').prop('disabled', true);
				}
			});

			state.form.find('.progress').hide();
			state.form.find('.cbi-input-file').val('').show();
			state.form.find('p').text(content || L.tr('Select the file to upload and press "%s" to proceed.').format(L.tr('Ok')));

			state.form.find('[name=sessionid]').val(L.globals.sid);

			state.success_cb = options.success;

			L.ui.dialog(title || L.tr('File upload'), state.form, {
				style: 'confirm',
				confirm: state.confirm_cb
			});

			$('input[type="file"]').change(function (e) {
				var fileName = e.target.files[0].name;
				//~ alert('The file "' + fileName +  '" has been selected.');
				state.form.find('[name=filename]').val("/root/Device_health/certificate/" + fileName);
				// state.form.find('[name=filename]').val("/root/MQTTSenderAppComponent/etc/certs/"+fileName);
			});
		},


		archiveUploadcertstls: function (title, content, options) {
			var state = L.ui._applicationUpload || (L.ui._applicationUpload = {

				form: $('<form />')
					.attr('method', 'post')
					.attr('action', '/cgi-bin/luci-upload')
					.attr('enctype', 'multipart/form-data')
					.attr('target', 'cbi-fileupload-frame')
					.append($('<p />'))
					.append($('<input />')
						.attr('type', 'hidden')
						.attr('name', 'sessionid'))
					.append($('<input />')
						.attr('type', 'hidden')
						.attr('name', 'filename'))
					.append($('<input />')
						.attr('type', 'file')
						.attr('name', 'filedata')
						.addClass('cbi-input-file'))
					.append($('<div />')
						.css('width', '100%')
						.addClass('progress progress-striped active')
						.append($('<div />')
							.addClass('progress-bar')
							.css('width', '100%')))
					.append($('<iframe />')
						.addClass('pull-right')
						.attr('name', 'cbi-fileupload-frame')
						.css('width', '1px')
						.css('height', '1px')
						.css('visibility', 'hidden')),

				finish_cb: function (ev) {
					$(this).off('load');

					var body = (this.contentDocument || this.contentWindow.document).body;
					if (body.firstChild.tagName.toLowerCase() == 'pre')
						body = body.firstChild;

					var json;
					try {
						json = $.parseJSON(body.innerHTML);
					} catch (e) {
						json = {
							message: L.tr('Invalid server response received'),
							error: [-1, L.tr('Invalid data')]
						};
					};

					if (json.error) {
						L.ui.dialog(L.tr('File upload'), [
							$('<p />').text(L.tr('The file upload failed with the server response below:')),
							$('<pre />').addClass('alert-message').text(json.message || json.error[1]),
							$('<p />').text(L.tr('In case of network problems try uploading the file again.'))
						], { style: 'close' });
					}
					else if (typeof (state.success_cb) == 'function') {
						state.success_cb(json);
					}
				},

				confirm_cb: function () {

					var f = state.form.find('.cbi-input-file');
					var b = state.form.find('.progress');
					var p = state.form.find('p');

					if (!f.val())
						return;

					state.form.find('iframe').on('load', state.finish_cb);
					state.form.submit();

					f.hide();
					b.show();
					p.text(L.tr('File upload in progress '));

					state.form.parent().parent().find('button').prop('disabled', true);
				}
			});

			state.form.find('.progress').hide();
			state.form.find('.cbi-input-file').val('').show();
			state.form.find('p').text(content || L.tr('Select the file to upload and press "%s" to proceed.').format(L.tr('Ok')));

			state.form.find('[name=sessionid]').val(L.globals.sid);

			state.success_cb = options.success;

			L.ui.dialog(title || L.tr('File upload'), state.form, {
				style: 'confirm',
				confirm: state.confirm_cb
			});

			$('input[type="file"]').change(function (e) {
				var fileName = e.target.files[0].name;
				//~ alert('The file "' + fileName +  '" has been selected.');
				state.form.find('[name=filename]').val("/root/SenderAppComponent/etc/certs/" + fileName);
			});
		},

		archiveUploadcertstls2: function (title, content, options) {
			var state = L.ui._applicationUpload || (L.ui._applicationUpload = {

				form: $('<form />')
					.attr('method', 'post')
					.attr('action', '/cgi-bin/luci-upload')
					.attr('enctype', 'multipart/form-data')
					.attr('target', 'cbi-fileupload-frame')
					.append($('<p />'))
					.append($('<input />')
						.attr('type', 'hidden')
						.attr('name', 'sessionid'))
					.append($('<input />')
						.attr('type', 'hidden')
						.attr('name', 'filename'))
					.append($('<input />')
						.attr('type', 'file')
						.attr('name', 'filedata')
						.addClass('cbi-input-file'))
					.append($('<div />')
						.css('width', '100%')
						.addClass('progress progress-striped active')
						.append($('<div />')
							.addClass('progress-bar')
							.css('width', '100%')))
					.append($('<iframe />')
						.addClass('pull-right')
						.attr('name', 'cbi-fileupload-frame')
						.css('width', '1px')
						.css('height', '1px')
						.css('visibility', 'hidden')),

				finish_cb: function (ev) {
					$(this).off('load');

					var body = (this.contentDocument || this.contentWindow.document).body;
					if (body.firstChild.tagName.toLowerCase() == 'pre')
						body = body.firstChild;

					var json;
					try {
						json = $.parseJSON(body.innerHTML);
					} catch (e) {
						json = {
							message: L.tr('Invalid server response received'),
							error: [-1, L.tr('Invalid data')]
						};
					};

					if (json.error) {
						L.ui.dialog(L.tr('File upload'), [
							$('<p />').text(L.tr('The file upload failed with the server response below:')),
							$('<pre />').addClass('alert-message').text(json.message || json.error[1]),
							$('<p />').text(L.tr('In case of network problems try uploading the file again.'))
						], { style: 'close' });
					}
					else if (typeof (state.success_cb) == 'function') {
						state.success_cb(json);
					}
				},

				confirm_cb: function () {

					var f = state.form.find('.cbi-input-file');
					var b = state.form.find('.progress');
					var p = state.form.find('p');

					if (!f.val())
						return;

					state.form.find('iframe').on('load', state.finish_cb);
					state.form.submit();

					f.hide();
					b.show();
					p.text(L.tr('File upload in progress '));

					state.form.parent().parent().find('button').prop('disabled', true);
				}
			});

			state.form.find('.progress').hide();
			state.form.find('.cbi-input-file').val('').show();
			state.form.find('p').text(content || L.tr('Select the file to upload and press "%s" to proceed.').format(L.tr('Ok')));

			state.form.find('[name=sessionid]').val(L.globals.sid);

			state.success_cb = options.success;

			L.ui.dialog(title || L.tr('File upload'), state.form, {
				style: 'confirm',
				confirm: state.confirm_cb
			});

			$('input[type="file"]').change(function (e) {
				var fileName = e.target.files[0].name;
				//~ alert('The file "' + fileName +  '" has been selected.');
				state.form.find('[name=filename]').val("/root/SenderAppComponent/etc/certs2/" + fileName);
			});
		},


		reconnect: function () {
			var protocols = (location.protocol == 'https:') ? ['http', 'https'] : ['http'];
			var ports = (location.protocol == 'https:') ? [80, location.port || 443] : [location.port || 80];
			var address = location.hostname.match(/^[A-Fa-f0-9]*:[A-Fa-f0-9:]+$/) ? '[' + location.hostname + ']' : location.hostname;
			var images = $();
			var interval, timeout;

			L.ui.dialog(
				L.tr('Waiting for device'), [
				$('<p />').text(L.tr('Please stand by while the device is reconfiguring')),
				$('<div />')
					.css('width', '100%')
					.addClass('progressbar')
					.addClass('intermediate')
					.append($('<div />')
						.css('width', '100%'))
			], { style: 'wait' }
			);

			for (var i = 0; i < protocols.length; i++)
				images = images.add($('<img />').attr('url', protocols[i] + '://' + address + ':' + ports[i]));

			//L.network.getNetworkStatus(function(s) {
			//	for (var i = 0; i < protocols.length; i++)
			//	{
			//		for (var j = 0; j < s.length; j++)
			//		{
			//			for (var k = 0; k < s[j]['ipv4-address'].length; k++)
			//				images = images.add($('<img />').attr('url', protocols[i] + '://' + s[j]['ipv4-address'][k].address + ':' + ports[i]));
			//
			//			for (var l = 0; l < s[j]['ipv6-address'].length; l++)
			//				images = images.add($('<img />').attr('url', protocols[i] + '://[' + s[j]['ipv6-address'][l].address + ']:' + ports[i]));
			//		}
			//	}
			//}).then(function() {
			images.on('load', function () {
				var url = this.getAttribute('url');
				L.session.isAlive().then(function (access) {
					if (access) {
						window.clearTimeout(timeout);
						window.clearInterval(interval);
						L.ui.dialog(false);
						images = null;
					}
					else {
						location.href = url;
					}
				});
			});

			interval = window.setInterval(function () {
				images.each(function () {
					this.setAttribute('src', this.getAttribute('url') + L.globals.resource + '/icons/loading.gif?r=' + Math.random());
				});
			}, 5000);

			timeout = window.setTimeout(function () {
				window.clearInterval(interval);
				images.off('load');

				L.ui.dialog(
					L.tr('Device not responding'),
					L.tr('The device was not responding within 180 seconds, you might need to manually reconnect your computer or use SSH to regain access.'),
					{ style: 'close' }
				);
			}, 180000);
			//});
		},



		login: function (reason) {
			var self = this;
			var loginReason = reason || L.session.loginReason || null;

			var state = L.ui._login || (L.ui._login = {
				form: $('<form />')
					.append(
						$('<div />').addClass('login-wrapper').append(
							$('<div />').addClass('login-container').append(
								// Left Panel
								$('<div />').addClass('left-panel').append(
									$('<div />').addClass('bubble big'),
									$('<div />').addClass('bubble medium'),
									$('<div />').addClass('bubble small'),
									$('<div />').addClass('welcome-text').append(
										$('<h1 />').text('WELCOME BACK!'),
										$('<h3 />').text('Secure. Smart. Always Connected'),
										$('<p />').text('Please enter your login credentials to manage your router.')
									)
								),
								// Right Panel
								$('<div />').addClass('right-panel').append(
									$('<div />').addClass('logo').append(
										$('<img />').attr('src', '/luci2/icons/invendis_silbo.svg').attr('alt', 'Invendis Logo')
									),
									$('<h2 />').text('Login'),
									$('<p />').text('Please enter your credentials to continue.'),

									$('<div />').addClass('invalid-login').text('Wrong UserName and Password'),

									$('<div />').addClass('session-logout').text('Session timed out. Please log in again.').hide(),

									$('<div />').addClass('login-group').append(
										$('<span />').addClass('icon').append(
											$('<img />').attr('src', '/luci2/icons/user-solid.svg')
										),
										$('<input />').attr({
											type: 'text',
											id: 'username',
											name: 'username',
											placeholder: 'User Name'
										}).on('keypress', function (ev) {
											if (ev.which === 13 || ev.which === 10) state.confirm_cb();
										})
									),

									$('<div />').addClass('login-group').append(
										$('<span />').addClass('icon').append(
											$('<img />').attr('src', '/luci2/icons/lock-solid.svg')
										),
										$('<input />').attr({
											type: 'password',
											id: 'password',
											name: 'password',
											placeholder: 'Password'
										}).on('keypress', function (ev) {
											if (ev.which === 13 || ev.which === 10) state.confirm_cb();
										})
									),


									// $('<div />').addClass('options').append(
									// 	$('<label />').append(
									// 		$('<input />').attr('type', 'checkbox'),
									// 		' Remember me'
									// 	)
									// ),

									$('<button />').addClass('login_btn primary').text('Log in').attr('type', 'button').on('click', function () {
										state.confirm_cb();
									}),

									// $('<p />').addClass('signup').html('Default credentials <a href="#">admin / admin</a>'),

									$('<div />').addClass('bubble right')
								)
							))
					),

				response_cb: function (response) {
					if (!response.ubus_rpc_session) {
						L.ui.login(true);
						L.ui.dialog(false);
						state.form.find('.login_btn').off('click').on('click', function () {
							state.confirm_cb();
						});
					} else {
						L.globals.sid = response.ubus_rpc_session;
						L.setHash('id', L.globals.sid);
						localStorage.removeItem('sessionTimeout');
						L.session.startHeartbeat();
						L.ui.dialog(false);
						state.deferred.resolve();
					}
				},

				confirm_cb: function () {
					L.session.SessionTimeout().then(() => {
						var u = state.form.find('[name=username]').val();
						var p = state.form.find('[name=password]').val();
						var t = parseInt(localStorage.getItem('seconds'), 10);
						if (!u)
							return;

						L.ui.dialog(
							L.tr('Logging in'), [
							$('<p />').text(L.tr('Login in progress')),
							$('<div />')
								.css('width', '100%')
								.addClass('progressbar')
								.addClass('intermediate')
								.append($('<div />').css('width', '100%'))
						], { style: 'wait' }
						);

						L.globals.sid = '00000000000000000000000000000000';
						L.session.login(u, p, t).then(state.response_cb);
						localStorage.removeItem('seconds');

						const now = new Date();
						const Loginuser = u;
						const formatted = now.toLocaleString('en-GB');
						const login_info = `User : ${Loginuser} &nbsp; Login Time : ${formatted}`;
						localStorage.setItem('login_info', login_info);
					});
				}
			});

			if (!state.deferred || state.deferred.state() !== 'pending')
				state.deferred = $.Deferred();

			var sid = L.getHash('id');
			if (sid && sid.match(/^[a-f0-9]{32}$/)) {
				L.globals.sid = sid;
				L.session.isAlive().then(function (access) {
					if (access) {
						L.session.startHeartbeat();
						state.deferred.resolve();
					} else {
						L.setHash('id', undefined);
						L.ui.login(reason);
					}
				});
				return state.deferred;
			}

			// Show error messages
			if (reason === true)
				state.form.find('.invalid-login').show();
			else
				state.form.find('.invalid-login').hide();

			if (loginReason === "timeout")
				state.form.find('.session-logout').show();
			else
				state.form.find('.session-logout').hide();

			$('#login-main').empty().append(state.form);

			state.form.find('[name=username]').focus();
			return state.deferred;
		},

		cryptPassword: L.rpc.declare({
			object: 'luci2.ui',
			method: 'crypt',
			params: ['data'],
			expect: { crypt: '' }
		}),


		mergeACLScope: function (acl_scope, scope) {
			if ($.isArray(scope)) {
				for (var i = 0; i < scope.length; i++)
					acl_scope[scope[i]] = true;
			}
			else if ($.isPlainObject(scope)) {
				for (var object_name in scope) {
					if (!$.isArray(scope[object_name]))
						continue;

					var acl_object = acl_scope[object_name] || (acl_scope[object_name] = {});

					for (var i = 0; i < scope[object_name].length; i++)
						acl_object[scope[object_name][i]] = true;
				}
			}
		},

		mergeACLPermission: function (acl_perm, perm) {
			if ($.isPlainObject(perm)) {
				for (var scope_name in perm) {
					var acl_scope = acl_perm[scope_name] || (acl_perm[scope_name] = {});
					L.ui.mergeACLScope(acl_scope, perm[scope_name]);
				}
			}
		},

		mergeACLGroup: function (acl_group, group) {
			if ($.isPlainObject(group)) {
				if (!acl_group.description)
					acl_group.description = group.description;

				if (group.read) {
					var acl_perm = acl_group.read || (acl_group.read = {});
					L.ui.mergeACLPermission(acl_perm, group.read);
				}

				if (group.write) {
					var acl_perm = acl_group.write || (acl_group.write = {});
					L.ui.mergeACLPermission(acl_perm, group.write);
				}
			}
		},

		callACLsCallback: function (trees) {
			var acl_tree = {};

			for (var i = 0; i < trees.length; i++) {
				if (!$.isPlainObject(trees[i]))
					continue;

				for (var group_name in trees[i]) {
					var acl_group = acl_tree[group_name] || (acl_tree[group_name] = {});

					L.ui.mergeACLGroup(acl_group, trees[i][group_name]);
				}
			}

			return acl_tree;
		},

		callACLs: L.rpc.declare({
			object: 'luci2.ui',
			method: 'acls',
			expect: { acls: [] }
		}),

		getAvailableACLs: function () {
			return this.callACLs().then(this.callACLsCallback);
		},

		renderChangeIndicator: function () {
			return $('<ul />')
				.addClass('nav navbar-nav navbar-right')
				.append($('<li />')
					.append($('<a />')
						.attr('id', 'changes')
						.attr('href', '#')
						.append($('<span />')
							.addClass('label label-info'))));
		},

		callMenuCallback: function (entries) {
			L.globals.mainMenu = new L.ui.menu();
			L.globals.mainMenu.entries(entries);

			$('#mainmenu')
				.empty()
				.append(L.globals.mainMenu.render(0, 1))
				.append(L.ui.renderChangeIndicator());
		},

		callMenu: L.rpc.declare({
			object: 'luci2.ui',
			method: 'menu',
			expect: { menu: {} }
		}),

		renderMainMenu: function () {
			return this.callMenu().then(this.callMenuCallback);
		},

		renderViewMenu: function () {
			$('#viewmenu')
				.empty()
				.append(L.globals.mainMenu.render(2, 900));
		},

		renderView: function () {
			var node = arguments[0];
			var name = node.view.split(/\//).join('.');
			var cname = L.toClassName(name);
			var views = L.views || (L.views = {});
			var args = [];

			for (var i = 1; i < arguments.length; i++)
				args.push(arguments[i]);

			if (L.globals.currentView)
				L.globals.currentView.finish();

			L.ui.renderViewMenu();
			L.setHash('view', node.view);

			if (views[cname] instanceof L.ui.view) {
				L.globals.currentView = views[cname];
				return views[cname].render.apply(views[cname], args);
			}

			var url = L.globals.resource + '/view/' + name + '.js';

			return $.ajax(url, {
				method: 'GET',
				cache: true,
				dataType: 'text'
			}).then(function (data) {
				try {
					var viewConstructorSource = (
						'(function(L, $) { ' +
						'return %s' +
						'})(L, $);\n\n' +
						'//@ sourceURL=%s'
					).format(data, url);

					var viewConstructor = eval(viewConstructorSource);

					views[cname] = new viewConstructor({
						name: name,
						acls: node.write || {}
					});

					L.globals.currentView = views[cname];
					return views[cname].render.apply(views[cname], args);
				}
				catch (e) {
					alert('Unable to instantiate view "%s": %s'.format(url, e));
				};

				return $.Deferred().resolve();
			});
		},

		changeView: function () {
			var name = L.getHash('view');
			var node = L.globals.defaultNode;

			if (name && L.globals.mainMenu)
				node = L.globals.mainMenu.getNode(name);

			if (node) {
				L.ui.loading(true);
				L.ui.renderView(node).then(function () {
					$('#mainmenu.in').collapse('hide');
					L.session.startHeartbeat()
					L.ui.loading(false);
				});
			}
		},

		updateHostname: function () {
			return L.system.getBoardInfo().then(function (info) {
				if (info.hostname)
					$('#hostname').text(info.hostname);
			});
		},

		updateChanges: function () {
			return L.uci.changes().then(function (changes) {
				var n = 0;
				var html = '';

				for (var config in changes) {
					var log = [];

					for (var i = 0; i < changes[config].length; i++) {
						var c = changes[config][i];

						switch (c[0]) {
							case 'order':
								log.push('uci reorder %s.<ins>%s=<strong>%s</strong></ins>'.format(config, c[1], c[2]));
								break;

							case 'remove':
								if (c.length < 3)
									log.push('uci delete %s.<del>%s</del>'.format(config, c[1]));
								else
									log.push('uci delete %s.%s.<del>%s</del>'.format(config, c[1], c[2]));
								break;

							case 'rename':
								if (c.length < 4)
									log.push('uci rename %s.<ins>%s=<strong>%s</strong></ins>'.format(config, c[1], c[2], c[3]));
								else
									log.push('uci rename %s.%s.<ins>%s=<strong>%s</strong></ins>'.format(config, c[1], c[2], c[3], c[4]));
								break;

							case 'add':
								log.push('uci add %s <ins>%s</ins> (= <ins><strong>%s</strong></ins>)'.format(config, c[2], c[1]));
								break;

							case 'list-add':
								log.push('uci add_list %s.%s.<ins>%s=<strong>%s</strong></ins>'.format(config, c[1], c[2], c[3], c[4]));
								break;

							case 'list-del':
								log.push('uci del_list %s.%s.<del>%s=<strong>%s</strong></del>'.format(config, c[1], c[2], c[3], c[4]));
								break;

							case 'set':
								if (c.length < 4)
									log.push('uci set %s.<ins>%s=<strong>%s</strong></ins>'.format(config, c[1], c[2]));
								else
									log.push('uci set %s.%s.<ins>%s=<strong>%s</strong></ins>'.format(config, c[1], c[2], c[3], c[4]));
								break;
						}
					}

					html += '<code>/etc/config/%s</code><pre class="uci-changes">%s</pre>'.format(config, log.join('\n'));
					n += changes[config].length;
				}

				if (n > 0)
					//$('#changes')
					//.click(function(ev) {
					//L.ui.dialog(L.tr('Staged configuration changes'), html, {
					//style: 'confirm',
					//confirm: function() {
					L.uci.apply().then(
						function (code) {
							L.ui.showAlert(
								"success",
								"Configuration Applied",
								"Settings were successfully applied."
								// { stack: true, duration: 5000, sticky: true }
							);
							setTimeout(function () {
								location.reload();
							}, 1500);
						},
						function (code) {
							// error
							L.ui.showAlert("error", "Configuration Failed", "Error with code " + code);
						}
					);

				//	}
				//	});
				//ev.preventDefault();
				//	})
				//.children('span')
				//.show()
				//	.text(L.trcp('Pending configuration changes', '1 change', '%d changes', n).format(n));
				else
					$('#changes').children('span').hide();
			});
		},

		load: function () {
			var self = this;

			self.loading(true);

			$.when(
				L.session.updategatewaypage(),
				L.session.updateACLs(),
				self.updateHostname(),
				self.updateChanges(),
				self.renderMainMenu(),
				L.network.load()
			).then(function () {
				self.renderView(L.globals.defaultNode).then(function () {
					self.loading(false);
				});

				$(window).on('hashchange', function () {
					self.changeView();
				});
			});
		},

		button: function (label, style, title, id) {
			style = style || 'default';

			let $btn = $('<button />')
				.attr('type', 'button')
				.attr('title', title ? title : '')
				.attr('data-action', label.toLowerCase())
				.attr('data-id', id || '');

			switch (label.toLowerCase()) {
				case 'edit':
					$btn.addClass('action-btn btn-edit')
						.append('<img src="/luci2/icons/pen-solid-full.svg" class="edit_svg" alt="Edit" aria-hidden="true">');
					break;

				case 'delete':
					$btn.addClass('action-btn btn-delete')
						.append('<img src="/luci2/icons/trash-solid-full.svg" class="delete_svg" alt="Delete" aria-hidden="true">');
					break;

				default:
					$btn.addClass('btn btn-' + style)
						.text(label);
			}

			return $btn;
		},

		showAlert: function (type, title, message, options) {
			var self = this;
			var body = $("body");
			var state = this._alert || (this._alert = {
				container: $("<div/>").addClass("alert-container").appendTo(body)
			});

			if (typeof options !== "object")
				options = {};

			if (title === false) {
				state.container.empty();
				return state.container;
			}
			if (!options.stack)
				state.container.empty();
			state.container.addClass("fade in");

			var iconSymbol = "";
			switch (type) {
				case "success": iconSymbol = "✔"; break;
				case "error": iconSymbol = "✖"; break;
				case "info": iconSymbol = "ℹ"; break;
				case "warning": iconSymbol = "!"; break;
			}


			var $alert = $("<div/>").addClass("alert").addClass(type);
			var $icon = $("<div/>").addClass("alert-icon").text(iconSymbol);
			var $content = $("<div/>").addClass("alert-content");
			var $title = $("<div/>").addClass("alert-title").text(title);
			var $msg = $("<div/>").addClass("alert-message").text(message);

			$content.append($title).append($msg);
			$alert.append($icon).append($content);

			// If confirm/cancel buttons are requested
			if (options.confirm || options.cancel) {
				var $actions = $("<div/>").addClass("alert-actions");

				if (options.confirm) {
					$("<button/>")
						.addClass("btn btn-danger btn-sm")
						.text(options.confirmText || "Confirm")
						.click(function () {
							if (typeof options.confirm === "function")
								options.confirm();
							state.container.removeClass('fade in')
							$alert.remove();

						})
						.appendTo($actions);
				}

				if (options.cancel) {
					$("<button/>")
						.addClass("btn btn-default btn-sm")
						.text(options.cancelText || "Cancel")
						.click(function () {
							if (typeof options.cancel === "function")
								options.cancel();
							state.container.removeClass("fade in");
							$alert.remove();
						})
						.appendTo($actions);
				}

				$alert.append($actions);
			}

			state.container.append($alert);

			var duration = options.duration || 3000;
			if (!options.sticky && !options.confirm && !options.cancel) {
				setTimeout(function () {
					$alert.css("animation", "fadeOutUp 0.4s forwards");
					setTimeout(function () { $alert.remove(); state.container.removeClass("fade in"); }, 400);
				}, duration);
			}

			return $alert;
		},


		confirmDelete: function (ev, title, callback) {
			ev.preventDefault();

			// If title is a function, it's actually the callback
			if (typeof title === 'function') {
				callback = title;
				title = null;
			}

			L.ui.showAlert(
				'warning',
				L.tr('Confirm delete'),
				L.tr('Are you sure you want to delete this configuration?'),
				{
					sticky: true,
					confirmText: L.tr('Yes, Delete'),
					cancelText: L.tr('Cancel'),

					confirm: function () {
						var msg = title
							? L.tr(`Deleted "${title}" configuration successfully.`)
							: L.tr('Deleted configuration successfully.');

						L.ui.showAlert('success', L.tr('Deleted'), msg);

						if (typeof callback === 'function') callback(1);
					},

					cancel: function () {
						L.ui.showAlert('info', L.tr('Cancelled'), L.tr('Deletion aborted.'));
						if (typeof callback === 'function') callback(0);
					}
				}
			);
		},

		confirmAction: function (action, callback) {
			let title, message, yesText;

			switch (action) {
				case 'reboot':
					title = 'Reboot router';
					message = 'This will restart the device and briefly disconnect all clients.';
					yesText = 'Yes, Reboot';
					break;
				case 'network':
					title = 'Restart network';
					message = 'This will restart network interfaces and apply changes.';
					yesText = 'Yes, Restart';
					break;
				case 'logout':
					title = 'Logout';
					message = 'Are you sure you want to log out from the admin interface?';
					yesText = 'Yes, Logout';
					break;

				case 'password':
					title = 'Change Password';
					message = 'Do you want to change your administrator password? You may need to log in again after updating it.';
					yesText = 'Yes, Change';
					break;
				default:
					title = 'Confirm action';
					message = 'Are you sure you want to continue?';
					yesText = 'Yes';
			}

			L.ui.showAlert('warning', title, message, {
				sticky: true,
				confirmText: yesText,
				cancelText: 'Cancel',
				confirm: function () {
					if (typeof callback === 'function') callback(1);
				},
				cancel: function () {
					if (typeof callback === 'function') callback(0);
				}
			});
		},




		showNoConfigMessage: function (featureName, elementId) {
			var el = document.getElementById(elementId);
			if (!el) return;

			el.innerHTML = `No ${featureName} configurations found. Please add a configuration to get started.`;
			el.classList.add('no-configurations');
		},



		createNote: function (title, message, options) {
			options = options || {};

			var type = (options.type || 'info').toLowerCase(); // info|warn|muted|subtle
			var variants = [];

			if (options.variant === 'inline') variants.push('note--inline');
			if (options.variant === 'dense') variants.push('note--dense');
			if (options.variant === 'large') variants.push('note--large');
			if (options.variant === 'banner') variants.push('note--banner');
			if (options.compact) variants.push('note--compact');
			if (options.truncate) variants.push('note--truncate');
			if (options.elevated) variants.push('note--elevated');
			if (options.subtle) variants.push('note--subtle');


			var cls = ['note', 'note--' + (type || 'info')].concat(variants).join(' ');
			var $note = $('<div/>').addClass(cls);

			var role = options.role || 'note';
			$note.attr('role', role);
			if (role === 'status') {
				$note.attr('aria-live', options.ariaLive || 'polite');
			}

			var iconHtml = options.iconHtml;
			if (!iconHtml) {
				switch (type) {
					case 'warn': iconHtml = '⚠'; break;
					case 'muted': iconHtml = 'i'; break;
					case 'subtle': iconHtml = 'i'; break;
					default:
						iconHtml = '<svg viewBox="0 0 24 24" aria-hidden="true" focusable="false">' +
							'<path d="M11 10h2v6h-2v-6zM11 7h2v2h-2V7z"/>' +
							'</svg>';
				}
			}


			var $icon = $('<div/>').addClass('note__icon').html(iconHtml);
			$note.append($icon);

			var $body = $('<div/>').addClass('note__body');
			if (title) {
				var $title = $('<p/>').addClass('note__title').text(title);
				$body.append($title);
			}
			var $msg = $('<p/>').addClass('note__message');
			if (options.allowHtml) {
				$msg.html(message || '');
			} else {
				$msg.html((message || '').replace(/\n/g, '<br>'));
			}
			$body.append($msg);

			$note.append($body);

			// append to container if requested
			if (options.appendTo) {
				var $target = $(options.appendTo);
				if ($target.length) $target.append($note);
			}

			// return HTML string if requested
			if (options.returnHtml) return $note.prop('outerHTML');

			// otherwise return jQuery element
			return $note;
		},




		icon: function (src, alt, title) {
			if (!src.match(/\.[a-z]+$/))
				src += '.png';

			if (!src.match(/^\//))
				src = L.globals.resource + '/icons/' + src;

			var icon = $('<img />')
				.attr('src', src);

			if (typeof (alt) !== 'undefined')
				icon.attr('alt', alt);

			if (typeof (title) !== 'undefined')
				icon.attr('title', title);

			return icon;
		},

		dynamicLoad: L.rpc.declare({
			object: 'uci',
			method: 'get',
			params: ['config', 'type'],
			expect: { values: {} }
		}),

		dynamicLoad: L.rpc.declare({
			object: 'uci',
			method: 'get',
			expect: { menu: {} }
		})
	};

	ui_class.AbstractWidget = Class.extend({
		i18n: function (text) {
			return text;
		},

		label: function () {
			var key = arguments[0];
			var args = [];

			for (var i = 1; i < arguments.length; i++)
				args.push(arguments[i]);

			switch (typeof (this.options[key])) {
				case 'undefined':
					return '';

				case 'function':
					return this.options[key].apply(this, args);

				default:
					return ''.format.apply('' + this.options[key], args);
			}
		},

		toString: function () {
			return $('<div />').append(this.render()).html();
		},

		insertInto: function (id) {
			return $(id).empty().append(this.render());
		},

		appendTo: function (id) {
			return $(id).append(this.render());
		},

		on: function (evname, evfunc) {
			var evnames = L.toArray(evname);

			if (!this.events)
				this.events = {};

			for (var i = 0; i < evnames.length; i++)
				this.events[evnames[i]] = evfunc;

			return this;
		},

		trigger: function (evname, evdata) {
			if (this.events) {
				var evnames = L.toArray(evname);

				for (var i = 0; i < evnames.length; i++)
					if (this.events[evnames[i]])
						this.events[evnames[i]].call(this, evdata);
			}

			return this;
		}
	});

	ui_class.view = ui_class.AbstractWidget.extend({
		_fetch_template: function () {
			return $.ajax(L.globals.resource + '/template/' + this.options.name + '.htm', {
				method: 'GET',
				cache: true,
				dataType: 'text',
				success: function (data) {
					data = data.replace(/<%([#:=])?(.+?)%>/g, function (match, p1, p2) {
						p2 = p2.replace(/^\s+/, '').replace(/\s+$/, '');
						switch (p1) {
							case '#':
								return '';

							case ':':
								return L.tr(p2);

							case '=':
								return L.globals[p2] || '';

							default:
								return '(?' + match + ')';
						}
					});

					$('#maincontent').append(data);
				}
			});
		},

		execute: function () {
			throw "Not implemented";
		},

		render: function () {
			var container = $('#maincontent');

			container.empty();

			if (this.title)
				container.append($('<h2 />').append(this.title));

			if (this.description)
				container.append($('<p />').append(this.description));

			var self = this;
			var args = [];

			for (var i = 0; i < arguments.length; i++)
				args.push(arguments[i]);

			return this._fetch_template().then(function () {
				return L.deferrable(self.execute.apply(self, args));
			});
		},

		repeat: function (func, interval) {
			var self = this;

			if (!self._timeouts)
				self._timeouts = [];

			var index = self._timeouts.length;

			if (typeof (interval) != 'number')
				interval = 5000;

			var setTimer, runTimer;

			setTimer = function () {
				if (self._timeouts)
					self._timeouts[index] = window.setTimeout(runTimer, interval);
			};

			runTimer = function () {
				L.deferrable(func.call(self)).then(setTimer, setTimer);
			};

			runTimer();
		},

		finish: function () {
			if ($.isArray(this._timeouts)) {
				for (var i = 0; i < this._timeouts.length; i++)
					window.clearTimeout(this._timeouts[i]);

				delete this._timeouts;
			}
		}
	});

	ui_class.menu = ui_class.AbstractWidget.extend({
		init: function () {
			this._nodes = {};
		},

		entries: function (entries) {
			for (var entry in entries) {
				var path = entry.split(/\//);
				var node = this._nodes;

				for (i = 0; i < path.length; i++) {
					if (!node.childs)
						node.childs = {};

					if (!node.childs[path[i]])
						node.childs[path[i]] = {};

					node = node.childs[path[i]];
				}

				$.extend(node, entries[entry]);
			}
		},

		sortNodesCallback: function (a, b) {
			var x = a.index || 0;
			var y = b.index || 0;
			return (x - y);
		},

		firstChildView: function (node) {
			if (node.view)
				return node;

			var nodes = [];
			for (var child in (node.childs || {}))
				nodes.push(node.childs[child]);

			nodes.sort(this.sortNodesCallback);

			for (var i = 0; i < nodes.length; i++) {
				var child = this.firstChildView(nodes[i]);
				if (child) {
					for (var key in child)
						if (!node.hasOwnProperty(key) && child.hasOwnProperty(key))
							node[key] = child[key];

					return node;
				}
			}

			return undefined;
		},



		handleClick: function (ev) {
			L.setHash('view', ev.data);

			ev.preventDefault();
			this.blur();
		},

		// renderNodes: function (childs, level, min, max) {
		// 	// ---------- helpers ----------
		// 	function slugify(s) {
		// 		return String(s || '').toLowerCase().trim()
		// 			.replace(/\s+/g, '-').replace(/[^a-z0-9\-]/g, '').replace(/\-+/g, '-');
		// 	}
		// 	function iterateChilds(childsObj, cb) {
		// 		if (!childsObj) return;
		// 		Object.keys(childsObj).forEach(function (k) { cb(childsObj[k], k); });
		// 	}

		// 	// Icon map (titles -> icon path)
		// 	var iconMap = {
		// 		"Info": "/luci2/icons/Dashboard.svg",
		// 		"Dashboard1": "/luci2/icons/Dashboard.svg",
		// 		"Network": "/luci2/icons/networkManagement.svg",
		// 		"Settings": "/luci2/icons/networkManagement.svg",
		// 		"Routing Management": "/luci2/icons/Routes.svg",
		// 		"Security": "/luci2/icons/securityManagement.png",
		// 		"System": "/luci2/icons/system.svg",
		// 		"Commands": "/luci2/icons/Commands.png",
		// 		"Firewall": "/luci2/icons/Configurations.png",
		// 		"Monitoring": "/luci2/icons/Features.svg",
		// 		"Diagnostics": "/luci2/icons/diagnostics-tools.svg",
		// 		"Commissioning": "/luci2/icons/Test_Management.svg"
		// 	};
		// 	function iconHTML(title) {
		// 		var src = iconMap[title] || "/luci2/icons/Dashboard.svg";
		// 		return '<span class="mm-icon"><img src="' + src + '" alt=""></span><span class="mm-label">' + (L.tr ? L.tr(title) : title) + '</span>';
		// 	}

		// 	// ----------  nesting rules ----------
		// 	var nestRules = this.nestRules || [{ parent: 'Network', child: 'Routing' },
		// 	{ parent: 'Security', child: 'Firewall' },
		// 	{ parent: 'System', child: 'SNMP Configuration' },
		// 	{ parent: 'Gateway', child: 'Configuration' }
		// 	];
		// 	var nestChildSet = new Set(nestRules.map(function (r) { return r.child; }));
		// 	var nestMapByParent = nestRules.reduce(function (m, r) {
		// 		(m[r.parent] || (m[r.parent] = [])).push(r.child); return m;
		// 	}, {});

		// 	// ---------- collect nodes ----------
		// 	var nodes = [];
		// 	for (var node in childs) {
		// 		if (!childs.hasOwnProperty(node)) continue;
		// 		var child = this.firstChildView(childs[node]);
		// 		if (child) nodes.push(childs[node]);
		// 	}
		// 	nodes.sort(this.sortNodesCallback);

		// 	// fast lookup by view + title
		// 	L.globals.viewIndex = L.globals.viewIndex || {};
		// 	var nodeByTitle = {};
		// 	nodes.forEach(function (n) {
		// 		nodeByTitle[n.title] = n;
		// 		if (n.view) L.globals.viewIndex[n.view] = n;
		// 	});

		// 	// ---------- containers ----------
		// 	var sideMenu = $('<div />').addClass('side-menu-container');
		// 	var subMenuTemplates = $('<div />', { id: 'subMenuTemplates', style: 'display:none;' });
		// 	var ul = (level === 0) ? $('<ul />', { class: 'main-menu', id: 'mainMenu' }) : null;

		// 	// ---------- build top-level + submenu templates ----------
		// 	for (var i = 0; i < nodes.length; i++) {
		// 		if (!L.globals.defaultNode) {
		// 			var v = L.getHash('view');
		// 			if (!v || v === nodes[i].view) L.globals.defaultNode = nodes[i];
		// 		}

		// 		var rawTitle = nodes[i].title;
		// 		var tmplId = 'submenu-' + slugify(rawTitle);

		// 		var liTop = $('<li />', { class: 'accordion-item' });

		// 		// Build anchor with icon + label (works for both leaf and parent)
		// 		var aTop = $('<a />', { href: '#', html: iconHTML(rawTitle), title: L.tr(rawTitle) })
		// 			.append($('<span />').addClass('dropdown-icon'))
		// 			.data('template', tmplId);

		// 		// top-level leaf
		// 		if (!nodes[i].childs) {
		// 			aTop.attr('data-view', nodes[i].view);
		// 			if (nodes[i].view) L.globals.viewIndex[nodes[i].view] = nodes[i];
		// 		}

		// 		liTop.append(aTop);
		// 		if (level === 0 && !nestChildSet.has(rawTitle)) ul.append(liTop);

		// 		// submenu template for parents (non-nested)
		// 		if (nodes[i].childs && level < max && !nestChildSet.has(rawTitle)) {
		// 			var subUl = $('<ul />', { class: 'sub-menu', id: tmplId });

		// 			// regular leaves
		// 			iterateChilds(nodes[i].childs, function (childNode) {
		// 				var li = $('<li />');
		// 				var a = $('<a />', { href: '#', text: L.tr(childNode.title) })
		// 					.attr('data-view', childNode.view);
		// 				li.append(a); subUl.append(li);
		// 				if (childNode.view) L.globals.viewIndex[childNode.view] = childNode;
		// 			});

		// 			// nested groups
		// 			var nestChildren = nestMapByParent[rawTitle] || [];
		// 			for (var k = 0; k < nestChildren.length; k++) {
		// 				var childTitle = nestChildren[k];
		// 				var nestedNode = nodeByTitle[childTitle];
		// 				if (!nestedNode) continue;

		// 				var nestedLi = $('<li />', { class: 'accordion-item' });
		// 				var nestedA = $('<a />', { href: '#', html: L.tr(nestedNode.title) })
		// 					.append($('<span />').addClass('dropdown-icon'));
		// 				nestedLi.append(nestedA);

		// 				var nestedUl = $('<ul />', { class: 'sub-menu accordion-sub-menu' });
		// 				if (nestedNode.childs) {
		// 					iterateChilds(nestedNode.childs, function (nnChild) {
		// 						var nnLi = $('<li />');
		// 						var nnA = $('<a />', { href: '#', text: L.tr(nnChild.title) })
		// 							.attr('data-view', nnChild.view);
		// 						nnLi.append(nnA); nestedUl.append(nnLi);
		// 						if (nnChild.view) L.globals.viewIndex[nnChild.view] = nnChild;
		// 					});
		// 				}
		// 				nestedLi.append(nestedUl);
		// 				subUl.append(nestedLi);
		// 			}
		// 			subMenuTemplates.append(subUl);
		// 		}
		// 	}

		// 	// ensure default node exists
		// 	(function ensureDefault() {
		// 		if (L.globals.defaultNode) return;
		// 		var v = L.getHash('view');
		// 		if (v && L.globals.viewIndex && L.globals.viewIndex[v]) {
		// 			L.globals.defaultNode = L.globals.viewIndex[v]; return;
		// 		}
		// 		if (nodes.length) L.globals.defaultNode = nodes[0];
		// 	})();

		// 	// ---------- assemble ----------
		// 	var subPanel = $('<div />', { class: 'sub-menu-panel', id: 'subMenuPanel' });
		// 	sideMenu.append(ul).append(subPanel);
		// 	var wrapper = $('<div />').append(sideMenu).append(subMenuTemplates);
		// 	wrapper.attr('id', 'mainmenu');

		// 	var ctx = this;

		// 	// ---------- behaviors ----------
		// 	$(document).off('click.menuCollapse').on('click.menuCollapse', '[data-toggle="menu-collapse"]', function (e) {
		// 		e.preventDefault();
		// 		$('#mainmenu').toggleClass('collapsed');
		// 		if ($('#mainmenu').hasClass('collapsed')) {
		// 			$('#subMenuPanel').removeClass('active').empty();
		// 			$('#mainmenu').removeClass('subpanel-open');
		// 			$('#mainmenu .main-menu > .accordion-item').removeClass('active');
		// 		}
		// 	});

		// 	// 1) Delegated handler for ANY leaf link
		// 	wrapper.on('click', 'a[data-view]', function (e) {
		// 		e.preventDefault();
		// 		var viewStr = $(this).attr('data-view'); if (!viewStr) return;

		// 		var ev = $.Event('click'); ev.data = viewStr;
		// 		ctx.handleClick.call(this, ev);

		// 		// close panel & reset UI
		// 		$(this).blur();
		// 		var $panel = wrapper.find('#subMenuPanel');
		// 		$panel.removeClass('active').empty();
		// 		wrapper.removeClass('subpanel-open');
		// 		wrapper.find('.main-menu > .accordion-item').removeClass('active');
		// 	});

		// 	// 2) Open/close top-level parents & load submenu template
		// 	wrapper.on('click', '.main-menu > .accordion-item > a', function (e) {
		// 		var $link = $(this);
		// 		var hasView = !!$link.attr('data-view');
		// 		if (hasView) { return; } // leaf handled above

		// 		e.preventDefault();
		// 		if (wrapper.hasClass('collapsed')) wrapper.removeClass('collapsed');

		// 		var parent = $link.parent();
		// 		var subMenuPanel = wrapper.find('#subMenuPanel');
		// 		var tmplId = $link.data('template');
		// 		var $template = tmplId ? wrapper.find('#' + tmplId) : $();

		// 		if (parent.hasClass('active')) {
		// 			parent.removeClass('active');
		// 			subMenuPanel.removeClass('active').empty();
		// 			wrapper.removeClass('subpanel-open');
		// 			return;
		// 		}

		// 		wrapper.find('.main-menu > .accordion-item').removeClass('active');
		// 		parent.addClass('active');

		// 		if ($template.length) {
		// 			var $clone = $template.clone().show();
		// 			subMenuPanel.empty().append($clone).addClass('active');
		// 			wrapper.addClass('subpanel-open');

		// 			subMenuPanel.find('.accordion-item > a').off('click.nest').on('click.nest', function (ev) {
		// 				ev.preventDefault();
		// 				ev.stopPropagation();
		// 				var $li = $(this).parent();
		// 				$li.toggleClass('active');
		// 			});

		// 			subMenuPanel.find('a[data-view]').off('click.highlight').on('click.highlight', function (e) {
		// 				subMenuPanel.find('li').removeClass('active');
		// 				$(this).closest('li').addClass('active');
		// 			});
		// 		}
		// 	});

		// 	return wrapper.get(0);
		// },

		// renderNodes: function (childs, level, min, max) {
		// 	// ---------- Helpers ----------
		// 	function slugify(s) {
		// 		return String(s || '').toLowerCase().trim()
		// 			.replace(/\s+/g, '-').replace(/[^a-z0-9\-]/g, '').replace(/\-+/g, '-');
		// 	}

		// 	function iterateChilds(childsObj, cb) {
		// 		if (!childsObj) return;
		// 		Object.keys(childsObj).forEach(function (k) { cb(childsObj[k], k); });
		// 	}

		// 	function sortByMenuIndex(a, b) {
		// 		return (a.index || 999) - (b.index || 999);
		// 	}

		// 	// Icon map
		// 	var iconMap = {
		// 		"Info": "/luci2/icons/Dashboard.svg",
		// 		"Dashboard1": "/luci2/icons/Dashboard.svg",
		// 		"Network": "/luci2/icons/networkManagement.svg",
		// 		"Settings": "/luci2/icons/networkManagement.svg",
		// 		"Routing Management": "/luci2/icons/Routes.svg",
		// 		"Security": "/luci2/icons/securityManagement.png",
		// 		"System": "/luci2/icons/system.svg",
		// 		"Commands": "/luci2/icons/Commands.png",
		// 		"Firewall": "/luci2/icons/Configurations.png",
		// 		"Monitoring": "/luci2/icons/Features.svg",
		// 		"Diagnostics": "/luci2/icons/diagnostics-tools.svg",
		// 		"Commissioning": "/luci2/icons/Test_Management.svg"
		// 	};

		// 	function iconHTML(title) {
		// 		var src = iconMap[title] || "/luci2/icons/Dashboard.svg";
		// 		return '<span class="mm-icon"><img src="' + src + '" alt=""></span><span class="mm-label">' + (L.tr ? L.tr(title) : title) + '</span>';
		// 	}

		// 	// ---------- Nesting Rules ----------
		// 	var nestRules = this.nestRules || [{ parent: 'Network', child: 'Routing' },
		// 	{ parent: 'Security', child: 'Firewall' },
		// 	{ parent: 'System', child: 'SNMP Configuration' },
		// 	{ parent: 'Gateway', child: 'Configuration' },
		// 	{ parent: 'Gateway', child: 'Monitoring' }
		// 	];
		// 	var nestChildSet = new Set(nestRules.map(function (r) { return r.child; }));
		// 	var nestMapByParent = nestRules.reduce(function (m, r) {
		// 		(m[r.parent] || (m[r.parent] = [])).push(r.child); return m;
		// 	}, {});

		// 	// ---------- Collect All Nodes ----------
		// 	var nodes = [];
		// 	L.globals.viewIndex = L.globals.viewIndex || {};
		// 	var nodeByTitle = {};

		// 	for (var node in childs) {
		// 		if (!childs.hasOwnProperty(node)) continue;
		// 		var nodeObj = childs[node];
		// 		nodes.push(nodeObj);
		// 		nodeByTitle[nodeObj.title] = nodeObj;
		// 		if (nodeObj.view) L.globals.viewIndex[nodeObj.view] = nodeObj;
		// 	}
		// 	nodes.sort(sortByMenuIndex);

		// 	// ---------- Containers ----------
		// 	var sideMenu = $('<div />').addClass('side-menu-container');
		// 	var subMenuTemplates = $('<div />', { id: 'subMenuTemplates', style: 'display:none;' });
		// 	var ul = (level === 0) ? $('<ul />', { class: 'main-menu', id: 'mainMenu' }) : null;

		// 	// ---------- Build Menu Logic ----------
		// 	for (var i = 0; i < nodes.length; i++) {
		// 		var rawTitle = nodes[i].title;

		// 		// Don't render "child" at the top level (root) because it will be nested
		// 		if (level === 0 && nestChildSet.has(rawTitle)) continue;

		// 		var tmplId = 'submenu-' + slugify(rawTitle);
		// 		var liTop = $('<li />', { class: 'accordion-item' });
		// 		var aTop = $('<a />', { href: '#', html: iconHTML(rawTitle), title: L.tr(rawTitle) })
		// 			.append($('<span />').addClass('dropdown-icon'))
		// 			.data('template', tmplId);

		// 		if (!nodes[i].childs && nodes[i].view) {
		// 			aTop.attr('data-view', nodes[i].view);
		// 		}

		// 		liTop.append(aTop);
		// 		if (level === 0) ul.append(liTop);

		// 		// Submenu Processing (Where the interleaving happens)
		// 		if (nodes[i].childs && level < max) {
		// 			var subUl = $('<ul />', { class: 'sub-menu', id: tmplId });
		// 			var combinedItems = [];

		// 			// 1. Add normal pages from this parent (parent pages)
		// 			iterateChilds(nodes[i].childs, function (c) { combinedItems.push(c); });

		// 			// 2. Add the Nested "child" menu into this list as a sibling
		// 			var nestChildrenTitles = nestMapByParent[rawTitle] || [];
		// 			nestChildrenTitles.forEach(function (t) {
		// 				var nNode = nodeByTitle[t];
		// 				if (nNode) {
		// 					var virtual = $.extend({}, nNode, { __isNestedParent: true });
		// 					combinedItems.push(virtual);
		// 				}
		// 			});

		// 			// 3. SORT EVERYTHING TOGETHER 
		// 			// This is the part that places child menu between pages 2 and 3
		// 			combinedItems.sort(sortByMenuIndex);

		// 			// 4. Loop through sorted list and render
		// 			combinedItems.forEach(function (item) {
		// 				if (item.__isNestedParent) {
		// 					// Render child as a nested accordion
		// 					var nestedLi = $('<li />', { class: 'accordion-item' });
		// 					var nestedA = $('<a />', { href: '#', html: L.tr(item.title) }).append($('<span />').addClass('dropdown-icon'));
		// 					nestedLi.append(nestedA);

		// 					var nestedUl = $('<ul />', { class: 'sub-menu accordion-sub-menu' });
		// 					var deep = [];
		// 					iterateChilds(item.childs, function (dc) { deep.push(dc); });
		// 					deep.sort(sortByMenuIndex).forEach(function (dc) {
		// 						var nnLi = $('<li />');
		// 						var nnA = $('<a />', { href: '#', text: L.tr(dc.title) }).attr('data-view', dc.view);
		// 						nnLi.append(nnA);
		// 						nestedUl.append(nnLi);
		// 						if (dc.view) L.globals.viewIndex[dc.view] = dc;
		// 					});
		// 					nestedLi.append(nestedUl);
		// 					subUl.append(nestedLi);
		// 				} else {
		// 					// Render standard parent page
		// 					var li = $('<li />');
		// 					var a = $('<a />', { href: '#', text: L.tr(item.title) }).attr('data-view', item.view);
		// 					li.append(a); subUl.append(li);
		// 					if (item.view) L.globals.viewIndex[item.view] = item;
		// 				}
		// 			});
		// 			subMenuTemplates.append(subUl);
		// 		}
		// 	}

		// 	// Default Node Safety (Fixed to prevent renderView crashes)
		// 	(function ensureDefault() {
		// 		var v = L.getHash('view');
		// 		if (v && L.globals.viewIndex[v]) {
		// 			L.globals.defaultNode = L.globals.viewIndex[v];
		// 			return;
		// 		}
		// 		if (!L.globals.defaultNode || !L.globals.defaultNode.view) {
		// 			for (var key in L.globals.viewIndex) {
		// 				if (L.globals.viewIndex[key] && L.globals.viewIndex[key].view) {
		// 					L.globals.defaultNode = L.globals.viewIndex[key];
		// 					break;
		// 				}
		// 			}
		// 		}
		// 	})();

		// 	var subPanel = $('<div />', { class: 'sub-menu-panel', id: 'subMenuPanel' });
		// 	sideMenu.append(ul).append(subPanel);
		// 	var wrapper = $('<div />').attr('id', 'mainmenu').append(sideMenu).append(subMenuTemplates);
		// 	var ctx = this;

		// 	// Click Behaviors
		// 	wrapper.on('click', 'a[data-view]', function (e) {
		// 		e.preventDefault();
		// 		var viewStr = $(this).attr('data-view');
		// 		if (!viewStr || viewStr === "undefined") return;
		// 		var targetNode = L.globals.viewIndex[viewStr];
		// 		if (!targetNode || !targetNode.view) return;

		// 		var ev = $.Event('click'); ev.data = viewStr;
		// 		ctx.handleClick.call(this, ev);
		// 		wrapper.find('#subMenuPanel').removeClass('active').empty();
		// 		wrapper.removeClass('subpanel-open').find('.main-menu > .accordion-item').removeClass('active');
		// 	});

		// 	wrapper.on('click', '.main-menu > .accordion-item > a', function (e) {
		// 		var $link = $(this);
		// 		if ($link.attr('data-view')) return;
		// 		e.preventDefault();
		// 		var parent = $link.parent();
		// 		var subMenuPanel = wrapper.find('#subMenuPanel');
		// 		var tmplId = $link.data('template');
		// 		var $template = tmplId ? wrapper.find('#' + tmplId) : $();

		// 		if (parent.hasClass('active')) {
		// 			parent.removeClass('active');
		// 			subMenuPanel.removeClass('active').empty();
		// 			wrapper.removeClass('subpanel-open');
		// 			return;
		// 		}

		// 		wrapper.find('.main-menu > .accordion-item').removeClass('active');
		// 		parent.addClass('active');

		// 		if ($template.length) {
		// 			var $clone = $template.clone().show();
		// 			subMenuPanel.empty().append($clone).addClass('active');
		// 			wrapper.addClass('subpanel-open');
		// 			subMenuPanel.find('.accordion-item > a').on('click', function (ev) {
		// 				ev.preventDefault();
		// 				$(this).parent().toggleClass('active');
		// 			});
		// 		}
		// 	});

		// 	return wrapper.get(0);
		// },


		renderNodes: function (childs, level, min, max) {
			// ---------- Helpers ----------
			function slugify(s) {
				return String(s || '').toLowerCase().trim()
					.replace(/\s+/g, '-').replace(/[^a-z0-9\-]/g, '').replace(/\-+/g, '-');
			}

			function iterateChilds(childsObj, cb) {
				if (!childsObj) return;
				Object.keys(childsObj).forEach(function (k) { cb(childsObj[k], k); });
			}

			function sortByMenuIndex(a, b) {
				return (a.index || 999) - (b.index || 999);
			}
			function addMenuSection(title) {
				return $('<li />', { class: 'menu-section-wrapper' })
					.append(
						$('<div />', { class: 'menu-section-title' })
							.append($('<span />', { class: 'menu-section-text', text: title }))
					);
			}

			// Icon map
			var iconMap = {
				"Info": "/luci2/icons/Dashboard.svg",
				"Dashboard1": "/luci2/icons/Dashboard.svg",
				"Network": "/luci2/icons/networkManagement.svg",
				"Settings": "/luci2/icons/networkManagement.svg",
				"Management": "/luci2/icons/Routes.svg",
				"Security": "/luci2/icons/securityManagement.png",
				"System": "/luci2/icons/system.svg",
				"Commands": "/luci2/icons/Commands.png",
				"Firewall": "/luci2/icons/Configurations.png",
				"Monitoring": "/luci2/icons/Features.svg",
				"Diagnostics": "/luci2/icons/diagnostics-tools.svg",
				"Configuration": "/luci2/icons/configuration.svg",
				"Management": "/luci2/icons/management.svg"
			};

			function iconHTML(title) {
				var src = iconMap[title] || "/luci2/icons/Dashboard.svg";
				return '<span class="mm-icon"><img src="' + src + '" alt=""></span><span class="mm-label">' + (L.tr ? L.tr(title) : title) + '</span>';
			}

			// ---------- Nesting Rules ----------
			var nestRules = this.nestRules || [{ parent: 'Network', child: 'Routing' },
			{ parent: 'Security', child: 'Firewall' },
			{ parent: 'System', child: 'SNMP App' }
			];
			var nestChildSet = new Set(nestRules.map(function (r) { return r.child; }));
			var nestMapByParent = nestRules.reduce(function (m, r) {
				(m[r.parent] || (m[r.parent] = [])).push(r.child); return m;
			}, {});

			// ---------- Collect All Nodes ----------
			var nodes = [];
			L.globals.viewIndex = L.globals.viewIndex || {};
			var nodeByTitle = {};

			for (var node in childs) {
				if (!childs.hasOwnProperty(node)) continue;
				var nodeObj = childs[node];
				nodes.push(nodeObj);
				nodeByTitle[nodeObj.title] = nodeObj;
				if (nodeObj.view) L.globals.viewIndex[nodeObj.view] = nodeObj;
			}
			nodes.sort(sortByMenuIndex);
			// ---------- Section Logic ----------
			var section1Name = "Router Configurations";
			var section2Name = "Gateway Management";

			var section1Added = false;
			var section2Added = false;
			var topLevelNodeCount = 0;
			var SECTION1_LIMIT = 9; // tweak if needed


			// ---------- Containers ----------
			var sideMenu = $('<div />').addClass('side-menu-container');
			var subMenuTemplates = $('<div />', { id: 'subMenuTemplates', style: 'display:none;' });
			var ul = (level === 0) ? $('<ul />', { class: 'main-menu', id: 'mainMenu' }) : null;

			// ---------- Build Menu Logic ----------
			for (var i = 0; i < nodes.length; i++) {
				var rawTitle = nodes[i].title;
				// ---------- Section Headings (TOP LEVEL ONLY) ----------
				if (level === 0) {
					if (!section1Added) {
						ul.append(addMenuSection(section1Name));
						section1Added = true;
					}

					if (topLevelNodeCount >= SECTION1_LIMIT && !section2Added) {
						ul.append(addMenuSection(section2Name));
						section2Added = true;
					}

					topLevelNodeCount++;
				}


				// Don't render "child" at the top level (root) because it will be nested
				if (level === 0 && nestChildSet.has(rawTitle)) continue;

				var tmplId = 'submenu-' + slugify(rawTitle);
				var liTop = $('<li />', { class: 'accordion-item' });
				var aTop = $('<a />', { href: '#', html: iconHTML(rawTitle), title: L.tr(rawTitle) })
					.append($('<span />').addClass('dropdown-icon'))
					.data('template', tmplId);

				if (!nodes[i].childs && nodes[i].view) {
					aTop.attr('data-view', nodes[i].view);
				}

				liTop.append(aTop);
				if (level === 0) ul.append(liTop);

				// Submenu Processing (Where the interleaving happens)
				if (nodes[i].childs && level < max) {
					var subUl = $('<ul />', { class: 'sub-menu', id: tmplId });
					var combinedItems = [];

					// 1. Add normal pages from this parent (parent pages)
					iterateChilds(nodes[i].childs, function (c) { combinedItems.push(c); });

					// 2. Add the Nested "child" menu into this list as a sibling
					var nestChildrenTitles = nestMapByParent[rawTitle] || [];
					nestChildrenTitles.forEach(function (t) {
						var nNode = nodeByTitle[t];
						if (nNode) {
							var virtual = $.extend({}, nNode, { __isNestedParent: true });
							combinedItems.push(virtual);
						}
					});

					// 3. SORT EVERYTHING TOGETHER 
					// This is the part that places child menu between pages 2 and 3
					combinedItems.sort(sortByMenuIndex);

					// 4. Loop through sorted list and render
					combinedItems.forEach(function (item) {
						if (item.__isNestedParent) {
							// Render child as a nested accordion
							var nestedLi = $('<li />', { class: 'accordion-item' });
							var nestedA = $('<a />', { href: '#', html: L.tr(item.title) }).append($('<span />').addClass('dropdown-icon'));
							nestedLi.append(nestedA);

							var nestedUl = $('<ul />', { class: 'sub-menu accordion-sub-menu' });
							var deep = [];
							iterateChilds(item.childs, function (dc) { deep.push(dc); });
							deep.sort(sortByMenuIndex).forEach(function (dc) {
								var nnLi = $('<li />');
								var nnA = $('<a />', { href: '#', text: L.tr(dc.title) }).attr('data-view', dc.view);
								nnLi.append(nnA);
								nestedUl.append(nnLi);
								if (dc.view) L.globals.viewIndex[dc.view] = dc;
							});
							nestedLi.append(nestedUl);
							subUl.append(nestedLi);
						} else {
							// Render standard parent page
							var li = $('<li />');
							var a = $('<a />', { href: '#', text: L.tr(item.title) }).attr('data-view', item.view);
							li.append(a); subUl.append(li);
							if (item.view) L.globals.viewIndex[item.view] = item;
						}
					});
					subMenuTemplates.append(subUl);
				}
			}

			// Default Node Safety (Fixed to prevent renderView crashes)
			(function ensureDefault() {
				var v = L.getHash('view');
				if (v && L.globals.viewIndex[v]) {
					L.globals.defaultNode = L.globals.viewIndex[v];
					return;
				}
				if (!L.globals.defaultNode || !L.globals.defaultNode.view) {
					for (var key in L.globals.viewIndex) {
						if (L.globals.viewIndex[key] && L.globals.viewIndex[key].view) {
							L.globals.defaultNode = L.globals.viewIndex[key];
							break;
						}
					}
				}
			})();

			var subPanel = $('<div />', { class: 'sub-menu-panel', id: 'subMenuPanel' });
			sideMenu.append(ul).append(subPanel);
			var wrapper = $('<div />').attr('id', 'mainmenu').append(sideMenu).append(subMenuTemplates);
			var ctx = this;

			// Click Behaviors
			wrapper.on('click', 'a[data-view]', function (e) {
				e.preventDefault();
				var viewStr = $(this).attr('data-view');
				if (!viewStr || viewStr === "undefined") return;
				var targetNode = L.globals.viewIndex[viewStr];
				if (!targetNode || !targetNode.view) return;

				var ev = $.Event('click'); ev.data = viewStr;
				ctx.handleClick.call(this, ev);
				wrapper.find('#subMenuPanel').removeClass('active').empty();
				wrapper.removeClass('subpanel-open').find('.main-menu > .accordion-item').removeClass('active');
			});

			wrapper.on('click', '.main-menu > .accordion-item > a', function (e) {
				var $link = $(this);
				if ($link.attr('data-view')) return;
				e.preventDefault();
				var parent = $link.parent();
				var subMenuPanel = wrapper.find('#subMenuPanel');
				var tmplId = $link.data('template');
				var $template = tmplId ? wrapper.find('#' + tmplId) : $();

				if (parent.hasClass('active')) {
					parent.removeClass('active');
					subMenuPanel.removeClass('active').empty();
					wrapper.removeClass('subpanel-open');
					return;
				}

				wrapper.find('.main-menu > .accordion-item').removeClass('active');
				parent.addClass('active');

				if ($template.length) {
					var $clone = $template.clone().show();
					subMenuPanel.empty().append($clone).addClass('active');
					wrapper.addClass('subpanel-open');
					subMenuPanel.find('.accordion-item > a').on('click', function (ev) {
						ev.preventDefault();
						$(this).parent().toggleClass('active');
					});
				}
			});

			return wrapper.get(0);
		},

		render: function (min, max) {
			var top = min ? this.getNode(L.globals.defaultNode.view, min) : this._nodes;
			return this.renderNodes(top.childs, 0, min, max);
		},

		getNode: function (path, max) {
			var p = path.split(/\//);
			var n = this._nodes;

			if (typeof (max) == 'undefined')
				max = p.length;

			for (var i = 0; i < max; i++) {
				if (!n.childs[p[i]])
					return undefined;

				n = n.childs[p[i]];
			}

			return n;
		}
	});

	ui_class.table = ui_class.AbstractWidget.extend({
		init: function () {
			this._rows = [];
		},

		row: function (values) {
			if ($.isArray(values)) {
				this._rows.push(values);
			}
			else if ($.isPlainObject(values)) {
				var v = [];
				for (var i = 0; i < this.options.columns.length; i++) {
					var col = this.options.columns[i];

					if (typeof col.key == 'string')
						v.push(values[col.key]);
					else
						v.push(null);
				}
				this._rows.push(v);
			}
		},

		rows: function (rows) {
			for (var i = 0; i < rows.length; i++)
				this.row(rows[i]);
		},

		render: function (id) {
			var fieldset = document.createElement('fieldset');
			fieldset.className = 'cbi-section';

			if (this.options.caption) {
				var legend = document.createElement('legend');
				$(legend).append(this.options.caption);
				fieldset.appendChild(legend);
			}

			var table = document.createElement('table');
			table.className = 'table table-condensed table-hover';

			var has_caption = false;
			var has_description = false;

			for (var i = 0; i < this.options.columns.length; i++)
				if (this.options.columns[i].caption) {
					has_caption = true;
					break;
				}
				else if (this.options.columns[i].description) {
					has_description = true;
					break;
				}

			if (has_caption) {
				var tr = table.insertRow(-1);
				tr.className = 'cbi-section-table-titles';

				for (var i = 0; i < this.options.columns.length; i++) {
					var col = this.options.columns[i];
					var th = document.createElement('th');
					th.className = 'cbi-section-table-cell';

					tr.appendChild(th);

					if (col.width)
						th.style.width = col.width;

					if (col.align)
						th.style.textAlign = col.align;

					if (col.caption)
						$(th).append(col.caption);
				}
			}

			if (has_description) {
				var tr = table.insertRow(-1);
				tr.className = 'cbi-section-table-descr';

				for (var i = 0; i < this.options.columns.length; i++) {
					var col = this.options.columns[i];
					var th = document.createElement('th');
					th.className = 'cbi-section-table-cell';

					tr.appendChild(th);

					if (col.width)
						th.style.width = col.width;

					if (col.align)
						th.style.textAlign = col.align;

					if (col.description)
						$(th).append(col.description);
				}
			}

			if (this._rows.length == 0) {
				if (this.options.placeholder) {
					var tr = table.insertRow(-1);
					var td = tr.insertCell(-1);
					td.className = 'cbi-section-table-cell';

					td.colSpan = this.options.columns.length;
					$(td).append(this.options.placeholder);
				}
			}
			else {
				for (var i = 0; i < this._rows.length; i++) {
					var tr = table.insertRow(-1);

					for (var j = 0; j < this.options.columns.length; j++) {
						var col = this.options.columns[j];
						var td = tr.insertCell(-1);

						var val = this._rows[i][j];

						if (typeof (val) == 'undefined')
							val = col.placeholder;

						if (typeof (val) == 'undefined')
							val = '';

						if (col.width)
							td.style.width = col.width;

						if (col.align)
							td.style.textAlign = col.align;

						if (typeof col.format == 'string')
							$(td).append(col.format.format(val));
						else if (typeof col.format == 'function')
							$(td).append(col.format(val, i));
						else
							$(td).append(val);
					}
				}
			}

			this._rows = [];
			fieldset.appendChild(table);

			return fieldset;
		}
	});

	ui_class.table1 = ui_class.AbstractWidget.extend({
		init: function () {
			this._rows = [];
			this.clearTable();
		},

		clearTable: function () {
			var table = document.getElementById(this.options.id);
			if (table) {
				// Remove the entire table element
				table.parentNode.removeChild(table);
			}
		},

		row: function (values) {
			if ($.isArray(values)) {
				this._rows.push(values);
			}
			else if ($.isPlainObject(values)) {
				var v = [];
				for (var i = 0; i < this.options.columns.length; i++) {
					var col = this.options.columns[i];

					if (typeof col.key == 'string')
						v.push(values[col.key]);
					else
						v.push(null);
				}
				this._rows.push(v);
			}
		},

		rows: function (rows) {
			for (var i = 0; i < rows.length; i++)
				this.row(rows[i]);
		},

		render: function (id) {
			var fieldset = document.createElement('fieldset');
			fieldset.className = 'cbi-section';

			if (this.options.id)
				fieldset.id = this.options.id;

			if (this.options.caption) {
				var legend = document.createElement('legend');
				$(legend).append(this.options.caption);
				fieldset.appendChild(legend);
			}

			var table = document.createElement('table');
			table.className = 'table table-condensed table-hover';

			if (this.options.id)
				table.id = this.options.id;

			var has_caption = false;
			var has_description = false;

			for (var i = 0; i < this.options.columns.length; i++)
				if (this.options.columns[i].caption) {
					has_caption = true;
					break;
				}
				else if (this.options.columns[i].description) {
					has_description = true;
					break;
				}

			if (has_caption) {
				var tr = table.insertRow(-1);
				tr.className = 'cbi-section-table-titles';

				for (var i = 0; i < this.options.columns.length; i++) {
					var col = this.options.columns[i];
					var th = document.createElement('th');
					th.className = 'cbi-section-table-cell';

					tr.appendChild(th);

					if (col.width)
						th.style.width = col.width;

					if (col.align)
						th.style.textAlign = col.align;

					if (col.caption)
						$(th).append(col.caption);
				}
			}

			if (has_description) {
				var tr = table.insertRow(-1);
				tr.className = 'cbi-section-table-descr';

				for (var i = 0; i < this.options.columns.length; i++) {
					var col = this.options.columns[i];
					var th = document.createElement('th');
					th.className = 'cbi-section-table-cell';

					tr.appendChild(th);

					if (col.width)
						th.style.width = col.width;

					if (col.align)
						th.style.textAlign = col.align;

					if (col.description)
						$(th).append(col.description);
				}
			}

			if (this._rows.length == 0) {
				if (this.options.placeholder) {
					var tr = table.insertRow(-1);
					var td = tr.insertCell(-1);
					td.className = 'cbi-section-table-cell';

					td.colSpan = this.options.columns.length;
					$(td).append(this.options.placeholder);
				}
			}
			else {
				for (var i = 0; i < this._rows.length; i++) {
					var tr = table.insertRow(-1);

					for (var j = 0; j < this.options.columns.length; j++) {
						var col = this.options.columns[j];
						var td = tr.insertCell(-1);

						var val = this._rows[i][j];

						if (typeof (val) == 'undefined')
							val = col.placeholder;

						if (typeof (val) == 'undefined')
							val = '';

						if (col.width)
							td.style.width = col.width;

						if (col.align)
							td.style.textAlign = col.align;

						if (typeof col.format == 'string')
							$(td).append(col.format.format(val));
						else if (typeof col.format == 'function')
							$(td).append(col.format(val, i));
						else
							$(td).append(val);
					}
				}
			}

			this._rows = [];
			fieldset.appendChild(table);

			return fieldset;
		}
	});

	// Router action btn Logic
	$('#router_actions').on('click', '.action-item', function (e) {
		const action = $(this).data('action'); // 'reboot' | 'restart' | 'logout' | 'password'
		switch (action) {
			case 'reboot':
				L.ui.confirmAction('reboot', function (ok) {
					if (!ok) return;
					L.ui.routeractions('reboot')
				});


				break;
			case 'restart':
				L.ui.confirmAction('network', function (ok) {
					if (!ok) return;
					L.ui.routeractions('network')
				});

				break;
			case 'logout':
				L.ui.confirmAction('logout', function (ok) {
					if (!ok) return;
					let params = window.location.href;
					var link = params.split(",")[0]
					link = link + ",view:logout/logout";
					window.open(link, "_self");
				});
				break;

			case 'password':
				L.ui.confirmAction('password', function (ok) {
					if (!ok) return;
					let params = window.location.href;
					var link = params.split(",")[0]
					link = link + ",view:system/changepassword";
					window.open(link, "_self");
				});
				break;

		}
	});



	ui_class.grid = ui_class.AbstractWidget.extend({
		init: function () {
			this._rows = [];
		},

		row: function (values) {
			if ($.isArray(values)) {
				this._rows.push(values);
			}
			else if ($.isPlainObject(values)) {
				var v = [];
				for (var i = 0; i < this.options.columns.length; i++) {
					var col = this.options.columns[i];

					if (typeof col.key == 'string')
						v.push(values[col.key]);
					else
						v.push(null);
				}
				this._rows.push(v);
			}
		},

		rows: function (rows) {
			for (var i = 0; i < rows.length; i++)
				this.row(rows[i]);
		},

		createCell: function (col, classNames) {
			var sizes = ['xs', 'sm', 'md', 'lg'];

			var cell = $('<div />')
				.addClass('cell clearfix');

			if (classNames)
				cell.addClass(classNames);

			if (col.nowrap)
				cell.addClass('nowrap');

			if (col.align)
				cell.css('text-align', col.align);

			for (var i = 0; i < sizes.length; i++)
				cell.addClass((col['width_' + sizes[i]] > 0)
					? 'col-%s-%d'.format(sizes[i], col['width_' + sizes[i]])
					: 'hidden-%s'.format(sizes[i]));

			if (col.hidden)
				cell.addClass('hidden-%s'.format(col.hidden));

			return cell;
		},

		render: function (id) {
			var fieldset = $('<fieldset />')
				.addClass('cbi-section');

			if (this.options.caption)
				fieldset.append($('<legend />').append(this.options.caption));

			var grid = $('<div />')
				.addClass('luci2-grid luci2-grid-hover');

			if (this.options.condensed)
				grid.addClass('luci2-grid-condensed');

			var has_caption = false;
			var has_description = false;

			var sizes = ['xs', 'sm', 'md', 'lg'];

			for (var i = 0; i < sizes.length; i++) {
				var size = sizes[i];
				var width_unk = 0;
				var width_dyn = 0;
				var width_rem = 12;

				for (var j = 0; j < this.options.columns.length; j++) {
					var col = this.options.columns[j];
					var k = i, width = NaN;

					do { width = col['width_' + sizes[k++]]; }
					while (isNaN(width) && k < sizes.length);

					if (isNaN(width))
						width = col.width;

					if (isNaN(width))
						width_unk++;
					else
						width_rem -= width, col['width_' + size] = width;

					if (col.caption)
						has_caption = true;

					if (col.description)
						has_description = true;
				}

				if (width_unk > 0)
					width_dyn = Math.floor(width_rem / width_unk);

				for (var j = 0; j < this.options.columns.length; j++)
					if (isNaN(this.options.columns[j]['width_' + size]))
						this.options.columns[j]['width_' + size] = width_dyn;
			}

			if (has_caption) {
				var row = $('<div />')
					.addClass('row')
					.appendTo(grid);

				for (var i = 0; i < this.options.columns.length; i++) {
					var col = this.options.columns[i];
					var cell = this.createCell(col, 'caption')
						.appendTo(row);

					if (col.caption)
						cell.append(col.caption);
				}
			}

			if (has_description) {
				var row = $('<div />')
					.addClass('row')
					.appendTo(grid);

				for (var i = 0; i < this.options.columns.length; i++) {
					var col = this.options.columns[i];
					var cell = this.createCell(col, 'description')
						.appendTo(row);

					if (col.description)
						cell.append(col.description);
				}
			}

			if (this._rows.length == 0) {
				if (this.options.placeholder)
					$('<div />')
						.addClass('row')
						.append($('<div />')
							.addClass('col-md-12 cell placeholder clearfix')
							.append(this.options.placeholder))
						.appendTo(grid);
			}
			else {
				for (var i = 0; i < this._rows.length; i++) {
					var row = $('<div />')
						.addClass('row')
						.appendTo(grid);

					for (var j = 0; j < this.options.columns.length; j++) {
						var col = this.options.columns[j];
						var cell = this.createCell(col, 'content')
							.appendTo(row);

						var val = this._rows[i][j];

						if (typeof (val) == 'undefined')
							val = col.placeholder;

						if (typeof (val) == 'undefined')
							val = '';

						if (typeof col.format == 'string')
							cell.append(col.format.format(val));
						else if (typeof col.format == 'function')
							cell.append(col.format(val, i));
						else
							cell.append(val);
					}
				}
			}

			this._rows = [];

			return fieldset.append(grid);
		}
	});

	ui_class.hlist = ui_class.AbstractWidget.extend({
		render: function () {
			if (!$.isArray(this.options.items))
				return '';

			var list = $('<span />');
			var sep = this.options.separator || ' | ';
			var items = [];

			for (var i = 0; i < this.options.items.length; i += 2) {
				if (typeof (this.options.items[i + 1]) === 'undefined' ||
					this.options.items[i + 1] === '')
					continue;

				items.push(this.options.items[i], this.options.items[i + 1]);
			}

			for (var i = 0; i < items.length; i += 2) {
				list.append($('<span />')
					.addClass('nowrap')
					.append($('<strong />')
						.append(items[i])
						.append(': '))
					.append(items[i + 1])
					.append(((i + 2) < items.length) ? sep : ''))
					.append(' ');
			}

			return list;
		}
	});

	ui_class.progress = ui_class.AbstractWidget.extend({
		render: function () {
			var vn = parseInt(this.options.value) || 0;
			var mn = parseInt(this.options.max) || 100;
			var pc = Math.floor((100 / mn) * vn);

			var text;

			if (typeof (this.options.format) == 'string')
				text = this.options.format.format(this.options.value, this.options.max, pc);
			else if (typeof (this.options.format) == 'function')
				text = this.options.format(pc);
			else
				text = '%.2f%%'.format(pc);

			return $('<div />')
				.addClass('progress')
				.append($('<div />')
					.addClass('progress-bar')
					.addClass('progress-bar-info')
					.css('width', pc + '%'))
				.append($('<small />')
					.text(text));
		}
	});

	ui_class.devicebadge = ui_class.AbstractWidget.extend({
		render: function () {
			var l2dev = this.options.l2_device || this.options.device;
			var l3dev = this.options.l3_device;
			var dev = l3dev || l2dev || '?';

			var span = document.createElement('span');
			span.className = 'badge';

			if (typeof (this.options.signal) == 'number' ||
				typeof (this.options.noise) == 'number') {
				var r = 'none';
				if (typeof (this.options.signal) != 'undefined' &&
					typeof (this.options.noise) != 'undefined') {
					var q = (-1 * (this.options.noise - this.options.signal)) / 5;
					if (q < 1)
						r = '0';
					else if (q < 2)
						r = '0-25';
					else if (q < 3)
						r = '25-50';
					else if (q < 4)
						r = '50-75';
					else
						r = '75-100';
				}

				span.appendChild(document.createElement('img'));
				span.lastChild.src = L.globals.resource + '/icons/signal-' + r + '.png';

				if (r == 'none')
					span.title = L.tr('No signal');
				else
					span.title = '%s: %d %s / %s: %d %s'.format(
						L.tr('Signal'), this.options.signal, L.tr('dBm'),
						L.tr('Noise'), this.options.noise, L.tr('dBm')
					);
			}
			else {
				var type = 'ethernet';
				var desc = L.tr('Ethernet device');

				if (l3dev != l2dev) {
					type = 'tunnel';
					desc = L.tr('Tunnel interface');
				}
				else if (dev.indexOf('br-') == 0) {
					type = 'bridge';
					desc = L.tr('Bridge');
				}
				else if (dev.indexOf('.') > 0) {
					type = 'vlan';
					desc = L.tr('VLAN interface');
				}
				else if (dev.indexOf('wlan') == 0 ||
					dev.indexOf('ath') == 0 ||
					dev.indexOf('wl') == 0) {
					type = 'wifi';
					desc = L.tr('Wireless Network');
				}

				span.appendChild(document.createElement('img'));
				span.lastChild.src = L.globals.resource + '/icons/' + type + (this.options.up ? '' : '_disabled') + '.png';
				span.title = desc;
			}

			$(span).append(' ');
			$(span).append(dev);

			return span;
		}
	});

	return Class.extend(ui_class);

})();

