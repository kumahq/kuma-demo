# Developer documentation

## API

### Endpoints

First and foremost, make sure to run all commands to get each endpoint setup. Please refer to the [README](README.md) to see those commands.

#### PostgreSQL - Products endpoint

The products endpoint is located at: `http://localhost:3001/items`. This will not return any product data unless `?q=` is appended to it (see below).

To query all of the items:

```sh
curl http://localhost:3001/items?q=
```

To query all items based on a search value:

```sh
curl http://localhost:3001/items?q=shirt
```

#### Redis - Reviews endpoint

The reviews endpoint is located at: `http://localhost:3001/items/{id}/reviews/`

To query the reviews for a specific product, try replacing `{id}` with a random ID:

```sh
curl http://localhost:3001/items/6/reviews/
```

## App

### Structure

#### Components (located in `/src/components/`)

- `Error.vue` - A generic component for displaying errors
- `GlobalFooter.vue` - The global app footer
- `GlobalHeader.vue` - The global app header (it contains the logo and the search bar)
- `Modal.vue` - A generic component for displaying modals
- `Product.vue` - Displays all of the product details. It's the first component seen when loading the app, and has the most importance in `SearchResults.vue`
- `Reviews.vue` - This component displays a product's reviews. It's used within a modal in `Product.vue`
- `Search.vue` - The main search bar referenced in `GlobalHeader.vue`. It triggers the PostgreSQL endpoint queries as the user types, but will ignore the BACKSPACE and DEL keys as to prevent needless repeat queries. Using the search will emit an action to `App.vue`, which will trigger the PostgreSQL queries based on what the user searches for
- `SearchResults.vue` - This is what is immediately displayed on app load. It will consume the PostgreSQL endpoint and display its data. It is housed within `/src/App.vue`, which is where the PostgreSQL products data is called

#### App.vue

This is where all of the magic happens. The PostgreSQL endpoint is called on page load and displays all of the products. As the user searches, the search method is called and queries the PostgreSQL endpoint for the query the user enters.
