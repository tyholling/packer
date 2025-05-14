# macOS QEMU Fedora Server (arm64)

1. Install QEMU
   ```
   brew tap hashicorp/tap
   brew install hashicorp/tap/packer qemu
   ```
1. Set SSH key in `kickstart.cfg`
   ```
   sshkey --username=root "..."
   ```
1. Install Fedora
   ```
   packer build -force fedora.pkr.hcl
   ```
1. Start the VM
   ```
   sudo ./start.sh &
   ```
1. Find the IP
   ```
   cat /var/db/dhcpd_leases
   ```
1. Connect to the VM
   ```
   ssh -l root <ip address>
   ```
