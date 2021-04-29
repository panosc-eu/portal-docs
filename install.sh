## Portal installation script for Debian / Ubuntu / CentOS

if [ -f /etc/os-release ]; then
  source /etc/os-release
  DISTRO=$ID
  echo "Distro is $DISTRO"
else [ -f '/etc/redhat-release' ]
  DISTRO="Redhat"
fi

# TODO: if Ubuntu/Debian

# helm
curl https://baltocdn.com/helm/signing.asc | sudo apt-key add -
sudo apt-get install apt-transport-https --yes
echo "deb https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update --allow-insecure-repositories
sudo apt-get install -y helm

# minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube_latest_amd64.deb
sudo dpkg -i minikube_latest_amd64.deb

#
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
# TODO: if ubuntu
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update --allow-insecure-repositories
sudo apt-get install -y --allow-unauthenticated kubectl


# tzdata:
sudo ln -fs /usr/share/zoneinfo/Europe/Berlin /etc/localtime
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends tzdata
# Java:
sudo apt-get install -y default-jre-headless


# keycloak
KEYCLOAK_VER="12.0.4"
KEYCLOAK="keycloak-$KEYCLOAK_VER"
echo "Downloading $KEYCLOAK:"
curl -LO "https://github.com/keycloak/keycloak/releases/download/$KEYCLOAK_VER/$KEYCLOAK.tar.gz"
tar xvzf "$KEYCLOAK.tar.gz"

# Configure Keycloak
./$KEYCLOAK/bin/add-user.sh
#./$KEYCLOAK/bin$ ./standalone.sh
