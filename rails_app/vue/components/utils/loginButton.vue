<template>
  <div id="login-button-root">
    <button v-on:click="jumpToLink">
      <span>{{message}}</span>
    </button>
    <!--p class="debug"> uid: {{this.userId}}</p-->
  </div>
</template>


<script>
import axios from 'axios'
import { csrfToken } from 'rails-ujs'
axios.defaults.headers.common['X-CSRF-Token'] = csrfToken()

export default {
  components: {
  },
  data: function () {
    return {
      userId:"",
      message: "",
      link: "/",
    }
  },
  methods:{
    getMyUserId(){
      axios.post('/user/user_id.json', {
      })
      .then(response => (
        this.userId = response.data["user_id"],
        this.changeButtonMessage()
      ))
    },
    changeButtonMessage(){
      if(this.userId == null){
        this.message = "ログイン";
        this.link = "/user/index";
      }
      else{
        this.message = "ログアウト";
        this.link = "/signout"
      }
    },
    jumpToLink(){
      location.href= this.link;
    }
  },
  mounted: function(){
    this.getMyUserId()
  }
}
</script>


<style scoped lang="scss">
#login-button-root{
  position:fixed;
}
div{
  //border: solid 1px gray;
  display: flex;
  align-items: center;
}

button{
  height:66%;
  vertical-align: center;
  font-size:16px;
  border: none;
  border-radius: 2px;
  padding: 0px 5px;
  background-color: white;
}

.debug{
  margin-left: 10px;
}
</style>
