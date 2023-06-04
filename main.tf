data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "own" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "my own"
  }

}


resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.own.id

  tags = {
    Name = "gw"
  }
}


resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidr)
  vpc_id                  = aws_vpc.own.id
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  cidr_block              = element(var.public_subnet_cidr, count.index)
  map_public_ip_on_launch = "true"

  tags = {
    Name = "gw"
  }
}

resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidr)
  vpc_id            = aws_vpc.own.id
  availability_zone = element(data.aws_availability_zones.available.names, count.index)
  cidr_block        = element(var.private_subnet_cidr, count.index)

  tags = {
    Name = "gw"
  }
}

resource "aws_subnet" "data" {
  count             = length(var.data_subnet_cidr)
  vpc_id            = aws_vpc.own.id
  availability_zone = element(data.aws_availability_zones.available.names, count.index)
  cidr_block        = element(var.data_subnet_cidr, count.index)

  tags = {
    Name = "gw"
  }
}
# eip
resource "aws_eip" "eip" {
  vpc = true
}

# natgateway
resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "gw NAT"
  }

}


# route tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.own.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "public_route"
  }
}


resource "aws_route_table" "private" {
  vpc_id = aws_vpc.own.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw.id
  }
  tags = {
    Name = "private_route"
  }
}


resource "aws_route_table_association" "public" {
  count          = length(var.public_subnet_cidr)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnet_cidr)
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = aws_route_table.private.id
}


resource "aws_route_table_association" "data" {
  count          = length(var.data_subnet_cidr)
  subnet_id      = element(aws_subnet.data.*.id, count.index)
  route_table_id = aws_route_table.private.id
}

resource "aws_security_group" "apache-sg" {
  name        = "apache-sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.own.id

  ingress {
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.own.cidr_block]

  }
  ingress {
    description = "TLS from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "apache-sg"
  }
}




resource "aws_instance" "apache" {

  ami             = var.ami_id
  instance_type   = var.instance_type
  key_name        = aws_key_pair.deployer.id
  subnet_id       = aws_subnet.public[1].id
  security_groups = [aws_security_group.apache-sg.id]
  user_data       = <<-EOF
  #!/bin/bash 
  sudo su -
  yum update -y 
  yum install httpd -y
  systemctl enable httpd 
  systemctl start httpd
  EOF 
}