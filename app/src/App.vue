<template>
  <div id="app" class="antialiased leading-tight">
    <div class="header-wrap fixed w-screen pt-2 pb-4 pl-8 pr-8 bg-white shadow-xl">
      <div class="sm:flex items-center justify-between -mx-4">
        <div class="w-full sm:w-2/6 md:w-1/6 sm:mx-4">
          <global-header />
        </div>
        <div class="w-full sm:w-4/6 md:w-5/6 sm:mx-4">
          <search @input="submitSearch" />
        </div>
      </div>
    </div>
    <div class="content-wrapper container mx-auto max-w-6xl">
      <div class="errors" v-if="productInitApiError || searchApiError || assetUploadError">
        <!-- initial product API errors -->
        <error v-if="productInitApiError">
          <template v-slot:header>
            <p>There was a Product API error:</p>
          </template>
          <template v-slot:body>
            <code>
              <pre>{{ productInitApiError }}</pre>
            </code>
          </template>
        </error>

        <!-- Search query API errors -->
        <error v-if="searchApiError">
          <template v-slot:header>
            <p>There was a Search API error:</p>
          </template>
          <template v-slot:body>
            <code>
              <pre>{{ searchApiError }}</pre>
            </code>
          </template>
        </error>

        <!-- Asset upload API errors -->
        <error v-if="assetUploadError">
          <template v-slot:header>
            <p>There was an Asset Upload API error:</p>
          </template>
          <template v-slot:body>
            <code>
              <pre>{{ assetUploadError }}</pre>
            </code>
          </template>
        </error>
      </div>
      <div v-if="dataIsLoaded">
        <search-results :items="items" :query="searchQuery" />
      </div>
      <div v-else class="loading-screen h-screen flex items-center justify-center text-pink">
        <fa-icon :icon="['fas', 'circle-notch']" size="5x" spin />
      </div>
      <global-footer />
    </div>
  </div>
</template>

<script>
import axios from "axios";
import { setupCache } from "axios-cache-adapter";
import GlobalHeader from "./components/GlobalHeader.vue";
import GlobalFooter from "./components/GlobalFooter.vue";
import Search from "./components/Search.vue";
import SearchResults from "./components/SearchResults.vue";
import Error from "./components/Error.vue";

// the API endpoint
const api = "http://localhost:3001";

// API search query param
const apiParam = "?q";

// setup axios caching
const cache = setupCache({
  maxAge: 15 * 60 * 1000
});

// setup the product API Elasticsearch call
const productsApi = axios.create({
  adapter: cache.adapter
});

// setup the asset upload endpoint
const assetUploadApi = axios.create({
  adapter: cache.adapter
});

export default {
  name: "app",
  metaInfo: {
    title: "Home",
    titleTemplate: "%s | Kuma Marketplace",
    htmlAttrs: {
      lang: "en"
    }
  },
  data() {
    return {
      items: [],
      dataIsLoaded: false,
      searchQuery: "",
      productInitApiError: "",
      searchApiError: "",
      assetUploadError: ""
    };
  },
  components: {
    GlobalHeader,
    GlobalFooter,
    Search,
    SearchResults,
    Error
  },
  created() {
    // load all products initially
    this.loadAllProducts();
  },
  methods: {
    loadAllProducts() {
      productsApi({
        url: `${api}/items${apiParam}`,
        method: "GET"
      })
        .then(async response => {
          // populate the items array
          this.items = await response.data;
          this.dataIsLoaded = true;
          // upload assets to the endpoints
          this.uploadAssets();
        })
        .catch(error => {
          this.productInitApiError = error;
          console.error("Product API Error:", error);
        });
    },
    submitSearch(ev) {
      const query = ev.target.value.trim().toLowerCase();
      productsApi({
        url: `${api}/items${apiParam}=${query}`,
        method: "GET"
      })
        .then(async response => {
          if (query) {
            // only load the query results
            this.items = await response.data;
            this.searchQuery = await query;
          } else {
            // otherwise load all products
            await this.loadAllProducts();
          }
        })
        .catch(error => {
          this.searchApiError = error;
          console.error("Search API Error:", error);
        });
    },
    uploadAssets() {
      assetUploadApi({
        url: `${api}/upload`,
        method: "POST"
      })
        .then(async response => {
          await console.log(response.data);
        })
        .catch(error => {
          this.assetUploadError = error;
          console.error("Asset Upload API Error:", error);
        });
    }
  }
};
</script>

<style lang="scss">
@import url("https://fonts.googleapis.com/css?family=Roboto:400,400i,700,700i&display=swap");

$topbar-height: 8rem;

// Tailwind
@tailwind base;
@tailwind components;
@tailwind utilities;

body {
  font-family: "Roboto", "Avenir", Helvetica, Arial, sans-serif;
}

.content-wrapper {
  padding-top: $topbar-height;
}

.loading-screen {
  margin-top: -#{$topbar-height};
}
</style>
