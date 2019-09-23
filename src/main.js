import Vue from "vue";
import App from "./App.vue";
import Vuex from "vuex";
import Store from "./store";
import "normalize.css";

Vue.use(Vuex);

Vue.config.productionTip = false;

new Vue({
  Store,
  render: h => h(App)
}).$mount("#app");
