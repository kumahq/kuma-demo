FROM elasticsearch:7.6.1

COPY data /data

COPY data /elasticsearch/data

COPY data /usr/share/elasticsearch/data

VOLUME ["/data"]

COPY data/nodes/0 /data/nodes/0

RUN ls -la /data/nodes/0

RUN sudo chown -R 1000:1000 /usr/share/elasticsearch/data
