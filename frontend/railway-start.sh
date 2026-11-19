#!/bin/sh
# Writes the nginx server block for Railway, then hands over to the image's own entrypoint.
set -eu
PORT="${PORT:-5173}"
export NGINX_PORT="$PORT"
BACKEND="${OPIK_BACKEND_HOST:?OPIK_BACKEND_HOST must be host:port of the Opik backend}"
AUTH_USER="${OPIK_AUTH_USER:-opik}"
AUTH_PASSWORD="${OPIK_AUTH_PASSWORD:-}"

# Railway's private DNS (IPv6 on Railway, IPv4 in plain Docker). nginx needs it to resolve the
# backend at request time, so the UI starts even while the backend is still booting.
NS="$(awk '/^nameserver/ { print $2; exit }' /etc/resolv.conf)"
case "$NS" in *:*) NS="[$NS]" ;; esac

if [ -z "$AUTH_PASSWORD" ]; then
  echo "opik-frontend: OPIK_AUTH_PASSWORD is empty; refusing to start an open Opik instance" >&2
  exit 1
fi
printf '%s:{PLAIN}%s\n' "$AUTH_USER" "$AUTH_PASSWORD" > /tmp/opik.htpasswd
UI_AUTH='auth_basic "Opik"; auth_basic_user_file /tmp/opik.htpasswd;'
# The API accepts the same login (the browser sends it) or "Authorization: <password>",
# which is what the Opik SDK sends when OPIK_API_KEY is set to the password.
API_AUTH="satisfy any; $UI_AUTH auth_request /_opik_authz;"

PROXY_COMMON='proxy_set_header Host $host; proxy_set_header X-Real-IP $remote_addr; proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for; proxy_set_header X-Forwarded-Proto $scheme; proxy_read_timeout 90; proxy_connect_timeout 90; proxy_send_timeout 90;'

cat > /etc/nginx/conf.d/default.conf <<NGINX
client_max_body_size 2G;
client_header_buffer_size 16k;
large_client_header_buffers 4 64k;
resolver $NS valid=30s;
resolver_timeout 5s;
map \$http_authorization \$opik_key_ok { default 0; "$AUTH_PASSWORD" 1; }
server {
    listen $PORT default_server;
    listen [::]:$PORT default_server;
    server_name _;
    root /usr/share/nginx/html;
    index index.html;
    set \$opik_backend "$BACKEND";
    add_header X-Frame-Options "DENY" always;
    add_header Content-Security-Policy "frame-src 'self' https://cdn.comet.com" always;

    location = /health { access_log off; otel_trace off; add_header Content-Type text/plain; return 200 "healthy\n"; }
    location = /_opik_authz { internal; if (\$opik_key_ok) { return 204; } return 401; }

    location ~ ^/api/(.*)\$ {
        $API_AUTH
        proxy_pass http://\$opik_backend/\$1\$is_args\$args;
        $PROXY_COMMON
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
    }
    location = /oauth/consent { $UI_AUTH try_files /dev/null /index.html; }
    location ^~ /oauth/ { $API_AUTH proxy_pass http://\$opik_backend; proxy_redirect off; $PROXY_COMMON }
    location = /.well-known/oauth-authorization-server { $API_AUTH proxy_pass http://\$opik_backend; proxy_redirect off; $PROXY_COMMON }
    location / { $UI_AUTH try_files \$uri \$uri/ /index.html; }
}
NGINX
echo "opik-frontend: listening on $PORT, /api -> http://$BACKEND (resolver $NS), login user '$AUTH_USER'"
exec /docker-entrypoint.sh nginx -g "daemon off;"
