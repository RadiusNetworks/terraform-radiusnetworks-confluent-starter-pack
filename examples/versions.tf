terraform {
  required_version = "~> 1.5.0"

  required_providers {
    confluent = {
      source = "confluentinc/confluent"
      version = ">= 1.48.0"
    }
    honeycombio = {
      source  = "honeycombio/honeycombio"
      version = ">= 0.15.1"
    }
  }
}
