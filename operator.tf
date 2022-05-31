module "crds" {
  source = "./crds"
}

resource "helm_release" "main" {
  # repository = 
  namespace  = var.namespace
  name       = var.name
  chart      = "${path.module}/submodules/postgres-operator/helm/install"
  values = [
    yamlencode(var.values),
  ]

  skip_crds = true

  depends_on = [
    module.crds
  ]
}
