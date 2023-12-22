provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

resource "helm_release" "metallb" {
  name       = "metallb"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "metallb"

  set {
    name  = "controller.image.tag"
    value = "v0.9.6"
  }

  set {
    name  = "speaker.image.tag"
    value = "v0.9.6"
  }

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
    value = var.address_range
  }
}