terraform {
required_version = ">= 1.6.3"

  backend "s3" {
    endpoints = {
      s3 = "${var.do_s3_endpoint_url}"
    }

    bucket = var.state_bucket
    key    = var.state_file_name

    # Deactivate a few AWS-specific checks
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_s3_checksum            = true
    region                      = "nyc3"
  }
}
