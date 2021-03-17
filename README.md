## How to deploy the PaNOSC Portal





### local deployment
We need to install the following software:
* Helm + Minikube
* Keycloak
* portal microservices
* RemoteDesktop / Jupyter instances

https://github.com/panosc-portal/helm-charts/tree/master/panosc-portal-demo
https://confluence.panosc.eu/pages/viewpage.action?pageId=10879127

Please follow the instructions line by line!


helm
====
See https://helm.sh/docs/intro/install/

on Ubuntu:
```bash
curl https://baltocdn.com/helm/signing.asc | sudo apt-key add -
sudo apt-get install apt-transport-https --yes
echo "deb https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm
```

Minikube
========
See https://minikube.sigs.k8s.io/docs/start/

on Ubuntu:
```bash
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube_latest_amd64.deb
sudo dpkg -i minikube_latest_amd64.deb
```


kubectl
=======
Install Kubernetes: https://kubernetes.io/docs/tasks/tools/install-kubectl/

on Ubuntu:
```bash
sudo apt-get update && sudo apt-get install -y apt-transport-https gnupg2 curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubectl
```

test Kubernetes
===============

```bash
minikube start
kubectl get po -A
minikube dashboard   #(!!! web interface to minikube)
kubectl create deployment hello-minikube --image=k8s.gcr.io/echoserver:1.4
kubectl expose deployment hello-minikube --type=NodePort --port=8080
kubectl port-forward service/hello-minikube 7080:8080
```
then check http://localhost:7080/whateveritis

Clean up:
```bash
kubectl delete service hello-minikube
kubectl delete deployment hello-minikube
```
kubectl cluster-info     #provides the IP of <Yourk8sMaster>

Keycloak
=========
Install Keycloak
See https://www.keycloak.org/docs/latest/server_installation/#installation

- distribution files  (localhost installation)
--------------------
https://www.keycloak.org/downloads         #'keycloak-12.0.1.[zip|tar.gz]'
```bash
tar xvzf keycloak-12.0.4.tar.gz 
keycloak-12.0.4/bin$ ./standalone.sh  # check if it works
keycloak-12.0.4/bin$ ./add-user.sh    # add the admin user
```

(a) keycloak - <HAL MANAGEMENT PASSWORD>
http://127.0.0.1:9990  # HAL Management Console
http://127.0.0.1:8080  # Keycloak (create new keycloak admin user+pass when first connected)

on Keycloak Admin console:
New realm: panosc
In panosc realm, new user: <USERNAME>

Users -> Add user -> panosc_keycloak : panosc_pwd

user <USERNAME>: EmailVerification:off (to have immediately a fully enabled account)
user credentials: set password <USERPASSWORD>  temporary:off (to have immediately a fully enabled account)
new client: <CLIENT_ID>
new client scope: openid
add openid as optional client scope to client <CLIENT_ID> 

Clients -> Client Scopes -> Optional Client Scopes: button: Add selected

testing keycloak
----------------
https://www.appsdeveloperblog.com/keycloak-client-credentials-grant-example/

curl --location --request POST 'http://localhost:8080/auth/realms/panosc/protocol/openid-connect/token' --header 'Content-Type: application/x-www-form-urlencoded' --data-urlencode 'client_id=<CLIENT_ID>' --data-urlencode 'scope=openid' --data-urlencode 'grant_type=password' --data-urlencode 'username=<USERNAME>' --data-urlencode 'password=<USERPASSWORD>'

mapping to "external" port 8090
-------------------------------
Install `socat` if necessary.

``` bash
socat tcp-listen:8090,reuseaddr,fork tcp:localhost:8080 &
ifconfig        # check for <KEYCLOAK_EXTERNAL_IP>
```

curl --location --request POST 'http://<KEYCLOAK_EXTERNAL_IP>:8090/auth/realms/panosc/protocol/openid-connect/token' --header 'Content-Type: application/x-www-form-urlencoded' --data-urlencode 'client_id=<CLIENT_ID>' --data-urlencode 'scope=openid' --data-urlencode 'grant_type=password' --data-urlencode 'username=<USERNAME>' --data-urlencode 'password=<USERPASSWORD>'

<-YourLoginField-> or username is set here by default to 'preferred_username' (check in keycloak: Client Scopes > profile > Mappers > username > TokenClaimName)
also by copying the id_token generated above to https://jwt.ms/#id_token=... 

shall look similar to:

https://jwt.ms/#id_token=eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6IjdfWnVmMXR2a3dMeFlhSFMzcTZsVWpVWUlHdyIsImtpZCI6IjdfWnVmMXR2a3dMeFlhSFMzcTZsVWpVWUlHdyJ9.eyJhdWQiOiJiMTRhNzUwNS05NmU5LTQ5MjctOTFlOC0wNjAxZDBmYzljYWEiLCJpc3MiOiJodHRwczovL3N0cy53aW5kb3dzLm5ldC9mYTE1ZDY5Mi1lOWM3LTQ0NjAtYTc0My0yOWYyOTU2ZmQ0MjkvIiwiaWF0IjoxNTM2Mjc1MTI0LCJuYmYiOjE1MzYyNzUxMjQsImV4cCI6MTUzNjI3OTAyNCwiYWlvIjoiQVhRQWkvOElBQUFBcXhzdUIrUjREMnJGUXFPRVRPNFlkWGJMRDlrWjh4ZlhhZGVBTTBRMk5rTlQ1aXpmZzN1d2JXU1hodVNTajZVVDVoeTJENldxQXBCNWpLQTZaZ1o5ay9TVTI3dVY5Y2V0WGZMT3RwTnR0Z2s1RGNCdGsrTExzdHovSmcrZ1lSbXY5YlVVNFhscGhUYzZDODZKbWoxRkN3PT0iLCJhbXIiOlsicnNhIl0sImVtYWlsIjoiYWJlbGlAbWljcm9zb2Z0LmNvbSIsImZhbWlseV9uYW1lIjoiTGluY29sbiIsImdpdmVuX25hbWUiOiJBYmUiLCJpZHAiOiJodHRwczovL3N0cy53aW5kb3dzLm5ldC83MmY5ODhiZi04NmYxLTQxYWYtOTFhYi0yZDdjZDAxMWRiNDcvIiwiaXBhZGRyIjoiMTMxLjEwNy4yMjIuMjIiLCJuYW1lIjoiYWJlbGkiLCJub25jZSI6IjEyMzUyMyIsIm9pZCI6IjA1ODMzYjZiLWFhMWQtNDJkNC05ZWMwLTFiMmJiOTE5NDQzOCIsInJoIjoiSSIsInN1YiI6IjVfSjlyU3NzOC1qdnRfSWN1NnVlUk5MOHhYYjhMRjRGc2dfS29vQzJSSlEiLCJ0aWQiOiJmYTE1ZDY5Mi1lOWM3LTQ0NjAtYTc0My0yOWYyOTU2ZmQ0MjkiLCJ1bmlxdWVfbmFtZSI6IkFiZUxpQG1pY3Jvc29mdC5jb20iLCJ1dGkiOiJMeGVfNDZHcVRrT3BHU2ZUbG40RUFBIiwidmVyIjoiMS4wIn0=.UJQrCA6qn2bXq57qzGX_-D3HcPHqBMOKDPx4su1yKRLNErVD8xkxJLNLVRdASHqEcpyDctbdHccu6DPpkq5f0ibcaQFhejQNcABidJCTz0Bb2AbdUCTqAzdt9pdgQvMBnVH1xk3SCM6d4BbT4BkLLj10ZLasX7vRknaSjE_C5DI7Fg4WrZPwOhII1dB0HEZ_qpNaYXEiy-o94UJ94zCr07GgrqMsfYQqFR7kn-mn68AjvLcgwSfZvyR_yIK75S_K37vC3QryQ7cNoafDe9upql_6pB2ybMVlgWPs_DmbJ8g0om-sPlwyn74Cc1tW3ze-Xptw_2uVdPgWyqfuWAfq6Q


Install the portal components
=============================

clone:
```bash
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
```

#### Install helm components
```bash
helm repo add panosc-portal https://panosc-portal.github.io/helm-charts/
helm repo update

kubectl create namespace panosc-portal  #<YourExistentNamespace>
```
The installation command template:
```bash
helm install <YourReleaseName> panosc-portal/panosc-portal-demo \
--set global.kubernetesMasterHostname=<Yourk8sMaster> \      
--set account-service.idp.url=<YourOpenIDDiscoveryEndpoint> \      #<KEYCLOAK_EXTERNAL_IP>
--set account-service.idp.clientId=<YourClientID> \
--set account-service.idp.loginField=<YourLoginField> \
-n <YourExistentNamespace>
```
eg:
```bash
helm install panosc-portal panosc-portal/panosc-portal-demo \
--set global.kubernetesMasterHostname=192.168.99.100 \
--set account-service.idp.url=http://131.169.212.94:8090/auth/realms/panosc/.well-known/openid-configuration \
--set account-service.idp.clientId=PanoscPortal \
--set account-service.idp.loginField=preferred_username \
-n panosc-portal
```

Now wait until the portal is up and running (check on minikube dashboard)



Test the portal
===============

#### Install Node.js

See https://github.com/nodesource/distributions/blob/master/README.md

on Ubuntu / Debian
```bash
curl -sL https://deb.nodesource.com/setup_15.x | sudo -E bash -
sudo apt-get install -y nodejs
```
on RedHat
```bash
curl -fsSL https://rpm.nodesource.com/setup_15.x | bash -
# remove an version if any: yum remove nodejs -y
yum install nodejs -y
```

### account-service-client-cli
Go to the `api-service-client-cli` repo and install Node components:
```bash
cd api-service-client-cli
npm install
```

### create a config:
In the same `api-service-client-cli` folder create a file `config.json`
with the following content
```json
{
  "idp": {
    "url": "http://<KEYCLOAK_EXTERNAL_IP>:8090/auth/realms/panosc/protocol/openid-connect/token",
    "clientId": "<CLIENT_ID>"
  }
}
```

allow connecting external (local) client to kubernetes api service on the default port 3000 (check namespace!):
`kubectl port-forward -n <YourExistentNamespace> service/api-service 3000:3000`

```bash
bin/run user-instance:list #provide <USERNAME> and <USERPASSWORD> if requested for obtaining a token
bin/run user-instance:add  #(select e.g plan jupyer_small and name it jupytersmall)
```

<!---
alternatively with a different [portnumber]:
bin/run user-instance:list -u http://localhost:[portnumber]
or simply without the extra proxying above:
bin/run user-instance:list -u http://<Yourk8sMaster>:32306/portal

sandor@exflpcx18296:~/work/PanoscPortal/git/api-service-client-cli$ bin/run user-instance:list -u http://192.168.99.100:32306/portal
Token read from token.json
┌────┬──────────────┬────────────────┬──────────┬────────┬──────────────────────┬─────────────┬─────────────────────────────┬────────────────┬───────────────┐
│ Id │         Name │ Cloud Provider │ Cloud Id │ Status │                 Plan │       Image │                     Flavour │           Host │     Protocols │
├────┼──────────────┼────────────────┼──────────┼────────┼──────────────────────┼─────────────┼─────────────────────────────┼────────────────┼───────────────┤
│  8 │ desktopsmall │  localhost-k8s │        1 │ ACTIVE │ remote_desktop_small │ ubuntu-xrdp │ small (1 Cores, 1024MB RAM) │ 192.168.99.100 │ GUACD (31489) │
└────┴──────────────┴────────────────┴──────────┴────────┴──────────────────────┴─────────────┴─────────────────────────────┴────────────────┴───────────────┘

Status: BUILDING > STARTING > ACTIVE (ERROR if something goes wrong e.g not enough memory on host)

sandor@exflpcx18296:~/work/PanoscPortal/git/api-service-client-cli$ bin/run user-instance:token
Token read from token.json
? Choose an instance for the authorisation token desktopsmall (id=8, image=ubuntu-xrdp, status=ACTIV
E)
Getting authorisation token for instance 8...
... token is : '8c94d887-6242-4817-9628-fff9c5fb4992'

http://192.168.99.100:32407/instances/8?token=8c94d887-6242-4817-9628-fff9c5fb4992
in general:
http://<Yourk8sMaster>:32407/instances/<Id from the table>?token=<as obtained above>

username/pass: ubuntu ubuntu

and it works!!!

sandor@exflpcx18296:~/work/PanoscPortal/git/api-service-client-cli$ bin/run user-instance:delete
Token read from token.json
Refreshing token...
... token refreshed successfully (saved to token.json)
? Choose a instance to delete desktopsmall (id=8, plan=remote_desktop_small, status=ACTIVE)
Deleting instance 8...
... done
sandor@exflpcx18296:~/work/PanoscPortal/git/api-service-client-cli$ bin/run user-instance:add
Token read from token.json
? Choose a plan jupyter_small (provider=localhost-k8s, image=jupyter, flavour=small)
? Enter a name for the instance jupytersmall
? Enter a description for the instance (optional) 
{"name":"jupytersmall","description":"","planId":1}
Creating instance...
... done
┌────┬──────────────┬────────────────┬──────────┬──────────┬───────────────┬─────────┬─────────────────────────────┬──────┬───────────┐
│ Id │         Name │ Cloud Provider │ Cloud Id │   Status │          Plan │   Image │                     Flavour │ Host │ Protocols │
├────┼──────────────┼────────────────┼──────────┼──────────┼───────────────┼─────────┼─────────────────────────────┼──────┼───────────┤
│  9 │ jupytersmall │  localhost-k8s │        2 │ BUILDING │ jupyter_small │ jupyter │ small (1 Cores, 1024MB RAM) │      │           │
└────┴──────────────┴────────────────┴──────────┴──────────┴───────────────┴─────────┴─────────────────────────────┴──────┴───────────┘
sandor@exflpcx18296:~/work/PanoscPortal/git/api-service-client-cli$ bin/run user-instance:list
Token read from token.json
┌────┬──────────────┬────────────────┬──────────┬────────┬───────────────┬─────────┬─────────────────────────────┬────────────────┬──────────────┐
│ Id │         Name │ Cloud Provider │ Cloud Id │ Status │          Plan │   Image │                     Flavour │           Host │    Protocols │
├────┼──────────────┼────────────────┼──────────┼────────┼───────────────┼─────────┼─────────────────────────────┼────────────────┼──────────────┤
│  9 │ jupytersmall │  localhost-k8s │        2 │ ACTIVE │ jupyter_small │ jupyter │ small (1 Cores, 1024MB RAM) │ 192.168.99.100 │ HTTP (31065) │
└────┴──────────────┴────────────────┴──────────┴────────┴───────────────┴─────────┴─────────────────────────────┴────────────────┴──────────────┘

http://192.168.99.100:31065/login?next=%2Ftree%3F
in general:
http://<Yourk8sMaster>:<port from table above>/

password: ""       !!! 2 quotation marks!!! - based on the Log of the instance on Kubernetes Replica Set:
> Set username to: jovyan
> usermod: no changes
> Executing the command: jupyter notebook --NotebookApp.token=""
> /opt/conda/lib/python3.8/site-packages/traitlets/traitlets.py:2196: FutureWarning: Supporting extra quotes around Unicode is deprecated in traitlets 5.0. Use '' instead of '""' – or use CUnicode.
> ...

and it works, too!!!


Clean up
========

helm uninstall panosc-portal -n <YourExistentNamespace>
minikube stop
kill socat and keycloak's standalone.sh


yarn
====
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt-get update && sudo apt-get install yarn

chrome
======
https://linuxize.com/post/how-to-install-google-chrome-web-browser-on-ubuntu-20-04/

wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt install ./google-chrome-stable_current_amd64.deb

integration to VSCode:
https://create-react-app.dev/docs/setting-up-your-editor
+ .vscode/launch.jason
+ Debugger for Chrome (Microsoft) debug extension to support chrome debug config


Frontend (+ Search API)
=======================

set up .env file in the root directory of the repo (without comments):
REACT_APP_SEARCH=http://localhost:5001/api                   #search api installation below
REACT_APP_API=http://192.168.99.100:32306/portal/api/v1      #<Yourk8sMaster>
REACT_APP_DESKTOP_WEB=http://192.168.99.100:32407/instances  #<Yourk8sMaster>
REACT_APP_KEYCLOAK_URL=http://192.168.10.102:8090/auth       #<KEYCLOAK_EXTERNAL_IP> (same where api-service connects to)
REACT_APP_KEYCLOAK_REALM=panosc                              #realm name
REACT_APP_KEYCLOAK_CLIENT_ID=PanoscPortal                    #<CLIENT_ID>


yarn install
yarn start

http://localhost:3001/   # or :3000 if no other services are running there (but docker service will)

kill the frontend for now


keycloak's JavaScript Adapter:
------------------------------
https://www.keycloak.org/docs/4.8/securing_apps/
set Clients > <CLIENT_ID> : AccessType=public and ValidredirectURIs=* and WebOrigins=*
then Installation : format=Keycloak OIDC JSON; and then 'Download' keycloak.json to HTML pages of Server (public/). Note that auth-server-url shall be the same as in .env above:
katica@sandor:~/work/PanoscPortal/git/frontend$ cat public/keycloak.json 
{
  "realm": "panosc",
  "auth-server-url": "http://192.168.10.102:8090/auth/",
  "ssl-required": "external",
  "resource": "PanoscPortal",
  "public-client": true,
  "confidential-port": 0
}


docker / docker-compose for branch demo_16-6
---------------------------------------------
https://docs.docker.com/engine/install/ubuntu/
https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-compose-on-ubuntu-20-04-fr

sudo curl -L "https://github.com/docker/compose/releases/download/1.26.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version

also:
sudo groupadd docker
sudo usermod -aG docker $USER
after relogin check it:
docker run hello-world

frontend branch demo_16-6
--------------------------
in a separate dir (e.g. PanoscPosrta/demo/), check out a special branch of frontend:
git clone https://github.com/panosc-portal/frontend; cd frontend
git checkout demo_16-6

docker-compose up    #note: jupyterdemo could not COPY ./notebook/. . , so take this service off of docker-compose.yml

http://localhost:5001            # Search API
http://localhost:5001/explorer   # test interface for search API
http://localhost:3000/           # old frontend demo portal


back to our current frontend:

yarn start

http://localhost:3001/


debugging: .vscode/jason
------------------------
katica@sandor:~/work/PanoscPortal/git/frontend$ cat .vscode/launch.json 
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Chrome",
      "type": "chrome",
      "request": "launch",
      "url": "http://localhost:3001",
      "webRoot": "${workspaceFolder}/src",
      "sourceMapPathOverrides": {
        "webpack:///src/*": "${webRoot}/*"
      }
    }
  ]
}

- Open directory for development 'frontend' in VSCode
- open the file package.json and hover above scipts
- click debug just above and select start
- allow the use of port 3001 in terminal view below (it will also automatically open the webpage http://localhost:3001)
- disconnet by debug control buttons in separate pane on top
- F5 (or Debug button on the left and then Start Debugging Chrome on top) which will lauch the portal in chrome.

stop portal:
- kill the portal proces in the terminal view on bottom
- then can also exit this shell


quick startup:
katica@sandor:~/work/PanoscPortal$ cat startup.sh 
========================================================
export PPFILE=`basename $(realpath $0)`
export PPDIR=`dirname $(realpath $0)`
echo Portal directory: $PPDIR

#keycloak
cd $PPDIR/keycloak-12.0.1/bin
gnome-terminal --tab -- bash -c "printf \"\033]0;keycloak\007\";./standalone.sh; exec $BASH;" &
gnome-terminal --tab -- bash -c "printf \"\033]0;socat(keycloak)\007\";socat tcp-listen:8090,reuseaddr,fork tcp:localhost:8080; exec $BASH;" &

#kubernetes
cd $PPDIR
gnome-terminal --tab -- bash -c "printf \"\033]0;minikube\007\";minikube start; exec $BASH;" &
#cd $PPDIR/git/api-service-client-cli
#bin/run user-instance:list -u http://192.168.99.100:32306/portal

#demo-docker
cd $PPDIR/demo/frontend
gnome-terminal --tab -- bash -c "printf \"\033]0;docker(demofrontend)\007\";docker-compose up; exec $BASH;" &
#wait for binding port 3000
while [ $(netstat -plnt 2> /dev/null | awk '{print $4}' | awk -F ':' '{print $2}' | grep -w 3000 | wc -l) -eq 0 ]; do sleep 1; done


#frontend
cd $PPDIR/git/frontend
gnome-terminal --tab -- bash -c "printf \"\033]0;yarn(frontend)\007\";yarn start; exec $BASH;" &

cd $PPDIR
========================================================

exit:
minikube stop
and Ctrl-C in all tabs...




-->