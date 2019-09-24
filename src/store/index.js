import Vue from "vue";
import Vuex from "vuex";

import FakeData from "./tempFakeData.json";

Vue.use(Vuex);

export default new Vuex.Store({
  state: {
    searchQuery: "",
    // temp items for testing
    items: FakeData
  },
  getters: {
    filterListBySearchQuery: state => {
      const query = state.searchQuery.trim().toLowerCase();
      return state.items.filter(
        item => item.name.toLowerCase().indexOf(query) > -1
      );
    }
  },
  actions: {},
  mutations: {
    updateSearchQuery: (state, payload) => (state.searchQuery = payload)
  }
});
