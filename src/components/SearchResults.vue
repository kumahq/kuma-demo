<template>
  <div class="search-results">
    <ul v-if="items.length">
      <li v-for="item in items" :key="item._id">
        <product
          :name="item.name"
          :category="item.category"
          :picture="item.picture"
          :detail="item.productDetail"
          :quantity="item.quantity"
          :size="item.size"
          :reviews="item.reviews"
        />
      </li>
    </ul>
    <div v-else>
      <p>No results met your search criteria!</p>
    </div>
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