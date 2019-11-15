<template>
  <div class="search-results">
    <ul v-if="items && items.length">
      <li v-for="item in items" :key="item._id">
        <product
          :index="item._source.index"
          :name="item._source.name"
          :category="item._source.category"
          :picture="item._source.picture"
          :detail="item._source.productDetail"
          :quantity="item._source.quantity"
          :size="item._source.size"
          :price="item._source.price"
          :company="item._source.company"
          :specialOffer="item._source.specialOffer"
        />
      </li>
    </ul>
    <div
      v-else
      class="no-results h-screen flex items-center justify-center text-4xl text-pink font-bold"
    >
      <p v-if="query && query.length">No search results for {{ query }}!</p>
      <p v-else>No search results!</p>
    </div>
  </div>
</template>

<script>
import Product from "./Product.vue";

export default {
  props: ["items", "query"],
  components: {
    Product
  }
};
</script>

<style lang="scss">
.no-results {
  margin-top: -8rem; // the topbar height
}
</style>