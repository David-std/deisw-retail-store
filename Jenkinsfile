pipeline {
  agent any

  tools {
    maven 'MAVEN_3_9_11'
    jdk 'JDK_26'
  }

  environment {
    REGISTRY_USER = 'david6455544'
    IMAGE_NAME = 'retail-store-u20231b504'
    TAG = "${env.BUILD_NUMBER}"
  }

  stages {
    stage('Compile Project') {
      steps {
        withMaven(maven: 'MAVEN_3_9_11') {
          sh 'mvn clean compile'
        }
      }
    }

    stage('Validate Checkstyle') {
      steps {
        withMaven(maven: 'MAVEN_3_9_11') {
          sh 'mvn checkstyle:check'
        }
      }
    }

    stage('Validate Unit Tests') {
      steps {
        withMaven(maven: 'MAVEN_3_9_11') {
          sh 'mvn test'
        }
      }
    }

    stage('Validate Test Coverage') {
      steps {
        withMaven(maven: 'MAVEN_3_9_11') {
          sh 'mvn clean verify jacoco:report'
          sh 'mvn jacoco:check'
        }
      }
    }

    stage('SonarQube Analysis') {
      steps {
        withSonarQubeEnv('MiSonarServer') {
          sh '''
            mvn clean verify sonar:sonar \
              -Dsonar.projectKey=retail-store-u20231b504 \
              -Dsonar.projectName=retail-store-u20231b504
          '''
        }

        script {
          timeout(time: 10, unit: 'MINUTES') {
            def qualityGate = waitForQualityGate()

            if (qualityGate.status != 'OK') {
              error "Quality Gate no superado. Estado: ${qualityGate.status}"
            }
          }
        }
      }
    }

    stage('Construir y Publicar Imagen Docker') {
      steps {
        withCredentials([
          usernamePassword(
            credentialsId: 'DOCKER_HUB_CREDENTIALS',
            usernameVariable: 'DOCKER_USER',
            passwordVariable: 'DOCKER_PASS'
          )
        ]) {
          sh '''
            echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin

            docker buildx build \
              --platform linux/amd64 \
              -t ${REGISTRY_USER}/${IMAGE_NAME}:${TAG} \
              -t ${REGISTRY_USER}/${IMAGE_NAME}:latest \
              --push .

            docker logout
          '''
        }
      }
    }
  }
}
