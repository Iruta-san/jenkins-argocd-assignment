pipeline {
    
    agent any

    environment { // configure credentials to use AWS ECR
        APPNAME='testapp'

        AWS_ACCESS_KEY_ID     = credentials('jenkins-aws-secret-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('jenkins-aws-secret-access-key')
        AWS_ACCOUNT_ID        = credentials('aws-account-id')
        REGION='us-west-2'
        

        REGISTRY =   "${AWS_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com"
        IMAGE_NAME = "${REGISTRY}/${APPNAME}"
        IMAGE_TAG =  "build-${BUILD_NUMBER}"
    }

    // Using GItHub webhook as a trigger would be much better,
    // but I don't have an accessible URL for Jenkins server
    // so for this assignment we're going to poll the repo every minute
    triggers { 
        pollSCM('H/1 * * * *') // Polls the repository every 1 minutes
    }


    stages {
        // Checkout the repo
        stage('Checkout') {
            steps {
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: '*/master']], // for this assignment we're only using master branch now
                    userRemoteConfigs: [[
                        url: 'https://github.com/Iruta-san/jenkins-argocd-assignment.git' // Replace with your repository URL
                    ]]
                ])
            }
        }

        stage('Docker Build') {
            steps {
                // script {
                //     REGISTRY = "${AWS_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com"
                // }
                echo "${REGISTRY}"
                sh 'env | sort'
                sh 'docker build -t $IMAGE_NAME:$IMAGE_TAG app'
            }
        }

        stage('Docker Test') {
            steps {
                sh 'docker run --rm $IMAGE_NAME:$IMAGE_TAG nginx -t'
            }
        }

        stage('Registry Login') {
            steps {
                sh 'aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com'
            }
        }        
// docker run -v $(pwd):$(pwd) -w $(pwd) nginx:1.25 nginx -t -c $(pwd)/app/app.conf -c /etc/nginx/nginx.conf
        // Other stages for build, deploy, etc.
    }
}