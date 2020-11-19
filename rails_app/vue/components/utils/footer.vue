<template>
  <div id="banner-root" style="width:100vw">
    <footer>
      <p id="sight-nav">
        <a href="/">トップページ</a>
        <a href="/user/index">マイページ</a>
        <a href="/contact/new">お問い合わせ</a>
        <a href="/home/terms">利用規約</a>
      </p>
      <p id="copyright">&copy; white.io, all rights reserved.</p>
    </footer>
  </div>
</template>


<script>
export default {
  components: {
  },
  data: function () {
    return {
      message: "This is banner."
    }
  }
}
</script>


<style scoped lang="scss">
#banner-root{
  /* box-sizing の指定 */
  -webkit-box-sizing: border-box;
  -moz-box-sizeing: border-box;
  box-sizing: border-box;
  a {
    margin: 0 2px 0 2px;
  }
}

#sight-nav{
  font-size:12px;
  background-color:white;
}

#copyright{
  color: white;
  vertical-align:bottom;
  margin-top:2px;
}
footer  {
        height:40px;
        font-size: 12px;
        width: 100%;
        text-align: center;
        position: fixed;
        bottom: 0;
        margin-bottom: 0;
        background-color:rgb(12, 141, 12);
        z-index:100;
}
</style>
