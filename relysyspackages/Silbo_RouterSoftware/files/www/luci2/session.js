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


	GetUCISections: L.rpc.declare({
		object: 'uci',
		method: 'get',
		params: ['config', 'type'],
		expect: { values: {} }
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

		if (this._hearbeatInterval) {
			clearInterval(this._hearbeatInterval);
		}

		this._hearbeatInterval = setInterval(() => {

			L.session.isAlive()
				.then(alive => {
					if (!alive) {
						console.warn("Session expired");
						this.stopHeartbeat();
						localStorage.setItem("loginReason", "timeout");
						window.location.href = window.location.origin + '/';
					}
					// else → KEEP checking
				})
				.catch(() => {
					this.stopHeartbeat();
					localStorage.setItem("loginReason", "timeout");
					window.location.href = window.location.origin + '/';
				});

		}, L.globals.timeout + 5000); // keep your timing
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
