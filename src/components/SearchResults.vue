<template>
  <div class="search-results">
    <ul>
      <li v-for="(item, index) in items" :key="index">{{ item.title }}</li>
    </ul>
  </div>
</template>

<script>
export default {
  props: {
    items: Array
  }
};
</script>

<style lang="scss">
</style>