pipeline {
    
    agent any

    environment { // configure credentials to use AWS ECR
        APPNAME='testapp'
        AWS_ACCOUNT_ID = '427560904335'
        
        // AWS_ACCESS_KEY_ID     = credentials('jenkins-aws-secret-key-id')
        // AWS_SECRET_ACCESS_KEY = credentials('jenkins-aws-secret-access-key')
        // AWS_ACCOUNT_ID        = credentials('aws-account-id')
        REGION='us-east-2'
        

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
        
        // Shell alternative
        // stage('Docker Build') {
        //     steps {
        //         sh 'docker build -t $IMAGE_NAME:$IMAGE_TAG app'
        //     }
        // }
        
        stage('Build image') {
            /* This builds the actual image; synonymous to
             * docker build on the command line */
            steps {
                script {
                    def dockerapp = docker.build("${IMAGE_NAME}", "./app")
                }    
            }
            
        }


    // Can't control image user here...
    // stage('Test image') {
    //         steps {
    //             script {
    //                 docker.image("${IMAGE_NAME}").inside {
    //                     sh 'nginx -T'
    //                 }
    //             }    
    //         }        
    // }        

        stage('Docker Test') {
            steps {
                sh 'docker run --rm $IMAGE_NAME nginx -t'
            }
        }

        // Shell alternative
        // stage('Registry Login') {
        //     steps {
        //         sh 'aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com'
        //     }
        // }   
        
        
        stage('Deploy Image') {
            steps {
                script{
                    docker.withRegistry("https://${REGISTRY}/${APPNAME}", "ecr:${REGION}:jenkins-aws-credentials") {
                        docker.image("${IMAGE_NAME}").push("build-${BUILD_NUMBER}")
                        docker.image("${IMAGE_NAME}").push("latest")
                    }
                }
            }
        }        

    }
}