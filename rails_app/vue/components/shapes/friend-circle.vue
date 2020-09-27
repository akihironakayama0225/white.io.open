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
      <ellipse ref="line"
        :transform="'translate('+ 0.5*(x1+x2) + ' ' + 0.5*(y1+y2) + ')'"
        :rx="0.5*Math.abs(x2-x1)" :ry="0.5*Math.abs(y2-y1)"
        fill="none" :stroke="lineColor" :stroke-width="lineWidth">
      </ellipse>
    </svg>

    <expantion v-if="isActive"
        :position="expantionButtonPosition"
        v-on:expandStart="setPivotObjectSize">
    </expantion>
  </div>
</template>

<script>
const minAreaPx = 5; //px 縮小時の最小ピクセル
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
      var el = document.getElementById("frame");
      // キャンバス左上からの座標を取得
      var data = line.getBoundingClientRect();
      var framerect = el.getBoundingClientRect();
      var offX = data["left"] - canvasX - rectPadding + this.borderOffset;
      var offY = data["top"] - canvasY - rectPadding + this.borderOffset;
      var wid = data["width"]  + rectPadding;
      var hig = data["height"] + rectPadding;
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
      //console.log("HAGE! ",this.$props);
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
  left: -5px;
}
</style>
