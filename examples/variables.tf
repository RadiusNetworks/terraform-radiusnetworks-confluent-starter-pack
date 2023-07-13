variable "confluent_cloud_api_key" {
  type        = string
  sensitive   = true
  description = <<EOF
$ export TF_VAR_confluent_cloud_api_key=<secret>
EOF
}

variable "confluent_cloud_api_secret" {
  type        = string
  sensitive   = true
  description = <<EOF
$ export TF_VAR_confluent_cloud_api_secret=<secret>
EOF
}

variable "honeycomb_api_key" {
  type        = string
  description = <<EOF
Honeycomb API key

$ export TF_VAR_honeycomb_api_key=<secret>
EOF
  default = ""
}
