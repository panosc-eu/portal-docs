## Portal installation script for Debian / Ubuntu / CentOS

if [ -f /etc/os-release ]; then
  source /etc/os-release
  DISTRO=$ID
  echo "Distro is $DISTRO"
else [ -f '/etc/redhat-release' ]
  DISTRO="Redhat"
fi

CUBE_NAMESPACE="panosc-portal"
# Keycloack
KC_REALM='Panosc'
KC_USERNAME='kc_user'
KC_CLIENT_ID='panosc-portal'
# Helm
HELM_RELEASE='panosc-portal'

# TODO: if Ubuntu/Debian

# helm
echo "\nInstall Helm:"
curl https://baltocdn.com/helm/signing.asc | sudo apt-key add -
sudo apt-get install -y apt-transport-https ca-certificates gnupg lsb-release
echo "deb https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update --allow-insecure-repositories
sudo apt-get install --allow-unauthenticated -y helm



# Docker machinery
echo "\nInstall Docker machinery:"
if [ $DISTRO == 'ubuntu' ]; then
  echo "\nInstall Docker from docker.com"
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
  echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt-get update
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io
  sudo usermod -aG docker $USER

  echo "\nInstall kubectl from google services:"
  sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
  echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
  sudo apt-get update
  sudo apt-get install -y kubectl

  echo "\nInstall minikube"
  curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube_latest_amd64.deb
  sudo dpkg -i minikube_latest_amd64.deb
fi

# Java:
sudo apt-get install -y default-jre-headless

# keycloak
KEYCLOAK_VER="13.0.1"
KEYCLOAK="keycloak-$KEYCLOAK_VER"
echo "Downloading $KEYCLOAK:"
curl -LO "https://github.com/keycloak/keycloak/releases/download/$KEYCLOAK_VER/$KEYCLOAK.tar.gz"
tar xvzf "$KEYCLOAK.tar.gz"

# TODO: Configure Keycloak
#./$KEYCLOAK/bin/add-user.sh
#./$KEYCLOAK/bin$ ./standalone.sh


#sudo apt-get install -y socat git
socat tcp-listen:8090,reuseaddr,fork tcp:localhost:8080 &


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
helm install $HELM_RELEASE panosc-portal/panosc-portal-demo \
--set global.kubernetesMasterHostname=<Yourk8sMaster> \
--set account-service.idp.url=<YourOpenIDDiscoveryEndpoint> \      #<KEYCLOAK_EXTERNAL_IP>
--set account-service.idp.clientId=<YourClientID> \
--set account-service.idp.loginField=<YourLoginField> \
-n $CUBE_NAMESPACE

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
#cd api-service-client-cli
#npm install && npm audit fix