terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    # Used once, to read the real TLS (Transport Layer Security)
    # certificate of the cluster's OIDC (OpenID Connect) endpoint, so its
    # exact thumbprint does not have to be typed in by hand.
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}
