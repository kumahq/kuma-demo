<template>
  <div class="search mb-8">
    <form @submit.prevent>
      <input
        @keyup="submitQuery"
        type="search"
        name="search"
        id="search"
        placeholder="Search products by title..."
        autocomplete="off"
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
input[type="search"] {
  display: block;
  width: 100%;
  padding: 1rem;
  border: 1px solid #ccc;
}
</style>