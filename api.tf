# Lambda
resource "aws_lambda_function" "WeatherAPI" {
  function_name = "WeatherAPI"
  s3_bucket = data.aws_s3_bucket.WeatherStationLambdaFunctions.bucket
  s3_key = "WeatherAPI/function.zip"
  handler = "main"
  role = aws_iam_role.WeatherAPI.arn
  runtime = "go1.x"
}

resource "aws_lambda_function" "ForecastAPI" {
  function_name = "ForecastAPI"
  s3_bucket = data.aws_s3_bucket.WeatherStationLambdaFunctions.bucket
  s3_key = "WeatherAPI/forecast.zip"
  handler = "main"
  role = aws_iam_role.ForecastAPI.arn
  runtime = "go1.x"
}

# Api Gateway
resource "aws_api_gateway_rest_api" "WeatherAPI" {
  name = "WeatherAPI"
}

resource "aws_api_gateway_deployment" "WeatherAPI" {
  rest_api_id = aws_api_gateway_rest_api.WeatherAPI.id
  depends_on = [aws_api_gateway_integration.WeatherAPI]
  stage_name = "api"
}

# Sensors
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

# Forecast
resource "aws_api_gateway_resource" "ForecastAPI" {
  parent_id = aws_api_gateway_rest_api.WeatherAPI.root_resource_id
  path_part = "forecast"
  rest_api_id = aws_api_gateway_rest_api.WeatherAPI.id
}

resource "aws_api_gateway_method" "ForecastAPI" {
  authorization = "NONE"
  http_method = "GET"
  resource_id = aws_api_gateway_resource.ForecastAPI.id
  rest_api_id = aws_api_gateway_rest_api.WeatherAPI.id
}

resource "aws_api_gateway_integration" "ForecastAPI" {
  http_method = aws_api_gateway_method.ForecastAPI.http_method
  resource_id = aws_api_gateway_resource.ForecastAPI.id
  rest_api_id = aws_api_gateway_rest_api.WeatherAPI.id
  type = "AWS_PROXY"
  integration_http_method = "POST"
  uri = aws_lambda_function.ForecastAPI.invoke_arn
}
