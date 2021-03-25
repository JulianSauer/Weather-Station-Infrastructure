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

resource "aws_dynamodb_table" "WeatherStation" {
  name = "WeatherStation"
  hash_key = "messageId"
  range_key = "timestamp"
  billing_mode = "PROVISIONED"
  read_capacity = 1
  write_capacity = 1

  attribute {
    name = "messageId"
    type = "S"
  }
  attribute {
    name = "timestamp"
    type = "S"
  }
}

data "aws_s3_bucket" "WeatherStationLambdaFunctions" {
  bucket = "weather-station-lambda-functions"
}

resource "aws_lambda_function" "SnsToDynamoDB" {
  function_name = "SnsToDynamoDB"
  s3_bucket = data.aws_s3_bucket.WeatherStationLambdaFunctions.bucket
  s3_key = "SnsToDynamoDB/function.zip"
  handler = "main"
  role = aws_iam_role.SnsToDynamoDB.arn
  runtime = "go1.x"
}

resource "aws_sns_topic" "WeatherStation" {
  name = "WeatherStation"
}

resource "aws_sns_topic_subscription" "SnsToDynamoDB" {
  topic_arn = aws_sns_topic.WeatherStation.arn
  endpoint = aws_lambda_function.SnsToDynamoDB.arn
  protocol = "lambda"
}
