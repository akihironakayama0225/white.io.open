<template>
  <div id="feature-container">
    <div class="txt-area vert-left scroll-trigger">
      <img src="/images/draw_pencil.svg"><p>あなたのアイディアを自由にスケッチ</p>
    </div>
    <div class="txt-area vert-left scroll-trigger">
      <img src="/images/mail.svg"><p>URLの共有で、友人をホワイトボードへ簡単招待</p>
    </div>
    <div class="txt-area vert-left scroll-trigger">
      <img src="/images/team.svg"><p>複数人での同時編集が可能</p>
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
      elemTrigger: null,
    }
  },
  methods: {
    scroll_effect(){
      for (let el of this.elemTrigger) {
        if (el.offsetTop + el.offsetHeight < window.scrollY + window.innerHeight * 0.9){
          el.classList.add('show');
        }else{
          el.classList.remove('show');
        }
      }
    }
  },
  created: function(){
    this.elemTrigger = document.getElementsByClassName("scroll-trigger");
    var that = this;
    window.addEventListener('scroll', function(e) {
      that.scroll_effect();
    });
  }
}
</script>


<style scoped lang="scss">
$p-size: 20px;

div{
  //border: solid 1px gray;
  box-sizing: border-box;
    -moz-box-sizing: border-box;
    -webkit-box-sizing: border-box;
    -o-box-sizing: border-box;
    -ms-box-sizing: border-box;
}

img {
  width: $p-size;
  height: $p-size;
  margin: 0px 0.5*$p-size;
}

p {
  font-size: $p-size;
}

#feature-container {
  width: 100%;
  //background-color: gray;

  .txt-area {
    width: 100%;
    //height: 50px;
    margin: 20px 0px;
    padding: 10px 50px;
    background-color: rgb(245, 245, 201);
  }

  .scroll-trigger {
    opacity: 0;
    transform: translate(0, 60px);
  }
  .show {
    animation: fadein 2s ease forwards;
  }
  @keyframes fadein {
    0% {
      opacity: 0;
      transform: translate(0, 60px);
    }
    100% {
      opacity: 1;
      transform: translate(0, 0);
    }
  }
}

.vert-left{
  display: flex;
  align-items: center;
}
</style>
