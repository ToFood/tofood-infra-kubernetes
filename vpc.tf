# Declaração do recurso de dados para obter as zonas de disponibilidade
data "aws_availability_zones" "available" {
  state = "available"
}

# Recurso VPC
resource "aws_vpc" "tofood_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "tofood-vpc"
  }
}

# Recurso de sub-redes
resource "aws_subnet" "tofood_subnets" {
  count             = 3
  vpc_id            = aws_vpc.tofood_vpc.id
  cidr_block        = "10.0.${count.index}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "tofood-subnet-${count.index}"
  }
}
