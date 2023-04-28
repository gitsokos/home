variable "instance_name" {
  type          = string
  default       = "main_instance"
}

variable "type" {
  type          = string
  default       = "t2.large"
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

resource "aws_key_pair" "ec2-ssh-pub" {
  key_name   = "ec2_rsa"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDUYjxF3kIZB7OeYAgRPEYCUvcTwzsEa1BsIk/odnCvphRVdhwEWdtmVuNPe4aoWCFPgQ/UB8AFIfbyunzVon088wdqmPLtA5pKGPC2Gn6kSxq5yK4+jhNVKT+qcHnS6FeTdCGDKZehoeTq6usE9FFI+56nfgvYXBJ2DjWvl7kn/fsbrU5Q30JAbDioDY9QSrPgJxGBJC62MDH3ryckqBDNwsE3O988bA85Zl3oGlYOsMis0JZIxvJJ1OX9+iEtxJjwT2FaWV/B0hl2ZhcBUry25L/nVWiQHWI6NH8o0Fj9qCFOiiTWFrri62J9YrDNS1eSv+kI9Y4X0peDeinuV2zq1Dmdyxwy+dOCHVcj7jEmb+WR1ALgipsHN27PiRMnnBiVcyQtNa/YcNbxgEIz3wYTmYFQI8EF2IjEBb0CmuoB9b5iSB8fv1Z/ebSIGqSh3slKJ5vV1EgU2bUocP3DC6tCYlIBoqolJ9IwgxholwyE+Bv4RMger9R5R6aN9P39hC0= george@experimental"

}

output "instance_nodes" {
  value = [aws_instance.redrive.*.public_dns, aws_instance.redrive.*.tags.Name]
}

////////////////////////////////////////////////

/*
locals {
  sshPrivateKey = "/home/DMALEAS/AWS_XA/a.pem"
}
*/


resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"

  ingress {
    from_port   = 0 #22
    to_port     = 0 #22
    protocol    = "-1" # "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # "-1" stands for all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_role" "ec2_sqs_role" {
  name = "ec2-sqs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "sqs_full_access" {
  name        = "sqs-full-access"
  description = "Grant full access to SQS"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sqs:*"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "sqs_full_access" {
  policy_arn = aws_iam_policy.sqs_full_access.arn
  role       = aws_iam_role.ec2_sqs_role.name
}


resource "aws_instance" "redrive" {
  ami           = "ami-0b7fd829e7758b06d" # Amazon Linux 2 AMI
  instance_type = "t2.micro"

  key_name = "ec2_rsa"
#  key_name             = "awsredrive"
  iam_instance_profile = aws_iam_instance_profile.ec2_sqs_role.name
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  tags = {
    Name = "awsredrive"
  }

  user_data = file("awsredrive.sh")

}

resource "aws_iam_instance_profile" "ec2_sqs_role" {
  name = "ec2-sqs-role"
  role = aws_iam_role.ec2_sqs_role.name
}

output "instance_public_ip" {
  value = aws_instance.redrive.public_ip
}

//------------------------------------------------------------------------------------------

resource "aws_sns_topic" "example_topic" {
  name            = "example-topic"
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

resource "aws_sqs_queue" "example_queue" {
  name = "example_queue"
  depends_on = [
    aws_iam_policy_attachment.example_attachment
  ]

}


#resource "aws_sns_topic_subscription" "user_updates_emails" {
#  topic_arn = aws_sns_topic.example_topic.arn
#  protocol  = "email"
#  for_each  = toset(["grtsokos@gmail.com"])
#  endpoint  = each.value
#}

resource "aws_sns_topic_subscription" "user_updates_sqs" {
  topic_arn = aws_sns_topic.example_topic.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.example_queue.arn
}

resource "aws_sqs_queue_policy" "example_queue_policy" {
  queue_url = aws_sqs_queue.example_queue.url

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action = [
          "sqs:SendMessage",
          "sqs:CreateQueue",    #
          "sqs:GetQueueUrl",    #
          "sqs:ListQueues"      #
        ]
        Resource = aws_sqs_queue.example_queue.arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_sns_topic.example_topic.arn
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "example_policy" {
  name        = "sqs-create-policy"
  description = "Allows users to create SQS resources"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:CreateQueue",
          "sqs:GetQueueUrl",
          "sqs:ListQueues"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "example_attachment" {
  name       = "sqs-create-attachment"
  policy_arn = aws_iam_policy.example_policy.arn
  users      = ["terraform"]

}
