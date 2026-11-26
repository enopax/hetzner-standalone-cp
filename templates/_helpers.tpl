{{- define "cluster.name" -}}
    {{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "hcloudmachinetemplate.controlplane.name" -}}
    {{- include "cluster.name" . }}-cp-mt
{{- end }}

{{- define "hcloudmachinetemplate.worker.name" -}}
    {{- include "cluster.name" . }}-worker-mt
{{- end }}

{{- define "k0scontrolplane.name" -}}
    {{- include "cluster.name" . }}-cp
{{- end }}

{{- define "k0sworkerconfigtemplate.name" -}}
    {{- include "cluster.name" . }}-machine-config
{{- end }}

{{- define "machinedeployment.name" -}}
    {{- include "cluster.name" . }}-md
{{- end }}

{{/*
Die Fassung in der Form, die der kubelet meldet.

Es gibt zwei Schreibweisen derselben Fassung, und sie sind nicht
austauschbar:

  v1.35.4+k0s.0   die k0s-Release-Nummer. Die installiert k0s, die steht im
                  `K0sWorkerConfigTemplate` und in `k0s.version`.
  v1.35.4+k0s     was der Knoten danach in
                  `Node.status.nodeInfo.kubeletVersion` meldet.

k0rdent vergleicht `Machine.spec.version` mit der **gemeldeten** Form, und
zwar als Zeichenkette. Hier stand vorher

  {{ regexReplaceAll "\\+k0s.+$" .Values.k0s.version "" }}

und das schneidet zu viel: aus `v1.35.4+k0s.0` wird `v1.35.4`, und damit
galten die Arbeiter des Regionals dauerhaft als veraltet (UpToDate=False).
Am laufenden Bestand gemessen, siehe enopax/enopax#56 und #49:

  spec.version: v1.35.4         →  UpToDate=False
  spec.version: v1.35.4+k0s     →  UpToDate=True

Das Schema dieses Charts laesst fuer `k0s.version` jede Zeichenkette zu,
deshalb wird erst jeder `+k0s`-Schwanz entfernt und dann genau einer
angehaengt. Damit gilt fuer alle drei Formen dasselbe Ergebnis:

  v1.35.4+k0s.0  →  v1.35.4+k0s
  v1.35.4+k0s    →  v1.35.4+k0s
  v1.35.4        →  v1.35.4+k0s

Die Release-Nummer bleibt im `K0sWorkerConfigTemplate`, und das ist keine
Redundanz: k0smotron nimmt sie von dort, wenn sie dort steht, und nur sonst
die vom Machine-Objekt - die es dann mit
`fmt.Sprintf("%s+%s", version, "k0s.0")` normalisiert. Aus `v1.35.4+k0s`
wuerde dabei `v1.35.4+k0s+k0s.0`, also Unsinn.
*/}}
{{- define "cluster.kubeletVersion" -}}
{{- printf "%s+k0s" (regexReplaceAll "\\+k0s.*$" .Values.k0s.version "") -}}
{{- end -}}
