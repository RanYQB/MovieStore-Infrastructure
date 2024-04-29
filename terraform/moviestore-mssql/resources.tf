resource "kubernetes_deployment" "sqlserver" {
  metadata {
    name = "sqlserver"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "sqlserver"
      }
    }

    template {
      metadata {
        labels = {
          app = "sqlserver"
        }
      }

      spec {
        volume {
          name = "mssql-storage"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.database_pvc.metadata.0.name
          }
        }

        container {
          name  = "sqlserver"
          image = "mcr.microsoft.com/mssql/server:2022-latest"

          port {
            container_port = 1433
          }

          volume_mount {
            name       = "mssql-storage"
            mount_path = "/var/opt/mssql/data"
            sub_path   = "mssql"
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

resource "kubernetes_service" "sqlserver" {
  metadata {
    name = "sqlserver"
  }

  spec {
    selector = {
      app = "sqlserver"
    }

    port {
      protocol   = "TCP"
      port       = 1433
      target_port = 1433
    }

    type = "ClusterIP"
  }
}