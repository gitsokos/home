provider "aws" {
  region = "eu-west-3"
}

###resource "aws_sns_topic" "example_topic" {
###  name            = "example-topic"
###  delivery_policy = <<EOF
###{
###  "http": {
###    "defaultHealthyRetryPolicy": {
###      "minDelayTarget": 20,
###      "maxDelayTarget": 20,
###      "numRetries": 3,
###      "numMaxDelayRetries": 0,
###      "numNoDelayRetries": 0,
###      "numMinDelayRetries": 0,
###      "backoffFunction": "linear"
###    },
###    "disableSubscriptionOverrides": false,
###    "defaultThrottlePolicy": {
###      "maxReceivesPerSecond": 1
###    }
###  }
###}
###EOF
###}

resource "aws_sqs_queue" "example_queue" {
  name = "example_queue"
}


#resource "aws_sns_topic_subscription" "user_updates_emails" {
#  topic_arn = aws_sns_topic.example_topic.arn
#  protocol  = "email"
#  for_each  = toset(["grtsokos@gmail.com"])
#  endpoint  = each.value
#}

###resource "aws_sns_topic_subscription" "user_updates_sqs" {
###  topic_arn = aws_sns_topic.example_topic.arn
###  protocol  = "sqs"
###  endpoint  = aws_sqs_queue.example_queue.arn
###}

###resource "aws_sqs_queue_policy" "example_queue_policy" {
###  queue_url = aws_sqs_queue.example_queue.url

###  policy = jsonencode({
###    Version = "2012-10-17"
###    Statement = [
###      {
###        Effect = "Allow"
###        Principal = "*"
###        Action = [
###          "sqs:SendMessage",
###          "sqs:CreateQueue",	#
###          "sqs:GetQueueUrl",	#
###          "sqs:ListQueues"	#
###        ]
###        Resource = aws_sqs_queue.example_queue.arn
###        Condition = {
###          ArnEquals = {
###            "aws:SourceArn" = aws_sns_topic.example_topic.arn
###          }
###        }
###      }
###    ]
###  })
###}

###resource "aws_iam_policy" "example_policy" {
###  name        = "sqs-create-policy"
###  description = "Allows users to create SQS resources"
###  policy      = jsonencode({
###    Version = "2012-10-17"
###    Statement = [
###      {
###        Effect = "Allow"
###        Action = [
###          "sqs:CreateQueue",
###          "sqs:GetQueueUrl",
###          "sqs:ListQueues"
###        ]
###        Resource = "*"
###      }
###    ]
###  })
###}


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

