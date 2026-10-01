# info: https://certbot.eff.org/instructions?ws=web-hosting-product&os=ubuntu-18
# Install Snap
sudo snap install core
sudo snap refresh core

# Remove certbot
sudo apt-get remove certbot

# Install new certbot
sudo snap install --classic certbot

# Prepare command
sudo ln -s /snap/bin/certbot /usr/bin/certbot

# Install while running
sudo certbot certonly --standalone --register-unsafely-without-email --non-interactive --agree-tos --domains cvp-recording.sandbox.platform.cp.net -v
sudo certbot certonly --manual --register-unsafely-without-email --non-interactive --agree-tos --domains cvp-recording.sandbox.platform.cp.net -v

# Test cert update
sudo certbot renew --dry-run