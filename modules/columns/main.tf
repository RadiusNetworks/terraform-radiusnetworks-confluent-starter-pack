resource "honeycombio_column" "columns" {
  for_each = {
    for i, column in var.columns : column.name => column
  }
  name        = each.value.name
  type        = each.value.type
  description = each.value.description == "" ? null : each.value.description
  dataset     = var.dataset_name
}
