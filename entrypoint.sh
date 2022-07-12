#!/bin/bash
cmd="/ngrok/bin/ngrokd -domain="${NGROK_DOMAIN}" -httpAddr=:${NGROK_HTTP_PORT} -httpsAddr=:${NGROK_HTTPS_PORT} -tunnelAddr=:${NGROK_TUNNEL_PORT}"
if [[ ${NGROK_TLS_CRT} ]] && [[ ${NGROK_TLS_KEY} ]] && [ -f ${NGROK_TLS_CRT} ] && [ -f ${NGROK_TLS_KEY} ];
then
    cmd=${cmd}" -tlsCrt=${NGROK_TLS_CRT} -tlsKey=${NGROK_TLS_KEY}"
fi
echo "cmd=$cmd"
$cmd