# Create a new Auth0 application for OIDC authentication
resource "auth0_client" "oidc_client" {
  name                = "MyCoolApp"
  description         = "My Cool App Client Created Through Terraform"
  app_type            = "regular_web"
  callbacks           = ["http://localhost:8080/callback"]
  allowed_logout_urls = ["http://localhost:8080"]
  oidc_conformant     = true

  jwt_configuration {
    alg = "RS256"
  }
}

# Configuring client_secret_post as an authentication method.
resource "auth0_client_credentials" "oidc_client_creds" {
  client_id = auth0_client.oidc_client.id
  authentication_method = "client_secret_post"
}