resource "aws_security_group" "sg" {
  description = "inbound allow for ${var.tool_name}"

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = "var.sg_port"
    to_port   = "var.sg_port"
    protocol  = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


tags = {
  Name = "${var.tool_name}-sg"
}

resource "aws_instance" "instance" {
  ami           = "data.aws_ami.ami.id"
  instance_type = "var.instance_type"
  vpc_security_group_ids = ["aws_seurity_group.sg.id"]
  tags = {
    name = var.tool_name
  }
}

resource "aws_route53_record" "record-public" {
zone_id = var.zone_id
name = "${var.tool_name}-${var.env}.${var.domain_name}"
type = "A"
ttl  = "30"
records = [aws_instance.instance.public_ip]
}

resource "aws_route53_record" "record-internal" {
zone_id = var.zone_id
name = "$(var.tool_name)-internal.${var.domain_name}"
type = "A"
ttl  = "30"
records = [aws_instance.instance.private_ip]
}


# provisioner "local-exec" {
#   command = <<EOL
#   /home/ec2-user/roboshop-ansible
# ansible-playbook -i ${self.private_ip}, -e ansible_user=ec2-user -e ansible_password=Devops321-e app_name=${var.component_name} -e env=$(var.env) roboshop.yml
#  }
# }