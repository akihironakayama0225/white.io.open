<template>
  <div id="status-bar-root">
    <div v-if="isPrivate" id="members" @click="onClick">
      <img src="/images/lock.svg"/>
      <span> Private</span>
    </div>
    <div v-else id="members" @click="onClick">
      <img src="/images/man.png"/>
      <span> × {{userCount}}人</span>
    </div>
    <div v-show="isBallonActive">
      <div class="balloon1" v-if="isPrivate">
        <p>非公開モードです</p>
      </div>
      <div class="balloon1" v-else>
        <p>共同編集モードです</p>
      </div>
    </div>
  </div>
</template>


<script>
export default {
  components: {
  },
  props: ["userCount", "isPrivate"],
  data: function () {
    return {
      message: "This is banner.",
      isBallonActive: false,
    }
  },
  methods: {
    onClick(){
      if (this.isPrivate){
        alert("ボードを共有するには下の[マイページ]へ。");
      }else{
        alert("共有ボードの設定は下の[マイページ]から変更できます。");
      }
    },
    showBalloon(){
      this.isBallonActive = true;
    },
    hideBalloon(){
      this.isBallonActive = false;
    },
  },
  mounted: function(){
    setTimeout(this.showBalloon, 1000);
    setTimeout(this.hideBalloon, 4000);
  }
}
</script>

<style scoped lang="scss">
$ballon-color: #1f3020;
$ballon-opacity: 0.8;

#status-bar-root {
  position: relative;
  
}

#members {
  height: 100%;
  width:100%;
  font-size: 20px;
  display:flex;
  flex-direction: row;
  justify-content: flex-end;
  cursor: pointer;
  img {
    height: 95%;
    margin-right:5px;
  }
  span {
    color: white;
  }
}

.balloon1 {
  position: relative;
  display: inline-block;
  margin-top: 5px;
  padding: 7px 10px;
  min-width: 120px;
  max-width: 100%;
  color: #555;
  font-size: 16px;
  background-color: $ballon-color;
  border-radius: 5px;
  opacity: $ballon-opacity;
}

.balloon1:before {
  content: "";
  position: absolute;
  bottom: 100%;
  right: 10%;
  margin-right: 10px;
  border: 10px solid transparent;
  border-bottom: 10px solid $ballon-color;
  opacity: $ballon-opacity;
}

.balloon1 p {
  margin: 0;
  padding: 0;
  color: white;
}
</style>
