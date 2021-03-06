#!/bin/bash -e

if [ ! -f /usr/bin/chef-client ]; then
  sudo apt-get update 
  sudo apt-get install -y ruby ruby1.8-dev build-essential wget libruby-extras libruby1.8-extras curl
  cd /tmp 
  sudo wget http://rubyforge.org/frs/download.php/69365/rubygems-1.3.6.tgz
  sudo tar xvf rubygems-1.3.6.tgz
  cd rubygems-1.3.6
  sudo ruby setup.rb
  echo "Installing Chef and Ohai"
  sudo gem install ohai chef --no-rdoc --no-ri
fi

echo "Downloading openstack cookbooks..."

cd ~
wget -O openstack-cookbooks.tar.gz  http://github.com/aghareza/openstack-cookbooks/tarball/master
tar zxvf openstack-cookbooks.tar.gz
mv aghareza-openstack-cookbooks-* openstack-cookbooks
cd openstack-cookbooks

echo -n "Enter your username: "
read username
echo -n "Enter your group: "
read groupname
echo -n "Enter your launchpad login: "
read launchpad_login
echo -n "Enter your bzr email address: "
read bzr_email

cp swift-template.json swift.json
perl -pi -e "s/USERNAME/$username/g" swift.json
perl -pi -e "s/GROUP/$groupname/g" swift.json
perl -pi -e "s/LAUNCHPAD_LOGIN/$launchpad_login/g" swift.json
perl -pi -e "s/BZR_EMAIL/$bzr_email/g" swift.json

sudo chef-solo -c chef-solo.rb -j swift.json

export PYTHONPATH=~/swift
export PATH_TO_TEST_XFS=/mnt/sdb1/test
export SWIFT_TEST_CONFIG_FILE=/etc/swift/func_test.conf
export PATH=${PATH}:~/bin

~/bin/remakerings
~/bin/startmain
echo "Waiting for swift to start..."
sleep 5
/usr/local/bin/swift-auth-create-account test tester testing

echo "***"
echo
echo "Swift installed - next steps:"
echo "1. source ~/.bashrc"
echo "2. cd ~/swift; ./.functests"
echo "3. Profit!"
echo 
echo "Enjoy!"
