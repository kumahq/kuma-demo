<template>
  <div class="search-results">
    <ul v-if="items && items.length">
      <li v-for="item in items" :key="item._id">
        <product
          :index="item.data.index"
          :name="item.data.name"
          :category="item.data.category"
          :picture="item.data.picture"
          :detail="item.data.productDetail"
          :quantity="item.data.quantity"
          :size="item.data.size"
          :price="item.data.price"
          :company="item.data.company"
          :specialOffer="item.data.specialOffer"
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