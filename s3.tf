resource "aws_s3_bucket" "main" {
  bucket = "servarc-class-demo-bucket-v1"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}