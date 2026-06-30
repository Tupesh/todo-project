```groovy
pipeline {
    agent none

    parameters {
        string(
            name: 'K8S_WORKER_PUBLIC_IP',
            defaultValue: 'REPLACE_WITH_k8s_worker_IP',
            description: 'Public IP of the Kubernetes worker node. Example: 34.231.171.34'
        )
    }

    environment {
        SONARQUBE_SERVER = 'sonarqube-server'

        AWS_REGION   = 'us-east-1'
        ECR_REGISTRY = '069211227659.dkr.ecr.us-east-1.amazonaws.com'

        BACKEND_ECR  = '069211227659.dkr.ecr.us-east-1.amazonaws.com/devops-demo-backend'
        FRONTEND_ECR = '069211227659.dkr.ecr.us-east-1.amazonaws.com/devops-demo-frontend'

        IMAGE_TAG = "${BUILD_NUMBER}"
        NAMESPACE = 'devops-demo'

        FRONTEND_PUBLIC_URL = "http://${params.K8S_WORKER_PUBLIC_IP}:30080"
        BACKEND_PUBLIC_URL  = "http://${params.K8S_WORKER_PUBLIC_IP}:30081"
    }

    stages {
        stage('Validate Inputs') {
            agent { label 'docker' }

            steps {
                sh '''
                    echo "Checking required pipeline inputs..."

                    if [ -z "${K8S_WORKER_PUBLIC_IP}" ] || [ "${K8S_WORKER_PUBLIC_IP}" = "REPLACE_WITH_k8s_worker_IP" ]; then
                        echo "ERROR: Set K8S_WORKER_PUBLIC_IP before running this pipeline."
                        echo "Example: 34.231.171.34"
                        exit 1
                    fi

                    echo "Kubernetes worker public IP: ${K8S_WORKER_PUBLIC_IP}"
                    echo "Frontend URL: http://${K8S_WORKER_PUBLIC_IP}:30080"
                    echo "Backend URL: http://${K8S_WORKER_PUBLIC_IP}:30081"
                '''
            }
        }

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

                    echo "Kubernetes manifests:"
                    ls -la k8s

                    test -f sonar-project.properties
                    test -f k8s/namespace.yml
                    test -f k8s/postgres.yml
                    test -f k8s/backend.yml
                    test -f k8s/frontend.yml
                    test -f k8s/migrate-job.yml

                    echo "Checking Kubernetes placeholders..."
                    grep -R "BACKEND_IMAGE_PLACEHOLDER\\|FRONTEND_IMAGE_PLACEHOLDER\\|FRONTEND_ORIGIN_PLACEHOLDER" k8s || true
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

                withSonarQubeEnv('sonarqube-server') {
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

        stage('Check Deploy Agent') {
            agent { label 'deploy' }

            steps {
                sh '''
                    echo "Checking deploy-agent..."
                    hostname
                    whoami

                    kubectl get nodes
                    aws --version
                    aws sts get-caller-identity
                '''
            }
        }

        stage('Deploy Namespace and Postgres') {
            agent { label 'deploy' }

            steps {
                deleteDir()
                unstash 'source-code'

                sh '''
                    echo "Applying namespace..."
                    kubectl apply -f k8s/namespace.yml

                    echo "Applying Postgres, postgres-secret, and backend-secret..."
                    kubectl apply -f k8s/postgres.yml

                    echo "Waiting for Postgres rollout..."
                    kubectl -n ${NAMESPACE} rollout status deployment/postgres --timeout=180s

                    echo "Postgres status:"
                    kubectl -n ${NAMESPACE} get pods -l app=postgres -o wide
                    kubectl -n ${NAMESPACE} get svc postgres
                '''
            }
        }

        stage('Create ECR Image Pull Secret') {
            agent { label 'deploy' }

            steps {
                sh '''
                    echo "Creating or updating ECR imagePullSecret..."
                    kubectl create secret docker-registry ecr-registry-secret \
                      --docker-server=${ECR_REGISTRY} \
                      --docker-username=AWS \
                      --docker-password="$(aws ecr get-login-password --region ${AWS_REGION})" \
                      --namespace=${NAMESPACE} \
                      --dry-run=client -o yaml | kubectl apply -f -
                '''
            }
        }

        stage('Run Database Migrations') {
            agent { label 'deploy' }

            steps {
                deleteDir()
                unstash 'source-code'

                sh '''
                    echo "Deleting old migration job if it exists..."
                    kubectl -n ${NAMESPACE} delete job backend-migrate --ignore-not-found=true

                    echo "Creating migration job from k8s/migrate-job.yml..."
                    sed \
                      -e "s#BACKEND_IMAGE_PLACEHOLDER#${BACKEND_ECR}:${IMAGE_TAG}#g" \
                      -e "s#FRONTEND_ORIGIN_PLACEHOLDER#${FRONTEND_PUBLIC_URL}#g" \
                      k8s/migrate-job.yml | kubectl apply -f -

                    echo "Waiting for migration job..."
                    kubectl -n ${NAMESPACE} wait --for=condition=complete job/backend-migrate --timeout=180s

                    echo "Migration logs:"
                    kubectl -n ${NAMESPACE} logs job/backend-migrate
                '''
            }
        }

        stage('Deploy Backend') {
            agent { label 'deploy' }

            steps {
                deleteDir()
                unstash 'source-code'

                sh '''
                    echo "Deploying backend..."
                    sed "s#BACKEND_IMAGE_PLACEHOLDER#${BACKEND_ECR}:${IMAGE_TAG}#g" \
                      k8s/backend.yml | kubectl apply -f -

                    echo "Forcing backend FRONTEND_ORIGIN for CORS..."
                    kubectl -n ${NAMESPACE} set env deployment/backend FRONTEND_ORIGIN=${FRONTEND_PUBLIC_URL}

                    echo "Waiting for backend rollout..."
                    kubectl -n ${NAMESPACE} rollout status deployment/backend --timeout=180s

                    echo "Backend status:"
                    kubectl -n ${NAMESPACE} get pods -l app=backend -o wide
                    kubectl -n ${NAMESPACE} get svc backend

                    echo "Backend env check:"
                    kubectl -n ${NAMESPACE} exec deployment/backend -- printenv | grep FRONTEND_ORIGIN
                '''
            }
        }

        stage('Deploy Frontend') {
            agent { label 'deploy' }

            steps {
                deleteDir()
                unstash 'source-code'

                sh '''
                    echo "Deploying frontend..."
                    sed "s#FRONTEND_IMAGE_PLACEHOLDER#${FRONTEND_ECR}:${IMAGE_TAG}#g" \
                      k8s/frontend.yml | kubectl apply -f -

                    echo "Waiting for frontend rollout..."
                    kubectl -n ${NAMESPACE} rollout status deployment/frontend --timeout=180s

                    echo "Frontend status:"
                    kubectl -n ${NAMESPACE} get pods -l app=frontend -o wide
                    kubectl -n ${NAMESPACE} get svc frontend
                '''
            }
        }

        stage('Verify Deployment') {
            agent { label 'deploy' }

            steps {
                sh '''
                    echo "All resources:"
                    kubectl -n ${NAMESPACE} get all

                    echo "Backend logs:"
                    kubectl -n ${NAMESPACE} logs deployment/backend --tail=50 || true

                    echo "Frontend logs:"
                    kubectl -n ${NAMESPACE} logs deployment/frontend --tail=50 || true

                    echo "Frontend URL:"
                    echo "${FRONTEND_PUBLIC_URL}"

                    echo "Backend URL:"
                    echo "${BACKEND_PUBLIC_URL}"

                    echo "Backend docs:"
                    echo "${BACKEND_PUBLIC_URL}/docs"
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

            node('deploy') {
                deleteDir()
            }
        }
    }
}
```
