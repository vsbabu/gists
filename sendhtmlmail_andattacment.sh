MAIL_PARTBOUNDARY="`tr -dc A-Za-z0-9 </dev/urandom | head -c 16`"
/usr/sbin/sendmail -t <<EOF
From: ${MAIL_FROM}
To: ${MAIL_TO}
Cc: ${MAIL_CC}
Subject: ${MAIL_SUBJECT}
Content-Type:multipart/mixed; boundary="${MAIL_PARTBOUNDARY}"

--${MAIL_PARTBOUNDARY}
Content-Type: text/html
Content-Disposition: inline

<p>Attached as CSV file <tt>${ATTACHMENT_FN}</tt>.</p>
<p style="font-size:smaller;">Generated at <em>
`TZ=America/New_York date`
</em></p>

--${MAIL_PARTBOUNDARY}
Content-Type: text/csv
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="${ATTACHMENT_FN}"

`base64 ${ATTACHMENT_FN}`
--${MAIL_PARTBOUNDARY}--
EOF