<template>
  <div class="portal-page">
    <section class="hero">
      <div class="slide slide-one"></div>
      <div class="slide slide-two"></div>

      <header class="topbar">
        <div class="brand">
          <img src="@/assets/guohong/logo.png" alt="北京国宏规划院" />
          <span class="brand-divider"></span>
          <span class="platform-name">招采服务平台</span>
        </div>
        <div class="top-actions">
          <el-button @click="openAuth('register')">注册</el-button>
          <el-button type="success" @click="openAuth('login')">登录</el-button>
        </div>
      </header>

      <div class="hero-copy">
        <div class="hero-kicker">北京国宏规划院有限公司</div>
        <h1>规范招采 高效协同</h1>
        <div class="en">Standardized procurement and efficient collaboration</div>
        <div class="slogan">公开 / 规范 / 高效 / 可信</div>
      </div>

      <div class="dots"><span></span><span></span></div>
    </section>

    <main class="portal-main">
      <section class="top-grid">
        <notice-section title="平台招标公告" en-title="NOTICE" :list="bidNotices" />
        <div class="guide-card">
          <div class="qr-box">
            <div class="qr"></div>
            <p>手机扫码关注平台公告，及时查看入库审核进度</p>
          </div>
          <div class="doc-box">
            <el-icon><Document /></el-icon>
            <a href="#quick-entry">入库办理指引</a>
            <p>查看供应商、专家入库材料清单与办理流程</p>
          </div>
        </div>
      </section>

      <notice-section
        class="info-section"
        title="入库公告"
        en-title="INFORMATION"
        :list="entryNotices"
      />

      <section class="status-grid">
        <dynamic-ticker
          title="专家入库动态"
          subtitle="申请入库的专家实时动态展示"
          right-title="状态"
          :list="expertDynamic"
        />
        <dynamic-ticker
          title="战略合作单位"
          subtitle="平台供应商合作单位动态"
          right-title="累计入库"
          :list="supplierDynamic"
        />
      </section>

      <entry-cards id="quick-entry" @open="handleEntryOpen" />
    </main>

    <div class="float-tools">
      <el-button circle title="资料下载"><el-icon><Download /></el-icon></el-button>
      <el-button circle title="通知提醒"><el-icon><Bell /></el-icon></el-button>
    </div>

    <auth-modal
      v-model="authVisible"
      :mode="authMode"
      :default-role="defaultRole"
      @success="handleAuthSuccess"
    />
  </div>
</template>

<script setup>
import { ref } from "vue";
import { useRouter } from "vue-router";
import { Bell, Document, Download } from "@element-plus/icons-vue";
import AuthModal from "@/components/portal/AuthModal.vue";
import DynamicTicker from "@/components/portal/DynamicTicker.vue";
import EntryCards from "@/components/portal/EntryCards.vue";
import NoticeSection from "@/components/portal/NoticeSection.vue";

const router = useRouter();

const authVisible = ref(false);
const authMode = ref("login");
const defaultRole = ref("supplier");

const bidNotices = [
  { title: "北京国宏规划院项目咨询服务合作单位入围征集公告", date: "2026-05-25" },
  { title: "全过程工程咨询数字化管理平台技术服务采购公告", date: "2026-05-25" },
  { title: "产业园区专项债项目咨询服务供应商征集公告", date: "2026-05-24" },
  { title: "新能源与数智产业中心课题研究服务采购公告", date: "2026-05-24" },
  { title: "投资咨询、造价咨询、招标代理服务单位补充征集公告", date: "2026-05-23" },
  { title: "北京国宏规划院专家评审服务相关事项通知", date: "2026-05-22" },
];

const entryNotices = [
  { title: "北京国宏规划院有限公司供应商库入库征集公告", date: "长期有效" },
  { title: "公开征集专家入库公告", date: "长期有效" },
  { title: "供应商入库申请表、保密协议模板下载", date: "资料下载" },
  { title: "专家库入库申报表、专家承诺书模板下载", date: "资料下载" },
];

const expertDynamic = [
  { name: "李*东专家　自动化　高级工程师", status: "新入库" },
  { name: "任*专家　机械设计与制造　高级工程师", status: "新入库" },
  { name: "黄*丽专家　统计学　高级经济师", status: "新入库" },
  { name: "张*专家　经济管理　高级会计师", status: "新入库" },
  { name: "钱*安专家　建筑学　高级建筑师", status: "新入库" },
];

const supplierDynamic = [
  { name: "北京****管理有限公司", status: "257名" },
  { name: "北京****标有限公司", status: "149名" },
  { name: "新华****有限公司", status: "149名" },
  { name: "中大****管理有限公司", status: "140名" },
  { name: "北京****程咨询有限公司", status: "137名" },
];

const openAuth = (mode, role = "supplier") => {
  authMode.value = mode;
  defaultRole.value = role;
  authVisible.value = true;
};

const handleEntryOpen = (role) => {
  openAuth("register", role);
};

const handleAuthSuccess = ({ role }) => {
  router.push({
    path: "/application/dashboard",
    query: { role },
  });
};
</script>

<style lang="scss" scoped>
.portal-page {
  min-height: 100vh;
  background: #f5f6f8;
}

.hero {
  position: relative;
  min-height: 500px;
  overflow: hidden;
  color: #fff;
  background: #7f1519;
  border-bottom: 4px solid #d7b16a;
}

.slide {
  position: absolute;
  inset: 0;
  background-position: center;
  background-size: cover;
  opacity: 0;
  animation: fadeSlide 12s infinite;
  transform: scale(1.03);
}

.slide-one {
  background-image:
    linear-gradient(90deg, rgba(74, 8, 13, 0.92) 0, rgba(94, 12, 16, 0.82) 38%, rgba(128, 20, 22, 0.32) 66%, rgba(255, 255, 255, 0.04)),
    url("@/assets/guohong/hero-cultural-1.jpg");
  background-blend-mode: normal;
  background-position: center 56%;
}

.slide-two {
  background-image:
    linear-gradient(90deg, rgba(74, 8, 13, 0.92) 0, rgba(94, 12, 16, 0.84) 38%, rgba(128, 20, 22, 0.34) 66%, rgba(255, 255, 255, 0.04)),
    url("@/assets/guohong/hero-cultural-2.jpg");
  animation-delay: 6s;
  background-blend-mode: normal;
  background-position: center 50%;
}

@keyframes fadeSlide {
  0%,
  45% {
    opacity: 1;
    transform: scale(1);
  }

  50%,
  95% {
    opacity: 0;
    transform: scale(1.03);
  }

  100% {
    opacity: 1;
    transform: scale(1);
  }
}

.topbar {
  position: relative;
  z-index: 2;
  display: flex;
  align-items: center;
  justify-content: space-between;
  width: min(1480px, calc(100vw - 80px));
  margin: 0 auto;
  padding: 26px 0;
}

.brand {
  display: flex;
  align-items: center;
  gap: 18px;

  img {
    width: 270px;
    filter: brightness(0) invert(1);
  }
}

.brand-divider {
  width: 1px;
  height: 34px;
  background: rgba(255, 255, 255, 0.42);
}

.platform-name {
  font-size: 30px;
  font-weight: 800;
  letter-spacing: 2px;
}

.top-actions {
  display: flex;
  gap: 14px;

  :deep(.el-button) {
    width: 104px;
    height: 40px;
    border-radius: 2px;
    font-weight: 700;
  }

  :deep(.el-button--success) {
    --el-button-bg-color: #9b1c1f;
    --el-button-border-color: #9b1c1f;
    --el-button-hover-bg-color: #7a1215;
    --el-button-hover-border-color: #7a1215;
  }
}

.hero-copy {
  position: relative;
  z-index: 2;
  width: min(1480px, calc(100vw - 80px));
  margin: 82px auto 0;

  h1 {
    margin: 0;
    font-size: 58px;
    line-height: 1.2;
    font-weight: 800;
    letter-spacing: 2px;
  }
}

.hero-kicker {
  display: inline-flex;
  align-items: center;
  height: 32px;
  padding: 0 12px;
  margin-bottom: 18px;
  color: #fff;
  background: rgba(117, 22, 25, 0.72);
  border-left: 4px solid #c8a15a;
  font-weight: 800;
}

.en {
  margin-top: 10px;
  font-size: 20px;
  font-weight: 700;
  opacity: 0.9;
  text-transform: uppercase;
}

.slogan {
  margin-top: 20px;
  font-size: 28px;
  font-weight: 800;
  letter-spacing: 3px;
}

.dots {
  position: absolute;
  z-index: 2;
  bottom: 28px;
  left: 50%;
  display: flex;
  gap: 10px;
  transform: translateX(-50%);

  span {
    width: 34px;
    height: 4px;
    background: rgba(255, 255, 255, 0.45);
    border-radius: 99px;

    &:first-child {
      background: #c8a15a;
    }
  }
}

.portal-main {
  width: min(1480px, calc(100vw - 80px));
  margin: -34px auto 60px;
  position: relative;
  z-index: 3;
}

.top-grid {
  display: grid;
  grid-template-columns: minmax(0, 1.45fr) minmax(360px, 0.65fr);
  gap: 18px;
}

.top-grid,
.info-section,
.status-grid,
:deep(.quick-section) {
  border-radius: 4px;
}

.guide-card {
  display: grid;
  grid-template-columns: 1fr 1fr;
  min-height: 312px;
  padding: 24px;
  background: #fff;
  border: 1px solid #dcdfe6;
  box-shadow: 0 8px 20px rgba(24, 31, 42, 0.06);
}

.qr-box,
.doc-box {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  text-align: center;

  p {
    margin: 18px 0 0;
    color: #5a6572;
    font-size: 16px;
    line-height: 1.55;
  }
}

.qr-box {
  border-right: 1px solid #dcdfe6;
}

.qr {
  display: grid;
  width: 118px;
  height: 118px;
  place-items: center;
  background:
    linear-gradient(90deg, #111 10px, transparent 10px) 0 0 / 24px 24px,
    linear-gradient(#111 10px, transparent 10px) 0 0 / 24px 24px,
    #fff;
  border: 8px solid #111;
  box-shadow: inset 0 0 0 12px #fff;

  &::after {
    width: 28px;
    height: 28px;
    content: "";
    background: #9b1c1f;
    border-radius: 50%;
  }
}

.doc-box {
  .el-icon {
    display: grid;
    width: 92px;
    height: 92px;
    place-items: center;
    color: #9b1c1f;
    background: #f8eeeb;
    border-radius: 10px;
    font-size: 52px;
  }

  a {
    margin-top: 16px;
    color: #9b1c1f;
    font-size: 20px;
    font-weight: 800;
  }
}

.info-section {
  margin-top: 18px;
}

.status-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 28px;
  margin-top: 28px;
  padding-bottom: 36px;
  background: #f5f6f8;
}

.float-tools {
  position: fixed;
  right: 28px;
  bottom: 150px;
  z-index: 5;
  display: grid;
  gap: 12px;

  .el-button {
    width: 54px;
    height: 54px;
    color: #9b1c1f;
    box-shadow: 0 12px 34px rgba(44, 29, 24, 0.14);
  }

  .el-icon {
    font-size: 26px;
  }
}

@media (max-width: 980px) {
  .topbar,
  .hero-copy,
  .portal-main {
    width: calc(100vw - 28px);
  }

  .hero {
    min-height: 560px;
  }

  .topbar {
    display: grid;
    gap: 18px;
  }

  .brand {
    flex-wrap: wrap;

    img {
      width: 220px;
    }
  }

  .platform-name {
    font-size: 24px;
  }

  .hero-copy {
    margin-top: 42px;

    h1 {
      font-size: 38px;
    }
  }

  .top-grid,
  .guide-card,
  .status-grid {
    grid-template-columns: 1fr;
  }

  .qr-box {
    padding-bottom: 24px;
    margin-bottom: 24px;
    border-right: 0;
    border-bottom: 1px solid #e5eaf2;
  }

  .float-tools {
    display: none;
  }
}
</style>
