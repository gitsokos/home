#!/bin/bash
sudo yum update -y
              sudo yum -y install unzip curl libicu
        curl -L -o awsredrive.zip https://github.com/nickntg/awsredrive.core/releases/download/1.0.9/awsredrive.core.linux-console.zip
              unzip awsredrive.zip -d awsredrive
              sudo mv awsredrive /opt
              sudo chown -R ec2-user:ec2-user /opt/awsredrive
              # Daemonize the application using systemd
              echo "[Unit]
              Description=AWS Redrive Service

              [Service]
              ExecStart=/opt/awsredrive/AWSRedrive.console
              Restart=always
              User=ec2-user
              Group=ec2-user

              [Install]
              WantedBy=multi-user.target" > /etc/systemd/system/awsredrive.service

echo "
[
  {
    "Alias": "#1",
    "QueueUrl": "https://sqs.eu-central-1.amazonaws.com/107824434974/sqs-q1",
/*    "RedriveUrl": "http://nohost.com/", */
    "RedriveScrip": "/opt/redrivescript"
    "Region": "eu-central-1",
    "Active": true,
    "Timeout": 10000,
    "UseGET": true,
    "ServiceUrl":  "https://www.google.com"
  }
]
" > /opt/awsredrive/config.json

echo "echo \"aline\" >> /opt/messages" > /opt/redrivescript
sudo chown ec2-user:ec2-user /opt/redrivescript
sudo chmod 755 /opt/redrivescript

sudo touch /opt/messages
sudo chown ec2-user:ec2-user /opt/messages
sudo chmod 666 /opt/messages

	     chmod 700 /opt/awsredrive/AWSRedrive.console
              sudo systemctl daemon-reload
              sudo systemctl enable awsredrive.service
              sudo systemctl start awsredrive.service
