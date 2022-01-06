#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

cd terraform
terraform apply --auto-approve
cd -

cd ansible
ansible-playbook -i inventory.txt os-setup.yaml --ssh-extra-args="-o IdentitiesOnly=yes"

ansible-playbook -i inventory.txt cri-containerd.yaml --ssh-extra-args="-o IdentitiesOnly=yes" -l master,worker00
ansible-playbook -i inventory.txt cri-docker.yaml --ssh-extra-args="-o IdentitiesOnly=yes" -l worker01
ansible-playbook -i inventory.txt cri-crio.yaml --ssh-extra-args="-o IdentitiesOnly=yes" -l worker02

ansible-playbook -i inventory.txt kubernetes.yaml --ssh-extra-args="-o IdentitiesOnly=yes"
cd -

kubectl config rename-context kubernetes-admin@kubernetes kubeadm
kubectl config use-context kubeadm
