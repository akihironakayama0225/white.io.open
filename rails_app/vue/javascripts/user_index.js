import Vue from 'vue'
import Users from '../components/userIndex.vue'

document.addEventListener('DOMContentLoaded', () => {
  const app = new Vue({
    el: "#user-index",
    render: h => h(Users, {props:{"rails": "hoge"}})
  })
})
