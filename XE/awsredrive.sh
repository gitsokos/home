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
	     chmod 700 /opt/awsredrive/AWSRedrive.console
              sudo systemctl daemon-reload
              sudo systemctl enable awsredrive.service
              sudo systemctl start awsredrive.service
