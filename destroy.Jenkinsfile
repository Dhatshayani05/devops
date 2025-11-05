pipeline {
    agent any
    tools {
        nodejs "nodejs"
        terraform "terraform"
    }
    stages {
        stage("Destroy") {
            environment {
                TFSTATE = sh (returnStdout: true, script: 
                """
                aws s3api list-buckets --query 'Buckets[].Name' | grep -wo "\\w*playgroundtfstate\\w*"
                """
                ).trim()
            }
            steps {
                script {
                    sh """
                    cd terraform
                    terraform init -no-color -backend-config="key=${UNIQUE_ANIMAL_IDENTIFIER}.tfstate" -backend-config="bucket=${TFSTATE}"
                    terraform destroy --auto-approve -no-color -var ARTIFACT=""
                    """
                }
            }
        }
    }
    post {
        cleanup {
            deleteDir()
        }
    }
}
