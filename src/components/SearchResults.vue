<template>
  <div class="search-results">
    <ul v-if="items.length">
      <li v-for="item in items" :key="item._id">
        <product
          :name="item._source.name"
          :category="item._source.category"
          :picture="item._source.picture"
          :detail="item._source.productDetail"
          :quantity="item._source.quantity"
          :size="item._source.size"
          :reviews="item._source.reviews"
          :price="item._source.price"
          :company="item._source.company"
        />
      </li>
    </ul>
    <div v-else>
      <p class="text-2xl text-center font-bold">No results!</p>
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