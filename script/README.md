# Run a Kubernetes cluster on macOS (arm64)

1. Install dependencies
   ```
   brew tap hashicorp/tap
   brew install ansible go hashicorp/tap/packer qemu watch
   go install github.com/hairyhenderson/gomplate/v4/cmd/gomplate@latest
   ```
1. Configure SSH
   - [centos](../centos/kickstart.cfg)
     ```
     sshkey --username=root "..."
     ```
   - [debian](../debian/preseed.cfg)
     ```
     echo "..." > /root/.ssh/authorized_keys
     ```
   - [fedora](../fedora/kickstart.cfg)
     ```
     sshkey --username=root "..."
     ```
   - [ubuntu](../ubuntu/user-data)
     ```
     authorized-keys: [ "..." ]
     ```
1. Build the cluster
   ```
   ./cluster.sh
   ```
   - Monitor the build:
     ```
     ./monitor.sh
     ```
1. Initialize the cluster
   - Option 1: Single-node control plane
     ```
     ssh k0
     kubeadm init --pod-network-cidr=10.244.0.0/16
     ```
   - Option 2: Multi-node control plane (high availability)
     - The provided pod manifest uses `192.168.64.64` for the cluster virtual IP

     Initialize the cluster:
     ```
     ssh k0
     ```
     ```
     curl -Os --output-dir /etc/kubernetes/manifests/ \
     https://raw.githubusercontent.com/tyholling/deploy/refs/heads/main/kube-vip.yaml
     ```
     ```
     kubeadm init --pod-network-cidr=10.244.0.0/16 \
     --control-plane-endpoint 192.168.64.64 --upload-certs
     ```
     Add nodes to the control plane:
     ```
     ssh k1
     kubeadm join --control-plane ...
     ```
     Update and deploy `kube-vip` to the control plane:
     ```
     ssh k0 sed -i s/super-admin/admin/g /etc/kubernetes/manifests/kube-vip.yaml
     scp k0:/etc/kubernetes/manifests/kube-vip.yaml k1:/etc/kubernetes/manifests/
     ```
1. Add worker nodes
   ```
   ssh a0
   kubeadm join ...
   ```
1. On macOS:
   Copy `/etc/kubernetes/admin.conf` from a control plane node:
   ```
   mkdir -p ~/.kube
   scp centos:/etc/kubernetes/admin.conf ~/.kube/config
   ```
1. Prepare to deploy services to the cluster
   ```
   brew install helm kubernetes-cli opentofu
   git clone https://github.com/tyholling/deploy.git
   cd deploy
   tofu init
   ```
1. Deplay [flannel](https://github.com/flannel-io/flannel)
   - This provides the overlay network to allow pods to communicate
   ```
   tofu apply -target helm_release.flannel
   ```
1. Deploy services to the cluster
   - https://github.com/cert-manager/cert-manager
   - https://github.com/grafana/grafana
   - https://github.com/kubernetes-sigs/metrics-server
   - https://github.com/kubernetes/ingress-nginx
   - https://github.com/mariadb/server
   - https://github.com/metallb/metallb
   - https://github.com/openebs/dynamic-localpv-provisioner
   ```
   tofu apply
   ```
1. Login to grafana with username `admin`
   - https://192.168.64.100/grafana
