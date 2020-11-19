<template>
  <div id="home-index-root">
    <div id="white-space"></div>
    <div class="content-container">
      <div class="h2-container">
        <img class="icon" src="/images/man_u.svg"><h2>My Page</h2>
      </div>
      <ul>
        <li>こんにちは。User Id = {{userName}} さん</li>
      </ul>
      <div　class="center">
        <button class="link" v-on:click="jumpToBoard">共有ボードを開く</button>
        <div>
          <a href="/board/private">一人で使う場合はこちら</a>
        </div>
      </div>

      <div class="h2-container">
        <img class="icon" src="/images/mail_u.svg"><h2>ホワイトボードへの招待</h2>
      </div>
      <ul>
        <li>以下のURLを教えて、共有ボードに招待しましょう！</li>
        <li>招待された人は、ログイン不要でそのままアクセスできます。</li>
      </ul>
      <div class="center" id="url-box">
        <img class="url-icon" src="/images/share_u.svg">
        <i class="fa fa-share" aria-hidden="true"></i> 招待URL：
        <input type="text" id="copyUrl" :value="'http://' + boardUrl" readonly="readonly">
        <button class="myButton" v-on:click="copyUrl">コピー</button>
      </div>
      <div id="main-img">
        <img src="/images/top-fv.jpg">
      </div>

      <div class="h2-container">
        <img class="icon" src="/images/gear_u.svg"><h2>設定</h2>
      </div>
      <ul>
        <li>以前までの招待URLを無効にし、新しいURLに変更します。</li>
        <li>
          <button class="myButton" ref="updateUrl" v-on:click="updateBoardUrl">{{msgOnUpdateUrlButton}}</button>
          <!--button class="myButton" ref="remake" v-on:click="remakeBoard">{{msgOnRemakeButton}}</button-->
        </li>
      </ul>

      <div class="h2-container">
        <img class="icon" src="/images/caution_u.svg"><h2>ご注意</h2>
      </div>
      <ul>
        <li>30分以上操作がないと、共有ボードへの書き込みが消去されます。</li>
      </ul>

    </div>
    <div style="height:50px"></div>
  </div>
</template>


<script>
// font-awsome vue
// https://qiita.com/riversun/items/4faa56ac40071f638313
// https://fontawesome.com/v4.7.0/icons/
// --> ページサイズが大きくなるので使わない。

import axios from 'axios'
import { csrfToken } from 'rails-ujs'
axios.defaults.headers.common['X-CSRF-Token'] = csrfToken()

export default {
  components: {
  },
  props: ['rails'],
  data: function () {
    return {
      msgOnRemakeButton: "ホワイトボードを初期化する",
      msgOnUpdateUrlButton: "招待URLを変更する",
      userName: "",
      boardUrl: "",
    }
  },
  methods:{
    getMyUserId(){
      axios.post('/user/user_and_board.json', {
      })
      .then(response => (
        console.log(response.data),
        this.userName = response.data["user_id"],
        this.boardUrl = response.data["board_path"]
      ))
    },
    jumpToBoard(){
      location.href = 'https://' + this.boardUrl;
    },
    copyUrl(){
      var copyTarget = document.getElementById("copyUrl");
      copyTarget.select();
      document.execCommand("Copy");
      copyTarget.blur();
      alert("URLをコピーしました！ : " + copyTarget.value);
    },
    updateBoardUrl(){
      var updateBt = this.$refs.updateUrl;
      updateBt.disabled = true;
      axios.patch('/board/update_hash.json', {
      })
      .then(response => (
        console.log(response.data),
        this.boardUrl = response.data["board_path"],
        this.msgOnUpdateUrlButton = "招待URLを変更しました"
      ))
      .catch(error => {
        this.msgOnUpdateUrlButton = "サーバー内部でエラーが発生しました"
        console.log('response: ', error.response.data);
      })
    },
    remakeBoard(){
      var remakeBt = this.$refs.remake;
      var updateBt = this.$refs.updateUrl;
      remakeBt.disabled = true;
      updateBt.disabled = true;
      axios.post('/board/remake_board.json', {
      })
      .then(response => (
        console.log(response.data),
        this.boardUrl = response.data["board_path"],
        this.msgOnRemakeButton = "ホワイトボードを初期化しました",
        this.msgOnUpdateUrlButton = "招待URLを変更しました"
      ))
      .catch(error => {
        this.msgOnRemakeButton = "サーバー内部でエラーが発生しました"
        console.log('response: ', error.response.data);
      })
    },
  },
  mounted: function(){
    this.getMyUserId();
  }
}
</script>

<style scoped lang="scss">
* {
  color: rgb(75, 75, 75);
}

#home-index-root{
    background-color: #dddddd;
}

#white-space{
  height: 5px;
}

.content-container{
		width:80%;
    max-width:800px;
		padding:10px 30px 20px 30px;
		margin: auto;
		margin-top:10px;
    border-radius: 10px;
		border:solid 1px gray;
		overflow: hidden;
    background-color:white;
}

.h2-container {
  display: flex;
  //background-color: red;
  align-items: center;
  margin: 20px 0px 10px 0px;
  h2 {
    font-size: 24px;
  }
  .icon {
    height: 24px;
    margin-right: 5px;
  }
}


.link{
  width:80%;
  max-width:300px;
  margin: 10px 0px 10px 0px;
  font-size: 20px;
  letter-spacing: 5px;
  color: white;
  border: solid 1px white;
  background-color: rgb(75, 170, 77);
  border-radius: 3px;
  box-shadow:2px 3px 3px gray;
}

.myButton{
  //width:80%;
  //max-width:300px;
  margin: 10px 0px 10px 0px;
  //font-size: 20px;
  color: rgb(78, 82, 26);
  border: solid 1px green;
  background-color: beige;
  border-radius: 3px;
  box-shadow:1px 1px 2px gray;

  &:disabled {
    color:gray;
    background: lightgray;
    box-shadow:none;
  }
}

.center{
  text-align:center;
}

#main-img{
		display:flex;
		justify-content: center;
    align-items: flex-start;
    width: 100%;
    
    img {
      width: 100%;
      max-width: 400px;
      margin: 20px;
    }
}

#url-box{
  //margin: 10px 0px 10px 0px;
  display: flex;
  justify-content: center;
  align-items: center;
  //background-color: blue;
  .url-icon {
    height: 20px;
    margin-right: 3px;
  }
}
#copyUrl{
  width: 70%;
  max-width:360px;
  background-color: rgb(70, 68, 68);
  color: rgb(238, 235, 213);
  border-radius: 3px;
}
</style>
