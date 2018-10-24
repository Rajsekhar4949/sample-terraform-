provider "aws" {
  region = "us-west-2"
}

#vpc
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags {
    Name = "main"
  }
}

#public subnet
resource "aws_subnet" "public_subnet" {
  availability_zone = "us-west-2a"
  cidr_block        = "10.0.1.0/24"
  vpc_id            = "${aws_vpc.main.id}"

  tags {
    Name = "public_raj"
  }
}

#private subnet
resource "aws_subnet" "private_subnet" {
  availability_zone = "us-west-2b"
  cidr_block        = "10.0.2.0/24"
  vpc_id            = "${aws_vpc.main.id}"

  tags {
    Name = "private_raj"
  }
}

#internet gateway
resource "aws_internet_gateway" "raj_ig" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name = "Raj_IG"
  }
}

#Elastic ip
resource "aws_eip" "raj_eip" {
  vpc = true

  tags {
    Name = "Raj-eip"
  }
}

#Natgateway
resource "aws_nat_gateway" "raj_nat_gateway" {
  allocation_id = "${aws_eip.raj_eip.id}"
  subnet_id     = "${aws_subnet.public_subnet.id}"

  tags {
    Name = "Raj-NAT"
  }
}

#RouteTable public
resource "aws_route_table" "public_route" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.raj_ig.id}"
  }
}

#RouteTable private
resource "aws_route_table" "private_route" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.raj_nat_gateway.id}"
  }
}

#subnet asscoiation public
resource "aws_route_table_association" "RTpublic" {
  subnet_id      = "${aws_subnet.public_subnet.id}"
  route_table_id = "${aws_route_table.public_route.id}"
}

#subnet association private
resource "aws_route_table_association" "RTprivate" {
  subnet_id      = "${aws_subnet.private_subnet.id}"
  route_table_id = "${aws_route_table.private_route.id}"
}

#ec2 instance
resource "aws_instance" "my_instance" {
  ami           = "ami-a0cfeed8"
  instance_type = "t2.micro"
  subnet_id     = "${aws_subnet.public_subnet.id}"
}
