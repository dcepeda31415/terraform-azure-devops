variable "location" {
  type    = string
  default = "westeurope"
}

variable "address_space" {
  type    = list(string)
  default = ["10.10.0.0/16"]
}
