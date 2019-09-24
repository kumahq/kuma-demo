<template>
  <div id="app" class="container mx-auto min-h-screen antialiased leading-tight">
    <global-header />
    <search />
    <search-results :items="filterListBySearchQuery" />
    <global-footer />
  </div>
</template>

<script>
import { mapGetters } from "vuex";
import GlobalHeader from "./components/GlobalHeader.vue";
import GlobalFooter from "./components/GlobalFooter.vue";
import Search from "./components/Search.vue";
import SearchResults from "./components/SearchResults.vue";

export default {
  name: "app",
  components: {
    GlobalHeader,
    GlobalFooter,
    Search,
    SearchResults
  },
  computed: {
    ...mapGetters(["filterListBySearchQuery"])
  }
};
</script>

<style lang="scss">
@import url("https://fonts.googleapis.com/css?family=Roboto:400,400i,700,700i&display=swap");

// Tailwind
@tailwind base;
@tailwind components;
@tailwind utilities;

// App
html {
  // font-size: 62.5%;
}

body {
  // font-family: "Roboto", "Avenir", Helvetica, Arial, sans-serif;
}

#app {
}

h1 {
  @apply text-2xl;
}

h2 {
  @apply text-xl;
}

h3 {
  @apply text-lg;
}
</style>
