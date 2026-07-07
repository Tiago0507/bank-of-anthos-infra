terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    # Used once, to read the real TLS (Transport Layer Security) certificate
    # served by GitHub's OIDC (OpenID Connect) issuer, so its exact
    # thumbprint does not have to be typed in by hand.
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}
