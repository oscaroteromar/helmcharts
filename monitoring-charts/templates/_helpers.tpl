{{/* *** COMMON *** */}}

{{/*
Service annotations
*/}}
{{- define "svc.annotations" -}}
prometheus.io/scrape: "true"
prometheus.io/port: {{ .deployment.containers.port | quote }}
{{- end -}}


{{/* *** PROMETHEUS *** */}}

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
Notes
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

{{/* *** KUBE-STATE-METRICS *** */}}

{{/*
Common labels
*/}}
{{- define "kubesm.labels" -}}
{{ toYaml .Values.kubeStateMetrics.labels }}
{{- end -}}

{{/*
Deployment selector.matchLables
*/}}
{{- define "kubesm.deploy.selector.matchLabels" -}}
{{ toYaml .Values.kubeStateMetrics.deployment.matchLabels }}
{{- end -}}

{{/*
Deployment liveness
*/}}
{{- define "kubesm.deploy.liveness" -}}
{{ toYaml .Values.kubeStateMetrics.deployment.containers.livenessProbe }}
{{- end -}}

{{/*
Deployment readiness
*/}}
{{- define "kubesm.deploy.readiness" -}}
{{ toYaml .Values.kubeStateMetrics.deployment.containers.readinessProbe }}
{{- end -}}

{{/*
Deployment ports
*/}}
{{- define "kubesm.deploy.ports" -}}
{{ toYaml .Values.kubeStateMetrics.deployment.containers.ports }}
{{- end -}}

{{/*
Deployment nodeSelector
*/}}
{{- define "kubesm.deploy.nodeselector" -}}
{{ toYaml .Values.kubeStateMetrics.deployment.nodeSelector }}
{{- end -}}

{{/*
Service ports
*/}}
{{- define "kubesm.svc.ports" -}}
{{ toYaml .Values.kubeStateMetrics.service.ports }}
{{- end -}}

{{/*
Service selector
*/}}
{{- define "kubesm.svc.selector" -}}
{{ toYaml .Values.kubeStateMetrics.service.selector }}
{{- end -}}

{{/* *** NODE-EXPORTER *** */}}

{{/*
Common labels
*/}}
{{- define "nexp.labels" -}}
{{ toYaml .Values.nodeExporter.labels }}
{{- end -}}

{{/*
Service ports
*/}}
{{- define "nexp.svc.ports" -}}
- name: {{ .Values.nodeExporter.name }}
  protocol: TCP
  port: {{ .Values.nodeExporter.service.port | default .Values.nodeExporter.deployment.containers.port }}
  targetPort: {{ .Values.nodeExporter.deployment.containers.port }}
  {{ if .Values.nodeExporter.service.nodePort -}}
  nodePort: {{ .Values.nodeExporter.service.nodePort }}
  {{- end -}}
{{- end -}}

{{/*
Daemonset args
*/}}
{{- define "nexp.ds.args" -}}
{{- with (index .Values.nodeExporter.deployment.containers.volumeMounts 0) -}}
- --path.sysfs={{ .mountPath}}
{{- end -}}
{{- with (index .Values.nodeExporter.deployment.containers.volumeMounts 1) }}
- --path.rootfs={{ .mountPath}}
{{- end }}
- --no-collector.wifi
- --no-collector.hwmon
- --collector.filesystem.ignored-mount-points=^/(dev|proc|sys|var/lib/docker/.+|var/lib/kubelet/pods/.+)($|/)
- --collector.netclass.ignored-devices=^(veth.*)$
{{- end -}}

{{/*
Daemonset ports
*/}}
{{- define "nexp.ds.ports" -}}
- containerPort: {{ .Values.nodeExporter.deployment.containers.port }}
  protocol: TCP
{{- end -}}

{{/*
Daemonset resources
*/}}
{{- define "nexp.ds.resources" -}}
limits:
  cpu: 250m
  memory: 180Mi
requests:
  cpu: 102m
  memory: 180Mi
{{- end -}}

{{/*
Daemonset volumeMounts
*/}}
{{- define "nexp.ds.volumemounts" -}}
{{ toYaml .Values.nodeExporter.deployment.containers.volumeMounts }}
{{- end -}}

{{/*
Daemonset volumes
*/}}
{{- define "nexp.ds.volumes" -}}
{{ toYaml .Values.nodeExporter.deployment.volumes }}
{{- end -}}
