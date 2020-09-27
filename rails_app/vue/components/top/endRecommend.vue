<template>
  <div id="recom-root">
    <div id="fv-scroll-button" v-on:click="requestScroll">
          <p class="bt-txt">今すぐ試してみる</p>
    </div>
  </div> 
</template>


<script>
export default {
  components: {
  },
  props: [],
  data: function () {
    return {
    }
  },
  methods: {
    requestScroll(){
      this.$emit("scroll");
    }
  },
  created: function(){
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

#recom-root {
  width: 100%;
  padding: 50px 0px;

  #fv-scroll-button {
      background-color: rgba($color: green, $alpha: 0.8);
      border: solid 3px rgba($color: white, $alpha: 0.8);
      border-radius: 6px;
      display: flex;
      justify-content: center;
      align-items: center;
      cursor: pointer;
      margin: 0 auto;
      width: 350px;
      
      &:hover {
        background-color: rgba(75, 170, 77, $alpha: 1);
      }

      .bt-txt{
        text-align: center;
        color: white;
        font-size: 1.5em;
        letter-spacing: 0.1em;
        margin: 0.5em; 
        font-weight: bold;
      }
    }

}
</style>
