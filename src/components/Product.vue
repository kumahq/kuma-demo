<template>
  <div class="product mb-8 pt-8 border-t border-gray-300">
    <header class="product__header flex flex-row -mx-4">
      <div class="w-1/5 px-4">
        <div class="product__image">
          <img
            :src="picture"
            :alt="`A picture of ${name}`"
            class="object-cover w-full rounded md:w-56"
          />
        </div>
        <div class="product__actions mt-4">
          <a
            class="block bg-blue-500 hover:bg-blue-700 text-white text-center font-bold py-2 px-4 rounded"
            href="#"
          >Buy</a>
        </div>
      </div>
      <div class="w-4/5 px-4">
        <h2 class="product__title text-2xl mb-4">{{ name }}</h2>
        <div class="product__detail">
          <p>{{ detail }}</p>
        </div>
        <!-- .product__detail -->

        <div class="product__extras mt-4 p-4 bg-gray-200 rounded">
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
              <fa-icon :icon="['fas', 'box-open']" class="mr-2" />
              {{ quantity }} Left
            </li>
          </ul>
        </div>
        <!-- .product__extras -->

        <reviews :items="reviews" />
        <!-- product reviews -->
      </div>
    </header>
  </div>
</template>

<script>
import Reviews from "./Reviews.vue";

export default {
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
    reviews: Array
  },
  components: {
    Reviews
  }
};
</script>

<style lang="scss">
.product__title {
  font-weight: 700;
}

.product__category {
  // font-size: 1.8rem;
}

.product__detail {
}
</style>