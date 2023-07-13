####################################################
# Create Datasets to Contain all Required Columns
####################################################

resource "honeycombio_dataset" "confluent_metrics_dataset" {
  count       = var.create_datasets ? 1 : 0
  name        = var.confluent_metrics_dataset_name
  description = "Dataset for Confluent metrics"
}

resource "honeycombio_dataset" "kafka_metrics_dataset" {
  count       = var.create_datasets ? 1 : 0
  name        = var.kafka_metrics_dataset_name
  description = "Dataset for Confluent metrics"
}

####################################################
# Create Columns in the Datasets
####################################################

module "confluent_metrics_columns" {
  source       = "./modules/columns"
  count        = var.create_columns ? 1 : 0
  dataset_name = var.confluent_metrics_dataset_name
  columns = [
    {
      name        = "confluent_kafka_server_active_connection_count"
      type        = "integer"
      description = "The count of active authenticated connections."
    },
    {
      name        = "confluent_kafka_server_consumer_lag_offsets"
      type        = "integer"
      description = "The lag between a group member's committed offset and the partition's high watermark."
    },
    {
      name        = "confluent_kafka_server_partition_count"
      type        = "integer"
      description = "The number of partitions."
    },
    {
      name        = "confluent_kafka_server_request"
      type        = "integer"
      description = ""
    },
    {
      name        = "confluent_kafka_server_request_count"
      type        = "integer"
      description = ""
    },
    {
      name        = "confluent_kafka_server_response"
      type        = "integer"
      description = ""
    },
    {
      name        = "confluent_kafka_server_retained"
      type        = "integer"
      description = "The current count of bytes retained by the cluster. The count is sampled every 60 seconds."
    },
    {
      name        = "confluent_kafka_server_sent"
      type        = "integer"
      description = "The delta count of bytes of the customer's data sent over the network. The count is sampled every 60 seconds."
    },
    {
      name        = "confluent_kafka_server_sent_records"
      type        = "integer"
      description = "The delta count of records sent. The count is sampled every 60 seconds."
    },
    {
      name        = "confluent_kafka_server_successful_authentication_count"
      type        = "integer"
      description = "The delta count of successful authentications. The count sampled every 60 seconds."
    },
    {
      name        = "consumer_group_id"
      type        = "string"
      description = "The ID of the consumer group"
    },
    {
      name        = "http.scheme"
      type        = "string"
      description = ""
    },
    {
      name        = "kafka_id"
      type        = "string"
      description = "ID of the Kafka cluster"
    },
    {
      name        = "net.host.name"
      type        = "string"
      description = ""
    },
    {
      name        = "net.host.port"
      type        = "string"
      description = ""
    },
    {
      name        = "principal_id"
      type        = "string"
      description = "The authentication principal (Confluent Cloud User or Service Account)"
    },
    {
      name        = "scrape_duration"
      type        = "float"
      description = "The length of time to scrape Conlfuent Cloud metrics endpoint"
    },
    {
      name        = "scrape_samples_post_metric_relabeling"
      type        = "integer"
      description = ""
    },
    {
      name        = "scrape_samples_scraped"
      type        = "integer"
      description = ""
    },
    {
      name        = "scrape_series_added"
      type        = "integer"
      description = ""
    },
    {
      name        = "service.instance.id"
      type        = "string"
      description = ""
    },
    {
      name        = "service.name"
      type        = "string"
      description = ""
    },
    {
      name        = "topic"
      type        = "string"
      description = "Name of the Kafka topic"
    },
    {
      name        = "type"
      type        = "string"
      description = "The Kafka protocol request type (defined in https://kafka.apache.org/protocol#protocol_api_keys)."
    },
    {
      name        = "up"
      type        = "integer"
      description = "1 if the intance is healthy or 0 if the scrape failed."
    },
  ]

  depends_on = [
    honeycombio_dataset.confluent_metrics_dataset
  ]
}

module "kafka_metrics_columns" {
  source       = "./modules/columns"
  count        = var.create_columns ? 1 : 0
  dataset_name = var.kafka_metrics_dataset_name
  columns = [
    {
      name        = "group"
      type        = "string"
      description = "The ID (string) of a consumer group"
    },
    {
      name        = "kafka.brokers"
      type        = "integer"
      description = "Number of brokers in the cluster."
    },
    {
      name        = "kafka.consumer_group.lag"
      type        = "integer"
      description = "Current approximate lag of consumer group at partition of topic"
    },
    {
      name        = "kafka.consumer_group.lag_sum"
      type        = "integer"
      description = "Current approximate sum of consumer group lag across all partitions of topic"
    },
    {
      name        = "kafka.consumer_group.members"
      type        = "integer"
      description = "Count of members in the consumer group"
    },
    {
      name        = "kafka.consumer_group.offset"
      type        = "integer"
      description = "Current offset of the consumer group at partition of topic"
    },
    {
      name        = "kafka.consumer_group.offset_sum"
      type        = "integer"
      description = "Sum of consumer group offset across partitions of topic"
    },
    {
      name        = "kafka.partition.current_offset"
      type        = "integer"
      description = "Current offset of partition of topic."
    },
    {
      name        = "kafka.partition.oldest_offset"
      type        = "integer"
      description = "Oldest offset of partition of topic"
    },
    {
      name        = "kafka.partition.replicas"
      type        = "integer"
      description = "Number of replicas for partition of topic"
    },
    {
      name        = "kafka.partition.replicas_in_sync"
      type        = "integer"
      description = "Number of synchronized replicas of partition"
    },
    {
      name        = "kafka.topic.partitions"
      type        = "integer"
      description = "Number of partitions in topic."
    },
    {
      name        = "partition"
      type        = "integer"
      description = "The number (integer) of the partition"
    },
    {
      name        = "topic"
      type        = "string"
      description = "The ID (integer) of a topic"
    },
  ]

  depends_on = [
    honeycombio_dataset.kafka_metrics_dataset
  ]
}

####################################################
# Create Queries
####################################################

module "kafka_metrics_queries" {
  source       = "./modules/kafka_queries"
  dataset_name = var.kafka_metrics_dataset_name

  depends_on = [
    honeycombio_dataset.kafka_metrics_dataset,
    module.kafka_metrics_columns
  ]
}

####################################################
# Create Confluent Kafka Board
####################################################

resource "honeycombio_board" "confluent_kafka" {
  name  = "Confluent Kafka Operations"
  style = "visual"
  query {
    query_id            = module.kafka_metrics_queries.consumer_group_lag_query_id
    query_annotation_id = module.kafka_metrics_queries.consumer_group_lag_query_annotation_id
  }
  query {
    query_id            = module.kafka_metrics_queries.consumer_group_lag_sum_query_id
    query_annotation_id = module.kafka_metrics_queries.consumer_group_lag_sum_query_annotation_id
  }
}
