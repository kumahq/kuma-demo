<template>
  <div id="app" class="antialiased leading-tight">
    <div class="header-wrap fixed w-screen pt-2 pb-4 pl-8 pr-8 bg-white shadow-xl">
      <div class="flex items-center justify-between -mx-4">
        <div class="w-1/6 mx-4">
          <global-header />
        </div>
        <div class="w-5/6 mx-4">
          <search @input="submitSearch" />
        </div>
      </div>
    </div>
    <div class="content-wrapper container mx-auto">
      <search-results :items="items" />
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
      items: []
    };
  },
  components: {
    GlobalHeader,
    GlobalFooter,
    Search,
    SearchResults
  },
  methods: {
    submitSearch(ev) {
      const query = ev.target.value.trim().toLowerCase();
      axios
        .get(`http://localhost:3001/search?item=${query}`)
        .then(response => {
          this.items = response.data;
        })
        .catch(error => {
          console.log(error);
        });
    }
  }
};
</script>

<style lang="scss">
@import url("https://fonts.googleapis.com/css?family=Roboto:400,400i,700,700i&display=swap");

// Tailwind
@tailwind base;
@tailwind components;
@tailwind utilities;

body {
  font-family: "Roboto", "Avenir", Helvetica, Arial, sans-serif;
}

.content-wrapper {
  padding-top: 8rem;
}
</style>
