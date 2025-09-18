pipeline {
    agent any

    environment {
        HAPI_VERSION = "0.1.1"
    }

    stages {

        stage('Build') {
            agent {
                docker {
                    image 'node:18-alpine'
                    reuseNode true
                }
            }
            steps {
                sh '''
                ls
                node --version
                npm --version
                npm ci
                npm run build
                ls -la
                '''
                archiveArtifacts artifacts: 'build/**', followSymlinks: false, onlyIfSuccessful: true
            }
        }

        stage('Deploy to hostinger') {
            agent {
                docker {
                    image 'ubuntu:24.04'
                    reuseNode true
                    args "-u root"
                }
            }
            steps {
                withCredentials([string(credentialsId: 'HOSTINGER_API_KEY', variable: 'HOSTINGER_TOKEN')]) {
                    sh '''
                    apt-get update && apt-get install -y curl tar wget
                    cd /home
                    wget hapi-${HAPI_VERSION}-linux-amd64.tar.gz \
                    https://github.com/hostinger/api-cli/releases/download/${HAPI_VERSION}/hapi-${HAPI_VERSION}-linux-amd64.tar.gz
                    tar -xf hapi-${HAPI_VERSION}-linux-amd64.tar.gz
                    ls -la
                    mv hapi /usr/local/bin
                    export HAPI_API_TOKEN=$HOSTINGER_TOKEN
                    hapi --help
                    hapi vps vm list

                    '''
                }
            }
        }
    }
}
