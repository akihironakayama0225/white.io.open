<template>
  <div class="my-button"
      v-on:mousedown="onClick"
      v-on:mouseenter="onMouseEnter"
      v-on:mouseleave="onMouseLeave"
      v-bind:style="myStyle">
      <BtnNav ref="nav"></BtnNav>
      <img :src="src">
  </div>
</template>


<script>
import BtnNav from "./boardEdit-leftButton-nav.vue"
require.context('../images', true, /\.(png|jpg|jpeg|svg)$/);

export default {
  components: {
    BtnNav
  },
  props: ['src', 'mode', 'navComment'],
  data: function () {
    return {
      isOn: false,
      myStyle: {
        "background-color":"transparent",
      }
    }
  },
  methods: {
    onClick(){
      // ボタンの色表示の操作は、boardEdit-leftMenuへ移動した
      //this.isOn = true;
      //this.$set(this.myStyle, 'background-color', 'orange'); 
      this.$emit('child-click', this.mode);
    },
    onMouseEnter(){
      this.$refs.nav.isHover = true;
      this.$refs.nav.comment = this.navComment;
    },
    onMouseLeave(){
      this.$refs.nav.isHover = false;
    },
    turnOn(){
      this.isOn = true;
      this.$set(this.myStyle, 'background-color', 'orange'); 
    },
    turnOff(){
      this.isOn = false;
      this.$set(this.myStyle, 'background-color', 'transparent');
      this.$refs.nav.isHover = false;
    }
  }
}
</script>


<style scoped lang="scss">
p {
  font-size: 2em;
  text-align: center;
}

div {
  border-radius: 2px;
  box-sizing: border-box;
    -moz-box-sizing: border-box;
    -webkit-box-sizing: border-box;
    -o-box-sizing: border-box;
    -ms-box-sizing: border-box;
}

.my-button{
  position: relative;
  border: solid 1px rgb(12, 141, 12);
}

@media (min-width: 720px) {
  .my-button {
    height:10vh;
    width:10vh;
    max-height: 90px;
    max-width: 90px;
    padding:3%;
    margin:5px 0px 5px auto;
    box-shadow: 1px 2px 2px rgb(8, 59, 8);

    img {
      width:100%;
      height:100%;
      &:hover{
        background-color: rgb(231, 206, 160)
      }
    }
  }
}

@media (max-width: 720px) {
  .my-button  {
    height:12vw;
    width:12vw;
    padding:5px 5px;
    margin:5px 5px auto;
    box-shadow: 1px 2px 2px rgb(85, 52, 52);
    }

  img {
    width:100%;
    height:100%;
    //max-height:50px;
    &:hover{
      background-color: rgb(231, 206, 160)
    }
  }
}
</style>
