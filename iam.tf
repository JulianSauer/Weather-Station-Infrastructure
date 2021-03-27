# Role for writing SNS messages to DynamoDB using Lambda
resource "aws_iam_role" "SnsToDynamoDB" {
  name = "SnsToDynamoDB"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "SnsToDynamoDBPolicyAttach" {
  role = aws_iam_role.SnsToDynamoDB.name
  policy_arn = data.aws_iam_policy.AWSLambdaBasicExecutionRole.arn
}

resource "aws_iam_role_policy_attachment" "LambdaS3Access" {
  role = aws_iam_role.SnsToDynamoDB.name
  policy_arn = aws_iam_policy.LambdaS3Access.arn
}

# Allow SNS to trigger Lambda and write to DynamoDB
resource "aws_lambda_permission" "sns" {
  statement_id = "AllowExecutionFromSNS"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.SnsToDynamoDB.function_name
  principal = "sns.amazonaws.com"
  source_arn = aws_sns_topic.WeatherStation.arn
}

data "aws_iam_policy" "AWSLambdaBasicExecutionRole" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "SnsToDynamoDBWriting" {
  name = "SnsToDynamoDBWriting"
  role = aws_iam_role.SnsToDynamoDB.id

  policy = jsonencode({
    Version: "2012-10-17",
    Statement: [
      {
        Sid: "VisualEditor0",
        Effect: "Allow",
        Action: "dynamodb:PutItem",
        Resource: aws_dynamodb_table.WeatherStation.arn
      }
    ]
  })
}

# Allow API Gateway to call Lambda
resource "aws_lambda_permission" "WeatherAPI" {
  statement_id = "AllowAPIGatewayInvoke"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.WeatherAPI.function_name
  principal = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_rest_api.WeatherAPI.execution_arn}/*/*"
}

# Lambda function for API
resource "aws_iam_role" "WeatherAPI" {
  name = "WeatherAPI"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "WeatherAPIPolicyAttach" {
  role = aws_iam_role.WeatherAPI.name
  policy_arn = data.aws_iam_policy.AWSLambdaBasicExecutionRole.arn
}

resource "aws_iam_role_policy_attachment" "WeatherAPILambdaS3Access" {
  role = aws_iam_role.WeatherAPI.name
  policy_arn = aws_iam_policy.LambdaS3Access.arn
}

resource "aws_iam_role_policy" "WeatherAPIDBReading" {
  name = "WeatherAPIDBReading"
  role = aws_iam_role.WeatherAPI.id

  policy = jsonencode({
    Version: "2012-10-17",
    Statement: [
      {
        Sid: "VisualEditor0",
        Effect: "Allow",
        Action: "dynamodb:Query",
        Resource: aws_dynamodb_table.WeatherStation.arn
      }
    ]
  })
}

# Allow Lambda to download functions from S3
resource "aws_iam_policy" "LambdaS3Access" {
  name = "LambdaS3Access"

  policy = jsonencode({
    Version: "2012-10-17",
    Statement: [
      {
        Effect: "Allow",
        Action: [
          "s3:ListAllMyBuckets",
          "s3:GetBucketLocation"
        ],
        Resource: "*"
      },
      {
        Effect: "Allow",
        Action: "s3:*",
        Resource: [
          data.aws_s3_bucket.WeatherStationLambdaFunctions.arn
        ]
      }
    ]
  })
}

resource "aws_iam_user" "UploadToS3" {
  name = "UploadToS3"
}
