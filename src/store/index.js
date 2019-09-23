import Vue from "vue";
import Vuex from "vuex";

Vue.use(Vuex);

export default new Vuex.Store({
  state: {
    searchQuery: "",
    // temp items for testing
    items: [
      {
        title: "Item 1 Pizza",
        content: "Lorem Ipsum Pizza"
      },
      {
        title: "Item 2 Tacos",
        content: "Lorem Ipsum Tacos"
      },
      {
        title: "Item 3 Sushi",
        content: "Lorem Ipsum Sushi"
      },
      {
        title: "Item 4 Sandwiches",
        content: "Lorem Ipsum Sandwiches"
      },
      {
        title: "Item 5 Steak",
        content: "Lorem Ipsum Steak"
      },
      {
        title: "Item 6 Potatoes",
        content: "Lorem Ipsum Potatoes"
      }
    ]
  },
  getters: {
    filterListBySearchQuery: state => {
      const query = state.searchQuery.trim().toLowerCase();
      return state.items.filter(
        item => item.title.toLowerCase().indexOf(query) > -1
      );
    }
  },
  actions: {},
  mutations: {
    updateSearchQuery: (state, payload) => (state.searchQuery = payload)
  }
});
