## Portal installation script for Debian / Ubuntu / CentOS

if [ -f /etc/os-release ]; then
  source /etc/os-release
  DISTRO=$ID
  echo "Distro is $DISTRO"
else [ -f '/etc/redhat-release' ]
  DISTRO="Redhat"
fi

CUBE_NAMESPACE="panosc-portal"


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

# Java:
sudo apt-get install -y default-jre-headless


# keycloak
KEYCLOAK_VER="12.0.4"
KEYCLOAK="keycloak-$KEYCLOAK_VER"
echo "Downloading $KEYCLOAK:"
curl -LO "https://github.com/keycloak/keycloak/releases/download/$KEYCLOAK_VER/$KEYCLOAK.tar.gz"
tar xvzf "$KEYCLOAK.tar.gz"

# TODO: Configure Keycloak
#./$KEYCLOAK/bin/add-user.sh
#./$KEYCLOAK/bin$ ./standalone.sh


sudo apt-get install -y socat git

# Install the portal components
git clone https://github.com/panosc-portal/api-service-client-cli
git clone https://github.com/panosc-portal/api-service
git clone https://github.com/panosc-portal/account-service-client-cli
git clone https://github.com/panosc-portal/cloud-service-client-cli
git clone https://github.com/panosc-portal/cloud-service
git clone https://github.com/panosc-portal/cloud-provider-client-cli
git clone https://github.com/panosc-portal/frontend
git clone https://github.com/panosc-portal/account-service
git clone https://github.com/panosc-portal/cloud-provider-kubernetes
git clone https://github.com/panosc-portal/simple-notebook-client
git clone https://github.com/panosc-portal/desktop-service-web-test-client
git clone https://github.com/panosc-portal/desktop-service
git clone https://github.com/panosc-portal/microservices-integration-test
git clone https://github.com/panosc-portal/helm-charts
git clone https://github.com/panosc-portal/remote-desktop-test-image
git clone https://github.com/panosc-portal/notebook-service-web-test-client
git clone https://github.com/panosc-portal/notebook-service


# Install helm components:
helm repo add panosc-portal https://panosc-portal.github.io/helm-charts/
helm repo update

kubectl create namespace $CUBE_NAMESPACE
# TODO: install helm components:


# Install Node
if [ $DISTRO == 'ubuntu' ]; then
  curl -sL https://deb.nodesource.com/setup_15.x | sudo -E bash -
  sudo apt-get install -y nodejs npm
else
  curl -fsSL https://rpm.nodesource.com/setup_15.x | bash -
  # remove an version if any:
  sudo yum remove nodejs -y
  sudo yum install nodejs npm -y
fi


### account-service-client-cli
# Go to the `api-service-client-cli` repo and install Node components:
cd api-service-client-cli
npm install && npm audit fix