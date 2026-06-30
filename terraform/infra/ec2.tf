resource "aws_instance" "tooling" {
  ami                         = "ami-0f8a61b66d1accaee"
  instance_type               = "m7i-flex.large"
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.tooling.id]
  associate_public_ip_address = true
  key_name                    = var.key_pair_name

  user_data                   = file("${path.module}/tooling-bootstrap.sh")
  user_data_replace_on_change = true

  root_block_device {
    volume_size = 80
    volume_type = "gp3"
  }

  metadata_options {
    http_tokens = "required"
  }

  tags = {
    Name      = "tooling"
    Role      = "tooling"
    Project   = "todo-project"
    Purpose   = "jenkins-sonarqube-nexus"
    ManagedBy = "terraform"
  }
}


resource "aws_instance" "docker_agent" {
  ami                         = "ami-0f8a61b66d1accaee"
  instance_type               = "c7i-flex.large"
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.docker_agent.id]
  associate_public_ip_address = true
  key_name                    = var.key_pair_name
  iam_instance_profile        = aws_iam_instance_profile.docker_agent_profile.name

  root_block_device {
    volume_size = 40
    volume_type = "gp3"
  }

  metadata_options {
    http_tokens = "required"
  }

  tags = {
    Name      = "docker-agent"
    Role      = "docker_agent"
    Project   = "todo-project"
    Purpose   = "docker-trivy-sonarscanner-agent"
    ManagedBy = "terraform"
  }
}


resource "aws_instance" "deploy_agent" {
  ami                         = "ami-0f8a61b66d1accaee"
  instance_type               = "t3.small"
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.deploy_agent.id]
  associate_public_ip_address = true
  key_name                    = var.key_pair_name
  iam_instance_profile        = aws_iam_instance_profile.deploy_agent_profile.name

  root_block_device {
    volume_size = 40
    volume_type = "gp3"
  }

  metadata_options {
    http_tokens = "required"
  }

  tags = {
    Name      = "deploy-agent"
    Role      = "deploy_agent"
    Project   = "todo-project"
    Purpose   = "ansible-kubectl-helm-deploy-agent"
    ManagedBy = "terraform"
  }
}


resource "aws_instance" "k8s_control" {
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

  metadata_options {
    http_tokens = "required"
  }

  tags = {
    Name      = "k8s-control"
    Role      = "k8s_control"
    Project   = "todo-project"
    Purpose   = "kubernetes-control-plane"
    ManagedBy = "terraform"
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

  metadata_options {
    http_tokens = "required"
  }

  tags = {
    Name      = "k8s-worker"
    Role      = "k8s_worker"
    Project   = "todo-project"
    Purpose   = "kubernetes-worker-node"
    ManagedBy = "terraform"
  }
}
