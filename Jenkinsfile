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
                script {
                    def action = input(
                        message: "Select action for Fomax Landing Surge infrastructure:",
                        ok: "Proceed",
                        parameters: [
                            choice(name: 'ACTION', choices: ['Deploy', 'Destroy'], description: 'Choose Deploy or Destroy')
                        ]
                    )
                    env.ACTION = action
                }
            }
        }

        stage('Terraform Apply or Destroy') {
            steps {
                script {
                    if (env.ACTION == 'Deploy') {
                        sh 'terraform apply -input=false tfplan'
                    } else if (env.ACTION == 'Destroy') {
                        sh 'terraform destroy -auto-approve'
                    }
                }
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