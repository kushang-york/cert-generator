# domain_arg=$1

CONFIG_FOLDER="/var/www/certificates"
WEBROOT_PATH="/var/www/html"
NGINX_CONF_DIR="/etc/nginx/sites"

if [ ! -d "$CONFIG_FOLDER" ]; then
    mkdir -p "$CONFIG_FOLDER"
fi

#Function to proces a domain
process_domain() {
    echo $1
    local domain=$1
    local email_suffix=$(date +%s)
    local email="devops+${email_suffix}@broadlume.com"
    echo "Processing $domain..."
    if certbot certonly --standalone -d "$domain" -n --email "$email" --agree-tos \
    --config-dir "$CONFIG_FOLDER" --work-dir "$CONFIG_FOLDER" --logs-dir "$CONFIG_FOLDER"; then
        echo "$domain"
        create_nginx_conf "$domain"
    else
        echo "$domain: SSL certificate creation failed or domain validation failed." >&2
        exit 1
        echo "$domain"
    fi
}
create_nginx_conf() {
    local domain=$1
    local conf_file="$NGINX_CONF_DIR/$domain.conf"
    local ssl_block_exists=$(grep -c "listen 443 ssl;" "$conf_file")
    if [ -f "$conf_file" ]; then
        echo "Updating Nginx configuration for $domain..."
    else
        echo "Creating Nginx configuration for $domain..."
    cat << EOF > "$conf_file"
server {
  listen 80;
  server_name $domain www.$domain;
  location ^~ /.well-known/acme-challenge/ {
    root $WEBROOT_PATH/$domain;
  }
  location / {
    return 301 https://\$host\$request_uri;
  }
}
server {
  listen 443 ssl;
  server_name www.$domain;
  location / {
    return 301 https://\$host\$request_uri;
  }
  ssl_certificate $CONFIG_FOLDER/live/$domain/fullchain.pem;
  ssl_certificate_key $CONFIG_FOLDER/live/$domain/privkey.pem;
}
server {
  listen 443 ssl;
  server_name $domain;
  location ^~ /.well-known/acme-challenge/ {
    root $WEBROOT_PATH/$domain;
    return 301 https://www.\$host\$request_uri;
  }
  ssl_certificate $CONFIG_FOLDER/live/$domain/fullchain.pem;
  ssl_certificate_key $CONFIG_FOLDER/live/$domain/privkey.pem;
}
EOF
    fi
# Check for syntax errors
nginx -t && systemctl reload nginx 
}
# Main processing loop for each domain in the file

process_domain "$domain_arg"