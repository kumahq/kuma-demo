import Vue from "vue";
import App from "./App.vue";
import VueMeta from "vue-meta";
import "normalize.css";

// Font Awesome
import { library } from "@fortawesome/fontawesome-svg-core";
// icons
import {
  faTag,
  faStar,
  faBoxOpen,
  faTshirt,
  faShoppingCart,
  faCircleNotch
} from "@fortawesome/free-solid-svg-icons";
// setup
import { FontAwesomeIcon } from "@fortawesome/vue-fontawesome";
library.add(faTag, faStar, faBoxOpen, faTshirt, faShoppingCart, faCircleNotch);
Vue.component("fa-icon", FontAwesomeIcon);

Vue.use(VueMeta);

Vue.config.productionTip = false;

new Vue({
  render: h => h(App)
}).$mount("#app");
