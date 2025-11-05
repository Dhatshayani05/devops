terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  required_version = ">= 1.0.0"
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "react_app_bucket" {
  bucket = "devops-deploy-project"   # bucket name you gave
  acl    = "public-read"

  website {
    index_document = "index.html"
  }
}

resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket                  = aws_s3_bucket.react_app_bucket.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "public_policy" {
  bucket = aws_s3_bucket.react_app_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = "*",
        Action    = ["s3:GetObject"],
        Resource  = "${aws_s3_bucket.react_app_bucket.arn}/*"
      }
    ]
  })
}

resource "aws_s3_bucket_object" "react_build_files" {
  for_each = fileset("../build", "**/*.*")

  bucket = aws_s3_bucket.react_app_bucket.id
  key    = each.value
  source = "../build/${each.value}"
  acl    = "public-read"

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
