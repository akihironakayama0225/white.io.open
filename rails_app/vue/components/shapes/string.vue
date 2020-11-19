<template>
  <div ref="objectRoot" id="string-root" :style="position" v-on:focusout="confirm">
    
    <div v-if="isEditing" id="text-edit">
      <input ref="text" id="text" class="string" v-on:keydown="onKeyDown"
        type="text" placeholder="　[Enter] to confirm." autocomplete="off" 
        :style="inputStyle"/>
    </div>
    <div v-else>
      <p class="string" v-on:mousedown="onMouseDown" :style="fontStyle">{{content}}</p>
    </div>

    <div v-if="isActive" class="button-container">
      <clicks class="string" roll="delete"
        :position="defaultButtonPosition"
        v-on:action="requestDelete">
      </clicks>
      <clicks class="string" roll="edit"
          :position="defaultButtonPosition"
          v-on:action="edit">
      </clicks>
    </div>

    <expantion v-if="isActive && !isEditing" class="string"
        :position="expantionButtonPosition"
        v-on:expandStart="setPivotObjectSize"
        v-on:expand="" 
        v-on:expandEnd="">
    </expantion>
  </div>
</template>


<script>
const minFontSize = 10; // 最小フォント
const ratioMouseMove2expand = 0.3; //マウスの移動量とフォントの拡大pxの比
let expandStartX;
let expandStartY;

import expantion from "./button-expantion.vue"
import clicks from "./button-click.vue"

export default {
  components: {
    expantion,
    clicks
  },
  props: ['globalId', 'userId', 'objId', 'type', 'status', 'position', 'content', 'fontStyle'],
  data: function () {
    return {
      isEditing: false,
      isActive: false,
      isSelected: false,
      isDrag: false,
      isExpand: false,
      pivotLeft:"0px",
      pivotTop:"0px",
      activeClass: "activeClass", 
      passiveClass: "passiveClass",
      activeBorder: "dotted 2px rgb(75, 170, 77)",
      passiveBorder: "dotted 2px transparent",
      lockedBorder: "dashed 2px purple",
      inputStyle:{
        color: this.fontStyle.color,
      },
      
      defaultButtonPosition: {
        "top": "",
        "left": "",
        "height": "30px",
        "width": "30px",
      },
      expantionButtonPosition: {
        "position": "absolute",
        "top": "",
        "left": "",
        "height": "30px",
        "width": "30px",
      },
      pivotFontSize: "",
    }
  },
  methods: {
    onMouseDown(){
      var frame = document.getElementById("frame");
      var mode = frame.getAttribute("mode");
      if(mode === "write" || mode === "manipulate"){
        // this.activate();
        this.resetButtonPosition();
        this.setPivotPosition();
        this.$emit('respond', this);
      }
    },
    onKeyDown(e){
      var textBox = this.$refs.text;
      var fontSize = 14;
      textBox.style.width = (textBox.value.length + 1) * fontSize + "px";
      if(e.keyCode === 13){
        this.confirm();
      }
    },
    /* --- テキスト編集 --- */
    edit(){
      this.isEditing = true;
      this.isDrag = false;
      this.$nextTick(function () {
        this.$refs.text.value = this.content;
        this.$refs.text.select();
        this.$refs.text.focus();
      });
    },
    confirm(){
      if(this.$refs.text.value.length < 1){
        // 初回は未登録なので自分で消す
        if(typeof this.objId === "undefined"){
          this.deleteSelf();
        }
        this.requestDelete();
        return;
      }
      if(!this.isEditing){
        return;
      }
      this.content = this.$refs.text.value;
      //this.findURL(this.content);

      // 2回目以降の編集時は、requestAddしない
      if(typeof this.objId === "undefined"){
        this.$emit('requestAddMemory', this);
        this.$emit('requestSend', [this], "create");
      }else{
        this.$emit('requestSend', [this], "update");
      }
      this.$nextTick(function () {
        this.resetButtonPosition();
      });
      this.isEditing = false;
    },
    findURL(str){
      const regex_url = /https?:\/\/[^\s]*/g;
      let url_list = str.match(regex_url);
      console.log(url_list);
    },
    activate(){
      this.isActive = true;
      this.isSelected = true;
      this.isDrag = true;
      this.position["z-index"] = 9000;
    },
    deactivate(){
      this.isEditing = false;
      this.isActive = false;
      this.isSelected = false;
      this.isExpand = false;
      this.position["z-index"] = "";
    },
    /* --- 平行移動 --- */
    move(offsetX, offsetY){
      if(this.isDrag){
        this.updatePosition(offsetX, offsetY);
      }else if(this.isExpand){
        this.transformShape(offsetX, offsetY);
      }
    },
    setPivotPosition(){
      this.pivotLeft = parseFloat(this.position.left.split("px")[0]);
      this.pivotTop = parseFloat(this.position.top.split("px")[0]);
    },
    updatePosition(offsetX, offsetY){
      var newX = (this.pivotLeft + offsetX) + 'px';
      var newY = (this.pivotTop + offsetY) + 'px';
      this.$set(this.position, 'left', newX);
      this.$set(this.position, 'top', newY);
    },
    /* --- 拡大縮小 --- */
    setPivotObjectSize(){
      this.setPivotPosition();
      this.isExpand = true;
      this.pivotFontSize = parseFloat(this.fontStyle["font-size"].split("px")[0]);
    },
    transformShape(deltaX, deltaY){
      var newSize = this.pivotFontSize + ratioMouseMove2expand * (deltaX + deltaY);
      newSize = newSize < minFontSize ? minFontSize : newSize;
      this.$set(this.fontStyle, 'font-size', newSize + 'px'); 
    },
    // グループ拡大時に使用
    transformShapeG(selectionLeft, selectionTop, Kx, Ky){
      var newSize = this.pivotFontSize * 0.5*(Kx + Ky);
      newSize = newSize < minFontSize ? minFontSize : newSize;
      this.$set(this.fontStyle, 'font-size', newSize + 'px'); 

      this.updatePosition(
                  (Kx-1) * (this.pivotLeft - selectionLeft), 
                  (Ky-1) * (this.pivotTop - selectionTop)
                  );
    },
    resetButtonPosition(){
      this.isExpand = false;
      var rootDiv = this.$refs.objectRoot;
      var buttonHeight = parseFloat(this.expantionButtonPosition.height.split("px")[0]);
      var buttonWidth = parseFloat(this.expantionButtonPosition.width.split("px")[0]);
      this.expantionButtonPosition.top = (rootDiv.offsetHeight - 0.5 * buttonHeight) + "px";
      this.expantionButtonPosition.left= (/*rootDiv.offsetWidth*/ - 0.5 * buttonWidth) + "px";
    },
    deleteSelf(){
      this.$destroy();
      this.$el.parentNode.removeChild(this.$el);
    },
    requestDelete(){
      this.$emit('requestDelete', this);
    },
    changeBorderStyle(userId){
      if(this.status === "unlock"){
        this.$el.style.border = this.passiveBorder;
        return;
      }
      if(userId === this.userId){
        this.$el.style.border = this.activeBorder;
        return;
      }
      this.$el.style.border = this.lockedBorder;
    },
  },
  mounted: function(){
    this.$nextTick(function () {
    });
  }
}
</script>


<style scoped lang="scss">
#string-root{
  user-select: none;
  -moz-user-select: none;
  -webkit-user-select: none;
  -ms-user-select: none;
}

p {
  text-align: center;
  line-height: 1.0;
  padding:5px;
  user-select: none;
  -moz-user-select: none;
  -webkit-user-select: none;
  -ms-user-select: none;
}

#text-edit{
  display: flex;
  flex-direction: row;
  text-align: center;
  padding:5px;
  border: solid 1px gray;
}

#text{
  margin: 1px;
  font-size: 13px;
}

.button-container{
  position: absolute;
  display:flex;
  flex-direction: row;
  top:-30px;
  height:30px;
  left:-5px;
}
</style>
