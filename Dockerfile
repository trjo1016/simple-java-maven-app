# Use Jenkins base image
FROM jenkins/jenkins:lts

USER root

ARG MAVEN_VER=3.8.6
# install wget and tools
RUN apt-get update && apt-get install -y wget && apt-get install -y software-properties-common

## INSTALL MAVEN ON JENKINS PROCESS

# get maven ${MAVEN_VER}
RUN wget --no-verbose -O /tmp/apache-maven-${MAVEN_VER}-bin.tar.gz https://repo.huaweicloud.com/apache/maven/maven-3/${MAVEN_VER}/binaries/apache-maven-${MAVEN_VER}-bin.tar.gz

# install maven
RUN tar xzf /tmp/apache-maven-${MAVEN_VER}-bin.tar.gz -C /opt/
RUN ln -s /opt/apache-maven-${MAVEN_VER} /opt/maven
RUN ln -s /opt/maven/bin/mvn /usr/local/bin
RUN rm -f /tmp/apache-maven-${MAVEN_VER}-bin.tar.gz

RUN chown -R jenkins:jenkins /opt/maven

## SET JAVA 8
RUN apt-add-repository 'deb http://security.debian.org/debian-security stretch/updates main'
RUN apt-get update && apt-get install -y openjdk-8-jdk
RUN update-alternatives --set java /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java

# remove download archive files
RUN apt-get clean

user jenkins