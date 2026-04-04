{{/*
Expand the name of the chart.
*/}}
{{- define "camp.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "camp.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "camp.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "camp.labels" -}}
helm.sh/chart: {{ include "camp.chart" . }}
{{ include "camp.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- with .Values.commonLabels }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "camp.selectorLabels" -}}
app.kubernetes.io/name: {{ include "camp.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "camp.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "camp.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create image name
*/}}
{{- define "camp.image" -}}
{{- $registry := .Values.global.imageRegistry | default .Values.image.registry }}
{{- $repository := .Values.image.repository }}
{{- $tag := .Values.image.tag | default .Chart.AppVersion }}
{{- if .Values.global.imageRegistry }}
{{- printf "%s/%s:%s" $registry $repository $tag }}
{{- else }}
{{- printf "%s/%s:%s" $registry $repository $tag }}
{{- end }}
{{- end }}

{{/*
Create backend image name
*/}}
{{- define "camp.backend.image" -}}
{{- $registry := .Values.global.imageRegistry | default .Values.image.registry }}
{{- $repository := .Values.backend.image.repository }}
{{- $tag := .Values.image.tag | default .Chart.AppVersion }}
{{- printf "%s/%s:%s" $registry $repository $tag }}
{{- end }}

{{/*
Create web image name
*/}}
{{- define "camp.web.image" -}}
{{- $registry := .Values.global.imageRegistry | default .Values.image.registry }}
{{- $repository := .Values.web.image.repository }}
{{- $tag := .Values.image.tag | default .Chart.AppVersion }}
{{- printf "%s/%s:%s" $registry $repository $tag }}
{{- end }}

{{/*
Create auth image name
*/}}
{{- define "camp.auth.image" -}}
{{- $registry := .Values.global.imageRegistry | default .Values.image.registry }}
{{- $repository := .Values.auth.image.repository }}
{{- $tag := .Values.image.tag | default .Chart.AppVersion }}
{{- printf "%s/%s/%s:%s" $registry $Values.image.repository $repository $tag }}
{{- end }}

{{/*
Create backend fullname
*/}}
{{- define "camp.backend.fullname" -}}
{{- printf "%s-%s" (include "camp.fullname" .) .Values.backend.name }}
{{- end }}

{{/*
Create web fullname
*/}}
{{- define "camp.web.fullname" -}}
{{- printf "%s-%s" (include "camp.fullname" .) .Values.web.name }}
{{- end }}

{{/*
Create auth fullname
*/}}
{{- define "camp.auth.fullname" -}}
{{- printf "%s-%s" (include "camp.fullname" .) .Values.auth.name }}
{{- end }}

{{/*
Create backend selector labels
*/}}
{{- define "camp.backend.selectorLabels" -}}
app.kubernetes.io/name: {{ include "camp.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: {{ .Values.backend.name }}
{{- end }}

{{/*
Create web selector labels
*/}}
{{- define "camp.web.selectorLabels" -}}
app.kubernetes.io/name: {{ include "camp.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: {{ .Values.web.name }}
{{- end }}

{{/*
Create auth selector labels
*/}}
{{- define "camp.auth.selectorLabels" -}}
app.kubernetes.io/name: {{ include "camp.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: {{ .Values.auth.name }}
{{- end }}

{{/*
Check if autoscaling is enabled
*/}}
{{- define "camp.backend.autoscaling.enabled" -}}
{{- if and .Values.backend.autoscaling.enabled (gt (.Values.backend.autoscaling.minReplicas | int) 0) }}
{{- true }}
{{- else }}
{{- false }}
{{- end }}
{{- end }}

{{- define "camp.web.autoscaling.enabled" -}}
{{- if and .Values.web.autoscaling.enabled (gt (.Values.web.autoscaling.minReplicas | int) 0) }}
{{- true }}
{{- else }}
{{- false }}
{{- end }}
{{- end }}

{{- define "camp.auth.autoscaling.enabled" -}}
{{- if and .Values.auth.autoscaling.enabled (gt (.Values.auth.autoscaling.minReplicas | int) 0) }}
{{- true }}
{{- else }}
{{- false }}
{{- end }}
{{- end }}

{{/*
Create config map name
*/}}
{{- define "camp.configMapName" -}}
{{- printf "%s-config" (include "camp.fullname" .) }}
{{- end }}

{{/*
Create secret name
*/}}
{{- define "camp.secretName" -}}
{{- printf "%s-secrets" (include "camp.fullname" .) }}
{{- end }}
