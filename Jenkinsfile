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
                unstash 'source-code'

                sh '''
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
                unstash 'source-code'

                withSonarQubeEnv("${SONARQUBE_SERVER}") {
                    sh '''
                        sonar-scanner
                    '''
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

