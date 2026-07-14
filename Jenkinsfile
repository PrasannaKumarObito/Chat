pipeline {
    agent any

    stages {
        stage('cleanWs') {
            steps {
                cleanWs()
            }
        }
        stage('git checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/PrasannaKumarObito/Chat.git'
            }
        }
        stage('SonarQube Analysis') {
             steps {
                script {
                    def scannerHome = tool 'Sonar'

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
    }
}