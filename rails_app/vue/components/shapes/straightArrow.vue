<template>
  <div ref="objectRoot" :style="position"
    v-on:mousedown="divOnMouseDown">
    <div v-if="isActive" class="button-container">
      <clicks roll="delete"
        :position="defaultButtonPosition"
        v-on:action="requestDelete" >
      </clicks>
    </div>

    <svg ref="svg" id="svg" viewbox="0% 0% 100% 100%" width="100%" height="100%">
      <line ref="line" 
        :x1="x1" :y1="y1" :x2="x2" :y2="y2"
        :stroke-width="lineWidth" :stroke="lineColor">
      </line>
      <polygon ref="arrowHead"
        :points="x2 + ' ' + y2  + ', ' + (x2 - headSize) + ' ' + (y2 + headSize) + ', ' + (x2 + headSize) + ' ' + (y2 + headSize)"
        :transform="'rotate(' + rotateArrowHead() + ', ' + x2 + ', ' + y2 + ')'"
        :fill="lineColor">
      </polygon>
    </svg>

    <expantion v-if="isActive"
        :position="expantionButtonPosition"
        v-on:expandStart="setPivotObjectSize">
    </expantion>
  </div>
</template>

<script>
const minAreaPx = 20; //px 縮小時の最小ピクセル
const rectPadding = 10; // pathを囲うdivのpadding

import expantion from "./button-expantion.vue"
import clicks from "./button-click.vue"

export default {
  components: {
    clicks,
    expantion
  },
  props: ['globalId', 'userId', 'objId', 'type', 'status', 'position', 'lineWidth', 'lineColor', 'x1', 'y1', 'x2', 'y2'],
  data: function () {
    return {
      /*position: {
        position:"absolute",
        top: "",
        left: "",
        width: "100%",
        height: "100%",
        border: "",
      },*/
      isActive: false,
      isSelected: false,
      isDrag: false,
      isExpand: false,
      activeClass: "activeClass", 
      passiveClass: "passiveClass",
      activeBorder: "dotted 2px rgb(75, 170, 77)",
      passiveBorder: "dotted 2px transparent",
      lockedBorder: "dashed 2px purple",
      borderOffset: 2, //px :この図形を囲むborder幅を指定
      headSize: 10,

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
      pivotX1: "",
      pivotY1: "",
      pivotX2: "",
      pivotY2: "",
    }
  },
  methods: {
    divOnMouseDown(){
      var frame = document.getElementById("frame");
      var mode = frame.getAttribute("mode");
      if(mode === "manipulate" && !this.isExpand){
        //this.activate();
        this.resetButtonPosition();
        this.setPivotPosition();
        this.$emit('respond', this);
      }
    },
    rotateArrowHead(){
      var radian = Math.atan2(this.y2 - this.y1,this.x2 - this.x1);
      return radian / Math.PI * 180 + 90;
    },
    move(offsetX, offsetY){
      if(this.isDrag){
        this.updatePosition(offsetX, offsetY);
      }else if(this.isExpand){
        this.transformShape(offsetX, offsetY);
      }
    },
    activate(){
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
    fitBounding(canvasX, canvasY){
      var line = this.$refs.line;
      var head = this.$refs.arrowHead;
      var el = document.getElementById("frame");
      // キャンバス左上からの座標を取得
      var data = line.getBoundingClientRect();
      var headData = head.getBoundingClientRect();
      var framerect = el.getBoundingClientRect();

      var minX = data["left"] - 0.5 * this.headSize;
      var minY = data["top"] - 0.5 * this.headSize;
      var maxW = data["width"] + this.headSize;
      var maxH = data["height"] + this.headSize;

      var offX = minX - canvasX - rectPadding + this.borderOffset;
      var offY = minY - canvasY - rectPadding + this.borderOffset;
      var wid = maxW  + rectPadding;
      var hig = maxH + rectPadding;
      //console.log(data);
      
      this.x1 -= offX 
      this.y1 -= offY 
      this.x2 -= offX
      this.y2 -= offY

      // Update div position      
      this.position.top = offY + "px";
      this.position.left = offX + "px";
      this.position.width = wid + "px";
      this.position.height = hig + "px";
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
    /* ---図形の拡大・縮小処理--- */
    setPivotObjectSize(){
      this.setPivotPosition();
      this.isDrag = false;
      this.isExpand = true;
      this.pivotX1 = this.x1;
      this.pivotY1 = this.y1;
      this.pivotX2 = this.x2;
      this.pivotY2 = this.y2;
    },
    transformShape(deltaX, deltaY){
      var newWidth = (this.pivotWidth + deltaX) < minAreaPx ? minAreaPx : (this.pivotWidth + deltaX);
      var newHeight = (this.pivotHeight + deltaY) < minAreaPx ? minAreaPx : (this.pivotHeight + deltaY);
      this.position.width = newWidth + "px";
      this.position.height = newHeight + "px";
      this.expandStraight(
                      newWidth / this.pivotWidth,
                      newHeight / this.pivotHeight
                      );
      this.adjustBoundingRect(newWidth, newHeight);
    },
    // グループ拡大時に使用
    transformShapeG(selectionLeft, selectionTop, Kx, Ky){
      var newWidth =  Kx * this.pivotWidth;
      var newHeight = Ky * this.pivotHeight;
      this.position.width = newWidth + "px";
      this.position.height = newHeight + "px";
      this.expandStraight(
                      newWidth / this.pivotWidth,
                      newHeight / this.pivotHeight
                      );
      this.updatePosition(
                  (Kx-1) * (this.pivotLeft - selectionLeft), 
                  (Ky-1) * (this.pivotTop - selectionTop)
                  );
      this.adjustBoundingRectG(newWidth, newHeight);
      //ToDo: グループ操作時のフィッティング
    },
    adjustBoundingRect(newWidth, newHeight){
      var constWidth = minAreaPx + 2*this.headSize + rectPadding + this.borderOffset;
      var constHeight= minAreaPx + 2*this.headSize + rectPadding + this.borderOffset;

      if(newWidth < constWidth){
        var difWidth = constWidth - newWidth;
        this.position.width = constWidth + "px"
        this.position.left = (this.pivotLeft - 0.5 * difWidth) + "px"
        this.x1 += 0.5 * difWidth;
        this.x2 += 0.5 * difWidth;
      }
      if(newHeight < constHeight){
        var diffHeight = constHeight - newHeight;
        this.position.height = constHeight + "px";
        this.position.top = (this.pivotTop - 0.5 * diffHeight) + "px"
        this.y1 += 0.5 * diffHeight;
        this.y2 += 0.5 * diffHeight;
      }
    },
    adjustBoundingRectG(newWidth, newHeight){
      var constWidth = minAreaPx + this.headSize + rectPadding + this.borderOffset;
      var constHeight= minAreaPx + this.headSize + rectPadding + this.borderOffset;

      if(newWidth < constWidth){
        var difWidth = constWidth - newWidth;
        this.position.width = constWidth + "px"
        this.position.left = (parseFloat(this.position.left.split("px")[0]) - 0.5 * difWidth) + "px"
        this.x1 += 0.5 * difWidth;
        this.x2 += 0.5 * difWidth;
      }
      if(newHeight < constHeight){
        var diffHeight = constHeight - newHeight;
        this.position.height = constHeight + "px";
        this.position.top = (parseFloat(this.position.top.split("px")[0]) - 0.5 * diffHeight) + "px"
        this.y1 += 0.5 * diffHeight;
        this.y2 += 0.5 * diffHeight;
      }
    },
    resetButtonPosition(){
      this.isExpand = false;
      var rootDiv = this.$refs.objectRoot;
      var buttonHeight = parseFloat(this.expantionButtonPosition.height.split("px")[0]);
      var buttonWidth = parseFloat(this.expantionButtonPosition.width.split("px")[0]);
      this.expantionButtonPosition.top = (rootDiv.offsetHeight - 0.5 * buttonHeight) + "px";
      this.expantionButtonPosition.left= (rootDiv.offsetWidth - 0.5 * buttonWidth) + "px";
    },
    expandStraight(Kx, Ky){
      this.x1 = Kx * this.pivotX1;
      this.x2 = Kx * this.pivotX2;
      this.y1 = Ky * this.pivotY1;
      this.y2 = Ky * this.pivotY2;
    },
    //deleteSelf(){
    //  this.$destroy();
    //  this.$el.parentNode.removeChild(this.$el);
    //},
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
    mounted: function(){
    }
  }
}

// private:
function slidePath(pathStr, offsetX, offsetY){
  // もともとのPathを空白文字でsplitする
  // x座標, y座標それぞれを平行移動する
  var transFormedArr = [];
  var pathArr = pathStr.split(/\s+/);
  var chainCount = 0;
  pathArr.forEach(data => {
    if(isNaN(data)){ // 文字の場合(S, C, Mなど)
      transFormedArr.push(data);
      chainCount = 0;
      return;
    }
    if(chainCount % 2 === 0){ // x座標の場合
      transFormedArr.push(Math.round((data - offsetX)* 100) / 100);
    }
    else{ // y座標の場合
      transFormedArr.push(Math.round((data - offsetY)* 100) / 100);
    }
    chainCount++;
  });

  // Update path
  var tmpPath = "";
  transFormedArr.forEach(data => {
    console.log(data);
    tmpPath += data + " ";
  });
  return tmpPath;
}
</script>

<style scoped lang="scss">
p {
  font-size: 2em;
  text-align: center;
  }

svg{
  position: absolute;
}

.button-container{
  position: absolute;
  display:flex;
  flex-direction: row;
  top:-30px;
  height:30px;
  right:0;
}
</style>
