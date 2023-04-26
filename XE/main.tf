variable "instance_name" {
  type		= string
  default	= "main_instance"	
}

variable "instances" {
  type		= number
  default	= 1
}

variable "type" {
  type		= string
  default	= "t2.large"
}

provider "aws" {
  region = "eu-west-3"
}


resource "aws_instance" "node" {
  ami           = "ami-0c6ebbd55ab05f070"
  instance_type = var.type
#  count         = var.instances
  tags = {
    Name = var.instance_name
#    Name = "${var.instance_name}${count.index}"
  }
  key_name = "id_rsa"
#  key_name = "nodes_rsa"
  vpc_security_group_ids = [aws_security_group.main.id]
#  provisioner "local-exec" {
#    command = "echo \"The server's IP address is ${self.private_ip}\""
#  }
}

#resource "local_file" "inventory" {
#  filename = var.inventory
#  file_permission = "0664"
#  content = <<-EOT
#    [nodes]
#    %{ for ip in aws_instance.node.*.public_ip ~}
#    ${ip} ansible_ssh_user=ubuntu
#    %{ endfor ~}
#  EOT
#}

resource "aws_security_group" "main" {
  egress = [
    {
      cidr_blocks      = ["0.0.0.0/0", ]
      description      = ""
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = []
      self             = false
      to_port          = 0 
    }
  ]
  ingress = [
    {
      cidr_blocks      = ["0.0.0.0/0", ]
      description      = ""
      from_port        = 0 # 22
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1" # "tcp"
      security_groups  = []
      self             = false
      to_port          = 0 #22
    }
  ]
}


resource "aws_key_pair" "deployer" {
  key_name   = "id_rsa"
#  key_name = "nodes_rsa"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDUYjxF3kIZB7OeYAgRPEYCUvcTwzsEa1BsIk/odnCvphRVdhwEWdtmVuNPe4aoWCFPgQ/UB8AFIfbyunzVon088wdqmPLtA5pKGPC2Gn6kSxq5yK4+jhNVKT+qcHnS6FeTdCGDKZehoeTq6usE9FFI+56nfgvYXBJ2DjWvl7kn/fsbrU5Q30JAbDioDY9QSrPgJxGBJC62MDH3ryckqBDNwsE3O988bA85Zl3oGlYOsMis0JZIxvJJ1OX9+iEtxJjwT2FaWV/B0hl2ZhcBUry25L/nVWiQHWI6NH8o0Fj9qCFOiiTWFrri62J9YrDNS1eSv+kI9Y4X0peDeinuV2zq1Dmdyxwy+dOCHVcj7jEmb+WR1ALgipsHN27PiRMnnBiVcyQtNa/YcNbxgEIz3wYTmYFQI8EF2IjEBb0CmuoB9b5iSB8fv1Z/ebSIGqSh3slKJ5vV1EgU2bUocP3DC6tCYlIBoqolJ9IwgxholwyE+Bv4RMger9R5R6aN9P39hC0= george@experimental"
#  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDthw0WqnKTurOCDD31mtV8NdBXffZm6BXXU86ri+IhTVd/z0MnxFSIvRTxvczrZynBnRH3k1PU4yHODcYP2cyoeEU2GxpeoWJ3CVgYYtNB8Oj3ev1EbyPgCW5g5eFHq4UAh29dxqw1pWE3hYUSShPoC8rdke4qSSnBV2SC8esIrsX6o+Nm/p7CVF5i5hHOUb9jL2qAHPMaGIntnhO7+Cyb7aPydiJ/2tdlOANQ1TfNKO6Lqp2yph3ql1wwudt5MEvrRgz89Dxod2heQe6o1D8cykhCpSktU/Fz1U/LBmI+R2UNaZrQ6XpMAgTeQitlub30hIMDvc6FrYRMThBbddcnF0ASlkt5b1g6+kWjbgXPxhbItNgUip3RZLkHHo0InrKOr24IBFJJKEGtf/uS2/JpavH1i7P9v6+vgRLmMfMozat9R62A5KhLzo0rUbKA1HicVqu8Q2bqUCYaNXXUUu0Z5HWgZYNX31nuQUf8Y0RVTSrP4021K8M/nuGrXipweo8= george@experimental"

}


output "instance_nodes" {
  value = [aws_instance.node.*.public_dns, aws_instance.node.*.tags.Name]
}
