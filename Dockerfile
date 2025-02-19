FROM tomcat:8

#COPY target/*.war /usr/local/tomcat/webapps/dockeransible.war
ARG ver

RUN echo ${ver} && \
    curl -u admin:oracle -o myweb-${ver}.war "http://172.23.150.201:8081/repository/demo-release/in/javahome/myweb/${ver}/myweb-${ver}.war" && \
    cp myweb-${ver}.war /usr/local/tomcat/webapps/dockeransible.war
