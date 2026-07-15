pipeline {
    agent any

   environment {
    obito = "obitomanu/yuvi:ai-chat-${GIT_COMMIT}"
    NAMESPACE = "obito"
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
                    sh 'docker push ${obito}'
                    }
            }
        }
        }
        stage('Deploying EKS cluster') {
            steps {
                withKubeConfig(caCertificate: '', clusterName: ' obito-cluster', contextName: '', credentialsId: 'kube', namespace: 'obito', restrictKubeConfigAccess: false, serverUrl: 'https://25A46D23363173D176599E57083115DC.gr7.us-east-1.eks.amazonaws.com') {
                     sh """
                        sed -i 's|replace|${obito}|g' Deployment.yml
                        grep image Deployment.yml
                        kubectl apply -f Deployment.yml -n ${NAMESPACE}
                        """
                }
            }
        }
        stage('Verify the deployment') {
            steps {
                withKubeConfig(caCertificate: '', clusterName: ' obito-cluster', contextName: '', credentialsId: 'kube', namespace: 'obito', restrictKubeConfigAccess: false, serverUrl: 'https://25A46D23363173D176599E57083115DC.gr7.us-east-1.eks.amazonaws.com') {
                   sh 'kubectl get pods -n ${NAMESPACE}'
                    sh 'kubectl get svc -n ${NAMESPACE}'
                }
            }
        }
    }
}