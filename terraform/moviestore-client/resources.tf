resource "kubernetes_deployment" "moviestore_client" {
  metadata {
    name = "moviestore-client"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "moviestore-client"
      }
    }

    template {
      metadata {
        labels = {
          app = "moviestore-client"
        }
      }

      spec {
        container {
          image = "ranyqb/moviestoreclient:2.0.0"
          name  = "moviestore-client"

          port {
            container_port = 3000
          }

          volume_mount {
            name      = "client-files"
            mount_path = "/usr/share/nginx/html"
          }
        }

        volume {
          name = "client-files"
          empty_dir {}
        }
      }
    }
  }
}

resource "kubernetes_service" "moviestore_client" {
  metadata {
    name = "moviestore-client"
  }

  spec {
    selector = {
      app = "moviestore-client"
    }

    port {
      port        = 3000
      target_port = 3000
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_ingress" "moviestore_client" {
  metadata {
    name = "moviestore-client"
  }

  spec {
    ingress_class_name = "nginx"

    rule {
      http {
        path {
          path     = "/"
          path_type = "Prefix"
        }

        backend {
          service_name = kubernetes_service.moviestore_client.metadata.0.name
          service_port = 3000
        }
      }
    }
  }
}