L.ui.view.extend({
	refresh: 5000,

	getKernelLog: L.rpc.declare({
		object: 'luci2.system',
		method: 'dmesg',
		expect: { log: '' }
	}),

	execute: function () {
		return this.getKernelLog().then(function (log) {
			var pre = document.getElementById('syslog');
			var lines = log.replace(/\n+$/, '').split(/\n/);
			var formatted = lines.reverse().join("\n");
			pre.textContent = formatted;
			pre.scrollTop = pre.scrollHeight;
		});
	}
});


