pipeline {
    agent any

    environment {
        IMAGE = "obitomanu/yuvi:ai-chat-${GIT_COMMIT}"
        NAMESPACE = "obito"
    }
    stages {
        stage('Clean Workspace') {
            steps {
                cleanWs()
            }
        }
        stage('Git Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/PrasannaKumarObito/Chat.git'
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
    //     stage('Build Image') {
    //         steps {
    //             sh """
    //                 printenv
    //                 docker build -t ${IMAGE} .
    //             """
    //         }
    //     }
    //     stage('Image Scan') {
    //         steps {
    //             sh """
    //                 trivy image ${IMAGE} > app-report.txt
    //             """
    //         }
    //     }
    //     stage('Push Image') {
    //         steps {
    //             script {
    //                 withDockerRegistry(credentialsId: 'Docker') {
    //                     sh """
    //                         docker push ${IMAGE}
    //                     """
    //                 }
    //             }
    //         }
    //     }
    //     stage('Deploy to EKS') {
    //         steps {
    //             withKubeConfig(
    //                 caCertificate: '',
    //                 clusterName: 'obito-cluster',
    //                 contextName: '',
    //                 credentialsId: 'kube',
    //                 namespace: 'obito',
    //                 restrictKubeConfigAccess: false,
    //                 serverUrl: 'https://25A46D23363173D176599E57083115DC.gr7.us-east-1.eks.amazonaws.com') {
    //                 sh """
    //                     sed -i 's|replace|${IMAGE}|g' Deployment.yml
    //                     grep image Deployment.yml
    //                     kubectl apply -f Deployment.yml -n ${NAMESPACE}
    //                 """
    //             }
    //         }
    //     }
    //     stage('Verify Deployment') {
    //         steps {
    //             withKubeConfig(
    //                 caCertificate: '',
    //                 clusterName: 'obito-cluster',
    //                 contextName: '',
    //                 credentialsId: 'kube',
    //                 namespace: 'obito',
    //                 restrictKubeConfigAccess: false,
    //                 serverUrl: 'https://25A46D23363173D176599E57083115DC.gr7.us-east-1.eks.amazonaws.com') {
    //                 sh """
    //                     kubectl get pods -n ${NAMESPACE}
    //                     kubectl get svc -n ${NAMESPACE}
    //                 """
    //             }
    //         }
    //     }
     }
}