resource "aws_vpc" "devops-vpc" {
  cidr_block       = var.vpc
  instance_tenancy = "default"
}

#Create two private subnet for web resources
resource "aws_subnet" "web-subnet" {
  vpc_id                  = aws_vpc.devops-vpc.id
  cidr_block              = element(var.web-subnet-cidr, count.index)
  availability_zone       = element(var.availability_zone, count.index)
  map_public_ip_on_launch = false
  count                   = length(var.web-subnet-cidr)

  depends_on = [aws_vpc.devops-vpc]
}

#Create two public subnet for public resources like alb
resource "aws_subnet" "public-subnet" {
  vpc_id                  = aws_vpc.devops-vpc.id
  cidr_block              = element(var.public-subnet-cidr, count.index)
  availability_zone       = element(var.availability_zone, count.index)
  map_public_ip_on_launch = false
  count                   = length(var.public-subnet-cidr)

  depends_on = [aws_vpc.devops-vpc]
}


#Access outside resources
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.devops-vpc.id

  depends_on = [aws_vpc.devops-vpc]
}


#Routing for  servers to access internet via NATGW
resource "aws_eip" "eip" {
    domain = "vpc"
    count = 2
    depends_on = [aws_internet_gateway.igw]
}

resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.eip[count.index].id
  subnet_id     = aws_subnet.public-subnet[count.index].id
  count = 2
  tags = {
    Name = "NAT GW"
  }
  depends_on = [aws_internet_gateway.igw]
}


resource "aws_route_table" "route-ngw" {
  count = 2
  vpc_id = aws_vpc.devops-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ngw[count.index].id
  }
  tags = {
    Name = "Used to access to internet via NATGW"
  }
  depends_on = [aws_nat_gateway.ngw]
}


resource "aws_route_table_association" "rt-web" {
  count =2
  subnet_id      = aws_subnet.web-subnet[count.index].id
  route_table_id = aws_route_table.route-ngw[count.index].id
  depends_on = [aws_route_table.route-ngw]
  
}

# Route tables for public subnets to IGW
resource "aws_route_table" "route-public" {
  vpc_id = aws_vpc.devops-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_route_table_association" "rt-public" {
  count = 2
  subnet_id      = aws_subnet.public-subnet[count.index].id
  route_table_id = aws_route_table.route-public.id
  depends_on = [aws_internet_gateway.igw]
}


resource "aws_security_group" "www-to-alb" {
    vpc_id              = aws_vpc.devops-vpc.id
    name                = "www-to-alb"
    description         = "Access from WWW to ALB"
    dynamic "ingress" {
        for_each = var.alb-port
        content {
          protocol = "tcp"
          from_port = ingress.value
          to_port = ingress.value
          cidr_blocks = [ "0.0.0.0/0" ]
        }      
    }
    egress {
        protocol = "-1"
        from_port = 0
        to_port = 0
        cidr_blocks = [ "0.0.0.0/0" ]
    }
}


resource "aws_security_group" "alb-to-web" {
    vpc_id              = aws_vpc.devops-vpc.id
    name                = "alb-to-web"
    description         = "Access from ALB to WEB subnet"
    dynamic "ingress" {
        for_each = var.web-ec2-port
        content {
          protocol = "tcp"
          from_port = ingress.value
          to_port = ingress.value
          cidr_blocks = var.public-subnet-cidr
        }     
    }
    egress {
        protocol = "-1"
        from_port = 0
        to_port = 0
        cidr_blocks = [ "0.0.0.0/0" ]
    }
}
