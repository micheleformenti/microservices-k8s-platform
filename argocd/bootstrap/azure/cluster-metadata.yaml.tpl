apiVersion: v1
kind: Secret
metadata:
  name: cluster-aks
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: cluster
    cloud: azure
  annotations:
    gitops-bridge/alb-controller-client-id: ${ALB_CONTROLLER_CLIENT_ID}
    gitops-bridge/application-gateway-subnet-id: ${APPLICATION_GATEWAY_SUBNET_ID}
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
