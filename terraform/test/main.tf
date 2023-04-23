provider "aws" {
  region = "eu-west-3"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

#  vpc_zone_identifier  = data.aws_subnets.default.ids


#  subnets            = data.aws_subnets.default.ids


#  vpc_id   = data.aws_vpc.default.id


output "vpc" {
  value       = data.aws_vpc.default #.id
  description = "aws_vpc default"
}

output "subnets" {
  value = data.aws_subnets.default #.ids
  description = "aws_subnets"
}
