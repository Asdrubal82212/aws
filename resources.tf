# Listar todos los buckets S3
data "aws_s3_bucket" "buckets" {
  for_each = toset(["test-bucket-compunube", "test-ec2s3", "vfg-computonube-20261"])
  bucket   = each.value
}

# Listar todas las tablas DynamoDB
data "aws_dynamodb_tables" "all" {}

# Outputs
output "buckets_s3" {
  value = [for b in data.aws_s3_bucket.buckets : b.bucket]
}

output "tablas_dynamodb" {
  value = data.aws_dynamodb_tables.all.names
}