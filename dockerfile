# ---- Build stage ----
FROM maven:3.9.6-eclipse-temurin-11 AS build
WORKDIR /app

# Copier seulement les fichiers nécessaires pour tirer parti du cache Maven
COPY backend/pom.xml ./pom.xml
COPY backend/.mvn ./.mvn
COPY backend/mvnw ./mvnw
COPY backend/mvnw.cmd ./mvnw.cmd

# Télécharger les dépendances (cache)
RUN mvn -B -q -DskipTests dependency:go-offline

# Copier le code et builder
COPY backend/src ./src
RUN mvn -B -DskipTests clean package

# ---- Run stage ----
FROM eclipse-temurin:11-jre
WORKDIR /app

# Copie le jar généré
COPY --from=build /app/target/*.jar app.jar

EXPOSE 8080
ENTRYPOINT ["java","-jar","app.jar"]
