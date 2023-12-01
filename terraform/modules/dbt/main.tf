resource "kubernetes_secret_v1" "git_credentials" {
  metadata {
    name = "git-credentials"
    namespace = var.namespace
  }
  data = {
    "ssh": base64encode(jsonencode(data.sops_file.git_sync_secret.data["ssh-key-file"]))
    "known_hosts": base64encode(jsonencode(data.sops_file.git_sync_secret.data["known-hosts"]))
  }
}

resource "kubernetes_deployment_v1" "my_finances_dbt_deployment" {
  metadata {
    name = "${var.namespace}-dbt"
    namespace = var.namespace
    labels = {
      "app.kubernetes.io/name": var.namespace,
      "app.kubernetes.io/component": "dbt"
    }
  }
  spec {
    replicas = "1"
    selector {
      match_labels = {"app.kubernetes.io/name": var.namespace}
    }
    template {
      metadata {
        labels = {
          "app.kubernetes.io/name": var.namespace,
          "app.kubernetes.io/component": "dbt"
        }
      }
      spec {
        volume {
          name = "git-sync-content"
        }
        volume {
          name = "git-sync-secret"
          secret {
            secret_name = kubernetes_secret_v1.git_credentials.metadata.0.name
            default_mode = "0400"
          }
        }

        init_container {
          name = "dbt-repo-setup"
          image = var.git_sync_image
          args = [
            "--repo=${var.git_sync_git_repo}",
            "--branch=master",
            "--depth=1",
            "--max-failures=6",
            "--one-time=true",  # exit after the first sync (we just want to initialize the file system)
            "--period=10s",
            "--root=/git",
            "--ssh=true",
            "--ssh-known-hosts=true"
          ]
          security_context {
            run_as_user = "65533" # git-sync-user
          }
          volume_mount {
            mount_path = "/git"
            name       = "git-sync-content"
          }
          volume_mount {
            mount_path = "/etc/git-secret"
            name       = "git-sync-secret"
            read_only = true
          }
        }

        container {
          name  = "dbt"
          image = var.dbt_image
          image_pull_policy = "IfNotPresent"
          port {
            container_port = 8080
            name           = "docs-port"
          }

          env {
            name = "POSTGRES_PASSWORD"
            value_from {
              secret_key_ref {
                name = var.postgres_secrets_name
                key = "password"
              }
            }
          }
          env {
            name = "POSTGRES_USER"
            value_from {
              secret_key_ref {
                name = var.postgres_secrets_name
                key = "user"
              }
            }
          }
          env {
            name = "POSTGRES_DB"
            value_from {
              secret_key_ref {
                name = var.postgres_secrets_name
                key = "db"
              }
            }
          }
          env {
            name = "POSTGRES_HOST"
            value = var.postgres_service_name
          }

          volume_mount {
            mount_path = "/usr/app"
            name       = "git-sync-content"
            sub_path   = var.git_sync_path_to_dbt
          }
          volume_mount {
            mount_path = "/root/.dbt/profiles.yml"
            name       = "git-sync-content"
            sub_path   = var.git_sync_path_to_dbt_profiles
            read_only = true
          }
        }

        container {
          name = "git-sync"
          image = var.git_sync_image
          args = [
            "--repo=${var.git_sync_git_repo}",
            "--branch=master",
            "--depth=1",
            "--max-failures=-1",
            "--period=60s",
            "--root=/git",
            "--add-user",
            "--ssh",
            "--ssh-known-hosts"
          ]
          security_context {
            run_as_user = "65533" # git-sync-user
          }
          volume_mount {
            mount_path = "/git"
            name       = "git-sync-content"
          }
          volume_mount {
            mount_path = "/etc/git-secret"
            name       = "git-sync-secret"
            read_only = true
          }
        }

        security_context {
          fs_group = "65533" # git-sync-user
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "my_finances_dbt_service" {
  metadata {
    name = "${var.namespace}-dbt"
    namespace = var.namespace
    labels = {
      "app.kubernetes.io/name": var.namespace,
      "app.kubernetes.io/component": "dbt"
    }
  }
  spec {
    type = "NodePort"
    port {
      name = "http"
      port = 80
      target_port = "docs-port"
    }
    selector = {
      "app.kubernetes.io/name": var.namespace
    }
  }
}