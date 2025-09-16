pipeline {
    agent any

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
            }
                sh '''
                ls
                wget https://github.com/hostinger/api-cli/archive/refs/tags/v0.1.9.tar.gz
                tar -xf hapi-v0.1.9-linux-amd64.tar.gz
                sudo mv hapi /usr/local/bin

                export HAPI_API_TOKEN=$HOSTINGER_TOKEN
                hapi --help


            '''
            }
        
        }
        
    }
}
