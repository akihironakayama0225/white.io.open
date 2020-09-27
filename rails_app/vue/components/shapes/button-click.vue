<template>
  <div id="click-button" :style="position" 
      v-on:mousedown="onMouseDown"
      v-on:click="onClick">
    <img :src="src"/>
  </div>
</template>
  
  
<script>
// FIX:
// このボタン押下時に、先に本体の requestUpdate()が発火してしまう。
// onMouseDownに変更。 後続を発火させないギミックが必要

export default {
  components: {
  },
  props: ['position', 'roll'],
  data: function () {
    return {
      src: "",

      //position:{
      //  "position": "absolute",
      //  "top": "10px",
      //  "left": "10px",
      //  "height": "50px",
      //  "width": "50px",
      //},
    }
  },
  methods: {
    onMouseDown(){
      document.getElementById("isButtonOnObjectPressed").value = true;
    },
    onClick(e){
      //e.stopPropagation();
      this.$emit("action");
    }
  },
  mounted: function(){
    if(this.roll === "delete"){
      this.src="/images/trash.svg";
    }
    if(this.roll === "edit"){
      this.src="/images/pencil.svg";
    }

    this.$nextTick(function () {
    });
  }
}
</script>


<style scoped lang="scss">
div {
      background-color: lemonchiffon;
      box-shadow: 1px 2px 1px gray;
      margin-left:5px;
      user-select: none;
      -moz-user-select: none;
      -webkit-user-select: none;
      -ms-user-select: none;
    }
    
img {
      width:95%;
      height: 95%;
      top:2.5%;
      left:2.5%;
      pointer-events: none;
    }

</style>
  