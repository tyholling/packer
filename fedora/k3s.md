# k3s on fedora

1. podman

		dnf install podman
		mkdir /opt/registry
		podman run -d -p 5000:5000 -v /opt/registry:/var/lib/registry:z --name registry registry
		podman ps
		podman generate systemd --new --name registry -f
		mv container-registry.service /etc/systemd/system/
		restorecon -v /etc/systemd/system/container-registry.service
		podman rm -f registry
		systemctl enable container-registry
		systemctl start container-registry
		podman ps

		# vim /etc/containers/registries.conf.d/localhost.conf
		[[registry]]
		location = "localhost:5000"
		insecure = true

1. k3s.io

		curl -sfL https://get.k3s.io | sh -
		kubectl version
		kubectl completion bash > /etc/bash_completion.d/kubectl.sh
		cp /etc/rancher/k3s/k3s.yaml .kube/config
		systemctl stop k3s

		# vim /etc/rancher/k3s/registries.yaml
		mirrors:
		  localhost:
		    endpoint:
		    - "http://localhost:5000"

		# vim /etc/systemd/system/k3s.service
		server --disable traefik \

		systemctl daemon-reload
		systemctl start k3s
		cd /tmp
		# https://github.com/helm/helm/releases
		wget -4 https://get.helm.sh/helm-v3.10.2-linux-arm64.tar.gz
		tar xf helm-v3.10.2-linux-arm64.tar.gz
		mv linux-arm64/helm /usr/local/bin/
		helm version
		cd
		helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
		kubectl create ns ingress-nginx
		helm install ingress-nginx ingress-nginx/ingress-nginx -n ingress-nginx
		# wait for the deployment to finish
		kubectl get deploy -n ingress-nginx -w
