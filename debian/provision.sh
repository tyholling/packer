#!/bin/bash

packer build -force debian.pkr.hcl

sudo ./start.sh &

ansible debian -om wait_for_connection

ansible-playbook -l debian ../ansible/script.yaml

ssh debian bash -s < kubelet.sh
