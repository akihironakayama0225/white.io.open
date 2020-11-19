<template>
  <!-- 2次path d="M 終点座標 Q ハンドル点 始点座標" -->
  <!-- 3次path d="M 終点座標 C ハンドル点1 ハンドル点2 S 次のハンドル点2" -->
  <!-- S (sequenceモード）の場合、一続きの曲線が書ける。 Sオプションでは、 Cオプションの前方2つの引数を省略できる　-->
  <!--  <path d="M100 100 C 108.33333333333333, 100, 141.66666666666666, 91.66666666666667, 150, 100
  S 141.66666666666666, 141.66666666666666, 150, 150
  S 191.66666666666666, 141.66666666666666, 200, 150
  S 191.66666666666666, 191.66666666666666, 200, 200
  S 250, 200, 250, 200" 
  stroke="red" stroke-width="3"　fill="transparent"/>
  -->
  <div ref="objectRoot" :style="position"
      v-on:mousedown="divOnMouseDown">

    <div v-if="isActive" class="button-container">
      <clicks roll="delete"
        :position="defaultButtonPosition"
        v-on:action="requestDelete">
      </clicks>
    </div>

    <svg ref="svg" id="svg" viewbox="0% 0% 100% 100%" width="100%" height="100%">
      <!--shape components here-->
      <path ref="line" :d="path" :stroke="lineColor" :stroke-width="width" fill="transparent"
        :transform="transform"
      />
    </svg>

    <expantion v-if="isActive"
        :position="expantionButtonPosition"
        v-on:expandStart="setPivotObjectSize"
        v-on:expand="" 
        v-on:expandEnd="">
    </expantion>
  </div>
</template>


<script>
// global
const bufferSize = 5; // 移動平均点数
const aveSize = 3; // ベジェ曲線用通点数 (3で固定)
const drawInterval = 3; // プロット間隔
const thresDist = 50; //px**2
const rectPadding = 10; // pathを囲うdivのpadding
const borderOffset = 2; //px :この図形を囲むborder幅を指定
const minAreaPx = 5; //px 縮小時の最小ピクセル
let count = 0;
let trajX = Array(bufferSize); // 移動平均前の点の履歴
let trajY = Array(bufferSize);
let histX = Array(aveSize);  // 移動平均後の点の履歴
let histY = Array(aveSize);

import expantion from "./button-expantion.vue"
import clicks from "./button-click.vue"

export default {
  components: {
    clicks,
    expantion
  },
  props: ['globalId', 'userId', 'objId', 'type', 'status', 'position', 'width', 'lineColor', 'path'],
  data: function () {
    return {
      //path: "",
      transform:"",
      /*
      position: {
        position:"absolute",
        top: "",
        left: "",
        width:"100%",
        height: "100%",
        border: "",
      },*/
      pivotWidth: "",
      pivotHeight: "",
      pivotPath: "",
      isActive: false,
      isSelected: false,
      isDrag: false,
      isExpand: false,
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
    divOnMouseDown(){
      var frame = document.getElementById("frame");
      var mode = frame.getAttribute("mode");
      if(mode === "manipulate" && !this.isExpand){
        // サーバーに任せる
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
    initialize(){
      var pathArr = this.path.split(/\s+/);
      var x0 = parseFloat(pathArr[1]);
      var y0 = parseFloat(pathArr[2]);
      trajX.fill(x0);
      trajY.fill(y0);
      histX.fill(x0);
      histY.fill(y0);
      count = 0;
    },
    appendPath(x, y, isEnd){
      count++;
      let idx = count % bufferSize;
      let idxBefore = (count-1) % bufferSize;
      trajX[idx] = x;
      trajY[idx] = y;
      var xBefore = trajX[idxBefore]
      var yBefore = trajY[idxBefore]

      var dist2 = (x-xBefore)**2 + (y-yBefore)**2 
      if((count % drawInterval) !== 0 && dist2 < thresDist && !isEnd){
        return;
      }

      /* calc average x,y */
      let aveX = sum(trajX)/trajX.length;
      let aveY = sum(trajY)/trajY.length;
      
      if(isEnd){
        aveX = x;
        aveY = y;
      }
      /* function rotateHistory */
      rotate(histX, aveX);
      rotate(histY, aveY);

      var ret = catmullRom2bezier([
        {"x":histX[0],"y":histY[0]},
        {"x":histX[1],"y":histY[1]},
        {"x":histX[2],"y":histY[2]}
      ]);
      
      // スプライン補完なし
      this.path += " S " + String(aveX) + " " + String(aveY)
                + " " + String(aveX) + " " + String(aveY);
      // スプライン補完有り
      /*this.path += " S " + String(ret[0][2]) + " " + String(ret[0][3])
      + " " + String(ret[0][4]) + " " + String(ret[0][5]);
      if(isEnd){
        this.path += " S " + String(ret[1][2]) + " " + String(ret[1][3])
        + " " + String(ret[1][4]) + " " + String(ret[1][5]);
      }*/
    },
    fitBounding(canvasX, canvasY){
      var line = this.$refs.line;
      var data = line.getBoundingClientRect();
      var offX = data["left"] - canvasX - rectPadding + borderOffset;
      var offY = data["top"] - canvasY - rectPadding + borderOffset;
      var wid = data["width"]  + rectPadding;
      var hig = data["height"] + rectPadding;
      //console.log(data);
      
      this.path = transformPath(this.path, offX, offY, "slide");
      
      // Update div position      
      this.position.top = offY + "px";
      this.position.left = offX + "px";
      this.position.width = wid + "px";
      this.position.height = hig + "px";
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
      this.pivotPath = this.path;
    },
    transformShape(deltaX, deltaY){
      var newWidth = (this.pivotWidth + deltaX) < minAreaPx ? minAreaPx : (this.pivotWidth + deltaX);
      var newHeight = (this.pivotHeight + deltaY) < minAreaPx ? minAreaPx : (this.pivotHeight + deltaY);
      this.position.width = newWidth + "px";
      this.position.height = newHeight + "px";
      this.path = transformPath(
                      this.pivotPath,
                      newWidth / this.pivotWidth,
                      newHeight / this.pivotHeight,
                      "expand"
                  );
    },
    // グループ拡大時に使用
    transformShapeG(selectionLeft, selectionTop, Kx, Ky){
      var newWidth =  Kx * this.pivotWidth;
      var newHeight = Ky * this.pivotHeight;
      this.position.width = newWidth + "px";
      this.position.height = newHeight + "px";
      this.path = transformPath(
                      this.pivotPath,
                      newWidth / this.pivotWidth,
                      newHeight / this.pivotHeight,
                      "expand"
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
  },
  mounted: function(){
      this.initialize();
  }
}


// private
function sum(arr) {
    var sum = 0;
    arr.forEach(function(elm) {
        sum += elm;
    });
    return sum;
};

function rotate(arr, data){
  arr.shift();
  arr.push(data);
}

function catmullRom2bezier(pts){
  var cubics = [];
  for ( var i = 0, iLen = pts.length; i < iLen ; i++ ){
      var p = [
          pts[i - 1],
          pts[i],
          pts[i + 1],
          pts[i + 2]
      ];
      if( i === 0 ){
        p[0] = {
            x: pts[ 0 ].x,
            y: pts[ 0 ].y
        }
      }
      if( i === iLen - 2 ){
        p[3] = {
            x: pts[iLen - 2].x,
            y: pts[iLen - 2].y
        };
      }
      if ( i === iLen - 1 ) {
        p[2] = {
            x: pts[iLen - 1].x, 
            y: pts[iLen - 1].y
        };
        p[3] = {
            x: pts[iLen - 1].x, 
            y: pts[iLen - 1].y
        };
      }
    const val = 6;
      cubics.push([
        (-p[0].x + val * p[1].x + p[2].x) / val,
        (-p[0].y + val * p[1].y + p[2].y) / val,
        (p[1].x + val * p[2].x - p[3].x) / val,
        (p[1].y + val * p[2].y - p[3].y) / val,
        p[2].x,
        p[2].y
      ]);
  }
  return cubics;
};

function transformPath(pathStr, inputX, inputY, tmode){
  // もともとのPathを空白文字でsplitする
  // slide => x座標, y座標それぞれを平行移動する
  // expand => x座標, y座標それぞれをk倍する
  var transFormedArr = [];
  var pathArr = pathStr.split(/\s+/);
  var chainCount = 0;
  pathArr.forEach(data => {
    if(isNaN(data)){ // 文字の場合(S, C, Mなど)
      transFormedArr.push(data);
      chainCount = 0;
      return;
    }
    if(tmode === "slide"){
      var newData = slideXY(data, inputX, inputY, chainCount);
    }
    else if(tmode === "expand"){
      var newData = expandXY(data, inputX, inputY, chainCount);
    }
    else{
      console.log("Transform mode Error!");
    }
    transFormedArr.push(newData);
    chainCount++;
  });

  // Update path
  var tmpPath = "";
  var length = transFormedArr.length;
  var idx = 0;
  transFormedArr.forEach(data => {
    //console.log(data);
    if(idx === length -1){
      tmpPath += data;
      return;
    }
    tmpPath += data + " ";
    idx++;
  });
  return tmpPath;
}

function slideXY(data, inputX, inputY, chainCount){
  var newData = "";
  if(chainCount % 2 === 0){ // x座標の場合
    newData = data - inputX;
  }
  else{ // y座標の場合
    newData = data - inputY;
  }
  return Math.round(newData * 100) / 100;
}

function expandXY(data, inputX, inputY, chainCount){
  var newData = "";
  if(chainCount % 2 === 0){ // x座標の場合
    newData = data * inputX;
  }
  else{ // y座標の場合
    newData = data * inputY;
  }
  return Math.round(newData * 100) / 100;
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
