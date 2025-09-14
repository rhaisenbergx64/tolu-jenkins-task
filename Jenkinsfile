pipeline {
    agent any

    stages {

        stage('Hello') {
            agent {
                docker {
                    image 'nginx:1.28.0-alpine'
                    reuseNode true
            }
        }
            steps {
                sh '''
                echo 'Hello World'
                nginx -h
                echo 'We are testing Github Webhooks 1'

                    '''
            }
        }
    }
}
