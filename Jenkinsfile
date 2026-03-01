pipeline {
    agent any

    environment {
        TF_VAR_db_password = credentials('fomax-db-password') // Securely pulled from Jenkins Credentials Provider
        // AWS_CREDENTIALS removed; instance profile will be used
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Terraform Init') {
            steps {
                sh 'terraform init'
            }
        }

        stage('Terraform Plan') {
            steps {
                sh 'terraform plan -out=tfplan'
                archiveArtifacts artifacts: 'tfplan'
            }
        }

        stage('Approval') {
            steps {
                input message: "Does the plan look correct for the Fomax Landing Surge requirements?", ok: "Deploy!"
            }
        }

        stage('Terraform Apply') {
            steps {
                sh 'terraform apply -input=false tfplan'
            }
        }
    }

    post {
        success {
            echo "Infrastructure deployed successfully. Ready for landing surge."
        }
        failure {
            echo "Deployment failed. Check Terraform logs for resource conflicts."
        }
    }
}