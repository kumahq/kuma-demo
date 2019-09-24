<template>
  <div class="product mb-8">
    <header class="product__header flex flex-row -mx-4">
      <div class="w-1/6 px-4">
        <div class="product__image">
          <img :src="picture" :alt="`A picture of ${name}`" class="object-cover w-full rounded" />
        </div>
        <div class="product__extras mt-4">
          <p class="product__category font-bold text-gray-600 mb-4">{{ category }}</p>
          <a
            class="block bg-blue-500 hover:bg-blue-700 text-white text-center font-bold py-2 px-4 rounded"
            href="#"
          >Buy</a>
        </div>
      </div>
      <div class="w-5/6 px-4">
        <h2 class="product__title text-xl mb-4">{{ name }}</h2>
        <div class="product__detail">{{ detail }}</div>
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
    category: String,
    name: String,
    detail: String
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