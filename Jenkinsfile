pipeline {
    agent none

    environment {
        SONARQUBE_SERVER = 'sonarqube-server'

        AWS_REGION   = 'us-east-1'
        ECR_REGISTRY = '069211227659.dkr.ecr.us-east-1.amazonaws.com'

        BACKEND_ECR  = '069211227659.dkr.ecr.us-east-1.amazonaws.com/devops-demo-backend'
        FRONTEND_ECR = '069211227659.dkr.ecr.us-east-1.amazonaws.com/devops-demo-frontend'

        IMAGE_TAG = "${BUILD_NUMBER}"

        // This will matter when we deploy frontend.
        // Update later with current backend NodePort URL after Kubernetes is ready.
        BACKEND_PUBLIC_URL = 'http://REPLACE_WITH_K8S_WORKER_PUBLIC_IP:30081'
    }

    stages {
        stage('Checkout Source') {
            agent { label 'docker' }

            steps {
                deleteDir()

                git branch: 'Jenkins', url: 'https://github.com/Tupesh/todo-project.git'

                sh '''
                    echo "Current machine:"
                    hostname

                    echo "Current workspace:"
                    pwd

                    echo "Repo files:"
                    ls -la
                '''

                stash name: 'source-code', includes: '**/*'
            }
        }

        stage('Check Docker Agent Tools') {
            agent { label 'docker' }

            steps {
                deleteDir()
                unstash 'source-code'

                sh '''
                    echo "Checking docker-agent tools..."
                    hostname
                    whoami

                    docker --version
                    aws --version
                    trivy --version
                    sonar-scanner --version
                    aws sts get-caller-identity
                '''
            }
        }

        stage('SonarQube Analysis') {
            agent { label 'docker' }

            steps {
                deleteDir()
                unstash 'source-code'

                withSonarQubeEnv("${SONARQUBE_SERVER}") {
                    sh '''
                        echo "Running SonarQube analysis..."
                        sonar-scanner
                    '''
                }
            }
        }

        stage('SonarQube Quality Gate') {
            agent none

            steps {
                timeout(time: 3, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Build Backend Image') {
            agent { label 'docker' }

            steps {
                deleteDir()
                unstash 'source-code'

                sh '''
                    echo "Building backend Docker image..."
                    docker build \
                      -t devops-demo-backend:${IMAGE_TAG} \
                      ./backend
                '''
            }
        }

        stage('Build Frontend Image') {
            agent { label 'docker' }

            steps {
                deleteDir()
                unstash 'source-code'

                sh '''
                    echo "Building frontend Docker image..."
                    docker build \
                      --build-arg VITE_API_BASE_URL=${BACKEND_PUBLIC_URL} \
                      -t devops-demo-frontend:${IMAGE_TAG} \
                      ./frontend
                '''
            }
        }

        stage('Scan Images With Trivy') {
            agent { label 'docker' }

            steps {
                sh '''
                    echo "Scanning backend image..."
                    trivy image --exit-code 0 --severity HIGH,CRITICAL devops-demo-backend:${IMAGE_TAG}

                    echo "Scanning frontend image..."
                    trivy image --exit-code 0 --severity HIGH,CRITICAL devops-demo-frontend:${IMAGE_TAG}
                '''
            }
        }

        stage('Login to ECR') {
            agent { label 'docker' }

            steps {
                sh '''
                    echo "Logging in to ECR..."
                    aws ecr get-login-password --region ${AWS_REGION} \
                    | docker login --username AWS --password-stdin ${ECR_REGISTRY}
                '''
            }
        }

        stage('Tag and Push Images to ECR') {
            agent { label 'docker' }

            steps {
                sh '''
                    echo "Tagging backend image..."
                    docker tag devops-demo-backend:${IMAGE_TAG} ${BACKEND_ECR}:${IMAGE_TAG}

                    echo "Tagging frontend image..."
                    docker tag devops-demo-frontend:${IMAGE_TAG} ${FRONTEND_ECR}:${IMAGE_TAG}

                    echo "Pushing backend image..."
                    docker push ${BACKEND_ECR}:${IMAGE_TAG}

                    echo "Pushing frontend image..."
                    docker push ${FRONTEND_ECR}:${IMAGE_TAG}
                '''
            }
        }
    }

    post {
        always {
            node('docker') {
                sh '''
                    docker image prune -f || true
                '''
                deleteDir()
            }
        }
    }
}
