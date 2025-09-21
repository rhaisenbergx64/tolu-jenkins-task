pipeline {
    agent any

    stages {
        stage('Hello') {
            steps {
                echo 'Hello World'
            }
        }

        stage('Test SSH to VPS') {
            steps {
                sshagent(['rhaisenberg']) {
                    sh '''
                        ssh -p 2222 -o StrictHostKeyChecking=no rhaisenberg@server.toluwalasheolosunde.xyz "hostname"
                    '''
                }
            }
        }

        stage('Deploy') {
            steps {
                sshagent(['rhaisenberg']) {
                    sh '''
                        ssh -p 2222 -o StrictHostKeyChecking=no rhaisenberg@server.toluwalasheolosunde.xyz "
                            echo '--- Stopping old container if running ---' &&
                            docker ps -q --filter \\"name=tolu-jenkins-task\\" | grep -q . && docker stop tolu-jenkins-task && docker rm tolu-jenkins-task || echo 'No old container' &&

                            echo '--- Running new container ---' &&
                            docker run -d --name tolu-jenkins-task -p 3000:80 public.ecr.aws/b3b5m5n0/tolu-jenkins-task:${BUILD_NUMBER} &&

                            echo '--- Showing running containers ---' &&
                            docker ps -a &&

                            echo '--- Cleaning up old images ---' &&
                            docker image prune -f
                        "
                    '''
                }
            }
        }
    }
}
