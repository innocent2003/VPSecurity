provider "aws" {
  region = var.region
}

resource "aws_instance" "vulnerable_instance" {
  ami           = "ami-0c55b159cbfafe1f0" # Update with your desired AMI
  instance_type = "t2.micro"
  security_groups = [aws_security_group.vulnerable_sg.name]
  
  user_data = <<-EOF
              #!/bin/bash
              sudo apt update
              sudo apt install python3 python3-pip -y
              pip3 install -r /home/ubuntu/flask_app/requirements.txt
              nohup python3 /home/ubuntu/flask_app/app.py &
              EOF

  tags = {
    Name = "VulnerableFlaskApp"
  }
}

resource "aws_security_group" "vulnerable_sg" {
  name        = "vulnerable_sg"
  description = "Security group with overly permissive rules"

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_s3_bucket" "vulnerable_bucket" {
  bucket = "vulnerable-logs-bucket"
  acl    = "public-read"
}

resource "aws_s3_bucket_policy" "vulnerable_bucket_policy" {
  bucket = aws_s3_bucket.vulnerable_bucket.id
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::${aws_s3_bucket.vulnerable_bucket.id}/*"
    }
  ]
}
POLICY
}

resource "aws_s3_bucket" "secure_bucket" {
  bucket = "secure-logs-bucket"
  acl    = "private"
}

resource "aws_s3_bucket_policy" "secure_bucket_policy" {
  bucket = aws_s3_bucket.secure_bucket.id
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::${aws_s3_bucket.secure_bucket.id}/*"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${var.account_id}:user/your-user"
      },
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::${aws_s3_bucket.secure_bucket.id}/*"
    }
  ]
}
POLICY
}
