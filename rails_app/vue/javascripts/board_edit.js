import Vue from 'vue'
import board from '../components/boardEdit.vue'
import ActionCable from 'actioncable'


Vue.prototype.$cable = ActionCable.createConsumer();

// ToDo: ブラウザバック時の処理を実装する

document.addEventListener('DOMContentLoaded', () => {
  const app = new Vue({
    el: "#board-edit",
    render: h => h(board)
  });
});

