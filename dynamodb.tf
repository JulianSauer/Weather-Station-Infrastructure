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
resource "aws_lambda_function" "SnsToDynamoDB" {
  function_name = "SnsToDynamoDB"
  s3_bucket = data.aws_s3_bucket.WeatherStationLambdaFunctions.bucket
  s3_key = "SnsToDynamoDB/function.zip"
  handler = "main"
  role = aws_iam_role.SnsToDynamoDB.arn
  runtime = "go1.x"
}
