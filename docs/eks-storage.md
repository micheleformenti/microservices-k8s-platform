# EKS Storage

This document describes the first EKS storage iteration for the platform.

The goal is to demonstrate persistent Kubernetes storage for Redis cart data
while keeping the architecture simple enough for a demo environment.

## Architecture

```text
redis-cart StatefulSet
        |
        | volumeClaimTemplates
        v
PersistentVolumeClaim
        |
        | storageClassName: gp3
        v
EBS CSI driver
        |
        v
AWS EBS volume
```

The AWS-specific `gp3` `StorageClass` is managed separately from the application
chart:

```text
helm/platform/aws
```

The application chart consumes that storage class only when EKS values are used:

```text
helm/application/values-eks.yaml
```

## Redis StatefulSet

Redis cart storage is deployed as a `StatefulSet`.

With the default values, Redis still uses ephemeral local storage:

```yaml
redisCart:
  persistence:
    enabled: false
```

That renders an `emptyDir` volume. This keeps the default local development
path lightweight.

On EKS, persistence is enabled:

```yaml
redisCart:
  persistence:
    enabled: true
    storageClassName: gp3
    size: 1Gi
```

That renders a `volumeClaimTemplates` block. Kubernetes creates a dedicated PVC
for the Redis pod, for example:

```text
redis-data-redis-cart-0
```

The flow is:

```text
StatefulSet redis-cart
  -> Pod redis-cart-0
  -> PVC redis-data-redis-cart-0
  -> PV
  -> EBS volume
```

If the Redis pod is deleted, the StatefulSet recreates `redis-cart-0` and mounts
the same PVC again.

## StorageClass

The AWS platform chart creates a `gp3` `StorageClass`:

```yaml
provisioner: ebs.csi.aws.com
parameters:
  type: gp3
  encrypted: "true"
reclaimPolicy: Delete
allowVolumeExpansion: true
volumeBindingMode: WaitForFirstConsumer
```

Important settings:

- `provisioner: ebs.csi.aws.com` tells Kubernetes to use the AWS EBS CSI driver.
- `type: gp3` uses the current general-purpose EBS volume type.
- `encrypted: "true"` creates encrypted EBS volumes.
- `volumeBindingMode: WaitForFirstConsumer` delays volume creation until the
  pod is scheduled, so the EBS volume is created in the same Availability Zone
  as the selected node.
- `reclaimPolicy: Delete` deletes the backing EBS volume when the PVC is
  deleted.

`reclaimPolicy: Delete` does not delete data when the pod restarts. It only
applies when the PVC itself is deleted.

## Validation

After syncing the EKS platform and application Argo CD apps, verify the storage
resources:

```sh
kubectl get storageclass gp3
kubectl get statefulset redis-cart -n microservices-platform
kubectl get pvc -n microservices-platform
kubectl get pv
```

Expected result:

```text
redis-cart runs as a StatefulSet
redis-data-redis-cart-0 PVC exists
PVC uses the gp3 StorageClass
PV is dynamically provisioned by the EBS CSI driver
```

Validate persistence:

1. Open the frontend.
2. Add an item to the cart.
3. Delete the Redis pod:

   ```sh
   kubectl delete pod redis-cart-0 -n microservices-platform
   ```

4. Wait for the pod to be recreated:

   ```sh
   kubectl get pods -n microservices-platform -w
   ```

5. Refresh the frontend and confirm the cart data is still present.

## Tradeoffs

This setup demonstrates persistence across pod restarts and node replacement
within the same Availability Zone.

It is not a multi-AZ Redis high-availability setup. EBS volumes are tied to one
Availability Zone, so Redis can only mount the volume on a node in the same AZ.

For production, Redis would need a stronger design, such as:

- Redis replication with Sentinel
- Redis Cluster
- a managed Redis service such as Amazon ElastiCache with Multi-AZ

For this demo project, a single Redis StatefulSet with EBS-backed persistence is
the intended tradeoff: it demonstrates Kubernetes persistent storage without
turning the project into a full Redis operations project.
