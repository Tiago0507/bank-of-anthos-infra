# The AWS account ID makes the bucket name globally unique without needing a
# random suffix. S3 bucket names must be unique across all of AWS, not only
# within a single account. Using the account ID keeps the name deterministic,
# so other modules can compute and reference it without reading this
# module's output.
data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "tfstate" {
  bucket = "${var.project_name}-tfstate-${data.aws_caller_identity.current.account_id}"

  # Prevents "terraform destroy" from deleting this bucket by accident.
  # Destroying it would remove the state history of every other module that
  # depends on it.
  lifecycle {
    prevent_destroy = true
  }
}

# Versioning turns every state write into a new object version instead of an
# overwrite. If a bad apply corrupts the state, the previous version can be
# restored from the bucket instead of the data being lost.
resource "aws_s3_bucket_versioning" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  versioning_configuration {
    status = "Enabled"
  }
}

# State files can contain secrets in plaintext, such as database passwords
# or keys pulled into resource attributes. Encryption at rest is enabled by
# default for that reason.
resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Extra safeguard. Even though no public-read bucket policy is attached
# here, this blocks any future ACL or policy change from accidentally
# making the bucket, and any secrets stored in state, public.
resource "aws_s3_bucket_public_access_block" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
