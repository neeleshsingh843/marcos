provider "aws" {

}
resource "aws_vpc" "vpc1" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "vpc1"
  }
}

resource "aws_internet_gateway" "ig1" {
    depends_on = [ aws_vpc.vpc1 ]
  vpc_id = aws_vpc.vpc1.id
  tags = {
    Name = "ig1"
  }
}
resource "aws_subnet" "sub1" {
    depends_on = [ aws_vpc.vpc1 ]
  vpc_id            = aws_vpc.vpc1.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "ap-south-1a"
}
resource "aws_route_table" "rt1" {
    depends_on = [ aws_vpc.vpc1 ]
  vpc_id = aws_vpc.vpc1.id
  tags = {
    Name = "rt1"
  }

}
resource "aws_route" "name" {
  depends_on             = [aws_route_table.rt1,aws_internet_gateway.ig1]
  route_table_id         = aws_route_table.rt1.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ig1.id

}
resource "aws_route_table_association" "name" {
  depends_on     = [aws_route_table.rt1]
  subnet_id      = aws_subnet.sub1.id
  route_table_id = aws_route_table.rt1.id
}
resource "aws_security_group" "sg01" {
  name        = "sg01"
  description = "Security group for instance1"
  vpc_id      = aws_vpc.vpc1.id
  depends_on = [ aws_vpc.vpc1 ]
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_instance" "instance1" {
    depends_on = [ aws_vpc.vpc1,aws_internet_gateway.ig1 ]
  vpc_security_group_ids      = [aws_security_group.sg01.id]
  ami                         = "ami-0d03cb826412c6b0f" # Replace with a valid AMI ID
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.sub1.id
  key_name                    = "pilot"
  associate_public_ip_address = true
  tags = {
    Name = "instance1"
  }
  user_data = file("demo.sh")

}



#============= VPC -2===========================

provider "aws" {
  region = "us-east-1"
  alias  = "us"
}

resource "aws_vpc" "vpc2" {
  provider   = aws.us
  cidr_block = "10.1.0.0/16"
  tags = {
    Name = "vpc2"
  }
}
resource "aws_internet_gateway" "ig2" {
    depends_on = [ aws_vpc.vpc2 ]
  provider = aws.us
  vpc_id   = aws_vpc.vpc2.id
  tags = {
    Name = "ig2"
  }

}

resource "aws_subnet" "sub20" {
    depends_on = [ aws_vpc.vpc2 ]
  provider          = aws.us
  vpc_id            = aws_vpc.vpc2.id
  cidr_block        = "10.1.1.0/24"
  availability_zone = "us-east-1a"

}
resource "aws_subnet" "sub21" {
    depends_on = [ aws_vpc.vpc2 ]
  provider          = aws.us
  vpc_id            = aws_vpc.vpc2.id
  cidr_block        = "10.1.2.0/24"
  availability_zone = "us-east-1b"

}
resource "aws_route_table" "rt20" {
    provider = aws.us
    depends_on = [ aws_vpc.vpc2 ]
    vpc_id = aws_vpc.vpc2.id
  tags = {
    Name = "rt20"
  }
}
resource "aws_route" "name2" {
    provider = aws.us
  depends_on             = [aws_route_table.rt20]
  route_table_id         = aws_route_table.rt20.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ig2.id
}
resource "aws_route_table_association" "name2" {
    provider = aws.us
  depends_on     = [aws_route_table.rt20]
  route_table_id = aws_route_table.rt20.id

  subnet_id      = aws_subnet.sub20.id
}

resource "aws_eip" "eip2" {
    
    depends_on = [ aws_vpc.vpc2 ]
  provider = aws.us
  tags = {
    Name = "eip2"
  }
  
}
resource "aws_nat_gateway" "name2" {
  provider = aws.us
  depends_on = [aws_vpc.vpc2 ,aws_eip.eip2 ]
  subnet_id = aws_subnet.sub20.id
  connectivity_type = "public"
  allocation_id = aws_eip.eip2.id

}
resource "aws_route_table" "rt21" {
  provider = aws.us
    depends_on = [ aws_vpc.vpc2 , aws_nat_gateway.name2 ]
  vpc_id = aws_vpc.vpc2.id
  tags = {
    Name = "rt21"
  }
}
resource "aws_route" "name3" {
  provider= aws.us
    depends_on = [ aws_route_table.rt21 ]
  route_table_id         = aws_route_table.rt21.id
  nat_gateway_id         = aws_nat_gateway.name2.id
  destination_cidr_block = "0.0.0.0/0"

}
resource "aws_route_table_association" "name3" {
  provider = aws.us
    depends_on = [ aws_route_table.rt21 ]
  route_table_id = aws_route_table.rt21.id
  subnet_id      = aws_subnet.sub21.id
}

resource "aws_security_group" "sg02" {
  provider = aws.us
    depends_on = [ aws_vpc.vpc2 ]
  name        = "sg02"
  description = "Security group for instance2"
  vpc_id      = aws_vpc.vpc2.id
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_instance" "instance2" {
    provider = aws.us
  depends_on = [ aws_vpc.vpc2,aws_nat_gateway.name2 ]
  vpc_security_group_ids      = [aws_security_group.sg02.id]
  ami                         = "ami-05ffe3c48a9991133" # Replace with a valid AMI ID
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.sub21.id
  key_name                    = "useast1"
  associate_public_ip_address = false
  tags = {
    Name = "instance2"
  }
  user_data = file("demo2.sh")

}

#============= VPC PEERING ================

resource "aws_vpc_peering_connection" "peer" {
  provider = aws
  depends_on = [ aws_vpc.vpc1]
  vpc_id   = aws_vpc.vpc1.id
  peer_region = "us-east-1"
  peer_vpc_id = aws_vpc.vpc2.id
  auto_accept = false
  tags = {
    Name = "vpc-peering-connection"
  }
  
}
resource "aws_vpc_peering_connection_accepter" "accepter" {
  provider = aws.us
  depends_on = [ aws_vpc_peering_connection.peer ]
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
  auto_accept = true
  tags = {
    Name = "vpc-peering-connection-accepter"
  }
}
resource "aws_route" "name10" {
  provider = aws
  depends_on = [ aws_vpc_peering_connection.peer, aws_instance.instance1 ]
  route_table_id         = aws_route_table.rt1.id
  destination_cidr_block = aws_vpc.vpc2.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}
resource "aws_route" "name20" {
  provider = aws.us
  depends_on = [ aws_vpc_peering_connection.peer,aws_instance.instance2 ]
  route_table_id         = aws_route_table.rt20.id
  destination_cidr_block = aws_vpc.vpc1.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}
resource "aws_route" "name21" {
  provider = aws.us
  depends_on = [ aws_vpc_peering_connection.peer,aws_instance.instance2 ]
  route_table_id         = aws_route_table.rt21.id
  destination_cidr_block = aws_vpc.vpc1.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}
