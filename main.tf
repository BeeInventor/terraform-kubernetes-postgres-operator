terraform {
  required_version = ">= 1.3.0"
  required_providers {
    kustomization = {
      source  = "kbst/kustomization"
      version = "~> 0.7"
    }
  }
}
