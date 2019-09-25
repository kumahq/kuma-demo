<template>
  <div id="app" class="antialiased leading-tight">
    <div class="header-wrap fixed w-screen pt-2 pb-4 pl-8 pr-8 bg-white shadow-xl">
      <div class="flex items-center justify-between -mx-4">
        <div class="w-1/6 mx-4">
          <global-header />
        </div>
        <div class="w-5/6 mx-4">
          <search />
        </div>
      </div>
    </div>
    <div class="content-wrapper container mx-auto">
      <search-results :items="filterListBySearchQuery" />
      <global-footer />
    </div>
  </div>
</template>

<script>
import debounce from "vue-debounce/src/debounce";
import { mapGetters } from "vuex";
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

body {
  font-family: "Roboto", "Avenir", Helvetica, Arial, sans-serif;
}

.content-wrapper {
  padding-top: 8rem;
}
</style>
