# docker build . -t kvn0218/postgres:latest
# docker push kvn0218/postgres:latest

# docker run --name kuma-postgres \
# -p 5432:5432 \       
# -e POSTGRES_USER=kumademo \
# -e POSTGRES_PASSWORD=kumademo \
# -e POSTGRES_DB=kumademo \
# kvn0218/postgres:latest

FROM postgres:alpine

RUN mkdir -p /tmp/psql_data/

RUN echo "host all  all    0.0.0.0/0  md5" >> /var/lib/postgresql/data/pg_hba.conf

# Expose the PostgreSQL port
EXPOSE 5432

COPY ./database.sql /tmp/psql_data/
COPY ./init_docker_postgres.sh /docker-entrypoint-initdb.d/
