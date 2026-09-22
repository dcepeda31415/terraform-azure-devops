variable "location" {
  type    = string
  default = "westeurope"
}

variable "address_space" {
  type    = list(string)
  default = ["10.30.0.0/16"]
}
