{{/*
Return the chart's name. Fallback to a default if .Chart is nil.
*/}}
{{- define "common.names.name" -}}
{{- if .Chart }}
  {{- $nameOverride := "" }}
  {{- if .Values }}
    {{- $nameOverride = .Values.nameOverride }}
  {{- end }}
  {{- default .Chart.Name $nameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
  {{- $nameOverride := "" }}
  {{- if .Values }}
    {{- $nameOverride = .Values.nameOverride }}
  {{- end }}
  {{- default "unknown-chart" $nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end }}

{{/*
Return the chart name and version for labeling.
*/}}
{{- define "common.chart" -}}
{{- if .Chart }}
  {{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- else -}}
  unknown-chart-unknown
{{- end -}}
{{- end }}


