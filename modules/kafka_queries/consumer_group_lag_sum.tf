data "honeycombio_query_specification" "consumer_group_lag_sum" {
  calculation {
    op     = "AVG"
    column = "kafka.consumer_group.lag_sum"
  }

  filter {
    column = "kafka.consumer_group.lag_sum"
    op     = "exists"
  }

  breakdowns = ["group", "topic"]
  time_range = var.time_range
}

resource "honeycombio_query" "consumer_group_lag_sum" {
  dataset    = var.dataset_name
  query_json = data.honeycombio_query_specification.consumer_group_lag_sum.json
}

resource "honeycombio_query_annotation" "consumer_group_lag_sum" {
  dataset     = var.dataset_name
  query_id    = honeycombio_query.consumer_group_lag_sum.id
  name        = "Consumer Group Lag Sum"
  description = "Current approximate sum of consumer group lag across all partitions of topic"
}

output "consumer_group_lag_sum_query_id" {
  value = honeycombio_query.consumer_group_lag_sum.id
}

output "consumer_group_lag_sum_query_annotation_id" {
  value = honeycombio_query_annotation.consumer_group_lag_sum.id
}
