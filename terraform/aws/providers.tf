provider "aws" {
  region = var.aws_region

  default_tags {
    tags = merge(var.tags, {
      Project     = var.name
      ManagedBy   = "terraform"
      Environment = "experiment"
    })
  }
}

