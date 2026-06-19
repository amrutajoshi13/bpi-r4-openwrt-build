L.ui.view.extend({

    getValues: L.rpc.declare({
        object: 'uci',
        method: 'get',
        params: ['config', 'type'],
        expect: { values: {} }
    }),

    sensorCreateUCISection: L.rpc.declare({
        object: 'uci',
        method: 'add',
        params: ['config', 'type', 'values', 'name']
    }),

    sensorCommitUCISection: L.rpc.declare({
        object: 'uci',
        method: 'commit',
        params: ['config']
    }),

    cryptPassword: L.rpc.declare({
        object: 'luci2.ui',
        method: 'crypt',
        params: ['data'],
        expect: { crypt: '' }
    }),

    updateSection: function (config, type, name, values, errorMsg, successMsg) {
        var self = this;
        L.ui.loading(true);
        self.sensorCreateUCISection(config, type, values, name).then(function (rv) {
            if (rv) {
                L.ui.loading(false);
                if (rv.section) {
                    self.sensorCommitUCISection(config).then(function (res) {
                        if (res != 0) {
                            alert("error");
                            if (errorMsg) {
                                alert(errorMsg);
                            }
                            return false;
                        }
                        else {
                            if (successMsg) {
                                L.ui.showAlert(
                                    'success',
                                    'Configuration Applied',
                                    'Configuration has been applied successfully.'
                                );
                            }
                            location.reload();
                        }
                    });
                };
            };
        });
    },


    execute: function () {
        var self = this;
        var passwordData = {};
        $('#exampleModal').modal('show');
        self.getValues('rpcdtemp', 'rpcdtempsection').then(function (rv) {
            passwordData['password'] = rv['rpcdtemp'].password;
        });
        goBackToStoredView = function () {
            $('#exampleModal').modal('hide');
            let params = window.location.href;
            let base = params.split(",")[0];
            let view = localStorage.getItem("previousView");

            if (view) {
                base += view;
            }

            window.open(base, "_self");
            location.reload()
        },
            $('#passcancel').click(function () {

                goBackToStoredView()
            })

        savePassword = function () {
            var currentPassword = document.getElementById('current-password').value;
            var newPassword = document.getElementById('new-password').value;
            var confirmPassword = document.getElementById('confirm-password').value;

            // Password validation
            var passwordPattern = /^(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#$%^&*])[A-Za-z0-9!@#$%^&*]{8,}$/;

            if (newPassword !== confirmPassword) {
                L.ui.showAlert(
                    'error',
                    'Password Mismatch',
                    'New password and confirm password do not match. Please try again!'
                );
                return;
            }

            if (!passwordPattern.test(newPassword)) {
                L.ui.showAlert(
                    'error',
                    'Invalid Password Format',
                    'Password must contain at least one uppercase letter, one digit, one special character, and be at least 8 characters long.'
                );
                return;
            }
            if (currentPassword != passwordData['password']) {
                L.ui.showAlert(
                    'error',
                    'Incorrect Current Password',
                    'The current password you entered does not match. Please try again!'
                );
                return;
            }
            if (newPassword === currentPassword) {
                L.ui.showAlert(
                    'error',
                    'Invalid Password',
                    'The new password cannot be the same as your current password. Please choose a different password.'
                );
                return;
            }

            var sectionData = {};
            sectionData['password'] = newPassword;
            sectionData['new_password'] = newPassword;
            sectionData['confirm_password'] = confirmPassword;


            self.cryptPassword(newPassword).then(function (rv) {
                var newSectionData = {};
                newSectionData['password'] = rv;

                self.updateSection('rpcdtemp', 'rpcdtempsection', 'rpcdtemp', sectionData);
                self.updateSection('rpcd', 'login', 'admin', newSectionData);

                L.ui.showAlert(
                    'success',
                    'Password Saved',
                    'Password saved successfully! Please use this password for future logins.'
                );

                // setTimeout(function () {
                goBackToStoredView();
                // }, 1000);
            });

        }
    }
})
