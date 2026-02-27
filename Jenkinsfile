pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "gopikrishna09/node-app"
        CONTAINER_NAME = "my-k8s-app"
    }

    stages {

        stage('Checkout from GitHub') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/Gopikrishna398/node-app-k8s.git'
            }
        }

        stage('Install Dependencies') {
            steps {
                bat 'npm install'
            }
        }

        stage('Build Docker Image') {
            steps {
                bat """
                docker build -t %CONTAINER_NAME%:%BUILD_NUMBER% .
                docker tag %CONTAINER_NAME%:%BUILD_NUMBER% %DOCKER_IMAGE%:%BUILD_NUMBER%
                """
            }
        }

        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    bat """
                    echo %DOCKER_PASS% | docker login -u %DOCKER_USER% --password-stdin
                    docker push %DOCKER_IMAGE%:%BUILD_NUMBER%
                    """
                }
            }
        }

        stage('Start Minikube') {
            steps {
                bat 'minikube start --driver=docker --memory=2048 --cpus=2'
            }
        }

        stage('Wait for Kubernetes') {
            steps {
                bat 'kubectl wait --for=condition=Ready nodes --all --timeout=120s'
                bat 'kubectl cluster-info'
                bat 'kubectl get nodes'
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                bat """
                powershell -Command "(Get-Content k8s\\deployment.yaml) -replace 'IMAGE_TAG', '%BUILD_NUMBER%' | Set-Content k8s\\deployment.yaml"
                minikube image load %DOCKER_IMAGE%:%BUILD_NUMBER%
                kubectl apply -f k8s\\deployment.yaml --validate=false
                kubectl apply -f k8s\\service.yaml --validate=false
                """
            }
        }
    }
}
