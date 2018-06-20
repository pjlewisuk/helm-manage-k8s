# Demo
## 1. Preparation

* [ ] Ensure cluster is running
* [ ] Ensure Helm is installed
```bash
$ brew install kuberenetes-helm
$ kubectl create -f gp2-storage-class.yaml
$ kubectl create -f rbac-config.yaml
```
* Initialise helm in the cluster:
`$ helm init --service-account tiller`
* [ ] Ensure no releases are installed
`$ helm ls`
* [ ] Ensure helm-s3 plugin is installed
`$ helm plugin install https://github.com/hypnoglow/helm-s3.git`
* [ ] Ensure private repository is configured
`$ helm repo add pjlewis-aws-helm s3://pjlewis-aws-helm/charts`
* [ ] Ensure v1.0.4 of chart is not present in private repository
`helm search -l hello-world`
* [ ] Ensure scaffold chart directory does not exist
* [ ] Ensure hello-world v1.0.4 chart directory is named 'v4'
* [ ] Switch to `~/Repositories/helm-manage-k8s` directory