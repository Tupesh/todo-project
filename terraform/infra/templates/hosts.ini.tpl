[docker_agent]
docker-agent ansible_host=${docker_agent_private_ip} ansible_user=ubuntu

[deploy_agent]
deploy-agent ansible_host=${deploy_agent_private_ip} ansible_user=ubuntu

[k8s_control]
k8s-control ansible_host=${k8s_control_private_ip} ansible_user=ubuntu

[k8s_worker]
k8s-worker ansible_host=${k8s_worker_private_ip} ansible_user=ubuntu

[k8s:children]
k8s_control
k8s_worker

[jenkins_agents:children]
docker_agent
deploy_agent

[servers:children]
docker_agent
deploy_agent
k8s_control
k8s_worker

[servers:vars]
ansible_ssh_private_key_file=/home/ubuntu/todo-infra-kp.pem