#!/bin/bash

packer build -force fedora.pkr.hcl

sudo ./start.sh &

ansible fedora -om wait_for_connection

ansible-playbook -l fedora ../ansible/script.yaml

ssh fedora bash -s < kubelet.sh
