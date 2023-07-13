variable "confluent_metrics_dataset_name" {
  description = "The name of the Confluent metrics dataset."
  type        = string
  default     = "confluent-metrics"
}

variable "kafka_metrics_dataset_name" {
  description = "The name of the Kafka metrics dataset."
  type        = string
  default     = "confluent-metrics"
}

variable "create_datasets" {
  description = "When set to true two datasets, confluent-metrics and kafka-metrics, will be created. Default is false."
  type        = bool
  default     = false
}

variable "create_columns" {
  description = "When set to true the columns will be created. Default is false."
  type        = bool
  default     = false
}

variable "time_range" {
  description = "The default time range for queries in the Refinery metrics board - Defaults to 86400 seconds (24hours)"
  type        = number
  default     = 86400
}
