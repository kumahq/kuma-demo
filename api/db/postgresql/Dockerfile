# docker build . -t kvn0218/postgres:latest
# docker push kvn0218/postgres:latest

FROM postgres:10-alpine

RUN mkdir -p /tmp/psql_data/

# commented out the following line on 2/12/2024 because it was source of
# clunky builds between the docker legacy builder and docker's new buildkit
# RUN echo "host all  all    0.0.0.0/0  md5" >> /var/lib/postgresql/data/pg_hba.conf

# Expose the PostgreSQL port
EXPOSE 5432

COPY ./database.sql /tmp/psql_data/
COPY ./init_docker_postgres.sh /docker-entrypoint-initdb.d/
