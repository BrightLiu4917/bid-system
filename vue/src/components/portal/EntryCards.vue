<template>
  <section class="quick-section">
    <div class="quick-cards">
      <button class="quick-card" type="button" @click="$emit('open', 'supplier')">
        <div class="quick-left">
          <el-icon><OfficeBuilding /></el-icon>
          <span>供应商入口</span>
        </div>
        <div class="quick-action">立即申请入库</div>
      </button>

      <button class="quick-card" type="button" @click="$emit('open', 'expert')">
        <div class="quick-left">
          <el-icon><Medal /></el-icon>
          <span>专家入口</span>
        </div>
        <div class="quick-action">立即加入专家库</div>
      </button>
    </div>

    <div class="flow-box">
      <div class="flow-title">入库办理流程</div>
      <div class="flow-line">
        <div class="flow-step">
          <div class="flow-icon"><el-icon><User /></el-icon></div>
          <b>第一步</b>
          <span>注册 / 登录</span>
        </div>
        <div class="arrow"></div>
        <div class="flow-step">
          <div class="flow-icon"><el-icon><Document /></el-icon></div>
          <b>第二步</b>
          <span>填写基础信息并上传附件</span>
        </div>
        <div class="arrow"></div>
        <div class="flow-step">
          <div class="flow-icon"><el-icon><Check /></el-icon></div>
          <b>第三步</b>
          <span>平台审核并完成入库</span>
        </div>
        <div class="mini-qr">
          <div class="qr"></div>
          <span>扫码查看入库指引</span>
        </div>
      </div>
    </div>
  </section>
</template>

<script setup>
import { Check, Document, Medal, OfficeBuilding, User } from "@element-plus/icons-vue";

defineEmits(["open"]);
</script>

<style lang="scss" scoped>
.quick-section {
  margin-top: 36px;
  padding: 66px 0 54px;
  overflow: hidden;
  background:
    linear-gradient(180deg, rgba(112, 20, 23, 0.6) 0, rgba(112, 20, 23, 0.6) 110px, #fff 110px),
    linear-gradient(0deg, rgba(255, 255, 255, 0.28), rgba(255, 255, 255, 0.28)),
    url("@/assets/guohong/banner-2.jpg") center top / cover no-repeat;
  border: 1px solid #dcdfe6;
  border-radius: 2px;
}

.quick-cards {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 26px;
  width: min(1120px, calc(100% - 72px));
  margin: 0 auto;
}

.quick-card {
  display: grid;
  grid-template-columns: 210px minmax(0, 1fr);
  min-height: 108px;
  overflow: hidden;
  background: #fff;
  border: 1px solid #dcdfe6;
  border-radius: 2px;
  box-shadow: 0 8px 20px rgba(24, 31, 42, 0.08);
  cursor: pointer;
  transition:
    border-color 0.16s ease,
    box-shadow 0.16s ease,
    transform 0.16s ease;

  &:hover {
    border-color: #1677d2;
    box-shadow: 0 10px 24px rgba(22, 119, 210, 0.14);
    transform: translateY(-2px);
  }
}

.quick-left {
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 14px;
  padding: 0 22px;
  color: #fff;
  background: #9b1c1f;
  font-size: 23px;
  font-weight: 800;
  line-height: 1.25;

  .el-icon,
  span {
    position: relative;
    z-index: 1;
  }

  .el-icon {
    flex: 0 0 auto;
    font-size: 36px;
  }

  span {
    min-width: 0;
    white-space: nowrap;
  }
}

.quick-action {
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 0 24px;
  color: #1f2329;
  font-size: 21px;
  font-weight: 800;
  white-space: nowrap;

  &::after {
    margin-left: 16px;
    content: "›";
    font-size: 38px;
    line-height: 1;
  }

  .quick-card:hover & {
    color: #1677d2;
  }
}

.flow-box {
  width: min(1120px, calc(100% - 72px));
  margin: 26px auto 0;
  padding: 28px 44px;
  background: rgba(255, 255, 255, 0.98);
  border: 1px solid #dcdfe6;
  border-radius: 2px;
  box-shadow: 0 8px 18px rgba(24, 31, 42, 0.06);
}

.flow-title {
  margin-bottom: 24px;
  font-size: 18px;
  font-weight: 800;
}

.flow-line {
  display: grid;
  grid-template-columns: 1fr 60px 1fr 60px 1fr 170px;
  gap: 16px;
  align-items: center;
}

.flow-step {
  display: grid;
  justify-items: center;
  gap: 10px;
  text-align: center;

  b {
    color: #9b1c1f;
  }
}

.flow-icon {
  display: grid;
  width: 78px;
  height: 78px;
  place-items: center;
  color: #9b1c1f;
  background: #fff;
  border-radius: 50%;
  box-shadow: 0 8px 28px rgba(155, 28, 31, 0.13);

  .el-icon {
    font-size: 34px;
  }
}

.arrow {
  position: relative;
  height: 1px;
  border-top: 1px dashed #d7b8ad;

  &::after {
    position: absolute;
    top: -5px;
    right: -2px;
    width: 0;
    height: 0;
    content: "";
    border-top: 5px solid transparent;
    border-bottom: 5px solid transparent;
    border-left: 8px solid #d7b8ad;
  }
}

.mini-qr {
  display: grid;
  justify-items: center;
  gap: 10px;
  color: #555;
  text-align: center;
}

.qr {
  display: grid;
  width: 94px;
  height: 94px;
  place-items: center;
  background:
    linear-gradient(90deg, #111 8px, transparent 8px) 0 0 / 20px 20px,
    linear-gradient(#111 8px, transparent 8px) 0 0 / 20px 20px,
    #fff;
  border: 7px solid #111;
  box-shadow: inset 0 0 0 10px #fff;

  &::after {
    width: 22px;
    height: 22px;
    content: "";
    background: #9b1c1f;
    border-radius: 50%;
  }
}

@media (max-width: 980px) {
  .quick-cards,
  .flow-line,
  .quick-card {
    grid-template-columns: 1fr;
  }

  .quick-left::after,
  .arrow {
    display: none;
  }
}
</style>
