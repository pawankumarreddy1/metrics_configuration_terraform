
# Define the AWS IAM role for Prometheus EC2 instances
resource "aws_iam_role" "prometheus-ec2-role" {
  name = "prometheus"
  path = "/"

  assume_role_policy = <<EOF
{
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
}
EOF
}

# Attach an IAM policy to the Prometheus IAM role for EC2 instances
resource "aws_iam_role_policy_attachment" "prometheus-sd-policy-attach" {
  role       = aws_iam_role.prometheus-ec2-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}

# Define the AWS IAM instance profile for Prometheus EC2 instances
resource "aws_iam_instance_profile" "prometheus-instance-profile" {
  name = "prometheus-instance-profile"
  role = aws_iam_role.prometheus-ec2-role.name
}

# Define the AWS security group for Prometheus
resource "aws_security_group" "prometheus-security-group" {
  name        = "prometheus-security-group"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.own.id

  ingress {
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "TLS from VPC"
    from_port   = 9090
    to_port     = 9090
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
    Name = "prometheus-security-group"
  }
}

resource "aws_instance" "prometheus" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.deployer.id
  subnet_id              = aws_subnet.public[1].id
  security_groups        = [aws_security_group.prometheus-security-group.id]
  iam_instance_profile   = aws_iam_instance_profile.prometheus-instance-profile.name
  depends_on             = [aws_instance.node_exporter]
  user_data              = <<-EOT
    #!/bin/bash
    sudo su -
    cd /tmp
    wget https://github.com/prometheus/prometheus/releases/download/v2.39.1/prometheus-2.39.1.linux-amd64.tar.gz
    tar -xf prometheus-2.39.1.linux-amd64.tar.gz
    mv prometheus-2.39.1.linux-amd64 prometheus
    cp -r * /opt
    chmod 755 /opt/prometheus
    chown -R ec2-user:ec2-user /opt/prometheus
    cd /opt/prometheus
    echo '
    global:
      scrape_interval: 15s
      evaluation_interval: 15s

    # Alertmanager configuration
    alerting:
      alertmanagers:
        - static_configs:
            - targets:
                - alertmanager:9093

    # Load rules once and periodically evaluate them according to the global 'evaluation_interval'.
    rule_files:
      - "first_rules.yml"
      - "second_rules.yml"

    # A scrape configuration containing Prometheus and node-exporter as targets.
    scrape_configs:
      - job_name: "prometheus"
        static_configs:
          - targets: ["localhost:9090"]

      - job_name: "node-exporter"
        static_configs:
          - targets: ["${aws_instance.node_exporter.private_ip}:9100"]

      - job_name: "tomcat"
        static_configs:
          - targets: ["${aws_instance.tomcat.private_ip}:8080"]' > prometheus.yml

    # Start Prometheus in the background using nohup
    nohup ./prometheus > /dev/null 2>&1 &
    EOT

  tags = {
    Name = "prometheus"
  }
}


resource "null_resource" "prometheus_provisioner" {
  depends_on = [aws_instance.prometheus]

  connection {
    type        = "ssh"
    host        = aws_instance.prometheus.public_ip
    user        = "ec2-user"
    private_key = file("~/.ssh/id_rsa")
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /opt/prometheus",
      "sudo cp ${path.module}/config/prometheus.yml /opt/prometheus/prometheus.yml",
      "sudo chmod 0777 /opt/prometheus/prometheus.yml",
    ]
  }
}
