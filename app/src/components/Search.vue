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
      const query = ev.target.value;
      const key = event.keyCode || event.charCode;
      this.searchQuery = query;
      // only run the search query if the user is not pressing
      // the delete or backspace keys. no need to hit the API
      // for every single string that is being deleted
      if (key !== 8 && key !== 46) {
        this.$emit("input", ev);
      }
      // if the user has typed a query and cleared the search input,
      // the list is returned to its normal state
      if (!query) {
        this.$emit("input", ev);
      }
    }
  }
};
</script>

<style lang="scss">
</style>