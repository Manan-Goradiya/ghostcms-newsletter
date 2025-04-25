
# resource "aws_ecr_repository" "repository" {
#   name                 = var.ecr_repository_name
#   image_tag_mutability = var.image_tag_mutability
#   force_delete         = var.force_delete
#   tags                 = var.tags
#   encryption_configuration {
#     encryption_type = var.encryption_type
#   }
#   image_scanning_configuration {
#     scan_on_push = var.image_scan_on_push
#   }
# }

# resource "aws_ecr_lifecycle_policy" "lifecycle_policy" {
#   repository = aws_ecr_repository.repository.name
#   policy     = jsonencode({
#     rules = [for rule in var.lifecycle_rules : merge(
#       {
#         rulePriority = rule.rulePriority
#         description  = rule.description
#         selection = {
#           tagStatus   = rule.tagStatus
#           countType   = rule.countType
#           countNumber = rule.countNumber
#         }
#         action = {
#           type = rule.action_type
#         }
#       },
#       rule.tagStatus == "untagged" && rule.countUnit != null ? {
#         selection = merge({ countUnit = rule.countUnit }, {
#           tagStatus = rule.tagStatus, countType = rule.countType, countNumber = rule.countNumber
#         })
#       } : {},
#       rule.tagStatus == "tagged" && lookup(rule, "tagPrefixList", []) != [] ? {
#         selection = merge({ tagPrefixList = rule.tagPrefixList }, {
#           tagStatus = rule.tagStatus, countType = rule.countType, countNumber = rule.countNumber
#         })
#       } : {},
#       rule.tagStatus == "tagged" && lookup(rule, "tagPatternList", []) != [] ? {
#         selection = merge({ tagPatternList = rule.tagPatternList }, {
#           tagStatus = rule.tagStatus, countType = rule.countType, countNumber = rule.countNumber
#         })
#       } : {}
#     )]
#   })
# }