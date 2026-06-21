# =========================
# Security Groups
# =========================

resource "aws_security_group" "tooling" {
  name        = "devops-demo-tooling-sg"
  description = "Security group for Jenkins SonarQube Nexus server"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name        = "devops-demo-tooling-sg"
    Environment = "dev"
    Purpose     = "jenkins-sonarqube-nexus"
    ManagedBy   = "terraform"
  }
}

resource "aws_security_group" "docker_agent" {
  name        = "devops-demo-docker-agent-sg"
  description = "Security group for Docker and Trivy Jenkins agent"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name        = "devops-demo-docker-agent-sg"
    Environment = "dev"
    Purpose     = "docker-trivy-agent"
    ManagedBy   = "terraform"
  }
}

resource "aws_security_group" "deploy_agent" {
  name        = "devops-demo-deploy-agent-sg"
  description = "Security group for Terraform Ansible kubectl Jenkins agent"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name        = "devops-demo-deploy-agent-sg"
    Environment = "dev"
    Purpose     = "terraform-ansible-kubectl-agent"
    ManagedBy   = "terraform"
  }
}

resource "aws_security_group" "k8s_node" {
  name        = "devops-demo-k8s-node-sg"
  description = "Security group for Kubernetes node"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name        = "devops-demo-k8s-node-sg"
    Environment = "dev"
    Purpose     = "kubernetes-node"
    ManagedBy   = "terraform"
  }
}

# =========================
# Tooling Server Inbound Rules
# Jenkins + SonarQube + Nexus
# =========================

resource "aws_vpc_security_group_ingress_rule" "tooling_ssh" {
  security_group_id = aws_security_group.tooling.id
  cidr_ipv4         = var.my_ip
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22

  tags = {
    Name = "tooling-ssh"
  }
}

resource "aws_vpc_security_group_ingress_rule" "tooling_jenkins" {
  security_group_id = aws_security_group.tooling.id
  cidr_ipv4         = var.my_ip
  from_port         = 8080
  ip_protocol       = "tcp"
  to_port           = 8080

  tags = {
    Name = "tooling-jenkins"
  }
}

resource "aws_vpc_security_group_ingress_rule" "tooling_sonarqube" {
  security_group_id = aws_security_group.tooling.id
  cidr_ipv4         = var.my_ip
  from_port         = 9000
  ip_protocol       = "tcp"
  to_port           = 9000

  tags = {
    Name = "tooling-sonarqube"
  }
}

resource "aws_vpc_security_group_ingress_rule" "tooling_nexus" {
  security_group_id = aws_security_group.tooling.id
  cidr_ipv4         = var.my_ip
  from_port         = 8081
  ip_protocol       = "tcp"
  to_port           = 8081

  tags = {
    Name = "tooling-nexus"
  }
}

# =========================
# Docker Agent Inbound Rules
# =========================

resource "aws_vpc_security_group_ingress_rule" "docker_agent_ssh" {
  security_group_id = aws_security_group.docker_agent.id
  cidr_ipv4         = var.my_ip
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22

  tags = {
    Name = "docker-agent-ssh"
  }
}

# =========================
# Deploy Agent Inbound Rules
# =========================

resource "aws_vpc_security_group_ingress_rule" "deploy_agent_ssh" {
  security_group_id = aws_security_group.deploy_agent.id
  cidr_ipv4         = var.my_ip
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22

  tags = {
    Name = "deploy-agent-ssh"
  }
}

# =========================
# Kubernetes Node Inbound Rules
# =========================

resource "aws_vpc_security_group_ingress_rule" "k8s_node_ssh" {
  security_group_id = aws_security_group.k8s_node.id
  cidr_ipv4         = var.my_ip
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22

  tags = {
    Name = "k8s-node-ssh"
  }
}

resource "aws_vpc_security_group_ingress_rule" "k8s_node_http" {
  security_group_id = aws_security_group.k8s_node.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80

  tags = {
    Name = "k8s-node-http"
  }
}

resource "aws_vpc_security_group_ingress_rule" "k8s_node_https" {
  security_group_id = aws_security_group.k8s_node.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443

  tags = {
    Name = "k8s-node-https"
  }
}

resource "aws_vpc_security_group_ingress_rule" "k8s_api_from_deploy_agent" {
  security_group_id            = aws_security_group.k8s_node.id
  referenced_security_group_id = aws_security_group.deploy_agent.id
  from_port                    = 6443
  ip_protocol                  = "tcp"
  to_port                      = 6443

  tags = {
    Name = "k8s-api-from-deploy-agent"
  }
}

# =========================
# Outbound Rules
# Allow all outbound traffic
# =========================

resource "aws_vpc_security_group_egress_rule" "tooling_all_out" {
  security_group_id = aws_security_group.tooling.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"

  tags = {
    Name = "tooling-all-out"
  }
}

resource "aws_vpc_security_group_egress_rule" "docker_agent_all_out" {
  security_group_id = aws_security_group.docker_agent.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"

  tags = {
    Name = "docker-agent-all-out"
  }
}

resource "aws_vpc_security_group_egress_rule" "deploy_agent_all_out" {
  security_group_id = aws_security_group.deploy_agent.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"

  tags = {
    Name = "deploy-agent-all-out"
  }
}

resource "aws_vpc_security_group_egress_rule" "k8s_node_all_out" {
  security_group_id = aws_security_group.k8s_node.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"

  tags = {
    Name = "k8s-node-all-out"
  }
}



resource "aws_vpc_security_group_ingress_rule" "docker_agent_ssh_from_tooling" {
  security_group_id            = aws_security_group.docker_agent.id
  referenced_security_group_id = aws_security_group.tooling.id
  from_port                    = 22
  ip_protocol                  = "tcp"
  to_port                      = 22

  tags = {
    Name = "docker-agent-ssh-from-tooling"
  }
}

resource "aws_vpc_security_group_ingress_rule" "deploy_agent_ssh_from_tooling" {
  security_group_id            = aws_security_group.deploy_agent.id
  referenced_security_group_id = aws_security_group.tooling.id
  from_port                    = 22
  ip_protocol                  = "tcp"
  to_port                      = 22

  tags = {
    Name = "deploy-agent-ssh-from-tooling"
  }
}

resource "aws_vpc_security_group_ingress_rule" "k8s_node_ssh_from_deploy_agent" {
  security_group_id            = aws_security_group.k8s_node.id
  referenced_security_group_id = aws_security_group.deploy_agent.id
  from_port                    = 22
  ip_protocol                  = "tcp"
  to_port                      = 22

  tags = {
    Name = "k8s-node-ssh-from-deploy-agent"
  }
}

resource "aws_vpc_security_group_ingress_rule" "k8s_internal_all" {
  security_group_id            = aws_security_group.k8s_node.id
  referenced_security_group_id = aws_security_group.k8s_node.id
  ip_protocol                  = "-1"

  tags = {
    Name = "k8s-internal-all"
  }
}


resource "aws_vpc_security_group_ingress_rule" "docker_agent_ssh_from_deploy_agent" {
  security_group_id            = aws_security_group.docker_agent.id
  referenced_security_group_id = aws_security_group.deploy_agent.id
  from_port                    = 22
  ip_protocol                  = "tcp"
  to_port                      = 22

  tags = {
    Name = "docker-agent-ssh-from-deploy-agent"
  }
}

resource "aws_vpc_security_group_ingress_rule" "k8s_node_ssh_from_tooling" {
  security_group_id            = aws_security_group.k8s_node.id
  referenced_security_group_id = aws_security_group.tooling.id
  from_port                    = 22
  ip_protocol                  = "tcp"
  to_port                      = 22

  tags = {
    Name = "k8s-node-ssh-from-tooling"
  }
}