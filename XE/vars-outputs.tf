################################	Variables	##############################################
 
variable "instance_name" {
  type          = string
  default       = "redrive"
}

variable "type" {
  type          = string
  default       = "t2.micro"
}

variable "ami" {
  type          = string
  default       ="ami-0b7fd829e7758b06d"	# Amazon Linux 2 @eu-central-1
#  default       ="ami-0c6ebbd55ab05f070"	# Ubuntu @eu-west-3
}

variable "key_name" {
  type		= string
  default	= "ec2_rca"
}

variable "pub_key" {
  type		= string
  default	= "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDUYjxF3kIZB7OeYAgRPEYCUvcTwzsEa1BsIk/odnCvphRVdhwEWdtmVuNPe4aoWCFPgQ/UB8AFIfbyunzVon088wdqmPLtA5pKGPC2Gn6kSxq5yK4+jhNVKT+qcHnS6FeTdCGDKZehoeTq6usE9FFI+56nfgvYXBJ2DjWvl7kn/fsbrU5Q30JAbDioDY9QSrPgJxGBJC62MDH3ryckqBDNwsE3O988bA85Zl3oGlYOsMis0JZIxvJJ1OX9+iEtxJjwT2FaWV/B0hl2ZhcBUry25L/nVWiQHWI6NH8o0Fj9qCFOiiTWFrri62J9YrDNS1eSv+kI9Y4X0peDeinuV2zq1Dmdyxwy+dOCHVcj7jEmb+WR1ALgipsHN27PiRMnnBiVcyQtNa/YcNbxgEIz3wYTmYFQI8EF2IjEBb0CmuoB9b5iSB8fv1Z/ebSIGqSh3slKJ5vV1EgU2bUocP3DC6tCYlIBoqolJ9IwgxholwyE+Bv4RMger9R5R6aN9P39hC0= george@experimental"
}

################################	Output		##############################################

output "instance_public_ip" {
  value = aws_instance.redrive.public_ip
}

output "instance" {
  value = aws_instance.redrive.public_dns
}

