# Walkthrough
## 4. Cleaning Up
* [ ] Remove all installed releases:
`$ helm delete --purge $(helm ls --short)`
```bash
release "ironic-lionfish" deleted
release "khaki-aardwolff" deleted
release "mewing-seal" deleted
release "wanton-zorse" deleted
```
* [ ] Remove your private repos:
`$ helm repo remove my-new-repo`
```bash
"my-new-repo" has been removed from your repositories
```
* [ ] Remove `helm-s3` plugin:
`$ helm plugin remove s3`
```bash
Removed plugin: s3
```
* [ ] Uninstall Tiller from your cluster:
`$ kubectl delete deployment/tiller-deploy service/tiller-deploy --namespace kube-system`
```bash
deployment.extensions "tiller-deploy" deleted
service "tiller-deploy" deleted
```
* [ ] Remove service account configuration for Tiller:
`$ kubectl delete -f rbac-config.yaml`
```bash
serviceaccount "tiller" deleted
clusterrolebinding.rbac.authorization.k8s.io "tiller" deleted
```
* [ ] Remove default storage class:
`$ kubectl delete -f gp2-storage-class.yaml`
```bash
storageclass.storage.k8s.io "gp2" deleted
```
* [ ] Delete your S3 bucket and EKS/K8s cluster