terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  required_version = ">= 1.0.0"
}

locals {
  bucket_name = "devops-deploy-project"
}

# Create CloudFront Origin Access Identity
resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "OAI for accessing S3 bucket securely"
}

# Attach CloudFront access permissions to S3 bucket
resource "aws_s3_bucket_policy" "cloudfront_policy" {
  bucket = local.bucket_name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = aws_cloudfront_origin_access_identity.oai.iam_arn
        },
        Action   = ["s3:GetObject"],
        Resource = "arn:aws:s3:::${local.bucket_name}/*"
      }
    ]
  })
}

# CloudFront Distribution
resource "aws_cloudfront_distribution" "react_app_cdn" {
  origin {
    domain_name = "${local.bucket_name}.s3.amazonaws.com"
    origin_id   = "s3-${local.bucket_name}"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "s3-${local.bucket_name}"
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  price_class = "PriceClass_100"

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}

# Upload build files to S3
resource "aws_s3_object" "react_build_files" {
  for_each = fileset("../build", "**/*.*")

  bucket = local.bucket_name
  key    = each.value
  source = "../build/${each.value}"
  etag   = filemd5("../build/${each.value}")
  content_type = lookup({
    html = "text/html",
    css  = "text/css",
    js   = "application/javascript",
    json = "application/json",
    png  = "image/png",
    jpg  = "image/jpeg",
    svg  = "image/svg+xml"
  }, split(".", each.value)[1], "application/octet-stream")
}

# CloudFront cache invalidation
resource "aws_cloudfront_distribution_invalidation" "invalidate" {
  distribution_id = aws_cloudfront_distribution.react_app_cdn.id
  paths           = ["/*"]

  depends_on = [aws_s3_object.react_build_files]
}
