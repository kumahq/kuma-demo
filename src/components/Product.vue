<template>
  <div class="product mb-8">
    <header class="product__header flex flex-row -mx-4">
      <div class="w-1/5 px-4">
        <div class="product__image">
          <img :src="picture" :alt="`A picture of ${name}`" class="object-cover w-full rounded" />
        </div>
        <div class="product__actions mt-4">
          <a
            class="block bg-blue-500 hover:bg-blue-700 text-white text-center font-bold py-2 px-4 rounded"
            href="#"
          >Buy</a>
        </div>
      </div>
      <div class="w-4/5 px-4">
        <h2 class="product__title text-xl mb-4">{{ name }}</h2>
        <div class="product__detail">
          <p>{{ detail }}</p>
        </div>
        <!-- .product__detail -->

        <div class="product__extras mt-4 pt-4 border-t border-gray-300">
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

        <div v-if="reviews" class="product__reviews">
          <ul>
            <li v-for="item in reviews" :key="item.id" class="product__reviews__item">
              <h3>{{ item.name }}</h3>
              <p>{{ item.review }}</p>
              <ul class="flex">
                <li v-for="i in parseInt(item.rating)" :key="i">
                  <fa-icon :icon="['fas', 'star']" class="mr-2" />
                </li>
              </ul>
            </li>
          </ul>
        </div>
        <!-- .product__reviews -->
      </div>
    </header>
  </div>
</template>

<script>
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