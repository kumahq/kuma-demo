<template>
  <div class="product mb-8 pt-8 border-t border-gray-300">
    <header class="product__header flex flex-row -mx-4">
      <div class="w-1/5 px-4">
        <div class="product__image bg-white">
          <img
            :src="picture"
            :alt="`A picture of ${name}`"
            class="object-fill w-full rounded border-4 border-solid border-gray-300 shadow-lg"
          />
        </div>
        <div class="product__actions mt-4">
          <p class="text-center mt-4 font-bold text-3xl">{{ price }}</p>
          <p class="text-center mt-4">
            <a
              class="block bg-green hover:bg-green-lighter text-white text-center font-bold py-2 px-4 rounded"
              href="#"
            >
              <fa-icon :icon="['fas', 'shopping-cart']" class="mr-2" />Add to Cart
            </a>
          </p>
        </div>
      </div>
      <div class="w-4/5 px-4">
        <h2 class="product__title text-3xl font-bold mb-4">{{ name }}</h2>
        <h3 class="product__company text-xl text-pink font-bold italic mb-4">Made by {{ company }}</h3>
        <div class="product__detail text-lg leading-normal">
          <p>{{ detail }}</p>
        </div>
        <!-- .product__detail -->

        <div class="product__extras mt-4 p-4 bg-gray-200 rounded">
          <div class="flex items-center justify-between flex-row -mx-4">
            <div class="mx-4">
              <ul class="flex text-gray-600 flex-row -mx-4">
                <li class="mx-4">
                  <fa-icon :icon="['fas', 'tshirt']" class="mr-2" />
                  {{ size }}
                </li>
                <li class="mx-4">
                  <fa-icon :icon="['fas', 'tag']" class="mr-2" />
                  {{ category }}
                </li>
                <li class="mx-4">
                  <fa-icon :icon="['fas', 'box-open']" class="mr-2" />Only
                  <strong>{{ quantity }}</strong> Left!
                </li>
              </ul>
            </div>
            <div class="mx-4">
              <p>
                <button
                  type="button"
                  @click="showModal"
                  @keydown.prevent="closeOnEsc"
                  class="bg-green hover:bg-green-lighter text-white text-center font-bold py-2 px-4 rounded"
                >Read Reviews</button>
              </p>
            </div>
          </div>
        </div>
        <!-- .product__extras -->

        <modal v-show="isModalVisible" @close="closeModal">
          <template v-slot:header>
            <h2
              class="font-bold text-3xl text-center border-b border-gray-300 pb-4"
            >Reviews for {{ name }}</h2>
          </template>
          <template v-slot:body>
            <reviews :items="reviews" />
          </template>
        </modal>
        <!-- modal -->
      </div>
    </header>
  </div>
</template>

<script>
import axios from "axios";
import { setupCache } from "axios-cache-adapter";
import Reviews from "./Reviews.vue";
import Modal from "./Modal.vue";

// axios caching
const cache = setupCache({
  maxAge: 15 * 60 * 1000
});

const reviewsApi = axios.create({
  adapter: cache.adapter
});

export default {
  data() {
    return {
      isModalVisible: false,
      reviews: []
    };
  },
  props: {
    id: Number,
    index: Number,
    price: String,
    quantity: Number,
    picture: String,
    company: String,
    size: String,
    category: String,
    name: String,
    detail: String
  },
  components: {
    Reviews,
    Modal
  },
  methods: {
    showModal() {
      this.isModalVisible = true;
      this.fetchReviews(this.index);
      console.log(this.index);
    },
    closeModal() {
      this.isModalVisible = false;
    },
    closeOnEsc(ev) {
      if (this.isModalVisible && ev.keyCode === 27) {
        this.closeModal();
      }
    },
    fetchReviews(id) {
      reviewsApi({
        url: `http://localhost:3001/items/${id}/reviews/`,
        method: "GET"
      })
        .then(async response => {
          this.reviews = await response.data;
        })
        .catch(error => {
          console.log(error);
        });
    }
  }
};
</script>
