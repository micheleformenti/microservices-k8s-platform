{{- define "ms-k8s-platform.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "ms-k8s-platform.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := include "ms-k8s-platform.name" . }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{- define "ms-k8s-platform.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "ms-k8s-platform.labels" -}}
helm.sh/chart: {{ include "ms-k8s-platform.chart" . }}
app.kubernetes.io/name: {{ include "ms-k8s-platform.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "ms-k8s-platform.frontendLabels" -}}
{{ include "ms-k8s-platform.labels" . }}
app.kubernetes.io/component: frontend
{{- end }}

{{- define "ms-k8s-platform.frontendSelectorLabels" -}}
app.kubernetes.io/name: {{ include "ms-k8s-platform.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: frontend
{{- end }}

{{- define "ms-k8s-platform.productCatalogServiceLabels" -}}
{{ include "ms-k8s-platform.labels" . }}
app.kubernetes.io/component: productcatalogservice
{{- end }}

{{- define "ms-k8s-platform.productCatalogServiceSelectorLabels" -}}
app.kubernetes.io/name: {{ include "ms-k8s-platform.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: productcatalogservice
{{- end }}

{{- define "ms-k8s-platform.currencyServiceLabels" -}}
{{ include "ms-k8s-platform.labels" . }}
app.kubernetes.io/component: currencyservice
{{- end }}

{{- define "ms-k8s-platform.currencyServiceSelectorLabels" -}}
app.kubernetes.io/name: {{ include "ms-k8s-platform.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: currencyservice
{{- end }}

{{- define "ms-k8s-platform.cartServiceLabels" -}}
{{ include "ms-k8s-platform.labels" . }}
app.kubernetes.io/component: cartservice
{{- end }}

{{- define "ms-k8s-platform.cartServiceSelectorLabels" -}}
app.kubernetes.io/name: {{ include "ms-k8s-platform.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: cartservice
{{- end }}

{{- define "ms-k8s-platform.recommendationServiceLabels" -}}
{{ include "ms-k8s-platform.labels" . }}
app.kubernetes.io/component: recommendationservice
{{- end }}

{{- define "ms-k8s-platform.recommendationServiceSelectorLabels" -}}
app.kubernetes.io/name: {{ include "ms-k8s-platform.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: recommendationservice
{{- end }}

{{- define "ms-k8s-platform.shippingServiceLabels" -}}
{{ include "ms-k8s-platform.labels" . }}
app.kubernetes.io/component: shippingservice
{{- end }}

{{- define "ms-k8s-platform.shippingServiceSelectorLabels" -}}
app.kubernetes.io/name: {{ include "ms-k8s-platform.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: shippingservice
{{- end }}

{{- define "ms-k8s-platform.adServiceLabels" -}}
{{ include "ms-k8s-platform.labels" . }}
app.kubernetes.io/component: adservice
{{- end }}

{{- define "ms-k8s-platform.adServiceSelectorLabels" -}}
app.kubernetes.io/name: {{ include "ms-k8s-platform.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: adservice
{{- end }}

{{- define "ms-k8s-platform.checkoutServiceLabels" -}}
{{ include "ms-k8s-platform.labels" . }}
app.kubernetes.io/component: checkoutservice
{{- end }}

{{- define "ms-k8s-platform.checkoutServiceSelectorLabels" -}}
app.kubernetes.io/name: {{ include "ms-k8s-platform.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: checkoutservice
{{- end }}

{{- define "ms-k8s-platform.paymentServiceLabels" -}}
{{ include "ms-k8s-platform.labels" . }}
app.kubernetes.io/component: paymentservice
{{- end }}

{{- define "ms-k8s-platform.paymentServiceSelectorLabels" -}}
app.kubernetes.io/name: {{ include "ms-k8s-platform.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: paymentservice
{{- end }}

{{- define "ms-k8s-platform.emailServiceLabels" -}}
{{ include "ms-k8s-platform.labels" . }}
app.kubernetes.io/component: emailservice
{{- end }}

{{- define "ms-k8s-platform.emailServiceSelectorLabels" -}}
app.kubernetes.io/name: {{ include "ms-k8s-platform.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: emailservice
{{- end }}

{{- define "ms-k8s-platform.loadGeneratorLabels" -}}
{{ include "ms-k8s-platform.labels" . }}
app.kubernetes.io/component: loadgenerator
{{- end }}

{{- define "ms-k8s-platform.loadGeneratorSelectorLabels" -}}
app.kubernetes.io/name: {{ include "ms-k8s-platform.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: loadgenerator
{{- end }}

{{- define "ms-k8s-platform.redisCartLabels" -}}
{{ include "ms-k8s-platform.labels" . }}
app.kubernetes.io/component: redis-cart
{{- end }}

{{- define "ms-k8s-platform.redisCartSelectorLabels" -}}
app.kubernetes.io/name: {{ include "ms-k8s-platform.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: redis-cart
{{- end }}
