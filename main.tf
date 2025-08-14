terraform {
  required_providers {
    kind = {
      source = "tehcyx/kind"
      version = "0.9.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.19.0"
    }
    helm = {
      source = "hashicorp/helm"
      version = "3.0.2"
    }
  }
}

provider "kind" {}

locals {
    k8s_config_path = pathexpand(".")
}

resource "kind_cluster" "default" {
  name = var.cluster_name
  wait_for_ready = true
  kind_config {
    kind = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    node {
      role = "control-plane"
      extra_port_mappings {
        container_port = 80
        host_port      = 80
      }
      extra_port_mappings {
        container_port = 443
        host_port      = 443
      }

      extra_mounts {
        host_path      = "${path.root}"
        container_path = "/mnt/local-repo.git"
        read_only      = true
      }
    }
    
    node {
      role = "worker"
      extra_mounts {
        host_path      = "${path.root}"
        container_path = "/mnt/local-repo.git"
        read_only      = true
      }

    }
  }
}

provider "kubectl" {
  host                   = kind_cluster.default.endpoint
  cluster_ca_certificate = kind_cluster.default.cluster_ca_certificate
  client_certificate     = kind_cluster.default.client_certificate
  client_key             = kind_cluster.default.client_key
  load_config_file       = false
}

provider "helm" {
  kubernetes = {
    host                   = kind_cluster.default.endpoint
    cluster_ca_certificate = kind_cluster.default.cluster_ca_certificate
    client_certificate     = kind_cluster.default.client_certificate
    client_key             = kind_cluster.default.client_key
  }
}

resource "helm_release" "argocd" {
  name  = "argocd"
  depends_on = [kind_cluster.default]

  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  version          = "8.2.5"
  create_namespace = true

  values = [
    file("argocd/argocd-server.yaml")
  ]

resource "helm_release" "argocd-apps" {
  name  = "argocd-apps"

  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argocd-apps"
  namespace        = "argocd"
  version          = "2.0.2"

  values = [
    file("argocd/application.yaml")
  ]

  depends_on = [helm_release.argocd]
}

#data "kubectl_file_documents" "local-repo" {
#  content = file("argocd/local-repo-secret.yaml")
#  depends_on = [helm_release.argocd]
#}

#resource "kubectl_manifest" "local_repo_apply" {
#  for_each          = data.kubectl_file_documents.local-repo.manifests
#  yaml_body         = each.value
#  wait              = true
#  server_side_apply = true
#}

#resource "kubernetes_manifest" "local_repo_secret" {
#  manifest = {
#    apiVersion = "v1"
#    kind       = "Secret"
#    metadata = {
#      name      = "local-repo"
#      namespace = "argocd"
#      labels = {
#        "argocd.argoproj.io/secret-type" = "repository"
#      }
#      annotations = {
#        "managed-by" = "argocd.argoproj.io"
#      }
#    }
#    type = "Opaque"
#   stringData = {
#      type = "git"
#      name = "local-repo"
#      url  = "file:///mnt/local-repo.git"
#    }
#  }
#
#  depends_on = [helm_release.argocd]
#}
