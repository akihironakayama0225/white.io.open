import Vue from 'vue'
import Common from '../components/utils/common.vue'

document.addEventListener('DOMContentLoaded', () => {
  const app = new Vue({
    el: "#common-vue",
    render: h => h(Common, {props:{"rails": "hoge"}})
  })
})
