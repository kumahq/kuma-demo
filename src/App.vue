<template>
  <div id="app">
    <search />
    <search-results :items="filterListBySearchQuery" />
    <global-footer />
  </div>
</template>

<script>
import { mapGetters } from "vuex";
import GlobalFooter from "./components/GlobalFooter.vue";
import Search from "./components/Search.vue";
import SearchResults from "./components/SearchResults.vue";

export default {
  name: "app",
  components: {
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
@import url("https://fonts.googleapis.com/css?family=Roboto&display=swap");

html {
  font-size: 62.5%;
}

body {
  font-family: "Roboto", "Avenir", Helvetica, Arial, sans-serif;
  font-size: 2.4rem;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

#app {
  width: 100%;
  max-width: 1040px;
  padding: 2rem;
  margin: 0 auto;
}
</style>
