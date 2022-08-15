{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "mastodon.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "mastodon.fullname" -}}
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
{{- define "mastodon.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "mastodon.labels" -}}
helm.sh/chart: {{ include "mastodon.chart" . }}
{{ include "mastodon.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "mastodon.selectorLabels" -}}
app.kubernetes.io/name: {{ include "mastodon.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "mastodon.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "mastodon.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create a default fully qualified name for dependent services.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "mastodon.elasticsearch.fullname" -}}
{{- printf "%s-%s" .Release.Name "elasticsearch" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "mastodon.redis.fullname" -}}
{{- printf "%s-%s" .Release.Name "redis" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "mastodon.postgresql.fullname" -}}
{{- printf "%s-%s" .Release.Name "postgresql" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Get the mastodon secret.
*/}}
{{- define "mastodon.secretName" -}}
{{- if .Values.mastodon.secrets.existingSecret }}
    {{- printf "%s" (tpl .Values.mastodon.secrets.existingSecret $) -}}
{{- else -}}
    {{- printf "%s" (include "common.names.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
Get the postgresql secret.
*/}}
{{- define "mastodon.postgresql.secretName" -}}
{{- if (and (or .Values.postgresql.enabled .Values.postgresql.postgresqlHostname) .Values.postgresql.auth.existingSecret) }}
    {{- printf "%s" (tpl .Values.postgresql.auth.existingSecret $) -}}
{{- else if .Values.postgresql.enabled -}}
    {{- printf "%s-postgresql" (tpl .Release.Name $) -}}
{{- else -}}
    {{- printf "%s" (include "common.names.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
Get the redis secret.
*/}}
{{- define "mastodon.redis.secretName" -}}
{{- if .Values.redis.auth.existingSecret }}
    {{- printf "%s" (tpl .Values.redis.auth.existingSecret $) -}}
{{- else if .Values.redis.existingSecret }}
    {{- printf "%s" (tpl .Values.redis.existingSecret $) -}}
{{- else -}}
    {{- printf "%s-redis" (tpl .Release.Name $) -}}
{{- end -}}
{{- end -}}

{{/*
Return true if a mastodon secret object should be created
*/}}
{{- define "mastodon.createSecret" -}}
{{- if (or
    (and .Values.mastodon.s3.enabled (not .Values.mastodon.s3.existingSecret))
    (not .Values.mastodon.secrets.existingSecret )
    (and (not .Values.postgresql.enabled) (not .Values.postgresql.auth.existingSecret))
    ) -}}
    {{- true -}}
{{- end -}}
{{- end -}}
