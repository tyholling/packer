#!/bin/bash

packer build -force ubuntu.pkr.hcl

sudo ./start.sh &

ansible ubuntu -om wait_for_connection

ansible-playbook -l ubuntu ../ansible/script.yaml

ssh ubuntu bash -s < kubelet.sh
