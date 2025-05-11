variable "load_balancer_hostname" {
    type        = string
    description = "The hostname of the load balancer"
}
variable "alb_origin" {
    type        = string
    description = "The origin domain name for the load balancer"
}

variable "s3_origin" {
    type        = string
    description = "The origin domain name for the S3 bucket"
}

variable "aliases" {
    type        = list(string)
    description = "A list of aliases for the CloudFront distribution"
}