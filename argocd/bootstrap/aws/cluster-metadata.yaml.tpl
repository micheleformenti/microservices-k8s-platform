apiVersion: v1
kind: Secret
metadata:
  name: cluster-eks
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: cluster
    cloud: aws
  annotations:
    gitops-bridge/cluster-name: ${CLUSTER_NAME}
    gitops-bridge/aws-region: ${AWS_REGION}
    gitops-bridge/dns-zone-name: ${DNS_ZONE_NAME}
    gitops-bridge/application-domain-name: ${APPLICATION_DOMAIN_NAME}
    gitops-bridge/application-certificate-arn: ${APPLICATION_CERTIFICATE_ARN}
type: Opaque
stringData:
  name: eks
  server: https://kubernetes.default.svc
  config: |
    {
      "tlsClientConfig": {
        "insecure": false
      }
    }
