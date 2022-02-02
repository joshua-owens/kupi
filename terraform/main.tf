provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

resource "helm_release" "metallb" {
  name       = "metallb"
  repository = "https://metallb.github.io/metallb"
  chart      = "metallb"
  namespace  = "kube-system"

  set {
    name  = "configInline.address-pools[0].name"
    value = "default"
  }

  set {
    name  = "configInline.address-pools[0].protocol"
    value = "layer2"
  }

  set {
    name  = "configInline.address-pools[0].addresses[0]"
    value = "192.168.0.240-192.168.0.250"
  }
}

resource "helm_release" "nginx_ingress" {
  name       = "nginx-ingress-controller"
  repository = "https://helm.nginx.com/stable"
  chart      = "nginx-ingress"
  namespace  = "kube-system"

  set {
    name  = "defaultBackend.enabled"
    value = false
  }
}
