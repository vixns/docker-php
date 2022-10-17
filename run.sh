#!/bin/sh

cat > /etc/msmtprc << EOF

account	smtpd
host	${SMTP_HOST}
port	${SMTP_PORT-25}
auth	off
domain	$(hostname -f)
account default : smtpd

EOF

exec 2>&1

export PATH=/usr/local/bin:/usr/local/sbin:/bin:/sbin:/usr/bin:/usr/sbin

exec runsvdir -P /etc/service
