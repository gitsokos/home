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
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
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

  key_name             = "awsredrive"
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
