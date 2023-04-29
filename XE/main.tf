provider "aws" {
  region = "eu-central-1"
}

resource "aws_instance" "redrive" {
  ami                    = var.ami
  instance_type          = var.type

  key_name               = aws_key_pair.ec2-ssh-pub.key_name
#  iam_instance_profile   = aws_iam_instance_profile.ec2_sqsrole.name
  vpc_security_group_ids = [aws_security_group.allowssh.id]

  tags = {
    Name = var.instance_name
  }

  user_data = file("awsredrive.sh")
}

resource "aws_key_pair" "ec2-ssh-pub" {
  key_name = var.key_name
  public_key= var.pub_key

}

////////////////////////////////////////////////

/*
locals {
  sshPrivateKey = "/home/DMALEAS/AWS_XA/a.pem"
}
*/


resource "aws_security_group" "allowssh" {
  name        = "allowssh"
  description = "Allow SSH inbound traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0",]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # "-1" stands for all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }
}

/*
resource "aws_iam_role" "ec2_sqsrole" {
  name = "ec2-sqsrole"

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

resource "aws_iam_policy" "sqs_full" {
  name        = "sqs-full"
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

resource "aws_iam_role_policy_attachment" "sqs_full" {
  policy_arn = aws_iam_policy.sqs_full.arn
  role       = aws_iam_role.ec2_sqsrole.name
}

*/

#------------------------------------------------------------------------------------------

resource "aws_sns_topic" "sns-topic1" {
  name            = "sns-topic1"
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


resource "aws_sqs_queue" "sqs-q1" {
  name = "sqs-q1"
#  depends_on = [
#    aws_iam_policy_attachment.example_attachment
#  ]

}

resource "aws_sns_topic_subscription" "sns-subscr" {
  topic_arn = aws_sns_topic.sns-topic1.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.sqs-q1.arn
}

resource "aws_sqs_queue_policy" "sqs-policy" {
  queue_url = aws_sqs_queue.sqs-q1.url

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action = [
          "sqs:SendMessage",
#          "sqs:CreateQueue",    #
#          "sqs:GetQueueUrl",    #
#          "sqs:ListQueues"      #
        ]
        Resource = aws_sqs_queue.sqs-q1.arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_sns_topic.sns-topic1.arn
          }
        }
      }
    ]
  })
}

/*
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
*/
