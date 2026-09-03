resource "aws_secretsmanager_secret" "ghcr" {
  name                    = "${var.project_name}/ghcr"
  description             = "GHCR pull credentials for the microservices platform"
  recovery_window_in_days = 7

  lifecycle {
    prevent_destroy = true
  }
}
