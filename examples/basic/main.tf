terraform {
  required_version = ">= 0.13"

  required_providers {
    kustomization = {
      source  = "kbst/kustomization"
      version = "~> 0.7"
    }
  }
}

module "postgres-operator" {
  source = "../.."
}