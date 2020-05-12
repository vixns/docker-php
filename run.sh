#!/bin/sh

cat > /etc/ssmtp/ssmtp.conf << EOF
root=postmaster
mailhub=${SMTP_HOST}:${SMTP_PORT-25}
hostname=$(hostname -f)
FromLineOverride=YES

EOF

/usr/local/sbin/runsvdir-start