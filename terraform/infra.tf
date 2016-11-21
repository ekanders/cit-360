# Add your VPC ID to default below
variable "vpc_id" {
  description = "VPC ID for usage throughout the build process"
  default = "vpc-29bf4d4e"
}
variable "db_password"{
	
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

resource "aws_security_group" "group_db"{
	name="group_db"
	description = "assignment 3"

	ingress {
		from_port = 3306
		to_port= 3306
		protocol = "tcp"
		cidr_blocks = ["172.31.0.0/16"]
	}
	
}

resource "aws_db_subnet_group" "db_group" {
	name = "db_group"
	subnet_ids= ["${aws_subnet.us-west2a_private.id}", "${aws_subnet.us-west2b_private.id}"]

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

	egress {
	from_port = 0
	to_port = 0
	protocol = "-1"
	cidr_blocks = ["0.0.0.0/0"]
	}
}

resource "aws_security_group" "http_ssh" {
	name = "instance security"
	
	ingress {
		from_port = 22
		to_port = 22
		protocol = "tcp"
		cidr_blocks = ["172.31.0.0/16"]
	}

	ingress {
		from_port = 80
		to_port = 80
		protocol = "tcp"
		cidr_blocks = ["172.31.0.0/16"]
	}

        egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        }
}



resource "aws_security_group" "elb_group"{
	name= "ELB_security_group"
	
	ingress {
		from_port = 80
		to_port = 80
		protocol = "tcp"
		cidr_blocks= ["0.0.0.0/0"]
	}
	
	egress {
        	from_port = 0
        	to_port = 0
        	protocol = "-1"
        	cidr_blocks = ["0.0.0.0/0"]
        }
}





resource "aws_db_instance" "maria_db"{
	allocated_storage = 5
	engine = "mariadb"
	engine_version = "10.0.24"
	instance_class = "db.t2.micro"
	storage_type= "gp2"
	multi_az= false
	username = "root"
	password = "${var.db_password}"
	db_subnet_group_name = "${aws_db_subnet_group.db_group.id}"
	tags { 
	name="mariadb"
	}
}

resource "aws_elb" "bar" {
	listener {
		instance_port = 80
		instance_protocol = "http"
		lb_port = 80
		lb_protocol = "http"
	}
	
	health_check {
	   	timeout = 5
		healthy_threshold = 2
		unhealthy_threshold = 2
		target = "HTTP:80/"
		interval = 30
	}
	
	instances = ["${aws_instance.web_b.id}", "${aws_instance.web_c.id}"]
	connection_draining = true
	connection_draining_timeout = 60
	security_groups = ["${aws_security_group.elb_group.id}"]
	subnets = ["${aws_subnet.us-west2b_public.id}", "${aws_subnet.us-west2c_public.id}"]
		
	tags {
		name = "Load_balancer"
	}
}

resource "aws_instance" "web_b" {
    ami = "ami-5ec1673e"
    instance_type = "t2.micro"
    availability_zone = "us-west-2b"
    subnet_id = "${aws_subnet.us-west2b_private.id}"
    associate_public_ip_address = false
    key_name = "cit360"
     vpc_security_group_ids = ["${aws_security_group.http_ssh.id}"]
    tags {
        Name = "webserver-b"
	Service = "Curriculum"
    }
}

resource "aws_instance" "web_c" {
    ami = "ami-5ec1673e"
    instance_type = "t2.micro"
    availability_zone = "us-west-2c"
    subnet_id = "${aws_subnet.us-west2c_private.id}"
    associate_public_ip_address = false
    key_name = "cit360"
    vpc_security_group_ids = ["${aws_security_group.http_ssh.id}"]

    tags {
        Name = "webserver-c"
	Service = "curriculum"
    }
}

