########## description to Vagrantfile
  config.vbguest.auto_update=false

/etc/init.t/vboxxadd setup && reboot

yum clean all && yum -y update && yum -y upgrade
systemctl disable firewalld && systemctl stop firewalld

rpm -ivh http://ftp.jaist.ac.jp/pub/Linux/Fedora/epel/6/i386/epel-release-6-8.noarch.rpm
yum install docker-io -y
systemctl start docker && systemctl enable docker

docker pull centos:centos6
docker pull centos:centos7

for ((i=0;i<10;i++)) ; \
do \
docker run --privileged -p 20${i}22:22 -p 800$i:80 -i -t --name C$i -d centos:centos7 /sbin/init; \
docker exec C$i /bin/bash ; \
done

docker exec -it C0 /bin/bash
        yum -y install openssh openssh-server passwd
        passwd root

for ((i=0;i<10;i++)) ; do docker start C$i ; done
for ((i=0;i<10;i++)) ; do docker stop C$i ; done

docker rm $(docker ps -a -q)
