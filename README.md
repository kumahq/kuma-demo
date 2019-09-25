# kuma-market


### Steps to test on local machine with Docker:

1. Clone the repository:
   ```sh
   git clone https://github.com/devadvocado/kuma-market
   ```
2. Navigate into the Node directory:
   ```sh
   cd /kuma-market/src/searchpage
   ```
3. Install dependencies:
   ```sh
   npm install
   ```
4. Run ElasticSearch on Docker:
   ```sh
   docker run -p 9200:9200 -p 9300:9300 -e "discovery.type=single-node" docker.elastic.co/elasticsearch/elasticsearch:7.3.2
   ```
5. Run Redis on Docker:
   ```sh
   docker run -d -p 6379:6379 --name redis1 redis
   ```
6. Start Node application:
   ```sh
   npm start
   ```
7. Make a request to the Node /search endpoint that queries ES for the market item and then gets the item reviews from Redis
   ```sh
   curl -i http://localhost:3001/search?item=jean
   ```