resource "aws_default_vpc" "default" {}

data "aws_ami" "latest_ubuntu" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

data "aws_ami" "latest_windows" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["Windows_Server-2022-English-Core-Base-*"]
  }
}

#==================
resource "aws_eip" "eip_ip_ubuntu" {
  vpc      = true
  instance = aws_instance.ubuntu.id
  tags     = merge(var.common_tags, { Name = "${var.common_tags["Environment"]} Ubuntu_bastion EIP" })
}

resource "aws_eip" "eip_ip_windows" {
  vpc      = true
  instance = aws_instance.windows.id
  tags     = merge(var.common_tags, { Name = "${var.common_tags["Environment"]} Windows_bastion EIP" })
}

resource "aws_security_group" "remote" {
  name   = "Remote Access Security Group"
  vpc_id = aws_default_vpc.default.id

  dynamic "ingress" {
    for_each = var.allow_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, { Name = "${var.common_tags["Environment"]} Remote Access SecurityGroup" })
}

resource "aws_instance" "ubuntu" {
  ami                    = data.aws_ami.latest_ubuntu.id
  instance_type          = var.instance_type
  key_name               = var.pem_key
  vpc_security_group_ids = [aws_security_group.remote.id]
  root_block_device {
    volume_size = var.ubuntu_volume
  }
  tags = merge(var.common_tags, { Name = "${var.common_tags["Environment"]} Ubuntu_bastion Server" })
}

resource "aws_instance" "windows" {
  ami                    = data.aws_ami.latest_windows.id
  instance_type          = var.instance_type
  key_name               = var.pem_key
  vpc_security_group_ids = [aws_security_group.remote.id]
  root_block_device {
    volume_size = var.windows_volume
  }
  tags = merge(var.common_tags, { Name = "${var.common_tags["Environment"]} Windows_bastion Server" })
}

