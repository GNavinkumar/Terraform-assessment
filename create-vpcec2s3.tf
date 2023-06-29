provider "aws" {
  region     = "eu-west-1"
  access_key = "AKIAZ7AZ7IQIGZGGI7WD"
  secret_key = "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"
}

resource "aws_instance" "myvpcec2" {
  ami                    = "ami-01dd271720c1ba44f"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.mysubnet.id
}

resource "aws_vpc" "myvpc" {
  cidr_block = "10.10.0.0/16"
}

resource "aws_subnet" "mysubnet" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.10.1.0/24"

  tags = {
    Name = "mysubnet"
  }
}

resource "aws_internet_gateway" "myigw" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "myigw"
  }
}

resource "aws_route_table" "myroutetble" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myigw.id
  }

  tags = {
    Name = "myroutetble"
  }
}

resource "aws_route_table_association" "myrt_association" {
  subnet_id      = aws_subnet.mysubnet.id
  route_table_id = aws_route_table.myroutetble.id
}

resource "aws_security_group" "mysg" {
  name   = "mysg"
  vpc_id = aws_vpc.myvpc.id

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "mysg"
  }
}

resource "aws_s3_bucket" "mys3bucket" {
  bucket = "navin-bucket01"

  tags = {
    Name        = "mys3bucket"
    Environment = "Dev"
  }
}
