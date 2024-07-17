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
