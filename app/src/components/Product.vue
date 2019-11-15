<template>
  <div
    class="product mb-8 pt-8 border-t border-gray-300 md:flex flex-row -mx-4"
    :class="{ 'special-offer': specialOffer }"
  >
    <div
      v-if="specialOffer"
      class="ribbon"
    >
      <span>Sale!</span>
    </div>

    <div class="md:w-1/5 px-4">
      <h2 class="product__title text-2xl text-center font-bold mb-4 md:hidden">{{ name }}</h2>
      <div class="product__image bg-white">
        <img
          :src="picture"
          :alt="`A picture of ${name}`"
          class="max-w-xs md:max-w-full rounded border-4 border-solid border-gray-300 shadow-lg mx-auto"
        />
      </div>
      <div class="product__actions mt-4">

        <p v-if="specialOffer" class="text-center mt-4 font-bold">
          <span class="text-gray-500 line-through text-xl">{{ cleanPrice }}</span><br>
          <span class="text-pink text-3xl">{{ discountedPrice }}</span>
        </p>
        <p v-else class="text-center mt-4 font-bold text-3xl">
          {{ cleanPrice }}
        </p>

        <p class="text-center mt-4">
          <a
            class="inline-block md:block bg-green hover:bg-green-lighter text-white text-center font-bold py-2 px-4 rounded"
            href="#"
          >
            <fa-icon :icon="['fas', 'shopping-cart']" class="mr-2" />Add to Cart
          </a>
        </p>
      </div>
    </div>
    <div class="md:w-4/5 px-4">
      <h2 class="product__title text-3xl font-bold mb-4 hidden md:block">
        {{ name }}
      </h2>
      <h3
        class="product__company text-xl text-pink font-bold italic mb-4 mt-4 md:mt-0 text-center md:text-left"
      >Made by {{ company }}</h3>
      <div class="product__detail text-lg leading-normal">
        <p>{{ detail }}</p>
      </div>
      <!-- .product__detail -->

      <div class="product__extras mt-4 p-4 bg-gray-200 rounded">
        <div class="md:flex items-center justify-between flex-row -mx-4">
          <div class="mx-4">
            <ul class="sm:flex text-gray-600 flex-row -mx-4">
              <li class="mx-4">
                <fa-icon :icon="['fas', 'tshirt']" class="mr-2" />
                <span>{{ size }}</span>
              </li>
              <li class="mx-4 mt-4 sm:mt-0">
                <fa-icon :icon="['fas', 'tag']" class="mr-2" />
                <span>{{ category }}</span>
              </li>
              <li class="mx-4 mt-4 sm:mt-0">
                <fa-icon :icon="['fas', 'box-open']" class="mr-2" />Only
                <strong>{{ quantity }}</strong> Left!
              </li>
            </ul>
          </div>
          <div class="mx-4 mt-4 md:mt-0">
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
          <error v-if="modalApiError">
            <template v-slot:header>
              <p>There was a Review Redis API error:</p>
            </template>
            <template v-slot:body>
              <code>
                <pre>{{ modalApiError }}</pre>
              </code>
            </template>
          </error>
          <div v-if="isModalDataLoaded">
            <reviews :items="reviews" />
          </div>
          <div v-else class="loading-reviews flex items-center justify-center text-pink mt-8 mb-8">
            <fa-icon :icon="['fas', 'circle-notch']" size="3x" spin />
          </div>
        </template>
      </modal>
      <!-- modal -->
    </div>
  </div>
</template>

<script>
import axios from "axios";
import Reviews from "./Reviews.vue";
import Modal from "./Modal.vue";
import Error from "./Error.vue";

const reviewsApi = axios.create({
  // adapter: cache.adapter
});

export default {
  data() {
    return {
      reviews: Array,
      isModalVisible: false,
      modalApiError: null,
      isModalDataLoaded: false
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
    detail: String,
    specialOffer: Boolean
  },
  components: {
    Reviews,
    Modal,
    Error
  },
  computed: {
    cleanPrice () {
      const price = parseInt(this.price.replace('$','')).toFixed(2);

      return `$${price}`
    },
    discountedPrice () {
      const basePrice = this.cleanPrice.replace('$','');
      const discount = 50 / 100;
      const adjusted = (basePrice - (basePrice * discount))

      return `$${adjusted.toFixed(2)}`
    }
  },
  methods: {
    showModal() {
      this.isModalVisible = true;
      this.fetchReviews(this.index);
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
        url: `${process.env.VUE_APP_REDIS_ENDPOINT}/items/${id}/reviews/`,
        method: "GET"
      })
        .then(async response => {
          // error checking and logging
          const errorCheck = response.data.code;
          
          if (errorCheck && errorCheck.length) {
            this.modalApiError = errorCheck;
          } else {
            this.reviews = await response.data;
            this.modalApiError = null;
          }

          // trigger the modal
          this.isModalDataLoaded = await true;
        })
        .catch(error => {
          this.modalApiError = error;
          console.error("Reviews Redis API Error:", error);
        });
    }
  }
};
</script>

<style lang="scss">
.special-offer {
  position: relative;
  overflow: hidden;
  background: #fff;
  border: 4px solid #FF5D8C !important;
  padding: 40px;
  border-radius: 5px;
  box-shadow: 0 0 20px rgba(0,0,0,0.35);
}

.ribbon {
  $dims: 85px;

  position: absolute;
  right: 0;
  top: 0;
  z-index: 1;
  width: $dims;
  height: $dims; 
  text-align: right;

  span {
    text-transform: uppercase; 
    text-align: center;
    color: #fff;
    font-size: 30px;
    font-weight: bold;
    line-height: 42px;
    transform: rotate(45deg);
    width: 200px;
    display: block;
    background: #FF5D8C;
    background: linear-gradient(#FF5D8C 0%, darken(#FF5D8C, 15%) 100%);
    box-shadow: 0 3px 10px -5px rgba(0, 0, 0, 1);
    position: absolute;
    top: 34px;
    right: -44px;
  }
}

@media (max-width: 780px) {
  .ribbon {

    span {
      font-size: 24px;
      line-height: 36px;
      width: 150px;
      top: 16px;
      right: -36px;
    }
  }
}
</style>