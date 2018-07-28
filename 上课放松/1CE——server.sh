#!/bin/bash
#初始化server0环境
hostnamectl set-hostname server0.example.com
firewall-cmd --set-default-zone=trusted 
firewall-cmd --permanent --add-source=172.34.0.0/24 --zone=block
firewall-cmd --permanent --zone=trusted --add-forward-port=port=5423:proto=tcp:toport=80
firewall-cmd --reload
lab smtp-nullclient setup
lab nfskrb5 setup
#修改samba布尔值
setsebool -P samba_export_all_rw=on
#开启非标准端口8909
semanage port -a -t http_port_t -p tcp 8909
#安装自动应答文件
yum -y install expect.x86_64 
#自定义用户环境
sed -i "2a alias qstat='/bin/ps -Ao pid,tt,user,fname,rsz'" /etc/bashrc
#配置聚合链路、ipv6地址
nmcli con add type team con-name team0 ifname team0 config '{"runner": {"name": "activebackup"}}'
nmcli con add type team-slave con-name team0-slave1 ifname eth1 master team0
nmcli con add type team-slave con-name team0-slave2 ifname eth2 master team0
nmcli connection modify team0 ipv4.method manual ipv4.addresses 172.16.3.20/24 connection.autoconnect yes
nmcli connection up team0
nmcli connection up team0-slave1
nmcli connection up team0-slave2
nmcli connection modify 'System eth0' ipv6.method manual ipv6.addresses 2003:ac18::305/64 connection.autoconnect yes
nmcli connection up 'System eth0'
#配置本地邮件服务
sed -i '314c relayhost = [smtp0.example.com]' /etc/postfix/main.cf
sed -i '98c myorigin = desktop0.example.com' /etc/postfix/main.cf
sed -i '116c inet_interfaces = loopback-only' /etc/postfix/main.cf
sed -i '164c mydestination =' /etc/postfix/main.cf
sed -i '264c mynetworks = 127.0.0.0/8 [::1]/128' /etc/postfix/main.cf
echo "local_transport = error:local delivery disabled" >> /etc/postfix/main.cf
systemctl restart postfix.service
systemctl enable postfix.service 
#配置samba服务
yum -y install samba
sed -i '89c workgroup = STAFF' /etc/samba/smb.conf
mkdir /common /devops
#正式考试可不用创建用户
useradd harry
echo "[common]" >> /etc/samba/smb.conf
echo "path = /common" >> /etc/samba/smb.conf
echo "hosts allow = 172.25.0.0/24" >> /etc/samba/smb.conf
useradd kenji
useradd chihiro
setfacl -m u:chihiro:rwx /devops
echo "[devops]" >> /etc/samba/smb.conf 
echo "path = devops " >> /etc/samba/smb.conf
echo " hosts allow = 172.25.0.0/24 " >> /etc/samba/smb.conf
echo " write list = chihiro" >> /etc/samba/smb.conf
#添加密码
echo -e "migwhisk\nmigwhisk"| pdbedit -a harry -t
echo -e "atenorth\natenorth"| pdbedit -a kenji -t
echo -e "atenorth\natenorth"| pdbedit -a chihiro -t
systemctl restart smb
systemctl enable smb
#配置NFS共享
mkdir -p /public /protected/project
chown ldapuser0 /protected/project/
wget -O /etc/krb5.keytab http://classroom/pub/keytabs/server0.keytab
echo "/public 172.25.0.0/24(ro)" > /etc/exports
echo "/protected 172.25.0.0/24(rw,sec=krb5p)" >> /etc/exports
systemctl restart nfs-secure-server nfs-server
systemctl enable nfs-secure-server nfs-server
#配置web服务（包含安全及动态）
#实现一个web服务器
yum -y install httpd
echo "<VirtualHost *:80>" > /etc/httpd/conf.d/server.conf
echo "ServerName server0.example.com" >> /etc/httpd/conf.d/server.conf
echo "DocumentRoot /var/www/html" >> /etc/httpd/conf.d/server.conf
echo "</VirtualHost>" >> /etc/httpd/conf.d/server.conf
wget -O /var/www/html/index.html http://classroom.example.com/pub/materials/station.html
#配置安全web服务
yum -y install mod_ssl.x86_64 
sed -i '59s/^#Doc/Doc/' /etc/httpd/conf.d/ssl.conf
sed -i '60s/^#Ser/Ser/' /etc/httpd/conf.d/ssl.conf
sed -i '122s/^#SSLCA/SSLCA/' /etc/httpd/conf.d/ssl.conf
sed -i '122s/ca-bundle/example-ca/' /etc/httpd/conf.d/ssl.conf
sed -i '100s/localhost/server0/' /etc/httpd/conf.d/ssl.conf
sed -i '107s/localhost/server0/' /etc/httpd/conf.d/ssl.conf
wget -O /etc/pki/tls/certs/server0.crt http://classroom.example.com/pub/tls/certs/server0.crt 
wget -O /etc/pki/tls/private/server0.key http://classroom/pub/tls/private/server0.key
wget -O /etc/pki/tls/certs/example-ca.crt http://classroom.example.com/pub/example-ca.crt 
#配置虚拟主机
mkdir /var/www/virtual
wget -O /var/www/virtual/index.html http://classroom.example.com/pub/materials/www.html
useradd fleyd
setfacl -m u:fleyd:rwx /var/www/virtual
echo "<VirtualHost *:80>" >> /etc/httpd/conf.d/server.conf
echo "ServerName www0.example.com" >> /etc/httpd/conf.d/server.conf
echo "DocumentRoot /var/www/virtual" >> /etc/httpd/conf.d/server.conf
echo "</VirtualHost>" >> /etc/httpd/conf.d/server.conf
#配置web内容访问
mkdir /var/www/html/private
wget -O /var/www/html/private/index.html http://classroom.example.com/pub/materials/private.html
echo "<Directory /var/www/html/private>" >> /etc/httpd/conf.d/server.conf
echo "Require ip 127.0.0.1 ::1 172.25.0.11" >> /etc/httpd/conf.d/server.conf
echo "</Directory>" >> /etc/httpd/conf.d/server.conf
#配置动态web主页
yum -y install mod_wsgi.x86_64 
mkdir /var/www/webapp
wget -O /var/www/webapp/webinfo.wsgi http://classroom.example.com/pub/materials/webinfo.wsgi
echo "Listen 8909" >> /etc/httpd/conf.d/server.conf
echo "<VirtualHost *:8909>" >> /etc/httpd/conf.d/server.conf
echo "ServerName webapp0.example.com" >> /etc/httpd/conf.d/server.conf
echo "DocumentRoot /var/www/webapp" >> /etc/httpd/conf.d/server.conf
echo "WSGIScriptAlias / /var/www/webapp/webinfo.wsgi" >> /etc/httpd/conf.d/server.conf
echo "</VirtualHost>" >> /etc/httpd/conf.d/server.conf
#起httpd服务
systemctl restart httpd
systemctl enable httpd
#创建一个脚本
echo '#!/bin/bash' > /root/foo.sh
echo 'if [ "$1" = "redhat" ] ; then' >> /root/foo.sh
echo 'echo "fedora"' >> /root/foo.sh
echo 'elif [ "$1" = "fedora" ] ; then' >> /root/foo.sh
echo 'echo "redhat"' >> /root/foo.sh
echo 'else' >> /root/foo.sh
echo 'echo "/root/foo.sh redhat|fedora" >&2' >> /root/foo.sh
echo 'fi' >> /root/foo.sh
chmod +x /root/foo.sh
#创建一个添加用户的脚本
echo '#!/bin/bash' > /root/batchusers
echo 'if [ $# -eq 0 ] ; then' >> /root/batchusers
echo 'echo "Usage: /root/batchusers <userfile>"' >> /root/batchusers
echo 'exit 1' >> /root/batchusers
echo 'fi' >> /root/batchusers
echo 'if [ ! -f $1 ] ; then' >> /root/batchusers
echo 'echo "Input file not found"' >> /root/batchusers
echo 'exit 2' >> /root/batchusers
echo 'fi' >> /root/batchusers
echo 'for name in $(cat $1)' >> /root/batchusers
echo 'do' >> /root/batchusers
echo 'useradd -s /bin/false $name' >> /root/batchusers
echo 'done' >> /root/batchusers
chmod +x /root/batchusers
#配置iscsi服务端
#expect <<EOF
#spawn "fdisk /dev/vdb"
#expoct "取帮助)" {send "n\n"}
#expoct "default p)" {send " \n"}
#expoct "默认 1)" {send " \n"}
#expoct "起始 扇区" {send " \n"}
#expoct "+扇区" {send "+3G\n"}
#expoct "取帮助)" {send "w\n"}
#expoct "#" {send"exit\n"} 
#EOF
#添加分区
parted /dev/vdb mklabel msdos
parted /dev/vdb mkpart primary 1 3100M
yum -y install targetcli
#expect <<EOF
#spawn "targetcli"
#expoct "/> " {send "backstores/block create iscsi_store /dev/vdb1\n"}
#expoct "/> " {send "/iscsi create iqn.2016-02.com.example:server0\n"}
#expoct "/> " {send " /iscsi/iqn.2016-02.com.example:server0/tpg1/acls create iqn.2016-02.com.example:desktop0\n"}
#expoct "/> " {send " /iscsi/iqn.2016-02.com.example:server0/tpg1/luns create /backstores/block/iscsi_store\n"}
#expoct "/> " {send "/iscsi/iqn.2016-02.com.example:server0/tpg1/portals create 172.25.0.11\n"}
#expoct "/>" {send"exit\n"} 
#expoct "#" {send"exit\n"} 
#EOF
targetcli backstores/block create iscsi_store /dev/vdb1
targetcli /iscsi create iqn.2016-02.com.example:server0
targetcli /iscsi/iqn.2016-02.com.example:server0/tpg1/acls create iqn.2016-02.com.example:desktop0
targetcli /iscsi/iqn.2016-02.com.example:server0/tpg1/luns create /backstores/block/iscsi_store
targetcli /iscsi/iqn.2016-02.com.example:server0/tpg1/portals create 172.25.0.11
systemctl restart target
systemctl enable target
#配置一个数据库




















