#!/bin/bash

# AWS Configuration
export AWS_ACCESS_KEY_ID="AKIA6BJOJL4R2YNEWSJI"
export AWS_SECRET_ACCESS_KEY="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"
export AWS_DEFAULT_REGION="<ap south-1>"

# Create Terraform Files
cat > main.tf <<EOF
provider "aws" {
  region = "$ap south-1"
}

resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "my_subnet" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.1.0/24"
}

resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Allow HTTP inbound traffic"
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "frontend" {
  ami           = "ami-0123456789abcdef0" 
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.my_subnet.id
  key_name      = "devops2"
  
  security_groups = [aws_security_group.allow_http.name]

  provisioner "file" {
    source      = "frontend/Dockerfile"
    destination = "/tmp/Dockerfile"
  }

  provisioner "file" {
    source      = "index.html"
    destination = "/tmp/index.html"
  }

  provisioner "file" {
    source      = "style.css"
    destination = "/tmp/style.css"
  }

  provisioner "file" {
    source      = "script.js"
    destination = "/tmp/script.js"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install -y docker.io",
      "sudo docker build -t frontend-container /tmp",
      "sudo docker run -d -p 80:80 --name frontend-container frontend-container"
    ]
  }
}

resource "aws_instance" "backend" {
  ami           = "ami-0123456789abcdef0" 
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.my_subnet.id
  key_name      = "devops2"

  provisioner "file" {
    source      = "backend/Dockerfile"
    destination = "/tmp/Dockerfile"
  }

  provisioner "file" {
    source      = "config.php"
    destination = "/tmp/config.php"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install -y docker.io",
      "sudo docker build -t backend-container /tmp",
      "sudo docker run -d -e MYSQL_ROOT_PASSWORD=password -e MYSQL_DATABASE=student_data --name backend-container backend-container"
    ]
  }
}

resource "aws_cloudwatch_metric_alarm" "frontend_cpu_alarm" {
  alarm_name          = "FrontendCPUAlarm"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "70"
  alarm_description  = "Alarm when frontend CPU utilization is less than 70%"
  alarm_actions      = ["arn:aws:sns:us-west-1:123456789012:MyFrontendAlarmTopic"]
  
  dimensions = {
    InstanceId = aws_instance.frontend.id
  }
}

resource "aws_cloudwatch_metric_alarm" "frontend_disk_alarm" {
  alarm_name          = "FrontendDiskAlarm"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "DiskSpaceUtilization"
  namespace           = "System/Linux"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description  = "Alarm when frontend disk space utilization is less than 80%"
  alarm_actions      = ["arn:aws:sns:us-west-1:123456789012:MyFrontendAlarmTopic"]
  
  dimensions = {
    InstanceId = aws_instance.frontend.id
  }
}

resource "aws_cloudwatch_dashboard" "frontend_dashboard" {
  dashboard_name = "FrontendDashboard"

  dashboard_body = <<EOF
{
  "widgets": [
    {
      "type": "metric",
      "x": 0,
      "y": 0,
      "width": 12,
      "height": 6,
      "properties": {
        "metrics": [
          ["AWS/EC2", "CPUUtilization", "InstanceId", "${aws_instance.frontend.id}"],
          ["System/Linux", "DiskSpaceUtilization", "InstanceId", "${aws_instance.frontend.id}"]
        ],
        "title": "Frontend Metrics",
        "period": 300,
        "view": "timeSeries",
        "stacked": false
      }
    }
  ]
}
EOF
}

resource "aws_cloudwatch_metric_alarm" "backend_cpu_alarm" {
  alarm_name          = "BackendCPUAlarm"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "70"
  alarm_description  = "Alarm when backend CPU utilization is less than 70%"
  alarm_actions      = ["arn:aws:sns:us-west-1:123456789012:MyBackendAlarmTopic"]
  
  dimensions = {
    InstanceId = aws_instance.backend.id
  }
}

resource "aws_cloudwatch_metric_alarm" "backend_disk_alarm" {
  alarm_name          = "BackendDiskAlarm"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "DiskSpaceUtilization"
  namespace           = "System/Linux"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description  = "Alarm when backend disk space utilization is less than 80%"
  alarm_actions      = ["arn:aws:sns:us-west-1:123456789012:MyBackendAlarmTopic"]
  
  dimensions = {
    InstanceId = aws_instance.backend.id
  }
}

resource "aws_cloudwatch_dashboard" "backend_dashboard" {
  dashboard_name = "BackendDashboard"

  dashboard_body = <<EOF
{
  "widgets": [
    {
      "type": "metric",
      "x": 0,
      "y": 0,
      "width": 12,
      "height": 6,
      "properties": {
        "metrics": [
          ["AWS/EC2", "CPUUtilization", "InstanceId", "${aws_instance.backend.id}"],
          ["System/Linux", "DiskSpaceUtilization", "InstanceId", "${aws_instance.backend.id}"]
        ],
        "title": "Backend Metrics",
        "period": 300,
        "view": "timeSeries",
        "stacked": false
      }
    }
  ]
}
EOF
}

EOF

# Create Docker Configuration Scripts
mkdir frontend
mkdir backend

# Create Dockerfile for Frontend Container
cat > frontend/Dockerfile <<EOF
# Use an official Nginx image as the base image
FROM nginx:latest

# Copy the HTML, CSS, and JavaScript files to the Nginx root directory
COPY index.html /usr/share/nginx/html/
COPY style.css /usr/share/nginx/html/
COPY script.js /usr/share/nginx/html/

# Expose port 80 to the host
EXPOSE 80

# Start Nginx when the container is run
CMD ["nginx", "-g", "daemon off;"]
EOF

# Create Dockerfile for Backend Container
cat > backend/Dockerfile <<EOF
# Use an official PHP image as the base image
FROM php:7.4-apache

# Install mysqli extension and MySQL client
RUN docker-php-ext-install mysqli && \
    apt-get update && \
    apt-get install -y default-mysql-client

# Set the working directory to /var/www/html
WORKDIR /var/www/html

# Copy the PHP application files to the container
COPY . .

# Expose port 80 to the host
EXPOSE 80

# Start Apache when the container is run
CMD ["apache2-foreground"]
EOF

# Create Configuration Script
cat > CONFIGURATION.sh <<EOF
#!/bin/bash

# Update the system
sudo apt-get update -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Configure Docker network
docker network create my_network

# Run frontend container
docker run -d --name frontend-container --network my_network -p 80:80 <07e06f51c19bdc22d800a6652e4d5215bab16a9d7efe3add330cbd478e5b9e21>

# Run backend container
docker run -d --name backend-container --network my_network -e MYSQL_ROOT_PASSWORD=aditi202 -e MYSQL_DATABASE=student_data <07e06f51c19bdc22d800a6652e4d5215bab16a9d7efe3>
EOF

# Run Terraform commands
terraform init
terraform apply

# Get DNS/IP of FRONTEND
FRONTEND_DNS=$(terraform output frontend_dns)

# Output information
echo "FRONTEND Public IP/DNS: $FRONTEND_DNS"
echo "FRONTEND Dashboard URL: https://console.aws.amazon.com/cloudwatch/home?region=$AWS_DEFAULT_REGION#dashboards:name=FrontendDashboard"