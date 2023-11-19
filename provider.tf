provider "aws" {
  region = "us-east-1"
}

###### vpc ##########
resource "aws_vpc" "myvpc3" {
  cidr_block       = "10.0.0.0/16"

  tags = {
    Name = "vpc"
  }
}

######## internet gateway #######
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc3.id 

  tags = {
    Name = "internet gateway"
  }
}

######## Subnet 1 ###########
resource "aws_subnet" "subnet1" {
  vpc_id     = aws_vpc.myvpc3.id
  cidr_block = "10.0.0.0/17"

  tags = {
    Name = "subnet1"
  }
}

####### Subnet 2 ##########
resource "aws_subnet" "Subnet2" {
  vpc_id     = aws_vpc.myvpc3.id
  cidr_block = "10.0.128.0/17"

  tags = {
    Name = "subnet2"
  }
}


######## route table ##########
resource "aws_route_table" "rt1" {
  vpc_id = aws_vpc.myvpc3.id

  route = []

  tags = {
    Name = "route table 1"
  }
}

######### route ###########
resource "aws_route" "route" {
  route_table_id            = aws_route_table.rt1.id
  destination_cidr_block    = "0.0.0.0/0"
#   vpc_peering_connection_id = "pcx-45ff3dc1" 
  gateway_id = aws_internet_gateway.igw.id
  depends_on = [aws_route_table.rt1]
}

########## rt- associate with subnet ######
 resource "aws_route_table_association" "subnetassociate1" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.rt1.id
}

 resource "aws_route_table_association" "subnetassociate2" {
  subnet_id      = aws_subnet.Subnet2.id
  route_table_id = aws_route_table.rt1.id
}

######## seccurity group ###########
resource "aws_security_group" "sg" {
  name        = "vpc_sg"
  description = "Allow all traffic"
  vpc_id      = aws_vpc.myvpc3.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = null
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_all traffic"
  }
}

# ######## key pair ############
# resource "aws_key_pair" "deployer_keypair_tf" {
#   key_name   = "deployer-keypair_tf"
#   public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 email@example.com"
# }


###### ec2 for subnet 1 #######
resource "aws_instance" "web1" {
  ami           = "ami-0bb4c991fa89d4b9b"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.subnet1.id
  key_name = "aws-login-key-pair"

   user_data = <<-EOF
    ${file("userdata.sh")}
  EOF

  tags = {
    Name = "ec2 1"
  }
}

###### ec2 for subnet 2 ########
resource "aws_instance" "web2" {
  ami           = "ami-0bb4c991fa89d4b9b"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.Subnet2.id
  key_name = "newkey"

  tags = {
    Name = "ec2 2"
  }
}