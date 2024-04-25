resource "aws_vpc" "main_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "main_vpc"
  }
}

resource "aws_subnet" "public" {
  count = var.az_count
  # cidr subnetting to get a /24 subnet, it will start from 10.0.11.0/24 to 10.0.11.255/24
  #8 bits more on the mask to be /24, 10+1 because we are using only one availability zone
  cidr_block              = cidrsubnet(aws_vpc.main_vpc.cidr_block, 8, 20 + count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  vpc_id                  = aws_vpc.main_vpc.id
  map_public_ip_on_launch = true

  tags = var.resource_tags
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc_internet_gateway.id
  }

  tags = var.resource_tags
}

resource "aws_route_table_association" "public" {
  count          = var.az_count
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_main_route_table_association" "public_main" {
  vpc_id         = aws_vpc.main_vpc.id
  route_table_id = aws_route_table.public.id
}

resource "aws_subnet" "private" {
  count             = var.az_count
  cidr_block        = cidrsubnet(aws_vpc.main_vpc.cidr_block, 8, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  vpc_id            = aws_vpc.main_vpc.id
  tags              = var.resource_tags
}

resource "aws_route_table" "private" {
  count  = var.az_count
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway[count.index].id
  }

  tags = var.resource_tags
}

resource "aws_route_table_association" "private" {
  count          = var.az_count
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

## Creates one Elastic IP for the NAT Gateway, as we are using only one availability zone
resource "aws_nat_gateway" "nat_gateway" {
  count         = var.az_count
  subnet_id     = aws_subnet.public[count.index].id
  allocation_id = aws_eip.nat_gateway_elastic_ip[count.index].id
  tags          = var.resource_tags
  depends_on = [aws_eip.nat_gateway_elastic_ip]
}

resource "aws_eip" "nat_gateway_elastic_ip" {
  count      = var.az_count
  domain     = "vpc"
  tags       = var.resource_tags
}

resource "aws_internet_gateway" "vpc_internet_gateway" {
  vpc_id = aws_vpc.main_vpc.id
  tags   = var.resource_tags
}