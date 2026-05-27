<template>
  <section class="notice-card">
    <div class="section-head">
      <div class="section-title">{{ title }} <span>{{ enTitle }}</span></div>
      <a class="more" href="javascript:;">更多 〉</a>
    </div>
    <ul class="notice-list">
      <li v-for="item in list" :key="item.title">
        <a href="javascript:;">{{ item.title }}</a>
        <time>{{ item.date }}</time>
      </li>
    </ul>
  </section>
</template>

<script setup>
defineProps({
  title: {
    type: String,
    required: true,
  },
  enTitle: {
    type: String,
    default: "",
  },
  list: {
    type: Array,
    default: () => [],
  },
});
</script>

<style lang="scss" scoped>
.notice-card {
  background: #fff;
  border: 1px solid #dcdfe6;
  box-shadow: 0 8px 20px rgba(24, 31, 42, 0.06);
}

.section-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  height: 58px;
  padding: 0 26px;
  border-bottom: 1px solid #dcdfe6;
}

.section-title {
  display: flex;
  align-items: center;
  gap: 8px;
  color: #1f2329;
  font-size: 18px;
  font-weight: 800;

  &::before {
    width: 4px;
    height: 20px;
    content: "";
    background: #1f2329;
    border-radius: 0;
  }

  span {
    font-weight: 800;
  }
}

.more {
  color: #1f2329;
  transition: color 0.16s ease;

  &:hover {
    color: #1677d2;
  }
}

.notice-list {
  margin: 0;
  padding: 22px 28px 28px;
  list-style: none;

  li {
    display: grid;
    grid-template-columns: minmax(0, 1fr) 120px;
    gap: 18px;
    align-items: center;
    height: 42px;
    color: #1f2329;
    font-size: 17px;
  }

  a {
    color: #1f2329;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
    transition: color 0.16s ease;

    &:hover {
      color: #1677d2;
    }
  }

  time {
    color: #a5aeb9;
    text-align: right;
    white-space: nowrap;
  }
}

@media (max-width: 768px) {
  .notice-list li {
    grid-template-columns: 1fr;
    gap: 2px;
    height: auto;
    padding: 10px 0;
  }

  .notice-list time {
    text-align: left;
  }
}
</style>
