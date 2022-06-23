# https://access.crunchydata.com/documentation/postgres-operator/v5/tutorial/create-cluster/

locals {
  dbname = "testing"
  postgresVersion = 13
  # https://www.crunchydata.com/developers/download-postgres/containers
  images = {
    postgres   = "registry.developers.crunchydata.com/crunchydata/crunchy-postgres:ubi8-13.7-0"
    pgbackrest = "registry.developers.crunchydata.com/crunchydata/crunchy-pgbackrest:ubi8-2.38-1"
    pgbouncer  = "registry.developers.crunchydata.com/crunchydata/crunchy-pgbouncer:ubi8-1.16-3"
  }
}

resource "kubernetes_manifest" "database" {
  depends_on = [
    module.postgres-operator
  ]

  manifest = {
    "apiVersion" = "postgres-operator.crunchydata.com/v1beta1"
    "kind"       = "PostgresCluster"
    "metadata" = {
      "name"      = "testpostgres"
      "namespace" = "default"
    }
    "spec" = {
      "databaseInitSQL" = {
        "name" = kubernetes_config_map.postgres_init.metadata[0].name
        "key"  = "init.sql"
      }

      # https://access.crunchydata.com/documentation/postgres-operator/5.0.4/tutorial/user-management/
      "users" = [
        {
          # "postgres" is the default superuser
          name = "postgres"
        },
        {
          name      = "test"
          databases = [local.dbname]
        },
      ]

      "backups" = {
        "pgbackrest" = {
          "image" = local.images.pgbackrest
          "repos" = [
            {
              "name" = "repo1"
              "volume" = {
                "volumeClaimSpec" = {
                  "accessModes" = ["ReadWriteOnce"]
                  "resources" = {
                    "requests" = {
                      "storage" = "1Gi"
                    }
                  }
                }
              }
            },
          ]
        }
      }

      "image" = local.images.postgres
      "instances" = [
        {
          "dataVolumeClaimSpec" = {
            "accessModes" = [
              "ReadWriteOnce",
            ]
            "resources" = {
              "requests" = {
                "storage" = "1Gi"
              }
            }
          }
          "name"     = "testpostgres-1"
          "replicas" = 2
        },
      ]
      "postgresVersion" = local.postgresVersion
      "proxy" = {
        "pgBouncer" = {
          "image"    = local.images.pgbouncer
          "replicas" = 2
        }
      }
    }
  }
}

resource "kubernetes_config_map" "postgres_init" {
  metadata {
    name = "postgres-init"
  }

  # doc for "\c dbname": https://www.postgresql.org/docs/13/app-psql.html
  data = {
    "init.sql" = <<-EOF
      \set ON_ERROR_STOP
      \c ${local.dbname}
      CREATE EXTENSION IF NOT EXISTS postgis;
      \echo 'Created postgis extension(s) for ${local.dbname}'
    EOF
  }
}
