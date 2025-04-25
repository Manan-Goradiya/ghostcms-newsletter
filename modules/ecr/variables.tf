variable "ecr_repository_name" {
  type        = string
  description = "Name of the Elastic Container Registry Repository"
}

variable "tags" {
  type        = map(string)
  description = "Tags to be added to the resource"
}

variable "image_tag_mutability" {
  type        = string
  description = "Set the image tag mutability (MUTABLE or IMMUTABLE)"
  validation {
    condition     = can(regex("^(MUTABLE|IMMUTABLE)$", var.image_tag_mutability))
    error_message = "Allowed values: MUTABLE, IMMUTABLE"
  }
}

variable "force_delete" {
  description = "Allow force deletion of the repository"
  type        = bool
}

variable "encryption_type" {
  description = "Encryption type for images (AES256 or KMS)"
  type        = string
}

variable "image_scan_on_push" {
  description = "Enable automatic image scanning on push"
  type        = bool
}

variable "lifecycle_rules" {
  description = "List of ECR lifecycle policy rules"
  type = list(object({
    rulePriority = number
    description  = string
    tagStatus    = string
    countType    = string
    countNumber  = number
    countUnit    = optional(string) # Optional for 'sinceImagePushed'
    tagPrefixList = optional(list(string), [])  # Optional tag prefix
    tagPatternList = optional(list(string), [])
    action_type  = string
  }))
}
