variable "waf_name"{
    type = string
    description = "Name of WAF"
}
variable "tags" {
  type        = map(string)
  description = "Tags to be added to the resource"
}
variable "load_balancer_name" {
  type=string
  description = "Application Load Balancer Name"
}