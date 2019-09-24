<template>
  <div class="search-results">
    <ul>
      <li v-for="(item, index) in items" :key="index">
        <product :name="item.name" :category="item.category" />
      </li>
    </ul>
  </div>
</template>

<script>
import Product from "./Product.vue";

export default {
  props: {
    items: Array
  },
  components: {
    Product
  }
};
</script>

<style lang="scss">
</style>