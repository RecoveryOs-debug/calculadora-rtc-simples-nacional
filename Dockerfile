# Build: gera o banco SQLite via Flyway e empacota o jar (precisa de JDK 21 —
# o projeto não compila com versões mais novas por causa do Lombok).
#
# A pasta flyway/ deste repositório foi copiada de calculadora-rtc-regime-regular:
# os dois serviços usam o mesmo banco oficial (schema único, com as tabelas de
# Simples Nacional já incluídas) — o README original pede pra copiar essa pasta
# "do próprio repositório", o que não faz sentido; o schema correto vem de lá.
FROM eclipse-temurin:21-jdk AS builder

WORKDIR /app
COPY . .

RUN mkdir -p ./calculadora/db \
  && ./mvnw flyway:migrate -Dflyway.configFiles=./flyway/flyway-pro.conf --batch-mode --errors \
  && ./mvnw clean package -DskipTests --batch-mode

# Runtime: JRE só, com o jar e o banco já gerado.
FROM eclipse-temurin:21-jre

WORKDIR /app
COPY --from=builder /app/target/api-simples-nacional.jar app.jar
COPY --from=builder /app/calculadora ./calculadora

EXPOSE 8082
ENV SPRING_PROFILES_ACTIVE=offline

ENTRYPOINT ["java", "-Dspring.profiles.active=offline", "-jar", "app.jar"]
