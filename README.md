# Kuma Demo

#### Table of contents

- [Setup](#setup)
- [API](#api)
  - [Docker](#docker---products-endpoint)
  - [Redis](#redis---reviews-endpoint)
  - [Run](#run-the-api)
- [App](#app)
  - [Run](#run-the-app)
  - [Build](#build-the-app)
  - [Notes](#app-notes)

## Setup

This command will install the independencies for both the API and the app in their respective folders:

```sh
npm run setup
```

## API

### Docker - Products endpoint

This command will setup the Docker container for the Elasticsearch endpoint:

```sh
npm run api:docker
```

The products endpoint is located at: `http://localhost:3001/items`.

To query all of the items:

```sh
curl http://localhost:3001/items?q=
```

To query all items with a search value:

```sh
curl http://localhost:3001/items?q=shirt
```

### Redis - Reviews endpoint

This command will run the Redis endpoint for product reviews:

```sh
npm run api:redis
```

The reviews endpoint is located at: `http://localhost:3001/items/{id}/reviews/`

To query the reviews for a specific product, try replacing `{id}` with a random ID:

```sh
curl http://localhost:3001/items/6/reviews/
```

### Run the API

Finally, this command will start the API itself:

```sh
npm run api:start
```

## App

### Run the app

This command will run the Vue app:

```sh
npm run app:start
```

You should now be able to view the app by going to [http://localhost:8080/](http://localhost:8080/).

### Build the app

If you have to build the app for hosted use:

```sh
npm run app:build
```

This will output to a `dist` folder.

### App notes

The app is not yet prepared to be hosted but runs perfectly well locally. To get it working in a hosting environment (like Netlify), the build and run commands will need to be written based on [Netlify's documentation](https://www.netlify.com/docs/build-settings/).

1. The search runs queries as you type but will not run unnecessary queries when you are deleting characters in the search field. Try typing things like "hat", "shirt", "fedora", etc.
2. The reviews for each product make a separate Redis endpoint call when clicking the "Read Reviews" button on each product. The reviews will open in a modal window and that is when the API call is made to that product's ID.
3. If for some reason an endpoint fails, the app will display errors very clearly on the front end. For example, if the app fails to load the products on initial page load, you will see the error itself where the content would usually load. For reviews, you will see API errors appear within the modals themselves (which are triggered by clicking the "Read Reviews" buttons).
4. There is [an adapter](https://www.npmjs.com/package/axios-cache-adapter) in place that will cache Axios endpoint calls. This makes all calls after the initial ones much smaller.
5. There is currently no pagination but it's on the roadmap.
