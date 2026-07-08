pipeline {
    agent any

    stages {
        stage('CleanWS') {
            steps {
                cleanWs()
            }
        }
        stage('checkOut') {
            steps {
                git branch: 'main', url: 'https://github.com/PrasannaKumarObito/Chat.git'
            }
        }
        stage('SonarQube Analysis') {
             steps {
                script {
                    def scannerHome = tool 'SonarScanner'

                    withSonarQubeEnv('SonarQube') {

                        sh """
                        ${scannerHome}/bin/sonar-scanner \
                        -Dsonar.projectKey=Chat \
                        -Dsonar.projectName=Chat \
                        -Dsonar.sources=. \
                        -Dsonar.sourceEncoding=UTF-8
                          """
                    }
                }
             }
        }
        stage('Quality Gate') {
            steps {
                script {
                    waitForQualityGate abortPipeline: false, credentialsId: 'Sonar-token'
                }
            }
        }
    }
}