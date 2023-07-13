#############################
## Terraform Kafka Manager ##
#############################

# app-manager service account is required to create topics and grant
# ACLs in the Kafka cluster.

resource "confluent_service_account" "tf_kafka_manager" {
  display_name = "tf-starter-pack-terraform-kafka-manager"
  description  = "Service account for Terraform to manage Kafka clusters"
}

resource "confluent_role_binding" "tf_kafka_manager_cluster_admin" {
  principal   = "User:${confluent_service_account.tf_kafka_manager.id}"
  role_name   = "CloudClusterAdmin"
  crn_pattern = confluent_kafka_cluster.main.rbac_crn
}

resource "confluent_api_key" "tf_kafka_manager" {
  display_name = "tf-starter-pack-app-manager"
  description  = "Owned by 'app-manager' service account"
  owner {
    id          = confluent_service_account.tf_kafka_manager.id
    api_version = confluent_service_account.tf_kafka_manager.api_version
    kind        = confluent_service_account.tf_kafka_manager.kind
  }

  managed_resource {
    id          = confluent_kafka_cluster.main.id
    api_version = confluent_kafka_cluster.main.api_version
    kind        = confluent_kafka_cluster.main.kind

    environment {
      id = confluent_environment.main.id
    }
  }

  depends_on = [
    confluent_role_binding.tf_kafka_manager_cluster_admin
  ]
}


###############################
## Confluent Metrics API Key ##
###############################

/*
  Used to collect metrics from Confluent Cloud. Does not
  support colllecting metrics from Kafka nodes.
*/

resource "confluent_service_account" "monitoring" {
  display_name = "tf-starter-pack-monitoring"
  description  = "Service Account Monitoring Confluent Metrics"
}

resource "confluent_role_binding" "monitoring_metrics_viewer" {
  principal   = "User:${confluent_service_account.monitoring.id}"
  role_name   = "MetricsViewer"
  crn_pattern = confluent_kafka_cluster.main.rbac_crn
}

resource "confluent_api_key" "monitoring" {
  display_name = "tf-starter-pack-monitoring"
  description  = "Owned by the monitoring service account"

  owner {
    id          = confluent_service_account.monitoring.id
    api_version = confluent_service_account.monitoring.api_version
    kind        = confluent_service_account.monitoring.kind
  }
}

########################################
## OpenTelemetry kafkametrics API Key ##
########################################

/*

  Used to collect metrics from Kafka. Different from the
  Confluent monitoring API Key. This API key has access
  to Kafka whereas the Confluent monitoring API key has
  access to Confluent Cloud metrics API.

*/

resource "confluent_service_account" "kafka_monitoring" {
  display_name = "tf-starter-pack-kafka-monitoring"
  description  = "Service Account Monitoring Kafka Cluster"
}

resource "confluent_kafka_acl" "kafka_monitoring_describe_cluster" {
  kafka_cluster {
    id = confluent_kafka_cluster.main.id
  }
  credentials {
    key    = confluent_api_key.tf_kafka_manager.id
    secret = confluent_api_key.tf_kafka_manager.secret
  }
  rest_endpoint = confluent_kafka_cluster.main.rest_endpoint

  resource_type = "CLUSTER"
  pattern_type  = "LITERAL"
  resource_name = "kafka-cluster"
  principal     = "User:${confluent_service_account.kafka_monitoring.id}"
  permission    = "ALLOW"
  operation     = "DESCRIBE"
  host          = "*"
}

resource "confluent_kafka_acl" "kafka_monitoring_describe_group" {
  kafka_cluster {
    id = confluent_kafka_cluster.main.id
  }
  credentials {
    key    = confluent_api_key.tf_kafka_manager.id
    secret = confluent_api_key.tf_kafka_manager.secret
  }
  rest_endpoint = confluent_kafka_cluster.main.rest_endpoint

  resource_type = "GROUP"
  pattern_type  = "LITERAL"
  resource_name = "*"
  principal     = "User:${confluent_service_account.kafka_monitoring.id}"
  permission    = "ALLOW"
  operation     = "DESCRIBE"
  host          = "*"
}

resource "confluent_kafka_acl" "kafka_monitoring_describe_topic" {
  kafka_cluster {
    id = confluent_kafka_cluster.main.id
  }
  credentials {
    key    = confluent_api_key.tf_kafka_manager.id
    secret = confluent_api_key.tf_kafka_manager.secret
  }
  rest_endpoint = confluent_kafka_cluster.main.rest_endpoint

  resource_type = "TOPIC"
  pattern_type  = "LITERAL"
  resource_name = "*"
  principal     = "User:${confluent_service_account.kafka_monitoring.id}"
  permission    = "ALLOW"
  operation     = "DESCRIBE"
  host          = "*"
}

resource "confluent_api_key" "kafka_monitoring" {
  display_name = "tf-starter-pack-kafka-monitoring"
  description  = "Owned by the Kafka monitoring service account"
  owner {
    id          = confluent_service_account.kafka_monitoring.id
    api_version = confluent_service_account.kafka_monitoring.api_version
    kind        = confluent_service_account.kafka_monitoring.kind
  }

  managed_resource {
    id          = confluent_kafka_cluster.main.id
    api_version = confluent_kafka_cluster.main.api_version
    kind        = confluent_kafka_cluster.main.kind

    environment {
      id = confluent_environment.main.id
    }
  }
}
