resource "local_file" "ansible_inventory" {
  filename = "${path.module}/../../ansibleplaybook/hosts.ini"

  content = templatefile("${path.module}/templates/hosts.ini.tpl", {
    docker_agent_private_ip = aws_instance.docker_agent.private_ip
    deploy_agent_private_ip = aws_instance.deploy_agent.private_ip
    k8s_control_private_ip  = aws_instance.k8s_control.private_ip
    k8s_worker_private_ip   = aws_instance.k8s_worker.private_ip
  })
}