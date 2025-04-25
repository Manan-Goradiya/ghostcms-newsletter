variable "bucket_name" {
  type = string
  description = "Name of the Bucket"
}
variable "region" {
  type = string
  description = "AWS S3 Bucket Region"
}
# variable "storage_class" {
#   description = "The default storage class for S3 objects"
#   type        = string
#   validation {
#     condition     = can(regex("(STANDARD|INTELLIGENT_TIERING|STANDARD_IA|GLACIER|GLACIER_DEEP_ARCHIVE)", var.storage_class))
#     error_message = "Invalid storage class. Allowed values: STANDARD, INTELLIGENT_TIERING, STANDARD_IA, GLACIER, GLACIER_DEEP_ARCHIVE"
#   }
# }
variable "versioning" {
  description = "Enable versioning on the S3 bucket"
  type        = bool
}
variable "block_public_access" {
  description = "Enable block public access settings for the S3 bucket"
  type        = bool
#   default     = true
}
variable "enable_encryption" {
  description = "Enable server-side encryption"
  type        = bool
#   default     = true
}
variable "tags" {
  type        = map(string)
  description = "Tags to be added to the resource"
}
