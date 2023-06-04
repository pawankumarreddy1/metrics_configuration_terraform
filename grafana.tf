resource "aws_security_group" "grafana-sg" {
  name        = "grafana-sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.own.id

  ingress {
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["43.225.22.26/32"]

  }

  ingress {
    description = "TLS from VPC"
    from_port   = 3000
    to_port     = 3000
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
    Name = "grafana-sg"
  }
}




resource "aws_instance" "grafana" {

  ami             = var.ami_id
  instance_type   = var.instance_type
  key_name        = aws_key_pair.deployer.id
  subnet_id       = aws_subnet.public[1].id
  security_groups = [aws_security_group.grafana-sg.id]
  user_data       = file("grafana.sh")

  tags = {
    Name = "grafana"
  }

}


