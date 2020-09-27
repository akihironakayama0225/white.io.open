<template>
  <div id="banner-root" style="width:100vw">
    <header>
      <login-button id="login"></login-button>
      <h1><a href="/">white.io</a></h1><!--a href="/"></a-->
    </header>
    <div id="white-space"></div>
  </div>
</template>

<script>
import loginButton from "./loginButton.vue"

export default {
  components: {
    loginButton
  },
  data: function () {
    return {
    }
  }
}
</script>


<style scoped lang="scss">
* {/* box-sizing の指定 */
  -webkit-box-sizing: border-box;
  -moz-box-sizeing: border-box;
  box-sizing: border-box;
  //border: solid 1px gray;
  }

header{
  z-index: 19999;
  height: 40px;
  position: fixed;
  width:100%;
  background-color: rgb(12, 141, 12);
}

a {
  text-decoration: none;
  cursor : pointer;
  color: white;
  user-select: none;
  -moz-user-select: none;
  -webkit-user-select: none;
  -ms-user-select: none;
}

h1 {
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 30px;
    height:100%;
    width: 100%;
    color: white;
}

#white-space{
  z-index: 0;
  position: relative;
  height: 40px;
}

#login {
  position: absolute;
  height: 100%;
  margin-left: 5%;
}
</style>
