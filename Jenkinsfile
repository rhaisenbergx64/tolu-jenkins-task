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
                    apt-get update && apt-get install -y curl tar

                    curl -L -o hapi-${HAPI_VERSION}-linux-amd64.tar.gz \
                    https://github.com/hostinger/api-cli/archive/refs/tags/${HAPI_VERSION}.tar.gz
                    ls -la
                    mv hapi /usr/local/bin

                    export HAPI_API_TOKEN=$HOSTINGER_TOKEN

                    # Sanity check
                    hapi --help

                    # Example deploy (replace with your actual values)
                    # hapi apps deploy --token $HAPI_API_TOKEN --app-id <your-app-id> --file build/
                    '''
                }
            }
        }
    }
}
