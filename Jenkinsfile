node{
  stage("SCM Checkout"){
    git branch: 'main', url: 'https://github.com/ashishtkumar/demo.git'
  }
  stage("Compile Package"){
    def mvnHome = tool name: 'maven3', type: 'maven'
    sh "$(mvnHome)/bin/mvn package"
  }
}
