terraform {
  required_version = ">= 1.7.0"
  required_providers {
    honeycombio = {
      source  = "honeycombio/honeycombio"
      version = ">= 0.22.0"
    }
  }
}
