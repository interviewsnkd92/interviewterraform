resource "kubernetes_namespace" "cert_manager" {
  metadata {
    name = "cert-manager"
  }
}

resource "helm_release" "cert_manager" {
  name       = "csert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "v1.14.1"
  namespace  = kubernetes_namespace.cert_manager.metadata.0.name

  set {
    name  = "installCRDs"
    value = "true"
  }
  depends_on = [
    azurerm_kubernetes_cluster.k8s
  ]
}

resource "helm_release" "ingress_nginx" {
  name             = random_string.azurerm_key_vault_name.result
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = "ingress"
  create_namespace = true

  set {
    name  = "controller.service.loadBalancerIP"
    value = azurerm_public_ip.ingress_nginx_pip.ip_address
  }

  lifecycle {
    ignore_changes = [
      set,
    ]
  }

  depends_on = [
    helm_release.cert_manager
  ]

}