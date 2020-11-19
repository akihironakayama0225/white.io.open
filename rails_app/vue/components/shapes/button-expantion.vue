<template>
  <div ref="exbtRoot" :style="position"
      v-on:mousedown="expandStart"
      v-on:mousemove="expand"
      v-on:mouseup="expandEnd"
      v-on:mouseleave="expandEnd">
    <img src="/images/stretch.svg"/>
  </div>
</template>
  
  
<script>

export default {
  components: {
  },
  props: ['position'],
  data: function () {
    return {
      content: "",
      isExpand: false,
      realX:"0px",
      realY:"0px",
      
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
    expandStart(e){
      this.isExpand = true;
      this.expandStartLeft = parseFloat(this.position.left.split("px")[0]);
      this.expandStartTop = parseFloat(this.position.top.split("px")[0]);
      this.expandStartMouseX = e.clientX;
      this.expandStartMouseY = e.clientY;
      console.log("ExpantionOn")
      this.$emit('expandStart');
    },
    expand(e){
      if(this.isExpand){
        var deltaX = e.clientX - this.expandStartMouseX;
        var deltaY = e.clientY - this.expandStartMouseY;
        var newX = (deltaX + this.expandStartLeft) + "px";
        var newY = (deltaY + this.expandStartTop) + "px";
        
        this.$emit('expand', deltaX, deltaY);
        this.$set(this.position, 'left', newX);
        this.$set(this.position, 'top', newY);
      }      
    },
    expandEnd(){
      this.isExpand = false;
      this.$emit('expandEnd');
    },
  },
  mounted: function(){
    this.$nextTick(function () {
    });
  }
}
</script>


<style scoped lang="scss">
div {
      border: solid green 2px;
      border-radius: 22.5px;
      user-select: none;
      -moz-user-select: none;
      -webkit-user-select: none;
      -ms-user-select: none;
      box-shadow: 1px 2px 1px gray;
    }

img {
      width:100%;
      height: 100%;
      pointer-events: none;
    }
</style>
  