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
   - Use a unique hostname (`fedora`), it will be added to `/etc/hosts`
   ```
   sudo echo
   ./provision.sh fedora
   ```
1. Connect to the machine
   ```
   ssh -l root fedora
   ```
