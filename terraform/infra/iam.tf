# =========================
# IAM Assume Role Policy for EC2
# =========================

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# =========================
# Docker Agent IAM Role
# Allows Docker agent to push/pull images from ECR
# =========================

resource "aws_iam_role" "docker_agent_ecr_role" {
  name = "devops-demo-docker-agent-ecr-role"

  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  tags = {
    Name        = "devops-demo-docker-agent-ecr-role"
    Environment = "dev"
    Purpose     = "docker-agent-ecr-push"
    ManagedBy   = "terraform"
  }
}

resource "aws_iam_role_policy_attachment" "docker_agent_ecr_poweruser" {
  role       = aws_iam_role.docker_agent_ecr_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

resource "aws_iam_instance_profile" "docker_agent_profile" {
  name = "devops-demo-docker-agent-profile"
  role = aws_iam_role.docker_agent_ecr_role.name

  tags = {
    Name        = "devops-demo-docker-agent-profile"
    Environment = "dev"
    Purpose     = "docker-agent-ecr-push"
    ManagedBy   = "terraform"
  }
}

# =========================
# Deploy Agent IAM Role
# Allows deploy agent to authenticate to ECR
# Useful for creating Kubernetes imagePullSecret
# =========================

resource "aws_iam_role" "deploy_agent_ecr_role" {
  name = "devops-demo-deploy-agent-ecr-role"

  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  tags = {
    Name        = "devops-demo-deploy-agent-ecr-role"
    Environment = "dev"
    Purpose     = "deploy-agent-ecr-read"
    ManagedBy   = "terraform"
  }
}

resource "aws_iam_role_policy_attachment" "deploy_agent_ecr_readonly" {
  role       = aws_iam_role.deploy_agent_ecr_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_instance_profile" "deploy_agent_profile" {
  name = "devops-demo-deploy-agent-profile"
  role = aws_iam_role.deploy_agent_ecr_role.name

  tags = {
    Name        = "devops-demo-deploy-agent-profile"
    Environment = "dev"
    Purpose     = "deploy-agent-ecr-read"
    ManagedBy   = "terraform"
  }
}