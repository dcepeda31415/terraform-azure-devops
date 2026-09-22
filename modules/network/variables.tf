variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "environment" { type = string }
variable "address_space" { type = list(string) }
variable "log_analytics_workspace_id" { type = string }
variable "tags" { type = map(string); default = {} }
