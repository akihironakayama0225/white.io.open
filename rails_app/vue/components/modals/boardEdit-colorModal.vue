<template>
  <div id="color-modal-root" v-on:click="onColorButtonClick(null)">
    <div id="modal-body" onclick="event.cancelBubble=true">
      <p>色を選択</p>
      <div class="button-container" id="color-wrapper">
        <div class="color-button" style="background-color:black" v-on:click="onColorButtonClick('black')"></div>
        <div class="color-button" style="background-color:red" v-on:click="onColorButtonClick('red')"></div>
        <div class="color-button" style="background-color:blue" v-on:click="onColorButtonClick('blue')"></div>
        <div class="color-button" style="background-color:green" v-on:click="onColorButtonClick('green')"></div>
      </div>
      <div class="button-container">
        <div id="cancel" v-on:click="onColorButtonClick(null)">
          <p>キャンセル</p>
        </div>
      </div>
    </div>
  </div>
</template>


<script>
export default {
  components: {
  },
  data: function () {
    return {
    }
  },
  methods: {
    onColorButtonClick(color){
      this.$emit('changeColor', color);
    }
  },
  mounted: function(){
  }
}
</script>


<style scoped lang="scss">
p {
  color: darkslategray;
  background-color: lightgray;
  font-size: 1.5em;
  text-align: center;
}

div {
  //border: solid 1px gray;
  box-sizing: border-box;
    -moz-box-sizing: border-box;
    -webkit-box-sizing: border-box;
    -o-box-sizing: border-box;
    -ms-box-sizing: border-box;
}

#color-modal-root {
  background: rgba(0, 0, 0, 0.6);
  display: flex;
  justify-content: center;
  align-items: center;
}

#modal-body {
  width:80%;
  max-width:400px;
  overflow: hidden;
  padding: 0px 0px 15px 0px;
  //height:200px;
  background-color: rgb(237, 248, 237);
  //border: solid 1px gray;
  border-radius: 7px;
  box-shadow: 0px 5px 3px rgb(59, 59, 59);
}

.button-container {
  display: flex;
  flex-direction: row;
  justify-content: center;
  align-items: center;
}

#color-wrapper {
  height: 80px;
}

.color-button {
  width:45px;
  height:45px;
  border-radius: 22.5px;
  border: solid 1px white;
  box-shadow: 2px 2px 2px gray;
  opacity: 0.5;
  margin: 5px 10px;

  &:hover {
    opacity: 1.0;
    width:50px;
    height:50px;
    border-radius: 25px;
  }
}

#cancel {
  background-color: lightgray;
  border-radius: 5px;
  box-shadow: 2px 2px 2px gray;

  & p {
    color: darkslategray;
    font-size: 1em;
    margin: 5px 10px;
  }
}
</style>