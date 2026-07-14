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

            withSonarQubeEnv('Sonar') {

                sh """
                ${scannerHome}/bin/sonar-scanner \
                  -Dsonar.projectKey=AI-Chat \
                  -Dsonar.projectName=AI-Chat \
                  -Dsonar.sources=. \
                  -Dsonar.sourceEncoding=UTF-8
                """
            }
        }
    }
        }
        stage('Quality Gate') {
            steps {
                waitForQualityGate abortPipeline: false, credentialsId: 'Sonar'
            }
        }
    }
}