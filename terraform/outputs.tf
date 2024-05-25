output "instance_public_ip" {
  description = "The public IP address of the EC2 instance"
  value       = aws_instance.vulnerable_instance.public_ip
}

output "vulnerable_s3_bucket_name" {
  description = "The name of the vulnerable S3 bucket"
  value       = aws_s3_bucket.vulnerable_bucket.bucket
}

output "secure_s3_bucket_name" {
  description = "The name of the secure S3 bucket"
  value       = aws_s3_bucket.secure_bucket.bucket
}
