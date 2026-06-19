L.ui.view.extend({

	updatefirewallconfig: L.rpc.declare({
		object: 'rpc-UpdateCLI',
		method: 'configure',
		params: ['status'],
		expect: { output: '' }
	}),





	execute: function () {
		var self = this;

		var status = "Enable"
		self.updatefirewallconfig(status).then(function (rv) {


		});
	}


});

