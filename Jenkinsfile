pipeline {
    agent any

    environment {
        obito="ai-chat:${GIT_COMMIT}"
    }
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
        stage('Build-Iamge') {
            steps {
                sh '''
                printenv
                docker build -t ${obito} .
                '''
            }
        }
        stage('Iamge Scan'){
            steps {
                sh 'trivy image ${obito} >> app-report.txt'
            }
        }
        stage('tag and push') {
            steps {
                script {
                    withDockerRegistry(credentialsId: 'Docker') {
                        sh 'docker tag ${obito} obitomanu/yuvi:AI-Chat'
                        sh 'docker push obitomanu/yuvi:AI-Chat'
                    }
                }
            }
        }
    }
}