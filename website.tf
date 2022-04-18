variable "certificate" {
  # Has to be created & verified manually
  default = "arn:aws:acm:us-east-1:104057843468:certificate/8a5e2780-5bae-4d86-bd0c-c746fa2ab518"
}

# S3 bucket for website
resource "aws_s3_bucket" "WeatherStationWebsite" {
  bucket = "wetter.julian-sauer.com"
  acl    = "public-read"
  policy = data.aws_iam_policy_document.WeatherStationUI.json
  website {
    index_document = "index.html"
    error_document = "index.html"
  }
}

# Cloudfront for HTTPS and a custom domain
resource "aws_cloudfront_distribution" "WeatherStationWebsite" {
  origin {
    domain_name = aws_s3_bucket.WeatherStationWebsite.bucket_regional_domain_name
    origin_id = "S3-wetter.julian-sauer.com"
  }
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  aliases = ["wetter.julian-sauer.com"]

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-wetter.julian-sauer.com"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "blacklist"
      locations        = ["RU"]
    }
  }

  viewer_certificate {
    acm_certificate_arn = var.certificate
    ssl_support_method = "sni-only"
  }
}
