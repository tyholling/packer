# Run a Kubernetes cluster on macOS (arm64)

1. Install dependencies
   ```
   brew install ansible axel go hashicorp/tap/packer qemu watch
   go install github.com/hairyhenderson/gomplate/v4/cmd/gomplate@latest
   packer plugins install github.com/hashicorp/qemu
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
1. Prepare the control plane
   - The first node in the list will be used to initialize the cluster
   - This prepares the cluster to use the virtual IP 192.168.64.64
   ```
   ./control.sh k0 k1 k2
   ```
1. Initialize the cluster
   ```
   ssh k0
   ```
   ```
   kubeadm init --patches /opt/kubeadm/patches \
   --control-plane-endpoint 192.168.64.64 --upload-certs \
   --pod-network-cidr 172.20.0.0/16 --service-cidr 172.24.0.0/16
   ```
   Add nodes to the control plane: `[k1, k2]`
   ```
   ssh k1
   kubeadm join --control-plane ... --patches /opt/kubeadm/patches
   ```
1. Add worker nodes: `[a0, a1, a2]`
   ```
   ssh a0
   kubeadm join ...
   ```
1. On macOS:
   Copy `/etc/kubernetes/admin.conf` from a control plane node:
   ```
   mkdir -p ~/.kube
   scp k0:/etc/kubernetes/admin.conf ~/.kube/config
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
   - https://github.com/grafana/loki
   - https://github.com/kubernetes-sigs/metrics-server
   - https://github.com/kubernetes/ingress-nginx
   - https://github.com/mariadb/server
   - https://github.com/metallb/metallb
   - https://github.com/open-telemetry/opentelemetry-operator
   - https://github.com/openebs/dynamic-localpv-provisioner
   ```
   tofu apply
   ```
1. Login to grafana with username `admin`
   - http://192.168.64.90/grafana
