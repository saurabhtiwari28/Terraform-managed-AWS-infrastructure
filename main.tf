resource "aws_vpc" "main"{
    cidr_block = var.cidr
}

resource "aws_subnet" "subnet1"{
    vpc_id = aws_vpc.main.id
    cidr_block = "10.0.0.0/24"
    availability_zone = "us-east-1a"
    map_public_ip_on_launch = true
}

resource "aws_subnet" "subnet2" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "igw"{
    vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "route1"{
    vpc_id = aws_vpc.main.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }
}

resource "aws_route_table_association" "rta1"{
    subnet_id = aws_subnet.subnet1.id
    route_table_id = aws_route_table.route1.id
}

resource "aws_route_table_association" "rta2"{
    subnet_id = aws_subnet.subnet2.id
    route_table_id = aws_route_table.route1.id
}

resource "aws_security_group" "sg" {
  name        = "security-group"
  description = "Security group for HTTP and SSH access"
  vpc_id      = aws_vpc.main.id
}

# HTTP ingress rule
resource "aws_security_group_rule" "http_ingress" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg.id
}

# SSH ingress rule
resource "aws_security_group_rule" "ssh_ingress" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg.id
}

# Egress rule (allow all outbound traffic)
resource "aws_security_group_rule" "egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg.id
}

resource "aws_s3_bucket" "example" {
  bucket = "infra-with-aws"
}

resource "aws_instance" "web1" {
  ami = "ami-0e2c8caa4b6378d8c"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.sg.id]
  subnet_id = aws_subnet.subnet1.id
  user_data = base64encode(file("userdata.sh"))
}

resource "aws_instance" "web2"{
    ami = "ami-0e2c8caa4b6378d8c"
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.sg.id]
    subnet_id = aws_subnet.subnet2.id
    user_data = base64encode(file("userdata1.sh"))
}

#create alb

resource "aws_lb" "myalb"{
  name = "myalb"
  internal = false
  load_balancer_type = "application"

  security_groups = [aws_security_group.sg.id]
  subnets = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]

  tags = {
    Name = "Web"
  }
}

resource "aws_lb_target_group" "mytg"{
  name = "mytg"
  port = 80
  protocol = "HTTP"
  vpc_id = aws_vpc.main.id

  health_check {
    path = "/"
    port = "traffic-port"
  }
}

resource "aws_lb_target_group_attachment" "my-tg-a1"{
  target_group_arn = aws_lb_target_group.mytg.arn
  target_id  = aws_instance.web1.id
  port = 80
}

resource "aws_lb_target_group_attachment" "my-tg-a2"{
  target_group_arn = aws_lb_target_group.mytg.arn
  target_id = aws_instance.web2.id
  port = 80
}

resource "aws_lb_listener" "fe"{
  load_balancer_arn = aws_lb.myalb.arn
  port = "80"
  protocol = "HTTP" 

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.mytg.arn
  }
}

output "loadbalancers" {
    value = aws_lb.myalb.dns_name
  }