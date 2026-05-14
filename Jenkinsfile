pipeline {
    agent {
        label 'docker-slave-02'
    }

    environment {
        APP_NAME = 'nodered'
        IMAGE_NAME = 'fpg-nodered'
        IMAGE_TAG = 'latest'
        NODE_RED_PORT = '1880'
        DEPLOY_DIR = '/home/jenkins/deploy/nodered'
    }

    stages {
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
                    mkdir -p ${DEPLOY_DIR}/data
                    chown -R 1000:1000 ${DEPLOY_DIR}/data || true
                    chmod -R 755 ${DEPLOY_DIR}/data || true
                '''
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
                      -v ${DEPLOY_DIR}/data:/data \
                      -e TZ=Asia/Manila \
                      ${IMAGE_NAME}:${IMAGE_TAG}
                '''
            }
        }

        stage('Verify Deployment') {
            steps {
                sh '''
                    docker ps --filter name=${APP_NAME}
                    sleep 5
                    curl -I http://localhost:${NODE_RED_PORT} || true
                '''
            }
        }
    }
}
