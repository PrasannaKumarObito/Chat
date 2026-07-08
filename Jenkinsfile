pipeline {
    agent any

    stages {
        stage('CleanWS') {
            steps {
                cleanWs()
            }
        }
    }
    stages {
        stage('checkOut') {
            steps {
                git branch: 'main', url: 'https://github.com/PrasannaKumarObito/Chat.git'
            }
        }
    }
}