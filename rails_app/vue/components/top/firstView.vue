<template>
  <div id="top-image">
    <img src="/images/top-fv.jpg" id="top-fv"/>
    <div id="fv-banner">
      <p class="title">オンラインで</p>
      <p class="title">ホワイトボードを双方向にシェア</p>
    </div>

    <div id="fv-scroll-button-container">
      <div id="free-circle" v-on:click="requestScroll">
        <p class="free-circle-txt">無 料</p>
      </div>
      <div id="fv-scroll-button" v-on:click="requestScroll">
        <p class="bt-txt">今すぐ試してみる</p>
      </div>
    </div>
  </div>
</template>


<script>
export default {
  components: {
  },
  props: ["label", "src", "href"],
  data: function () {
    return {
    }
  },
  methods: {
    requestScroll(){
      this.$emit("scroll");
    }
  }
}
</script>


<style scoped lang="scss">
$p-size: 30px;

div{
  //border: solid 1px gray;
  box-sizing: border-box;
    -moz-box-sizing: border-box;
    -webkit-box-sizing: border-box;
    -o-box-sizing: border-box;
    -ms-box-sizing: border-box;
}

  #top-image {
    position: relative;
    //background-color: rgba(50,50,50,0.5);
    width:100%;
    //height: 600px;
    max-width: 1200px;
    margin: 0 auto;
  }

  img {
    width:100%;
    height: 100%;
  }

  #fv-banner {
    position: absolute;
    //width: 40%;
    //min-width: 300px;
    //max-width: 300px;
    //height: 20%;
    top: 10%;
    //left: 5%;
    background-color: rgba($color: rgb(95, 114, 95), $alpha: 0.4);

    .title {
      color: white;
      font-size: 50px;
      text-shadow: 2px 2px 4px rgb(49, 102, 53);
      font-weight: bolder;
      margin: 0 20px;
      @media (max-width:720px){
        font-size: 36px;
      }
      @media (max-width:480px){
        font-size: 20px;
      }
    }
  }

  #fv-scroll-button-container {
    position: absolute;
    bottom:15%;
    right: 5%;
  
    #free-circle {
      cursor: pointer;
      position: absolute;
      width: 80px;
      height: 80px;
      top: -40px;
      left: -40px;
      border-radius: 50%;
      background-color: rgba($color: beige, $alpha: 1);
      border: solid 3px rgba($color: white, $alpha: 0.8);
      display: flex;
      justify-content: center;
      align-items: center;

      .free-circle-txt{
        font-size: 25px;
        font-weight: bolder;
        color: rgb(75, 22, 22);
      }

      &:hover {
        width: 90px;
        height: 90px;
        top: -45px;
        left: -45px;
      }
      @media (max-width:720px){
        width: 50px;
        height: 50px;
        top: -25px;
        left: -25px;
        .free-circle-txt{
          font-size: 15px;
          font-weight: bolder;
          color: rgb(75, 22, 22);
        }

        &:hover {
          width: 60px;
          height: 60px;
          top: -30px;
          left: -30px;
        }
      }
      @media (max-width:480px){
        width: 40px;
        height: 40px;
        top: -20px;
        left: -20px;
        .free-circle-txt{
          font-size: 10px;
          font-weight: bolder;
          color: rgb(75, 22, 22);
        }

        &:hover {
          width: 50px;
          height: 50px;
          top: -25px;
          left: -25px;
        }
      }
    }

    #fv-scroll-button {
      background-color: rgba(75, 170, 77, $alpha: 1);
      border: solid 3px rgba($color: white, $alpha: 0.8);
      border-radius: 6px;
      display: flex;
      justify-content: center;
      align-items: center;
      cursor: pointer;

      &:hover {
        background-color: rgba($color: green, $alpha: 0.8);
      }

      .bt-txt{
        text-align: center;
        color: white;
        font-size: 30px;
        letter-spacing: 0.1em;
        margin: 10px 30px 10px 45px;
        font-weight: bold;
      }
      @media (max-width:720px){
        .bt-txt{
          text-align: center;
          color: white;
          font-size: 20px;
          letter-spacing: 0.1em;
          margin: 7px 12.5px 7px 18px;
          font-weight: bold;
        }
      }
      @media (max-width:480px){
        .bt-txt{
          text-align: center;
          color: white;
          font-size: 15px;
          letter-spacing: 0.1em;
          margin: 5px 10px 5px 15px;
          font-weight: bold;
        }
      }
    }
  }


</style>
