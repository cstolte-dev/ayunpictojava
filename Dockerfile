# PictoChat (ayunpictojava) for Render
# Place this file in the top folder of your fork (next to build.gradle).

# --- Build stage: compile the server with Java 17 ---
FROM eclipse-temurin:17-jdk AS build
WORKDIR /src
COPY . .
RUN chmod +x gradlew && ./gradlew build --no-daemon -q
# Listen on all interfaces, on Render's default port (10000)
RUN sed -e 's#"port": 8080#"port": 10000#' \
        -e 's#"host": "127.0.0.1"#"host": "0.0.0.0"#' \
        src/main/resources/settings.json > /src/settings.json

# --- Run stage: small image with just Java and the server ---
FROM eclipse-temurin:17-jre
WORKDIR /app
COPY --from=build /src/build/libs/*.jar /app/pictochat.jar
COPY --from=build /src/settings.json /app/settings.json
EXPOSE 10000
# Tripcode secret comes from the PICTOJAVA_TRIPCODE_SECRET environment variable set in Render
CMD ["java", "-Xmx300m", "-jar", "/app/pictochat.jar"]
