pipeline {
    agent any

    parameters {
        choice(name: 'TERRAFORM_ACTION', choices: ['apply', 'destroy', 'plan'], description: 'Select Terraform action to perform')
        string(name: 'USER_NAME', defaultValue: 'shan', description: 'Specify who is running the code')
    }

    environment {
        AWS_ACCESS_KEY_ID = credentials('jen4')
    }

    stages {
        stage('Code checkout from Git') {
            steps {
                checkout scmGit(
                    branches: [[name: '*/main']], 
                    extensions: [], 
                    userRemoteConfigs: [[credentialsId: 'git-pass', url: 'https://github.com/shanilarej/eks-project.git']]
                )
            }
        }

        stage('terraform init') {
            steps {
                script {
                    sh "terraform init"
                }
            }
        }

        stage('Terraform Action') {
            steps {
                script {
                    // Perform selected Terraform action
                    if (params.TERRAFORM_ACTION == 'apply') {
                        sh 'terraform apply -auto-approve'
                    } else if (params.TERRAFORM_ACTION == 'destroy') {
                        sh 'terraform destroy -auto-approve'
                    } else if (params.TERRAFORM_ACTION == 'plan') {
                        sh 'terraform plan'
                    } else {
                        error "Invalid Terraform action selected: ${params.TERRAFORM_ACTION}"
                    }
                }
            }
        }
    }

    post {
        always {
            // Clean up workspace after pipeline execution
            cleanWs()
        }
    }
}

