FROM tomcat:8

#COPY target/*.war /usr/local/tomcat/webapps/dockeransible.war
ARG version
ENV ver=$version

RUN curl -u admin:oracle -o myweb-$ver.war "http://192.168.1.101:8081/repository/demo-release/in/javahome/myweb/$ver/myweb-$ver.war" && \
    cp myweb-$ver.war /usr/local/tomcat/webapps/dockeransible.war
