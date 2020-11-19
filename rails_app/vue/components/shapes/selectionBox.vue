<template>
  <div ref="objectRoot" id="selection" :style="position" :class="activeClass"
      v-on:mousedown="onMouseDown"
      v-on:mousemove=""
      v-on:mouseup="">
    
    <div id="selection" class="drag-area"></div>
    <div v-if="isActive" class="button-container">
      <clicks id="selection" roll="delete"
          :position="defaultButtonPosition"
          v-on:action="deleteGroup" >
      </clicks>
    </div>

    <expantion id="selection" v-if="isActive"
        :position="expantionButtonPosition1"
        v-on:expandStart="setPivotObjectSize"
        v-on:expand="" 
        v-on:expandEnd="">
    </expantion>
    <expantion id="selection" v-if="isActive"
        :position="expantionButtonPosition2"
        v-on:expandStart="setPivotObjectSize"
        v-on:expand="" 
        v-on:expandEnd="">
    </expantion>
  </div>
</template>

<script>
const minAreaPx = 20; //px

import expantion from "./button-expantion.vue"
import clicks from "./button-click.vue"

export default {
  components: {
    clicks,
    expantion
  },
  props: ["position"],
  data: function () {
    return {
      activeClass: "activeClass", 
      isActive: false,
      isDrag: false,
      isExpand: false,
      defaultButtonPosition: {
        "top": "",
        "left": "",
        "height": "30px",
        "width": "30px",
      },
      expantionButtonPosition1: {
        "position": "absolute",
        "top": "",
        "left": "",
        "height": "30px",
        "width": "30px",
      },
      expantionButtonPosition2: {
        "position": "absolute",
        "top": "",
        "left": "",
        "height": "30px",
        "width": "30px",
      },
    }
  },
  methods: {
    onMouseDown(e){
      var frame = document.getElementById("frame");
      var mode = frame.getAttribute("mode");
      if(mode === "manipulate" && !this.isExpand){
        this.$emit("setPivotPositions", e, this);
        this.isDrag = true;
      }
    },
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
      this.$emit("moveSelections", this);
    },
    /* ---図形の拡大・縮小処理--- */
    setPivotObjectSize(){
      this.setPivotPosition();
      this.isDrag = false;
      this.isExpand = true;
      this.$emit("setPivotObjectSizes", this.pivotLeft, this.pivotTop);
    },
    transformShape(deltaX, deltaY){
      var newWidth = (this.pivotWidth + deltaX) < minAreaPx ? minAreaPx : (this.pivotWidth + deltaX);
      var newHeight = (this.pivotHeight + deltaY) < minAreaPx ? minAreaPx : (this.pivotHeight + deltaY);
      var Kx = newWidth / this.pivotWidth;
      var Ky = newHeight / this.pivotHeight;
      this.position.width = newWidth + "px";
      this.position.height = newHeight + "px";
      this.$emit("transformShapes", deltaX, deltaY ,Kx ,Ky);
    },
    resetButtonPosition(){
      this.isActive = true; // selectionBox限定の処理
      this.isDrag = false;
      this.isExpand = false;
      var rootDiv = this.$refs.objectRoot;

      // 拡大ボタン1(左下)
      var buttonHeight1 = parseFloat(this.expantionButtonPosition1.height.split("px")[0]);
      var buttonWidth1 = parseFloat(this.expantionButtonPosition1.width.split("px")[0]);
      this.expantionButtonPosition1.top = (rootDiv.offsetHeight - 0.5 * buttonHeight1) + "px";
      this.expantionButtonPosition1.left= (/*rootDiv.offsetWidth*/ - 0.5 * buttonWidth1) + "px";
      // 拡大ボタン2(右下)
      var buttonHeight2 = parseFloat(this.expantionButtonPosition2.height.split("px")[0]);
      var buttonWidth2 = parseFloat(this.expantionButtonPosition2.width.split("px")[0]);
      this.expantionButtonPosition2.top = (rootDiv.offsetHeight - 0.5 * buttonHeight2) + "px";
      this.expantionButtonPosition2.left= (rootDiv.offsetWidth - 0.5 * buttonWidth2) + "px";
      this.$emit("resetButtonPositions");
    },
    deleteGroup(){
      this.$emit('deleteSelections');
      this.deleteSelf();

    },
    deleteSelf(){
      this.$destroy();
      this.$el.parentNode.removeChild(this.$el);
    },
  },
  mounted: function(){
  }
}


</script>

<style scoped lang="scss">
#selection{
  & *{
    user-select: none;
    -moz-user-select: none;
    -webkit-user-select: none;
    -ms-user-select: none;
  }
}


p {
  font-size: 2em;
  text-align: center;
  }

svg{
  position: absolute;
}

.activeClass{
  border: dotted 2px transparent; 
}

.passiveClass{
  border: dotted 2px transparent; 
}

.drag-area{
  position:absolute;
  width:100%;
  height: 100%;
  background-color: rgb(75, 170, 77);
  opacity: 0.3;
}

.button-container{
  position: absolute;
  display:flex;
  flex-direction: row;
  top:-30px;
  height:30px;
  left: -5px;
}
</style>
