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
      <div class="errors">

        <!-- product API errors and logs -->
        <error v-if="productInitApiLog1 || productInitApiLog2">
          <template v-slot:header>
            <p>There are Product API issues:</p>
          </template>
          <template v-slot:body>
            <code v-if="productInitApiLog1">
              <pre>{{ productInitApiLog1 }}</pre>
            </code>
            <code v-if="productInitApiLog2">
              <pre>{{ productInitApiLog2 }}</pre>
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
              <pre class="overflow-x-auto pt-4 pb-4">{{ searchApiError }}</pre>
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
              <pre class="overflow-x-auto pt-4 pb-4">{{ assetUploadError }}</pre>
            </code>
          </template>
        </error>
      </div>
      <div v-if="dataIsLoaded">
        <!-- results information -->
        <div v-if="items && items.length > 0" class="results-info mb-4 mt-4 text-gray-600">
          <p>
            Viewing {{ items.length }} results
            <span v-if="searchQuery">
              for
              <strong class="bg-gray-200 rounded px-2 py-1">{{ searchQuery }}</strong>
            </span>
          </p>
        </div>
        <!-- search results and initial products array -->
        <search-results :items="paginatedData" :query="searchQuery" />
        <!-- pagination controls -->
        <div
          class="border-t border-gray-300 pagination-controls flex items-center justify-between -mx-4 mb-8 pt-8"
        >
          <div class="mx-4">
            <button
              type="button"
              class="inline-block md:block bg-green hover:bg-green-lighter text-white text-center font-bold py-2 px-4 rounded"
              @click="prevPage"
              :disabled="pageNumber === 0"
              :class="{ 'opacity-50 cursor-not-allowed': pageNumber === 0 }"
            >&larr; Previous</button>
          </div>
          <div class="mx-4 text-gray-600">
            <p>Page {{ pageNumber + 1 }} of {{ realPageCount }} pages</p>
          </div>
          <div class="mx-4">
            <button
              type="button"
              class="inline-block md:block bg-green hover:bg-green-lighter text-white text-center font-bold py-2 px-4 rounded"
              @click="nextPage"
              :disabled="pageNumber >= realPageCount -1"
              :class="{ 'opacity-50 cursor-not-allowed': pageNumber >= realPageCount -1 }"
            >Next &rarr;</button>
          </div>
        </div>
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
import GlobalHeader from "./components/GlobalHeader.vue";
import GlobalFooter from "./components/GlobalFooter.vue";
import Search from "./components/Search.vue";
import SearchResults from "./components/SearchResults.vue";
import Error from "./components/Error.vue";

// the API endpoint
const api = process.env.VUE_APP_POSTGRES_ENDPOINT;

// API search query param
const apiParam = "?q";

// setup the product API PostgreSQL call
const productsApi = axios.create({
  // adapter: cache.adapter
});

// setup the asset upload endpoint
const assetUploadApi = axios.create({
  // adapter: cache.adapter
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
      productInitApiLog1: null,
      productInitApiLog2: null,
      searchApiError: "",
      assetUploadError: "",
      uploadHasAlreadyRun: false,
      pageNumber: 0, // starting page
      pageSize: 10, // items per page
      realPageCount: ""
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
  computed: {
    paginatedData() {
      const items = this.items

      if (items && items.length > 0) {
        const start = this.pageNumber * this.pageSize;
        const end = start + this.pageSize;

        return items.slice(start, end);
      } else {
        console.error('No items to paginate!')
      }
    }
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

          // calculate the page count on initial product load
          this.calculatePageCount();

          // quick and dirty error handling
          if (response.message) {
            this.productInitApiLog1 = response.message;
          } else {
            this.productInitApiLog1 = null;
          }

          if (response.data.msg) {
            this.productInitApiLog2 = response.data.msg;
          } else {
            this.productInitApiLog2 = null
          }
        })
        .catch(error => {
          this.productInitApiLog1 = error;
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
            this.searchQuery = "";
          }

          // if we're performing a search, we have to return to the first page
          this.pageNumber = 0;

          // figure out the actual page count based on the number of items
          this.calculatePageCount();
        })
        .catch(error => {
          this.searchApiError = error;
          console.error("Search API Error:", error);
        });
    },
    calculatePageCount() {
      let l = this.items.length;
      let s = this.pageSize;
      let value = Math.ceil(l / s);
      this.realPageCount = value < this.pageSize ? value : this.pageSize;
    },
    nextPage() {
      this.pageNumber++;
    },
    prevPage() {
      this.pageNumber--;
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

.header-wrap {
  z-index: 998; // 1 below the modal
}
</style>
