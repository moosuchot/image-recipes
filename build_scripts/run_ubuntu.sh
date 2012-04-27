#!/bin/sh 
export OS=Ubuntu
export OS_VERSION=11
export OS_ARCH=x86_64
export IMAGE_VERSION=1.0
export TYPE=base
export IMAGE_SIZE=5
export MAC_ADDRESS=0a:0a:86:9e:49:60
export NAME=ubuntu

sudo su - root -c "virt-install --nographics --noautoconsole --accelerate --hvm --name $NAME --ram=2000 --disk $OS-$OS_VERSION-$OS_ARCH-$TYPE-$IMAGE_VERSION.img,bus=scsi,size=5 --location=http://archive.ubuntu.com/ubuntu/dists/oneiric/main/installer-amd64/ -x \"auto=true priority=critical url=http://$NODE_IP/ubuntu11_stratus.preseed\" --network bridge=br0 --mac=$MAC_ADDRESS  --noreboot"



while [ -n "`sudo su - root -c 'virsh list | grep $NAME'|| true`" ]; do 
  sleep 120 
done

sudo su - root -c "yum install -y --nogpgcheck stratuslab-cli-user stratuslab-cli-sysadmin"

sudo su - root -c "stratus-build-metadata --author=\"hudson builder\" --os=$OS --os-version=$OS_VERSION --os-arch=$OS_ARCH --image-version=$IMAGE_VERSION --comment=\"$OS  $OS_VERSION $TYPE image automatically created by hudson. Configured only with a root user. The firewall in the image is disabled, IPv6 is enabled, and SELinux disabled. Uses the standard StratusLab contextualization mechanisms. A swap volume is expected to be provided on /dev/sdb. \" --compression=gz $OS-$OS_VERSION-$OS_ARCH-$TYPE-$IMAGE_VERSION.img"

sudo su - root -c "stratus-generate-p12 --common-name=\"hudson builder\" --email=\"hudson.builder@stratuslab.eu\" -o test.p12"

sudo su - root -c "stratus-upload-image -f --compress=gz --with-marketplace -U build -P build2934 --p12-cert=test.p12 --p12-password=XYZXYZ $OS-$OS_VERSION-$OS_ARCH-$TYPE-$IMAGE_VERSION.xml"