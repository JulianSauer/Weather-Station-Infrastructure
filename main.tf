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

# DynamoDB
resource "aws_dynamodb_table" "WeatherStation" {
  name = "WeatherStation"
  hash_key = "source"
  range_key = "timestamp"
  billing_mode = "PROVISIONED"
  read_capacity = 1
  write_capacity = 1

  attribute {
    name = "source"
    type = "S"
  }
  attribute {
    name = "timestamp"
    type = "S"
  }
}

# Lambda
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

resource "aws_lambda_function" "WeatherAPI" {
  function_name = "WeatherAPI"
  s3_bucket = data.aws_s3_bucket.WeatherStationLambdaFunctions.bucket
  s3_key = "WeatherAPI/function.zip"
  handler = "main"
  role = aws_iam_role.WeatherAPI.arn
  runtime = "go1.x"
}

# Api Gateway
resource "aws_api_gateway_rest_api" "WeatherAPI" {
  name = "WeatherAPI"
}

resource "aws_api_gateway_resource" "WeatherAPI" {
  parent_id = aws_api_gateway_rest_api.WeatherAPI.root_resource_id
  path_part = "weather"
  rest_api_id = aws_api_gateway_rest_api.WeatherAPI.id
}

resource "aws_api_gateway_method" "WeatherAPI" {
  authorization = "NONE"
  http_method = "GET"
  resource_id = aws_api_gateway_resource.WeatherAPI.id
  rest_api_id = aws_api_gateway_rest_api.WeatherAPI.id
}

resource "aws_api_gateway_integration" "WeatherAPI" {
  http_method = aws_api_gateway_method.WeatherAPI.http_method
  resource_id = aws_api_gateway_resource.WeatherAPI.id
  rest_api_id = aws_api_gateway_rest_api.WeatherAPI.id
  type = "AWS_PROXY"
  integration_http_method = "POST"
  uri = aws_lambda_function.WeatherAPI.invoke_arn
}

resource "aws_api_gateway_deployment" "WeatherAPI" {
  rest_api_id = aws_api_gateway_rest_api.WeatherAPI.id
  depends_on = [aws_api_gateway_integration.WeatherAPI]
  stage_name = "api"
}

output "WeatherAPI" {
  value = aws_api_gateway_deployment.WeatherAPI.invoke_url
}

# Simple Notification Service
resource "aws_sns_topic" "WeatherStation" {
  name = "WeatherStation"
}

resource "aws_sns_topic_subscription" "SnsToDynamoDB" {
  topic_arn = aws_sns_topic.WeatherStation.arn
  endpoint = aws_lambda_function.SnsToDynamoDB.arn
  protocol = "lambda"
}
