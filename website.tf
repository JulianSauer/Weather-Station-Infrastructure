# S3 bucket for website
resource "aws_s3_bucket" "WeatherStationWebsite" {
  bucket = "weather.julian-sauer.com"
  acl    = "public-read"
  policy = data.aws_iam_policy_document.WeatherStationUI.json
  website {
    index_document = "index.html"
    error_document = "index.html"
  }
}
