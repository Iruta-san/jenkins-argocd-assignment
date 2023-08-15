{{- define "nginx-test-app.fullname" -}}
{{- printf "%s-%s" .Release.Name .Values.namespace | trunc 63 | trimSuffix "-" -}}
{{- end -}}