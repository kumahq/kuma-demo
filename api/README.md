# API

The backend API is built using [Node.js](https://nodejs.org/en/). It contains endpoints that enables the user to query the Elasticsearch and Redis databases.

## Local Installation

1. Install application dependencies:
   ```sh
   npm install
   ```

2. Run ElasticSearch on Docker:
   ```sh
   docker run -p 9200:9200 -p 9300:9300 -e "discovery.type=single-node" docker.elastic.co/elasticsearch/elasticsearch:7.3.2
   ```
   
3. Run Redis on Docker:
   ```sh
   docker run -d -p 6379:6379 --name redis1 redis
   ```

4. Start the Node application:
   ```sh
   npm start
   ```

5. Add mock data by making a `POST` request to the `/upload` endpoint
   ```sh
   curl -X POST http://localhost:3001/upload
   ```

## API Endpoints

* Upload mock data : `POST /upload/`
* Get all marketplace items : `GET /items/`
* Get marketplace item with item id : `GET /items/:id/`
* Get marketplace item with item id : `GET /items/:id/reviews/`
