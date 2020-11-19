<template>
  <a class="btn btn-flat" :href=href>
    <img :src=src>
    <span>{{label}}</span>
  </a>             
</template>


<script>
export default {
  components: {
  },
  props: ["label", "src", "href"],
  data: function () {
    return {
      message: "This is Top Page!"
    }
  }
}
</script>


<style scoped lang="scss">
div{
  border: solid 1px gray;
  box-sizing: border-box;
    -moz-box-sizing: border-box;
    -webkit-box-sizing: border-box;
    -o-box-sizing: border-box;
    -ms-box-sizing: border-box;
}

.btn-flat {
  height:100px;
  position: relative;
  overflow: hidden;
  padding: 20px 30px;
  text-decoration: none;

  color: #fff;
  border-radius: 2px;
  background: rgb(117, 117, 117);
  box-shadow: 0 3px 6px rgba(0, 0, 0, 0.4);

  img {
    position: absolute;
    width: 120%;
    opacity: 0.3;
    z-index: 1;
  }

  span {
    font-weight: bolder;
    z-index: 1;
  }

  @media (max-width:900px){
    span {
      font-size: 40px;
    }
  }
  @media (max-width:720px){
    span {
      font-size: 30px;
    }
  }
  @media (min-width:900px){
    span {
      font-size: 40px;
    }
  }
}

.btn-flat:before {
  position: absolute;
  top: 170%;
  left: -200%;

  width: 300%;
  height: 500%;

  content: '';
  -webkit-transition: all .5s ease-in-out;
  transition: all .5s ease-in-out;
  -webkit-transform: rotate(45deg) translateX(0) translateY(0);
  transform: rotate(45deg) translateX(0) translateY(0);

  background: rgb(75, 170, 77);
  opacity: 0.8;
}

.btn-flat:after {
  position: absolute;
  top: -570%;
  right: -200%;

  width: 300%;
  height: 500%;

  content: '';
  -webkit-transition: all .5s ease-in-out;
  transition: all .5s ease-in-out;
  -webkit-transform: rotate(45deg) translateX(0) translateY(0);
  transform: rotate(45deg) translateX(0) translateY(0);

  background: rgb(75, 170, 77);
  opacity: 0.8;
}

.btn-flat:hover:before {
  -webkit-transform: rotate(45deg) translateX(0) translateY(-70%);
  transform: rotate(45deg) translateX(0) translateY(-70%);
}

.btn-flat:hover:after {
  -webkit-transform: rotate(45deg) translateX(0) translateY(70%);
  transform: rotate(45deg) translateX(0) translateY(70%);
}

</style>
