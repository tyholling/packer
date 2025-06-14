# macOS QEMU CentOS Stream Server (arm64)

1. Install QEMU
   ```
   brew tap hashicorp/tap
   brew install hashicorp/tap/packer qemu
   ```
1. Set SSH key in `kickstart.cfg`
   ```
   sshkey --username=root "..."
   ```
1. Install CentOS Stream
   - Use a unique hostname (`centos`), it will be added to `/etc/hosts`
   ```
   sudo echo
   ./provision.sh centos
   ```
1. Connect to the machine
   ```
   ssh -l root centos
   ```
