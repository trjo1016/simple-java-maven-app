# Use Maven base image
FROM maven:3.8.6-ibmjava-8 as build

# Copy source code
COPY . /app

# Build application
RUN mvn -f /app/pom.xml clean install

# Use Jenkins base image
FROM jenkins/jenkins:lts

USER root

# install wget and tools
RUN apt-get update && apt-get install -y wget && apt-get install -y software-properties-common

## INSTALL MAVEN ON JENKINS PROCESS

# get maven 3.8.6
RUN wget --no-verbose -O /tmp/apache-maven-3.8.6-bin.tar.gz https://repo.huaweicloud.com/apache/maven/maven-3/3.8.6/binaries/apache-maven-3.8.6-bin.tar.gz

# install maven
RUN tar xzf /tmp/apache-maven-3.8.6-bin.tar.gz -C /opt/
RUN ln -s /opt/apache-maven-3.8.6 /opt/maven
RUN ln -s /opt/maven/bin/mvn /usr/local/bin
RUN rm -f /tmp/apache-maven-3.8.6-bin.tar.gz
ENV MAVEN_HOME /opt/maven

RUN chown -R jenkins:jenkins /opt/maven

## SET JAVA 8 PROCESS
RUN apt-add-repository 'deb http://security.debian.org/debian-security stretch/updates main'
RUN apt-get update && apt-get install -y openjdk-8-jdk
RUN update-alternatives --set java /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64

# remove download archive files
RUN apt-get clean

USER jenkins

# Copy built application from the first stage
COPY --from=build /app/target /prometheus-jenkins

