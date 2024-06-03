pipeline{
    agent{
        lable 'rocky-09'
    }
    tools{
        jdk 'JAVA_HOME'
        nodejs 'NODEJS_HOME'
    }
    environment {
        SCANNER_HOME=tool 'sonar-server'
    }
    stages {
        stage('Workspace Cleaning'){
            steps{
                cleanWs()
            }
        }
        stage('Checkout from Git'){
            steps{
                git branch: 'main', url: 'https://github.com/sundarp1438/Netflix-Clone-K8S-End-to-End-Project.git'
            }
        }
        stage("Sonarqube Analysis"){
            steps{
                withSonarQubeEnv('sonar-server') {
                    sh ''' $SCANNER_HOME/bin/sonar-scanner -Dsonar.projectName=Netflix \
                    -Dsonar.projectKey=Netflix \
                    '''
                }
            }
        }
        stage("Quality Gate"){
           steps {
                script {
                    waitForQualityGate abortPipeline: false, credentialsId: 'sonar-token' 
                }
            } 
        }
        // stage('Install Dependencies') {
        //     steps {
        //         sh "npm install"
        //     }
        // }
        // stage('OWASP DP SCAN') {
        //     steps {
        //         dependencyCheck additionalArguments: '--scan ./ --disableYarnAudit --disableNodeAudit', odcInstallation: 'owasp-dp-check'
        //         dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
        //     }
        // }
        stage('TRIVY FS SCAN') {
            steps {
                sh "trivy fs . > trivyfs.txt"
            }
        }
        stage('Build Docker Image') {
            steps {
                script{
                    sh 'docker build --build-arg TMDB_V3_API_KEY=63cc6c7d94ca64ee08a360658a5dc5e4 -t sundarp1985/Netflix-app-pipeline:latest .'
                }
            }
        }
        stage('Containerize And Test') {
            steps {
                script{
                    sh 'docker run -d --name Netflix-app sundarp1985/Netflix-app-pipeline:latest && sleep 10 && docker stop Netflix-app'
                }
            }
        }
        stage('Push Image To Dockerhub') {
            steps {
                script{
                    withCredentials([string(credentialsId: 'DockerHubPass', variable: 'DockerHubPass')]) {
                    sh 'docker login -u sundarp1985 --password ${DockerHubPass}' }
                    sh 'docker push sundarp1985/Netflix-app-pipeline:latest'
                }
            }
        }  
        stage("TRIVY Image Scan"){
            steps{
                sh "trivy image sundarp1985/Netflix-app-pipeline:latest > trivyimage.txt" 
            }
        }
        // stage('Deploy to Kubernetes'){
        //     steps{
        //         script{
        //             dir('Kubernetes') {
        //                 withKubeConfig(caCertificate: '', clusterName: '', contextName: '', credentialsId: 'k8s', namespace: '', restrictKubeConfigAccess: false, serverUrl: '') {
        //                         sh 'kubectl apply -f deployment.yml'
        //                         sh 'kubectl apply -f service.yml'
        //                         sh 'kubectl get svc'
        //                         sh 'kubectl get all'
        //                 }   
        //             }
        //         }
        //     }
        // }
    }
    // post {
    //  always {
    //     emailext attachLog: true,
    //         subject: "'${currentBuild.result}'",
    //         body: "Project: ${env.JOB_NAME}<br/>" +
    //             "Build Number: ${env.BUILD_NUMBER}<br/>" +
    //             "URL: ${env.BUILD_URL}<br/>",
    //         to: 'aman07pathak@gmail.com',
    //         attachmentsPattern: 'trivyfs.txt,trivyimage.txt'
    //     }
    // }
}
