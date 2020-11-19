<template>
  <div id="mode-container-root" class="horiz-center">
    <div class="mode-strip">
      <div class="button-area horiz-center">
        <modeButton class="vert-center" label="ひとりで使う" src="/images/man-white.png"
          href="/board/private/"></modeButton>
      </div>
      <div class="description-area horiz-left">
        <div class="side-strip">
          <img src="/images/check.svg">
        </div>
        <div class="center-strip">
          <p>登録不要で今すぐ使えます！</p>
          <p>（無料）</p>
        </div>
      </div>
      <div class="description-area horiz-left">
        <div class="side-strip">
          <img src="/images/lock.svg">
        </div>
        <div class="center-strip">
          <p>ホワイトボードの共有はできません</p>
        </div>
      </div>
    </div>
    <div id="white-space"></div>
    <div class="mode-strip">
      <div class="button-area horiz-center">
        <modeButton class="vert-center" label="みんなで使う" src="/images/men-white.png"
          href="/user/index"></modeButton>     
      </div>
      <div class="description-area horiz-left">
        <div class="side-strip">
          <img src="/images/signup.svg">
        </div>
        <div class="center-strip">
          <p>Googleでのログインが必要です</p>
          <p>（無料）</p>
        </div>
      </div>
      <div class="description-area horiz-left">
        <div class="side-strip">
          <img src="/images/crown.svg">
        </div>
        <div class="center-strip">
          <p>ホワイトボードの共有ができます！</p>
        </div>
      </div>
    </div>
  </div>
</template>


<script>
import modeButton from "./modeSelection-button.vue"
export default {
  components: {
    modeButton
  },
  props: ['rails'],
  data: function () {
    return {
      message: "This is Top Page!"
    }
  }
}
</script>


<style scoped lang="scss">
$p-size: 20px;

div　{
  //border: solid 1px gray;
  box-sizing: border-box;
    -moz-box-sizing: border-box;
    -webkit-box-sizing: border-box;
    -o-box-sizing: border-box;
    -ms-box-sizing: border-box;
}

h2　{
  font-size: 2em;
  text-align: center;
}

p {
  font-size: $p-size;
}
.horiz-center{
  display: flex;
  justify-content: center;
}

.horiz-left{
  display: flex;
}

.vert-center{
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
}

.vert-center-left{
  display: flex;
  align-items: center;
  justify-content: flex-start;
}

#mode-container-root {
  //background-color: gray;
  width: 100%;

  #white-space {
    width: 5%;
    height:200px;
    //background-color:red;
  }
  .mode-strip {
    width: 47.5%;
    height: 100%;
    border-left: solid 10px lightgray;
    //background-color: green;

    .button-area {
      //width: 100%;
      //height: 200px;
      //margin: 0 auto;
      //background-color: darkgray;
      padding: 0px 0px 20px 0px;
    }

    .description-area {
      width: 100%;
      padding: 20px 0px;
      //height: 100px;
      //margin: 0 auto;
      //background-color:cyan;
    }

    .side-strip {
      width: 80px;
      height: 100%;
      padding-right:10px;

      img {
        width: 60%;
        margin-left: 40%;
      }
    }

    //.center-strip {
      //width: 100%;
      //height: 100%;
      //background-color:beige;
    //}
  }
}
</style>
