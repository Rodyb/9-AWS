#!/usr/bin/env groovy

pipeline {
   agent any
   environment {
        DIGITAL_OCEAN_IP = credentials('jenkins_id')
    }
    stages {
        stage('Update version') {
            steps {
                script {
                    dir("app") {
                        sh "npm version minor"
                        def packageJson = readJSON file: 'package.json'
                        def getVersion = packageJson.version
                        env.IMAGE_NAME = "$getVersion-$BUILD_NUMBER"
                    }
                }
            }
        }
        stage('Docker build and push') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-credentials', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                    sh "docker build -t rodybothe2/node-app-new:${IMAGE_NAME} ."
                    sh 'echo $PASS | docker login -u $USER --password-stdin'
                    sh "docker push rodybothe2/node-app-new:${IMAGE_NAME}"
                }
            }
        }
        stage('Deploy to EC2') {
            steps {
                script {
                    def dockerCmd = "bash ./server-cmds.sh ${IMAGE_NAME}"
                    def ec2Instance = "ec2-user@3.121.174.25"
                    def shellCmd = "bash ./update_inbound_rule.sh ${DIGITAL_OCEAN_IP}"
                    sshagent(['ec2-user']) {
                        sh "scp -o StrictHostKeyChecking=no server-cmds.sh docker-compose.yml ${ec2Instance}:~/"
                        sh "scp -o StrictHostKeyChecking=no update_inbound_rule.sh ${ec2Instance}:~/"
                        sh "scp -o StrictHostKeyChecking=no docker-compose.yml ${ec2Instance}:~/"
                        sh "ssh -tt -o StrictHostKeyChecking=no ec2-user@3.121.174.25 ${dockerCmd}"
                        sh "ssh -tt -o StrictHostKeyChecking=no ec2-user@3.121.174.25 ${shellCmd}"
                    }
                }
            }
        }
    }
}