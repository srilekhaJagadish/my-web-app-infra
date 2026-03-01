pipeline {
    agent any

    environment {
        TF_VAR_db_password = credentials('fomax-db-password') // Securely pulled from Jenkins Credentials Provider
        AWS_CREDENTIALS    = credentials('aws-creds')
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
                // Generates a plan file to ensure the 'Apply' stage uses the exact same logic
                sh 'terraform plan -out=tfplan'

                // Optional: Archive the plan so you can inspect it in the Jenkins UI
                archiveArtifacts artifacts: 'tfplan'
            }
        }

        stage('Approval') {
            // Human-in-the-loop to verify scaling limits and DB changes
            steps {
                input message: "Does the plan look correct for the Fomax Landing Surge requirements?", ok: "Deploy!"
            }
        }

        stage('Terraform Apply') {
            steps {
                // Only applies the previously generated plan
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