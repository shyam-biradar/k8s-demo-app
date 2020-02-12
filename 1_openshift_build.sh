#!/bin/bash

## Install helm
curl -s https://storage.googleapis.com/kubernetes-helm/helm-v2.9.0-linux-amd64.tar.gz | tar xz
cp linux-amd64/helm /usr/local/bin/
oc -n kube-system create serviceaccount tiller
oc get sa --namespace kube-system | grep tiller
oc create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount=kube-system:tiller
oc get clusterrolebinding | grep tiller
helm init --service-account tiller
until (kubectl get pods -n kube-system -l app=helm,name=tiller 2>/dev/null | grep Running); do sleep 1; done

## Install CSI host path driver
git clone https://github.com/kubernetes-csi/csi-driver-host-path.git
cd /root/csi-driver-host-path/
deploy/kubernetes-1.15/deploy-hostpath.sh
cd /root/
oc get pods

sleep 10
kubectl create -f /root/hostpath-snapshot-class.yaml
kubectl get volumesnapshotclass

kubectl create -f hostpath-storage-class.yaml
kubectl get sc 

###### TrilioVault Operator Installation ########
kubectl create ns operator-system
# Authenticate to gcr.io to pull trilio-operator docker image
oc create secret generic gcr-creds --from-file=.dockerconfigjson=/root/docker-config.json --type=kubernetes.io/dockerconfigjson -n operator-system
oc get secrets -n operator-system
# Add helm repo and install triliovault-operator chart
helm repo add k8s-triliovault-dev "http://charts.k8strilio.net/trilio-dev/k8s-triliovault"
helm install --name=triliovault-operator k8s-triliovault-dev/k8s-triliovault-operator

# Wait for triliovault operator pod to get up and running
until (kubectl get pods -n operator-system -l release=triliovault-operator 2>/dev/null | grep Running); do sleep 1; done

sleep 10
## Create TrilioVaultManager CR
kubectl apply -f triliovault-manager.yaml
kubectl get pods -n operator-system
kubectl get triliovaultmanager -n operator-system
until (kubectl get pods -n operator-system -l app=k8s-triliovault-executor 2>/dev/null | grep Running); do sleep 2; done
until (kubectl get pods -n operator-system -l app=k8s-triliovault-control-plane 2>/dev/null | grep Running); do sleep 1; done
until (kubectl get pods -n operator-system -l app=k8s-triliovault-admission-webhook 2>/dev/null | grep Running); do sleep 1; done
kubectl get pods -n operator-system
kubectl get triliovaultmanager -n operator-system

# Create s3 backup target
kubectl apply -f tv-backup-target.yaml
kubectl get target
##########################################################
