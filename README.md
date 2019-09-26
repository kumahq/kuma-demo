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
7. Make a request to the Node /items endpoint that queries ES for the market item
   ```sh
   curl -i http://localhost:3001/items?q=boot
    ```
    The response would be an array of item objects:
    ```
    [
        {
            "_index":"market-items",
            "_type":"clothing_list",
            "_id":"a5REbm0BbA87YP8VtVin",
            "_score":3.189999,
            "_source":{
                "index":6,
                "price":"$448.00",
                "quantity":6,
                "picture":"https://i.imgur.com/koDDUEC.png",
                "company":"Endicil",
                "size":"XXXXL",
                "category":"Boot with Fur",
                "name":"Endicil Boot with Fur - Size XXXXL",
                "productDetail":"Ullamco qui quis sunt officia ..."
                }
            },
            ...
    ]
    ```

8. Make a request to the Node /items/${item_index_id}/reviews endpoint
   ```sh
   curl -i http://localhost:3001/items/6/reviews
   ```
   The response would be an array of item reviews stored in Redis:
   ```
   [
       {
           "id":0,
           "name":"Cooley Gamble",
           "review":"Exercitation mollit aute sit et veniam...",
           "rating":3
        },
        {
            "id":1,
            "name":"Castaneda Thompson",
            "review":"Ullamco cillum pariatur veniam...",
            "rating":4
        },
        ...
    ]
   ```
