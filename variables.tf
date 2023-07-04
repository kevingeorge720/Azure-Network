variable "resource_group_name" {
    type        = string 
    description = "name of resource of group"
    default     = "my-resource-group"
}

variable "location" {
    type        = string 
    description = "location of resource of group"
    default     = "West US"
}

variable "subnets" {
  type    = map(any)
  default   = {
    "web-app-subnet"      = { cidr = "10.0.1.0/24", delegated = true }
    "private-endpoint"    = { cidr = "10.0.2.0/24", delegated = false }
  }
}