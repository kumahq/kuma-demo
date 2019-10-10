<template>
  <div class="error bg-red-300 rounded p-4 mt-4 mb-4 overflow-hidden">
    <header class="error__header font-bold text-xl">
      <slot name="header"></slot>
    </header>
    <div class="error__body">
      <slot name="body"></slot>
    </div>
  </div>
</template>