#vpc

resource "aws_vpc" "network-vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "vpc-${var.project_name}"
  }
}

#subnet

resource "aws_subnet" "public-subnets" {
  count                   = length(local.selected_azs)
  vpc_id                  = aws_vpc.network-vpc.id
  availability_zone       = local.selected_azs[count.index]
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-${var.project_name}-${count.index}"
  }
}

resource "aws_subnet" "pvt-subnets" {
  count             = length(local.selected_azs)
  vpc_id            = aws_vpc.network-vpc.id
  availability_zone = local.selected_azs[count.index]
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + length(local.selected_azs))
  tags = {
    Name = "private-subnet-${var.project_name}-${count.index}"
  }
}

#gateway

resource "aws_internet_gateway" "my-igw" {
  vpc_id = aws_vpc.network-vpc.id
  tags = {
    Name = "igw-${var.project_name}"
  }
}

resource "aws_eip" "nat-eip" {
  tags = {
    Name = "nat-eip-${var.project_name}"
  }
}

resource "aws_nat_gateway" "nat-gateway" {
  allocation_id = aws_eip.nat-eip.id
  subnet_id     = aws_subnet.public-subnets[1].id
  tags = {
    Name = "nat-gateway-${var.project_name}"
  }
}

#route table

resource "aws_route_table" "pub-rt" {
  vpc_id = aws_vpc.network-vpc.id
  route {
    gateway_id = aws_internet_gateway.my-igw.id
    cidr_block = "0.0.0.0/0"
  }
  tags = {
    Name = "public-rt-${var.project_name}"
  }
}

resource "aws_route_table" "pvt-rt" {
  vpc_id = aws_vpc.network-vpc.id
  route {
    gateway_id = aws_nat_gateway.nat-gateway.id
    cidr_block = "0.0.0.0/0"
  }
  tags = {
    Name = "pvt-rt-${var.project_name}"
  }
}

#route table association
resource "aws_route_table_association" "pub-rt-assoc" {
  count          = length(aws_subnet.public-subnets)
  subnet_id      = aws_subnet.public-subnets[count.index].id
  route_table_id = aws_route_table.pub-rt.id
}

resource "aws_route_table_association" "pvt-rt-assoc" {
  count          = length(aws_subnet.pvt-subnets)
  subnet_id      = aws_subnet.pvt-subnets[count.index].id
  route_table_id = aws_route_table.pvt-rt.id
}