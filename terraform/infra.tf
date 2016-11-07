# Add your VPC ID to default below
variable "vpc_id" {
  description = "VPC ID for usage throughout the build process"
  default = "vpc-29bf4d4e"
}

provider "aws" {
  region = "us-west-2"
}

resource "aws_instance" "Bastion" {
    ami = "ami-5ec1673e"
    instance_type = "t2.micro"
    availability_zone = "us-west-2a"
    subnet_id = "${aws_subnet.us-west2a_public.id}"
    associate_public_ip_address = true
    key_name = "cit360"
    tags {
        Name = "Bastion"
    }
    vpc_security_group_ids = ["${aws_security_group.allow_ssh.id}"]
}
resource "aws_internet_gateway" "gw" {
  vpc_id = "${var.vpc_id}"

  tags = {
    Name = "default_ig"
  }
}
#Create elastic IP
resource "aws_eip" "natIP" {
  vpc      = true
}

resource "aws_nat_gateway" "natGw" {
    allocation_id = "${aws_eip.natIP.id}"
    subnet_id = "${aws_subnet.us-west2a_public.id}"
}



resource "aws_route_table" "public_routing_table" {
  vpc_id = "${var.vpc_id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }

  tags {
    Name = "public_routing_table"
  }
}

resource "aws_route_table" "private_routing_table" {
  vpc_id = "${var.vpc_id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.natGw.id}"
  }

  tags {
    Name = "private_routing_table"
  }
}

#Create private subnets
resource "aws_subnet" "us-west2a_private" {
    vpc_id = "${var.vpc_id}"
    cidr_block = "172.31.0.0/22"
	availability_zone = "us-west-2a"

    tags {
        Name = "us-west2a_private"
    }
}

resource "aws_subnet" "us-west2b_private" {
    vpc_id = "${var.vpc_id}"
    cidr_block = "172.31.4.0/22"
	availability_zone = "us-west-2b"


    tags {
        Name = "us-west2b_private"
    }
}

resource "aws_subnet" "us-west2c_private" {
    vpc_id = "${var.vpc_id}"
    cidr_block = "172.31.8.0/22"
	availability_zone = "us-west-2c"


    tags {
        Name = "us-west-2c_private"
    }
}

#Create public subnets
resource "aws_subnet" "us-west2a_public" {
    vpc_id = "${var.vpc_id}"
    cidr_block = "172.31.12.0/24"
        availability_zone = "us-west-2a"

    tags {
        Name = "us_west-2a_public"
    }
}

resource "aws_subnet" "us-west2b_public" {
    vpc_id = "${var.vpc_id}"
    cidr_block = "172.31.13.0/24"
        availability_zone = "us-west-2b"


    tags {
        Name = "us-west-2b_public"
    }
}

resource "aws_subnet" "us-west2c_public" {
    vpc_id = "${var.vpc_id}"
    cidr_block = "172.31.14.0/24"
        availability_zone = "us-west-2c"


    tags {
        Name = "us-west-2c_public"
    }
}

#End Of Subnets

resource "aws_route_table_association" "public_subnet_a_rt_assoc" {
    subnet_id = "${aws_subnet.us-west2a_public.id}"
    route_table_id = "${aws_route_table.public_routing_table.id}"
}
resource "aws_route_table_association" "public_subnet_b_rt_assoc" {
    subnet_id = "${aws_subnet.us-west2b_public.id}"
    route_table_id = "${aws_route_table.public_routing_table.id}"
}

resource "aws_route_table_association" "public_subnet_c_rt_assoc" {
    subnet_id = "${aws_subnet.us-west2c_public.id}"
    route_table_id = "${aws_route_table.public_routing_table.id}"
}

resource "aws_route_table_association" "private_subnet_a_rt_assoc" {
    subnet_id = "${aws_subnet.us-west2a_private.id}"
    route_table_id = "${aws_route_table.private_routing_table.id}"
}

resource "aws_route_table_association" "private_subnet_b_rt_assoc" {
    subnet_id = "${aws_subnet.us-west2b_private.id}"
    route_table_id = "${aws_route_table.private_routing_table.id}"
}

resource "aws_route_table_association" "private_subnet_c_rt_assoc" {
    subnet_id = "${aws_subnet.us-west2c_private.id}"
    route_table_id = "${aws_route_table.private_routing_table.id}"
}

resource "aws_security_group" "allow_ssh" {
  name = "allow_ssh"
  description = "Allow ssh traffic"

  ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["130.166.220.254/32"]
     }

}