provider "kubernetes" {
  config_path = "~/.kube/config"
}

resource "kubernetes_secret" "docker_registry" {
  metadata {
    name = "docker-hub-credentials"
  }

  data = {
    ".dockerconfigjson" = jsonencode({
      "auths" = {
        "https://index.docker.io/v1/" = {
          "username" = var.docker_username
          "password" = var.docker_access_token
        }
      }
    })
  }

  type = "kubernetes.io/dockerconfigjson"
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
  depends_on = [helm_release.metallb]
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

resource "kubernetes_deployment" "fiddy" {
  metadata {
    name = "fiddy"
    labels = {
      App = "Fiddy"
    }
  }

  spec {
    replicas = 3
    selector {
      match_labels = {
        App = "Fiddy"
      }
    }

    template {
      metadata {
        labels = {
          App = "Fiddy"
        }
      }

      spec {
        image_pull_secrets {
          name = kubernetes_secret.docker_registry.metadata[0].name
        }

        container {
          image = "lpod64/fiddy:latest"
          name  = "fiddy"

          port {
            container_port = 4000
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "fiddy" {
  metadata {
    name = "fiddy-service"
  }
  spec {
    selector = {
      App = "Fiddy"
    }
    port {
      port        = 80
      target_port = 4000
    }
    type = "LoadBalancer"
  }
}

resource "kubernetes_secret" "postgres" {
  metadata {
    name = "postgres-secret"
  }

  data = {
    username = var.postgres_user
    password = var.postgres_password
  }
}

resource "kubernetes_persistent_volume" "postgres" {
  metadata {
    name = "postgres"
  }

  spec {
    capacity = {
      storage = "10Gi"
    }

    access_modes = ["ReadWriteOnce"]

    storage_class_name = "local-path"

    persistent_volume_source {
      host_path {
        path = "/postgres-data"
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "postgres" {
  metadata {
    name = "postgres"
  }

  spec {
    volume_name = kubernetes_persistent_volume.postgres.metadata[0].name

    access_modes = ["ReadWriteOnce"]

    storage_class_name = "local-path"

    resources {
      requests = {
        storage = "10Gi"
      }
    }
  }
}

resource "kubernetes_stateful_set" "postgres" {
  metadata {
    name = "postgres"
  }

  spec {
    selector {
      match_labels = {
        App = "postgres"
      }
    }

    service_name = "postgres"
    replicas     = 1

    template {
      metadata {
        labels = {
          App = "postgres"
        }
      }

      spec {
        node_selector = {
          "kubernetes.io/hostname" = "100.113.101.41"
        }

        container {
          image = "postgres:latest"
          name  = "postgres"

          env {
            name = "POSTGRES_USER"
            value_from {
              secret_key_ref {
                name = "postgres-secret"
                key  = "username"
              }
            }
          }
          env {
            name = "POSTGRES_PASSWORD"
            value_from {
              secret_key_ref {
                name = "postgres-secret"
                key  = "password"
              }
            }
          }

          port {
            container_port = 5432
          }

          volume_mount {
            mount_path = "/var/lib/postgresql/data"
            name       = "postgres"
          }
        }
      }
    }

    volume_claim_template {
      metadata {
        name = "postgres"
      }

      spec {
        access_modes = ["ReadWriteOnce"]
        resources {
          requests = {
            storage = "10Gi"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "postgres" {
  metadata {
    name = "postgres-service"
  }
  spec {
    selector = {
      app = "postgres"
    }
    port {
      port        = 5432
      target_port = 5432
    }
  }
}