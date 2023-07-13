variable "dataset_name" {
  description = "The name of the dataset where columns will need to be created"
  type        = string
}

variable "columns" {
  description = "The list of columns being created as a map object with the key being the column name and value being the column type"
  type = list(object({
    name        = string
    type        = string
    description = string
  }))
}
