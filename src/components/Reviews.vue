<template>
  <div class="product__reviews-wrap mt-8">
    <div v-if="items" class="product__reviews">
      <slot name="header"></slot>
      <ul>
        <li
          v-for="item in items"
          :key="item.id"
          class="product__reviews__item p-4 mt-4 border-b border-gray-300 shadow-md rounded"
        >
          <h3 class="product__reviews__title flex flex-row font-bold mb-2">
            <div class="mr-4">{{ item.name }}</div>
            <div>
              <ul class="flex">
                <li v-for="i in parseInt(item.rating)" :key="i">
                  <fa-icon :icon="['fas', 'star']" class="mr-2" />
                </li>
              </ul>
            </div>
          </h3>
          <p class="mb-2">{{ item.review }}</p>
        </li>
      </ul>
    </div>
    <div v-else class="text-center font-bold p-8">
      <p>There are no reviews for this product yet.</p>
    </div>
  </div>
  <!-- .product__reviews -->
</template>

<script>
export default {
  props: {
    items: Array
  }
};
</script>