# Build stage: Maven + Temurin 26 JDK
FROM eclipse-temurin:26-jdk-noble AS build

WORKDIR /workspace

COPY .mvn .mvn
COPY mvnw pom.xml ./
RUN chmod +x mvnw && ./mvnw -B -DskipTests dependency:go-offline

COPY src ./src
RUN ./mvnw -B -DskipTests package

FROM eclipse-temurin:26-jre-noble

WORKDIR /app

COPY --from=build /workspace/target/*.jar app.jar

ENV SPRING_PROFILES_ACTIVE=dev
ENV PORT=8096
ENV JAVA_OPTS=""

EXPOSE 8096

ENTRYPOINT ["sh","-c","java $JAVA_OPTS -Dspring.profiles.active=${SPRING_PROFILES_ACTIVE} -Dserver.port=${PORT} -jar /app/app.jar"]
