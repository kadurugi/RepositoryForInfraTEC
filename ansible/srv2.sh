#!/bin/sh
########################################
### description for td-agent,Elasticsearch and kibana ###

############ disable and stop firewalld
systemctl stop firewalld
systemctl disable firewalld

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

############ yum install glibc (libcurl-devel) openjdk#
yum -y install glibc libcurl-debel
yum -y install java-1.8.0-openjdk

############ install elasticsearch
rpm -ivh https://download.elastic.co/elasticsearch/elasticsearch/elasticsearch-1.7.0.noarch.rpm
systemctl start elasticsearch
systemctl enable elasticsearch
systemctl status elasticsearch
curl -X GET http://localhost:9200/

 /opt/td-agent/embedded/bin/gem install fluent-plugin-elasticsearch

############ install kibana
cd /tmp/ && wget https://download.elastic.co/kibana/kibana/kibana-4.1.1-linux-x64.tar.gz
tar -zxvf kibana-4.1.1-linux-x64.tar.gz
mkdir -p /var/www/html
mv kibana-4.1.1-linux-x64 /var/www/html/
chmod 777 /var/www/html/*
/var/www/html/kibana-4.1.1-linux-x64/bin/kibana

########### clean Elasticsearch indexes
curl -XDELETE 'http://localhost:9200/*'
curl -XDELETE http://192.168.33.12:9200/_template/*

########### Get mapping json
# http://192.168.33.12:9200/fluentd/_mapping

########### reconst json file
# http://www.ctrlshift.net/jsonprettyprinter/

########### disable splitted mapping
########### mytemplate.json に
###########  ,"index":"not_analyzed"
########### を追加 (sed 使うとよい)

########### cat mytemplate.json |  sed 's/"type": "string"'/'"type": "string","index": "not_analyzed"'/ > mytemplate_seded.json

########### jsonファイルを /etc/elasticsearch/templates/ (無ければ作成)　に置いて
########### systemctl restart elasticsearch

#PUT mytemplate via curl
#curl -XPUT 192.168.33.12:9200/_template/mytemplate -d "`cat /tmp/mytemplate_seded_restricted.json`"




#Dynamic Template
#curl -XPUT 192.168.33.12:9200/_template/template_all -d "`cat /tmp/template_all.json`"
#template_all.json
{
    "template": "*",
    "mappings": {
        "_default_": {
            "_source": { "compress": true },
            "dynamic_templates": [
                {
                    "string_template" : {
                        "match" : "*",
                        "mapping": {
                            "type": "multi_field",
                            "fields": {
                                "{name}": {
                                    "type": "string",
                                    "index" : "not_analyzed"
                                },
                                "full": {
                                    "type": "string",
                                    "index" : "not_analyzed"
                                }
                            }
                        },
                        "match_mapping_type" : "string"
                    }
                }
            ],
            "properties" : {
                "@timestamp" : { "type" : "date", "index" : "not_analyzed" }
            }
        }
    }
}

