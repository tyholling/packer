#!/bin/bash

packer build -force centos.pkr.hcl

sudo ./start.sh &

ansible centos -om wait_for_connection

ansible-playbook -l centos ../ansible/script.yaml

ssh centos bash -s < kubelet.sh
