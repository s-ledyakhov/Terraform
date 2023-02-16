resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  tags = {
    "Name" = "Main_vpc"
  }
}

data "aws_ami" "ami_latest_ami" {
  owners      = ["137112412989"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-*-x86_64-gp2"]
  }
}

resource "aws_internet_gateway" "main_gw" {
  vpc_id = aws_vpc.main.id
  tags = {
    "Name" = "Main_gw"
  }
}

###################
### PUBLIC ZONE ###
###################

resource "aws_subnet" "public_subnet_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_a
  availability_zone       = var.availability_zone_a
  map_public_ip_on_launch = true
  tags = {
    Name = "Public_Subnet_A"
  }
}

resource "aws_subnet" "public_subnet_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_b
  availability_zone       = var.availability_zone_b
  map_public_ip_on_launch = true
  tags = {
    Name = "Public_Subnet_B"
  }
}

resource "aws_route_table" "route_table_public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_gw.id
  }
  tags = {
    Name = "(Main)Route_table_PUBLIC"
  }
}

resource "aws_main_route_table_association" "public_route_association" {
  vpc_id         = aws_vpc.main.id
  route_table_id = aws_route_table.route_table_public.id
}

####################
### PRIVATE ZONE ###
####################
resource "aws_eip" "eip_a" {
  vpc = true
  tags = {
    Name = "NAT_eip_A"
  }
}

resource "aws_eip" "eip_b" {
  vpc = true
  tags = {
    Name = "NAT_eip_B"
  }
}

resource "aws_nat_gateway" "nat_gw_a" {
  allocation_id = aws_eip.eip_a.id
  subnet_id     = aws_subnet.public_subnet_a.id

  tags = {
    Name = "NAT_gw_A"
  }
  depends_on = [
    aws_internet_gateway.main_gw
  ]
}

resource "aws_nat_gateway" "nat_gw_b" {
  allocation_id = aws_eip.eip_b.id
  subnet_id     = aws_subnet.public_subnet_b.id

  tags = {
    Name = "NAT_gw_B"
  }
  depends_on = [
    aws_internet_gateway.main_gw
  ]
}

resource "aws_route_table" "route_table_private_a" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gw_a.id
  }
  tags = {
    Name = "Route_table_Private_Nat_A"
  }
}

resource "aws_route_table" "route_table_private_b" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gw_b.id
  }
  tags = {
    Name = "Route_table_Private_Nat_B"
  }
}


resource "aws_subnet" "private_subnet_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_a
  availability_zone = var.availability_zone_a
  tags = {
    Name = "Private_Subnet_A"
  }
}

resource "aws_route_table_association" "private_route_association_a" {
  subnet_id      = aws_subnet.private_subnet_a.id
  route_table_id = aws_route_table.route_table_private_a.id
}

resource "aws_subnet" "private_subnet_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_b
  availability_zone = var.availability_zone_b
  tags = {
    Name = "Private_Subnet_B"
  }
}

resource "aws_route_table_association" "private_route_association_b" {
  subnet_id      = aws_subnet.private_subnet_b.id
  route_table_id = aws_route_table.route_table_private_b.id
}

#####################
### DATABASE ZONE ###
#####################

resource "aws_route_table" "route_table_db" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "Route_table_DB"
  }
}

resource "aws_subnet" "db_subnet_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.db_subnet_a
  availability_zone = var.availability_zone_a
  tags = {
    Name = "DB_Subnet_A"
  }
}

resource "aws_route_table_association" "db_route_association_a" {
  subnet_id      = aws_subnet.db_subnet_a.id
  route_table_id = aws_route_table.route_table_db.id
}

resource "aws_subnet" "db_subnet_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.db_subnet_b
  availability_zone = var.availability_zone_b
  tags = {
    Name = "DB_Subnet_B"
  }
}

resource "aws_route_table_association" "db_route_association_b" {
  subnet_id      = aws_subnet.db_subnet_b.id
  route_table_id = aws_route_table.route_table_db.id
}

#####################
### SECURITY ZONE ###
#####################

resource "aws_security_group" "ssh_security" {
  name   = "Remote Access Security Group"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "tcp"
    cidr_blocks = var.allow_ssh_ip
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SSH Security Group"
  }
}

resource "aws_iam_policy" "cloud_policy" {
  name   = "AllowEIPAssociateAddress"
  policy = file("./templates/cloud_policy.json")
  tags = {
    "Name" = "EC2_editing_policy"
  }
}

resource "aws_iam_role" "cloud_role" {
  name               = "RoleForEC2AssociateAddress"
  assume_role_policy = file("./templates/cloud_role.json")
}

resource "aws_iam_policy_attachment" "cloud_attach" {
  name       = "Cloud_attachment"
  roles      = ["${aws_iam_role.cloud_role.name}"]
  policy_arn = aws_iam_policy.cloud_policy.arn
}

#####################
### AUTO SCALING  ###
#####################

resource "aws_eip" "bastion_eip" {
  vpc = true
  tags = {
    Name = "Bastion_EIP"
  }
}

resource "aws_iam_instance_profile" "cloud_profile" {
  name = "Cloud_profile"
  role = aws_iam_role.cloud_role.name
}

resource "aws_launch_configuration" "bastion_lc" {
  name                        = "Bastion_LC"
  image_id                    = data.aws_ami.ami_latest_ami.id
  instance_type               = var.instance_type
  associate_public_ip_address = true
  key_name                    = var.pem_key
  iam_instance_profile        = aws_iam_instance_profile.cloud_profile.name
  security_groups             = ["${aws_security_group.ssh_security.id}"]
  user_data = templatefile("./templates/cloud-config.tpl", {
    bastion_eip = aws_eip.bastion_eip.id
  })
  depends_on = [
    aws_eip.bastion_eip
  ]
}

resource "aws_autoscaling_group" "bastion_ag" {
  name                 = "Bastion_ASG"
  max_size             = 1
  min_size             = 1
  health_check_type    = "EC2"
  vpc_zone_identifier  = ["${aws_subnet.public_subnet_a.id}", "${aws_subnet.public_subnet_b.id}"]
  launch_configuration = aws_launch_configuration.bastion_lc.name
  depends_on = [
    aws_eip.bastion_eip
  ]
}
