#!/bin/bash -e

export DEBIAN_FRONTEND=noninteractive

## workaround for https://askubuntu.com/a/838291
chmod 0777 /tmp

echo "================ Installing locales ======================="
apt-get clean && apt-get update
apt-get install -q locales=2.23*

dpkg-divert --local --rename --add /sbin/initctl
locale-gen en_US en_US.UTF-8
dpkg-reconfigure locales

echo "HOME=$HOME"
cd /u16

echo "================= Updating package lists ==================="
apt-get update

echo "================= Adding some global settings ==================="
mv gbl_env.sh /etc/profile.d/
mkdir -p "$HOME/.ssh/"
mv config "$HOME/.ssh/"
mv 90forceyes /etc/apt/apt.conf.d/
touch "$HOME/.ssh/known_hosts"
mkdir -p /etc/drydock

echo "================= Installing basic packages ==================="
apt-get install -q -y \
  build-essential=12.1* \
  curl=7.47* \
  gcc=4:5.3* \
  gettext=0.19* \
  htop=2.0* \
  libxml2-dev=2.9* \
  libxslt1-dev=1.1* \
  make=4.1* \
  nano=2.5* \
  openssh-client=1:7* \
  openssl=1.0* \
  software-properties-common=0.96* \
  sudo=1.8*  \
  texinfo=6.1* \
  zip=3.0* \
  unzip=6.0* \
  wget=1.17* \
  rsync=3.1* \
  psmisc=22.21* \
  netcat-openbsd=1.105* \
  vim=2:7.4* \
  groff=1.22.*

echo "================= Installing Python packages ==================="
apt-get install -q -y \
  python-pip=8.1* \
  python-software-properties=0.96* \
  python-dev=2.7*

pip install -q virtualenv==15.2.0
pip install -q pyOpenSSL==17.5.0

echo "================= Installing Git ==================="
add-apt-repository ppa:git-core/ppa -y
apt-get update
apt-get install -q -y git=1:2.*

echo "================= Adding JQ 1.5.1 ==================="
apt-get install -q jq=1.5*

echo "================= Adding awscli 1.11.164 ============"
sudo pip install -q 'awscli==1.11.164'

echo "================= Installing Node 7.x ==================="
. /u16/node/install.sh

echo "================= Adding apache libcloud 2.3.0 ============"
sudo pip install 'apache-libcloud==2.3.0'

echo "================= Adding openstack client 3.15.0 ============"
sudo pip install 'python-openstackclient==3.15.0'
sudo pip install 'shade==1.27.1'

echo "================= Adding gcloud ============"
CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)"
echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" | tee /etc/apt/sources.list.d/google-cloud-sdk.list
curl -sS https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
sudo apt-get update && sudo apt-get install -q google-cloud-sdk=173.0.0-0

KUBECTL_VERSION=1.8.0
echo "================= Adding kubectl $KUBECTL_VERSION ==================="
curl -sSLO https://storage.googleapis.com/kubernetes-release/release/v"$KUBECTL_VERSION"/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl

AZURE_CLI_VERSION=2.0.25*
echo "================ Adding azure-cli $AZURE_CLI_VERSION =============="
echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ wheezy main" | \
  sudo tee /etc/apt/sources.list.d/azure-cli.list
curl -L https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
sudo apt-get install -q apt-transport-https=1.2*
sudo apt-get update && sudo apt-get install -q -y azure-cli=$AZURE_CLI_VERSION

echo "================= Intalling Shippable CLIs ================="

git clone https://github.com/Shippable/node.git nodeRepo
./nodeRepo/shipctl/x86_64/Ubuntu_16.04/install.sh
rm -rf nodeRepo

echo "Installed Shippable CLIs successfully"
echo "-------------------------------------"

rm -rf /usr/local/lib/python2.7/dist-packages/requests*
#pip install --upgrade pip

echo "================== Installing python requirements ====="
pip install -r /u16/requirements.txt

echo "================= Cleaning package lists ==================="
hash -r
apt-get clean
apt-get autoclean
apt-get autoremove
