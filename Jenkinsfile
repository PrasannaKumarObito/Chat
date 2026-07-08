pipeline {
    agent any
    
    environment{
        Obito="chat:${GIT_COMMIT}"
    }

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
                waitForQualityGate abortPipeline: false, credentialsId: 'Sonar-token'
            }
        }
        stage('build image'){
            steps {
                sh '''
                   printenv
                   docker build -t ${Obito} .
                 '''  
            }
        }
    }
}