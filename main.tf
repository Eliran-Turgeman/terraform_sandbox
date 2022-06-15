provider "aws" {
  region = "eu-west-1"
  profile = "dev2"
}

resource "aws_vpc" "main" {
  cidr_block       = "192.168.0.0/16"

  tags = {
    Name = "EliranVPC"
    Owner = "Eliran"
  }
}

resource "aws_subnet" "subnet_in_vpc" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "192.168.1.0/24"

  tags = {
    Name = "EliranSubnet"
    Owner = "Eliran"
  }
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH Bi-directional traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [aws_vpc.main.cidr_block]
  }

  egress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [aws_vpc.main.cidr_block]
  }

  tags = {
    Name = "allow_ssh"
    Owner = "Eliran"
  }
}


resource "aws_iam_role" "test_role_eliran" {
  name = "TestRoleEliran"

  assume_role_policy = jsonencode({ # what's the purpose of this?
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
})

  inline_policy {
    name = "s3_full_access"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
        "Effect": "Allow",
            "Action": [
                "s3:*",
                "s3-object-lambda:*"
            ],
            "Resource": "*"
      },
      ]
    })
  }

  tags = {
    Name = "Test Role"
    Owner = "Eliran"
  }
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-profile-eliran2"
  role = aws_iam_role.test_role_eliran.name

  tags = {
    Owner = "Eliran"
  }
}

resource "aws_s3_bucket_logging" "test_bucket_logging_eliran" {
  bucket        = aws_s3_bucket.test_bucket_eliran.id
  target_bucket = aws_s3_bucket.test_bucket_eliran.id
  target_prefix = "log/"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "test_bucket_sse_eliran" {
  bucket = aws_s3_bucket.test_bucket_eliran.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "example" {
  bucket = aws_s3_bucket.test_bucket_eliran.id
  versioning_configuration {
    status = "Enabled"
    mfa_delete = "Enabled"
  }
#  mfa = (Optional, Required if versioning_configuration mfa_delete is enabled) The concatenation of the
#  authentication device's serial number, a space, and the value that is displayed on your authentication device.
}


resource "aws_s3_bucket" "test_bucket_eliran" {
  bucket = "test-bucket-eliran2"

#  versioning {
#    mfa_delete = true
#  } can't find yet

  tags = {
    Name = "Test Bucket"
    Owner = "Eliran"
    Environment = "dev2"
  }
}


resource "aws_s3_bucket_acl" "test_bucket_acl" {
  bucket = aws_s3_bucket.test_bucket_eliran.id
  acl    = "public-read"
}


resource "aws_instance" "ec2-eliran" {
  ami           = "ami-0069d66985b09d219"
  instance_type = "t2.micro"

  subnet_id = aws_subnet.subnet_in_vpc.id
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
  security_groups = [aws_security_group.allow_ssh.id]

  tags = {
    Name = "ec2-eliran"
    Owner = "Eliran"
  }
}


resource "aws_s3_bucket" "data" {
  # bucket is public
  # bucket is not encrypted
  # bucket does not have access logs
  # bucket does not have versioning
  bucket        = "${local.resource_prefix.value}-data"
  acl           = "public-read"
  force_destroy = true
  tags = merge({
    Name        = "${local.resource_prefix.value}-data"
    Environment = local.resource_prefix.value
    }, {
    git_commit           = "d68d2897add9bc2203a5ed0632a5cdd8ff8cefb0"
    git_file             = "terraform/aws/s3.tf"
    git_last_modified_at = "2020-06-16 14:46:24"
    git_last_modified_by = "nimrodkor@gmail.com"
    git_modifiers        = "nimrodkor"
    git_org              = "bridgecrewio"
    git_repo             = "terragoat"
    yor_trace            = "0874007d-903a-4b4c-945f-c9c233e13243"
  })
}


#resource "aws_db_subnet_group" "default" {
#  name       = "main"
#  subnet_ids = [aws_subnet.subnet_in_vpc.id]
#
#  tags = {
#    Name = "My DB subnet group"
#    Owner = "Eliran"
#  }
#}

#resource "aws_db_instance" "mysql_eliran_db" {
#  allocated_storage    = 10
#  engine               = "mysql"
#  engine_version       = "5.7"
#  instance_class       = "db.t2.micro"
#  db_name                 = "mydb"
#  username             = "eliran"
#  password             = "eliran"
#  parameter_group_name = "default.mysql5.7"
#  skip_final_snapshot  = true
#  db_subnet_group_name = aws_db_subnet_group.default.name
#}

