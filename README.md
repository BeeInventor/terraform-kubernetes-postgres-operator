- CRD Reference: https://access.crunchydata.com/documentation/postgres-operator/v5/references/crd/

- Crunchy PostGIS Dockerfile: https://github.com/CrunchyData/crunchy-containers/blob/master/build/postgres-gis/Dockerfile
- TimescaleDB Dockerfile: https://github.com/timescale/timescaledb-docker/blob/master/Dockerfile



# Generate tf from k8s

```
go install github.com/jrhouston/tfk8s@latest
tfk8s -f submodules/postgres-operator/kustomize/high-availability/ha-postgres.yaml -o postgres.tf
```