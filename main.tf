terraform {
  experiments      = [module_variable_optional_attrs]
  required_version = "~> 1.0"
  required_providers {
    kustomization = {
      source  = "kbst/kustomization"
      version = "~> 0.7"
    }
  }
}
