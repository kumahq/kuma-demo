# Marketplace Frontend

This is a simple Vue.js demo application to show the capabilities of [Kuma](https://kuma.io/).

## Project setup

```
yarn install
```

### Compiles and hot-reloads for development

```
yarn run serve
```

### Compiles and minifies for production

```
yarn run build
```

### Run your tests

```
yarn run test
```

### Lints and fixes files

```
yarn run lint
```

### Run your unit tests

```
yarn run test:unit
```

### Customize configuration

See [Configuration Reference](https://cli.vuejs.org/config/).

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
6. The endpoints for reviews and products are hard-coded into the app. Therefore if you try to view the app via an IP address like `192.168.0.5:8080` (e.g. on a mobile device), you will receive a network error since the API calls go to `localhost`.
