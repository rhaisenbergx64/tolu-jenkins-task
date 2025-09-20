pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = "us-east-1"
        AWS_IMAGE_NAME = "tolujenkinstask"
        AWS_ECR_URI = "public.ecr.aws/b3b5m5n0/tolu-jenkins-task"
        HAPI_VERSION = "0.1.1"
        BUILD_VERSION = "1.0.$BUILD_ID"

    }

    stages {

        stage("Build ") {
            agent {
                docker {
                    image 'node:18-alpine'
                    reuseNode true
                }
            }
            steps {
                sh '''
                npm ci
                BUILD_VERSION=$BUILD_VERSION npm run build
                echo "Build completed with version: $BUILD_VERSION"
                '''
            }
        }

        stage('Build and push Docker Image to ECR') {
            agent {
                docker {
                    image 'amazon/aws-cli:latest' 
                    reuseNode true
                    args "-v /var/run/docker.sock:/var/run/docker.sock --entrypoint=''"
                }
            }
            steps {
                withCredentials([usernamePassword(credentialsId: 'tolujenkinstaskaws', passwordVariable: 'AWS_SECRET_ACCESS_KEY', usernameVariable: 'AWS_ACCESS_KEY_ID')]) {

                }
                
                sh '''
                dnf install -y docker
                aws ecr-public get-login-password --region $AWS_DEFAULT_REGION | docker login --username AWS --password-stdin public.ecr.aws/b3b5m5n0
                docker build -t $AWS_ECR_URI/$AWS_IMAGE_NAME:$BUILD_VERSION .
                docker images
                docker push $AWS_ECR_URI/$AWS_IMAGE_NAME:$BUILD_VERSION
                
                '''
            }
        }

        stage('Deploy to hostinger vps') {
            agent {
                docker {
                    image 'ubuntu:24.04'
                    reuseNode true
                    args "-u root --entrypoint='' "
                }
            }
            steps {
                withCredentials([string(credentialsId: 'HOSTINGER_API_KEY', variable: 'HOSTINGER_TOKEN')]) {
                    sh '''
                    apt-get update && apt-get install -y curl tar wget
                    wget https://github.com/hostinger/api-cli/releases/download/v0.1.1/hapi-0.1.1-linux-amd64.tar.gz
                    tar -xf hapi-0.1.1-linux-amd64.tar.gz
                    ls -la
                    mv hapi /usr/local/bin
                    export HAPI_API_TOKEN=$HOSTINGER_TOKEN
                    hapi --help
                    hapi vps vm list --format json
                    

                    '''
                }
            }
        }
    }
}
