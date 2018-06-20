# Demo

## Getting Started with Helm
### Taking Helm for a Test Drive
* Search for a popular chart:
`$ helm search wordpress`
```bash
NAME             	CHART VERSION	APP VERSION	DESCRIPTION
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

Continue to [Creating Your Own Helm Charts](DEMO-Creating-Helm-Charts.md)

---

## Creating Your Own Helm Charts
### Chart Structure
```bash
chart-name/
  Chart.yaml            # A YAML file containing information about the chart
  LICENSE               # OPTIONAL: A plain text file containing the license for the chart
  README.md             # OPTIONAL: A human-readable README file
  requirements.yaml     # OPTIONAL: A YAML file listing dependencies for the chart
  values.yaml           # The default configuration values for this chart
  charts/               # A directory containing any charts upon which this chart depends.
  templates/            # A directory of templates that, when combined with values,
                        # will generate valid Kubernetes manifest files.
  templates/NOTES.txt   # OPTIONAL: A plain text file containing short usage notes 
```
Full details in the [Kubernetes documentation](https://github.com/kubernetes/helm/blob/master/docs/charts.md).

### Creating a simple chart: hello-world v1
* Create a chart scaffold:
`$ helm create hello-world`
* Update [Chart.yaml](hello-world/v1/Chart.yaml) to define the name and version of our chart
* Update [templates/deployment.yaml](hello-world/v1/templates/deployment.yaml) to define the container to deploy, ports to use, and labels to apply
* Update [templates/service.yaml](hello-world/v1/templates/service.yaml) to use the `LoadBalancer` type to create an external load balancer for us
* Change into the relevant directory:
`$ cd hello-world/`
* Install the chart:
`$ helm install .`
```bash
NAME:   wanton-zorse
LAST DEPLOYED: Fri Jun  8 15:18:54 2018
NAMESPACE: default
STATUS: DEPLOYED

RESOURCES:
==> v1/Service
NAME         TYPE          CLUSTER-IP      EXTERNAL-IP  PORT(S)       AGE
hello-world  LoadBalancer  10.100.213.245  <pending>    80:31076/TCP  1s

==> v1beta1/Deployment
NAME         DESIRED  CURRENT  UP-TO-DATE  AVAILABLE  AGE
hello-world  1        1        1           0          1s

==> v1/Pod(related)
NAME                          READY  STATUS             RESTARTS  AGE
hello-world-5f79cd56f9-46cmz  0/1    ContainerCreating  0         1s
```
* But there are issues here: the `Service` and `Deployment` both have the same name (`hello-world`). All resources in Kubernetes must have unique names, so if we try to deploy another version of the chart we will run into issues:
`$ helm install .`
```bash
Error: release ironic-lionfish failed: services "hello-world" already exists
```
* If we check the list of releases in our cluster, we will see one is successfully `DEPLOYED`, but the second one we tried to install has status `FAILED`, because we were unable to create another instance of the `Service` and `Deployment` with a name that is already in use
`$ helm ls`
```bash
NAME           	REVISION	UPDATED                 	STATUS  	CHART            	NAMESPACE
ironic-lionfish	1       	Fri Jun  8 15:21:35 2018	FAILED  	hello-world-1.0.1	default
wanton-zorse   	1       	Fri Jun  8 15:18:54 2018	DEPLOYED	hello-world-1.0.1	default
```
* We need to fix this so that we can install multiple releases of our chart within a single cluster

### Improving our chart: hello-world v2
* Chart templates are written in the Go template language, and this means we can dynamically update values in our charts during installation
* Default values for a chart are supplied in a `values.yaml` file
* Users can override the default values in `values.yaml` at the time of creating a release. There are two mechanisms to do this:
  * Using the `--values $yaml_file_path` option
  * Using the `--set key1=value1,key2=value2` option
* Values provided with `--set` override values provided with `--value`, which overrides default values
* In addition to user-supplied values, there are a number of predefined values:
  * `.Release` refers to the resulting release values, e.g. `.Release.Name`, `.Release.Time`
  * `.Chart` refers to `Chart.yaml` configuration
  * `.Files` refers to the files in the chart directory
* Helm also has the concept of [Named Templates](https://github.com/kubernetes/helm/blob/master/docs/chart_template_guide/named_templates.md), or Partials. These allow you to create embedded templates within templates. They are useful for repeated template sections, e.g.
```go
{{- define "hello-world.release_labels" }}
app: {{ printf "%s-%s" .Release.Name .Chart.Name | trunc 63 }}
version: {{ .Chart.Version }}
release: {{ .Release.Name }}
{{- end }}
{{- define "hello-world.full_name" -}}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 -}}
{{- end -}}

apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: {{ template "hello-world.full_name" . }}
  labels:
    {{- include "hello-world.release_labels" . | indent 4 }}
```
* These partials are stored in `templates/_helpers.tpl`
* Our v2 hello-world app should therefore make use of partials to provide a unique `Deployment` and `Service` name based on the release name:
`$ head -6 templates/deployment.yaml templates/service.yaml`
```bash
==> templates/deployment.yaml <==
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: {{ template "fullname" . }}
  labels:
    {{ template "hello-world.release_labels" . }}

==> templates/service.yaml <==
apiVersion: v1
kind: Service
metadata:
  name: {{ template "fullname" . }}
  labels:
    {{ template "hello-world.release_labels" . }}
```
* If we now install v2 of our hello-world app, things look much better and our `Deployment` and `Service` have unique names generated from the `Release` name:
`$ helm install .`
```
NAME:   mewing-seal
LAST DEPLOYED: Fri Jun  8 16:06:00 2018
NAMESPACE: default
STATUS: DEPLOYED

RESOURCES:
==> v1/Service
NAME                     TYPE          CLUSTER-IP      EXTERNAL-IP  PORT(S)       AGE
mewing-seal-hello-world  LoadBalancer  10.100.156.192  <pending>    80:30195/TCP  1s

==> v1beta1/Deployment
NAME                     DESIRED  CURRENT  UP-TO-DATE  AVAILABLE  AGE
mewing-seal-hello-world  1        1        1           0          1s

==> v1/Pod(related)
NAME                                      READY  STATUS             RESTARTS  AGE
mewing-seal-hello-world-6579984d75-qtvz4  0/1    ContainerCreating  0         1s
```

### Can we do better? hello-world v3
* So now we have an application with unique resource names, what else do we need to do in order to ready it for production? We currently have a single pod running behind a load balancer, which presents a few issues with availability and reliability:
  * If the pod fails, the service will be unavailable until a replacement is deployed
  * If we upgrade the application, the pod will be terminated while a new pod is being deployed, again creating a service outage
* To address this issue, we will increase the number of `replicas` in our `Deployment` - we will increase this to 3 to match the number of Availability Zones
* We will also create a rolling update Deployment strategy to prevent unexpected outages during application updates
`$ cat templates/deployment.yaml`
```bash
...
spec:
  replicas: 3
...
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 50%     # how many pods we can add at a time
      maxUnavailable: 0 # maxUnavailable define how many pods can be
                        # unavailable during the rolling update
```
* With our rolling update Deployment strategy, new pods will be started before old pods are terminated

### Checksum annotations: hello-world v4
* We are currently using separate files for `Deployment` and `Service` defintions. This isn't strictly required by Helm, but it is useful for various reasons, such as:
  * Changing one character in a manifest would cause all resources to be redeployed, which could severely impact availability
* But sometimes this behaviour is counter-productive. Suppose we have a `ConfigMap` that we use to control the behaviour of our deployments (e.g. passing in environment variables or other parameters). If we update the `ConfigMap` definition and `upgrade` a `Release`, we will notice that the `Deployment` does not get updated - because the `deployment.yaml` spec file has not changed!
* How can we fix this? Add a checksum annocation in the `Deployment`:
`$ cat templates/deployment.yaml`
```go
...
spec:
  replicas: 3
  template:
    metadata:
      labels:
        app: {{ template "fullname" . }}
      annotations:
        checksum/config-map: {{ include (print $.Template.BasePath "/config-map.yaml") . | sha256sum }}
```
* If we now update the `ConfigMap` (i.e. update the `MAGIC_NUMBER` parameter), and `upgrade` a release, both the `ConfigMap` and `Deployment` will be updated within the cluster, and this will force pods to be replaced according to our rolling update Deployment strategy.

Continue to [Creating and Using Private Repos](DEMO-Private-Repos.md)

---

## Creating and Using Private Repos
### Hosting a Private Repository on S3
We will be making use of a Helm plugin that allows us to use AWS S3 as a [private] chart repository, available here: https://github.com/hypnoglow/helm-s3
* We assume you have an existing, empty S3 bucket to use for this purpose. If not, create one now.
* Install the plugin:
`$ helm plugin install https://github.com/hypnoglow/helm-s3.git`
```bash
Downloading and installing helm-s3 v0.7.0 ...
Installed plugin: s3
```
* Create a new repository:
`$ helm s3 init s3://my-bucket/charts`
```bash
Initialized empty repository at s3://my-bucket/charts
```
* Add the repository to your cluster:
`$ helm repo add my-new-repo s3://my-bucket/charts`
```bash
"my-new-repo" has been added to your repositories
```
* Check the repo has been added:
`$ helm repo list`
```bash
NAME            	URL
stable          	https://kubernetes-charts.storage.googleapis.com
local           	http://127.0.0.1:8879/charts
my-new-repo     	s3://my-bucket/charts
```
### Authoring a Chart
* When starting work on a new chart, create a chart scaffold:
`$ helm create $chart-name`
```bash
Creating $chart-name
```
* Update the files with your chart details, then check the chart for errors:
`$ helm lint $chart-name`
```bash
==> Linting $chart-name
[INFO] Chart.yaml: icon is recommended

1 chart(s) linted, no failures
```
* Package the chart into a chart archive:
`$ helm package $chart-name`
```bash
Successfully packaged chart and saved it to: ./$chart-name-0.1.0.tgz
```
* Push the chart archive into your private repository:
`$ helm s3 push ./$chart-name-0.1.0.tgz my-new-repo`
* Verify the chart has been uploaded to S3 successfully:
`$ aws s3 ls s3://my-bucket/charts/`
```bash
2018-06-14 15:37:50        462 $chart-name-0.1.0.tgz
```
---
## Cleaning Up
* Remove all installed releases:
`$ helm delete --purge $(helm ls --short)`
```bash
release "ironic-lionfish" deleted
release "khaki-aardwolff" deleted
release "mewing-seal" deleted
release "wanton-zorse" deleted
```
* Remove your private repos:
`$ helm repo remove my-new-repo`
```bash
"my-new-repo" has been removed from your repositories
```
* Uninstall Tiller from your cluster:
`$ kubectl delete deplodeployment/tiller-deploy service/tiller-deploy --namespace kube-system`
```bash
deployment.extensions "tiller-deploy" deleted
service "tiller-deploy" deleted
```
* Delete your S3 bucket and EKS/K8s cluster