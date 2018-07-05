# Walkthrough
## 1. Getting Started with Helm
### Installing Helm
* Install Helm on your laptop:
`$ brew install helm`
* If you're using an EKS cluster, you will need to configure a default storage class to allow releases to create storage volumes (see full details in the [EKS documentation](https://docs.aws.amazon.com/eks/latest/userguide/storage-classes.html)):
`$ kubectl create -f gps2-storage-class.yaml`
```bash
storageclass.storage.k8s.io "gp2" created
```
* Set the `gp2` storage class you just created as the default storage class:
`$ kubectl patch storageclass gp2 -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'`
```bash
storageclass.storage.k8s.io "gp2" patched
```
* Create a service account for Tiller:
`$ kubectl create -f rbac-config.yaml`
```bash
serviceaccount "tiller" created
clusterrolebinding.rbac.authorization.k8s.io "tiller" created
```
* Initialise Helm in your cluster:
`$ helm init --service-account tiller`
```bash
$HELM_HOME has been configured at /Users/$username/.helm.

Tiller (the Helm server-side component) has been installed into your Kubernetes Cluster.

Please note: by default, Tiller is deployed with an insecure 'allow unauthenticated users' policy.
For more information on securing your installation see: https://docs.helm.sh/using_helm/#securing-your-helm-installation
Happy Helming!
```
* View the Helm system components running in your cluster:
`$ kubectl get pods --namespace kube-system`
```bash
NAME                             READY     STATUS    RESTARTS   AGE
aws-node-7lmfq                   1/1       Running   0          2h
aws-node-g9n97                   1/1       Running   0          2h
aws-node-kvz4l                   1/1       Running   1          2h
kube-dns-7cc87d595-q2kxt         3/3       Running   0          2h
kube-proxy-5sbkt                 1/1       Running   0          2h
kube-proxy-6fclt                 1/1       Running   0          2h
kube-proxy-84lqt                 1/1       Running   0          2h
tiller-deploy-5c688d5f9b-zxqq4   1/1       Running   0          1h
```
* Check that Helm is running correctly
`$ helm ls`
* View the configured repositories:
`$ helm repo list`
```bash
NAME  	URL
stable	https://kubernetes-charts.storage.googleapis.com
local 	http://127.0.0.1:8879/charts
```
* Ensure all repos are up to date
`$ helm repo update`
```bash
Hang tight while we grab the latest from your chart repositories...
...Skip local chart repository
...Successfully got an update from the "stable" chart repository
Update Complete. ⎈ Happy Helming!⎈
```

### Taking Helm for a Test Drive
* Search for a popular chart:
`$ helm search wordpress`
```bash
NAME             	CHART VERSION	APP VERSION	DESCRIPTION
bitnami/wordpress	1.0.10       	4.9.6      	Web publishing platform for building blogs and ...
stable/wordpress 	1.0.10       	4.9.6      	Web publishing platform for building blogs and ...
```
* Install a sample chart (noting the `$repository-name/$chart-name` format):
`$ helm install stable/wordpress`
```bash
NAME:   khaki-aardwolf
LAST DEPLOYED: Thu Jun  7 10:52:17 2018
NAMESPACE: default
STATUS: DEPLOYED
...
```
* View more details about the chart:
`$ helm inspect stable/wordpress`
```bash
appVersion: 4.9.6
description: Web publishing platform for building blogs and websites.
engine: gotpl
home: http://www.wordpress.com/
icon: https://bitnami.com/assets/stacks/wordpress/img/wordpress-stack-220x234.png
keywords:
- wordpress
- cms
- blog
- http
- web
- application
- php
```
* View the releases you've deployed:
`$ helm ls`
```bash
NAME          	REVISION	UPDATED                 	STATUS  	CHART               	NAMESPACE
khaki-aardwolf	1       	Thu Jun  7 10:52:17 2018	DEPLOYED	wordpress-1.0.10	default
```
* View the status of a release you've installed:
`$ helm status khaki-aardwolf`
```bash
LAST DEPLOYED: Thu Jun  7 10:52:17 2018
NAMESPACE: default
STATUS: DEPLOYED
```
* View the services deployed as part of a release:
`$ kubectl get services -o wide -l release=khaki-aardwolf`
```bash
NAME                       TYPE           CLUSTER-IP       EXTERNAL-IP                                                               PORT(S)                      AGE       SELECTOR
khaki-aardwolf-mariadb     ClusterIP      10.100.100.174   <none>                                                                    3306/TCP                     4m        app=khaki-aardwolf-mariadb
khaki-aardwolf-wordpress   LoadBalancer   10.100.191.12    aa39655066f0411e8bb1906fcb1a6284-1809958623.us-west-2.elb.amazonaws.com   80:30684/TCP,443:31477/TCP   4m        app=khaki-aardwolf-wordpress
```

Continue to [Creating Your Own Helm Charts](Walkthrough-2-Creating-Helm-Charts.md)