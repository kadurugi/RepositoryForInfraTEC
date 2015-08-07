########## description to Vagrantfile
  config.vbguest.auto_update=false


/etc/init.t/vboxxadd setup && reboot


yum clean all && yum -y update && yum -y upgrade
chkconfig iptables off
chkconfig ip6tables off
service iptables stop
service ip6tables stop

systemctl disable firewalld
systemctl stop firewalld


rpm -ivh http://ftp.jaist.ac.jp/pub/Linux/Fedora/epel/6/i386/epel-release-6-8.noarch.rpm
yum install docker-io -y
service docker start
chkconfig docker on

docker pull centos:centos6
docker pull centos:centos7

#for ((i=0;i<10;i++)) ; do docker run -i -t --name C$i -d centos:centos7 --privileged /sbin/init ; done

for ((i=0;i<10;i++)) ; \
do \
docker run --cap-add=SYS_ADMIN -p 20${i}22:22 -p 800$i:80 -i -t --name C$i -d centos:centos7 /sbin/init;
docker exec -it C$i /bin/bash; \
done


for ((i=0;i<10;i++)) ; do docker start C$i ; done
for ((i=0;i<10;i++)) ; do docker stop C$i ; done

docker rm $(docker ps -a -q)
