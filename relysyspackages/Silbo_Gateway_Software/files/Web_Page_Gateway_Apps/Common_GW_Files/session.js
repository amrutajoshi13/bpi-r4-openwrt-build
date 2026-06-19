Class.extend({
	login: L.rpc.declare({
		object: 'session',
		method: 'login',
		params: ['username', 'password', 'timeout'],
		expect: { '': {} }
	}),

	access: L.rpc.declare({
		object: 'session',
		method: 'access',
		params: ['scope', 'object', 'function'],
		expect: { access: false }
	}),


	updategatewaypages: L.rpc.declare({
		object: 'rpc-managegatewaypage',
		method: 'configure',
		// params: ['type', 'jsonData'],
		expect: { output: '' }
	}),




	SessionTimeout: function () {
		return fetch('/cgi-bin/session_timeout')
			.then(response => {
				if (!response.ok) throw new Error("Network error");
				return response.text();
			})
			.then(text => {
				const match = text.match(/option\s+sessiontimeout\s+'?(\d+)'?/i);
				if (match) {
					const sessionTimeoutValue = match[1];
					const timeoutMin = parseInt(sessionTimeoutValue, 10);
					const timeoutSec = Number.isNaN(timeoutMin) ? 300 : timeoutMin * 60;
					localStorage.setItem("seconds", timeoutSec);
					const timeoutMs = Number.isNaN(timeoutMin) ? 1800000 : timeoutMin * 60 * 1000;
					L.globals.timeout = timeoutMs;
					return sessionTimeoutValue;
				} else {
					console.warn("sessiontimeout not found in config");
					return null;
				}
			})
			.catch(err => {
				console.error("Fetch error:", err);
				return null;
			});
	},

	isAlive: function () {
		return L.session.access('ubus', 'session', 'access');
	},



	startHeartbeat: function () {

		// clear any previous interval before starting a new one
		if (this._hearbeatInterval) {
			window.clearInterval(this._hearbeatInterval);
		}
		this._hearbeatInterval = window.setInterval(function () {
			L.session.isAlive().then(function (alive) {
				if (!alive) {
					console.warn("Session expired after timeout + 5s");
					L.session.stopHeartbeat();
					L.session.loginReason = "timeout";
					localStorage.setItem("loginReason", "timeout");
					window.location.href = window.location.origin + '/';
				} else {
					console.log("Session still alive at timeout + 5s");
				}
			});
		}, L.globals.timeout + 5000);
	},



	stopHeartbeat: function () {
		if (typeof (this._hearbeatInterval) != 'undefined') {
			window.clearInterval(this._hearbeatInterval);
			delete this._hearbeatInterval;
		}
	},


	aclCache: {},

	callAccess: L.rpc.declare({
		object: 'session',
		method: 'access',
		expect: { '': {} }
	}),

	callAccessCallback: function (acls) {
		L.session.aclCache = acls;
	},

	updateACLs: function () {
		return L.session.callAccess()
			.then(L.session.callAccessCallback);
	},

	updategatewaypage: function () {
		L.session.updategatewaypages("configure").then(function (rv) {
			console.log("rv", rv)
		})
	},

	hasACL: function (scope, object, func) {
		var acls = L.session.aclCache;

		if (typeof (func) == 'undefined')
			return (acls && acls[scope] && acls[scope][object]);

		if (acls && acls[scope] && acls[scope][object])
			for (var i = 0; i < acls[scope][object].length; i++)
				if (acls[scope][object][i] == func)
					return true;

		return false;
	}

});
