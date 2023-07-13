variable "dataset_name" {
  description = "The name of the dataset where columns will need to be created"
  type        = string
}

variable "time_range" {
  description = "The default time range for queries in the Refinery metrics board - Defaults to 86400 seconds (24hours)"
  type        = number
  default     = 86400
}
