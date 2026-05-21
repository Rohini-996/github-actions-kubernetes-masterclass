# =========================
# MySQL SkillPulse Database
# =========================
FROM mysql:8.4

# Environment variables
ENV MYSQL_ROOT_PASSWORD=rootpassword123
ENV DB_NAME=skillpulse
ENV DB_USER=skillpulse
ENV DB_PASSWORD=skillpulse123
ENV DOCKERHUB_USERNAME=rohinidivekar123

# Copy SQL schema + seed data
COPY init.sql /docker-entrypoint-initdb.d/

EXPOSE 3306
