FROM eclipse-temurin:21-jdk AS builder

WORKDIR /workspace

ENV GRADLE_OPTS="-Djava.net.preferIPv4Stack=true"

COPY gradlew settings.gradle.kts build.gradle.kts versions.properties ./
COPY gradle ./gradle

RUN chmod +x gradlew && ./gradlew --version --no-daemon

COPY src ./src

RUN ./gradlew bootJar --no-daemon -x test

RUN mkdir -p build/extracted \
    && cp build/libs/*-SNAPSHOT.jar build/extracted/app.jar \
    && cd build/extracted \
    && java -Djarmode=layertools -jar app.jar extract \
    && rm app.jar

FROM eclipse-temurin:21-jre-alpine AS runtime

RUN addgroup -S spring && adduser -S spring -G spring

WORKDIR /app

COPY --from=builder --chown=spring:spring /workspace/build/extracted/dependencies/ ./
COPY --from=builder --chown=spring:spring /workspace/build/extracted/spring-boot-loader/ ./
COPY --from=builder --chown=spring:spring /workspace/build/extracted/snapshot-dependencies/ ./
COPY --from=builder --chown=spring:spring /workspace/build/extracted/application/ ./

USER spring:spring

ENV SPRING_PROFILES_ACTIVE=prod \
    JAVA_OPTS="-XX:MaxRAMPercentage=75 -XX:+UseContainerSupport"

EXPOSE 8080 9090

ENTRYPOINT ["sh", "-c", "exec java $JAVA_OPTS org.springframework.boot.loader.launch.JarLauncher \"$@\"", "--"]
