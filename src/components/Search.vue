<template>
  <div class="search">
    <form class="flex flex-row items-center -mx-4 mt-4" @submit.prevent>
      <!-- <label for="search" class="mx-4 font-bold uppercase">Search</label> -->
      <input
        @keyup="search"
        v-model="searchQuery"
        type="search"
        name="search"
        id="search"
        placeholder="Search products by title..."
        autocomplete="off"
        class="border-2 border-gray-400 px-4 py-4 flex-grow mx-4 text-xl rounded"
      />
    </form>
  </div>
</template>

<script>
export default {
  data() {
    return {
      searchQuery: ""
    };
  },
  methods: {
    search(ev) {
      const query = ev.target.value.trim().toLowerCase();
      this.searchQuery = query;
      this.$emit("input", ev);
    }
  }
};
</script>

<style lang="scss">
</style>