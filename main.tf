terraform {
  required_version = ">= 0.13.1"

  required_providers {
    shoreline = {
      source  = "shorelinesoftware/shoreline"
      version = ">= 1.11.0"
    }
  }
}

provider "shoreline" {
  retries = 2
  debug = true
}

module "kafka_high_watermark_lag_incident" {
  source    = "./modules/kafka_high_watermark_lag_incident"

  providers = {
    shoreline = shoreline
  }
}