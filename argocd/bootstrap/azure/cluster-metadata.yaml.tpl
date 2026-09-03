apiVersion: v1
kind: Secret
metadata:
  name: cluster-aks
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: cluster
    cloud: azure
  annotations:
    gitops-bridge/azure-tenant-id: ${AZURE_TENANT_ID}
    gitops-bridge/azure-subscription-id: ${AZURE_SUBSCRIPTION_ID}
    gitops-bridge/cluster-name: ${CLUSTER_NAME}
    gitops-bridge/alb-controller-client-id: ${ALB_CONTROLLER_CLIENT_ID}
    gitops-bridge/application-gateway-subnet-id: ${APPLICATION_GATEWAY_SUBNET_ID}
    gitops-bridge/dns-zone-resource-group-name: ${DNS_ZONE_RESOURCE_GROUP_NAME}
    gitops-bridge/dns-zone-name: ${DNS_ZONE_NAME}
    gitops-bridge/external-dns-client-id: ${EXTERNAL_DNS_CLIENT_ID}
    gitops-bridge/external-secrets-client-id: ${EXTERNAL_SECRETS_CLIENT_ID}
    gitops-bridge/key-vault-uri: ${KEY_VAULT_URI}
type: Opaque
stringData:
  name: aks
  server: https://kubernetes.default.svc
  config: |
    {
      "tlsClientConfig": {
        "insecure": false
      }
    }
