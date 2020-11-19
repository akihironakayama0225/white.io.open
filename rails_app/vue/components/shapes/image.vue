<template>
  <div ref="objectRoot" id="image-root" :style="position" class="image">
    
    <div v-show="isShow" v-on:mousedown="onMouseDown" id="image-container">
      <img :src="src" v-on:load="onImgLoad"/>
      <div class="image" id="screen" />
    </div>
    
    <div v-if="isActive" class="button-container">
      <clicks class="image" roll="delete"
        :position="defaultButtonPosition"
        v-on:action="requestDelete" >
      </clicks>
    </div>

    <expantion v-if="isActive" class="image"
        :position="expantionButtonPosition"
        v-on:expandStart="setPivotObjectSize">
    </expantion>
  </div>
</template>


<script>
const minAreaPx = 5; //px 縮小時の最小ピクセル
const imgSize = 250; //px
let expandStartX;
let expandStartY;

import expantion from "./button-expantion.vue"
import clicks from "./button-click.vue"

export default {
  components: {
    expantion,
    clicks
  },
  props: ['globalId', 'userId', 'objId', 'type', 'status', 'position', 'src'],
  data: function () {
    return {
      isShow: false,
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
    }
  },
  methods: {
    onImgLoad(){
      this.isShow = true;
      this.position["background-color"] = "transparent";
    },
    onMouseDown(){
      console.log("mouse image down")
      var frame = document.getElementById("frame");
      var mode = frame.getAttribute("mode");
      if(mode === "manipulate"){
        //this.activate();
        this.resetButtonPosition();
        this.setPivotPosition();
        this.$emit('respond', this);
      }
    },

    activate(){
      this.$el.style.border = this.activeBorder;
      this.isActive = true;
      this.isSelected = true;
      this.isDrag = true;
      this.position["z-index"] = 9000;
    },
    deactivate(){
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
      this.pivotWidth = parseFloat(this.position.width.split("px")[0]);
      this.pivotHeight = parseFloat(this.position.height.split("px")[0]);
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
    },
    transformShape(deltaX, deltaY){
      var newWidth = (this.pivotWidth + deltaX) < minAreaPx ? minAreaPx : (this.pivotWidth + deltaX);
      var newHeight = (this.pivotHeight + deltaY) < minAreaPx ? minAreaPx : (this.pivotHeight + deltaY);
      this.position.width = newWidth + "px";
      this.position.height = newHeight + "px";
    },
    // グループ拡大時に使用
    transformShapeG(selectionLeft, selectionTop, Kx, Ky){
      var newSize = 1 * 0.5*(Kx + Ky);
      var newWidth =  Kx * this.pivotWidth;
      var newHeight = Ky * this.pivotHeight;
      this.position.width = newWidth + "px";
      this.position.height = newHeight + "px";

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
      this.expantionButtonPosition.left= (rootDiv.offsetWidth - 0.5 * buttonWidth) + "px";
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
    setImgSize(){
      var that = this;
      var element = new Image() ;
      element.onload = function () {
        var width = element.naturalWidth ;
        var height = element.naturalHeight ;
        var ratio = height/width;
        console.log(width, height,ratio);
        if(ratio > 1){
          height = imgSize;
          width = height / ratio;
        }
        else{
          width = imgSize;
          height = width * ratio;
        }
        that.updateSize(width, height);
        that.$emit('requestAddMemory', that);
        that.$emit('requestSend', [that], "create");
      }
      element.src = this.src ;
    },
    updateSize(width, height){
        this.position.width = width + "px";
        this.position.height = height + "px";
    }
  },
  mounted: function(){
    if(this.globalId != null){
      return;
    }
    this.$nextTick(function () {
      this.setImgSize();
    });
  }
}
</script>


<style scoped lang="scss">
p {
    text-align: center;
    line-height: 1.0;
    padding:5px;
}

.button-container{
  position: absolute;
  display:flex;
  flex-direction: row;
  top:-30px;
  height:30px;
  left: -5px;
}

#image-root{
  & *{
    user-select: none;
    -moz-user-select: none;
    -webkit-user-select: none;
    -ms-user-select: none;
  }
  
  #image-container{
    position:relative;
    width:100%;
    height:100%;

    img{
      position: absolute;
      width: calc(100% - 1px);
      height: calc(100% - 1px);
      top: -0.5px;
      left: -0.5px;
      border: solid 1px lightgray;
    }
    #screen{
      position:absolute;
      background-color:transparent;
      width:100%;
      height:100%;
    }
  }
}
</style>
