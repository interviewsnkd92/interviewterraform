resource "kubectl_manifest" "secret_class" {
  depends_on = [
        time_sleep.wait_for_certmanager                   
    ]
  yaml_body = <<YAML
apiVersion: secrets-store.csi.x-k8s.io/v1                        
kind: SecretProviderClass
metadata:
  name: azure-kvname-user-msi
spec:
  provider: azure
  parameters:
    usePodIdentity: "false"
    useVMManagedIdentity: "true"
    userAssignedIdentityID: ${azurerm_kubernetes_cluster.k8s.kubelet_identity[0].client_id}
    keyvaultName: ${azurerm_key_vault.vault.name}
    cloudName: ""
    objects: |
      array:
        - |
          objectName: ${azurerm_key_vault_key.key.name}
          objectType: key
          objectVersion: ""
    tenantId: ${data.azurerm_client_config.current.tenant_id}
YAML
}

resource "time_sleep" "wait_for_certmanager" {

    depends_on = [
      helm_release.cert_manager
    ]

    create_duration = "10s"
}

resource "kubectl_manifest" "secret_pod" {
  depends_on = [
        kubectl_manifest.secret_class
    ]
  yaml_body = <<YAML
kind: Pod
apiVersion: v1
metadata:
  name: busybox-secrets-store-inline-user-msi
spec:
  containers:
    - name: busybox
      image: registry.k8s.io/e2e-test-images/busybox:1.29-4
      command:
        - "/bin/sleep"
        - "10000"
      volumeMounts:
      - name: secrets-store01-inline
        mountPath: "/mnt/secrets-store"
        readOnly: true
  volumes:
    - name: secrets-store01-inline
      csi:
        driver: secrets-store.csi.k8s.io
        readOnly: true
        volumeAttributes:
          secretProviderClass: "azure-kvname-user-msi"
YAML
}

resource "kubectl_manifest" "deployment" {
  depends_on = [
        kubectl_manifest.secret_pod
    ]
  yaml_body = <<YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
        resources:
          requests:
            cpu: "100m"
            memory: "200Mi"
          limits:
            cpu: "500m"
            memory: "500Mi"
        volumeMounts:
        - name: secrets-store01-inline
          mountPath: "/mnt/secrets-store"
          readOnly: true
      volumes:
      - name: secrets-store01-inline
        csi:
          driver: secrets-store.csi.k8s.io
          readOnly: true
          volumeAttributes:
            secretProviderClass: "azure-kvname-user-msi"
YAML
}

resource "kubectl_manifest" "service" {
  depends_on = [
        kubectl_manifest.deployment
    ]
  yaml_body = <<YAML
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  selector:
    app: nginx
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
YAML
}

resource "kubectl_manifest" "ingress_rule" {
  depends_on = [
        kubectl_manifest.service
    ]
  yaml_body = <<YAML
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nginx-ingress
  annotations:
    kubernetes.io/ingress.class: "nginx"
spec:
  rules:
  - http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: nginx-service
            port:
              number: 80
YAML
}

resource "kubectl_manifest" "hpa" {
  depends_on = [
        kubectl_manifest.ingress_rule
    ]
  yaml_body = <<YAML
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: nginx-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: nginx-deployment
  minReplicas: 1
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 50
YAML
}
