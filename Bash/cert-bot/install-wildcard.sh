# info: https://certbot.eff.org/instructions?ws=web-hosting-product&os=ubuntu-18

# Install certbot and certbot-dns-azure
sudo apt-get -y install python3-pip
sudo pip3 -y  install certbot certbot-dns-azure 
sudo pip3 install -Iv zope.interface==5.4.0
sudo pip3 install -Iv cryptography==2.5

# Install while running
sudo certbot certonly \
  --authenticator dns-azure \
  --preferred-challenges dns \
  --noninteractive \
  --agree-tos \
  --dns-azure-config .secrets/certbot/azure.ini \
  -d cvp-recording.sandbox.platform.cp.net

# Test cert update
sudo certbot renew --dry-run

# Auto Renewal > https://eff-certbot.readthedocs.io/en/stable/using.html#setting-up-automated-renewal
SLEEPTIME=$(awk 'BEGIN{srand(); print int(rand()*(3600+1))}'); echo "0 0,12 * * * root sleep $SLEEPTIME && sudo certbot renew -q" | sudo tee -a /etc/crontab > /dev/null