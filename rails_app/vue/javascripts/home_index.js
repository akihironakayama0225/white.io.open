import Vue from 'vue'
import Home from '../components/homeIndex.vue'

document.addEventListener('DOMContentLoaded', () => {
  const app = new Vue({
    el: "#home-index",
    render: h => h(Home, {props:{"rails": "hoge"}})
  })
})
