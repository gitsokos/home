provider "aws" {
  region = "eu-west-3"
}

################################## Variables ####################################

variable "instance_name" {
  type		= string
  default	= "main_instance"	
}

variable "type" {
  type		= string
  default	= "t2.large"
}

#resource "aws_instance" "node" {
#  ami           = "ami-0c6ebbd55ab05f070"
#  instance_type = var.type
#  tags = {
#    Name = var.instance_name
#  }
#  key_name = "ec2_rsa"
#  vpc_security_group_ids = [aws_security_group.main.id]
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


#resource "aws_key_pair" "deployer" {
#  key_name   = "ec2_rsa"
#  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDUYjxF3kIZB7OeYAgRPEYCUvcTwzsEa1BsIk/odnCvphRVdhwEWdtmVuNPe4aoWCFPgQ/UB8AFIfbyunzVon088wdqmPLtA5pKGPC2Gn6kSxq5yK4+jhNVKT+qcHnS6FeTdCGDKZehoeTq6usE9FFI+56nfgvYXBJ2DjWvl7kn/fsbrU5Q30JAbDioDY9QSrPgJxGBJC62MDH3ryckqBDNwsE3O988bA85Zl3oGlYOsMis0JZIxvJJ1OX9+iEtxJjwT2FaWV/B0hl2ZhcBUry25L/nVWiQHWI6NH8o0Fj9qCFOiiTWFrri62J9YrDNS1eSv+kI9Y4X0peDeinuV2zq1Dmdyxwy+dOCHVcj7jEmb+WR1ALgipsHN27PiRMnnBiVcyQtNa/YcNbxgEIz3wYTmYFQI8EF2IjEBb0CmuoB9b5iSB8fv1Z/ebSIGqSh3slKJ5vV1EgU2bUocP3DC6tCYlIBoqolJ9IwgxholwyE+Bv4RMger9R5R6aN9P39hC0= george@experimental"

#}


resource "aws_sns_topic" "user_updates" {
  name            = "user-updates-topic"
  delivery_policy = <<EOF
{
  "http": {
    "defaultHealthyRetryPolicy": {
      "minDelayTarget": 20,
      "maxDelayTarget": 20,
      "numRetries": 3,
      "numMaxDelayRetries": 0,
      "numNoDelayRetries": 0,
      "numMinDelayRetries": 0,
      "backoffFunction": "linear"
    },
    "disableSubscriptionOverrides": false,
    "defaultThrottlePolicy": {
      "maxReceivesPerSecond": 1
    }
  }
}
EOF
}

resource "aws_sqs_queue" "test_queue" {
  name = "test_queue"
}


resource "aws_sns_topic_subscription" "user_updates_emails" {
  topic_arn = aws_sns_topic.user_updates.arn
  protocol  = "email"
  for_each  = toset(["grtsokos@gmail.com"])
  endpoint  = each.value
}

resource "aws_sns_topic_subscription" "user_updates_sqs" {
  topic_arn = aws_sns_topic.user_updates.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.test_queue.arn
}

resource "aws_sqs_queue_policy" "example_queue_policy" {
  queue_url = aws_sqs_queue.test_queue.url

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action = [
          "sqs:SendMessage"
        ]
        Resource = aws_sqs_queue.test_queue.arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_sns_topic.user_updates.arn
          }
        }
      }
    ]
  })
}


#################### output #################################################################

#output "instance_nodes" {
#  value = [aws_instance.node.*.public_dns, aws_instance.node.*.tags.Name]
#}
