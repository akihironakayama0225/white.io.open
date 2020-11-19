<template>
  <div id="demo-root">
    <div id="gif-area" ref="gifArea">
      <img :src="src" id="gif">
    </div>
    <reccomend @scroll="requestScroll"></reccomend>
  </div>
</template>


<script>
import reccomend from "./endRecommend.vue"

export default {
  components: {
    reccomend,
  },
  props: [],
  data: function () {
    return {
      fadeElems: null,
      src: null,
    }
  },
  methods: {
    scroll_effect(){
      var el = this.$refs.gifArea;
      if (el.offsetTop + el.offsetHeight < window.scrollY + window.innerHeight*0.9){
        this.src = "/images/demo.gif";
        console.log("Scroll");
      }
    },
    requestScroll(){
      this.$emit("scroll");
    }
  },
  created: function(){
    var that = this;
    window.addEventListener('scroll', function(e) {
      that.scroll_effect();
    });
  }
}
</script>


<style scoped lang="scss">
div{
  //border: solid 1px gray;
  box-sizing: border-box;
    -moz-box-sizing: border-box;
    -webkit-box-sizing: border-box;
    -o-box-sizing: border-box;
    -ms-box-sizing: border-box;
}

#demo-root {
  width: 100%;

  #gif-area {
    width: 100%;
    background-color: lightgray;
    padding: 50px;
    display: flex;
    justify-content: center;
    align-items: flex-start;

    #gif{
      width:100%;
      max-width:600px;
    }
  }
}
</style>
