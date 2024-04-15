FROM openjdk:8u242-jdk

EXPOSE 8080
COPY ./dockerweb /opt/dockerweb
WORKDIR /opt/dockerweb

#excute on build
RUN ./gradlew build

#excute on run
CMD java -jar /opt/dockerweb/build/libs/dockerweb-0.0.1-SNAPSHOT.jar