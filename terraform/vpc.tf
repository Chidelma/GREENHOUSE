
# VPC
# innternet gateway

resource "aws_vpc" "aws_practical" {
  cidr_block = "10.0.0.0/16"

  tags = local.tags
}

resource "aws_internet_gateway" "aws_practical" {
  vpc_id = aws_vpc.aws_practical.id

  tags = local.tags
}

# Public subnets (2 are required for EKS)
# * subnet
# * NAT gateway + elastic IP
# * route table + association

# Public subnet use-1a
resource "aws_subnet" "public_use_1a" {
  availability_zone       = "us-east-1a"
  cidr_block              = "10.0.1.0/24"
  vpc_id                  = aws_vpc.aws_practical.id
  map_public_ip_on_launch = true

  tags = local.tags
}

resource "aws_nat_gateway" "aws_practical_use_1a" {
  allocation_id = aws_eip.aws_practical_use_1a.id
  subnet_id     = aws_subnet.public_use_1a.id

  tags = local.tags

  depends_on = [ aws_eip.aws_practical_use_1a ]
}

resource "aws_eip" "aws_practical_use_1a" {
  domain = "vpc"

  tags = local.tags
}

resource "aws_route_table" "public_use_1a" {
  vpc_id = aws_vpc.aws_practical.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.aws_practical.id
  }

  tags = local.tags
}

resource "aws_route_table_association" "public_use_1a" {
  subnet_id      = aws_subnet.public_use_1a.id
  route_table_id = aws_route_table.public_use_1a.id
}

# Public subnet use-1b
resource "aws_subnet" "public_use_1b" {
  availability_zone       = "us-east-1b"
  cidr_block              = "10.0.2.0/24"
  vpc_id                  = aws_vpc.aws_practical.id
  map_public_ip_on_launch = true

  tags = local.tags
}

resource "aws_nat_gateway" "aws_practical_use_1b" {
  allocation_id = aws_eip.aws_practical_use_1b.id
  subnet_id     = aws_subnet.public_use_1b.id

  tags = local.tags

  depends_on = [ aws_eip.aws_practical_use_1b ]
}

resource "aws_eip" "aws_practical_use_1b" {
  domain = "vpc"

  tags = local.tags
}

resource "aws_route_table" "public_use_1b" {
  vpc_id = aws_vpc.aws_practical.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.aws_practical.id
  }

  tags = local.tags
}

resource "aws_route_table_association" "public_use_1b" {
  subnet_id      = aws_subnet.public_use_1b.id
  route_table_id = aws_route_table.public_use_1a.id
}

# Private subnets
# * subnet
# * route table + association

# Private subnet use-1a
resource "aws_subnet" "private_use_1a" {
  availability_zone = "us-east-1a"
  cidr_block        = "10.0.3.0/24"
  vpc_id            = aws_vpc.aws_practical.id

  tags = local.tags
}

resource "aws_route_table" "private_use_1a" {
  vpc_id = aws_vpc.aws_practical.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.aws_practical_use_1a.id
  }

  tags = local.tags
}

resource "aws_route_table_association" "private_use_1a" {
  subnet_id      = aws_subnet.private_use_1a.id
  route_table_id = aws_route_table.private_use_1a.id
}

# Private subnet use-1b
resource "aws_subnet" "private_use_1b" {
  availability_zone = "us-east-1b"
  cidr_block        = "10.0.4.0/24"
  vpc_id            = aws_vpc.aws_practical.id

  tags = local.tags
}

resource "aws_route_table" "private_use_1b" {
  vpc_id = aws_vpc.aws_practical.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.aws_practical_use_1b.id
  }

  tags = local.tags
}

resource "aws_route_table_association" "private_use_1b" {
  subnet_id      = aws_subnet.private_use_1b.id
  route_table_id = aws_route_table.private_use_1b.id
}
