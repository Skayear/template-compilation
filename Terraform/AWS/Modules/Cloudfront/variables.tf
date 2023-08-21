# Budgets_cost

variable "name" {
  default = ""
}
variable "budget_type" {
  default = ""
}
variable "limit_amount" {
  default = ""
}
variable "limit_unit" {
  default = ""
}
variable "time_unit" {
  default = ""
}

# Tags

variable "env_name" {
  default = ""
}
variable "application_name" {
  default = ""
}

# Notification

variable "comparison_operator" {
  default = ""
}
variable "threshold" {
  default = ""
}
variable "threshold_type" {
  default = ""
}
variable "notification_type" {
  default = ""
}

variable "subscriber_email_addresses" {
  default = ""
}

variable "subscriber_sns_topic_arns" {
  default = ""
}




variable "name_sns_topic" {
  default = ""
}

variable "region" {
  default = ""
}

variable "account_id" {
  default = ""
}