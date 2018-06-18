# Walkthrough
## 3. Creating and Using Private Repos
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

Continue to [Cleaning Up](Walkthrough-4-Clean-Up.md)