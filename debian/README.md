# macOS QEMU Debian Server (arm64)

1. Install QEMU
   ```
   brew tap hashicorp/tap
   brew install hashicorp/tap/packer qemu
   ```
1. Set SSH key in `preseed.cfg`
   ```
   echo "..." > /root/.ssh/authorized_keys
   ```
1. Install Debian
   ```
   packer build -force debian.pkr.hcl
   ```
1. Start the VM
   ```
   sudo ./start.sh &
   ```
1. Find the IP
   ```
   cat /var/db/dhcpd_leases
   ```
1. Set a static IP
   ```
   ssh -l root 192.168.64.3 bash -s < network.sh 192.168.64.3
   ```
1. Connect to the VM
   ```
   ssh -l root 192.168.64.3
   ```
