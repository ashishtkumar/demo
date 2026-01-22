properties([parameters([choice(choices: ['main', 'feature', 'hostfix'], description: 'Select branch to build', name: 'branch')])])

node{
  stage("SCM Checkout"){
    git branch: "${params.branch}", url: 'https://github.com/ashishtkumar/demo.git'
  }
  stage('Run Pre-commit Hooks') {
    sh '''
      export PATH=$HOME/.local/bin:$PATH
      pre-commit run --all-files --hook-stage manual
    '''
  }
  stage('Run dependency-check') {
    def mvnHome = tool name: 'maven-3', type: 'maven'
    withCredentials([
      string(credentialsId: 'nvd-api-key', variable: 'NVD_API_KEY'),
      usernamePassword(credentialsId: 'ossindex-creds', usernameVariable: 'OSSINDEX_USERNAME', passwordVariable: 'OSSINDEX_PASSWORD')])
      { 
        withEnv(['MAVEN_OPTS=--enable-native-access=ALL-UNNAMED --add-modules jdk.incubator.vector']) 
        {
          sh """
          ${mvnHome}/bin/mvn org.owasp:dependency-check-maven:12.1.3:check \
          -DnvdApiKey=$NVD_API_KEY \
          -Dnvd.forceupdate=true \
          -DdataDirectory=target/dc-cache \
          -DossIndexUsername=$OSSINDEX_USERNAME \
          -DossIndexPassword=$OSSINDEX_PASSWORD \
          -Dformat=HTML \
          -DfailBuildOnCVSS=7
          """
        }
      }
  }
  stage('Publish Dependency Check Report') {
    publishHTML([
      reportDir: 'target',
      reportFiles: 'dependency-check-report.html',
      reportName: 'Dependency Check Report',
      keepAll: true,
      alwaysLinkToLastBuild: true,
      allowMissing: false
    ])
  }
  stage('Snyk Test') {
    withCredentials([string(credentialsId: 'snyk-api-token', variable: 'SNYK_TOKEN')]) {
      sh '''
        export PATH=$HOME/.local/bin:$PATH
        export PATH=/usr/local/bin:$PATH
        snyk auth $SNYK_TOKEN
        export PATH=/opt/apache-maven-3.9.9/bin:$PATH
        export JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
        mkdir -p target
        snyk test --all-projects --severity-threshold=high --json | snyk-to-html -o target/snyk-report.html || true
      '''
    }
  }
  stage('Publish Snyk Report') {
    publishHTML([
      reportDir: 'target',
      reportFiles: 'snyk-report.html',
      reportName: 'Snyk Vulnerability Report',
      keepAll: true,
      alwaysLinkToLastBuild: true,
      allowMissing: false
    ])
  }
  stage("Compile Package"){
    def mvnHome = tool name: 'maven-3', type: 'maven'
    // sh "${mvnHome}/bin/mvn package"
    sh "${mvnHome}/bin/mvn clean compile"
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
