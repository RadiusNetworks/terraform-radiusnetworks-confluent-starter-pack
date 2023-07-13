data "honeycombio_query_specification" "consumer_group_lag" {
  calculation {
    op     = "AVG"
    column = "kafka.consumer_group.lag"
  }

  filter {
    column = "kafka.consumer_group.lag"
    op     = "exists"
  }

  breakdowns = ["group", "topic", "partition"]
  time_range = var.time_range
}

resource "honeycombio_query" "consumer_group_lag" {
  dataset    = var.dataset_name
  query_json = data.honeycombio_query_specification.consumer_group_lag.json
}

resource "honeycombio_query_annotation" "consumer_group_lag" {
  dataset     = var.dataset_name
  query_id    = honeycombio_query.consumer_group_lag.id
  name        = "Consumer Group Lag"
  description = "Current approximate lag of consumer group at partition of topic"
}

output "consumer_group_lag_query_id" {
  value = honeycombio_query.consumer_group_lag.id
}

output "consumer_group_lag_query_annotation_id" {
  value = honeycombio_query_annotation.consumer_group_lag.id
}
