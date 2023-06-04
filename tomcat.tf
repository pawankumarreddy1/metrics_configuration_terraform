resource "aws_security_group" "tomcat-sg" {
  name        = "tomcat-sg"
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
    from_port   = 8080
    to_port     = 8080
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
    Name = "tomcat-sg"
  }
}




resource "aws_instance" "tomcat" {
  
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = aws_key_pair.deployer.id
  subnet_id     = aws_subnet.public[1].id
  security_groups = [aws_security_group.tomcat-sg.id]
  user_data     = file("tomcat.sh")

}