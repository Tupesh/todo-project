pipeline {
    agent none

    environment {
        APP_NAME = ''
        ENVIRONMENT = ''

        REGISTRY_URL = ''
        FRONTEND_IMAGE = ''
        BACKEND_IMAGE = ''
        IMAGE_TAG = ''

        SONAR_PROJECT_KEY = ''
        SONAR_PROJECT_NAME = ''

        K8S_NAMESPACE = ''

        TERRAFORM_DIR = ''
        ANSIBLE_DIR = ''
        K8S_DIR = ''
    }

    stages {
        stage('Checkout') {
            agent {
                label 'agent-1-code-scan'
            }

            steps {
                checkout scm

                echo 'Code checked out on Agent 1'

                stash name: 'source-code', includes: '**/*'
            }
        }

        stage('SonarQube Quality Scan') {
            agent {
                label 'agent-1-code-scan'
            }

            steps {
                unstash 'source-code'

                echo 'Run SonarQube source code scan on Agent 1'
            }
        }

        stage('SonarQube Quality Gate') {
            agent {
                label 'agent-1-code-scan'
            }

            steps {
                echo 'Check SonarQube quality gate on Agent 1'
            }
        }

        stage('Docker Image Create') {
            agent {
                label 'agent-2-docker-security'
            }

            steps {
                unstash 'source-code'

                echo 'Build frontend Docker image on Agent 2'
                echo 'Build backend Docker image on Agent 2'
            }
        }

        stage('Trivy Image Scan') {
            agent {
                label 'agent-2-docker-security'
            }

            steps {
                echo 'Scan frontend Docker image using Trivy on Agent 2'
                echo 'Scan backend Docker image using Trivy on Agent 2'
                echo 'Fail pipeline if critical vulnerabilities are found'
            }
        }

        stage('Docker Image Push') {
            agent {
                label 'agent-2-docker-security'
            }

            steps {
                echo 'Login to Docker registry / Nexus / ECR from Agent 2'
                echo 'Push frontend image from Agent 2'
                echo 'Push backend image from Agent 2'
            }
        }

        stage('Terraform Init') {
            agent {
                label 'agent-3-deploy-infra'
            }

            steps {
                unstash 'source-code'

                echo 'Initialize Terraform on Agent 3'
            }
        }

        stage('Terraform Validate') {
            agent {
                label 'agent-3-deploy-infra'
            }

            steps {
                echo 'Validate Terraform configuration on Agent 3'
            }
        }

        stage('Terraform Plan') {
            agent {
                label 'agent-3-deploy-infra'
            }

            steps {
                echo 'Generate Terraform execution plan on Agent 3'
            }
        }

        stage('Terraform Apply') {
            agent {
                label 'agent-3-deploy-infra'
            }

            steps {
                echo 'Provision or update AWS infrastructure using Terraform from Agent 3'
            }
        }

        stage('Ansible Configuration') {
            agent {
                label 'agent-3-deploy-infra'
            }

            steps {
                echo 'Run Ansible playbook from Agent 3'
            }
        }

        stage('Kubernetes Manifest Validation') {
            agent {
                label 'agent-3-deploy-infra'
            }

            steps {
                echo 'Validate Kubernetes manifests from Agent 3'
            }
        }

        stage('Kubernetes Deploy') {
            agent {
                label 'agent-3-deploy-infra'
            }

            steps {
                echo 'Create or update Kubernetes namespace from Agent 3'
                echo 'Apply Kubernetes manifests from Agent 3'
                echo 'Update frontend deployment image from Agent 3'
                echo 'Update backend deployment image from Agent 3'
            }
        }

        stage('Kubernetes Rollout Check') {
            agent {
                label 'agent-3-deploy-infra'
            }

            steps {
                echo 'Check frontend deployment rollout status from Agent 3'
                echo 'Check backend deployment rollout status from Agent 3'
            }
        }

        stage('Application Smoke Test') {
            agent {
                label 'agent-3-deploy-infra'
            }

            steps {
                echo 'Check frontend endpoint from Agent 3'
                echo 'Check backend health endpoint from Agent 3'
                echo 'Verify application is reachable after deployment'
            }
        }

        stage('Prometheus Target Check') {
            agent {
                label 'agent-3-deploy-infra'
            }

            steps {
                echo 'Verify backend metrics endpoint is available'
                echo 'Verify Prometheus can scrape application metrics'
            }
        }

        stage('Grafana Dashboard Check') {
            agent {
                label 'agent-3-deploy-infra'
            }

            steps {
                echo 'Verify Grafana dashboard is available'
                echo 'Confirm app and Kubernetes metrics are visible'
            }
        }

        stage('Final Deployment Summary') {
            agent {
                label 'agent-3-deploy-infra'
            }

            steps {
                echo 'Print deployed image tags'
                echo 'Print Kubernetes namespace'
                echo 'Print application endpoint'
                echo 'Print monitoring dashboard URL'
            }
        }
    }

    post {
        success {
            echo 'Pipeline completed successfully'
        }

        failure {
            echo 'Pipeline failed'
        }

        always {
            echo 'Pipeline execution finished'
        }
    }
}