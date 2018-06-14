{{/* vim: set filetype=mustache: */}}

{{/* Expand the name of the chart. */}}
{{- define "name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* Define labels for resources created by the release. */}}
{{- define "hello-world.release_labels" -}}
app: {{ template "fullname" . }}
chart: "{{ .Chart.Name }}-{{ .Chart.Version }}"
heritage: "{{ .Release.Service }}"
release: "{{ .Release.Name }}"
version: "{{ .Chart.Version }}"
{{- end }}

{{/* Create a default fully qualified app name. We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
