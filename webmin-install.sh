# Update system packages
sudo apt update && sudo apt upgrade -y

# Install prerequisites
sudo apt install -y wget apt-transport-https software-properties-common

# Download and add the Webmin repository key
wget -qO - http://www.webmin.com/jcameron-key.asc | sudo apt-key add -

# Add the Webmin repository to your sources list
sudo sh -c 'echo "deb http://download.webmin.com/download/repository sarge contrib" >> /etc/apt/sources.list'

# Update package lists again
sudo apt update

# Install Webmin
sudo apt install -y webmin
