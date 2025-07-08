
Cloud Application Deployment on AWS - DevOps Engineer Challenge
Project Overview

This project demonstrates the deployment of a cloud-based application on AWS using modern DevOps tools and practices. The architecture includes:

    Docker for containerization of the application.

    Kubernetes (EKS) for managing and scaling containers.

    AWS Lambda for serverless health checks.

    AWS CloudFront for edge content delivery optimization.

    Terraform for infrastructure automation.

    AI-powered scaling using Horizontal Pod Autoscaler (HPA).

    Cost management and security best practices.

The goal was to deploy a simple Python Flask application, integrate it with Kubernetes and AWS services, and optimize edge performance and costs.
Table of Contents

    Prerequisites

    Infrastructure Setup

    Deployment Steps

        App Containerization

        Kubernetes Deployment

        CloudFront Configuration

        Latency Testing

    Automation & Optimization

    Security & Best Practices

    Cost Management

    Teardown Process

    Testing & Validation

    Final Thoughts

Prerequisites

Before proceeding, ensure that the following tools are installed and configured on your local machine:

    AWS CLI:

        Install the AWS CLI and configure your credentials using aws configure.

        Documentation: AWS CLI Install

    Terraform:

        Install Terraform to provision infrastructure.

        Documentation: Terraform Install

    Docker:

        Docker is required for containerizing the application.

        Documentation: Docker Install

    kubectl:

        Install kubectl to manage Kubernetes clusters.

        Documentation: kubectl Install

    Python 3.x:

        Required to run the latency testing script and Flask application.

        Documentation: Python Install

Infrastructure Setup

The infrastructure is managed via Terraform, and the following AWS resources are provisioned:

    VPC with Public and Private Subnets.

    EKS Cluster with a single node group to run Kubernetes workloads.

    Lambda Function for health checks and logging.

    CloudFront Distribution to cache content at edge locations.

    S3 Bucket for storing logs and static files.

    EC2 Instance for latency testing in the Mumbai region (ap-south-1).

Terraform Files

    main.tf: Defines the core infrastructure such as VPC, subnets, security groups, and EKS cluster.

    cloudfront.tf: Defines CloudFront distribution to optimize edge content delivery.

    variables.tf: Stores variable definitions for use across the Terraform configuration.

To initialize and apply the Terraform setup:

terraform init
terraform apply

Deployment Steps
1. App Containerization

The application is a simple Python Flask app with a /health endpoint returning a "OK" message. The app is containerized using Docker.

Dockerfile Example:

# Use Python base image
FROM python:3.9-slim

# Set working directory
WORKDIR /app

# Install app dependencies
COPY requirements.txt .
RUN pip install -r requirements.txt

# Copy app code
COPY . /app

# Expose port
EXPOSE 5000

# Run Flask app
CMD ["python", "app.py"]

Once the Dockerfile is ready, build the image and push it to Amazon ECR:

docker build -t flask-app .
aws ecr create-repository --repository-name flask-app
docker tag flask-app:latest <aws_account_id>.dkr.ecr.<region>.amazonaws.com/flask-app:latest
docker push <aws_account_id>.dkr.ecr.<region>.amazonaws.com/flask-app:latest

2. Kubernetes Deployment

The app is deployed on AWS EKS using Kubernetes manifests:

    Deployment: Defines the app’s container replicas.

    Service: LoadBalancer service to expose the Flask app.

    Horizontal Pod Autoscaler (HPA): Scales the application based on CPU usage.

Example Deployment.yaml:

apiVersion: apps/v1
kind: Deployment
metadata:
  name: flask-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: flask-app
  template:
    metadata:
      labels:
        app: flask-app
    spec:
      containers:
      - name: flask-app
        image: <aws_account_id>.dkr.ecr.<region>.amazonaws.com/flask-app:latest
        ports:
        - containerPort: 5000

To deploy, apply the Kubernetes manifests:

kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl apply -f hpa.yaml

3. CloudFront Configuration

CloudFront is configured to cache the app's content and deliver it from edge locations globally. The configuration is managed via Terraform using the aws_cloudfront_distribution resource.

Example CloudFront Configuration:

resource "aws_cloudfront_distribution" "flask_app" {
  origin {
    domain_name = aws_lb.flask_app.dns_name
    origin_id   = "flask-app-loadbalancer"
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "/"

  # Add Edge Locations
  price_class = "PriceClass_100"

  # Additional configuration...
}

Latency Testing

To measure the latency of the CloudFront distribution from different global regions, a Python script is used to query the CloudFront URL and output latency results:

import subprocess

edge_locations = ['US', 'Europe', 'Australia', 'Korea', 'Singapore', 'Japan']
url = "<CloudFront_URL>"

for location in edge_locations:
    print(f"Testing latency for {location}...")
    result = subprocess.run(["curl", "-w", "%{time_total}", "-o", "/dev/null", "-s", url], capture_output=True, text=True)
    print(f"{location}: {result.stdout} seconds")

Automation & Optimization

Automation is achieved through a bash script that:

    Initializes Terraform.

    Deploys the app on EKS and configures CloudFront.

    Runs latency tests.

    Teardown resources once tests are complete.

Automation Script Example (automation.sh):

#!/bin/bash

# Initialize Terraform
terraform init

# Apply infrastructure
terraform apply -auto-approve

# Deploy the app on EKS
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml

# Run Latency Tests
python latency_test.py

# Teardown resources
terraform destroy -auto-approve

AI-powered Scaling

Horizontal Pod Autoscaler (HPA) is configured to automatically scale the number of app replicas based on CPU usage.

Example HPA.yaml:

apiVersion: autoscaling/v2beta2
kind: HorizontalPodAutoscaler
metadata:
  name: flask-app-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: flask-app
  minReplicas: 2
  maxReplicas: 5
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 80

Security & Best Practices

    IAM Roles & Policies: Restricted EKS access via IAM roles.

    S3 Bucket Encryption: Enabled S3 encryption for logs.

    CloudFront HTTPS: Enforced HTTPS for secure content delivery.

    Security Groups: Configured security groups to restrict traffic on necessary ports only.

Cost Management

The AWS Cost Explorer is used to estimate and optimize costs, including those for CloudFront, S3, EKS, and EC2 instances. Based on the analysis:

    Spot Instances: Suggested for non-critical workloads.

    CloudFront Price Class: Configured to use the cheapest price class for global distribution.

Teardown Process

To delete all resources and avoid any ongoing costs, run the following command:

terraform destroy -auto-approve

Testing & Validation

    App Accessibility: Accessible via LoadBalancer and CloudFront.

    Lambda Health Check: Logs app health status to S3.

    HPA Scaling: Verified by simulating load on the app.

    Latency Optimization: CloudFront configured to deliver content with the lowest latency.