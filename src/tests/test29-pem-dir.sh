#!/bin/sh
#
# Test pem-dir & pem-dir-glob options
#
. hitch_test.sh
cat >hitch.cfg <<EOF
frontend = {
	host = "localhost"
	port = "$LISTENPORT"
}

pem-dir = "${CERTSDIR}/pemdirtest"
sni-nomatch-abort = on
EOF

start_hitch --config=hitch.cfg

s_client -servername site1.example.com -connect localhost:$LISTENPORT >site1.dump
run_cmd grep -q 'subject=/CN=site1.example.com' site1.dump

s_client -servername site2.example.com -connect localhost:$LISTENPORT >site2.dump
run_cmd grep -q 'subject=/CN=site2.example.com' site2.dump

s_client -servername default.example.com -connect localhost:$LISTENPORT >default.dump
run_cmd grep -q 'subject=/CN=default.example.com' default.dump

! s_client -servername invalid.example.com -connect localhost:$LISTENPORT >unknown.dump
run_cmd grep 'unrecognized name' unknown.dump


stop_hitch
cat >hitch.cfg <<EOF
frontend = {
	host = "localhost"
	port = "$LISTENPORT"
}

pem-dir = "${CERTSDIR}/pemdirtest"
pem-dir-glob = "*site*"
sni-nomatch-abort = on
pem-file = "${CERTSDIR}/site3.example.com"
EOF

start_hitch --config=hitch.cfg

s_client -servername site1.example.com -connect localhost:$LISTENPORT >site1.dump
run_cmd grep -q 'subject=/CN=site1.example.com' site1.dump

s_client -servername site2.example.com -connect localhost:$LISTENPORT >site2.dump
run_cmd grep -q 'subject=/CN=site2.example.com' site2.dump

! s_client -servername default.example.com -connect localhost:$LISTENPORT >default.dump
run_cmd grep 'unrecognized name' unknown.dump

s_client >cfg-no-sni.dump
run_cmd grep -q 'subject=/CN=site3.example.com' cfg-no-sni.dump

