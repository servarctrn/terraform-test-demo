# Define our VPC
resource "aws_vpc" "default" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  instance_tenancy     = "default"

  tags = {
    Name        = "Terraform-demo-vpc"
    builder     = "Dennis Ogunfiditimi"
    application = "security"
    environment = "test"
  }
}

# Define the public subnet
resource "aws_subnet" "public-subnet1" {
  vpc_id            = aws_vpc.default.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Web Public Subnet1"
  }
}

resource "aws_subnet" "public-subnet2" {
  vpc_id            = aws_vpc.default.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "Web Public Subnet2"
  }
}
# Define the application subnet
resource "aws_subnet" "app_subnet-1" {
  vpc_id            = aws_vpc.default.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "application subnet"
  }
}

resource "aws_subnet" "app_subnet-2" {
  vpc_id            = aws_vpc.default.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "application subnet"
  }
}
# Define the databese subnet
resource "aws_subnet" "db_subnet-1" {
  vpc_id            = aws_vpc.default.id
  cidr_block        = "10.0.5.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "database subnet"
  }
}

resource "aws_subnet" "db_subnet-2" {
  vpc_id            = aws_vpc.default.id
  cidr_block        = "10.0.6.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "database subnet"
  }
}
# Define the internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.default.id

  tags = {
    Name = "VPC-IGW"
  }
}

# Define the route table
resource "aws_route_table" "web-public-rt" {
  vpc_id = aws_vpc.default.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "Public Subnet RT"
  }
}

resource "aws_route_table" "non-web-private-rt" {
  vpc_id = aws_vpc.default.id

  route = []

  tags = {
    Name = "App & DB Subnet RT"
  }
}

# Assign the route table to the public Subnet
resource "aws_route_table_association" "web-public-rt1" {
  subnet_id      = aws_subnet.public-subnet1.id
  route_table_id = aws_route_table.web-public-rt.id
}

resource "aws_route_table_association" "web-public-rt2" {
  subnet_id      = aws_subnet.public-subnet2.id
  route_table_id = aws_route_table.web-public-rt.id
}

# Assign the route table to the App & DB Subnet
resource "aws_route_table_association" "app-rt1" {
  subnet_id      = aws_subnet.app_subnet-1.id
  route_table_id = aws_route_table.non-web-private-rt.id
}

resource "aws_route_table_association" "app-rt2" {
  subnet_id      = aws_subnet.app_subnet-2.id
  route_table_id = aws_route_table.non-web-private-rt.id
}

resource "aws_route_table_association" "db-rt1" {
  subnet_id      = aws_subnet.db_subnet-1.id
  route_table_id = aws_route_table.non-web-private-rt.id
}

resource "aws_route_table_association" "db-rt2" {
  subnet_id      = aws_subnet.db_subnet-2.id
  route_table_id = aws_route_table.non-web-private-rt.id
}


# Define the security group for public subnet
resource "aws_security_group" "app" {
  name        = "app-servers-sg"
  description = "SG for app server"
  vpc_id      = aws_vpc.default.id

dynamic "ingress" {
  for_each = [ "80", "443", "3806", "22"]
  content {
    description = "allow few ports app-server"
    from_port = ingress.value
    to_port = ingress.value
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name  = "SG"
    Owner = "Dennis Ogunfiditimi"
  }
}


/*
resource "aws_security_group" "sgweb" {
  name        = "vpc_test_web"
  description = "Allow incoming HTTP connections & SSH access"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = aws_vpc.default.id

  tags = {
    Name = "Web Server SG"
  }
}

# Define the security group for private subnet
resource "aws_security_group" "sgdb" {
  name        = "sg_test_web"
  description = "Allow traffic from public subnet"

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["${var.public_subnet_cidr}"]
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["${var.public_subnet_cidr}"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.public_subnet_cidr}"]
  }

  vpc_id = aws_vpc.default.id

  tags = {
    Name    = "DB SG"
    Builder = "Dennis Ogunfiditimi"
  }
}
*/