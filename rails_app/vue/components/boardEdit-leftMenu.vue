<template>
  <div id="board-edit-left-menu-root">
    <div class="button-container">
      <leftButton v-show="boolArray[0]" :ref="subMenuKeys[0]" :mode="subMenuKeys[0]" :src="images[subMenuKeys[0]]" :navComment="nav[subMenuKeys[0]]" @child-click="onSubMenuButtonClicked"></leftButton>
      <leftButton v-show="boolArray[1]" :ref="subMenuKeys[1]" :mode="subMenuKeys[1]" :src="images[subMenuKeys[1]]" :navComment="nav[subMenuKeys[1]]" @child-click="onSubMenuButtonClicked"></leftButton>
      <leftButton v-show="boolArray[2]" :ref="subMenuKeys[2]" :mode="subMenuKeys[2]" :src="images[subMenuKeys[2]]" :navComment="nav[subMenuKeys[2]]" @child-click="onSubMenuButtonClicked"></leftButton>
      <leftButton v-show="boolArray[3]" :ref="subMenuKeys[3]" :mode="subMenuKeys[3]" :src="images[subMenuKeys[3]]" :navComment="nav[subMenuKeys[3]]" @child-click="onSubMenuButtonClicked"></leftButton>
      <leftButton v-show="boolArray[4]" :ref="subMenuKeys[4]" :mode="subMenuKeys[4]" :src="images[subMenuKeys[4]]" :navComment="nav[subMenuKeys[4]]" @child-click="onSubMenuButtonClicked"></leftButton>
      <leftButton v-show="boolArray[5]" :ref="subMenuKeys[5]" :mode="subMenuKeys[5]" :src="images[subMenuKeys[5]]" :navComment="nav[subMenuKeys[5]]" @child-click="onSubMenuButtonClicked"></leftButton>
    </div>

    <div class="button-container">
      <leftButton :ref="modeKeys[0]" :mode="modeKeys[0]" :src="images[modeKeys[0]]" :navComment="nav[modeKeys[0]]" @child-click="onModeButtonClicked"></leftButton>
      <leftButton :ref="modeKeys[1]" :mode="modeKeys[1]" :src="images[modeKeys[1]]" :navComment="nav[modeKeys[1]]" @child-click="onModeButtonClicked"></leftButton>
      <leftButton :ref="modeKeys[2]" :mode="modeKeys[2]" :src="images[modeKeys[2]]" :navComment="nav[modeKeys[2]]" @child-click="onModeButtonClicked"></leftButton>
      <leftButton :ref="modeKeys[3]" :mode="modeKeys[3]" :src="images[modeKeys[3]]" :navComment="nav[modeKeys[3]]" @child-click="onModeButtonClicked"></leftButton>
      <leftButton :ref="modeKeys[4]" :mode="modeKeys[4]" :src="images[modeKeys[4]]" :navComment="nav[modeKeys[4]]" @child-click="onModeButtonClicked"></leftButton>
      <leftButton :ref="modeKeys[5]" :mode="modeKeys[5]" :src="images[modeKeys[5]]" :navComment="nav[modeKeys[5]]" @child-click="onModeButtonClicked"></leftButton>
      <leftButton :ref="modeKeys[6]" :mode="modeKeys[6]" :src="images[modeKeys[6]]" :navComment="nav[modeKeys[6]]" @child-click="onModeButtonClicked"></leftButton>
    </div>
  </div>
</template>


<script>
import leftButton from "./boardEdit-leftButton.vue"
export default {
  components: {
    leftButton,
  },
  data: function () {
    return {
      mode: "draw",
      subMenu: "",
      modeList:{
        // モードKey名: [サブメニューKeyの配列],
        'undo': [],
        'redo': [],
        'draw': ["freeHand", "straight", "straightArrow", "rectangle", "myCircle", "lineColor"],
        'write': ["string", "fontColor"],
        'manipulate': [],
        'image': [],
        'plus': ["reload", "trash", "save"]
      },
      modeKeys:[], // モードKey: initialize in created() method.
      subMenuKeys:[], // サブメニューKey: モードが変わるごとに初期化される
      preUsedSubMenuIdx:{}, // 1つ前に使用されたサブメニューKey: initialize in created() method.
      boolArray:[false, false, false, false, false, false],
      images:{
        // Main menu
        'undo': "/images/arrow_return.svg",
        'redo': "/images/arrow_go_ahead.svg",
        'draw': "/images/pencil.svg",
        'write': "/images/char_AA.svg",
        'manipulate': "/images/hand_grab.svg",
        'image': "/images/no_image.svg",
        'plus': "/images/plus.png",
        // Sub menu
        'freeHand': "/images/freeHand.png",
        'straight': "/images/straight.png",
        'string': "/images/text.png",
        'straightArrow': "/images/arrow_up.svg",
        'rectangle': "/images/square.png",
        'myCircle': "/images/circle.png",
        'lineColor': "/images/color.svg",
        "fontColor": "/images/color.svg",
        "reload": "/images/arrow_reload.svg",
        "trash": "/images/trash.svg",
        "save": "/images/floppy.svg",
      },
      nav:{
        // Main menu
        'undo': "戻る",
        'redo': "進む",
        'draw': "図形を描く",
        'write': "文字入力",
        'manipulate': "図形操作",
        'image': "画像貼付け",
        'plus': "その他",
        // Sub menu
        'freeHand': "フリーハンド",
        'straight': "直線",
        'string': "テキスト",
        'straightArrow': "矢印",
        'rectangle': "四角形",
        'myCircle': "楕円",
        "reload": "最新の状態に更新",
        "trash": "全削除",
        "save": "保存",
        "fontColor": "色を変える",
        "lineColor": "色を変える",
      }
    }
  },
  methods: {
    onModeButtonClicked(activeMode){
      this.changeMode(activeMode);
      this.$emit('change-mode', this.mode);
      this.$emit('change-subMenu', this.subMenu); 
      //console.log(this.preUsedSubMenuIdx);
    },
    onCanvasModeRecieved(mode){
      this.changeMode(mode);
    },
    onSubMenuButtonClicked(activeSubMenu){
      if(activeSubMenu === "fontColor" || activeSubMenu === "lineColor"){
        this.$emit('change-subMenu', activeSubMenu);
        return;
      }
      this.subMenu = activeSubMenu;
      this.updatePreUsedSubMenu();
      this.changeButtonIndication(this.subMenuKeys, activeSubMenu);
      this.$emit('change-subMenu', this.subMenu);
    },
    changeMode(mode){
      this.mode = mode;
      this.subMenuKeys = this.modeList[this.mode];
      this.subMenu = this.subMenuKeys[this.preUsedSubMenuIdx[this.mode]];
      this.changeButtonIndication(this.modeKeys, mode);
      this.showSubMenuButtons(this.mode);
    },
    myFindIndex(arr, val){
      var idx = 0;
      var ret = null;
      arr.forEach(el =>{
        if(el == val){
          ret = idx;
          return;
        }
        idx++;
      })
      return ret;
    },
    updatePreUsedSubMenu(){
      if(this.mode === "plus"){
        this.preUsedSubMenuIdx[this.mode] = -1;
        return;
      }
      this.preUsedSubMenuIdx[this.mode] = this.myFindIndex(this.subMenuKeys, this.subMenu);
    },
    changeButtonIndication(keyArr, activeMode){
      this.$nextTick(function () {
        keyArr.forEach(key => {
          if(key === activeMode){
            this.$refs[key].turnOn();
          }
          else{
            this.$refs[key].turnOff();
          }
        });
      });
    },
    showSubMenuButtons(mode){
      // サブメニューの数と同数だけ、ボタンを表示
      for (let idx = 0; idx < this.boolArray.length; idx++){
        this.boolArray[idx] = idx < this.subMenuKeys.length
      }
      this.changeButtonIndication(this.subMenuKeys, this.subMenuKeys[this.preUsedSubMenuIdx[this.mode]]);
    },
  },
  created: function(){
    this.modeKeys = Object.keys(this.modeList);
    this.preUsedSubMenuIdx = {}
    this.modeKeys.forEach(key => {
      this.preUsedSubMenuIdx[key] = 0;
    })
    this.preUsedSubMenuIdx["plus"] = -1;
    console.log(this.preUsedSubMenuIdx)
  },
  mounted: function(){
    this.onModeButtonClicked(this.modeKeys[2]);
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
    box-sizing: border-box;
      -moz-box-sizing: border-box;
      -webkit-box-sizing: border-box;
      -o-box-sizing: border-box;
      -ms-box-sizing: border-box;
    }

@media (min-width: 720px) {
#board-edit-left-menu-root  {
                    display: flex;
                    flex-direction: row;
                    justify-content: flex-end;
                    height:100%;
                    }

.button-container  {
    /* boardEdit-leftButtonと整合性を取ること */
    height:100%;
    width:11vh;
    max-width: 100px;
  }
}

@media (max-width: 720px) {
  #board-edit-left-menu-root  {
                    display: flex;
                    flex-direction: column;
                    flex-direction: column-reverse;
                    justify-content: flex-end;
                    width:100%;
                    }

  .button-container {
                    display: flex;
                    flex-direction: row;
                    width:100%;
                    }
}
</style>
