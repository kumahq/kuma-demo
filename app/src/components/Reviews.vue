<template>
  <div class="product__reviews-wrap mt-8">
    <div v-if="items" class="product__reviews">
      <slot name="header"></slot>
      <ul>
        <li
          v-for="item in items"
          :key="item.id"
          class="product__reviews__item p-4 mt-4 shadow-md bg-gray-200 rounded"
        >
          <h3 class="product__reviews__title flex flex-row items-center font-bold mb-2">
            <div class="mr-4">
              <h3 class="text-xl">{{ item.name }}</h3>
            </div>
            <div>
              <ul class="flex">
                <li v-for="i in item.rating" :key="i">
                  <fa-icon :icon="['fas', 'star']" class="text-lg mr-2 text-yellow-600" />
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
    items: ""
  }
};
</script>