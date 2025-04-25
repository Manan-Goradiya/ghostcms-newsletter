data "aws_lb" "ingress_alb" {
  name = var.load_balancer_name # Ensure this matches your ALB name in AWS
}

resource "aws_wafv2_web_acl" "this" {
  name        = var.waf_name
  scope       = "REGIONAL" # Use "CLOUDFRONT" for global WAF
  description = "WAF for ALB"

  default_action {
    allow {}
  }

  rule {
    name     = "RateLimitRule"
    priority = 1

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = 600
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "RateLimitRule"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "SQLInjectionRule"
    priority = 2

    action {
      block {}
    }

    statement {
      sqli_match_statement {
        field_to_match {
          all_query_arguments {}
        }

        text_transformation {
          priority = 1
          type     = "NONE"
        }

        sensitivity_level = "HIGH" # Sensitivity Level 4
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "SQLInjectionRule"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "XSSProtectionRule"
    priority = 3

    action {
      block {}
    }

    statement {
      xss_match_statement {
        field_to_match {
          all_query_arguments {}
        }

        text_transformation {
          priority = 1
          type     = "NONE"
        }

        # sensitivity_level = "LOW" # Sensitivity Level 2
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "XSSProtectionRule"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "LFIRule"
    priority = 4

    action {
      block {}
    }

    statement {
      byte_match_statement {
        field_to_match {
          uri_path {}
        }

        positional_constraint = "CONTAINS"
        search_string         = "Li4v" # Base64-encoded "../"

        text_transformation {
          priority = 1
          type     = "URL_DECODE"
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "LFIRule"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "RCERule"
    priority = 5

    action {
      block {}
    }

    statement {
      regex_pattern_set_reference_statement {
        arn = aws_wafv2_regex_pattern_set.rce.arn

        text_transformation {
          priority = 1
          type     = "NONE"
        }
        
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "RCERule"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "RFIRule"
    priority = 6

    action {
      block {}
    }

    statement {
      byte_match_statement {
        field_to_match {
          uri_path {}
        }

        positional_constraint = "CONTAINS"
        search_string         = "http://"

        text_transformation {
          priority = 1
          type     = "NONE"
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "RFIRule"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = var.waf_name
    sampled_requests_enabled   = true
  }
}

resource "aws_wafv2_web_acl_association" "this" {
  resource_arn = data.aws_lb.ingress_alb.arn
  web_acl_arn  = aws_wafv2_web_acl.this.arn
}

resource "aws_wafv2_regex_pattern_set" "rce" {
  name        = "rce-pattern-set"
  scope       = "REGIONAL" # Use "CLOUDFRONT" if needed
  description = "Regex pattern set for detecting RCE attempts"

  regular_expression {
    regex_string = ".*(system\\(|exec\\(|shell_exec\\(|passthru\\(|eval\\().*"
  }

  regular_expression {
    regex_string = ".*(/bin/bash|nc -e).*"
  }
}
