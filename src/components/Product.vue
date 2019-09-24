<template>
  <div class="product">
    <header class="product__header">
      <h3 class="product__title">{{ name }}</h3>
      <p class="product__category">{{ category }}</p>
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
    category: String, // possibly Array?
    name: String,
    detail: String
  }
};
</script>

<style>
</style>