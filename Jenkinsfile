pipeline {
    agent none

    environment {
        SONARQUBE_SERVER = 'sonarqube-server'
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
    }

    post {
        always {
            node('docker') {
                deleteDir()
            }
        }
    }
}
