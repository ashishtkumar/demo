FROM tomcat:8
RUN curl -u admin:oracle -o myweb-1.0.0.war "http://192.168.1.101:8081/repository/demo-release/in/javahome/myweb/1.0.0/myweb-1.0.0.war" && \
    cp myweb-1.0.0.war /usr/local/tomcat/webapps/dockeransible.war
