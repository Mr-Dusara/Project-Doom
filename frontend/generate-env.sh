#!/bin/sh
cat > /usr/share/nginx/html/env.js <<EOF
window.__env = { apiIp: "${API_IP}" };
EOF
