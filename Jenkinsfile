pipeline {
    
    agent any

    environment { // configure credentials to use AWS ECR
        AWS_ACCESS_KEY_ID     = credentials('jenkins-aws-secret-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('jenkins-aws-secret-access-key')
        REGISTRY = '427560904335.dkr.ecr.us-east-2.amazonaws.com'
        APPNAME='testapp'
        IMAGE_NAME = "$REGISTRY/$APPNAME"
        IMAGE_TAG = "build-$BUILD_NUMBER"
    }

    // Using GItHub webhook as a trigger would be much better,
    // but I don't have an accessible URL for Jenkins server
    // so for this assignment we're going to poll the repo every minute
    triggers { 
        pollSCM('H/1 * * * *') // Polls the repository every 1 minutes
    }
// WORKSPACE
// The absolute path of the workspace
//  ${env.WORKSPACE}


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
            // agent {
            //     docker { 
            //         image 'docker:1.25'
            //         reuseNode true
            //     }
            // } 
            steps {
                sh 'env | sort'
                sh 'docker build -t $IMAGE_NAME:$IMAGE_TAG app'
            }
        }

        stage('Test Configs') {
            // agent {
            //     docker { 
            //         image 'nginx:1.25'
            //         reuseNode true
            //         args '--user root'
            //     }
            // } 
            steps {
                //sh 'nginx -t'
                sh 'docker run --rm $IMAGE_NAME:$IMAGE_TAG nginx -t'
            }
        }
// docker run -v $(pwd):$(pwd) -w $(pwd) nginx:1.25 nginx -t -c $(pwd)/app/app.conf -c /etc/nginx/nginx.conf
        // Other stages for build, deploy, etc.
    }
}