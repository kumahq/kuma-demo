<template>
  <div class="search">
    <form class="flex flex-row items-center -mx-4 mt-4" @submit.prevent>
      <!-- <label for="search" class="mx-4 font-bold uppercase">Search</label> -->
      <input
        @keyup="submitQuery"
        type="search"
        name="search"
        id="search"
        placeholder="Search products by title..."
        autocomplete="off"
        class="border border-gray-400 px-4 py-4 flex-grow mx-4"
      />
    </form>
  </div>
</template>

<script>
export default {
  methods: {
    submitQuery(ev) {
      const query = ev.target.value;
      this.$store.commit("updateSearchQuery", query);
    }
  }
};
</script>

<style lang="scss">
</style>