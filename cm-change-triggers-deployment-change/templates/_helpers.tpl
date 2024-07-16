{{- define "cm-change-triggers-deployment-change.configMapHash" -}}
{{- $config := (include "cm-change-triggers-deployment-change/templates/configmap.yaml" . | sha256sum) -}}
{{- $config | quote -}}
{{- end -}}



