<template>
  <div id="canvas-root">
    <div id="display-area">
      <div id="frame" ref="frame"
        v-on:mousedown="onMouseDown"
        v-on:mousemove="onMouseMove"
        v-on:mouseup="onMouseUp"
        v-on:mouseleave="onMouseLeave"
        v-on:click="onClick"
        v-on:touchstart="onTouchStart"
        :status= "status"
        :mode = "mode">
      </div>
    </div>
    <div id="debug-container">
      <span v-if="isDebug" style="background-color:white;">{{mode}},{{objectType}},{{status}},{{windowWidth}},{{windowHeight}}</span>
    </div>
  </div>
</template>


<script>
// el と refs
// https://designsupply-web.com/knowledgeside/5412/
// props の基本
// https://qiita.com/minuro/items/fa3ddd70ace5b99a1f90
// component 動的生成
// https://qiita.com/s_yasunaga/items/05e56fad4631f7bc7fe9
// svg 教本
// https://developer.mozilla.org/ja/docs/Web/SVG/Tutorial
// https://qiita.com/kwst/items/16e4877890a19826ba7f
import Vue from 'vue'
import straight from "./shapes/friend-straight.vue"
import rectangle from "./shapes/friend-rectangle.vue"
import myCircle from "./shapes/friend-circle.vue"

import straightArrow from "./shapes/straightArrow.vue"
import freeHand from "./shapes/line-freeHand.vue"
import string from "./shapes/string.vue"
import myImage from "./shapes/image.vue"
import selectionBox from "./shapes/selectionBox.vue"


// private:
const ignoreMovePx = 2.4; //px
const thresMouseDragCount = 5; // times
const bufferSize = 10 // memory size of instances
const borderOffset = 0; //px: #frameのborder幅と同じにすること.
const selectionMargin = 10; //px
const lineWidth = 1.2;
const stringPaddingOffset = 10; //px;
const inCreatingBaseZindex = 10000; //新規作成中のz-index
const friendArr = ["straight", "rectangle", "myCircle", "straightArrow"];
let canvasX;
let canvasY;
let realX;
let realY;
let percentX;
let percentY;
let realX0;
let realY0;
let percentX0;
let percentY0;
let canvasFrame;
let tmpInstance;
let selBox = "";
let selectionList;
let drawStartCordinate = [0,0]; //x,y
let latestCursor = -1;
let mouseDragCount;
let isObjBtPressed;

export default {
  components: {
    straight,
    freeHand,
    rectangle,
    myCircle,
    string,
    myImage,
    selectionBox
  },
  props: ['isDebug', 'isPrivate'],
  data: function () {
    return {
      mode: "", // initial settings is in boardEedit-leftMenu.mounted()
      isDrawing: false,
      isMouseUpFromObjectSelected: true,
      isTouched: false,
      status: "waiting",
      // Z-positions are updated in updateZPosition()
      Zstring:"",
      Zshape:"",
      forcusedChild:"",
      objectType: "freeHand",
      objId: 0, // オブジェクトを足すごとにインクリメント
      objectMemory: [],
      lineColor: "black",
      fontColor: "black",

      windowWidth: "",
      windowHeight:"",
      userId:"",
      // 描画開始時に必須
      passiveBorder: "dotted 2px transparent",

      touchDeleteInstance: null, // 描画時に線をクリックした後、削除するか判断するためのオブジェクト
      imgUrl:"",
    }
  },
  methods: {
    onTouchStart(){
      if(!this.isTouched){
        alert("現在タッチ操作には対応しておりません。\nPCからご利用下さい。");
        this.isTouched = true;
      }
    },
    onMouseDown(e){
      resetPivotPosition(e);
      console.log("mousedown: ", e.target.id);
    
      // 選択の解除: オブジェクト以外をタッチ
      if(e.target.id === "frame"){
        this.deactivateFocused()
      }
      if(this.mode === "manipulate" && e.target.id !== "selection" && this.status === "selected"){
        this.clearSelection();
        return;
      }
      
      if(this.mode === "manipulate" && e.target.id === "frame" && this.status === "waiting"){
        this.status = "selecting";
        selectionList = [];
        this.displaySelectionBox(realX0, realY0, realX, realY, true);
        return;
      }

      if(this.mode === "write"){
        return;
      }

      if(this.mode === "draw"){
        var myVoid; //何も代入しない
        
        if(friendArr.includes(this.objectType)){
          tmpInstance = this.createFriendObj(myVoid, this.objectType);
        }
        else if(this.objectType === "freeHand"){
          tmpInstance = this.createFreeHand();
        }
        this.isDrawing = true;
      }
    },
    onMouseMove(e){
      getMousePosition(e);
      mouseDragCount++;

      if(isButtonOnObjPressed()){
        return;
      }

      if(this.mode === "manipulate"){
        if(this.status === "selecting"){
          this.displaySelectionBox(realX0, realY0, realX, realY, false);
          return;
        }
        if(this.status === "selected"){
          selBox.move(realX - realX0, realY - realY0);
          return;
        }
      }

      if (typeof this.forcusedChild.move !== "undefined") {
        this.forcusedChild.move(realX - realX0, realY - realY0);
      }

      if(this.mode === "draw"){
        if(this.isDrawing === false){
          this.status = "waiting";
          return;
        }
        this.status = "drawing";
        
        if(friendArr.includes(this.objectType)){
          this.drawFriendObj();
        }
        else if(this.objectType === "freeHand"){
          this.drawFreeHand(false);
        }
      }
    },
    onMouseUp(e){
      getMousePosition(e);
      let permitUpdate = !isButtonOnObjPressed();
      isObjBtPressed.value = false;
      this.isDrawing = false;
      this.isMouseUpFromObjectSelected = true;

      /* ---矩形選択の確定処理--- */
      if(this.mode === "manipulate"  && this.status === "selecting"){
        // NG: 選択幅が小さすぎ
        if(this.isSlightMouseMove()){
          this.status = "waiting"
          destroyComponent(selBox);
          return;
        }

        // NG: 何も選択されなかった
        var selectionCout = this.selectInRectangle(realX0, realY0, realX, realY);
        if(selectionCout < 1){
          this.status = "waiting";
          destroyComponent(selBox);
          return;
        };
        // ここに選択完了後の処理を書く
        this.status = "selected";
        this.fitSelectionBox();
        this.$nextTick(function () {
          selBox.resetButtonPosition();
          this.sendObject(selectionList, "lock");
        });
        return;
      }
      // 図形の移動確定処理
      if (this.forcusedChild.isDrag || this.forcusedChild.isExpand 
          || selBox.isDrag || selBox.isExpand) {
        this.confirmMoving(permitUpdate);
        return;
      }

      if(this.mode === "write"){
        console.log(e.target.className)
        if(e.target.className === "string"){
          return;
        }
        tmpInstance = this.createString();
        this.$nextTick(function () {
          tmpInstance.edit();
        });
        // requestAddMemory -> stringコンポーネントに任せる
        return;
      }
      
      /* ---以下、図形描画の処理---*/
      if(this.mode === "draw"){
        // フォーカスした図形の削除
        if(this.status === "waiting"){
          if(this.touchDeleteInstance != null){
            console.log("touch delete line");
            this.requestDelete(this.touchDeleteInstance);
          }
        }
        this.touchDeleteInstance = null;

        /* 描画距離が短い場合、無効 */
        if(this.isSlightMouseMove()){
          this.status = "waiting"
          destroyComponent(tmpInstance);
          return;
        }

        // 描画した図形の確定処理
        if(this.status === "drawing"){
          
          if(friendArr.includes(this.objectType)){
            this.drawFriendObj();
          }
          if(this.objectType === "freeHand"){
            this.drawFreeHand(true);
          }

          this.$nextTick(function () {
            tmpInstance.fitBounding(canvasX, canvasY);
            //
            this.addMemory(tmpInstance);
            this.sendObject([tmpInstance], "create");
            tmpInstance = null;
            //
          });
          return;
        }
      }
    },
    onMouseLeave(e){
      // 書きかけの図形を削除
      if(this.mode === "manipulate" && this.status === "selecting"){
        this.status = "waiting"
        destroyComponent(selBox);
        return;
      }
      if(this.mode === "draw"){
        //書きかけの図形を残す場合
        // ToDo: ドラッグしたまま、マウスをキャンバス外からキャンバスに戻ると
        // statusが勝手に waiting → drawing に遷移するバグを直す
        //this.onMouseUp(e);

        //書きかけの図形を消す場合
        this.status = "waiting"
        destroyComponent(tmpInstance);
        return;
      }

      // 図形ドラッグ中にキャンバスを出た場合
      if (this.forcusedChild.isDrag || this.forcusedChild.isExpand 
            || selBox.isDrag || selBox.isExpand) {
        let permitUpdate = !isButtonOnObjPressed();
        this.confirmMoving(permitUpdate); 
        //this.deactivateAll(); // ← updateとunlockが同時に発火してしまうため実装できない
        return;
      }
    },
    onClick(){
      if(this.mode !== "image" && this.mode !== "plus"){
        return;
      }
      this.onCanvasModeUpdate("manipulate");
    },
    onCanvasModeUpdate(newMode){
      // 選択中のオブジェクトを解除
      this.deactivateAll();

      if(newMode === "undo" || newMode === "redo"){
        var oldMode = this.mode;
        this.$emit('recieve-mode', oldMode);
        return;
      }

      this.mode = newMode;
      this.$emit('recieve-mode', newMode);
    },
    onImageUploaded(imgUrl){
      this.imgUrl = imgUrl;
      tmpInstance = this.createImage();
      tmpInstance = null;
      // requestAddMemory -> image コンポーネントに任せる
    },
    /* ---------------------------------------- */

    /* ---オブジェクトの生成--- */
    createFriendObj(propsJson, objectType){
      // straight, rectangle, myCircle
      if(typeof propsJson === "undefined"){
        propsJson = {
          'x1': realX,
          'y1': realY,
          'x2': realX,
          'y2': realY,
          'lineWidth': lineWidth,
          'lineColor': this.lineColor,
          type: objectType,
          position: {
            position:　"absolute",
            "z-index": inCreatingBaseZindex + this.objId,
            top: "",
            left: "",
            width: "100%",
            height: "100%",
            border: this.passiveBorder,
          },
        };
      }
      if(objectType === "straight"){
        var friend = straight; 
      }
      else if(objectType === "straightArrow"){
        var friend = straightArrow; 
      }
      else if(objectType === "rectangle"){
        var friend = rectangle; 
      }
      else if(objectType === "myCircle"){
        var friend = myCircle; 
      }
      else{
        throw "Error Friendobject not match!" + objectType;
      }
      var object = createComponent(canvasFrame, friend, propsJson);
      object.$on('respond', this.getForcusedChild);
      object.$on('touchDelete', this.touchDelete);
      object.$on('requestDelete', this.requestDelete);
      return object;
    },
    createFreeHand(propsJson){
      if(typeof propsJson === "undefined"){
        propsJson = {
          'width': lineWidth,
          'lineColor': this.lineColor,
          type: "freeHand",
          path: "M " + String(realX) + " " + String(realY) 
                  + " C " + String(realX) + " " + String(realY)
                  + " " + String(realX) + " " + String(realY)
                  + " " + String(realX) + " " + String(realY),
          position: {
            position:　"absolute",
            "z-index": inCreatingBaseZindex + this.objId,
            top: "",
            left: "",
            width: "100%",
            height: "100%",
            border: this.passiveBorder,
          },
        };
      }
      var object = createComponent(canvasFrame, freeHand, propsJson);
      object.$on('respond', this.getForcusedChild);
      object.$on('touchDelete', this.touchDelete);
      object.$on('requestDelete', this.requestDelete);
      return object;
    },
    createString(propsJson){
      if(typeof propsJson === "undefined"){
        propsJson = {
          content: "",
          type: "string",
          fontStyle:{
            "font-size": "20px",
            "color": this.fontColor,
          },
          'position':{
            "position": "absolute",
            "z-index": inCreatingBaseZindex + this.objId,
            "left": (realX - stringPaddingOffset) + "px",
            "top": (realY - stringPaddingOffset) + "px",
            "border": this.passiveBorder
          },
        };
      }
      var object = createComponent(canvasFrame, string, propsJson);
      object.$on('respond', this.getForcusedChild);
      object.$on('requestAddMemory', this.addMemory);
      object.$on('requestSend', this.sendObject);
      object.$on('requestDelete', this.requestDelete);
      return object;
    },
    createImage(propsJson){
      if(this.imgUrl == null){
        console.log("imgURL is null, skipping.");
        return;
      }
      console.log("create image")
      if(typeof propsJson === "undefined"){
        var propsJson = {
          type: "image",
          'src': this.imgUrl,
          'position':{
            "position": "absolute",
            "left": (getScreenCenter()[0] - 150) + "px",
            "top": (getScreenCenter()[1] - 150) + "px",
            "width": 300 + "px",
            "height": 300 + "px",
            "background-color": "lightgray",
          }
        };
      }
      var object = createComponent(canvasFrame, myImage, propsJson);
      object.$on('respond', this.getForcusedChild);
      object.$on('requestAddMemory', this.addMemory);
      object.$on('requestSend', this.sendObject);
      object.$on('requestDelete', this.requestDelete);
      return object;
    },
    getForcusedChild(arg){
      console.log("isSameObject? :" ,this.forcusedChild === arg)
      if (this.forcusedChild === arg){
        this.forcusedChild.activate();
        return;
      }
      // 違うオブジェクトをクリックしたら切り替える
      this.deactivateFocused()
      this.sendObject([arg], "lock");
      this.isMouseUpFromObjectSelected = false;
      // サーバーに任せる
      //this.forcusedChild = arg;
    },
    drawFriendObj(){
      // straight, rectangle, myCircle
      tmpInstance.x2 = realX;
      tmpInstance.y2 = realY;
    },
    drawFreeHand(isEnd){
      tmpInstance.appendPath(realX, realY, isEnd);
    },
    /* グループ選択処理 */
    displaySelectionBox(x1,y1,x2,y2,isInitial){
      var minX = Math.min(x1,x2);
      var minY = Math.min(y1,y2);
      var width = Math.abs(x1 - x2);
      var height = Math.abs(y1 - y2);
      var propsJson = {
        'position':{
          "position": "absolute",
          "left": minX + "px",
          "top": minY + "px",
          "width": width + "px",
          "height": height + "px"
        },
      };
      if(isInitial){
        selBox = createComponent(canvasFrame, selectionBox, propsJson);
        selBox.$on('setPivotPositions', this.setPivotPositions);
        selBox.$on('moveSelections', this.moveSelections);
        selBox.$on('setPivotObjectSizes', this.setPivotObjectSizes);
        selBox.$on('transformShapes', this.transformShapes);
        selBox.$on('resetButtonPositions', this.resetButtonPositions);
        selBox.$on('deleteSelections', this.deleteSelections);
      }
      else{
        selBox.position = propsJson["position"];
      }
    },
    selectInRectangle(x1,y1,x2,y2){
      var rect = selBox.$el;
      var minX = rect.offsetLeft
      var minY = rect.offsetTop
      var width = rect.offsetWidth;
      var height = rect.offsetHeight;
      var selectedCount = 0;
      selectionList = [];
      this.objectMemory.forEach(obj => {
        var el = obj["body"].$el;
        /* --- 図形を全て囲んだら選択（PowerPoint方式）--- */
        // if(
        //   (el.offsetLeft + selectionMargin) > minX &&
        //   (el.offsetTop + selectionMargin) > minY &&
        //   (el.offsetLeft + el.offsetWidth - selectionMargin) < (minX + width) &&
        //   (el.offsetTop + el.offsetHeight - selectionMargin) < (minY + height))
        //   {
        //     selectedCount++;
        //     selectionList.push(obj["body"]);
        //   }
        /* --- 図形を一部でも含んだら選択（PhotoShop方式）--- */
        if(
          (el.offsetLeft + selectionMargin) < (minX + width) && 
          (el.offsetLeft + el.offsetWidth - selectionMargin) > minX &&
          (el.offsetTop + selectionMargin) < (minY + height) && 
          (el.offsetTop + el.offsetHeight - selectionMargin) > minY )
          {
            selectedCount++;
            selectionList.push(obj["body"]);
          }
      });
      return selectedCount;
    },
    fitSelectionBox(){
      let minx = Infinity;
      let maxx = 0;
      let miny = Infinity;
      let maxy = 0;
      selectionList.forEach(sel => {
        var el = sel.$el;
        minx = minx < el.offsetLeft ? minx : el.offsetLeft;
        maxx = maxx > (el.offsetLeft + el.offsetWidth) ? maxx : (el.offsetLeft + el.offsetWidth);
        miny = miny < el.offsetTop ? miny : el.offsetTop;
        maxy = maxy > (el.offsetTop + el.offsetHeight) ? maxy : (el.offsetTop + el.offsetHeight);
      });
      selBox.position.left = minx + "px";
      selBox.position.width = (maxx - minx) + "px";
      selBox.position.top = miny + "px";
      selBox.position.height = (maxy - miny) + "px";
    },
    /* --- オブジェクトのグループ移動 --- */
    setPivotPositions(e, selectionBox){
      resetPivotPosition(e);
      selectionList.forEach(obj => {
        obj.setPivotPosition();
      });
      selectionBox.setPivotPosition();
    },
    moveSelections(selectionBox){
      selectionList.forEach(obj => {
        obj.updatePosition(realX - realX0, realY - realY0);
      });
    },
    /* --- オブジェクトのグループ拡大 --- */
    setPivotObjectSizes(pivotLeft, pivotTop){
      this.pl = pivotLeft;
      this.pt = pivotTop;

      selectionList.forEach(obj => {
        obj.setPivotObjectSize();
      });
    },
    transformShapes(deltaX, deltaY, Kx ,Ky){
      selectionList.forEach(obj => {
        obj.transformShapeG(this.pl, this.pt, Kx ,Ky);
      });
    },
    resetButtonPositions(){
      selectionList.forEach(obj => {
        obj.resetButtonPosition();
      });
    },
    deleteSelections(){
      this.sendObject(selectionList, "delete");
      this.status = "waiting";
    },
    /* --- グループ選択解除 --- */
    clearSelection(){
      this.status = "waiting";
      destroyComponent(selBox);
      selectionList.forEach(obj => {
        obj.deactivate();
      });
      this.sendObject(selectionList, "unlock");
      selBox = "";
    },
    /* わずかな動作を除外 */
    isSlightMouseMove(){
      // 曲線描画時
      if(this.mode === "draw" && this.objectType === "freeHand"){
        console.log(mouseDragCount, "dragcount");
        return mouseDragCount < thresMouseDragCount ? true : false;
      }
      // それ以外の図形
      var mouseMovePx = Math.sqrt(
        (drawStartCordinate[0]-realX)**2 
        + (drawStartCordinate[1]-realY)**2 
      );
      if(mouseMovePx < ignoreMovePx){
        console.log(mouseMovePx, "It's slight move");
        return true;
      }
      return false;
    },
    /* 移動の確定処理 */
    confirmMoving(permitUpdate){
      if(typeof this.forcusedChild.move !== "undefined"){
        this.forcusedChild.isDrag = false;
      }
      if(this.isSlightMouseMove() || !permitUpdate){
        return;
      }
      if(this.mode === "manipulate" && this.status === "selected"){
        selBox.resetButtonPosition();
        this.sendObject(selectionList, "update");
        return;
      }
      // 図形の単体操作の場合
      this.forcusedChild.resetButtonPosition();
      this.sendObject([this.forcusedChild], "update");
    },
    addMemory(object){
      // ToDo: ObjIDの双方向管理
      // 不完全
      if(typeof object.objId === "undefined"){
        object.objId = this.objId;
        object.globalId = null; 
        object.userId = this.userId;
        object.status = "unlock";
        object.position["z-index"] = "";
      }
      this.objId = parseInt(object.objId)　+ 1;
      object.changeBorderStyle(this.userId);

      var dict = {"body": object};
      console.log(dict)
      this.objectMemory.push(dict);
    },
    requestDelete(object){
      this.sendObject([object], "delete");
      if(typeof this.forcusedChild.deactivate !== "undefined"){
        this.forcusedChild.deactivate();
        this.forcusedChild = "";
      }
      //destroyComponent(object);
    },
    deactivateFocused(){
      if(typeof this.forcusedChild.deactivate !== "undefined"){
        this.forcusedChild.deactivate();
        this.sendObject([this.forcusedChild], "unlock");
        this.forcusedChild = "";
      }
    },
    touchDelete(inst){
      this.touchDeleteInstance = inst;
    },
    /* --- action cable --- */
    sendObject(objectArr, action){
      var dataArr = [];
      console.log(action);
      objectArr.forEach(object => {
        dataArr.push(this._jsonfyObject(object, action));
      });
      var data = {"action": action, "clientId": this.userId, "dataArr": dataArr}
      this.$emit("sendObject", data); // ---> board_edit.vue
    },

    _jsonfyObject(object, action){
      if(object.globalId == null && action !== "create"){
        //alert("Tried to send null globalId object!");
        //destroyComponent(object); //Debug
        return;
      }
      object.userId = this.userId; // 使用者を更新
      var body = JSON.parse(JSON.stringify(object.$props));
      body.position.top = this._roundPx(body.position.top);
      body.position.left = this._roundPx(body.position.left);
      body.position.height = this._roundPx(body.position.height);
      body.position.width = this._roundPx(body.position.width);
      return {"body": body};
    },
    _roundPx(str){
      try{
        var val = parseFloat(str.split("px")[0]) 
        val = Math.round(val * 100) / 100;
        return val.toString() + "px";
      }catch{
        return str;
      }
    },

    createObject(body){
      var type = body["type"]
      console.log("type ", type, "body ", body)
      var obj;

      if(friendArr.includes(type)){
        obj = this.createFriendObj(body, type);
      }
      else if(type === "freeHand"){
        obj = this.createFreeHand(body);
      }
      else if(type === "string"){
        obj = this.createString(body);
      }
      else if(type === "image"){
        obj = this.createImage(body);
      }
      else{
        throw "error: json not matches any object type!" + type;
      }
      this.addMemory(obj);
    },
    setGlobalId(body){
      var objId = body["objId"];
      var globalId = body["globalId"];

      this.objectMemory.forEach(record => {
        var object = record["body"];
        if(object.objId === objId){
          if(object.globalId !== null){
            throw 'globalId is NOT null! :' + object.globalId;
          }
          object.globalId = globalId;
          console.log("Update globalId:", object.globalId)
          return;
        }
      });
    },
    reject(){
      console.log("rejected");
      this.status = "waiting";
      destroyComponent(selBox);
      selBox = "";
    },
    flushAll(){
      this.deactivateAll();
      
      this.objectMemory.forEach(record => {
        destroyComponent(record["body"]);
      });
      this.objectMemory = [];
      this.status = "waiting";
      console.log(this.objectMemory);
    },
    deactivateAll(){
      this.deactivateFocused();
      if(this.mode === "manipulate" && this.status === "selected"){
        this.clearSelection();
      }
    },
    findAndAction(jsonStr, action){
      var body      = jsonStr["body"];
      var globalId  = jsonStr["body"]["globalId"];
      var isFound = false;

      this.objectMemory.forEach((record, idx) => {
        if(record["body"].globalId === globalId){
          console.log(action, "from remote gId:", globalId);
          this._actionToObj(action, body, record["body"]);
          if(action === "delete"){
            // ToDo: 暫定(もっとスマートなやり方があれば)
            this.objectMemory.splice(idx, 1);
          }
          isFound = true;
          return;
        }
      });

      if(!isFound){
        console.log("Incoming New Object");
        this.createObject(jsonStr["body"]);
      }
    },
    _actionToObj(action, body, localObject){
      if(action === "delete"){
        destroyComponent(localObject);
        return;
      }
      
      if(action === "lock"){
        // pass
      }
      if(action === "activate"){
        // グループ選択時
        if(this.status === "selected"){
          // pass
          // 各オブジェクトのz-indexを変更する必要はない
        }
        // 単体選択時
        else{
          this.forcusedChild = localObject;
          this.forcusedChild.activate();
          if(!this.isPrivate && this.isMouseUpFromObjectSelected){
            this.forcusedChild.isDrag = false;
          }
        }
      }
      if(action === "unlock"){
        localObject.deactivate();
      }
      if(action === "update"){
        // propsに指定した変数の値を順に代入する
        Object.keys(body).forEach(key=>{
          localObject[key] = body[key];
        })
      }
      if(action === "revive"){
        console.log(body)
        this.createObject(body);
      }
      // オブジェクトのボーダー表示を変える
      localObject.userId = body.userId;
      localObject.status = body.status;
      localObject.changeBorderStyle(this.userId);
      return;
    },
  },
  mounted: function(){
    canvasFrame = this.$refs.frame;
    this.windowWidth = window.innerWidth;
    this.windowHeight =  window.innerHeight;
    isObjBtPressed = document.getElementById("isButtonOnObjectPressed");

    window.addEventListener('blur', () => {
      // string編集中のfocuseoutイベントを待つため待機
      setTimeout(this.deactivateAll,100);
    });

    window.addEventListener('beforeunload', (e) => {
    this.deactivateAll();
      if(this.isPrivate){ 
        e.returnValue = "編集内容が消去されますがよろしいですか？";
      }
    });
  }
}

function getMousePosition(e){
  // =>ボード左上基準
  var clientRect = canvasFrame.getBoundingClientRect();
  canvasX = clientRect.left + borderOffset;
  canvasY = clientRect.top + borderOffset;
  realX = e.clientX - canvasX;
  realY = e.clientY - canvasY;
  percentX = 100 * realX / canvasFrame.offsetWidth;
  percentY = 100 * realY / canvasFrame.offsetHeight;
}

function resetPivotPosition(e){
  getMousePosition(e)
  realX0 = realX;
  realY0 = realY;
  percentX0 = percentX;
  percentY0 = percentY;
  drawStartCordinate = [realX, realY];
  mouseDragCount = 0;
}

function getScreenCenter(){
  let canvasRect = document.getElementById("frame").getBoundingClientRect();
  let screenRect = document.getElementById("display-area").getBoundingClientRect();
  let screenOffsetX = screenRect.left - canvasRect.left;
  let screenOffsetY = screenRect.top - canvasRect.top;
  let screenCenter = [0.5 * screenRect.width + screenOffsetX,
                        0.5 * screenRect.height + screenOffsetY];
  return screenCenter;
}

function rotate(arr, data){
  arr.shift();
  arr.push(data);
}

function createComponent(dom, module, propsJson){
  var component = Vue.extend(module);
  var instance = new component({
    propsData: propsJson
  });
  attach(instance,dom);
  
  return instance;
}

function attach(instance,dom){
  instance.$mount();
  dom.append(instance.$el);
}

function destroyComponent(inst){
  try{
    inst.$destroy();
    inst.$el.parentNode.removeChild(inst.$el);
  }
  catch(err){
    //console.log(err);
    console.log("Failed to destroyComponent()");
  }
}

function isButtonOnObjPressed(){
  // オブジェクト上のボタンが押下されているか確認
  if(isObjBtPressed.value === "true"){
    return true;
  }else{
    return false;
  }
}
</script>


<style scoped lang="scss">
p {
  font-size: 2em;
  text-align: center;
}

div {
  //border: solid 1px gray;
  box-sizing: content-box;
    -moz-box-sizing: content-box;
    -webkit-box-sizing: content-box;
    -o-box-sizing: content-box;
    -ms-box-sizing: content-box;
}

#debug-container{
  position: absolute;
}

#canvas-root  {
  position: relative;
  width:100%; /* ToDo: javaScript */
  height:100%;
}

#display-area  {
  /* 上下左右中央 このページの#5 */
  /* https://www.granfairs.com/blog/staff/centering-by-css */
  position: absolute;
  width:95%;
  height:95%;
  top: 0;
  right: 0;
  bottom: 0;
  left: 0;
  margin:auto;
  border: solid 3px darkgray;
  border-radius: 3px;
  overflow: scroll;
  background-color: gray;
}

#frame  {
  $gridPx: 28px;
  position: relative;
  width:1200px;
  height:800px;
  top: 0;
  right: 0;
  bottom: 0;
  left: 0;
  margin:auto;
  background-color: white;
  background-image: linear-gradient( transparent 97%, rgba(0, 0, 0, .06) 50%, rgba(0, 0, 0, .06)),
                    linear-gradient( 90deg, transparent 97%, rgba(0, 0, 0, .06) 50%, rgba(0, 0, 0, .06) );
  background-size: $gridPx $gridPx;
  background-repeat: repeat;
}

@media (max-width:720px){
}

@media (min-width:720px){
}
</style>
