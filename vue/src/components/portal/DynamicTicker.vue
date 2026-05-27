<template>
  <section class="status-card">
    <div class="status-head">
      <div>
        {{ title }}
        <span>{{ subtitle }}</span>
      </div>
      <div>{{ rightTitle }}</div>
    </div>
    <div class="ticker">
      <ul>
        <template v-for="round in 2" :key="round">
          <li v-for="item in list" :key="`${round}-${item.name}`">
            <el-icon class="sound"><Bell /></el-icon>
            <span>{{ item.name }}</span>
            <span class="right">{{ item.status }}</span>
          </li>
        </template>
      </ul>
    </div>
  </section>
</template>

<script setup>
import { Bell } from "@element-plus/icons-vue";

defineProps({
  title: {
    type: String,
    required: true,
  },
  subtitle: {
    type: String,
    default: "",
  },
  rightTitle: {
    type: String,
    default: "状态",
  },
  list: {
    type: Array,
    default: () => [],
  },
});
</script>

<style lang="scss" scoped>
.status-card {
  overflow: hidden;
  background: #fff;
  border-radius: 8px;
  box-shadow: 0 12px 34px rgba(44, 29, 24, 0.12);
}

.status-head {
  display: grid;
  grid-template-columns: minmax(0, 1fr) 96px;
  align-items: center;
  height: 68px;
  padding: 0 34px;
  color: #fff;
  background: linear-gradient(90deg, #7a1215, #9b1c1f);
  font-size: 24px;
  font-weight: 800;

  span {
    color: rgba(255, 255, 255, 0.62);
    font-size: 15px;
  }
}

.ticker {
  height: 318px;
  overflow: hidden;
  padding: 28px 38px;

  ul {
    margin: 0;
    padding: 0;
    list-style: none;
    animation: scrollList 14s linear infinite;
  }

  &:hover ul {
    animation-play-state: paused;
  }

  li {
    display: grid;
    grid-template-columns: 38px minmax(0, 1fr) 100px;
    gap: 12px;
    align-items: center;
    height: 50px;
    font-size: 18px;
  }
}

.sound {
  color: #c8a15a;
}

.right {
  color: #9b1c1f;
  text-align: right;
  font-weight: 800;
}

@keyframes scrollList {
  0% {
    transform: translateY(0);
  }

  100% {
    transform: translateY(-50%);
  }
}
</style>
