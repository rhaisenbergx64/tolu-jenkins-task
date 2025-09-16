pipeline {
    agent any

    environment {
        HAPI_VERSION = "v0.1.9"
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
            steps {
                withCredentials([string(credentialsId: 'HOSTINGER_API_KEY', variable: 'HOSTINGER_TOKEN')]) {
                sh '''
                ls -la
                apk add --no-cache curl tar sudo
                curl -L -o hapi-${HAPI_VERSION}-linux-amd64.tar.gz \
                https://github.com/hostinger/api-cli/releases/download/${HAPI_VERSION}/hapi-${HAPI_VERSION}-linux-amd64.tar.gz
                tar -xf hapi-${HAPI_VERSION}-linux-amd64.tar.gz
                ls -la
                mv hapi /usr/local/bin
                export HAPI_API_TOKEN=$HOSTINGER_TOKEN
                hapi --help
            '''
                }
                }
         }
        
        }
    }


