<template>
  <div id="nav-root">
    <div v-if="isHover" class="balloon1">
      <p>{{comment}}</p>
    </div>
  </div>
</template>


<script>

export default {
  components: {
  },
  //props: ['src', 'mode'],
  data: function () {
    return {
      comment: "画像貼付け",
      isHover: false
    }
  },
  methods: {
  }
}
</script>


<style scoped lang="scss">
p {
  //font-size: 2em;
  text-align: center;
}

#nav-root{
  z-index:3;
  position:absolute;
  background-color:rgba(58, 56, 56, 0.3);
  top: -10px;
  margin: 0 auto;

  & *{
    pointer-events: none;
  }
}

.balloon1 {
  position: relative;
  display: inline-block;
  width: 90px;
  color: #555;
  font-size: 16px;
  background: #f0f8e2;
  border-radius: 3px;
}

.balloon1:before {
  content: "";
  position: absolute;
  top: 100%;
  left: 20%;
  margin-left: -10px;
  border: 10px solid transparent;
  border-top: 10px solid #f0f8e2;
}

.balloon1 p {
  margin: 0;
  padding: 0;
}
</style>
