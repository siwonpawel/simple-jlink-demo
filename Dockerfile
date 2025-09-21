# Build application
FROM docker.io/gradle:8.14-jdk21-alpine AS gradle-build
WORKDIR /opt/app
COPY settings.gradle.kts ./
COPY build.gradle.kts ./
COPY src ./src

RUN --mount=type=cache,target=/root/.m2 gradle build

# Build custom JRE
FROM docker.io/eclipse-temurin:21-alpine AS jre-build
WORKDIR /opt/app
COPY --from=gradle-build /opt/app/build/libs/jlink-simple-demo-1.0-SNAPSHOT.jar ./app.jar

RUN jar xf app.jar

RUN jdeps --ignore-missing-deps -q  \
    --recursive  \
    --multi-release 21  \
    --print-module-deps  \
    --class-path 'BOOT-INF/lib/*'  \
    app.jar > deps.info

RUN jlink \
    --verbose \
    --add-modules $(cat deps.info) \
    --strip-debug \
    --compress=2 \
    --no-header-files \
    --no-man-pages \
    --output /customjre

# Build docker image
FROM docker.io/alpine:3.18
COPY --from=jre-build /customjre /opt/jre
ENV JAVA_HOME=/opt/jre
ENV PATH="$PATH:$JAVA_HOME/bin"

COPY --from=gradle-build /opt/app/build/libs/jlink-simple-demo-1.0-SNAPSHOT.jar /opt/app.jar
ENTRYPOINT ["java", "--module-path", "/opt/app.jar", "--module", "jlink.simple.demo.main/com.github.siwonpawel.Main"]