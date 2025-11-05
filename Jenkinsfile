pipeline {
    agent any

    environment {
        PATH = "/opt/homebrew/bin:${env.PATH}"     // For Mac npm/node
        NODE_OPTIONS = "--openssl-legacy-provider"
        AWS_DEFAULT_REGION = "us-east-1"
    }

    stages {

        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/Dhatshayani05/devops.git'
            }
        }

        stage('Install Dependencies') {
            steps {
                sh 'npm install'
            }
        }

        stage('Build React App') {
            steps {
                sh 'CI=false npm run build'
            }
        }

        stage('Deploy to AWS via Terraform') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds']]) {
                    dir('terraform') {
                        sh """
                          terraform init
                          terraform apply -auto-approve \
                            -var="AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}" \
                            -var="AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}"
                        """
                    }
                }
            }
        }
    }
}
