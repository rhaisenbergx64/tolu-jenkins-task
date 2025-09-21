pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = "us-east-1"
        AWS_IMAGE_NAME = "tolu-jenkins-task"
        AWS_ECR_URI = "public.ecr.aws/b3b5m5n0"
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
                    image 'docker:24.0.5-cli'
                    reuseNode true
                    args "-u root -v /var/run/docker.sock:/var/run/docker.sock"
                }
            }
            steps {
                withCredentials([usernamePassword(credentialsId: 'tolujenkinstaskaws', passwordVariable: 'AWS_SECRET_ACCESS_KEY', usernameVariable: 'AWS_ACCESS_KEY_ID')]) {
                    sh '''
                    apk add --no-cache python3 py3-pip
                    pip3 install awscli

                    echo "🔹 Building Docker image..."
                    docker build -t $AWS_ECR_URI/$AWS_IMAGE_NAME:$BUILD_VERSION .

                    echo "🔹 Listing images..."
                    docker images

                    echo "🔹 Logging in to AWS ECR..."
                    aws ecr-public get-login-password --region $AWS_DEFAULT_REGION | \
                        docker login --username AWS --password-stdin $AWS_ECR_URI

                    echo "🔹 Pushing Docker image..."
                    docker push $AWS_ECR_URI/$AWS_IMAGE_NAME:$BUILD_VERSION

                    echo "🔹 Containers running locally:"
                    docker ps -a
                    '''
                }
            }
        }

        stage('Pull and Deploy to Hostinger Vps') {
            steps {
                sshagent(['VPS_SSH_KEY']) {
                    sh '''
                    ssh -p 2222 -o StrictHostKeyChecking=no rhaisenberg@server.toluwalasheolosunde.xyz << EOF
                    docker ps -a
                    docker pull $AWS_ECR_URI/$AWS_IMAGE_NAME:$BUILD_VERSION
                    docker images
                    docker stop $AWS_IMAGE_NAME || true
                    docker rm $AWS_IMAGE_NAME || true
                    docker run -d --name $AWS_IMAGE_NAME -p 3000:3000 $AWS_ECR_URI/$AWS_IMAGE_NAME:$BUILD_VERSION
                    docker ps -a
EOF
                    '''
                }
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
                    hapi vps vm
                    cleanWs()
                    '''
                }
            }
        }
    }
}
