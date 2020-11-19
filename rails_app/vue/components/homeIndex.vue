<template>
  <div id="home-index-root">
    <first-view @scroll="scroll"></first-view>
    <div id="main">
      <section>
        <h2 ref="ms">■ 使い方を選ぶ</h2>
        <mode-selection></mode-selection>
      </section>
      <section>
        <h2>■ white.ioでできること</h2>
        <feature></feature>
      </section>
      <section>
        <h2>■ ブラウザ上で直感的な操作を</h2>
        <demo @scroll="scroll"></demo>
      </section>
    </div>
    <div style="height:50px"></div>
  </div>
</template>


<script>
import firstView from "./top/firstView.vue"
import modeSelection from "./top/modeSelection.vue"
import feature from "./top/feature.vue"
import demo from "./top/demo.vue"

export default {
  components: {
    firstView,
    modeSelection,
    feature,
    demo
  },
  props: ['rails'],
  data: function () {
    return {
      message: "This is Top Page!"
    }
  },
  methods: {
    scroll(){
      var destY = this.$refs.ms.offsetTop;
      console.log(destY);
      window.scrollTo(0, destY -80);
    }
  }
}
</script>


<style scoped lang="scss">
* {
  color: rgb(75, 75, 75);
}

h2 {
  margin: 50px;
  font-size: 2em;
  text-align: center;
}

#main {
    width:95%;
    max-width: 1024px;
    padding:0px;
    margin: auto;
    //margin-top:10px;
    //border:solid 1px gray;
    //border-radius: 5px;
    overflow: hidden;
    background-color: white;
}

section {
  margin: 100px 0px; 
}
</style>
