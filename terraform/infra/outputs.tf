output "vpc_id" {
  description = "Main VPC ID"
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "Public subnet ID"
  value       = aws_subnet.public.id
}

output "tooling_public_ip" {
  description = "Public IP of Jenkins SonarQube Nexus server"
  value       = aws_instance.tooling.public_ip
}

output "docker_agent_public_ip" {
  description = "Public IP of Docker and Trivy Jenkins agent"
  value       = aws_instance.docker_agent.public_ip
}

output "deploy_agent_public_ip" {
  description = "Public IP of Terraform Ansible kubectl Jenkins agent"
  value       = aws_instance.deploy_agent.public_ip
}

output "k8s_node_public_ip" {
  description = "Public IP of Kubernetes node"
  value       = aws_instance.k8s_control.public_ip
}

output "jenkins_url" {
  description = "Jenkins URL"
  value       = "http://${aws_instance.tooling.public_ip}:8080"
}

output "sonarqube_url" {
  description = "SonarQube URL"
  value       = "http://${aws_instance.tooling.public_ip}:9000"
}

output "nexus_url" {
  description = "Nexus URL"
  value       = "http://${aws_instance.tooling.public_ip}:8081"
}

output "frontend_ecr_repository_url" {
  description = "Frontend ECR repository URL"
  value       = aws_ecr_repository.frontend.repository_url
}

output "backend_ecr_repository_url" {
  description = "Backend ECR repository URL"
  value       = aws_ecr_repository.backend.repository_url
}

output "frontend_ecr_repository_name" {
  description = "Frontend ECR repository name"
  value       = aws_ecr_repository.frontend.name
}

output "backend_ecr_repository_name" {
  description = "Backend ECR repository name"
  value       = aws_ecr_repository.backend.name
}

output "tooling_private_ip" {
  description = "Private IP of Jenkins SonarQube Nexus server"
  value       = aws_instance.tooling.private_ip
}

output "docker_agent_private_ip" {
  description = "Private IP of Docker and Trivy Jenkins agent"
  value       = aws_instance.docker_agent.private_ip
}

output "deploy_agent_private_ip" {
  description = "Private IP of Terraform Ansible kubectl Jenkins agent"
  value       = aws_instance.deploy_agent.private_ip
}

output "k8s_node_private_control_plane_ip" {
  description = "Private IP of Kubernetes control plane"
  value       = aws_instance.k8s_control.private_ip
}

output "k8s_worker_public_ip" {
  description = "Public IP of Kubernetes worker node"
  value       = aws_instance.k8s_worker.public_ip
}

output "k8s_worker_private_ip" {
  description = "Private IP of Kubernetes worker node"
  value       = aws_instance.k8s_worker.private_ip
}