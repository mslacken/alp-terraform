#!/bin/bash
mkdir -p combustion/combustion
cat > combustion/combustion/script <<EOFOUT
#!/bin/sh
# combustion: network
echo 'root:\$6\$NBMrhuDZnXbQ/.ZZ\$WDfdw9He9ug3536PfYRj0ziC0EhZiqnc63armMm4sySD6CCWILvfzs6.mbja7vm5DQ13XIym4QbIBQci2nxCb1' | chpasswd -e
# Add a public ssh key and enable sshd
mkdir -pm700 /root/.ssh/
cat > /root/.ssh/authorized_keys <<EOF
SSHKEY
EOF
systemctl enable sshd.service
EOFOUT
virt-make-fs --label=ignition -F raw --partition=gpt combustion/ ignition.raw
