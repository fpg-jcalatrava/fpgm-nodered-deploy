pipeline {

    agent {
        label "${params.TARGET_AGENT}"
    }

    parameters {

        choice(
            name: 'TARGET_AGENT',
            choices: [
                'docker-slave-01',
                'docker-slave-02',
                'docker-slave-prod'
            ],
            description: 'Target Jenkins Docker agent'
        )

        string(
            name: 'APP_NAME',
            defaultValue: 'nodered',
            description: 'Docker container name'
        )

        string(
            name: 'IMAGE_TAG',
            defaultValue: 'latest',
            description: 'Docker image tag'
        )

        string(
            name: 'NODE_RED_PORT',
            defaultValue: '1880',
            description: 'Node-RED exposed port'
        )

        string(
            name: 'DEPLOY_DIR',
            defaultValue: '/home/jenkins/deploy/nodered',
            description: 'Persistent data directory'
        )

        string(
            name: 'TZ',
            defaultValue: 'Asia/Manila',
            description: 'Timezone'
        )

        text(
            name: 'NODE_RED_ENV',
            defaultValue: '''\
KAFKA_BROKER=10.52.2.10:9092
API_BASE_URL=https://api.fpgins.com
''',
            description: 'Additional environment variables'
        )
    }

    environment {
        IMAGE_NAME = 'fpg-nodered'
    }

    stages {

        stage('Show Target') {
            steps {
                echo "Deploying to agent: ${params.TARGET_AGENT}"
            }
        }

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Node-RED Image') {
            steps {
                sh '''
                    docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .
                '''
            }
        }

        stage('Prepare Persistent Data') {
            steps {
                sh '''
                    docker run --rm -u root \
                      -v ${DEPLOY_DIR}:/mnt \
                      alpine:latest sh -c "
                        mkdir -p /mnt/data &&
                        chown -R 1000:1000 /mnt/data &&
                        chmod -R 755 /mnt/data
                      "
                '''
            }
        }

        stage('Generate Env File') {
            steps {
                writeFile file: '.env', text: """
TZ=${TZ}
${NODE_RED_ENV}
"""
            }
        }

        stage('Stop Existing Container') {
            steps {
                sh '''
                    docker rm -f ${APP_NAME} || true
                '''
            }
        }

        stage('Deploy Node-RED') {
            steps {
                sh '''
                    docker run -d \
                      --name ${APP_NAME} \
                      --restart unless-stopped \
                      -p ${NODE_RED_PORT}:1880 \
                      --env-file .env \
                      -v ${DEPLOY_DIR}/data:/data \
                      ${IMAGE_NAME}:${IMAGE_TAG}
                '''
            }
        }

        stage('Verify Deployment') {
            steps {
                sh '''
                    echo "Container Status:"
                    docker ps --filter name=${APP_NAME}

                    echo "Container Environment:"
                    docker exec ${APP_NAME} env

                    echo "Checking Node-RED..."
                    sleep 5
                    curl -I http://localhost:${NODE_RED_PORT} || true
                '''
            }
        }
    }

    post {

        failure {
            sh '''
                echo "Deployment failed. Showing logs..."
                docker logs --tail=100 ${APP_NAME} || true
            '''
        }

        success {
            echo 'Node-RED deployment completed successfully.'
        }
    }
}
