pipeline {
    agent any
    environment {
        DOCKER_HUB_CREDENTIALS = 'DockerHub-Token2'
        DOCKER_IMAGE_NAME = 'esarulraj/spring-boot-kong'
        DOCKER_TAG = 'latest'
        KONG_ADMIN_URL = 'http://localhost:8001'
        KONG_YAML_FILE = 'kong/kong.yml'
       // DOCKER_HOST = "unix:///var/run/docker.sock"

    }

    tools {
        jdk 'jdk17'
        maven 'maven3'
    }

    stages {
        stage('Code Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/SBArulraj/spring-kong.git'

            }
        }

        stage('Build') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }
        stage('Docker Login') {
            steps {
                script {
                    // Logging in to Docker Hub using Jenkins credentials
                    withCredentials([usernamePassword(credentialsId: DOCKER_HUB_CREDENTIALS,
                                                       usernameVariable: 'esarulraj',
                                                       passwordVariable: 'JvaJsf@2')]) {
                        sh """
                            echo JvaJsf@2 | docker login -u esarulraj --password-stdin
                        """
                    }
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    //sh 'docker build -t ${DOCKER_IMAGE_NAME}:${DOCKER_TAG} .'
                    sh "docker build -t ${DOCKER_IMAGE_NAME}:${DOCKER_TAG} -f Dockerfile.final ."
                }
            }
        }

         stage('Push Docker Image') {
            steps {
                script {
                    // Pushing the image to Docker Hub
                    sh "docker push ${DOCKER_IMAGE_NAME}:${DOCKER_TAG}"
                }
            }
        }

        /*stage('Push Docker Image') {
            steps {

                script {
                    // Logging in to Docker Hub using Jenkins credentials
                    withCredentials([usernamePassword(credentialsId: DOCKER_HUB_CREDENTIALS,
                                                       usernameVariable: 'esarulraj',
                                                       passwordVariable: 'JvaJsf@2')]) {

                        sh 'echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin'
                        sh 'docker push ${DOCKER_IMAGE_NAME}:${DOCKER_TAG}'
                    }
                }
            }
        }*/

        stage('Deploy with Docker Compose') {
            steps {
                script {
                    sh 'docker-compose down'
                    echo 'Docker compose down executed successfully!!!.'
                    sh 'docker-compose up -d --build'
                }
            }
        }

        /* stage('Configure Kong') {
            steps {
                script {
                    sleep(time: 30, unit: 'SECONDS')
                    sh 'docker-compose exec kong kong config db_import /etc/kong/kong.yml'
                }
            }
        }*/

		 stage('Configure Kong') {
            steps {
                script {
                    // Wait for Kong to be ready
                    echo 'Docker pull kong/kong-gateway  - Start '
                    sh 'docker pull kong/kong-gateway'
                    echo 'Docker pull kong/kong-gateway  - end '

                    sleep(time: 30, unit: 'SECONDS')

                    // Apply the Kong configuration
                    sh 'docker-compose exec -T kong kong config db_import /etc/kong/kong.yml'
                }
            }
        }

		/*stage('Apply Kong Configuration') {
            steps {
                script {
				echo "Kong configuration started!!."
                    // Use Kong Admin API to apply the configuration
                    def configApply = sh(
                        script: "curl -i -X PUT ${KONG_ADMIN_URL}/config \
                                 -F 'config=@kong/kong.yml'",
                        returnStatus: true
                    )
                    if (configApply != 0) {
                        error "Failed to apply Kong configuration."
                    } else {
                        echo "Kong configuration applied successfully."
                    }
                }
            }
        }*/
    }

    post {
        always {
            sh 'docker-compose down'
        }
    }
}