<template>
  <transition name="modal-fade">
    <div class="modal-backdrop">
      <div
        class="modal bg-white rounded p-8 shadow-xl"
        role="dialog"
        aria-labelledby="modalTitle"
        aria-describedby="modalDescription"
      >
        <header class="modal__header" id="modalTitle">
          <button type="button" class="modal__close" aria-label="Close modal" @click="close">x</button>
          <slot name="header"></slot>
        </header>
        <div class="modal__body" id="modalDescription">
          <slot name="body"></slot>
        </div>
        <footer class="modal__footer">
          <slot name="footer"></slot>
        </footer>
      </div>
    </div>
  </transition>
</template>

<script>
export default {
  name: "modal",
  methods: {
    close() {
      this.$emit("close");
    }
  }
};
</script>

<style lang="scss">
.modal-backdrop {
  position: fixed;
  top: 0;
  right: 0;
  bottom: 0;
  left: 0;
  background-color: rgba(#fff, 0.95);
  display: flex;
  justify-content: center;
  align-items: center;
}

.modal {
  overflow-x: auto;
  display: flex;
  flex-direction: column;
}

.modal__header {
}

.modal__body {
}

.modal__footer {
}

.modal__close {
}

// transitions
.modal-fade-enter,
.modal-fade-leave-active {
  opacity: 0;
  transform: scale(0);
}

.modal-fade-enter-active,
.modal-fade-leave-active {
  transition: opacity 0.5s ease, transform 0.5s ease;
  transform: scale(1);
}
</style>