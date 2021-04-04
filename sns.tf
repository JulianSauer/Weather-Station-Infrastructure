# Simple Notification Service
resource "aws_sns_topic" "WeatherStationBattery"{
  name = "WeatherStationBattery"
}

resource "aws_sns_topic" "WeatherStation" {
  name = "WeatherStation"
}

resource "aws_sns_topic_subscription" "SnsToDynamoDB" {
  topic_arn = aws_sns_topic.WeatherStation.arn
  endpoint = aws_lambda_function.SnsToDynamoDB.arn
  protocol = "lambda"
}
