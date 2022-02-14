{{/*
ClusterRole metrics endpoint
*/}}
{{- define "prometheus.clusterrole.metrics" -}}
[{{- .Values.prometheus.clusterRole.metricsUrl | default "/metrics" | quote -}}]
{{- end -}}

{{/*
ConfigMap prometheus configuration
*/}}
{{- define "prometheus.cm.config" -}}
{{- .Values.prometheus.configMap.filename -}}: |-
{{- .Files.Get .Values.prometheus.configMap.filename | nindent 4 -}}
{{- end -}}

{{/*
Service annotations
*/}}
{{- define "prometheus.svc.annotations" -}}
prometheus.io/scrape: "true"
prometheus.io/port: {{ .Values.prometheus.deployment.containers.port | quote }}
{{- end -}}

{{/*
Service type
*/}}
{{- define "prometheus.svc.type" -}}
{{- if and (.Values.prometheus.service.type) (ne .Values.prometheus.service.type "ClusterIP") -}}
type: {{ .Values.prometheus.service.type }}
{{- end -}}
{{- end -}}

{{/*
Service ports
*/}}
{{- define "prometheus.svc.ports" -}}
- port: {{ .Values.prometheus.service.port }}
  targetPort: {{ .Values.prometheus.deployment.containers.port | default .Values.prometheus.service.port}}
  {{- if eq .Values.prometheus.service.type "NodePort" }}
  nodePort: {{ .Values.prometheus.service.nodePort }}
  {{- end}}
{{- end -}}

{{/*
Deployment containers config
*/}}
{{- define "prometheus.deploy.containers" -}}
- name: {{ .Values.prometheus.deployment.containers.name }}
  image: {{ .Values.prometheus.deployment.containers.image }}
  args:
    - "--config.file={{ .Values.prometheus.deployment.configLocation }}/{{ .Values.prometheus.configMap.filename }}"
    - "--storage.tsdb.path=/prometheus/"
  ports:
    - containerPort: {{ .Values.prometheus.deployment.containers.port }}
  volumeMounts: {{ toYaml .Values.prometheus.deployment.volume | nindent 2 }}
{{- end -}}

{{/*
Deployment containers volume
*/}}
{{- define "prometheus.deploy.volumes" -}}
{{- with (index .Values.prometheus.deployment.volume 0) -}}
- name: {{ .name }}
{{- end }}
  configMap:
    defaultMode: 420
    name: {{ .Values.prometheus.configMap.name  }}
{{- with (index .Values.prometheus.deployment.volume 1) }}
- name: {{ .name }}
{{- end }}
  emptyDir: {}
{{- end -}}

{{/*
NOTES
*/}}

{{- define "notes.svc.type" -}}
{{- if and (.Values.prometheus.service.type) -}}
{{ .Values.prometheus.service.type }}
{{- else -}}
ClusterIP
{{- end -}}
{{- end -}}

{{- define "notes.pod.filter" -}}
{{ toYaml .Values.prometheus.label | toString | replace ": " "=" | quote }}
{{- end -}}