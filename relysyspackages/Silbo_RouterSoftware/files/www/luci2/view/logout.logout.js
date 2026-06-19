L.ui.view.extend({


    updatefirewallconfig: L.rpc.declare({
        object: 'rpc-logout',
        method: 'configure',
        params: ['sid', 'proto', 'loginip'],
        expect: { output: '' }
    }),

    execute: function () {
        var self = this;
        L.ui.loading(true);
        let active_sessionid = L.globals.sid;
        let url = window.location.href;
        let protocol = window.location.protocol.replace(":", "");
        let host = window.location.href;
        let ip = host.split("/")[2];

        self.updatefirewallconfig(active_sessionid, protocol, ip).then(function (rv) {
            console.log(rv)
            if (rv === "1") {
                L.ui.loading(false);
                L.ui.showAlert(
                    'error',
                    'Logout Failed',
                    'Logout failed. Please try again.'
                );
                return
            }
            else {
                L.ui.loading(false);
                L.ui.showAlert(
                    'success',
                    'Logout Successful',
                    'You have been logged out successfully.'
                );

                setTimeout(() => {
                    location.href = rv;
                    L.ui.login(true);
                }, 1000);
            }
        });
    }
});
