FROM gradle:7-jdk11 AS build
WORKDIR /usr/app
COPY . /usr/app
RUN gradle buildFatJar --no-daemon

FROM openjdk:11
EXPOSE 8080:8080
WORKDIR /etc/usr/app
COPY --from=build /usr/app/build/libs/*.jar hamba-dispatcher.jar
CMD ["java", "-jar", "hamba-dispatcher.jar"]