#!/bin/sh
########################################
### description for Ansible,td-agent ###

############ disable and stop firewalld
systemctl stop firewalld
systemctl disable firewalld

############ setting ssh-key ###########
ssh-keygen -t rsa
ssh-copy-id -i  /root/.ssh/id_rsa.pub root@192.168.33.11
ssh-copy-id -i  /root/.ssh/id_rsa.pub root@192.168.33.12

############ install ansible ##########
sudo su -
rpm -iUvh http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-5.noarch.rpm
yum -y update
yum -y install ansible
ansible --version

############ install and enable ntpd
yum -y install ntp
systemctl start ntpd
systemctl enable ntpd
systemctl stop ntpd && ntpdate server ntp.nict.jp && systemctl restart ntpd
timedatectl set-timezone Asia/Tokyo

############ file descripter replace ##
sed -i 's/root.*soft.*nofile.*//' /etc/security/limits.conf
sed -i 's/root.*hard.*nofile.*//' /etc/security/limits.conf

echo "root	soft	nofile	65535" >> /etc/security/limits.conf
echo "root	hard	nofile	65535" >> /etc/security/limits.conf
ulimit -n

sed -i 's/net.ipv4.tcp_tw_recycle.*//' /etc/sysctl.conf
sed -i 's/net.ipv4.tcp_tw_reuse.*//' /etc/sysctl.conf
sed -i 's/net.ipv4.ip_local_port_range.*//' /etc/sysctl.conf

echo "net.ipv4.tcp_tw_recycle = 1" >> /etc/sysctl.conf
echo "net.ipv4.tcp_tw_reuse = 1" >> /etc/sysctl.conf
echo "net.ipv4.ip_local_port_range = 10240 65535" >> /etc/sysctl.conf
sysctl -w


############ install fluentd ###########
cd /tmp
wget https://td-toolbelt.herokuapp.com/sh/install-redhat-td-agent2.sh
sh ./install-redhat-td-agent2.sh
  #curl -L https://td-toolbelt.herokuapp.com/sh/install-redhat-td-agent2.sh | sh
systemctl start td-agent
systemctl status td-agent
systemctl enable td-agent

############ json sample ###############
echo '{"json":"message"}' | /opt/td-agent/embedded/bin/fluent-cat debug.test
cat /var/log/td-agent/td-agent.log



