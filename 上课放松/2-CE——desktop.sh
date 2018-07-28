#!/bin/bash
#初始化desktop0环境
hostnamectl set-hostname desktop0.example.com
firewall-cmd --set-default-zone=trusted
firewall-cmd --permanent --add-source=172.34.0.0/24 --zone=block
firewall-cmd --reload
lab smtp-nullclient setup
lab nfskrb5 setup
#安装自动应答文件
yum -y install expect.x86_64
#自定义用户环境
sed -i "2a alias qstat='/bin/ps -Ao pid,tt,user,fname,rsz'" /etc/bashrc
#配置聚合链路、ipv6地址
nmcli con add type team con-name team0 ifname team0 config '{"runner": {"name": "activebackup"}}'
nmcli con add type team-slave con-name team0-slave1 ifname eth1 master team0
nmcli con add type team-slave con-name team0-slave2 ifname eth2 master team0
nmcli connection modify team0 ipv4.method manual ipv4.addresses 172.16.3.25/24 connection.autoconnect yes
nmcli connection up team0
nmcli connection up team0-slave1
nmcli connection up team0-slave2
nmcli connection modify 'System eth0' ipv6.method manual ipv6.addresses 2003:ac18::306/64 connection.autoconnect yes
nmcli connection up 'System eth0'
#配置多用户samba挂载
yum -y install cifs-utils.x86_64
mkdir /mnt/dev
echo "//server0.example.com/devops /mnt/dev cifs username=kenji,password=atenorth,multiuser,sec=ntlmssp,_netdev 0 0" >> /etc/fstab 
mount -a
#挂载NFS共享
wget http://classroom.example.com/pub/keytabs/desktop0.keytab  -O /etc/krb5.keytab
systemctl restart nfs-secure
systemctl enable nfs-secure
mkdir /mnt/nfsmount /mnt/nfssecure
echo "server0.example.com:/public /mnt/nfsmount nfs _netdev 0 0" >> /etc/fstab 
echo "server0.example.com:/protected /mnt/nfssecure nfs sec=krb5p,_netdev 0 0" >> /etc/fstab
mount -a
#配置ISCSI客户端
mkdir /mnt/data
yum -y install iscsi-initiator-utils.i686
echo "InitiatorName=iqn.2016-02.com.example:desktop0" > /etc/iscsi/initiatorname.iscsi
systemctl daemon-reload
systemctl restart iscsi iscsid
systemctl enable iscsi iscsid
iscsiadm --mode discoverydb --type sendtargets --portal 172.25.0.11 --discover
sed -i '50s/manual/automatic/' /var/lib/iscsi/nodes/iqn.2016-02.com.example\:server0/172.25.0.11\,3260\,1/default
systemctl restart iscsi iscsid
sleep 5
#parted /dev/sda mklabel msdos
parted /dev/sda mkpart primary 1 2100M
mkfs.ext4 /dev/sda1
blkid /dev/sda1 | awk -F\" '{print "UUID="$2,"/mnt/data ext4 _netdev 0 0"}' >> /etc/fstab 
mount -a
#修改退出别名
sed -i "3a alias reboot='sync ; reboot -f'" /etc/bashrc
#添加自动挂载脚本
chmod +x /etc/rc.local
echo "for i in {1..30}" >> /etc/rc.local
echo "do" >> /etc/rc.local
echo "mount -a" >> /etc/rc.local 
echo "sleep 5" >> /etc/rc.local
echo "done"  >> /etc/rc.local


















