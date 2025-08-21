properties([parameters([choice(choices: ['main', 'feature', 'hostfix'], description: 'Select branch to build', name: 'branch')])])

node{
  stage("SCM Checkout"){
    git branch: "${params.branch}", url: 'https://github.com/ashishtkumar/demo.git'
  }
  stage('Run Pre-commit Hooks') {
    sh '''
      chmod +x hooks/java_maven_check.sh
      export PATH=$HOME/.local/bin:$PATH
      pre-commit run --all-files --hook-stage manual
    '''
  }
  stage("Compile Package"){
    def mvnHome = tool name: 'maven-3', type: 'maven'
    sh "${mvnHome}/bin/mvn package"
  }
  stage("SonarQube Analysis"){
    def mvnHome= tool name: 'maven-3', type: 'maven'
    withSonarQubeEnv('sonar-10'){
      sh "${mvnHome}/bin/mvn sonar:sonar"
    }
  }
  stage("Quality Gate Status Check"){
    sleep(60)
    timeout(time: 5, unit: 'MINUTES'){
      def qg = waitForQualityGate()
      if (qg.status != 'OK'){
        slackSend baseUrl: 'https://hooks.slack.com/services', channel: '#test', color: 'danger', message: 'Quality Gate Status Check Failed',
          teamDomain: "AppDev", tokenCredentialId: "slack"
        error "Pipleline Aborted due to quality gate failure: ${qg.status}"
    }
   }
    echo "Quality Gate Staus Passed"
  }
  stage("Deploy to tomcat"){
    sshagent(['tomcat-dev']) {
      sh 'scp -o StrictHostKeyChecking=no target/*.war jenkins@localhost:/var/lib/tomcat9/webapps/'
    }
  }
  stage("Email Notification"){
    mail bcc: '', cc:'', from: '', replyTo: '', subject: 'Jenkins Job', to: 'ashishvkumar7@gmail.com',
      body: '''Hi, Welcome to jenkins email address.
      Thanks,
      Jenkins'''
  }
  stage("Slack Notification"){
    slackSend baseUrl: 'https://hooks.slack.com/services', channel: '#test', color: 'good', message: 'Welcome to Jenkins!',
      teamDomain: "AppDev", tokenCredentialId: "slack"
  }
}
