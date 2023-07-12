####################################################
# Providers
####################################################

provider "confluent" {
  cloud_api_key    = var.confluent_cloud_api_key
  cloud_api_secret = var.confluent_cloud_api_secret
}

provider "honeycombio" {
  api_key = var.honeycomb_api_key
}

####################################################
# Local
####################################################

locals {
  confluent_metrics_dataset_name = "example-confluent-metrics"
  kafka_metrics_dataset_name     = "example-kafka-metrics"
}

####################################################
# Setup Confluent Cluster
####################################################

resource "confluent_environment" "main" {
  display_name = "terraform-confluent-starter-pack"
}

resource "confluent_kafka_cluster" "main" {
  display_name = "terraform-confluent-starter-pack"
  availability = "SINGLE_ZONE"
  cloud        = "AWS"
  region       = "us-east-2"
  basic {}

  environment {
    id = confluent_environment.main.id
  }
}

resource "confluent_kafka_topic" "example" {
  topic_name         = "examples"

  kafka_cluster {
    id = confluent_kafka_cluster.main.id
  }
  credentials {
    key    = confluent_api_key.tf_kafka_manager.id
    secret = confluent_api_key.tf_kafka_manager.secret
  }
  rest_endpoint = confluent_kafka_cluster.main.rest_endpoint
}

####################################################
# Setup Honeycomb Datasets and Dashboards
####################################################

module "radiusnetworks_confluent_starter_pack" {
  source = "../"

  confluent_metrics_dataset_name = local.confluent_metrics_dataset_name # Optional: Defaults to confluent-metrics
  kafka_metrics_dataset_name     = local.kafka_metrics_dataset_name     # Optional: Defaults to kafka-metrics

  create_datasets = true  # Optional: defaults to false
  create_columns  = true  # Optional: defaults to false
  time_range      = 86400 # Optional: defaults to 86400 (24 hours)
}

####################################################
# Generate Otel Config for Docker Compose
####################################################

locals {
  otel_collector_config = templatefile("./templates/config.yaml",
    {
      honeycomb_api_key    = var.honeycomb_api_key

      # prometheus/confluent
      confluent_metrics_api_key_id     = confluent_api_key.monitoring.id
      confluent_metrics_api_key_secret = confluent_api_key.monitoring.secret
      confluent_metrics_dataset_name   = local.confluent_metrics_dataset_name
      confluent_kafka_cluster_id       = confluent_kafka_cluster.main.id

      # kafkametrics
      kafka_api_key_id           = confluent_api_key.kafka_monitoring.id
      kafka_api_key_secret       = confluent_api_key.kafka_monitoring.secret
      kafka_metrics_dataset_name = local.kafka_metrics_dataset_name
      kafka_bootstrap_endpoint   = trimprefix(confluent_kafka_cluster.main.bootstrap_endpoint, "SASL_SSL://")
    }
  )
}

resource "local_file" "otel_config" {
  content  = local.otel_collector_config
  filename = "config.yaml"
}
