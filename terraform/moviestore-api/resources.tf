resource "kubernetes_ingress" "moviestore_api" {
  metadata {
    name = "moviestore-api"
  }

  spec {
    ingress_class_name = "nginx"

    rule {
      http {
        path {
          path     = "/swagger/"
          path_type = "Prefix"
        }

        backend {
          service_name = kubernetes_service.moviestore_api.metadata.0.name
          service_port = 8080
        }
      }
    }
  }
}

resource "kubernetes_deployment" "moviestore_api" {
  metadata {
    name = "moviestore-api"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "moviestore-api"
      }
    }

    template {
      metadata {
        labels = {
          app = "moviestore-api"
        }
      }

      spec {
        container {
          name  = "moviestore-api"
          image = "ranyqb/moviestoreapi:2.0.0"

          port {
            container_port = 8080
          }

          port {
            container_port = 8081
          }

          resources {
            requests {
              cpu    = "200m"
              memory = "300Mi"
            }
            limits {
              memory = "400Mi"
            }
          }

          env {
            name  = "MSSQL_TCP_PORT"
            value = "1433"
          }

          env {
            name  = "MSSQL_SA_PASSWORD"
            value_from {
              secret_key_ref {
                name = "mssqlpassword"
                key  = "MSSQLPASSWORD"
              }
            }
          }

          env {
            name  = "ACCEPT_EULA"
            value = "Y"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "moviestore_api" {
  metadata {
    name = "moviestore-api"
  }

  spec {
    selector = {
      app = "moviestore-api"
    }

    port {
      name       = "http"
      protocol   = "TCP"
      port       = 8080
      target_port = 8080
    }

    port {
      name       = "https"
      protocol   = "TCP"
      port       = 8081
      target_port = 8081
    }

    type = "ClusterIP"
  }
}