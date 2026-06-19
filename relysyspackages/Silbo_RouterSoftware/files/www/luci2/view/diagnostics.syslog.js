L.ui.view.extend({
	refresh: 5000,

	getSystemLog: L.rpc.declare({
		object: 'luci2.system',
		method: 'syslog',
		expect: { log: '' }
	}),

	execute: function () {
		return this.getSystemLog().then(function (log) {
			var pre = document.getElementById('syslog');
			var lines = log.replace(/\n+$/, '').split(/\n/);
			var formatted = lines.reverse().join("\n");
			pre.textContent = formatted;
			pre.scrollTop = pre.scrollHeight;
		});

	}
});
