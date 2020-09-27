<template>
  <div id="user-index-root">
    <banner></banner>

    <!-- 内部は、別コンポーネントを使って描画する -->

    <end></end>
  </div>
</template>

<script>
import banner from "./header.vue"
import end from "./footer.vue"
export default {
  components: {
    banner,
    end
  },
  props: ['rails'],
  data: function () {
    return {
    }
  }
}
</script>

<style scoped lang="scss">
</style>
