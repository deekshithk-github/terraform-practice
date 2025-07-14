# Create a VPC
#resource "aws_s3_bucket" "terraform_state" {
#  bucket = "my-terraform-state-bucket-12387612-south"
#  force_destroy = true
#
#  tags = {
#    Name = "Terraform State Bucket"
#  }
#}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "Terraform Locks Table"
  }
}


resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "my-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "my-igw"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet"
  }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  tags = {
    Name = "private-subnet"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "public_subnet_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_instance" "example" {
  ami                         = "ami-0f918f7e67a3323f0" # Use a valid AMI ID for your region
  instance_type               = "t2.micro"
  subnet_id                   = "subnet-0b0ccbcf69ade615b"     # Replace with your existing subnet ID
  vpc_security_group_ids      = ["sg-01d7d83d100657253"]        # Replace with existing security group ID
  key_name                    = "lms-key"        # Replace with existing key pair name
  associate_public_ip_address = true                   # Optional: for public access

  tags = {
    Name = "MyEC2Instance"
  }
}

resource "aws_security_group_rule" "example" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
    security_group_id = "sg-01d7d83d100657253"
}
