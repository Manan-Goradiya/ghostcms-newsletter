variable "role_name" {
  description = "Name of the IAM role"
  type        = string
}

variable "assume_role_policy" {
  description = "IAM assume role policy"
  type        = string
}
variable "tags" {
  type        = map(string)
  description = "Tags to be added to the resource"
}
variable "custom_policies" {
  description = "Map of custom policies to attach"
  type        = map(string)
  default     = {}
}
variable "managed_policy_arns" {
  description = "List of managed policy ARNs to attach to the role"
  type        = list(string)
  default     = []
}