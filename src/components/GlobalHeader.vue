<template>
  <header class="global-header">
    <div class="global-header__col">
      <img :src="require('@/assets/kuma-logo.svg')" alt="Kuma Marketplace Logo" />
    </div>
    <div class="global-header__col">
      <h1>Marketplace</h1>
    </div>
  </header>
</template>

<script>
export default {};
</script>

<style lang="scss">
.global-header {
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 2rem;
  text-align: center;

  h1 {
    font-size: 2.6rem;
    margin-left: auto;
  }
}

.global-header__col {
  flex: 1;
}
</style>