resource "aws_cloudwatch_event_rule" "dataMiningInterval" {
  name = "dataMining"
  description = "Update forecast every hour"
  schedule_expression = "cron(0 * ? * * *)"
}

resource "aws_cloudwatch_event_target" "dataMiningTrigger" {
  arn = aws_lambda_function.DataMining.arn
  rule = aws_cloudwatch_event_rule.dataMiningInterval.name
}
