# resource "aws_ecr_registry_scanning_configuration" "ecr_scanning_config" {
#   scan_type = var.scan_type
#   dynamic "rule" {
#     for_each = var.scan_rules
#     content {
#       scan_frequency = rule.value.scan_frequency

#       repository_filter {
#         filter      = rule.value.filter
#         filter_type = rule.value.filter_type
#       }
#     }
#   }
# }