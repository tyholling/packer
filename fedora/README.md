# macOS QEMU Fedora Server (arm64)

1. Install dependencies
   ```
   brew tap hashicorp/tap
   brew install ansible go hashicorp/tap/packer qemu
   go install github.com/hairyhenderson/gomplate/v4/cmd/gomplate@latest
   ```
1. Set SSH key in `kickstart.cfg`
   ```
   sshkey --username=root "..."
   ```
1. Install Fedora
   - Use a unique hostname (`fedora`), it will be added to `/etc/hosts`
   ```
   ./build.sh fedora
   ```
1. Provision the system
   ```
   sudo ./provision.sh fedora
   ```
1. Connect to the machine
   ```
   ssh -l root fedora
   ```
