provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

resource "kubernetes_namespace" "metallb_ns" {
  metadata {
    name = "metallb-system"
  }
}

resource "helm_release" "metallb" {
  name       = "metallb"
  namespace  = kubernetes_namespace.metallb_ns.metadata[0].name
  repository = "https://metallb.github.io/metallb"
  chart      = "metallb"
}

# These need to be commmented out for the first run
# as `terraform plan` fail due to the issue below if the metallb
# chart hasn't been ran yet 
# https://github.com/hashicorp/terraform-provider-kubernetes-alpha/issues/235
resource "kubernetes_manifest" "metallb_ip_pool" {
  manifest = {
    "apiVersion" = "metallb.io/v1beta1"
    "kind"       = "IPAddressPool"
    "metadata" = {
      "name"      = "metallb-ip-pool"
      "namespace" = "metallb-system"
    }
    "spec" = {
      "addresses" = ["192.168.1.240-192.168.1.250"]
    }
  }
  depends_on = [ helm_release.metallb ]
}

resource "kubernetes_manifest" "l2advertisement" {
  manifest = {
    "apiVersion" = "metallb.io/v1beta1"
    "kind"       = "L2Advertisement"
    "metadata" = {
      "name"      = "l2advertistment"
      "namespace" = "metallb-system"
    }
  }
}

resource "kubernetes_namespace" "ingress_nginx" {
  metadata {
    name = "ingress-nginx"
  }
}

resource "helm_release" "ingress_nginx" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = "ingress-nginx"
  depends_on = [
    kubernetes_namespace.ingress_nginx,
    helm_release.metallb,
  ]
}