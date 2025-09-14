pipeline {
    agent any

    stages {
        agent {
            docker {
                image 'nginx:1.28.0-alpine'
                reuseNode true
            }
        }
        stage('Hello') {
            steps {
                echo 'Hello World'
            }
        }
    }
}
