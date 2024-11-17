FROM openjdk:17-jdk-alpine
WORKDIR /app
COPY target/Kong-Testing-Arulraj-0.0.1-SNAPSHOT app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
