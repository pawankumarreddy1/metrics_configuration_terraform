resource "aws_security_group" "node_exporter-sg" {
  name        = "node_exporter-sg"
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
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "TLS from VPC"
    from_port   = 9117
    to_port     = 9117
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ingress {
  #   description      = "TLS from VPC"
  #   from_port        = 9100
  #   to_port          = 9100
  #   protocol         = "tcp"
  #   security_groups = [aws_security_group.prometheus-security-group.id]
  # }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "node_exporter-sg"
  }
}





resource "aws_instance" "node_exporter" {

  ami                  = var.ami_id
  instance_type        = var.instance_type
  key_name             = aws_key_pair.deployer.id
  subnet_id            = aws_subnet.public[1].id
  security_groups      = [aws_security_group.node_exporter-sg.id]
  user_data            = file("node-exporter.sh")
  iam_instance_profile = aws_iam_instance_profile.prometheus-instance-profile.name


  tags = {
    Name = "node-exporter"
  }


}

