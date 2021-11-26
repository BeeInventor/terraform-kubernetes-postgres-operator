data "kustomization_build" "postgres_operator" {
  path = "${path.module}/submodules/postgres-operator/kustomize/install"
}

resource "kustomization_resource" "postgres_operator_p0" {
  for_each = data.kustomization_build.postgres_operator.ids_prio[0]

  manifest = data.kustomization_build.postgres_operator.manifests[each.value]
}

resource "kustomization_resource" "postgres_operator_p1" {
  for_each = data.kustomization_build.postgres_operator.ids_prio[1]

  manifest = data.kustomization_build.postgres_operator.manifests[each.value]

  depends_on = [kustomization_resource.postgres_operator_p0]
}

resource "kustomization_resource" "postgres_operator_p2" {
  for_each = data.kustomization_build.postgres_operator.ids_prio[2]

  manifest = data.kustomization_build.postgres_operator.manifests[each.value]

  depends_on = [kustomization_resource.postgres_operator_p1]
}