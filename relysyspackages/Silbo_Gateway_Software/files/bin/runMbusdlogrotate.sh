#!/bin/sh

. /lib/functions.sh
mbusdlogrotatefile=/etc/logrotate.d/mbusdLogrotateConfig
logrotate "$mbusdlogrotatefile"

exit 0
