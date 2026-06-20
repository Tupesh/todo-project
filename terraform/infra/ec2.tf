resource "aws_instance" "tooling" {
  ami                         = "ami-0f8a61b66d1accaee"
  instance_type               = "m7i-flex.large"
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.tooling.id]
  associate_public_ip_address = true
  key_name                    = var.key_pair_name

  root_block_device {
    volume_size = 80
    volume_type = "gp3"
  }

  tags = {
    Name        = "devops-demo-tooling"
    Environment = "dev"
    Purpose     = "jenkins-sonarqube-nexus"
    ManagedBy   = "terraform"
  }
}

resource "aws_instance" "docker_agent" {
  ami                         = "ami-0f8a61b66d1accaee"
  instance_type               = "c7i-flex.large"
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.docker_agent.id]
  associate_public_ip_address = true
  key_name                    = var.key_pair_name

  root_block_device {
    volume_size = 60
    volume_type = "gp3"
  }

  tags = {
    Name        = "devops-demo-docker-agent"
    Environment = "dev"
    Purpose     = "docker-trivy-agent"
    ManagedBy   = "terraform"
  }
}

resource "aws_instance" "deploy_agent" {
  ami                         = "ami-0f8a61b66d1accaee"
  instance_type               = "t3.small"
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.deploy_agent.id]
  associate_public_ip_address = true
  key_name                    = var.key_pair_name

  root_block_device {
    volume_size = 40
    volume_type = "gp3"
  }

  tags = {
    Name        = "devops-demo-deploy-agent"
    Environment = "dev"
    Purpose     = "terraform-ansible-kubectl-agent"
    ManagedBy   = "terraform"
  }
}

resource "aws_instance" "k8s_node" {
  ami                         = "ami-0f8a61b66d1accaee"
  instance_type               = "t3.small"
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.k8s_node.id]
  associate_public_ip_address = true
  key_name                    = var.key_pair_name

  root_block_device {
    volume_size = 60
    volume_type = "gp3"
  }

  tags = {
    Name        = "devops-demo-k8s-node"
    Environment = "dev"
    Purpose     = "single-node-kubernetes"
    ManagedBy   = "terraform"
  }
}

resource "aws_instance" "k8s_worker" {
  ami                         = "ami-0f8a61b66d1accaee"
  instance_type               = "t3.small"
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.k8s_node.id]
  associate_public_ip_address = true
  key_name                    = var.key_pair_name

  root_block_device {
    volume_size = 40
    volume_type = "gp3"
  }

  tags = {
    Name        = "devops-demo-k8s-worker"
    Environment = "dev"
    Purpose     = "kubernetes-worker-node"
    ManagedBy   = "terraform"
  }
}