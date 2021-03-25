terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
}

provider "aws" {
  profile = "default"
  region = "eu-central-1"
}

# User for uploading to S3
resource "aws_iam_user" "UploadToS3" {
  name = "UploadToS3"
}

resource "aws_iam_user_policy_attachment" "UploadToS3" {
  user = aws_iam_user.UploadToS3.name
  policy_arn = aws_iam_policy.UploadToS3.arn
}

resource "aws_iam_policy" "UploadToS3" {
  policy = jsonencode({
    Version: "2012-10-17",
    Statement: [
      {
        Sid: "VisualEditor0",
        Effect: "Allow",
        Action: "s3:PutObject",
        Resource: "*"
      }
    ]
  })
}

resource "aws_s3_bucket" "WeatherStationLambdaFunctions" {
  bucket = "weather-station-lambda-functions"
  acl    = "private"
}
