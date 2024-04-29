resource "kubernetes_persistent_volume_claim" "database_pvc" {
  metadata {
    name = "database-persistent-volume-claim"
  }

  spec {
    access_modes = ["ReadWriteMany"]
    resources {
      requests = {
        storage = "1Gi"
      }
    }
  }
}