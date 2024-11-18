pipeline {
    agent any
     environment {
        DOCKER_CREDENTIALS_ID = 'DockerHub-Token2'  // Replace with your credentials ID in Jenkins
        IMAGE_NAME = 'spring-boot-kong'
        DOCKER_IMAGE = 'spring-boot-kong'

        DOCKER_HUB_CREDENTIALS = 'DockerHub-Token2'   // Jenkins credentials ID
        DOCKER_IMAGE_NAME = 'esarulraj/spring-boot-kong'
        DOCKER_TAG = 'latest'
        DOCKER_REGISTRY = 'https://index.docker.io/v1/'

        TRIVY_VERSION = "0.45.0"
        //TRIVY_IMAGE = "aquasec/trivy"
        TRIVY_IMAGE = "aquasec/trivy:latest"  // Using the official Trivy Docker image
        TARGET_IMAGE = "your-image-name:latest"  // Replace with your actual image name
        KONG_ADMIN_URL = 'http://localhost:8002'
        KONG_YAML_FILE = 'kong/kong.yml'
    }

    tools{
        jdk 'jdk17'
        maven 'maven3'
    }

    stages {
        stage('Code Checkout') {
            steps {
                git branch: 'main', changelog: false, poll: false, url: 'https://github.com/SBArulraj/spring-kong.git'
            }
        }


        stage('OWASP Dependency Check'){
            steps{
                dependencyCheck additionalArguments: '--scan . --nvd.apiKey=76e3fda9-1746-4ff3-9ad3-e3a46ed42556 ./ ', odcInstallation: 'db-check'
                dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
            }
        }

        stage('Clean & Package'){
            steps{
                sh "mvn clean package -DskipTests"
            }
        }

        stage('Sonarqube Analysis') {
            steps {
                sh ''' mvn sonar:sonar \
                    -Dsonar.host.url=http://localhost:9000/ \
                    -Dsonar.login=squ_28d44b15fa63217d3c928fdaf8f47c5d80446719 '''
            }
        }



        stage('Test Docker Access') {
            steps {
                sh 'docker ps'
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
                    // Building the Docker image
                    //sh "docker build -t ${DOCKER_IMAGE_NAME}:${DOCKER_TAG} ."
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



        stage('Install Trivy'){

            steps {
             script {
                    // Check if Trivy is already installed, if not install it
                     echo "Running Trivy scan on ${DOCKER_IMAGE_NAME} using Docker image ${TRIVY_IMAGE}"

                    // Running Trivy scan using Docker
                    def scanResult = sh(
                        script: """
                        docker run --rm \
                        -v /var/run/docker.sock:/var/run/docker.sock \
                        -v /tmp/trivy-cache:/root/.cache/ \
                        ${DOCKER_IMAGE_NAME} image --severity HIGH,CRITICAL --no-progress ${DOCKER_IMAGE_NAME}
                        """,
                        returnStatus: true
                    )

                    if (scanResult != 0) {
                        echo "Trivy found vulnerabilities in ${DOCKER_IMAGE_NAME}. Please review the logs."
                        currentBuild.result = 'UNSTABLE'  // Mark build as unstable if vulnerabilities are found

                    } else {
                        echo "No critical vulnerabilities found in ${DOCKER_IMAGE_NAME}."

                    }
                }
            }
        }

        stage('Deploy with Docker Compose') {
            steps {
                script {
                    echo ' Staging Started successfully !!'
                    sh 'docker-compose down'
                    sh 'docker-compose up -d --build'
                    echo ' Staging Completed successfully !!'
                }
            }
        }

        stage('Configure Kong') {
            steps {
                script {
                    // Wait for Kong to be ready
                    sleep(time: 30, unit: 'SECONDS')

                    // Apply the Kong configuration
                    sh 'docker-compose exec kong-gateway kong config db_import /etc/kong/kong.yml'
                }
            }
        }


        stage('Logout Docker') {
            steps {
                script {
                    // Logout from Docker Hub
                    sh "docker logout"
                }
            }
        }

    }

    post {
        always {
            echo 'Post-build actions'
            // Clean up
            sh 'docker-compose down'
        }
        success {
            echo 'Build completed successfully'
        }
        failure {
            echo 'Build failed'
        }
    }


}