<template>
  <div class="portal-gov">
    <header class="portal-header">
      <div class="header-inner">
        <a class="brand" href="#/portal-gov" aria-label="国宏规划院招采服务平台">
          <span class="brand-logo">
            <img src="@/assets/guohong/logo.png" alt="" />
          </span>
          <span class="brand-main">国宏规划院</span>
          <span class="brand-line"></span>
          <span class="brand-platform">招采服务平台</span>
          <span class="brand-sub">公开 · 规范 · 高效 · 可信</span>
        </a>

        <nav class="nav">
          <a class="is-active" href="#/portal-gov">首页</a>
          <a href="#bid">招标公告</a>
          <a href="#platform">平台公告</a>
          <a href="#result">中标公示</a>
          <a href="#expert">专家服务</a>
          <a href="#supplier">供应商服务</a>
          <a href="#clean">公正廉洁</a>
          <a href="#contact">联系我们</a>
        </nav>

        <div class="header-actions">
          <button type="button" class="btn-register" @click="goRole('supplier')">注册</button>
          <button type="button" class="btn-login" @click="goRole(loginRole)">登录</button>
        </div>
      </div>
    </header>

    <main class="portal-main">
      <section class="hero">
        <div class="hero-copy">
          <h1>规范招采　高效协同　公开透明</h1>
          <p class="hero-tags">公开 · 规范 · 高效 · 可信</p>
          <p class="hero-desc">打造公平、公正、公开的招标采购服务平台</p>
          <div class="hero-dots"><span></span><i></i><i></i><i></i></div>
        </div>

        <div class="temple-sign">祈年殿</div>

        <aside class="login-box">
          <div class="login-tabs">
            <button type="button" :class="{ active: loginRole === 'supplier' }" @click="loginRole = 'supplier'">供应商登录</button>
            <button type="button" :class="{ active: loginRole === 'expert' }" @click="loginRole = 'expert'">专家登录</button>
          </div>
          <div class="login-form">
            <label><el-icon><User /></el-icon><input placeholder="请输入用户名" /></label>
            <label><el-icon><Lock /></el-icon><input type="password" placeholder="请输入密码" /></label>
            <div class="code-line">
              <label><el-icon><Message /></el-icon><input placeholder="请输入验证码" /></label>
              <b>7328</b>
            </div>
            <button type="button" class="login-submit" @click="goRole(loginRole)">立即登录</button>
          </div>
          <div class="login-links">
            <button type="button" @click="goRole('supplier')">供应商注册</button>
            <button type="button">忘记密码?</button>
          </div>
        </aside>
      </section>

      <section class="quick-row">
        <button v-for="item in quickItems" :key="item.title" type="button" class="quick-item" @click="item.action">
          <span class="quick-icon"><el-icon><component :is="item.icon" /></el-icon></span>
          <span class="quick-text"><strong>{{ item.title }}</strong><em>{{ item.desc }}</em></span>
        </button>
      </section>

      <section class="flow-row">
        <div class="cloud-bg"></div>
        <h2>入库办理流程</h2>
        <div class="flow-steps">
          <div v-for="step in steps" :key="step.no" class="flow-step">
            <span class="step-icon"><el-icon><component :is="step.icon" /></el-icon></span>
            <div class="step-copy">
              <b>{{ step.no }}</b>
              <strong>{{ step.title }}</strong>
              <p>{{ step.desc }}</p>
            </div>
          </div>
        </div>
        <div class="flow-guide">
          <img src="@/assets/ewm.png" alt="入库指南二维码" />
          <div><strong>扫码查看<br />入库指南</strong><p>快速了解入库流程</p></div>
        </div>
      </section>

      <section class="notice-row">
        <PanelCard id="bid" title="招标公告" icon-class="doc" :items="bidNotices" />
        <PanelCard id="platform" title="平台公告" icon-class="notice" :items="platformNotices" />
      </section>

      <section class="bottom-row">
        <DataPanel id="supplier" title="供应商入库动态" :columns="supplierColumns" :rows="supplierRows" />
        <DataPanel id="expert" title="专家入库动态" :columns="expertColumns" :rows="expertRows" />

        <aside class="service-panel">
          <PanelTitle title="常用服务" />
          <button v-for="item in services" :key="item.title" type="button" class="service-item">
            <span :class="['service-icon', item.color]"><el-icon><component :is="item.icon" /></el-icon></span>
            <span><strong>{{ item.title }}</strong><em>{{ item.desc }}</em></span>
            <b>›</b>
          </button>
        </aside>
      </section>
    </main>

    <footer id="contact" class="footer">
      <div class="footer-inner">
        <div class="footer-brand">
          <span class="footer-logo"><img src="@/assets/guohong/logo.png" alt="" /></span>
          <strong>国宏规划院<br />招采服务平台</strong>
        </div>
        <div class="footer-contact">
          <h3>联系我们</h3>
          <p><el-icon><Phone /></el-icon>15946668530</p>
          <p><el-icon><Message /></el-icon>Beijingguohong1128@163.com</p>
          <p><el-icon><Location /></el-icon>北京市通州区西富门北大街45-9号</p>
        </div>
        <div class="footer-links">
          <h3>快速链接</h3>
          <div>
            <a>关于我们</a><a>友情链接</a><a>政策法规</a>
            <a>隐私政策</a><a>服务条款</a><a>网站地图</a>
          </div>
        </div>
        <div class="footer-follow">
          <h3>关注我们</h3>
          <p>官方公众号<br />获取最新资讯动态</p>
          <img src="@/assets/ewm.png" alt="二维码" />
        </div>
      </div>
      <div class="copyright">Copyright © 2026 国宏规划院有限公司　京ICP备2021099419号-1　京公网安备 11010802012345号</div>
    </footer>
  </div>
</template>

<script setup>
import { defineComponent, h, ref } from "vue";
import { useRouter } from "vue-router";
import {
  Check,
  DocumentChecked,
  Finished,
  Headset,
  Location,
  Lock,
  Medal,
  Message,
  OfficeBuilding,
  Phone,
  Promotion,
  Reading,
  ScaleToOriginal,
  Tickets,
  User,
  Wallet,
} from "@element-plus/icons-vue";

const router = useRouter();
const loginRole = ref("supplier");

const goRole = (role) => {
  router.push({ path: "/application/dashboard", query: { role } });
};

const quickItems = [
  { title: "供应商入库", desc: "申请成为供应商", icon: OfficeBuilding, action: () => goRole("supplier") },
  { title: "专家入库", desc: "申请成为专家", icon: User, action: () => goRole("expert") },
  { title: "招标公告", desc: "查看最新公告", icon: Tickets, action: () => document.getElementById("bid")?.scrollIntoView({ behavior: "smooth" }) },
  { title: "中标公示", desc: "查看中标结果", icon: Medal, action: () => document.getElementById("result")?.scrollIntoView({ behavior: "smooth" }) },
  { title: "公正廉洁", desc: "廉洁从业监督", icon: ScaleToOriginal, action: () => document.getElementById("clean")?.scrollIntoView({ behavior: "smooth" }) },
  { title: "帮助中心", desc: "常见问题解答", icon: Headset, action: () => document.getElementById("contact")?.scrollIntoView({ behavior: "smooth" }) },
];

const steps = [
  { no: "01", title: "注册 / 登录", desc: "注册账号并登录平台", icon: User },
  { no: "02", title: "填写信息并上传材料", desc: "完善基础信息，上传相关证明材料", icon: DocumentChecked },
  { no: "03", title: "平台审核", desc: "平台对提交信息进行审核", icon: Finished },
  { no: "04", title: "完成入库", desc: "审核通过后完成入库", icon: Check },
];

const bidNotices = [
  { title: "国宏规划院办公楼装修改造项目招标公告", date: "05-25" },
  { title: "国宏规划院信息化系统建设项目招标公告", date: "05-20" },
  { title: "国宏规划院园林景观设计项目招标公告", date: "05-18" },
  { title: "国宏规划院物业服务项目招标公告", date: "05-15" },
  { title: "国宏规划院会议设备采购项目招标公告", date: "05-10" },
];

const platformNotices = [
  { title: "关于系统升级维护的通知", date: "05-25" },
  { title: "关于开展供应商信息核验工作的通知", date: "05-20" },
  { title: "关于电子招投标系统操作培训的通知", date: "05-18" },
  { title: "关于阳光采购服务安排的通知", date: "05-15" },
  { title: "关于优化平台用户体验的公告", date: "05-10" },
];

const supplierColumns = ["企业名称", "入库类型", "状态", "入库时间"];
const supplierRows = [
  ["中建****工程有限公司", "供应商入库", "审核通过", "05-25 11:20"],
  ["北京****科技有限公司", "供应商入库", "审核通过", "05-25 10:45"],
  ["华建****建设有限公司", "供应商入库", "审核通过", "05-25 10:30"],
  ["国投****工程有限公司", "供应商入库", "审核通过", "05-24 16:55"],
];

const expertColumns = ["专家姓名", "专业领域", "职称/服务", "状态", "申请时间"];
const expertRows = [
  ["张*专家", "建筑学", "高级建筑师", "新入库", "05-25 10:30"],
  ["李*专家", "自动化", "高级工程师", "新入库", "05-25 09:20"],
  ["王*专家", "机械设计与制造", "高级工程师", "新入库", "05-24 16:40"],
  ["赵*专家", "经济管理", "高级会计师", "新入库", "05-24 11:08"],
];

const services = [
  { title: "入库办理指引", desc: "查看专家、供应商入库流程", icon: Reading, color: "red" },
  { title: "电子招投标系统", desc: "点击进入系统", icon: Tickets, color: "blue" },
  { title: "操作指南", desc: "平台操作手册下载", icon: DocumentChecked, color: "orange" },
  { title: "常见问题", desc: "解答平台使用常见问题", icon: Message, color: "purple" },
];

const PanelTitle = defineComponent({
  props: { title: { type: String, required: true } },
  setup(props) {
    return () => h("div", { class: "panel-title" }, [h("strong", props.title), h("a", "更多 >")]);
  },
});

const PanelCard = defineComponent({
  props: {
    title: { type: String, required: true },
    iconClass: { type: String, required: true },
    items: { type: Array, required: true },
  },
  setup(props) {
    return () => h("article", { class: "panel-card" }, [
      h("div", { class: "panel-title" }, [
        h("span", { class: ["title-icon", props.iconClass] }),
        h("strong", props.title),
        h("a", "更多 >"),
      ]),
      h("ul", { class: "notice-list" }, props.items.map((item) =>
        h("li", { key: item.title }, [h("i"), h("span", item.title), h("time", item.date)])
      )),
    ]);
  },
});

const DataPanel = defineComponent({
  props: {
    title: { type: String, required: true },
    columns: { type: Array, required: true },
    rows: { type: Array, required: true },
  },
  setup(props) {
    return () => h("article", { class: "data-panel" }, [
      h(PanelTitle, { title: props.title }),
      h("table", [
        h("thead", [h("tr", props.columns.map((col) => h("th", { key: col }, col)))]),
        h("tbody", props.rows.map((row, rowIndex) =>
          h("tr", { key: rowIndex }, row.map((cell, cellIndex) =>
            h("td", { key: `${rowIndex}-${cellIndex}` }, cellIndex === row.length - 2 ? h("span", { class: "pass" }, cell) : cell)
          ))
        )),
      ]),
    ]);
  },
});
</script>

<style lang="scss" scoped>
.portal-gov,
.portal-gov * {
  box-sizing: border-box;
}

.portal-gov {
  --gov-red: #b90412;
  --gov-red-dark: #93000c;
  --gov-red-bright: #d30b19;
  min-height: 100vh;
  color: #151922;
  background: #f6f7fb;
  font-family: "Microsoft YaHei", "PingFang SC", Arial, sans-serif;
}

.portal-header {
  height: 68px;
  background: #fff;
  border-bottom: 1px solid #eef0f5;
}

.header-inner {
  display: flex;
  align-items: center;
  width: 1500px;
  height: 68px;
  margin: 0 auto;
}

.brand {
  position: relative;
  display: grid;
  grid-template-columns: 42px auto 1px auto;
  gap: 12px;
  align-items: center;
  width: 385px;
  height: 68px;
  color: #111827;
  text-decoration: none;
}

.brand-logo {
  width: 42px;
  height: 42px;
  overflow: hidden;

  img {
    width: 162px;
    height: 42px;
    object-fit: cover;
    object-position: left center;
  }
}

.brand-main,
.brand-platform {
  font-size: 23px;
  font-weight: 900;
  white-space: nowrap;
}

.brand-line {
  width: 1px;
  height: 28px;
  background: #cfd3dd;
}

.brand-sub {
  position: absolute;
  left: 64px;
  bottom: 5px;
  color: #2f3745;
  font-size: 14px;
  letter-spacing: 4px;
  white-space: nowrap;
}

.nav {
  display: flex;
  flex: 1;
  justify-content: center;
  gap: 37px;

  a {
    position: relative;
    height: 68px;
    color: #111827;
    text-decoration: none;
    font-size: 15px;
    font-weight: 800;
    line-height: 68px;
    white-space: nowrap;

    &.is-active,
    &:hover {
      color: #b60012;
    }

    &.is-active::after,
    &:hover::after {
      position: absolute;
      right: 10px;
      bottom: 13px;
      left: 10px;
      height: 3px;
      content: "";
      background: #d50014;
      border-radius: 99px;
    }
  }
}

.header-actions {
  display: flex;
  gap: 14px;
}

.btn-register,
.btn-login {
  width: 78px;
  height: 36px;
  cursor: pointer;
  border-radius: 5px;
  font-size: 15px;
  font-weight: 800;
}

.btn-register {
  color: #b60012;
  background: #fff;
  border: 1px solid #c90015;
}

.btn-login {
  color: #fff;
  background: linear-gradient(180deg, #d80b1d, #af0012);
  border: 0;
  box-shadow: 0 8px 18px rgba(177, 0, 18, 0.22);
}

.portal-main {
  width: 1500px;
  margin: 0 auto;
}

.hero {
  position: relative;
  height: 250px;
  overflow: hidden;
  background-image:
    linear-gradient(90deg, rgba(178, 0, 15, 0.98) 0%, rgba(178, 0, 15, 0.94) 27%, rgba(178, 0, 15, 0.32) 47%, rgba(178, 0, 15, 0.03) 68%, rgba(178, 0, 15, 0.38) 100%),
    url("@/assets/guohong/hero-cultural-1.jpg"),
    linear-gradient(90deg, #b90412 0%, #b90412 45%, #c74234 100%);
  background-repeat: no-repeat;
  background-position: left top, right 250px 14%, left top;
  background-size: 100% 100%, 760px auto, 100% 100%;
  border-radius: 8px;
}

.hero::after {
  position: absolute;
  inset: 0;
  pointer-events: none;
  content: "";
  background:
    linear-gradient(90deg, rgba(151, 0, 11, 0.28) 0 26%, transparent 26% 100%),
    linear-gradient(90deg, transparent 0 72%, rgba(120, 0, 8, 0.08) 72% 100%);
}

.hero-copy {
  position: absolute;
  z-index: 1;
  top: 62px;
  left: 88px;
  color: #fff;

  h1 {
    margin: 0;
    font-size: 34px;
    line-height: 1.2;
    font-weight: 900;
    letter-spacing: 2px;
  }
}

.hero-tags {
  margin: 15px 0 0;
  font-size: 18px;
  font-weight: 800;
  letter-spacing: 5px;
}

.hero-desc {
  margin: 15px 0 0;
  font-size: 16px;
}

.hero-dots {
  display: flex;
  gap: 12px;
  margin-top: 39px;

  span,
  i {
    width: 12px;
    height: 12px;
    background: #fff;
    border-radius: 50%;
  }

  span {
    width: 24px;
    background: #ff2d24;
    box-shadow: 0 0 13px rgba(255, 45, 36, 0.75);
  }
}

.temple-sign {
  position: absolute;
  z-index: 1;
  top: 48px;
  right: 587px;
  display: grid;
  width: 62px;
  height: 88px;
  place-items: center;
  color: #ffd071;
  background: linear-gradient(180deg, #9d0710, #790008);
  border: 3px solid #d2a053;
  box-shadow: inset 0 0 0 2px rgba(255, 224, 143, 0.35);
  font-size: 18px;
  font-weight: 900;
  writing-mode: vertical-rl;
}

.login-box {
  position: absolute;
  z-index: 2;
  top: 12px;
  right: 54px;
  width: 287px;
  height: 236px;
  padding: 14px 18px 12px;
  background: rgba(255, 255, 255, 0.94);
  border-radius: 7px;
  box-shadow: 0 14px 30px rgba(71, 17, 18, 0.18);
}

.login-tabs {
  display: grid;
  grid-template-columns: 1fr 1fr;
  height: 35px;
  border-bottom: 1px solid #e6d6d8;

  button {
    position: relative;
    color: #252b36;
    cursor: pointer;
    background: transparent;
    border: 0;
    font-size: 14px;
    font-weight: 800;

    &.active {
      color: #b60012;
    }

    &.active::after {
      position: absolute;
      right: 26px;
      bottom: -1px;
      left: 26px;
      height: 3px;
      content: "";
      background: #c90015;
    }
  }
}

.login-form {
  display: grid;
  gap: 7px;
  margin-top: 10px;

  label {
    display: flex;
    align-items: center;
    height: 32px;
    color: #949aa6;
    background: #fff;
    border: 1px solid #e4e8ef;
  }

  .el-icon {
    margin: 0 9px;
  }

  input {
    flex: 1;
    min-width: 0;
    outline: none;
    border: 0;
    font-size: 12px;
  }
}

.code-line {
  display: grid;
  grid-template-columns: 1fr 68px;
  gap: 8px;

  b {
    display: grid;
    height: 32px;
    place-items: center;
    color: #151922;
    background: #f8f6f4;
    border: 1px solid #e4e8ef;
    font-size: 18px;
  }
}

.login-submit {
  height: 32px;
  color: #fff;
  cursor: pointer;
  background: linear-gradient(180deg, #d80b1d, #b50013);
  border: 0;
  border-radius: 3px;
  font-size: 14px;
  font-weight: 800;
}

.login-links {
  display: flex;
  justify-content: space-between;
  margin-top: 9px;

  button {
    color: #b60012;
    cursor: pointer;
    background: transparent;
    border: 0;
    font-size: 12px;
  }
}

.quick-row,
.flow-row,
.panel-card,
.data-panel,
.service-panel {
  background: #fff;
  border: 1px solid #edf0f5;
  box-shadow: 0 8px 24px rgba(30, 42, 66, 0.055);
}

.quick-row {
  display: grid;
  grid-template-columns: repeat(6, 1fr);
  width: 1426px;
  height: 72px;
  margin: 12px auto 0;
}

.quick-item {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 14px;
  cursor: pointer;
  background: transparent;
  border: 0;
  border-right: 1px solid #edf0f5;
  text-align: left;

  &:last-child {
    border-right: 0;
  }

  strong,
  em {
    display: block;
  }

  strong {
    color: #151922;
    font-size: 16px;
    font-weight: 900;
  }

  em {
    margin-top: 5px;
    color: #626b7a;
    font-size: 13px;
    font-style: normal;
  }
}

.quick-icon {
  display: grid;
  width: 43px;
  height: 43px;
  place-items: center;
  color: #c70015;
  background: radial-gradient(circle, #fff 0 45%, #fff0f2 46% 100%);
  border-radius: 50%;
  font-size: 24px;
}

.flow-row {
  position: relative;
  display: grid;
  grid-template-columns: 220px 1fr 240px;
  align-items: center;
  width: 1426px;
  height: 118px;
  margin: 12px auto 0;
  overflow: hidden;

  h2 {
    position: relative;
    z-index: 1;
    margin: 0 0 0 26px;
    font-size: 18px;
    font-weight: 900;
  }
}

.cloud-bg {
  position: absolute;
  top: 12px;
  bottom: 12px;
  left: 0;
  width: 360px;
  opacity: 0.16;
  background-image: url("data:image/svg+xml,%3Csvg width='360' height='96' viewBox='0 0 360 96' fill='none' xmlns='http://www.w3.org/2000/svg'%3E%3Cg stroke='%23CFA978' stroke-width='1.2'%3E%3Cpath d='M-26 88C22 44 80 44 128 88'/%3E%3Cpath d='M-8 88C34 54 84 54 126 88'/%3E%3Cpath d='M10 88C46 64 86 64 122 88'/%3E%3Cpath d='M50 88C100 32 170 32 220 88'/%3E%3Cpath d='M72 88C116 46 170 46 214 88'/%3E%3Cpath d='M94 88C132 60 172 60 210 88'/%3E%3Cpath d='M160 88C206 42 264 42 310 88'/%3E%3Cpath d='M180 88C220 56 266 56 306 88'/%3E%3Cpath d='M200 88C232 68 268 68 300 88'/%3E%3Ccircle cx='116' cy='54' r='18'/%3E%3Ccircle cx='156' cy='48' r='24'/%3E%3Ccircle cx='238' cy='58' r='17'/%3E%3C/g%3E%3C/svg%3E");
  background-repeat: no-repeat;
  background-position: left bottom;
  background-size: 360px 96px;
}

.flow-steps {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 32px;
  min-width: 0;
}

.flow-step {
  position: relative;
  display: flex;
  align-items: center;
  gap: 12px;

  &:not(:last-child)::after {
    position: absolute;
    top: 42px;
    right: -32px;
    width: 54px;
    height: 1px;
    content: "";
    background: #c70015;
  }

  &:not(:last-child)::before {
    position: absolute;
    top: 38px;
    right: -35px;
    width: 8px;
    height: 8px;
    content: "";
    border-top: 1px solid #c70015;
    border-right: 1px solid #c70015;
    transform: rotate(45deg);
  }
}

.step-icon {
  display: grid;
  flex: 0 0 auto;
  width: 50px;
  height: 50px;
  place-items: center;
  color: #c70015;
  background: #fff;
  border: 1px solid #f1dce0;
  border-radius: 50%;
  box-shadow: 0 8px 20px rgba(30, 42, 66, 0.08);
  font-size: 25px;
}

.step-copy {
  b,
  strong,
  p {
    display: block;
  }

  b {
    color: #c70015;
    font-size: 14px;
    line-height: 1;
  }

  strong {
    margin-top: 6px;
    font-size: 14px;
    font-weight: 900;
    line-height: 1.2;
  }

  p {
    margin: 6px 0 0;
    color: #7a8190;
    font-size: 12px;
    line-height: 1.35;
  }
}

.flow-guide {
  display: flex;
  align-items: center;
  gap: 18px;
  padding-left: 26px;
  border-left: 1px solid #edf0f5;

  img {
    width: 72px;
    height: 72px;
    object-fit: cover;
  }

  strong {
    font-size: 16px;
    line-height: 1.4;
  }

  p {
    margin: 7px 0 0;
    color: #7a8190;
    font-size: 12px;
  }
}

.notice-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 24px;
  width: 1390px;
  margin: 14px auto 0;
}

.panel-card {
  height: 160px;
  padding: 16px 32px;
}

.panel-title {
  display: flex;
  align-items: center;
  gap: 8px;
  height: 22px;

  strong {
    font-size: 16px;
    font-weight: 900;
  }

  a {
    margin-left: auto;
    color: #252b36;
    font-size: 12px;
  }
}

.title-icon {
  position: relative;
  display: grid;
  width: 18px;
  height: 18px;
  place-items: center;
  color: #c70015;
  border: 2px solid currentColor;
  border-radius: 2px;

  &::before,
  &::after {
    position: absolute;
    content: "";
  }

  &.doc::before {
    top: 4px;
    left: 4px;
    width: 7px;
    height: 2px;
    background: currentColor;
    box-shadow: 0 4px 0 currentColor, 0 8px 0 currentColor;
  }

  &.notice {
    width: 19px;
    height: 15px;
    border-radius: 10px 2px 2px 10px;

    &::before {
      right: -5px;
      bottom: -4px;
      width: 7px;
      height: 2px;
      background: currentColor;
      transform: rotate(55deg);
    }
  }
}

.notice-list {
  display: grid;
  gap: 8px;
  padding: 10px 0 0;
  margin: 0;
  list-style: none;

  li {
    display: grid;
    grid-template-columns: 8px minmax(0, 1fr) 46px;
    align-items: center;
    gap: 8px;
    color: #151922;
    font-size: 14px;
    line-height: 1.2;
  }

  i {
    width: 5px;
    height: 5px;
    background: #c70015;
    border-radius: 50%;
  }

  span {
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
  }

  time {
    color: #414958;
    text-align: right;
  }
}

.bottom-row {
  display: grid;
  grid-template-columns: 1fr 1fr 360px;
  gap: 24px;
  width: 1390px;
  margin: 16px auto 28px;
}

.data-panel,
.service-panel {
  height: 178px;
  padding: 16px 28px;
}

table {
  width: 100%;
  margin-top: 10px;
  border-collapse: collapse;
  font-size: 12px;

  th,
  td {
    height: 27px;
    border-bottom: 1px solid #edf0f5;
    text-align: left;
  }

  th {
    color: #4c5564;
    font-weight: 700;
    background: #fbfcfe;
  }
}

.pass {
  display: inline-flex;
  padding: 0 6px;
  color: #17a45d;
  background: #eaf8f0;
  border-radius: 2px;
}

.service-panel {
  display: grid;
  align-content: start;
}

.service-item {
  display: grid;
  grid-template-columns: 32px 1fr 18px;
  align-items: center;
  gap: 12px;
  height: 32px;
  cursor: pointer;
  background: transparent;
  border: 0;
  border-bottom: 1px solid #edf0f5;
  text-align: left;

  strong,
  em {
    display: block;
  }

  strong {
    font-size: 14px;
    font-weight: 900;
  }

  em {
    color: #7a8190;
    font-size: 11px;
    font-style: normal;
  }

  b {
    color: #525a68;
    font-size: 22px;
    font-weight: 400;
  }
}

.service-icon {
  display: grid;
  width: 28px;
  height: 28px;
  place-items: center;
  color: #fff;
  border-radius: 5px;

  &.red { background: #dd3a2d; }
  &.blue { background: #4aa3f0; }
  &.orange { background: #f2962b; }
  &.purple { background: #8063df; }
}

.footer {
  background: #fff;
  border-top: 1px solid #edf0f5;
}

.footer-inner {
  display: grid;
  grid-template-columns: 260px 340px 1fr 260px;
  gap: 26px;
  width: 1390px;
  height: 112px;
  margin: 0 auto;
  padding: 20px 0 16px;
}

.footer-brand {
  display: flex;
  align-items: center;
  gap: 16px;
  padding-left: 38px;
  border-right: 1px solid #e5e8ef;

  strong {
    font-size: 22px;
    line-height: 1.35;
  }
}

.footer-logo {
  width: 56px;
  height: 56px;
  overflow: hidden;

  img {
    width: 216px;
    height: 56px;
    object-fit: cover;
    object-position: left center;
  }
}

.footer-contact,
.footer-links,
.footer-follow {
  h3 {
    margin: 0 0 8px;
    font-size: 16px;
  }

  p,
  a {
    color: #4c5564;
    font-size: 12px;
  }

  p {
    display: flex;
    align-items: center;
    gap: 7px;
    margin: 5px 0;
  }
}

.footer-links div {
  display: grid;
  grid-template-columns: repeat(3, 80px);
  gap: 9px 32px;
}

.footer-follow {
  position: relative;
  padding-right: 92px;

  img {
    position: absolute;
    top: 0;
    right: 0;
    width: 82px;
    height: 82px;
    object-fit: cover;
  }
}

.copyright {
  height: 34px;
  color: #4c5564;
  text-align: center;
  border-top: 1px solid #f0f2f6;
  font-size: 12px;
  line-height: 34px;
}

:deep(.panel-title) {
  display: flex;
  align-items: center;
  gap: 8px;
  height: 22px;

  strong {
    font-size: 16px;
    font-weight: 900;
  }

  a {
    margin-left: auto;
    color: #252b36;
    font-size: 12px;
  }
}

:deep(.title-icon) {
  position: relative;
  display: grid;
  width: 18px;
  height: 18px;
  place-items: center;
  color: #c70015;
  border: 2px solid currentColor;
  border-radius: 2px;

  &::before,
  &::after {
    position: absolute;
    content: "";
  }

  &.doc::before {
    top: 4px;
    left: 4px;
    width: 7px;
    height: 2px;
    background: currentColor;
    box-shadow: 0 4px 0 currentColor, 0 8px 0 currentColor;
  }

  &.notice {
    width: 19px;
    height: 15px;
    border-radius: 10px 2px 2px 10px;

    &::before {
      right: -5px;
      bottom: -4px;
      width: 7px;
      height: 2px;
      background: currentColor;
      transform: rotate(55deg);
    }
  }
}

:deep(.notice-list) {
  display: grid;
  gap: 8px;
  padding: 10px 0 0;
  margin: 0;
  list-style: none;

  li {
    display: grid;
    grid-template-columns: 8px minmax(0, 1fr) 46px;
    align-items: center;
    gap: 8px;
    color: #151922;
    font-size: 14px;
    line-height: 1.2;
  }

  i {
    width: 5px;
    height: 5px;
    background: #c70015;
    border-radius: 50%;
  }

  span {
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
  }

  time {
    color: #414958;
    text-align: right;
  }
}

:deep(table) {
  width: 100%;
  margin-top: 10px;
  border-collapse: collapse;
  font-size: 12px;

  th,
  td {
    height: 27px;
    border-bottom: 1px solid #edf0f5;
    text-align: left;
  }

  th {
    color: #4c5564;
    font-weight: 700;
    background: #fbfcfe;
  }
}

:deep(.pass) {
  display: inline-flex;
  padding: 0 6px;
  color: #17a45d;
  background: #eaf8f0;
  border-radius: 2px;
}

@media (max-width: 1535px) {
  .header-inner,
  .portal-main {
    width: 100%;
  }

  .brand {
    margin-left: 18px;
  }

  .header-actions {
    margin-right: 18px;
  }

  .nav {
    gap: clamp(14px, 2.2vw, 37px);
  }
}
</style>
