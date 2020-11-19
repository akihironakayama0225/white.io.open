<template>
  <div id="board-edit-root">
    <statusBar id="status-bar" :userCount="userCount" :isPrivate="isPrivate"></statusBar>
    <div id="main-container">
      <color-modal class="modal"
        v-if="needColorModal"
        @changeColor="onColorChanged"></color-modal>
      <info-modal v-if="needWait" class="modal" :message="infoMsg"></info-modal>
      <div id="left-menu">
        <leftMenu ref="leftMenu" @change-mode="changeMode" @change-subMenu="changeSubMenu"></leftMenu>
      </div>
      <div id="board-area">
        <my-canvas ref="myCanvas"
          @recieve-mode="recieveMode"
          @sendObject="sendObject"
          :isDebug="isDebug" :isPrivate="isPrivate"></my-canvas>
      </div>
    </div>
    <div>
      <input v-show="isDebug" type="file" accept="image/jpg,image/jpeg,image/png, image/bmp"
        ref="imgSelector" v-on:change="sendImg" />
      <input v-show="isDebug" type="text" id="isButtonOnObjectPressed" value="hoge" />
      <input v-show="isDebug" type="text" ref="cursorDisplay" value="" />
    </div>
    <div style="height:50px"></div>
  </div>
</template>


<script>
import Vue from 'vue'
import leftMenu from "./boardEdit-leftMenu.vue"
import myCanvas from "./boardEdit-canvas.vue"
import colorModal from "./modals/boardEdit-colorModal.vue"
import infoModal from "./modals/boardEdit-infoModal.vue"
import transceiver from "./utils/transceiver.vue";
import statusBar from "./utils/boardEdit-statusBar.vue";

export default {
  components: {
    leftMenu,
    myCanvas,
    colorModal,
    infoModal,
    transceiver,
    statusBar
  },
  data: function () {
    return {
      isDebug: false,  //Trueにするとデバッグ表示
      isPrivate: true,
      socket:"",
      params: {},
      userCount: 0,
      tmp_stock_data: null,
      objectHistory: [],
      historyCursor: null,
      nextHistoryCursor: null,
      needColorModal: false,
      needWait: true,
      infoMsg: "None",
    }
  },
  methods:{
    changeMode(mode){
      this.$refs.myCanvas.onCanvasModeUpdate(mode);
      if(mode === "image"){
        this.$refs.imgSelector.click();
        // GoTo: this.sendImg()
      }
      if(mode === "undo"){
        this.undo();
      }
      if(mode === "redo"){
        this.redo();
      }
    },
    recieveMode(mode){
      if(mode === this.mode){
        return;
      }
      this.$refs.leftMenu.onCanvasModeRecieved(mode);
    },
    changeSubMenu(subMenu){
      if(subMenu === "reload"){
        if (this.isPrivate){
          return;
        }
        this.socket.fetchAll();
        return;
      }
      if(subMenu === "save"){
        alert("申し訳ございません。\n保存機能は現在開発中です。");
        return;
      }

      if(subMenu === "trash"){
        var ans = confirm("本当に削除しますか？ (この操作は戻せません）")
        if (!ans){
          return;
        }
        var data = {"action": "flushAll", "clientId": this.userId, "dataArr": ""}
        this.sendObject(data);
        return;
      }
      if(subMenu === "fontColor" || subMenu === "lineColor"){
        this.needColorModal = true;
        return;
      }
      this.$refs.myCanvas.objectType = subMenu;
    },
    onColorChanged(color){
      this.needColorModal = false;
      if (color == null){
        return;
      }
      this.$refs.myCanvas.lineColor = color;
      this.$refs.myCanvas.fontColor = color;
    },
    undo(){
      if (this.nextHistoryCursor != null){
        console.log("wait do No." + this.nextHistoryCursor.toString())
        return;
      }
      console.log("undo", this.historyCursor, "-->", this.historyCursor - 1)
      if(this.historyCursor < 0){
        alert("これ以上、戻せません。");
        return;
      }
      var data = this.objectHistory[this.historyCursor]["before"];
      var action = this.objectHistory[this.historyCursor]["action"];
      // this.historyCursor--; ここでは変化させない。 サーバーアクセプト後に変化させる
      if(action === "create"){
        action = "delete"
      }
      else if(action === "delete"){
        action = "revive"
      }
      else{
        action = "update"
      }
      this.nextHistoryCursor = this.historyCursor - 1;
      data["nextCursor"] = this.nextHistoryCursor;
      data["action"] = action
      console.log("undo",data);
      this.socket.speak(data);
    },
    redo(){
      if (this.nextHistoryCursor != null){
        console.log("wait do No." + this.nextHistoryCursor.toString())
        return;
      }
      console.log("redo", this.historyCursor, "-->", this.historyCursor +1)
      if(this.historyCursor >= this.objectHistory.length - 1){
        alert("これ以上、進めません。");
        return;
      }
      var data = this.objectHistory[this.historyCursor + 1]["after"];
      var action = this.objectHistory[this.historyCursor + 1]["action"];
      // this.historyCursor++; ここでは変化させない。 サーバーアクセプト後に変化させる
      if(action === "create"){
        action = "revive"
      }
      this.nextHistoryCursor = this.historyCursor + 1;
      data["nextCursor"] = this.nextHistoryCursor;
      data["action"] = action
      console.log(data)
      this.socket.speak(data);
    },
    sendObject(data){
      if(data.action === "flushAll"){
        this.socket.flush(data);
        return;
      }
      this.socket.speak(data);
    },
    recieveObject(data){
      console.log(data);
      if(data.action === "raiseHand"){
        // 誰かが入室/退出した際に、サーバーに自分のIDを送る
        this.userCount = 0;
        var data = {"user_id": this.userId};
        console.log("Raise Hand",data);
        this.socket.raiseHand(data);
        return;
      }
      if(data.action === "onUserChange"){
        if(this.userCount < data.user_list.length){
          this.userCount = data.user_list.length;
        }
        return;
      }
      if(data.action === "flushAll"){
        this.resetObjectHistory();
        this.$refs.myCanvas.flushAll();
        return;
      }

      this.unlockUndoRedo(data);
          
      // rejected
      if (data.action === "reject"){
        if (data.clientId === this.userId && data.dataArr[0].body.status !== "delete"){
          alert("他のユーザーが編集中のため、移動できません。");
          this.$refs.myCanvas.reject();
        }
        return;
      }
      // accepted
      this.handleOperationHistory(data);
      data.dataArr.forEach(rec => {
        this.reflectIncomingData(rec, data.action, data);
      })
    },
    unlockUndoRedo(data){
      // 戻る・進むボタンのアンロック
      if(data.clientId === this.userId && typeof data["nextCursor"] !== "undefined"){
        if (data["nextCursor"] == this.nextHistoryCursor){
          this.nextHistoryCursor = null;
        }
      }
    },
    handleOperationHistory(data){
      if(data.clientId === this.userId){
        // 戻る, 進む
        if(typeof data["nextCursor"] !== "undefined"){
          this.historyCursor = data["nextCursor"];
        }
        // 通常の操作
        else{
          var acList = ["lock", "update", "create", "delete"]
          if(acList.includes(data.action)){
            if(data.action !== "lock"){
              var data_for_save = JSON.parse(JSON.stringify(data));
              this.addHistory(data_for_save);
            }
            this.tmp_stock_data = JSON.parse(JSON.stringify(data));
          }
        }
        this.$refs.cursorDisplay.value = this.historyCursor;
      }
    },
    addHistory(data){
      if(data.action === "delete" || data.action === "create"){
        var history = {"before": data, "after": data, "action": data.action};
      }else{
        var history = {"before": this.tmp_stock_data, "after": data, "action": data.action};
      }
      
      if(this.historyCursor >= this.objectHistory.length - 1){
        this.objectHistory.push(history)
        this.historyCursor = this.objectHistory.length - 1;
      }else{
        this.objectHistory[this.historyCursor + 1] = history;
        this.objectHistory.splice(this.historyCursor + 2, this.objectHistory.length - 1); 
        this.historyCursor += 1;
      }
      console.log(this.objectHistory);
    },
    reflectIncomingData(rec, action, data){
      if(action === "create"){
        if(rec.body.userId === this.userId){
          this.$refs.myCanvas.setGlobalId(rec["body"]);
        }else{
          this.$refs.myCanvas.createObject(rec["body"]);
        }
      }
      if(action === "delete"){
        this.$refs.myCanvas.findAndAction(rec, action);
      }
      if(action === "lock"){
        if(rec.body.userId === this.userId){
          this.$refs.myCanvas.findAndAction(rec, "activate");
        }
        else{
          this.$refs.myCanvas.findAndAction(rec, action);
        }
      }
      if(action === "unlock"){
        this.$refs.myCanvas.findAndAction(rec, action);
      }
      if(action === "revive"){
        this.$refs.myCanvas.findAndAction(rec, action);
      }

      //if(rec.body.userId === this.userId){
      //  return;
      //}
      if(action === "update"){
        this.$refs.myCanvas.findAndAction(rec, action);
      }
      return;
    },
    sendImg(e){
      if (e.target.files[0] == "") {
        console.log("Image selection is canceled");
        this.$refs.myCanvas.onCanvasModeUpdate("manipulate");
        return;
      }
      this.switchBoardDisability(true, "画像を送信中...");
      // 注意: 下記関数は"非同期処理"
      this.socket.sendImage(e.target.files[0]);
      // ※ これより下の関数の方が先に実行される
      //alert("お先に失礼!")
    },
    switchBoardDisability(isDisabled, msg=null){
      var frame = document.getElementById("frame");
      if(isDisabled){
        frame.style["pointer-events"] = "none";
        this.needWait = true;
        this.infoMsg = msg
      }else{
        frame.style["pointer-events"] = "auto";
        this.needWait = false;
      }
    },
    resetObjectHistory(){
      this.objectHistory = [];
      this.historyCursor = -1;
      this.nextHistoryCursor = null;
    },
    createUserId(){
      var now = new Date();
      return (10000*now.getHours() + 100*now.getMinutes() + now.getSeconds()).toString()
                + this.generateRandomStr(3);
    },
    generateRandomStr(N){
      var S="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
      return Array.from(Array(N)).map(()=>S[Math.floor(Math.random()*S.length)]).join('');
    },
    // params[:id]を取得する
    getParamsFromURL() {
      var str = window.location.pathname;
      const regex_url = /\/[A-Z|a-z|0-9]+/g;
      let url_list = str.match(regex_url);
      var url_list2 = [];
      url_list.forEach(el => {
        url_list2.push(el.replace("/", ""));
      })
      var board_id = url_list2.pop();
      var board_hash = url_list2.pop();
      return {"board_id": board_id, "board_hash": board_hash};
    },
    onConnected(){
      this.socket.fetchAll();
      this.switchBoardDisability(false);
    },
    onRecieved(data){
      this.recieveObject(data);
    },
    onDisconnected(){
      this.resetObjectHistory();
      this.socket.$destroy();
      this.switchBoardDisability(true, "サーバーとの通信が切れました。　ページをリロードしてください。");
    },
    onFetchedAll(objects){
      if(!Array.isArray(objects)){
        this.onDisconnected();
        return;
      }

      this.resetObjectHistory();
      this.$refs.myCanvas.flushAll();
      objects.forEach(rec =>{
        rec = JSON.parse(rec)
        console.log(rec)
        // ToDo: この処理はサーバー側の責務かも？
        if(rec.status === "delete"){
          console.log("This object has been deleted. Skipping");
        }
        else{
          this.$refs.myCanvas.createObject(rec);
        }
      })
    },
    onSendImage(imgUrl){
      this.$refs.myCanvas.onImageUploaded(imgUrl);
      this.$refs.myCanvas.onCanvasModeUpdate("manipulate");
      this.$refs.imgSelector.value = "";
      this.switchBoardDisability(false);
    }
  },
  mounted: function(){
    this.switchBoardDisability(true, "サーバーに接続中...");
    this.userId = this.createUserId();
    this.$refs.myCanvas.userId = this.userId;
    console.log(this.userId, this.params.board_hash, this.params.board_id);

    this.params = this.getParamsFromURL();
    if(this.params.board_hash !== "borad" && this.params.board_id !== "private"){
      this.isPrivate = false;
    }

    // 通信用オブジェクトの生成
    var ComponentClass = Vue.extend(transceiver);
    this.socket = new ComponentClass({
      propsData: { 
        params: this.params,
        isPrivate: this.isPrivate
      }
    })
    
    this.socket.$on('onConnected', this.onConnected);
    this.socket.$on("onRecieved", this.onRecieved);
    this.socket.$on("onDisconnected", this.onDisconnected);
    this.socket.$on("onFetchedAll", this.onFetchedAll);
    this.socket.$on("onSendImage", this.onSendImage);
    this.socket.$mount();

    // https://www.yukiiworks.com/archives/236
    //window.addEventListener('pageshow', () => {alert('active');});
    //window.addEventListener('focus', () => {console.log('active');});
  }
}
</script>


<style scoped lang="scss">
#board-edit-root{
  z-index: 0;
}

p {
  font-size: 2em;
  text-align: center;
}

div {
    box-sizing: border-box;
      -moz-box-sizing: border-box;
      -webkit-box-sizing: border-box;
      -o-box-sizing: border-box;
      -ms-box-sizing: border-box;
}

#status-bar{
  top: 0px;
  height: 30px;
  right: 5%;
  font-size: 20px;
  margin-top: 5px;
  margin-right: 10px;
  z-index:20090;
  position:fixed;
}

#main-container{
  position: relative;
}

#left-menu {
  height:100%;
}

#board-area {
  height:100%;
}

.modal{
  position: absolute;
  z-index:20000;
  width:100vw;
  height:100%;
}

@media (max-width:720px){
  #main-container {
    height:90vh;
    background-color: rgb(207, 200, 200);
    display: flex;
    flex-direction: column;
  }

  #left-menu {
    height:30%;
    order: 2;
  }

  #board-area {
    height:70%;
    order: 1;
  }
}

@media (min-width:720px){
  #main-container {
    height:85vh;
    background-color: rgb(207, 200, 200);
    display: flex;
    flex-direction: row;
  }

  #left-menu {
    width: 200px;
  }

  #board-area {
    width: calc(100% - 200px);
  }
}
</style>
