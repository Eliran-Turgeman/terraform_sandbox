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


resource "aws_iam_role" "test_role" {
  name = "TestRole"

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

  inline_policy { # How can I use predefined policies?
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
  name = "ec2-profile-eliran"
  role = aws_iam_role.test_role.name

  tags = {
    Owner = "Eliran"
  }
}


resource "aws_s3_bucket" "test_bucket" {
  bucket = "test-bucket-eliran"

  tags = {
    Name = "Test Bucket"
    Owner = "Eliran"
    Environment = "dev2"
  }
}


resource "aws_s3_bucket_acl" "test_bucket_acl" {
  bucket = aws_s3_bucket.test_bucket.id
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


resource "aws_db_instance" "mysql_eliran_db" {
  allocated_storage    = 10
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  name                 = "mydb"
  username             = "eliran"
  password             = "eliran"
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
}

