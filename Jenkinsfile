pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = "us-east-1"
        AWS_IMAGE_NAME = "tolu-jenkins-task"
        AWS_ECR_URI    = "public.ecr.aws/b3b5m5n0"
        BUILD_VERSION  = "1.0.${BUILD_ID}"
    }

    stages {
        stage("Build") {
            agent {
                docker {
                    image 'node:18-alpine'
                    reuseNode true
                }
            }
            steps {
                sh """
                npm ci
                BUILD_VERSION=$BUILD_VERSION npm run build
                echo "Build completed with version: $BUILD_VERSION"
                """
            }
        }

        stage("Build and push Docker Image to ECR") {
            agent {
                docker {
                    image 'amazon/aws-cli:2.13.2'
                    reuseNode true
                    args "-u root -v /var/run/docker.sock:/var/run/docker.sock --entrypoint=''"
                }
            }
            steps {
                withCredentials([usernamePassword(credentialsId: 'tolujenkinstaskaws', passwordVariable: 'AWS_SECRET_ACCESS_KEY', usernameVariable: 'AWS_ACCESS_KEY_ID')]) {
                    sh """
                    docker build -t $AWS_ECR_URI/$AWS_IMAGE_NAME:$BUILD_VERSION .
                    docker images
                    aws ecr-public get-login-password --region $AWS_DEFAULT_REGION | docker login --username AWS --password-stdin $AWS_ECR_URI
                    docker push $AWS_ECR_URI/$AWS_IMAGE_NAME:$BUILD_VERSION
                    """
                }
            }
        }

        stage("Deploy to Hostinger VPS via SSH") {
            steps {
                sshagent(['VPS_SSH_KEY']) {
                    sh """
                    ssh -p 2222 -o StrictHostKeyChecking=no rhaisenberg@server.toluwalasheolosunde.xyz << EOF
                      docker pull $AWS_ECR_URI/$AWS_IMAGE_NAME:$BUILD_VERSION
                      docker stop $AWS_IMAGE_NAME || true
                      docker rm $AWS_IMAGE_NAME || true
                      docker run -d --name $AWS_IMAGE_NAME -p 80:3000 $AWS_ECR_URI/$AWS_IMAGE_NAME:$BUILD_VERSION
                      docker ps -a
EOF
                    """
                }
            }
        }
    }
}
