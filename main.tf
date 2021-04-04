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

# Lambda
data "aws_s3_bucket" "WeatherStationLambdaFunctions" {
  bucket = "weather-station-lambda-functions"
}

output "WeatherAPI" {
  value = aws_api_gateway_deployment.WeatherAPI.invoke_url
}

output "WeatherStationTopic" {
  value = aws_sns_topic.WeatherStation.arn
}

output "WeatherStationBatteryTopic" {
  value = aws_sns_topic.WeatherStationBattery.arn
}
