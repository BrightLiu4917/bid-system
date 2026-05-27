<template>
  <div class="role-dashboard">
    <header class="topbar">
      <div class="brand">
        <img src="@/assets/guohong/logo.png" alt="北京国宏规划院" />
        <span></span>
        <b>{{ roleMeta.platformTitle }}</b>
      </div>
      <div class="top-actions">
        <button v-if="role === 'supplier' || role === 'expert'" class="notice-bell" type="button" @click="openNoticeCenter">
          <el-icon><Bell /></el-icon>
          <span v-if="noticeUnreadCount" class="notice-badge">{{ noticeUnreadCount }}</span>
        </button>
        <el-tag effect="dark" class="role-tag">{{ roleMeta.name }}</el-tag>
        <el-button @click="goPortal">返回门户</el-button>
      </div>
    </header>

    <div class="layout">
      <aside class="sidebar">
        <div class="user-card">
          <div class="avatar">{{ roleMeta.avatar }}</div>
          <div>
            <strong>{{ roleMeta.userName }}</strong>
            <span>{{ roleMeta.desc }}</span>
          </div>
        </div>

        <el-menu :default-active="activeMenu" class="side-menu">
          <el-menu-item
            v-for="item in menus"
            :key="item.key"
            :index="item.key"
            @click="activeMenu = item.key"
          >
            <el-icon><component :is="item.icon" /></el-icon>
            <span>{{ item.label }}</span>
          </el-menu-item>
        </el-menu>
      </aside>

      <main class="main">
        <template v-if="isApplicationPage">
          <application-steps />
          <application-tabs :type="role" :materials="role === 'expert' ? expertMaterials : supplierMaterials" />
        </template>

        <template v-else>
          <section class="hero-panel">
            <div>
              <el-breadcrumb separator="/">
                <el-breadcrumb-item>{{ roleMeta.name }}</el-breadcrumb-item>
                <el-breadcrumb-item>{{ currentMenuLabel }}</el-breadcrumb-item>
              </el-breadcrumb>
              <h1>{{ currentPageTitle }}</h1>
              <p>{{ currentPageDesc }}</p>
            </div>
          </section>

          <section v-if="showStats" class="stat-row">
            <div v-for="item in roleStats" :key="item.label" class="stat-card">
              <el-icon><component :is="item.icon" /></el-icon>
              <div>
                <b>{{ item.value }}</b>
                <span>{{ item.label }}</span>
              </div>
            </div>
          </section>

          <template v-if="role === 'supplier'">
            <supplier-overview v-if="activeMenu === 'overview'" />
            <notice-panel
              v-else-if="activeMenu === 'tenders'"
              title="招标公告"
              :rows="supplierTenderRows"
              action-label="查看详情"
            />
            <bid-submit-panel v-else-if="activeMenu === 'bidSubmit'" />
            <notice-list-panel v-else-if="activeMenu === 'notice'" :messages="supplierMessages" />
          </template>

          <template v-else-if="role === 'expert'">
            <notice-list-panel v-if="activeMenu === 'notice'" :messages="expertMessages" />
          </template>

          <template v-else>
            <admin-overview v-if="activeMenu === 'overview'" />
            <admin-audit-panel
              v-else-if="activeMenu === 'supplierAudit'"
              title="供应商入库审核"
              :rows="supplierAuditRows"
              type="supplier"
            />
            <admin-audit-panel
              v-else-if="activeMenu === 'expertAudit'"
              title="专家入库审核"
              :rows="expertAuditRows"
              type="expert"
            />
            <announcement-panel v-else-if="activeMenu === 'announcement'" />
            <admin-audit-panel
              v-else-if="activeMenu === 'bidAudit'"
              title="投标资料审核"
              :rows="bidSubmissionRows"
              type="bid"
            />
          </template>
        </template>
      </main>
    </div>

    <el-dialog
      v-model="previewDialog.visible"
      :title="previewDialog.title || '文件预览'"
      width="760px"
      class="file-preview-dialog"
      @closed="closePreviewDialog"
    >
      <img
        v-if="previewDialog.type === 'image'"
        :src="previewDialog.url"
        class="preview-image"
        :alt="previewDialog.title"
      />
      <iframe
        v-else
        :src="previewDialog.url"
        class="preview-frame"
        :title="previewDialog.title"
      />
      <template #footer>
        <el-button type="primary" @click="previewDialog.visible = false">关闭</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { computed, defineComponent, h, reactive, ref, watch } from "vue";
import { useRoute, useRouter } from "vue-router";
import { ElButton, ElCard, ElCol, ElDescriptions, ElDescriptionsItem, ElDialog, ElForm, ElFormItem, ElIcon, ElInput, ElMessage, ElOption, ElPagination, ElRow, ElSelect, ElTabPane, ElTable, ElTableColumn, ElTabs, ElTag } from "element-plus";
import {
  Bell,
  CircleCheck,
  DataBoard,
  Document,
  EditPen,
  Files,
  Finished,
  FolderOpened,
  List,
  OfficeBuilding,
  Reading,
  Tickets,
  User,
} from "@element-plus/icons-vue";

const route = useRoute();
const router = useRouter();

const role = computed(() => {
  const value = route.query.role;
  return ["supplier", "expert", "admin"].includes(value) ? value : "supplier";
});

const activeMenu = ref("entry");

watch(
  role,
  () => {
    activeMenu.value = role.value === "expert" ? "profile" : role.value === "supplier" ? "entry" : "overview";
  },
  { immediate: true }
);

const roleMetaMap = {
  supplier: {
    name: "供应商后台",
    avatar: "供",
    userName: "供应商申报人",
    desc: "入库申请 / 投标资料",
    platformTitle: "供应商后台",
  },
  expert: {
    name: "专家后台",
    avatar: "专",
    userName: "专家申报人",
    desc: "专家入库 / 平台消息",
    platformTitle: "专家后台",
  },
  admin: {
    name: "平台管理员后台",
    avatar: "管",
    userName: "平台管理员",
    desc: "审核 / 公告 / 投标资料",
    platformTitle: "平台管理后台",
  },
};

const menuMap = {
  supplier: [
    { key: "entry", label: "入库申请", icon: EditPen },
    { key: "tenders", label: "招标公告", icon: List },
    { key: "bidSubmit", label: "投标资料提交", icon: FolderOpened },
    { key: "notice", label: "消息通知", icon: Bell },
  ],
  expert: [
    { key: "profile", label: "入库申请", icon: EditPen },
    { key: "notice", label: "消息通知", icon: Bell },
  ],
  admin: [
    { key: "overview", label: "管理工作台", icon: DataBoard },
    { key: "supplierAudit", label: "供应商审核", icon: OfficeBuilding },
    { key: "expertAudit", label: "专家审核", icon: User },
    { key: "announcement", label: "公告管理", icon: Document },
    { key: "bidAudit", label: "投标资料审核", icon: FolderOpened },
  ],
};

const pageCopyMap = {
  supplier: {
    entry: ["入库申请", "填写企业基础信息、上传附件、提交审核，并查看审核记录。"],
    tenders: ["招标公告", "查看平台发布的招标公告和投标模板。"],
    bidSubmit: ["投标资料提交", "按公告下载模板并上传投标资料，等待平台审核。"],
    notice: ["消息通知", "查看平台通知、驳回原因和资料补充提醒。"],
  },
  expert: {
    profile: ["入库申请", "填写专家基础信息、上传附件、提交审核，并查看审核记录。"],
    notice: ["消息通知", "查看平台发送的通知、驳回原因和资料补充提醒。"],
  },
  admin: {
    overview: ["管理工作台", "查看供应商、专家、公告和投标资料的待办事项。"],
    supplierAudit: ["供应商入库审核", "审核供应商基础信息和附件材料，生成入库结果。"],
    expertAudit: ["专家入库审核", "审核专家基础信息、证书材料和入库类别。"],
    announcement: ["公告管理", "发布平台招标公告、供应商入库公告和专家入库公告。"],
    bidAudit: ["投标资料审核", "按招标公告查看供应商投标资料并进行审核批注。"],
  },
};

const roleMeta = computed(() => roleMetaMap[role.value]);
const menus = computed(() => menuMap[role.value]);
const currentMenuLabel = computed(() => menus.value.find((item) => item.key === activeMenu.value)?.label || "");
const currentPageTitle = computed(() => pageCopyMap[role.value][activeMenu.value]?.[0] || currentMenuLabel.value);
const currentPageDesc = computed(() => pageCopyMap[role.value][activeMenu.value]?.[1] || "");
const isApplicationPage = computed(() => (role.value === "supplier" && activeMenu.value === "entry") || (role.value === "expert" && activeMenu.value === "profile"));

const statMap = {
  supplier: [
    { label: "入库资料待完善", value: 4, icon: Files },
    { label: "可投公告", value: 6, icon: Document },
    { label: "投标资料待审核", value: 1, icon: Tickets },
    { label: "平台通知", value: 2, icon: Bell },
  ],
  expert: [
    { label: "专家资料待完善", value: 4, icon: Files },
    { label: "必传附件待上传", value: 5, icon: Document },
    { label: "入库审核中", value: 0, icon: Tickets },
    { label: "未读消息", value: 2, icon: Bell },
  ],
  admin: [
    { label: "供应商待审核", value: 18, icon: OfficeBuilding },
    { label: "专家待审核", value: 12, icon: User },
    { label: "投标资料待审", value: 9, icon: FolderOpened },
    { label: "已发布公告", value: 6, icon: Document },
  ],
};

const roleStats = computed(() => statMap[role.value]);
const showStats = computed(() =>
  !(
    role.value === "admin"
    || (role.value === "supplier" && ["tenders", "bidSubmit", "notice"].includes(activeMenu.value))
    || (role.value === "expert" && activeMenu.value === "notice")
  )
);

const form = reactive({
  name: "",
  code: "",
  phone: "",
  category: "",
  business: "",
  email: "",
  contact: "",
  contactName: "",
  provinceCity: "",
  address: "",
  extra: "",
});

const uploadedFiles = reactive({});
const uploadedCount = computed(() => Object.keys(uploadedFiles).filter((key) => key.startsWith(`${role.value}-`)).length);
const previewDialog = reactive({
  visible: false,
  title: "",
  url: "",
  type: "",
  temporaryUrl: "",
});

const supplierMaterials = [
  {
    name: "供应商入库申请表",
    desc: "Word 模板填写后盖章上传扫描件",
    required: true,
    template: true,
    templateUrl: "/templates/supplier-entry-application.docx",
    downloadName: "供应商入库申请表.docx",
  },
  {
    name: "保密协议",
    desc: "下载协议模板，签字或盖章后上传",
    required: true,
    template: true,
    templateUrl: "/templates/supplier-confidentiality-agreement.docx",
    downloadName: "保密协议.docx",
  },
  { name: "营业执照电子版", desc: "合法有效的营业执照等主体资格证明", required: true },
  { name: "资质证书电子版", desc: "与申报类别匹配的行业资质或许可证", required: true },
  { name: "ISO 管理体系证书电子版", desc: "质量、环境、职业健康等体系证书，如有", required: false },
  { name: "法人代表身份证电子版", desc: "法人身份证正反面扫描件", required: true },
  { name: "授权委托人身份证电子版", desc: "授权委托人身份证正反面扫描件", required: true },
  { name: "近 1-3 年财务报表或审计报告", desc: "资产负债表、利润表、现金流量表等", required: true },
  { name: "近三年业绩表及合同主要页", desc: "类似项目业绩、合同主要页或中标通知书", required: true },
  { name: "信用证明材料", desc: "AAA 信用企业证明或银行信用良好证明", required: false },
];

const expertMaterials = [
  { name: "专家照片", desc: "2 寸证件照电子版", required: true },
  {
    name: "专家库入库申报表",
    desc: "Word 模板填写后上传",
    required: true,
    template: true,
    templateUrl: "/templates/expert-entry-application.docx",
    downloadName: "专家库入库申报表.docx",
  },
  {
    name: "专家承诺书",
    desc: "下载承诺书模板，本人签名后上传",
    required: true,
    template: true,
    templateUrl: "/templates/expert-commitment-letter.docx",
    downloadName: "专家承诺书.docx",
  },
  { name: "身份证正面", desc: "身份证人像面扫描件或清晰照片", required: true },
  { name: "身份证反面", desc: "身份证国徽面扫描件或清晰照片", required: true },
  { name: "职称证书", desc: "职称证书扫描件", required: true },
  { name: "学历学位证书", desc: "学历证书、学位证书扫描件", required: true },
  { name: "资格证书 / 荣誉证书", desc: "资格证书、荣誉证书等证明材料，如有", required: false },
  { name: "业绩成果材料", desc: "论文、著作、专利、科研项目等", required: false },
  { name: "其他证明材料", desc: "公告要求或平台补充要求的其他材料", required: false },
];

const supplierTenderRows = [
  { title: "项目咨询服务合作单位入围征集公告", date: "2026-05-25", deadline: "2026-06-10", status: "报名中", templateUrl: "/templates/supplier-entry-application.docx", downloadName: "项目咨询服务投标模板.docx" },
  { title: "全过程工程咨询数字化管理平台技术服务采购公告", date: "2026-05-25", deadline: "2026-06-08", status: "报名中", templateUrl: "/templates/supplier-entry-application.docx", downloadName: "数字化平台技术服务投标模板.docx" },
  { title: "产业园区专项债项目咨询服务供应商征集公告", date: "2026-05-24", deadline: "2026-06-06", status: "报名中", templateUrl: "/templates/supplier-entry-application.docx", downloadName: "专项债咨询服务投标模板.docx" },
  { title: "历史项目咨询服务采购公告", date: "2026-05-01", deadline: "2026-05-20", status: "已截止", templateUrl: "/templates/supplier-entry-application.docx", downloadName: "历史项目投标模板.docx" },
];

const auditRecordMap = reactive({
  supplier: [
    {
      applicationNo: "GH-SUP-202605-001",
      applicationType: "供应商入库申请",
      applicant: "北京某工程咨询有限公司",
      category: "服务类 / 投资咨询",
      submitTime: "-",
      status: "待提交",
      reviewer: "-",
      reviewTime: "-",
      opinion: "请完善基础信息并上传附件后提交审核。",
      rejectReasons: [],
      rejectComment: "",
      violationReason: "",
      violationLevel: "",
      violationSuggestion: "",
      appointmentCertificate: null,
      materialsCount: "10 项附件",
      snapshot: [
        { label: "公司名称", value: "北京某工程咨询有限公司" },
        { label: "统一社会信用代码", value: "91110108MA00GH2026" },
        { label: "供应商类型", value: "服务类" },
        { label: "业务方向", value: "投资咨询" },
        { label: "联系人", value: "刘经理" },
        { label: "手机号", value: "138****2026" },
        { label: "企业邮箱", value: "contact@example.com" },
        { label: "所在省市区", value: "北京市海淀区" },
        { label: "详细地址", value: "中关村南大街 1 号国宏咨询中心 8 层" },
        { label: "法定代表人", value: "张某某" },
        { label: "注册资本", value: "1000 万元" },
        { label: "成立日期", value: "2018-06-18" },
        { label: "申报说明", value: "申请进入供应商库，参与咨询服务类项目。" },
      ],
      materialSnapshot: [
        { name: "供应商入库申请表", required: "必传", fileName: "供应商入库申请表-盖章版.pdf", uploadTime: "2026-05-26 10:05:12", status: "已上传" },
        { name: "保密协议", required: "必传", fileName: "保密协议-盖章版.pdf", uploadTime: "2026-05-26 10:06:24", status: "已上传" },
        { name: "营业执照电子版", required: "必传", fileName: "营业执照.pdf", uploadTime: "2026-05-26 10:08:11", status: "已上传" },
        { name: "资质证书电子版", required: "必传", fileName: "工程咨询单位资信证书.pdf", uploadTime: "2026-05-26 10:10:33", status: "已上传" },
        { name: "ISO 管理体系证书电子版", required: "选传", fileName: "质量管理体系认证证书.pdf", uploadTime: "2026-05-26 10:11:08", status: "已上传" },
        { name: "法人代表身份证电子版", required: "必传", fileName: "法人身份证正反面.pdf", uploadTime: "2026-05-26 10:12:40", status: "已上传" },
        { name: "授权委托人身份证电子版", required: "必传", fileName: "授权委托人身份证正反面.pdf", uploadTime: "2026-05-26 10:13:18", status: "已上传" },
        { name: "近 1-3 年财务报表或审计报告", required: "必传", fileName: "2023-2025审计报告.pdf", uploadTime: "2026-05-26 10:15:01", status: "已上传" },
        { name: "近三年业绩表及合同主要页", required: "必传", fileName: "近三年业绩及合同主要页.pdf", uploadTime: "2026-05-26 10:18:26", status: "已上传" },
        { name: "信用证明材料", required: "选传", fileName: "企业信用证明.pdf", uploadTime: "2026-05-26 10:20:09", status: "已上传" },
      ],
    },
  ],
  expert: [
    {
      applicationNo: "GH-EXP-202605-001",
      applicationType: "专家入库申请",
      applicant: "王某某",
      category: "信息数字化 / 高级工程师",
      submitTime: "-",
      status: "待提交",
      reviewer: "-",
      reviewTime: "-",
      opinion: "请填写专家基础信息，并上传申报表、承诺书、身份证正反面、证书及业绩材料。",
      rejectReasons: [],
      rejectComment: "",
      violationReason: "",
      violationLevel: "",
      violationSuggestion: "",
      materialsCount: "10 项附件",
      snapshot: [
        { label: "专家姓名", value: "王某某" },
        { label: "身份证号", value: "110101********2026" },
        { label: "所属行业", value: "信息数字化" },
        { label: "职称", value: "高级工程师" },
        { label: "所在单位", value: "北京某信息技术研究院" },
        { label: "所在省市区", value: "北京市朝阳区" },
        { label: "详细地址", value: "望京科技园 A 座 12 层" },
        { label: "手机号", value: "139****2026" },
        { label: "邮箱", value: "expert@example.com" },
        { label: "申请入库类别", value: "信息数字化专家库" },
        { label: "从业年限", value: "12 年" },
        { label: "主要专长", value: "数字化平台、信息系统规划、项目评估。" },
      ],
      materialSnapshot: [
        { name: "专家照片", required: "必传", fileName: "专家照片.jpg", uploadTime: "2026-05-26 09:35:12", status: "已上传" },
        { name: "专家库入库申报表", required: "必传", fileName: "专家库入库申报表.pdf", uploadTime: "2026-05-26 09:38:20", status: "已上传" },
        { name: "专家承诺书", required: "必传", fileName: "专家承诺书-签字版.pdf", uploadTime: "2026-05-26 09:40:18", status: "已上传" },
        { name: "身份证正面", required: "必传", fileName: "身份证正面.jpg", uploadTime: "2026-05-26 09:42:06", status: "已上传" },
        { name: "身份证反面", required: "必传", fileName: "身份证反面.jpg", uploadTime: "2026-05-26 09:42:18", status: "已上传" },
        { name: "职称证书", required: "必传", fileName: "高级工程师职称证书.pdf", uploadTime: "2026-05-26 09:44:31", status: "已上传" },
        { name: "学历学位证书", required: "必传", fileName: "学历学位证书.pdf", uploadTime: "2026-05-26 09:45:25", status: "已上传" },
        { name: "资格证书 / 荣誉证书", required: "选传", fileName: "系统架构师资格证书.pdf", uploadTime: "2026-05-26 09:46:02", status: "已上传" },
        { name: "业绩成果材料", required: "选传", fileName: "项目业绩成果材料.pdf", uploadTime: "2026-05-26 09:48:17", status: "已上传" },
        { name: "其他证明材料", required: "选传", fileName: "其他证明材料.pdf", uploadTime: "2026-05-26 09:49:40", status: "已上传" },
      ],
    },
    {
      applicationNo: "GH-EXP-202605-002",
      applicationType: "专家入库申请",
      applicant: "王某某",
      category: "信息数字化 / 高级工程师",
      submitTime: "2026-05-20 10:18",
      status: "已通过",
      reviewer: "平台审核组",
      reviewTime: "2026-05-21 09:32",
      opinion: "专家入库申请审核通过，已生成返聘证书并归档。",
      rejectReasons: [],
      rejectComment: "",
      violationReason: "",
      violationLevel: "",
      violationSuggestion: "",
      materialsCount: "10 项附件",
      appointmentCertificate: {
        name: "王某某-返聘证书.pdf",
        uploadTime: "2026-05-21 09:35",
        size: "1.1MB",
      },
      snapshot: [
        { label: "专家姓名", value: "王某某" },
        { label: "身份证号", value: "110101********2026" },
        { label: "所属行业", value: "信息数字化" },
        { label: "职称", value: "高级工程师" },
        { label: "所在单位", value: "北京某信息技术研究院" },
        { label: "所在省市区", value: "北京市朝阳区" },
        { label: "详细地址", value: "望京科技园 A 座 12 层" },
        { label: "手机号", value: "139****2026" },
        { label: "邮箱", value: "expert@example.com" },
        { label: "申请入库类别", value: "信息数字化专家库" },
        { label: "从业年限", value: "12 年" },
        { label: "主要专长", value: "数字化平台、信息系统规划、项目评估。" },
      ],
      materialSnapshot: [
        { name: "专家照片", required: "必传", fileName: "专家照片.jpg", uploadTime: "2026-05-20 10:01:12", status: "已上传" },
        { name: "专家库入库申报表", required: "必传", fileName: "专家库入库申报表.pdf", uploadTime: "2026-05-20 10:03:20", status: "已上传" },
        { name: "专家承诺书", required: "必传", fileName: "专家承诺书-签字版.pdf", uploadTime: "2026-05-20 10:05:18", status: "已上传" },
        { name: "身份证正面", required: "必传", fileName: "身份证正面.jpg", uploadTime: "2026-05-20 10:06:06", status: "已上传" },
        { name: "身份证反面", required: "必传", fileName: "身份证反面.jpg", uploadTime: "2026-05-20 10:06:18", status: "已上传" },
        { name: "职称证书", required: "必传", fileName: "高级工程师职称证书.pdf", uploadTime: "2026-05-20 10:08:31", status: "已上传" },
        { name: "学历学位证书", required: "必传", fileName: "学历学位证书.pdf", uploadTime: "2026-05-20 10:09:25", status: "已上传" },
        { name: "资格证书 / 荣誉证书", required: "选传", fileName: "系统架构师资格证书.pdf", uploadTime: "2026-05-20 10:11:02", status: "已上传" },
        { name: "业绩成果材料", required: "选传", fileName: "项目业绩成果材料.pdf", uploadTime: "2026-05-20 10:13:17", status: "已上传" },
        { name: "其他证明材料", required: "选传", fileName: "其他证明材料.pdf", uploadTime: "2026-05-20 10:15:40", status: "已上传" },
      ],
    },
  ],
});

const statusTypeMap = {
  待提交: "info",
  待审核: "warning",
  已通过: "success",
  已驳回: "danger",
  违规: "warning",
};

const bidStatusTypeMap = {
  草稿: "info",
  待审核: "warning",
  已通过: "success",
  已驳回: "danger",
  已取消: "info",
};
const bidListStatusOptions = ["待审核", "通过", "驳回", "取消", "草稿"];
const bidListStatusLabelMap = {
  待审核: "待审核",
  已通过: "通过",
  已驳回: "驳回",
  已取消: "取消",
  草稿: "草稿",
};
const getBidListStatusLabel = (status) => bidListStatusLabelMap[status] || status || "-";

const currentAuditRows = computed(() => auditRecordMap[role.value] || []);
const currentApplicationRecord = computed(() => currentAuditRows.value[0] || {});
const canMaintainApplication = computed(() => ["待提交", "已驳回"].includes(currentApplicationRecord.value.status));
const applicationActiveTab = ref("base");
const mockReviewAction = ref("draft");
const applicationSubmitText = computed(() => {
  if (currentApplicationRecord.value.status === "已驳回") return "重新提交审核";
  if (!canMaintainApplication.value) return "已提交审核";
  return "提交审核";
});

const mockReviewOptions = [
  { label: "未提交", value: "draft" },
  { label: "审核中", value: "reviewing" },
  { label: "审核驳回", value: "rejected" },
  { label: "审核通过", value: "approved" },
  { label: "标记违规", value: "violation" },
];

const supplierAuditRows = reactive([
  {
    applicationNo: "GH-SUP-202605-001",
    name: "北京某工程咨询有限公司",
    category: "服务类",
    business: "投资咨询",
    status: "待审核",
    submitTime: "2026-05-26 10:23",
    contact: "刘经理",
    phone: "138****2026",
    provinceCity: "北京市海淀区",
    materialsCount: "10 项附件",
    opinion: "资料已提交，等待平台审核。",
    snapshot: auditRecordMap.supplier[0].snapshot,
    materialSnapshot: auditRecordMap.supplier[0].materialSnapshot,
  },
  {
    applicationNo: "GH-SUP-202605-002",
    name: "天津某造价咨询有限公司",
    category: "服务类",
    business: "造价咨询",
    status: "已驳回",
    submitTime: "2026-05-25 15:40",
    contact: "王经理",
    phone: "139****2026",
    provinceCity: "天津市河西区",
    materialsCount: "8 项附件",
    opinion: "资质证书过期，授权委托材料不完整。",
    snapshot: [
      { label: "公司名称", value: "天津某造价咨询有限公司" },
      { label: "统一社会信用代码", value: "91120103MA00GH2026" },
      { label: "供应商类型", value: "服务类" },
      { label: "业务方向", value: "造价咨询" },
      { label: "联系人", value: "王经理" },
      { label: "手机号", value: "139****2026" },
      { label: "企业邮箱", value: "cost@example.com" },
      { label: "所在省市区", value: "天津市河西区" },
      { label: "详细地址", value: "友谊路 20 号 5 层" },
    ],
    materialSnapshot: auditRecordMap.supplier[0].materialSnapshot.slice(0, 8),
  },
  {
    applicationNo: "GH-SUP-202605-003",
    name: "河北某招标代理有限公司",
    category: "服务类",
    business: "招标代理",
    status: "待审核",
    submitTime: "2026-05-24 11:18",
    contact: "赵经理",
    phone: "137****2026",
    provinceCity: "河北省石家庄市",
    materialsCount: "9 项附件",
    opinion: "资料已提交，等待平台审核。",
    snapshot: [
      { label: "公司名称", value: "河北某招标代理有限公司" },
      { label: "统一社会信用代码", value: "91130100MA00GH2026" },
      { label: "供应商类型", value: "服务类" },
      { label: "业务方向", value: "招标代理" },
      { label: "联系人", value: "赵经理" },
      { label: "手机号", value: "137****2026" },
      { label: "企业邮箱", value: "bid-agent@example.com" },
      { label: "所在省市区", value: "河北省石家庄市" },
      { label: "详细地址", value: "裕华区建设南大街 66 号" },
    ],
    materialSnapshot: auditRecordMap.supplier[0].materialSnapshot.slice(0, 9),
  },
  {
    applicationNo: "GH-SUP-202605-004",
    name: "北京某规划设计有限公司",
    category: "服务类",
    business: "规划设计",
    status: "已通过",
    submitTime: "2026-05-23 09:35",
    contact: "孙经理",
    phone: "136****2026",
    provinceCity: "北京市丰台区",
    materialsCount: "10 项附件",
    opinion: "供应商入库申请已审核通过。",
    snapshot: [
      { label: "公司名称", value: "北京某规划设计有限公司" },
      { label: "统一社会信用代码", value: "91110106MA00GH2026" },
      { label: "供应商类型", value: "服务类" },
      { label: "业务方向", value: "规划设计" },
      { label: "联系人", value: "孙经理" },
      { label: "手机号", value: "136****2026" },
      { label: "企业邮箱", value: "design@example.com" },
      { label: "所在省市区", value: "北京市丰台区" },
      { label: "详细地址", value: "丽泽商务区 18 号 7 层" },
    ],
    materialSnapshot: auditRecordMap.supplier[0].materialSnapshot,
  },
]);

const expertAuditRows = reactive([
  {
    applicationNo: "GH-EXP-202605-001",
    name: "王某某",
    category: "信息数字化",
    title: "高级工程师",
    status: "待审核",
    submitTime: "2026-05-26 09:50",
    phone: "139****2026",
    provinceCity: "北京市朝阳区",
    materialsCount: "10 项附件",
    opinion: "资料已提交，等待平台审核。",
    appointmentCertificate: null,
    snapshot: auditRecordMap.expert[0].snapshot,
    materialSnapshot: auditRecordMap.expert[0].materialSnapshot,
  },
  {
    applicationNo: "GH-EXP-202605-002",
    name: "李某某",
    category: "投资咨询",
    title: "正高级经济师",
    status: "待审核",
    submitTime: "2026-05-25 14:12",
    phone: "136****2026",
    provinceCity: "北京市西城区",
    materialsCount: "9 项附件",
    opinion: "资料已提交，等待平台审核。",
    appointmentCertificate: null,
    snapshot: [
      { label: "专家姓名", value: "李某某" },
      { label: "身份证号", value: "110102********2026" },
      { label: "所属行业", value: "投资咨询" },
      { label: "职称", value: "正高级经济师" },
      { label: "所在单位", value: "北京某咨询研究中心" },
      { label: "所在省市区", value: "北京市西城区" },
      { label: "详细地址", value: "金融街 12 号 9 层" },
      { label: "手机号", value: "136****2026" },
      { label: "申请入库类别", value: "投资咨询专家库" },
    ],
    materialSnapshot: auditRecordMap.expert[0].materialSnapshot.slice(0, 9),
  },
  {
    applicationNo: "GH-EXP-202605-003",
    name: "张某某",
    category: "新能源/电力",
    title: "高级工程师",
    status: "已通过",
    submitTime: "2026-05-24 16:08",
    phone: "135****2026",
    provinceCity: "河北省保定市",
    materialsCount: "10 项附件",
    opinion: "专家入库申请已审核通过。",
    appointmentCertificate: { name: "张某某-返聘证书.pdf", uploadTime: "2026-05-28 09:30", size: "1.2MB" },
    snapshot: [
      { label: "专家姓名", value: "张某某" },
      { label: "身份证号", value: "130600********2026" },
      { label: "所属行业", value: "新能源/电力" },
      { label: "职称", value: "高级工程师" },
      { label: "所在单位", value: "河北某电力设计院" },
      { label: "所在省市区", value: "河北省保定市" },
      { label: "详细地址", value: "竞秀区朝阳北大街 88 号" },
      { label: "手机号", value: "135****2026" },
      { label: "申请入库类别", value: "新能源电力专家库" },
    ],
    materialSnapshot: auditRecordMap.expert[0].materialSnapshot,
  },
  {
    applicationNo: "GH-EXP-202605-004",
    name: "陈某某",
    category: "工程造价",
    title: "高级经济师",
    status: "已驳回",
    submitTime: "2026-05-23 10:22",
    phone: "138****2026",
    provinceCity: "天津市和平区",
    materialsCount: "8 项附件",
    opinion: "专家承诺书未签名，身份证反面不清晰。",
    rejectReason: "专家承诺书未签名，身份证反面不清晰。",
    rejectReasons: ["专家承诺书未签名", "身份证反面不清晰"],
    rejectComment: "请补充签字版承诺书，并重新上传清晰身份证反面。",
    appointmentCertificate: null,
    snapshot: [
      { label: "专家姓名", value: "陈某某" },
      { label: "身份证号", value: "120101********2026" },
      { label: "所属行业", value: "工程造价" },
      { label: "职称", value: "高级经济师" },
      { label: "所在单位", value: "天津某造价咨询中心" },
      { label: "所在省市区", value: "天津市和平区" },
      { label: "详细地址", value: "南京路 99 号 6 层" },
      { label: "手机号", value: "138****2026" },
      { label: "申请入库类别", value: "工程造价专家库" },
    ],
    materialSnapshot: auditRecordMap.expert[0].materialSnapshot.slice(0, 8),
  },
]);

const announcementRows = reactive([
  { id: "GG-202605-001", title: "北京国宏规划院有限公司供应商库入库征集公告", type: "供应商入库公告", status: "上架", publishTime: "2026-05-20 09:00", deadline: "长期有效", publisher: "平台管理员", submitCount: 18, attachments: [{ name: "供应商入库公告附件.zip", sizeText: "2.4MB", type: "application/zip", uploadTime: "2026-05-20 09:02" }] },
  { id: "GG-202605-002", title: "公开征集专家入库公告", type: "专家入库公告", status: "上架", publishTime: "2026-05-20 09:20", deadline: "长期有效", publisher: "平台管理员", submitCount: 12, attachments: [{ name: "专家入库申报材料模板.docx", sizeText: "860KB", type: "application/vnd.openxmlformats-officedocument.wordprocessingml.document", uploadTime: "2026-05-20 09:22" }] },
  { id: "GG-202605-003", title: "全过程工程咨询数字化管理平台技术服务采购公告", type: "招标公告", status: "上架", publishTime: "2026-05-25 10:00", deadline: "2026-06-08", publisher: "平台管理员", submitCount: 4, attachments: [] },
  { id: "GG-202605-004", title: "产业园区专项债项目咨询服务供应商征集公告", type: "招标公告", status: "上架", publishTime: "2026-05-24 11:30", deadline: "2026-06-06", publisher: "平台管理员", submitCount: 3, attachments: [] },
  { id: "GG-202605-005", title: "历史项目咨询服务采购公告", type: "招标公告", status: "下架", publishTime: "2026-05-01 09:30", deadline: "2026-05-20", publisher: "平台管理员", submitCount: 2, attachments: [] },
]);

const adminOverviewStats = computed(() => [
  { label: "供应商入库待审核", value: supplierAuditRows.filter((item) => item.status === "待审核").length, icon: OfficeBuilding, menu: "supplierAudit" },
  { label: "专家入库待审核", value: expertAuditRows.filter((item) => item.status === "待审核").length, icon: User, menu: "expertAudit" },
  { label: "供应商投标待审核", value: bidSubmissionRows.filter((item) => item.status === "待审核").length, icon: FolderOpened, menu: "bidAudit" },
  { label: "未过期上架公告", value: announcementRows.filter((item) => item.status === "上架" && !isAnnouncementExpired(item)).length, icon: Document, menu: "announcement" },
]);

const bidSubmissionRows = reactive([
  {
    bidNo: "TB-202605-001",
    tenderTitle: "全过程工程咨询数字化管理平台技术服务采购公告",
    deadline: "2026-06-08",
    submitTime: "2026-05-26 11:20",
    contact: "刘经理",
    phone: "138****2026",
    materialsCount: "3 项附件",
    status: "待审核",
    auditOpinion: "投标资料已提交，等待平台审核。",
    supplierName: "北京某工程咨询有限公司",
    publishDate: "2026-05-25",
    templateName: "数字化平台技术服务投标模板.docx",
    remark: "已按公告要求上传盖章版投标资料。",
    materialSnapshot: [
      { name: "投标资料文件", required: "必传", fileName: "数字化平台技术服务投标资料-盖章版.pdf", size: "18.6MB", uploadTime: "2026-05-26 11:18", status: "已上传" },
      { name: "授权委托资料", required: "选传", fileName: "授权委托书.pdf", size: "2.4MB", uploadTime: "2026-05-26 11:19", status: "已上传" },
      { name: "补充说明文件", required: "选传", fileName: "技术服务补充说明.docx", size: "1.1MB", uploadTime: "2026-05-26 11:20", status: "已上传" },
    ],
    logs: [
      { action: "创建提交记录", operator: "供应商申报人", time: "2026-05-26 11:10", remark: "选择公告并填写联系人信息" },
      { action: "上传附件", operator: "供应商申报人", time: "2026-05-26 11:20", remark: "上传 3 项附件" },
      { action: "提交审核", operator: "供应商申报人", time: "2026-05-26 11:20", remark: "提交至平台审核" },
    ],
  },
  {
    bidNo: "TB-202605-002",
    tenderTitle: "产业园区专项债项目咨询服务供应商征集公告",
    deadline: "2026-06-06",
    submitTime: "-",
    contact: "王经理",
    phone: "139****2026",
    materialsCount: "1 项附件",
    status: "草稿",
    auditOpinion: "草稿暂未提交。",
    supplierName: "北京某工程咨询有限公司",
    publishDate: "2026-05-24",
    templateName: "专项债咨询服务投标模板.docx",
    remark: "资料整理中。",
    materialSnapshot: [
      { name: "投标资料文件", required: "必传", fileName: "专项债咨询服务投标资料.docx", size: "3.8MB", uploadTime: "2026-05-26 10:42", status: "已上传" },
      { name: "授权委托资料", required: "选传", fileName: "-", size: "-", uploadTime: "-", status: "未上传" },
    ],
    logs: [
      { action: "保存草稿", operator: "供应商申报人", time: "2026-05-26 10:45", remark: "暂未提交审核" },
    ],
  },
  {
    bidNo: "TB-202605-003",
    tenderTitle: "历史项目咨询服务采购公告",
    deadline: "2026-05-20",
    submitTime: "2026-05-18 15:10",
    contact: "张经理",
    phone: "137****2026",
    materialsCount: "2 项附件",
    status: "已取消",
    auditOpinion: "供应商主动取消投标资料提交。",
    supplierName: "北京某工程咨询有限公司",
    publishDate: "2026-05-01",
    templateName: "历史项目投标模板.docx",
    remark: "项目已停止参与。",
    materialSnapshot: [
      { name: "投标资料文件", required: "必传", fileName: "历史项目投标资料.pdf", size: "9.2MB", uploadTime: "2026-05-18 15:08", status: "已上传" },
      { name: "授权委托资料", required: "选传", fileName: "授权委托书.pdf", size: "1.9MB", uploadTime: "2026-05-18 15:09", status: "已上传" },
    ],
    logs: [
      { action: "提交审核", operator: "供应商申报人", time: "2026-05-18 15:10", remark: "提交至平台审核" },
      { action: "取消提交", operator: "供应商申报人", time: "2026-05-19 09:30", remark: "供应商主动取消" },
    ],
  },
  {
    bidNo: "TB-202605-004",
    tenderTitle: "政府投资项目可研咨询服务采购公告",
    deadline: "2026-05-30",
    submitTime: "2026-05-22 14:36",
    contact: "赵经理",
    phone: "136****2026",
    materialsCount: "2 项附件",
    status: "已通过",
    auditOpinion: "投标资料审核通过，已进入后续评选环节。",
    supplierName: "北京某工程咨询有限公司",
    publishDate: "2026-05-16",
    templateName: "可研咨询服务投标模板.docx",
    remark: "按公告要求提交完整盖章资料。",
    materialSnapshot: [
      { name: "投标资料文件", required: "必传", fileName: "可研咨询服务投标资料-盖章版.pdf", size: "12.7MB", uploadTime: "2026-05-22 14:30", status: "已上传" },
      { name: "授权委托资料", required: "选传", fileName: "授权委托书.pdf", size: "1.8MB", uploadTime: "2026-05-22 14:33", status: "已上传" },
    ],
    logs: [
      { action: "提交审核", operator: "供应商申报人", time: "2026-05-22 14:36", remark: "提交至平台审核" },
      { action: "审核通过", operator: "平台管理员", time: "2026-05-23 09:18", remark: "资料完整，审核通过" },
    ],
  },
  {
    bidNo: "TB-202605-005",
    tenderTitle: "专项规划编制服务采购公告",
    deadline: "2026-05-28",
    submitTime: "2026-05-21 10:25",
    contact: "孙经理",
    phone: "135****2026",
    materialsCount: "2 项附件",
    status: "已驳回",
    auditOpinion: "投标资料盖章页缺失，请补充后重新提交。",
    supplierName: "北京某工程咨询有限公司",
    publishDate: "2026-05-14",
    templateName: "专项规划编制投标模板.docx",
    remark: "等待补充盖章页。",
    materialSnapshot: [
      { name: "投标资料文件", required: "必传", fileName: "专项规划编制投标资料.pdf", size: "10.4MB", uploadTime: "2026-05-21 10:20", status: "已上传" },
      { name: "授权委托资料", required: "选传", fileName: "授权委托书.pdf", size: "1.6MB", uploadTime: "2026-05-21 10:23", status: "已上传" },
    ],
    logs: [
      { action: "提交审核", operator: "供应商申报人", time: "2026-05-21 10:25", remark: "提交至平台审核" },
      { action: "审核驳回", operator: "平台管理员", time: "2026-05-21 16:40", remark: "盖章页缺失" },
    ],
  },
]);

const expertMessages = reactive([
  {
    title: "专家入库审核通过",
    status: "未读",
    type: "success",
    category: "入库审核",
    time: "2026-05-28 09:18",
    related: "GH-EXP-202605-001",
    content: "您的专家入库申请已审核通过，已进入专家库。",
    reason: "基础信息、身份证明、职称证书、承诺书及相关附件均符合专家入库要求。",
    suggestion: "请持续维护个人信息和证书有效期，后续平台通知会通过消息中心发送。",
  },
  {
    title: "专家入库审核驳回",
    status: "未读",
    type: "warning",
    category: "入库审核",
    time: "2026-05-27 14:35",
    related: "GH-EXP-202605-001",
    content: "您的专家入库申请被平台驳回，请根据驳回原因修改资料后重新提交。",
    reason: "专家承诺书未签名；身份证反面不清晰；职称证书附件缺失。",
    suggestion: "请补充签字版承诺书，重新上传清晰身份证反面，并补齐职称证书附件。",
  },
]);

const supplierMessages = reactive([
  {
    title: "入库申请审核通过",
    status: "未读",
    type: "success",
    category: "入库审核",
    time: "2026-05-28 09:18",
    related: "GH-SUP-202605-001",
    content: "您的供应商入库申请已审核通过，已进入合格供应商库，后续可参与平台发布的招标采购项目。",
    reason: "资料完整，主体资格、资质证书、授权材料符合供应商入库要求。",
    suggestion: "请持续维护资质有效期，后续可在招标公告中下载模板并提交投标资料。",
  },
  {
    title: "入库申请审核驳回",
    status: "未读",
    type: "warning",
    category: "入库审核",
    time: "2026-05-27 14:35",
    related: "GH-SUP-202605-001",
    content: "您的供应商入库申请被平台驳回，请根据驳回原因修改资料后重新提交。",
    reason: "营业执照扫描件不清晰；部分质量管理体系认证证书缺失或已过期；公司简介中的业务范围描述不完整。",
    suggestion: "请重新上传清晰证照，补充有效证书，并完善公司业务范围说明。",
  },
  {
    title: "平台违规通知",
    status: "未读",
    type: "danger",
    category: "违规通知",
    time: "2026-05-27 16:20",
    related: "GH-SUP-202605-001",
    content: "平台风控已将该供应商标记为违规，请负责人核实处理。",
    reason: "经平台定期抽查该供应商存在资料造假",
    suggestion: "建议暂停当前入库申请，核验相关证明材料后再决定是否允许重新申请。",
  },
  {
    title: "投标资料审核通过",
    status: "已读",
    type: "success",
    category: "投标资料",
    time: "2026-05-27 10:05",
    related: "TB-202605-001",
    content: "您提交的投标资料已审核通过，平台已完成归档。",
    reason: "投标资料文件、授权委托资料和补充说明文件均已上传且内容清晰。",
    suggestion: "请关注后续评审或项目通知。",
  },
  {
    title: "投标资料审核驳回",
    status: "已读",
    type: "warning",
    category: "投标资料",
    time: "2026-05-26 17:40",
    related: "TB-202605-002",
    content: "您提交的投标资料被驳回，请修改后重新提交。",
    reason: "投标资料文件未盖章；授权委托资料未上传；报价说明与公告要求不一致。",
    suggestion: "请下载最新模板，重新填写盖章后上传，并补充授权委托资料。",
  },
  {
    title: "资料补正提醒",
    status: "已读",
    type: "warning",
    category: "资料补正",
    time: "2026-05-26 15:20",
    related: "GH-SUP-202605-001",
    content: "平台发现您的入库资料仍有缺项，请补充后再提交审核。",
    reason: "授权委托人近 3 个月社保证明、实际办公地址照片、公司 LOGO 尚未上传。",
    suggestion: "请在入库申请的附件材料中补齐对应文件。",
  },
  {
    title: "新增可投招标公告",
    status: "已读",
    type: "info",
    category: "公告提醒",
    time: "2026-05-25 16:10",
    related: "全过程工程咨询数字化管理平台技术服务采购公告",
    content: "平台发布了新的招标公告，请在截止时间前下载模板并提交投标资料。",
    reason: "公告发布时间：2026-05-25，截止时间：2026-06-08 18:00。",
    suggestion: "请进入招标公告查看详情，下载模板后提交投标资料。",
  },
]);

const supplierUnreadCount = computed(() => supplierMessages.filter((item) => item.status === "未读").length);
const expertUnreadCount = computed(() => expertMessages.filter((item) => item.status === "未读").length);
const noticeUnreadCount = computed(() => (role.value === "expert" ? expertUnreadCount.value : supplierUnreadCount.value));

const openNoticeCenter = () => {
  if (role.value === "supplier" || role.value === "expert") activeMenu.value = "notice";
};

const goPortal = () => {
  router.push("/portal");
};

const continueProfile = () => {
  activeMenu.value = role.value === "expert" ? "profile" : "entry";
};

const submitApplication = () => {
  if (!canMaintainApplication.value) {
    ElMessage.warning("资料已提交审核，当前状态不可维护；只有驳回后才能修改。");
    return;
  }
  Object.assign(currentApplicationRecord.value, {
    submitTime: "2026-05-26 14:30",
    status: "待审核",
    reviewer: "平台审核组",
    reviewTime: "-",
    opinion: "资料已提交，等待平台审核。审核期间不可修改资料。",
  });
  mockReviewAction.value = "reviewing";
  ElMessage.success("资料已提交，当前状态：待平台审核");
};

const applyMockReviewAction = (action) => {
  mockReviewAction.value = action;
  const record = currentApplicationRecord.value;
  const base = {
    submitTime: record.submitTime === "-" ? "2026-05-26 10:23:45" : record.submitTime,
    reviewer: "平台初审",
  };

  if (action === "draft") {
    Object.assign(record, {
      submitTime: "-",
      status: "待提交",
      reviewer: "-",
      reviewTime: "-",
      opinion: role.value === "expert"
        ? "请填写专家基础信息，并上传申报表、承诺书、身份证正反面、证书及业绩材料。"
        : "请完善基础信息并上传附件后提交审核。",
      rejectReasons: [],
      rejectComment: "",
      violationReason: "",
      violationLevel: "",
      violationSuggestion: "",
      appointmentCertificate: null,
    });
    applicationActiveTab.value = "base";
  }

  if (action === "reviewing") {
    Object.assign(record, {
      ...base,
      status: "待审核",
      reviewTime: "-",
      opinion: "平台初审进行中，请耐心等待审核结果。",
      rejectReasons: [],
      rejectComment: "",
      violationReason: "",
      violationLevel: "",
      violationSuggestion: "",
      appointmentCertificate: null,
    });
    applicationActiveTab.value = "base";
  }

  if (action === "rejected") {
    Object.assign(record, {
      ...base,
      status: "已驳回",
      reviewTime: "2026-05-27 14:35:22",
      opinion: "资料不完整或信息不一致，请根据驳回原因修改后重新提交。",
      rejectReasons: [
        "营业执照扫描件不清晰，请重新上传清晰的营业执照。",
        "部分质量管理体系认证证书缺失或已过期。",
        role.value === "expert" ? "专家承诺书未签名，请补充签字页。" : "公司简介中的业务范围描述不完整，请补充详细信息。",
      ],
      rejectComment: "请在提交前仔细核验资料完整性，如有疑问可联系系统管理员。",
      violationReason: "",
      violationLevel: "",
      violationSuggestion: "",
      appointmentCertificate: null,
    });
    applicationActiveTab.value = "audit";
  }

  if (action === "approved") {
    Object.assign(record, {
      ...base,
      status: "已通过",
      reviewer: "平台复核",
      reviewTime: "2026-05-28 09:18:36",
      opinion: role.value === "expert" ? "专家入库申请已审核通过，已进入专家库。" : "供应商入库申请已审核通过，已进入合格供应商库。",
      rejectReasons: [],
      rejectComment: "",
      violationReason: "",
      violationLevel: "",
      violationSuggestion: "",
      appointmentCertificate: role.value === "expert"
        ? { name: "专家返聘证书.pdf", uploadTime: "2026-05-28 09:18:36", size: "1.1MB" }
        : null,
    });
    applicationActiveTab.value = "audit";
  }

  if (action === "violation") {
    Object.assign(record, {
      ...base,
      status: "违规",
      reviewer: "平台风控",
      reviewTime: "2026-05-27 16:20:15",
      opinion: "申请存在疑似违规情况，已标记为平台违规，请负责人进一步核实处理。",
      rejectReasons: [],
      rejectComment: "",
      violationReason: "经平台定期抽查该供应商存在资料造假",
      violationLevel: "中风险",
      violationSuggestion: "建议暂停当前入库申请，核验相关证明材料后再决定是否允许重新申请。",
    });
    applicationActiveTab.value = "audit";
  }
};

const getMaterialKey = (item) => `${role.value}-${item.name}`;

const openMaterialPicker = (item) => {
  if (!canMaintainApplication.value) {
    ElMessage.warning("资料已提交审核，当前状态不可维护；只有驳回后才能修改。");
    return;
  }
  document.getElementById(`file-${getMaterialKey(item)}`)?.click();
};

const handleMaterialUpload = (item, event) => {
  const files = Array.from(event.target.files || []);
  if (!files.length) return;
  const materialKey = getMaterialKey(item);
  (uploadedFiles[materialKey] || []).forEach((file) => {
    if (file.url) URL.revokeObjectURL(file.url);
  });
  uploadedFiles[getMaterialKey(item)] = files.map((file) => ({
    name: file.name,
    size: file.size,
    type: file.type,
    url: URL.createObjectURL(file),
  }));
  ElMessage.success(`已选择 ${files.length} 个文件`);
  event.target.value = "";
};

const getPreviewType = (file) => {
  const name = (file.name || file.fileName || "").toLowerCase();
  const type = file.type || "";
  if (type.startsWith("image/")) return "image";
  if (type === "application/pdf" || name.endsWith(".pdf")) return "pdf";
  if (type.startsWith("text/") || name.endsWith(".txt")) return "text";
  return "";
};

const previewMaterialFile = (file) => {
  const previewType = getPreviewType(file);
  if (!previewType) {
    openTextPreview(file.name || "文件预览", [
      file.name || "文件预览",
      `文件大小：${file.size ? formatFileSize(file.size) : "-"}`,
      "当前为前端原型模拟预览文件，Word、Excel、压缩包等格式真实开发时可接入后端在线预览或 Office 预览服务。",
    ]);
    return;
  }
  Object.assign(previewDialog, {
    visible: true,
    title: file.name,
    url: file.url,
    type: previewType,
    temporaryUrl: "",
  });
};

const openPreviewUrl = (title, url, type = "text", temporaryUrl = "") => {
  closePreviewDialog();
  Object.assign(previewDialog, {
    visible: true,
    title,
    url,
    type,
    temporaryUrl,
  });
};

const openTextPreview = (title, lines) => {
  const blob = new Blob([lines.join("\n")], { type: "text/plain;charset=utf-8" });
  const url = URL.createObjectURL(blob);
  openPreviewUrl(title, url, "text", url);
};

const closePreviewDialog = () => {
  if (previewDialog.temporaryUrl) {
    URL.revokeObjectURL(previewDialog.temporaryUrl);
  }
  Object.assign(previewDialog, {
    visible: false,
    title: "",
    url: "",
    type: "",
    temporaryUrl: "",
  });
};

const renderPreviewDownloadActions = (previewHandler, downloadHandler, options = {}) =>
  h("div", { class: "file-action-group" }, [
    h(ElButton, {
      size: options.size || "small",
      type: "primary",
      text: true,
      disabled: options.disabled,
      onClick: previewHandler,
    }, () => "预览"),
    h(ElButton, {
      size: options.size || "small",
      type: "primary",
      text: true,
      disabled: options.disabled,
      onClick: downloadHandler,
    }, () => "下载"),
  ]);

const removeMaterialFile = (item, file) => {
  if (!canMaintainApplication.value) {
    ElMessage.warning("资料已提交审核，当前状态不可维护；只有驳回后才能修改。");
    return;
  }
  const materialKey = getMaterialKey(item);
  if (file.url) URL.revokeObjectURL(file.url);
  uploadedFiles[materialKey] = (uploadedFiles[materialKey] || []).filter((itemFile) => itemFile.url !== file.url);
  if (!uploadedFiles[materialKey].length) delete uploadedFiles[materialKey];
  ElMessage.success("已删除文件");
};

const downloadFile = (url, fileName) => {
  const link = document.createElement("a");
  link.href = url;
  link.download = fileName;
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);
};

const downloadMaterialFile = (file) => {
  if (!file.url) {
    ElMessage.warning("当前文件暂无可下载地址。");
    return;
  }
  downloadFile(file.url, file.name);
};

const downloadApplicationMaterials = (record = currentApplicationRecord.value) => {
  const materials = record.materialSnapshot?.length
    ? record.materialSnapshot
    : (role.value === "expert" ? expertMaterials : supplierMaterials).map((item) => ({
      name: item.name,
      required: item.required ? "必传" : "选传",
      fileName: item.downloadName || item.name,
      uploadTime: "-",
      status: "待上传",
    }));
  const content = [
    `${record.applicationType || "入库申请"}附件清单`,
    `申请编号：${record.applicationNo || "-"}`,
    `申请对象：${record.applicant || "-"}`,
    `附件数量：${record.materialsCount || "-"}`,
    "",
    ...materials.map((item, index) => `${index + 1}. ${item.name}（${item.required || "-"}） ${item.fileName || "-"} ${item.uploadTime || "-"}`),
  ].join("\n");
  const blob = new Blob([content], { type: "text/plain;charset=utf-8" });
  const url = URL.createObjectURL(blob);
  downloadFile(url, `${record.applicationNo || "application"}-附件清单.txt`);
  setTimeout(() => URL.revokeObjectURL(url), 0);
};

const previewApplicationMaterials = (record = currentApplicationRecord.value) => {
  const materials = record.materialSnapshot?.length
    ? record.materialSnapshot
    : (role.value === "expert" ? expertMaterials : supplierMaterials).map((item) => ({
      name: item.name,
      required: item.required ? "必传" : "选传",
      fileName: item.downloadName || item.name,
      uploadTime: "-",
      status: "待上传",
    }));
  openTextPreview(`${record.applicationNo || record.bidNo || "application"}-附件清单.txt`, [
    `${record.applicationType || "资料"}附件清单`,
    `编号：${record.applicationNo || record.bidNo || "-"}`,
    `对象：${record.applicant || record.name || record.supplierName || "-"}`,
    `附件数量：${record.materialsCount || "-"}`,
    "",
    ...materials.map((item, index) => `${index + 1}. ${item.name}（${item.required || "-"}） ${item.fileName || "-"} ${item.uploadTime || "-"}`),
  ]);
};

const downloadAppointmentCertificate = (certificate) => {
  if (!certificate?.name) {
    ElMessage.warning("暂无返聘证书附件。");
    return;
  }
  if (certificate.url) {
    downloadFile(certificate.url, certificate.name);
    return;
  }
  const content = [
    certificate.name,
    `上传时间：${certificate.uploadTime || "-"}`,
    `文件大小：${certificate.size || "-"}`,
    "当前为前端原型模拟下载文件，真实开发时替换为后端附件下载接口。",
  ].join("\n");
  const blob = new Blob([content], { type: "text/plain;charset=utf-8" });
  const url = URL.createObjectURL(blob);
  downloadFile(url, certificate.name);
  setTimeout(() => URL.revokeObjectURL(url), 0);
};

const previewAppointmentCertificate = (certificate) => {
  if (!certificate?.name) {
    ElMessage.warning("暂无返聘证书附件。");
    return;
  }
  if (certificate.url) {
    const previewType = getPreviewType(certificate);
    if (previewType) {
      openPreviewUrl(certificate.name, certificate.url, previewType);
      return;
    }
  }
  openTextPreview(certificate.name, [
    certificate.name,
    `上传时间：${certificate.uploadTime || "-"}`,
    `文件大小：${certificate.size || "-"}`,
    "当前为前端原型模拟预览文件，真实开发时替换为后端附件预览接口。",
  ]);
};

const downloadSnapshotMaterial = (record, material) => {
  const content = [
    material.fileName || material.name,
    `编号：${record.applicationNo || record.bidNo || "-"}`,
    `对象：${record.applicant || record.name || record.supplierName || "-"}`,
    `材料名称：${material.name || "-"}`,
    `上传时间：${material.uploadTime || "-"}`,
    "当前为前端原型模拟下载文件，真实开发时替换为后端附件下载接口。",
  ].join("\n");
  const blob = new Blob([content], { type: "text/plain;charset=utf-8" });
  const url = URL.createObjectURL(blob);
  downloadFile(url, material.fileName || `${material.name || "附件"}.txt`);
  setTimeout(() => URL.revokeObjectURL(url), 0);
};

const previewSnapshotMaterial = (record, material) => {
  if (material.url) {
    const previewType = getPreviewType({ ...material, name: material.fileName || material.name });
    if (previewType) {
      openPreviewUrl(material.fileName || material.name, material.url, previewType);
      return;
    }
  }
  openTextPreview(material.fileName || material.name || "附件预览", [
    material.fileName || material.name || "附件预览",
    `编号：${record.applicationNo || record.bidNo || "-"}`,
    `对象：${record.applicant || record.name || record.supplierName || "-"}`,
    `材料名称：${material.name || "-"}`,
    `上传时间：${material.uploadTime || "-"}`,
    "当前为前端原型模拟预览文件，真实开发时替换为后端附件预览接口。",
  ]);
};

const isTenderExpired = (row) => {
  if (!row.deadline) return false;
  const endTime = new Date(`${row.deadline} 23:59:59`).getTime();
  return Number.isFinite(endTime) && Date.now() > endTime;
};

const isAnnouncementExpired = (row) => {
  if (!row.deadline || row.deadline === "长期有效") return false;
  const endTime = new Date(`${row.deadline} 23:59:59`).getTime();
  return Number.isFinite(endTime) && Date.now() > endTime;
};

const formatFileSize = (size) => {
  if (!size) return "";
  if (size < 1024 * 1024) return `${Math.ceil(size / 1024)}KB`;
  return `${(size / 1024 / 1024).toFixed(1)}MB`;
};

const categoryOptions = computed(() =>
  role.value === "expert"
    ? ["投资咨询", "人工智能", "信息数字化", "新能源/电力", "环境/气象/水利", "物流与供应链"]
    : ["工程类", "货物类", "服务类", "综合类"]
);

const businessOptions = ["投资咨询", "勘察设计", "造价咨询", "招标代理", "工程监理", "BIM数字化管理", "专项咨询"];

function renderBaseInfoCard(isExpertForm) {
  return h(ElCard, { shadow: "never", class: "content-card" }, {
    header: () => h("div", { class: "card-header" }, [
      h("strong", "基础信息"),
      h(ElTag, { type: statusTypeMap[currentApplicationRecord.value.status] || "info" }, () => currentApplicationRecord.value.status || "待提交"),
    ]),
    default: () =>
      h("div", [
        !canMaintainApplication.value
          ? h("div", { class: "lock-tip" }, "资料已提交审核，当前不可维护；只有平台驳回后才能修改。")
          : null,
        h(ElForm, { model: form, labelPosition: "top", class: "clean-form" }, () =>
          h(ElRow, { gutter: 20 }, () => [
            formCol(isExpertForm ? "专家姓名" : "公司名称", "name", isExpertForm ? "请输入专家姓名" : "请输入营业执照上的公司名称"),
            formCol(isExpertForm ? "身份证号" : "统一社会信用代码", "code", isExpertForm ? "请输入身份证号" : "请输入统一社会信用代码"),
            selectCol(isExpertForm ? "所属行业" : "供应商类型", "category", categoryOptions.value),
            isExpertForm
              ? formCol("职称", "contact", "请输入职称，如高级工程师")
              : selectCol("业务方向", "business", businessOptions),
            formCol(isExpertForm ? "所在单位" : "联系人", "contactName", isExpertForm ? "请输入所在单位" : "请输入联系人姓名"),
            formCol("所在省市区", "provinceCity", "请输入省市区"),
            formCol("详细地址", "address", "请输入详细地址"),
            formCol("手机号", "phone", "请输入手机号"),
            formCol("邮箱", "email", "请输入邮箱"),
            isExpertForm ? formCol("申请入库类别", "extra", "如正高专家库、副高教授专家库") : null,
          ].filter(Boolean))
        ),
      ].filter(Boolean)),
  });
}

const EntryForm = defineComponent({
  name: "EntryForm",
  props: {
    type: { type: String, required: true },
    materials: { type: Array, required: true },
    showMaterials: { type: Boolean, default: true },
  },
  setup(props) {
    const isExpertForm = computed(() => props.type === "expert");
    return () =>
      h("div", { class: "application-body" }, [
        h("div", { class: "application-main" }, [
          h(ElCard, { shadow: "never", class: "content-card" }, {
            header: () => h("div", { class: "card-header" }, [
              h("strong", "基础信息"),
              h(ElTag, { type: statusTypeMap[currentApplicationRecord.value.status] || "info" }, () => currentApplicationRecord.value.status || "待提交"),
            ]),
            default: () =>
              h("div", [
                !canMaintainApplication.value
                  ? h("div", { class: "lock-tip" }, "资料已提交审核，当前不可维护；只有平台驳回后才能修改。")
                  : null,
                h(ElForm, { model: form, labelPosition: "top", class: "clean-form" }, () =>
                  h(ElRow, { gutter: 20 }, () => [
                    formCol(isExpertForm.value ? "专家姓名" : "公司名称", "name", isExpertForm.value ? "请输入专家姓名" : "请输入营业执照上的公司名称"),
                    formCol(isExpertForm.value ? "身份证号" : "统一社会信用代码", "code", isExpertForm.value ? "请输入身份证号" : "请输入统一社会信用代码"),
                    selectCol(isExpertForm.value ? "所属行业" : "供应商类型", "category", categoryOptions.value),
                    isExpertForm.value
                      ? formCol("职称", "contact", "请输入职称，如高级工程师")
                      : selectCol("业务方向", "business", businessOptions),
                    formCol(isExpertForm.value ? "所在单位" : "联系人", "contactName", isExpertForm.value ? "请输入所在单位" : "请输入联系人姓名"),
                    formCol("所在省市区", "provinceCity", "请输入省市区"),
                    formCol("详细地址", "address", "请输入详细地址"),
                    formCol("手机号", "phone", "请输入手机号"),
                    formCol("邮箱", "email", "请输入邮箱"),
                    isExpertForm.value ? formCol("申请入库类别", "extra", "如正高专家库、副高教授专家库") : null,
                  ].filter(Boolean))
                ),
              ].filter(Boolean)),
          }),
          props.showMaterials !== false ? materialCard(props.materials) : null,
        ].filter(Boolean)),
        h(ApplicationStatusPanel),
      ]);
  },
});

const ApplicationTabs = defineComponent({
  name: "ApplicationTabs",
  props: {
    type: { type: String, required: true },
    materials: { type: Array, required: true },
  },
  setup(props) {
    const isExpertForm = computed(() => props.type === "expert");
    return () =>
      h("div", { class: "application-detail-grid" }, [
        h(ElCard, { shadow: "never", class: "application-tabs-card" }, () =>
          h(ElTabs, { modelValue: applicationActiveTab.value, "onUpdate:modelValue": (value) => (applicationActiveTab.value = value), class: "application-tabs" }, () => [
            h(ElTabPane, { label: "基本信息", name: "base" }, () => renderBaseInfoCard(isExpertForm.value)),
            h(ElTabPane, { label: "附件材料", name: "materials" }, () => materialCard(props.materials)),
            h(ElTabPane, { label: "审核记录", name: "audit" }, () => h(AuditPanel, { rows: currentAuditRows.value })),
            h(ElTabPane, { label: "操作记录", name: "logs" }, () => h(OperationLogPanel)),
          ])
        ),
        h(ApplicationStatusPanel),
      ]);
  },
});

const SupplierOverview = defineComponent({
  setup() {
    return () =>
      h("div", { class: "overview-grid" }, [
        simpleCard("入库申请状态", "待提交", "请完善基础信息并上传附件材料，提交后进入平台审核。"),
        simpleCard("最近公告", "3 条可投公告", "可在“招标公告”菜单查看公告详情并下载模板。"),
        simpleCard("投标资料", "1 条草稿", "投标资料需在对应公告下提交，等待平台审核。"),
      ]);
  },
});

const ExpertOverview = defineComponent({
  setup() {
    return () =>
      h("div", { class: "overview-grid" }, [
        simpleCard("专家入库状态", "待提交", "请完善专家资料并上传申报表、承诺书和证书附件。"),
        simpleCard("附件材料", "5 项必传待上传", "身份证正反面、职称证书、学历学位证书需单独上传。"),
        simpleCard("平台消息", "2 条未读", "审核结果、补充材料提醒会在平台消息中展示。"),
      ]);
  },
});

const AdminOverview = defineComponent({
  setup() {
    return () =>
      h("div", { class: "admin-workbench" }, [
        h("div", { class: "admin-overview-grid" }, adminOverviewStats.value.map((item) =>
          h("div", {
            class: "admin-stat-card",
            role: "button",
            tabindex: 0,
            onClick: () => (activeMenu.value = item.menu),
            onKeydown: (event) => {
              if (event.key === "Enter") activeMenu.value = item.menu;
            },
          }, [
            h(ElIcon, () => h(item.icon)),
            h("div", { class: "admin-stat-main" }, [
              h("span", item.label),
              h("b", `${item.value}`),
            ]),
            h("em", "进入处理"),
          ])
        )),
      ]);
  },
});

const ApplicationSteps = defineComponent({
  setup() {
    const flowItems = computed(() => {
      const status = currentApplicationRecord.value.status;
      const rejected = status === "已驳回";
      const approved = status === "已通过";
      const reviewing = status === "待审核";
      const violation = status === "违规";
      const draft = status === "待提交";

      return [
        { title: "提交申请", time: currentApplicationRecord.value.submitTime === "-" ? "待提交" : currentApplicationRecord.value.submitTime, state: draft ? "current" : "done" },
        { title: "平台审核", time: rejected ? "已驳回" : reviewing ? "进行中" : approved || violation ? "已完成" : "待开始", state: rejected ? "reject" : reviewing ? "current" : approved || violation ? "done" : "" },
        { title: "审核通过", time: approved ? currentApplicationRecord.value.reviewTime : "待开始", state: approved ? "done" : "" },
        { title: "平台违规", time: violation ? currentApplicationRecord.value.reviewTime : "待触发", state: violation ? "violation" : "" },
      ];
    });

    return () =>
      h("section", { class: "application-detail-head" }, [
        h("div", { class: "application-title-row" }, [
          h("div", [
            h("div", { class: "detail-back" }, "‹ 申请详情"),
            h("h1", `${role.value === "expert" ? "专家" : "供应商"}入库申请`),
          ]),
          h("div", { class: "head-actions" }, [
            h(ElSelect, {
              modelValue: mockReviewAction.value,
              "onUpdate:modelValue": applyMockReviewAction,
              class: "mock-review-select",
              placeholder: "审核操作",
            }, () => mockReviewOptions.map((item) => h(ElOption, { key: item.value, label: item.label, value: item.value }))),
            h(ElTag, { type: statusTypeMap[currentApplicationRecord.value.status] || "info", size: "large" }, () => currentApplicationRecord.value.status || "待提交"),
            currentApplicationRecord.value.status === "待审核" ? h(ElButton, { plain: true, type: "danger" }, () => "撤回申请") : null,
          ].filter(Boolean)),
        ]),
        h("div", { class: "application-meta" }, [
          metaItem("申请编号", currentApplicationRecord.value.applicationNo),
          metaItem("提交时间", currentApplicationRecord.value.submitTime),
          metaItem("申请人", currentApplicationRecord.value.applicant),
          metaItem("当前节点", currentApplicationRecord.value.status === "待提交" ? "填写资料" : currentApplicationRecord.value.status === "待审核" ? "平台初审" : currentApplicationRecord.value.status),
        ]),
        h("div", { class: "audit-flow" }, flowItems.value.map((item, index) =>
          h("div", { class: ["flow-item", item.state ? `is-${item.state}` : ""] }, [
            h("span", { class: "flow-dot" }, item.state === "done" ? "✓" : item.state === "reject" ? "×" : index + 1),
            h("strong", item.title),
            h("p", item.time),
          ])
        )),
      ]);
  },
});

const ApplicationStatusPanel = defineComponent({
  setup() {
    const detailVisible = ref(false);
    const statusLine = computed(() => {
      const status = currentApplicationRecord.value.status;
      if (status === "待提交") return "资料尚未提交，补齐基础信息和附件后可提交审核。";
      if (status === "待审核") return "资料已提交，平台审核中，当前不可修改或重复提交。";
      if (status === "已驳回") return "平台已驳回，可根据审核意见修改后重新提交。";
      if (status === "违规") return "该申请已被平台标记违规，请根据违规原因进行核实处理。";
      return "审核通过，资料已归档。";
    });
    const detailItem = (label, value) => h(ElDescriptionsItem, { label }, () => value || "-");
    const materialCountItem = (record) =>
      h(ElDescriptionsItem, { label: "附件数量" }, () =>
        h("div", { class: "material-count-cell" }, [
          h("span", record.materialsCount || "-"),
          renderPreviewDownloadActions(
            () => previewApplicationMaterials(record),
            () => downloadApplicationMaterials(record)
          ),
        ])
      );

    return () =>
      h("aside", { class: "application-status" }, [
        h("div", { class: "status-card" }, [
          h("div", { class: "status-head" }, [
            h("span", "当前申请"),
            h(ElTag, { type: statusTypeMap[currentApplicationRecord.value.status] || "info" }, () => currentApplicationRecord.value.status || "待提交"),
          ]),
          h("h3", currentApplicationRecord.value.applicationType),
          h("p", statusLine.value),
          h("dl", [
            h("div", [h("dt", "申请编号"), h("dd", currentApplicationRecord.value.applicationNo || "-")]),
            h("div", [h("dt", "申请对象"), h("dd", currentApplicationRecord.value.applicant || "-")]),
            h("div", [h("dt", "类别/专业"), h("dd", currentApplicationRecord.value.category || "-")]),
            h("div", [h("dt", "提交时间"), h("dd", currentApplicationRecord.value.submitTime || "-")]),
            h("div", [h("dt", "审核时间"), h("dd", currentApplicationRecord.value.reviewTime || "-")]),
          ].filter(Boolean)),
          h("div", { class: "status-actions" }, [
            h(ElButton, { type: "primary", disabled: !canMaintainApplication.value, onClick: submitApplication }, () => applicationSubmitText.value),
            h(ElButton, { onClick: () => (detailVisible.value = true) }, () => "查看详情"),
          ]),
        ]),
        h("div", { class: "opinion-card" }, [
          h("strong", currentApplicationRecord.value.status === "已驳回" ? "驳回原因" : currentApplicationRecord.value.status === "违规" ? "违规原因" : "审核意见"),
          currentApplicationRecord.value.status === "已驳回"
            ? h("ol", { class: "reason-list" }, (currentApplicationRecord.value.rejectReasons || []).map((item) => h("li", item)))
            : currentApplicationRecord.value.status === "违规"
              ? h("div", { class: "violation-summary" }, [
                h("p", currentApplicationRecord.value.violationReason),
                h("div", [h("span", "违规等级"), h(ElTag, { type: "warning" }, () => currentApplicationRecord.value.violationLevel || "-")]),
                h("p", currentApplicationRecord.value.violationSuggestion),
              ])
              : h("p", currentApplicationRecord.value.opinion || "暂无审核意见"),
        ]),
        h(ElDialog, {
          modelValue: detailVisible.value,
          "onUpdate:modelValue": (value) => (detailVisible.value = value),
          title: "申请详情",
          width: "720px",
        }, {
          default: () =>
            h(ElDescriptions, { column: 2, border: true, class: "audit-detail" }, () => [
              detailItem("申请编号", currentApplicationRecord.value.applicationNo),
              detailItem("申请类型", currentApplicationRecord.value.applicationType),
              detailItem("申请对象", currentApplicationRecord.value.applicant),
              detailItem("类别/专业", currentApplicationRecord.value.category),
              ...(currentApplicationRecord.value.snapshot || []).map((item) => detailItem(item.label, item.value)),
              detailItem("提交时间", currentApplicationRecord.value.submitTime),
              detailItem("审核状态", currentApplicationRecord.value.status),
              detailItem("审核人", currentApplicationRecord.value.reviewer),
              detailItem("审核时间", currentApplicationRecord.value.reviewTime),
              materialCountItem(currentApplicationRecord.value),
              h(ElDescriptionsItem, { label: "审核意见", span: 2 }, () => currentApplicationRecord.value.opinion || "-"),
            ].filter(Boolean)),
          footer: () => h(ElButton, { type: "primary", onClick: () => (detailVisible.value = false) }, () => "关闭"),
        }),
      ]);
  },
});

const NoticePanel = defineComponent({
  props: {
    title: { type: String, required: true },
    rows: { type: Array, required: true },
    actionLabel: { type: String, default: "查看" },
  },
  setup(props) {
    const currentPage = ref(1);
    const pageSize = ref(3);
    const pagedRows = computed(() => {
      const start = (currentPage.value - 1) * pageSize.value;
      return props.rows.slice(start, start + pageSize.value);
    });
    watch(
      () => props.rows.length,
      () => {
        currentPage.value = 1;
      }
    );
    const downloadTemplate = (row) => {
      if (isTenderExpired(row)) {
        ElMessage.warning("公告已截止，不能下载模板。");
        return;
      }
      downloadFile(row.templateUrl, row.downloadName || "投标模板.docx");
    };

    return () =>
      h(ElCard, { shadow: "never", class: "content-card" }, {
        header: () => h("div", { class: "card-header" }, [h("strong", props.title)]),
        default: () =>
          h("div", [
            h(ElTable, { data: pagedRows.value, border: true }, () => [
              h(ElTableColumn, { prop: "title", label: "公告标题", minWidth: 260 }),
              h(ElTableColumn, { prop: "date", label: "发布日期", width: 130 }),
              h(ElTableColumn, { prop: "deadline", label: "截止时间", width: 130 }),
              h(ElTableColumn, { prop: "status", label: "状态", width: 110 }, {
                default: ({ row }) => h(ElTag, { type: isTenderExpired(row) ? "info" : "success" }, () => (isTenderExpired(row) ? "已截止" : row.status)),
              }),
              h(ElTableColumn, { label: "模板下载", width: 130 }, {
                default: ({ row }) =>
                  h(ElButton, {
                    type: "primary",
                    text: true,
                    disabled: isTenderExpired(row),
                    onClick: () => downloadTemplate(row),
                  }, () => (isTenderExpired(row) ? "已截止" : "下载模板")),
              }),
              h(ElTableColumn, { label: "操作", width: 120 }, { default: () => h(ElButton, { type: "primary", text: true }, () => props.actionLabel) }),
            ]),
            h("div", { class: "table-pagination" }, [
              h(ElPagination, {
                currentPage: currentPage.value,
                pageSize: pageSize.value,
                total: props.rows.length,
                layout: "total, prev, pager, next",
                background: true,
                "onUpdate:currentPage": (value) => (currentPage.value = value),
              }),
            ]),
          ]),
      });
  },
});

const BidSubmitPanel = defineComponent({
  setup() {
    const formVisible = ref(false);
    const detailVisible = ref(false);
    const selectedBid = ref(null);
    const editingBid = ref(null);
    const bidPage = ref(1);
    const bidPageSize = ref(3);
    const bidFilters = reactive({
      keyword: "",
      status: "",
      tenderTitle: "",
    });
    const bidForm = reactive({
      tenderTitle: "",
      contact: "",
      phone: "",
      remark: "",
    });
    const bidUploadedFiles = reactive({});
    const bidMaterials = [
      { name: "投标资料文件", desc: "Word/PDF/压缩包", required: true },
      { name: "授权委托资料", desc: "如公告要求提供", required: false },
    ];
    const availableTenders = computed(() => supplierTenderRows.filter((item) => !isTenderExpired(item)));
    const selectedTender = computed(() => supplierTenderRows.find((item) => item.title === bidForm.tenderTitle));
    const selectedTenderExpired = computed(() => selectedTender.value ? isTenderExpired(selectedTender.value) : false);
    const bidMaterialKey = (item) => `bid-${item.name}`;
    const openBidMaterialPicker = (item) => {
      document.getElementById(`file-${bidMaterialKey(item)}`)?.click();
    };
    const handleBidMaterialUpload = (item, event) => {
      const files = Array.from(event.target.files || []);
      if (!files.length) return;
      const materialKey = bidMaterialKey(item);
      (bidUploadedFiles[materialKey] || []).forEach((file) => {
        if (file.url) URL.revokeObjectURL(file.url);
      });
      bidUploadedFiles[materialKey] = files.map((file) => ({
        name: file.name,
        size: file.size,
        type: file.type,
        url: URL.createObjectURL(file),
      }));
      ElMessage.success(`已选择 ${files.length} 个文件`);
      event.target.value = "";
    };
    const removeBidMaterialFile = (item, file) => {
      const materialKey = bidMaterialKey(item);
      if (file.url) URL.revokeObjectURL(file.url);
      bidUploadedFiles[materialKey] = (bidUploadedFiles[materialKey] || []).filter((itemFile) => itemFile.url !== file.url);
      if (!bidUploadedFiles[materialKey].length) delete bidUploadedFiles[materialKey];
      ElMessage.success("已删除文件");
    };
    const clearBidUploadedFiles = () => {
      Object.values(bidUploadedFiles).flat().forEach((file) => {
        if (file.url) URL.revokeObjectURL(file.url);
      });
      Object.keys(bidUploadedFiles).forEach((key) => delete bidUploadedFiles[key]);
    };
    const getBidMaterialCount = () =>
      bidMaterials.reduce((count, item) => count + (bidUploadedFiles[bidMaterialKey(item)]?.length ? 1 : 0), 0);
    const latestBidRecord = computed(() => bidSubmissionRows[0]);
    const downloadSelectedTemplate = () => {
      if (!selectedTender.value) {
        ElMessage.warning("请先选择招标公告。");
        return;
      }
      if (selectedTenderExpired.value) {
        ElMessage.warning("公告已截止，不能下载模板。");
        return;
      }
      downloadFile(selectedTender.value.templateUrl, selectedTender.value.downloadName || "投标模板.docx");
    };
    const renderBidMaterialPanel = () =>
      h("div", { class: "bid-material-panel" }, [
        h("div", { class: "bid-upload-head" }, [
          h("div", [
            h("div", { class: "bid-section-title" }, "附件材料"),
            h("p", "支持 Word / PDF / ZIP 格式，单个文件不超过 100MB"),
          ]),
        ]),
        h("div", { class: "material-grid bid-material-grid" }, bidMaterials.map((item) => {
          const materialKey = bidMaterialKey(item);
          const files = bidUploadedFiles[materialKey] || [];
          return h("div", { class: "material-card", key: item.name }, [
            h("input", {
              id: `file-${materialKey}`,
              class: "material-file-input",
              type: "file",
              multiple: true,
              onChange: (event) => handleBidMaterialUpload(item, event),
            }),
            h("div", { class: "material-top" }, [
              h(ElIcon, { class: "material-icon" }, () => h(Document)),
              h(ElTag, { type: item.required ? "danger" : "info", size: "small" }, () => (item.required ? "必传" : "选传")),
            ]),
            h("h3", item.name),
            h("p", item.desc),
            h("div", { class: "material-actions" }, [
              h(ElButton, { type: "primary", plain: true, onClick: () => openBidMaterialPicker(item) }, () => "上传"),
            ]),
            files.length
              ? h("div", { class: "uploaded-files" }, files.map((file) =>
                h("div", { class: "uploaded-file", key: file.url || file.name }, [
                  h("span", { class: "file-name" }, `${file.name} ${formatFileSize(file.size)}`),
                  h("div", { class: "file-actions" }, [
                    h(ElButton, { text: true, type: "primary", onClick: () => previewMaterialFile(file) }, () => "预览"),
                    h(ElButton, { text: true, type: "primary", onClick: () => downloadMaterialFile(file) }, () => "下载"),
                    h(ElButton, { text: true, type: "danger", onClick: () => removeBidMaterialFile(item, file) }, () => "删除"),
                  ]),
                ])
              ))
              : h("div", { class: "upload-empty" }, "未选择文件"),
          ]);
        })),
      ]);
    const resetBidForm = () => {
      editingBid.value = null;
      clearBidUploadedFiles();
      Object.assign(bidForm, {
        tenderTitle: availableTenders.value[0]?.title || "",
        contact: "",
        phone: "",
        remark: "",
      });
    };
    const openCreate = () => {
      resetBidForm();
      formVisible.value = true;
    };
    const openEdit = (row) => {
      if (!["草稿", "已驳回"].includes(row.status)) {
        ElMessage.warning("当前状态不可编辑。");
        return;
      }
      editingBid.value = row;
      clearBidUploadedFiles();
      Object.assign(bidForm, {
        tenderTitle: row.tenderTitle,
        contact: row.contact,
        phone: row.phone,
        remark: row.auditOpinion || "",
      });
      formVisible.value = true;
    };
    const openDetail = (row) => {
      selectedBid.value = row;
      detailVisible.value = true;
    };
    const cancelForm = () => {
      formVisible.value = false;
      resetBidForm();
    };
    const upsertBidRow = (status) => {
      if (!bidForm.tenderTitle) {
        ElMessage.warning("请先选择招标公告。");
        return;
      }
      const tender = supplierTenderRows.find((item) => item.title === bidForm.tenderTitle);
      if (!tender || isTenderExpired(tender)) {
        ElMessage.warning("公告已截止或不可用，不能提交投标资料。");
        return;
      }
      if (status === "待审核" && !bidUploadedFiles[bidMaterialKey(bidMaterials[0])]?.length) {
        ElMessage.warning("请先上传投标资料文件。");
        return;
      }
      const payload = {
        tenderTitle: bidForm.tenderTitle,
        deadline: tender?.deadline || "-",
        submitTime: status === "待审核" ? "2026-05-26 16:30" : "-",
        contact: bidForm.contact || "未填写",
        phone: bidForm.phone || "未填写",
        materialsCount: `${getBidMaterialCount()} 项附件`,
        status,
        auditOpinion: status === "待审核" ? "投标资料已提交，等待平台审核。" : "草稿暂未提交。",
      };
      if (editingBid.value) {
        Object.assign(editingBid.value, payload);
      } else {
        bidSubmissionRows.unshift({
          bidNo: `TB-202605-${String(bidSubmissionRows.length + 1).padStart(3, "0")}`,
          ...payload,
        });
      }
      formVisible.value = false;
      resetBidForm();
      ElMessage.success(status === "待审核" ? "投标资料已提交审核" : "草稿已保存");
    };
    const cancelBidRow = (row) => {
      if (!["草稿", "待审核"].includes(row.status)) {
        ElMessage.warning("当前状态不可取消。");
        return;
      }
      Object.assign(row, {
        status: "已取消",
        auditOpinion: "供应商主动取消投标资料提交。",
      });
      ElMessage.success("已取消该投标资料提交记录");
    };
    const noticeItems = [
      "请按招标公告要求准备完整资料",
      "所有附件需清晰可读，内容真实有效",
      "提交后不可修改，请仔细核对",
      "平台仅记录提交信息，不保存文件内容",
    ];
    const bidTenderOptions = computed(() => Array.from(new Set(bidSubmissionRows.map((row) => row.tenderTitle).filter(Boolean))));
    const filteredBidRows = computed(() => {
      const keyword = bidFilters.keyword.trim();
      return bidSubmissionRows.filter((row) => {
        const matchKeyword = !keyword || [row.bidNo, row.tenderTitle, row.contact, row.phone].join(" ").includes(keyword);
        const matchStatus = !bidFilters.status || getBidListStatusLabel(row.status) === bidFilters.status;
        const matchTender = !bidFilters.tenderTitle || row.tenderTitle === bidFilters.tenderTitle;
        return matchKeyword && matchStatus && matchTender;
      });
    });
    const pagedBidRows = computed(() => {
      const start = (bidPage.value - 1) * bidPageSize.value;
      return filteredBidRows.value.slice(start, start + bidPageSize.value);
    });
    const resetBidFilters = () => {
      Object.assign(bidFilters, { keyword: "", status: "", tenderTitle: "" });
      bidPage.value = 1;
    };
    const renderBidActions = (row) =>
      h("div", { class: "table-actions" }, [
        h(ElButton, { size: "small", plain: true, onClick: () => openDetail(row) }, () => "查看"),
        ["草稿", "已驳回"].includes(row.status) ? h(ElButton, { size: "small", plain: true, onClick: () => openEdit(row) }, () => "编辑") : null,
        ["草稿", "待审核"].includes(row.status) ? h(ElButton, { size: "small", type: "danger", plain: true, onClick: () => cancelBidRow(row) }, () => "取消") : null,
      ].filter(Boolean));

    return () =>
      h("div", { class: "panel-stack" }, [
        h(ElCard, { shadow: "never", class: "content-card" }, {
          header: () => h("div", { class: "card-header" }, [
            h("div", [
              h("strong", "投标资料提交记录"),
              h("p", { class: "card-subtitle" }, "按公告下载模板，线下填写盖章后上传。网页只记录提交批次和附件。"),
            ]),
            h(ElButton, { type: "primary", onClick: openCreate }, () => "新增投标资料"),
          ]),
          default: () => h("div", [
            h("div", { class: "bid-list-filter-bar" }, [
              h(ElInput, {
                modelValue: bidFilters.keyword,
                "onUpdate:modelValue": (value) => {
                  bidFilters.keyword = value;
                  bidPage.value = 1;
                },
                placeholder: "搜索编号、公告名称、联系人",
                clearable: true,
                class: "bid-filter-keyword",
              }),
              h(ElSelect, {
                modelValue: bidFilters.status,
                "onUpdate:modelValue": (value) => {
                  bidFilters.status = value;
                  bidPage.value = 1;
                },
                placeholder: "投标状态",
                clearable: true,
                class: "bid-filter-select",
                popperClass: "bid-filter-popper",
              }, () => bidListStatusOptions.map((item) => h(ElOption, { key: item, label: item, value: item }))),
              h(ElSelect, {
                modelValue: bidFilters.tenderTitle,
                "onUpdate:modelValue": (value) => {
                  bidFilters.tenderTitle = value;
                  bidPage.value = 1;
                },
                placeholder: "关联公告",
                clearable: true,
                class: "bid-filter-select is-wide",
                popperClass: "bid-filter-popper is-wide",
              }, () => bidTenderOptions.value.map((item) => h(ElOption, { key: item, label: item, value: item }))),
              h(ElButton, { class: "bid-filter-reset", onClick: resetBidFilters }, () => "重置"),
            ]),
            h(ElTable, { data: pagedBidRows.value, border: true }, () => [
              h(ElTableColumn, { prop: "bidNo", label: "提交编号", width: 150 }),
              h(ElTableColumn, { prop: "tenderTitle", label: "公告标题", minWidth: 280 }),
              h(ElTableColumn, { prop: "deadline", label: "截止时间", width: 130 }),
              h(ElTableColumn, { prop: "submitTime", label: "提交时间", width: 160 }),
              h(ElTableColumn, { prop: "materialsCount", label: "附件", width: 110 }),
              h(ElTableColumn, { prop: "auditOpinion", label: "审核意见", minWidth: 210, showOverflowTooltip: true }),
              h(ElTableColumn, { prop: "status", label: "状态", width: 110 }, {
                default: ({ row }) => h(ElTag, { type: bidStatusTypeMap[row.status] || "info" }, () => getBidListStatusLabel(row.status)),
              }),
              h(ElTableColumn, { label: "操作", width: 220, fixed: "right" }, {
                default: ({ row }) => renderBidActions(row),
              }),
            ]),
            h("div", { class: "table-pagination" }, [
              h(ElPagination, {
                currentPage: bidPage.value,
                pageSize: bidPageSize.value,
                total: filteredBidRows.value.length,
                layout: "total, prev, pager, next",
                background: true,
                "onUpdate:currentPage": (value) => (bidPage.value = value),
              }),
            ]),
          ]),
        }),
        h(ElDialog, {
          modelValue: formVisible.value,
          "onUpdate:modelValue": (value) => {
            if (!value) cancelForm();
            else formVisible.value = value;
          },
          showClose: false,
          width: "1180px",
          class: "bid-submit-dialog",
        }, {
          header: () => h("div", { class: "bid-dialog-header" }, [
            h("div", { class: "bid-dialog-title" }, [
              h("div", { class: "bid-title-icon" }, [h(ElIcon, () => h(Document))]),
              h("div", [
                h("strong", editingBid.value ? "编辑投标资料" : "提交投标资料"),
                h("p", "请按要求上传完整资料，平台仅保存提交记录、联系人、备注和附件"),
              ]),
            ]),
            h(ElButton, { text: true, class: "dialog-close-btn", onClick: cancelForm }, () => "×"),
          ]),
          default: () => h("div", { class: "bid-dialog-body" }, [
            h("section", { class: "tender-template-box" }, [
              h("div", { class: "tender-select-field" }, [
                h("label", [h("span", "*"), "选择招标公告"]),
                h(ElSelect, {
                  modelValue: bidForm.tenderTitle,
                  "onUpdate:modelValue": (value) => (bidForm.tenderTitle = value),
                  placeholder: "请选择未截止公告",
                  class: "full",
                }, () => supplierTenderRows.map((item) =>
                  h(ElOption, {
                    key: item.title,
                    label: `${item.title}${isTenderExpired(item) ? "（已截止）" : ""}`,
                    value: item.title,
                    disabled: isTenderExpired(item),
                  })
                )),
              ]),
              h("div", { class: "template-block" }, [
                h("label", "投标模板"),
                h("div", { class: "template-download-field" }, [
                  h(ElButton, { type: "primary", plain: true, disabled: !selectedTender.value || selectedTenderExpired.value, onClick: downloadSelectedTemplate }, () => selectedTenderExpired.value ? "已截止不可下载" : "下载模板"),
                  h("span", selectedTender.value ? `模板截止：${selectedTender.value.deadline} 18:00` : "请先选择公告"),
                ]),
              ]),
            ]),
            h("div", { class: "bid-content-grid" }, [
              h("div", { class: "bid-dialog-main" }, [
                h(ElForm, { model: bidForm, labelPosition: "top", class: "clean-form bid-compact-form" }, () =>
                  h(ElRow, { gutter: 20 }, () => [
                    h(ElCol, { lg: 12, md: 12, sm: 24, xs: 24 }, () =>
                      h(ElFormItem, { label: "投标联系人", required: true }, () =>
                        h(ElInput, { modelValue: bidForm.contact, "onUpdate:modelValue": (value) => (bidForm.contact = value), placeholder: "请输入联系人" })
                      )
                    ),
                    h(ElCol, { lg: 12, md: 12, sm: 24, xs: 24 }, () =>
                      h(ElFormItem, { label: "联系电话", required: true }, () =>
                        h(ElInput, { modelValue: bidForm.phone, "onUpdate:modelValue": (value) => (bidForm.phone = value), placeholder: "请输入联系电话" })
                      )
                    ),
                    h(ElCol, { span: 24 }, () =>
                      h(ElFormItem, { label: "备注说明（选填）" }, () =>
                        h(ElInput, {
                          modelValue: bidForm.remark,
                          "onUpdate:modelValue": (value) => (bidForm.remark = value.slice(0, 500)),
                          type: "textarea",
                          rows: 4,
                          maxlength: 500,
                          showWordLimit: true,
                          placeholder: "可填写报价说明、资料说明或补充信息等",
                        })
                      )
                    ),
                  ])
                ),
                selectedTender.value
                  ? h("div", { class: "selected-tender-card" }, [
                    h("span", `公告发布时间：${selectedTender.value.date}`),
                    h("span", `截止时间：${selectedTender.value.deadline} 18:00`),
                    h("span", "当前状态："),
                    h(ElTag, { type: selectedTenderExpired.value ? "info" : "success" }, () => selectedTenderExpired.value ? "已截止" : selectedTender.value.status),
                  ])
                  : null,
                renderBidMaterialPanel(),
              ]),
              h("aside", { class: "bid-dialog-aside" }, [
                h("div", { class: "side-box" }, [
                  h("strong", "资料提交须知"),
                  h("ul", noticeItems.map((item) => h("li", item))),
                ]),
                h("div", { class: "side-box" }, [
                  h("strong", "提交记录"),
                  h("dl", [
                    h("div", [h("dt", "最近一次提交："), h("dd", latestBidRecord.value?.submitTime === "-" ? "暂无" : latestBidRecord.value?.submitTime || "暂无")]),
                    h("div", [h("dt", "提交状态："), h("dd", latestBidRecord.value?.status || "未提交")]),
                    h("div", [h("dt", "提交时间："), h("dd", latestBidRecord.value?.submitTime || "-")]),
                    h("div", [h("dt", "备注："), h("dd", latestBidRecord.value?.auditOpinion || "-")]),
                  ]),
                ]),
              ]),
            ]),
          ]),
          footer: () => h("div", { class: "form-footer-actions" }, [
            h(ElButton, { onClick: cancelForm }, () => "取消"),
            h(ElButton, { type: "primary", onClick: () => upsertBidRow("待审核") }, () => "确认提交"),
          ]),
        }),
        h(ElDialog, {
          modelValue: detailVisible.value,
          "onUpdate:modelValue": (value) => (detailVisible.value = value),
          title: "投标资料详情",
          width: "980px",
        }, {
          default: () =>
            selectedBid.value
              ? h("div", { class: "bid-detail-snapshot" }, [
                h("section", { class: "snapshot-section" }, [
                  h("div", { class: "snapshot-title" }, "提交信息"),
                  h(ElDescriptions, { column: 3, border: true, class: "audit-detail" }, () => [
                    h(ElDescriptionsItem, { label: "提交编号" }, () => selectedBid.value.bidNo),
                    h(ElDescriptionsItem, { label: "提交状态" }, () => h(ElTag, { type: bidStatusTypeMap[selectedBid.value.status] || "info" }, () => getBidListStatusLabel(selectedBid.value.status))),
                    h(ElDescriptionsItem, { label: "提交时间" }, () => selectedBid.value.submitTime),
                    h(ElDescriptionsItem, { label: "供应商名称" }, () => selectedBid.value.supplierName || "-"),
                    h(ElDescriptionsItem, { label: "联系人" }, () => selectedBid.value.contact),
                    h(ElDescriptionsItem, { label: "联系电话" }, () => selectedBid.value.phone),
                    h(ElDescriptionsItem, { label: "附件数量" }, () => selectedBid.value.materialsCount),
                    h(ElDescriptionsItem, { label: "审核意见", span: 2 }, () => selectedBid.value.auditOpinion || "-"),
                    h(ElDescriptionsItem, { label: "备注说明", span: 3 }, () => selectedBid.value.remark || "-"),
                  ]),
                ]),
                h("section", { class: "snapshot-section" }, [
                  h("div", { class: "snapshot-title" }, "公告信息"),
                  h(ElDescriptions, { column: 2, border: true, class: "audit-detail" }, () => [
                    h(ElDescriptionsItem, { label: "公告标题", span: 2 }, () => selectedBid.value.tenderTitle),
                    h(ElDescriptionsItem, { label: "发布日期" }, () => selectedBid.value.publishDate || "-"),
                    h(ElDescriptionsItem, { label: "截止时间" }, () => `${selectedBid.value.deadline || "-"} 18:00`),
                    h(ElDescriptionsItem, { label: "投标模板", span: 2 }, () => selectedBid.value.templateName || "-"),
                  ]),
                ]),
                h("section", { class: "snapshot-section" }, [
                  h("div", { class: "snapshot-title" }, "附件材料"),
                  h(ElTable, { data: selectedBid.value.materialSnapshot || [], border: true, class: "snapshot-material-table" }, () => [
                    h(ElTableColumn, { type: "index", label: "序号", width: 70 }),
                    h(ElTableColumn, { prop: "name", label: "附件名称", minWidth: 180 }),
                    h(ElTableColumn, { prop: "required", label: "要求", width: 90 }, {
                      default: ({ row }) => h(ElTag, { type: row.required === "必传" ? "danger" : "info" }, () => row.required || "-"),
                    }),
                    h(ElTableColumn, { prop: "fileName", label: "文件名称", minWidth: 240 }),
                    h(ElTableColumn, { prop: "size", label: "大小", width: 100 }),
                    h(ElTableColumn, { prop: "uploadTime", label: "上传时间", width: 160 }),
                    h(ElTableColumn, { prop: "status", label: "状态", width: 100 }, {
                      default: ({ row }) => h(ElTag, { type: row.status === "已上传" ? "success" : "info" }, () => row.status || "-"),
                    }),
                    h(ElTableColumn, { label: "操作", width: 140, fixed: "right" }, {
                      default: ({ row }) => row.status === "已上传"
                        ? renderPreviewDownloadActions(
                          () => previewSnapshotMaterial(selectedBid.value, row),
                          () => downloadSnapshotMaterial(selectedBid.value, row)
                        )
                        : h("span", "-"),
                    }),
                  ]),
                ]),
                h("section", { class: "snapshot-section" }, [
                  h("div", { class: "snapshot-title" }, "操作记录"),
                  h(ElTable, { data: selectedBid.value.logs || [], border: true }, () => [
                    h(ElTableColumn, { prop: "action", label: "操作", width: 140 }),
                    h(ElTableColumn, { prop: "operator", label: "操作人", width: 160 }),
                    h(ElTableColumn, { prop: "time", label: "操作时间", width: 180 }),
                    h(ElTableColumn, { prop: "remark", label: "说明", minWidth: 260 }),
                  ]),
                ]),
              ])
              : null,
          footer: () => h(ElButton, { type: "primary", onClick: () => (detailVisible.value = false) }, () => "关闭"),
        }),
      ]);
  },
});

const ReviewTaskPanel = defineComponent({
  setup() {
    const rows = [
      { title: "产业园区专项债咨询成果评审", deadline: "2026-06-02", status: "待评审" },
      { title: "新能源项目可研报告评审", deadline: "2026-06-05", status: "待评审" },
    ];
    return () =>
      h(ElCard, { shadow: "never", class: "content-card" }, {
        header: () => h("div", { class: "card-header" }, [h("strong", "评审任务")]),
        default: () =>
          h(ElTable, { data: rows, border: true }, () => [
            h(ElTableColumn, { prop: "title", label: "任务名称", minWidth: 260 }),
            h(ElTableColumn, { prop: "deadline", label: "截止时间", width: 140 }),
            h(ElTableColumn, { prop: "status", label: "状态", width: 120 }),
            h(ElTableColumn, { label: "操作", width: 140 }, { default: () => h(ElButton, { type: "primary", text: true }, () => "进入评审") }),
          ]),
      });
  },
});

const AuditPanel = defineComponent({
  props: { rows: { type: Array, required: true } },
  setup(props) {
    const detailVisible = ref(false);
    const selectedRecord = ref(null);
    const openDetail = (row) => {
      selectedRecord.value = row;
      detailVisible.value = true;
    };
    const detailItem = (label, value) => h(ElDescriptionsItem, { label }, () => value || "-");
    const materialCountItem = (record) =>
      h(ElDescriptionsItem, { label: "附件数量" }, () =>
        h("div", { class: "material-count-cell" }, [
          h("span", record.materialsCount || "-"),
          renderPreviewDownloadActions(
            () => previewApplicationMaterials(record),
            () => downloadApplicationMaterials(record)
          ),
        ])
      );
    const snapshotSection = (title, children) =>
      h("section", { class: "snapshot-section" }, [
        h("div", { class: "snapshot-title" }, title),
        children,
      ]);
    const renderReviewSnapshot = (record) =>
      h(ElDescriptions, { column: 2, border: true, class: "audit-detail" }, () => [
        detailItem("申请编号", record.applicationNo),
        detailItem("申请类型", record.applicationType),
        detailItem("提交时间", record.submitTime),
        detailItem("审核状态", record.status),
        detailItem("审核人", record.reviewer),
        detailItem("审核时间", record.reviewTime),
        materialCountItem(record),
        h(ElDescriptionsItem, { label: "审核意见", span: 2 }, () => record.opinion || "-"),
        record.status === "已驳回"
          ? h(ElDescriptionsItem, { label: "驳回原因", span: 2 }, () => (record.rejectReasons || []).join("；") || "-")
          : null,
        record.status === "已驳回"
          ? h(ElDescriptionsItem, { label: "批注", span: 2 }, () => record.rejectComment || "-")
          : null,
        record.status === "违规"
          ? h(ElDescriptionsItem, { label: "违规原因", span: 2 }, () => record.violationReason || "-")
          : null,
        record.status === "违规"
          ? h(ElDescriptionsItem, { label: "违规等级", span: 2 }, () => record.violationLevel || "-")
          : null,
        record.status === "违规"
          ? h(ElDescriptionsItem, { label: "处理建议", span: 2 }, () => record.violationSuggestion || "-")
          : null,
        role.value === "expert" && record.status === "已通过"
          ? h(ElDescriptionsItem, { label: "返聘证书", span: 2 }, () =>
            record.appointmentCertificate
              ? h("div", { class: "certificate-action-cell" }, [
                h("span", record.appointmentCertificate.name),
                renderPreviewDownloadActions(
                  () => previewAppointmentCertificate(record.appointmentCertificate),
                  () => downloadAppointmentCertificate(record.appointmentCertificate)
                ),
              ])
              : "-"
          )
          : null,
      ].filter(Boolean));
    const renderApplicationSnapshot = (record) =>
      h(ElDescriptions, { column: 3, border: true, class: "audit-detail" }, () =>
        (record.snapshot || []).map((item) => h(ElDescriptionsItem, { label: item.label }, () => item.value || "-"))
      );
    const renderMaterialSnapshot = (record) =>
      h(ElTable, { data: record.materialSnapshot || [], border: true, class: "snapshot-material-table" }, () => [
        h(ElTableColumn, { type: "index", label: "序号", width: 70 }),
        h(ElTableColumn, { prop: "name", label: "附件名称", minWidth: 220 }),
        h(ElTableColumn, { prop: "required", label: "要求", width: 90 }, {
          default: ({ row }) => h(ElTag, { type: row.required === "必传" ? "danger" : "info" }, () => row.required || "-"),
        }),
        h(ElTableColumn, { prop: "fileName", label: "提交文件", minWidth: 240 }),
        h(ElTableColumn, { prop: "uploadTime", label: "上传时间", width: 170 }),
        h(ElTableColumn, { prop: "status", label: "状态", width: 100 }, {
          default: ({ row }) => h(ElTag, { type: row.status === "已上传" ? "success" : "warning" }, () => row.status || "-"),
        }),
        h(ElTableColumn, { label: "操作", width: 140, fixed: "right" }, {
          default: ({ row }) => renderPreviewDownloadActions(
            () => previewSnapshotMaterial(record, row),
            () => downloadSnapshotMaterial(record, row)
          ),
        }),
      ]);
    const statusBlock = (row) => {
      if (row.status === "已驳回") {
        return h("div", { class: "audit-reason-card is-reject" }, [
          h("strong", "驳回原因"),
          h("ol", (row.rejectReasons || []).map((item) => h("li", item))),
          h("p", [h("b", "批注："), row.rejectComment || "-"]),
        ]);
      }
      if (row.status === "违规") {
        return h("div", { class: "audit-reason-card is-violation" }, [
          h("strong", "违规原因"),
          h("p", row.violationReason || "-"),
          h("div", { class: "violation-fields" }, [
            h("span", "违规等级"),
            h(ElTag, { type: "warning" }, () => row.violationLevel || "-"),
          ]),
          h("p", [h("b", "处理建议："), row.violationSuggestion || "-"]),
        ]);
      }
      if (row.status === "已通过") {
        return h("div", { class: "audit-reason-card is-approved" }, [
          h("strong", "审核通过"),
          h("p", row.opinion || "审核通过，已入库。"),
        ].filter(Boolean));
      }
      return h("div", { class: "audit-reason-card" }, [
        h("strong", "审核说明"),
        h("p", row.opinion || "暂无审核意见。"),
      ]);
    };

    return () =>
      h("div", [
        props.rows[0] ? statusBlock(props.rows[0]) : null,
        h(ElCard, { shadow: "never", class: "content-card" }, {
          header: () => h("div", { class: "card-header" }, [h("strong", "审核记录")]),
          default: () =>
            h(ElTable, { data: props.rows, border: true }, () => [
              h(ElTableColumn, { prop: "applicationNo", label: "申请编号", minWidth: 170 }),
              h(ElTableColumn, { prop: "applicationType", label: "申请类型", minWidth: 150 }),
              h(ElTableColumn, { prop: "applicant", label: "申请对象", minWidth: 160 }),
              h(ElTableColumn, { prop: "category", label: "类别/专业", minWidth: 160 }),
              h(ElTableColumn, { prop: "submitTime", label: "提交时间", width: 160 }),
              h(ElTableColumn, { prop: "status", label: "审核状态", width: 120 }, {
                default: ({ row }) => h(ElTag, { type: statusTypeMap[row.status] || "info" }, () => row.status),
              }),
              h(ElTableColumn, { prop: "reviewTime", label: "审核时间", width: 160 }),
              role.value === "expert"
                ? h(ElTableColumn, { label: "返聘证书", width: 150 }, {
                  default: ({ row }) => row.appointmentCertificate
                    ? renderPreviewDownloadActions(
                      () => previewAppointmentCertificate(row.appointmentCertificate),
                      () => downloadAppointmentCertificate(row.appointmentCertificate)
                    )
                    : h("span", "-"),
                })
                : null,
              h(ElTableColumn, { label: "操作", width: 120, fixed: "right" }, {
                default: ({ row }) => h(ElButton, { type: "primary", text: true, onClick: () => openDetail(row) }, () => "查看详情"),
              }),
            ].filter(Boolean)),
        }),
        h(ElDialog, {
          modelValue: detailVisible.value,
          "onUpdate:modelValue": (value) => (detailVisible.value = value),
          title: "审核记录详情",
          width: "980px",
        }, {
          default: () =>
            selectedRecord.value
              ? h("div", { class: "audit-snapshot-dialog" }, [
                snapshotSection("审批信息", renderReviewSnapshot(selectedRecord.value)),
                snapshotSection("申请信息快照", renderApplicationSnapshot(selectedRecord.value)),
                snapshotSection("附件材料快照", renderMaterialSnapshot(selectedRecord.value)),
              ])
              : null,
          footer: () => h(ElButton, { type: "primary", onClick: () => (detailVisible.value = false) }, () => "关闭"),
        }),
      ]);
  },
});

const NoticeListPanel = defineComponent({
  props: {
    messages: { type: Array, required: true },
  },
  setup(props) {
    const activeTab = ref("全部");
    const detailVisible = ref(false);
    const selectedMessage = ref(null);
    const unreadCount = computed(() => props.messages.filter((item) => item.status === "未读").length);
    const filteredMessages = computed(() => {
      if (activeTab.value === "全部") return props.messages;
      return props.messages.filter((item) => item.status === activeTab.value);
    });
    const openMessage = (row) => {
      selectedMessage.value = row;
      row.status = "已读";
      detailVisible.value = true;
    };
    const markAllRead = () => {
      props.messages.forEach((item) => {
        item.status = "已读";
      });
      ElMessage.success("已全部标记为已读");
    };
    return () => h("div", { class: "message-center" }, [
      h(ElCard, { shadow: "never", class: "content-card" }, {
        header: () => h("div", { class: "card-header" }, [
          h("div", [h("strong", "消息通知"), h("p", { class: "card-subtitle" }, "平台审核、资料补正、公告提醒会集中显示在这里。")]),
          h(ElButton, { plain: true, disabled: unreadCount.value === 0, onClick: markAllRead }, () => "全部已读"),
        ]),
        default: () => h("div", [
          h(ElTabs, { modelValue: activeTab.value, "onUpdate:modelValue": (value) => (activeTab.value = value), class: "message-tabs" }, () => [
            h(ElTabPane, { label: `全部(${props.messages.length})`, name: "全部" }),
            h(ElTabPane, { label: `未读(${unreadCount.value})`, name: "未读" }),
            h(ElTabPane, { label: `已读(${props.messages.length - unreadCount.value})`, name: "已读" }),
          ]),
          h(ElTable, { data: filteredMessages.value, border: true, class: "message-table" }, () => [
            h(ElTableColumn, { prop: "category", label: "类型", width: 120 }, {
              default: ({ row }) => h(ElTag, { type: row.type || "info" }, () => row.category),
            }),
            h(ElTableColumn, { prop: "title", label: "消息标题", minWidth: 260 }, {
              default: ({ row }) => h("div", { class: ["message-title-cell", row.status === "未读" ? "is-unread" : ""] }, [
                row.status === "未读" ? h("i") : null,
                h("span", row.title),
              ]),
            }),
            h(ElTableColumn, { prop: "related", label: "关联事项", minWidth: 220, showOverflowTooltip: true }),
            h(ElTableColumn, { prop: "reason", label: "原因摘要", minWidth: 220, showOverflowTooltip: true }),
            h(ElTableColumn, { prop: "time", label: "通知时间", width: 170 }),
            h(ElTableColumn, { prop: "status", label: "状态", width: 100 }, {
              default: ({ row }) => h(ElTag, { type: row.status === "未读" ? "danger" : "info" }, () => row.status),
            }),
            h(ElTableColumn, { label: "操作", width: 100, fixed: "right" }, {
              default: ({ row }) => h("div", { class: "table-actions" }, [
                h(ElButton, { size: "small", plain: true, onClick: () => openMessage(row) }, () => "查看"),
              ]),
            }),
          ]),
        ]),
      }),
      h(ElDialog, {
        modelValue: detailVisible.value,
        "onUpdate:modelValue": (value) => (detailVisible.value = value),
        title: "消息详情",
        width: "640px",
      }, {
        default: () => selectedMessage.value
          ? h("div", { class: "message-detail" }, [
            h("div", { class: "message-detail-head" }, [
              h(ElTag, { type: selectedMessage.value.type || "info" }, () => selectedMessage.value.category),
              h("strong", selectedMessage.value.title),
            ]),
            h("p", selectedMessage.value.content),
            h(ElDescriptions, { column: 2, border: true, class: "audit-detail" }, () => [
              h(ElDescriptionsItem, { label: "关联事项" }, () => selectedMessage.value.related || "-"),
              h(ElDescriptionsItem, { label: "通知时间" }, () => selectedMessage.value.time || "-"),
              h(ElDescriptionsItem, { label: "状态" }, () => selectedMessage.value.status || "-"),
              h(ElDescriptionsItem, { label: "原因/说明", span: 2 }, () => selectedMessage.value.reason || "-"),
              h(ElDescriptionsItem, { label: "处理建议", span: 2 }, () => selectedMessage.value.suggestion || "-"),
            ]),
          ])
          : null,
        footer: () => h(ElButton, { type: "primary", onClick: () => (detailVisible.value = false) }, () => "关闭"),
      }),
    ]);
  },
});

const MaterialCardView = defineComponent({
  props: { materials: { type: Array, required: true } },
  setup(props) {
    return () => materialCard(props.materials);
  },
});

const MessagePanel = defineComponent({
  props: { rows: { type: Array, required: true } },
  setup(props) {
    const activeTab = ref("all");
    const renderMessages = (status) => {
      const rows = status === "all" ? props.rows : props.rows.filter((item) => item.status === status);
      return h("div", { class: "message-list" }, rows.map((item) =>
        h("div", { class: ["message-item", item.status === "未读" ? "is-unread" : ""] }, [
          h("div", { class: "message-title" }, [
            h("strong", item.title),
            h(ElTag, { type: item.type, size: "small" }, () => item.status),
          ]),
          h("p", item.content),
          h("span", item.time),
        ])
      ));
    };

    return () =>
      h(ElCard, { shadow: "never", class: "content-card" }, {
        header: () => h("div", { class: "card-header" }, [h("strong", "平台消息")]),
        default: () =>
          h(ElTabs, { modelValue: activeTab.value, "onUpdate:modelValue": (value) => (activeTab.value = value), class: "message-tabs" }, () => [
            h(ElTabPane, { label: "全部", name: "all" }, () => renderMessages("all")),
            h(ElTabPane, { label: "未读", name: "未读" }, () => renderMessages("未读")),
            h(ElTabPane, { label: "已读", name: "已读" }, () => renderMessages("已读")),
          ]),
      });
  },
});

const AdminAuditPanel = defineComponent({
  props: {
    title: { type: String, required: true },
    rows: { type: Array, required: true },
    type: { type: String, default: "supplier" },
  },
  setup(props) {
    const filters = reactive({
      keyword: "",
      status: "",
      category: "",
    });
    const currentPage = ref(1);
    const pageSize = ref(5);
    const detailVisible = ref(false);
    const selectedRecord = ref(null);
    const certificateDialog = reactive({
      visible: false,
      row: null,
      file: null,
    });
    const rejectDialog = reactive({
      visible: false,
      row: null,
      reason: "",
      comment: "",
    });
    const adminStatusLabelMap = {
      待审核: "待审批",
      已通过: "通过",
      已驳回: "驳回",
      草稿: "待审批",
      已取消: "驳回",
    };
    const adminStatusTypeMap = {
      待审批: "warning",
      通过: "success",
      驳回: "danger",
    };
    const getAdminStatusLabel = (row) => adminStatusLabelMap[row.status] || row.status || "-";
    const getAdminStatusType = (row) => adminStatusTypeMap[getAdminStatusLabel(row)] || "info";
    const statusOptions = computed(() => ["待审批", "通过", "驳回"]);
    const categoryOptionsForRows = computed(() =>
      Array.from(new Set(props.rows.map((row) => props.type === "bid" ? row.tenderTitle : row.category).filter(Boolean)))
    );
    const filteredRows = computed(() => {
      const keyword = filters.keyword.trim();
      return props.rows.filter((row) => {
        const rowText = props.type === "bid"
          ? [row.bidNo, row.supplierName, row.tenderTitle, row.contact, row.phone].join(" ")
          : [row.applicationNo, row.name, row.category, row.business, row.title, row.contact, row.phone, row.provinceCity].join(" ");
        const matchKeyword = !keyword || rowText.includes(keyword);
        const matchStatus = !filters.status || getAdminStatusLabel(row) === filters.status;
        const rowCategory = props.type === "bid" ? row.tenderTitle : row.category;
        const matchCategory = !filters.category || rowCategory === filters.category;
        return matchKeyword && matchStatus && matchCategory;
      });
    });
    const pagedRows = computed(() => {
      const start = (currentPage.value - 1) * pageSize.value;
      return filteredRows.value.slice(start, start + pageSize.value);
    });
    const resetFilters = () => {
      Object.assign(filters, { keyword: "", status: "", category: "" });
      currentPage.value = 1;
    };
    const openDetail = (row) => {
      selectedRecord.value = row;
      detailVisible.value = true;
    };
    const openCertificateDialog = (row) => {
      certificateDialog.visible = true;
      certificateDialog.row = row;
      certificateDialog.file = null;
    };
    const handleCertificateUpload = (event) => {
      const file = event.target.files?.[0];
      if (file) {
        certificateDialog.file = {
          name: file.name,
          size: formatFileSize(file.size),
          type: file.type,
          url: URL.createObjectURL(file),
          uploadTime: "2026-05-28 09:30",
        };
      }
      event.target.value = "";
    };
    const chooseCertificateFile = () => {
      document.getElementById("expert-appointment-certificate-file")?.click();
    };
    const openRejectDialog = (row) => {
      rejectDialog.visible = true;
      rejectDialog.row = row;
      rejectDialog.reason = row.rejectReason || row.auditOpinion || "";
      rejectDialog.comment = row.rejectComment || "";
    };
    const completeAudit = (row, status, extra = {}) => {
      const rejectReason = extra.rejectReason || "资料不完整或不符合要求，已驳回。";
      Object.assign(row, {
        status,
        reviewTime: "2026-05-28 09:30",
        auditOpinion: status === "已通过" ? "平台审核通过，资料已归档。" : rejectReason,
        opinion: status === "已通过" ? "平台审核通过，资料已归档。" : rejectReason,
      });
      if (status === "已驳回") {
        row.rejectReason = rejectReason;
        row.rejectReasons = rejectReason.split(/[；;\n]/).map((item) => item.trim()).filter(Boolean);
        row.rejectComment = extra.rejectComment || "";
      }
      if (props.type === "expert" && status === "已通过") {
        row.appointmentCertificate = certificateDialog.file || {
          name: `${row.name || "专家"}-返聘证书.pdf`,
          uploadTime: "2026-05-28 09:30",
          size: "-",
        };
      }
      ElMessage.success(status === "已通过" ? "已审核通过" : "已驳回");
    };
    const markAudit = (row, status) => {
      if (props.type === "bid" && !["待审核", "已驳回"].includes(row.status)) {
        ElMessage.warning("当前投标资料状态不可审核。");
        return;
      }
      if (props.type !== "bid" && row.status !== "待审核") {
        ElMessage.warning("当前入库申请状态不可审核。");
        return;
      }
      if (props.type === "expert" && status === "已通过") {
        openCertificateDialog(row);
        return;
      }
      if (status === "已驳回") {
        openRejectDialog(row);
        return;
      }
      completeAudit(row, status);
    };
    const confirmReject = () => {
      if (!rejectDialog.reason.trim()) {
        ElMessage.warning("请填写驳回原因。");
        return;
      }
      completeAudit(rejectDialog.row, "已驳回", {
        rejectReason: rejectDialog.reason.trim(),
        rejectComment: rejectDialog.comment.trim(),
      });
      rejectDialog.visible = false;
      rejectDialog.row = null;
      rejectDialog.reason = "";
      rejectDialog.comment = "";
    };
    const confirmExpertApprove = () => {
      if (!certificateDialog.file) {
        ElMessage.warning("请先上传返聘证书附件。");
        return;
      }
      completeAudit(certificateDialog.row, "已通过");
      certificateDialog.visible = false;
      certificateDialog.row = null;
      certificateDialog.file = null;
    };
    const downloadRowMaterials = (row) => {
      const materials = row.materialSnapshot || [];
      const content = [
        `${props.title}附件清单`,
        `编号：${row.applicationNo || row.bidNo || "-"}`,
        `对象：${row.name || row.supplierName || "-"}`,
        "",
        ...materials.map((item, index) => `${index + 1}. ${item.name} ${item.required || ""} ${item.fileName || "-"} ${item.uploadTime || "-"}`),
      ].join("\n");
      const blob = new Blob([content], { type: "text/plain;charset=utf-8" });
      const url = URL.createObjectURL(blob);
      downloadFile(url, `${row.applicationNo || row.bidNo || "materials"}-附件清单.txt`);
      setTimeout(() => URL.revokeObjectURL(url), 0);
    };
    const renderFilters = () =>
      h("div", { class: "admin-filter-bar" }, [
        h(ElInput, {
          modelValue: filters.keyword,
          "onUpdate:modelValue": (value) => {
            filters.keyword = value;
            currentPage.value = 1;
          },
          placeholder: props.type === "bid" ? "搜索供应商、公告、提交编号" : "搜索名称、编号、联系人",
          clearable: true,
          class: "admin-filter-keyword",
        }),
        h(ElSelect, {
          modelValue: filters.status,
          "onUpdate:modelValue": (value) => {
            filters.status = value;
            currentPage.value = 1;
          },
          placeholder: props.type === "bid" ? "投标状态" : "入库状态",
          clearable: true,
          class: "admin-filter-select",
        }, () => statusOptions.value.map((item) => h(ElOption, { key: item, label: item, value: item }))),
        h(ElSelect, {
          modelValue: filters.category,
          "onUpdate:modelValue": (value) => {
            filters.category = value;
            currentPage.value = 1;
          },
          placeholder: props.type === "bid" ? "关联公告" : "类别/专业",
          clearable: true,
          class: "admin-filter-select is-wide",
        }, () => categoryOptionsForRows.value.map((item) => h(ElOption, { key: item, label: item, value: item }))),
        h(ElButton, { onClick: resetFilters }, () => "重置"),
      ]);
    const renderAppColumns = () => [
      h(ElTableColumn, { prop: "applicationNo", label: "申请编号", width: 170 }),
      h(ElTableColumn, { prop: "name", label: "申请对象", minWidth: 220 }),
      h(ElTableColumn, { prop: "category", label: props.type === "expert" ? "所属行业" : "供应商类型", width: 130 }),
      h(ElTableColumn, { prop: props.type === "expert" ? "title" : "business", label: props.type === "expert" ? "职称" : "业务方向", width: 140 }),
      h(ElTableColumn, { prop: "phone", label: "手机号", width: 130 }),
      h(ElTableColumn, { prop: "provinceCity", label: "所在省市区", width: 150 }),
      h(ElTableColumn, { prop: "materialsCount", label: "附件", width: 110 }),
      props.type === "expert"
        ? h(ElTableColumn, { label: "返聘证书", width: 150 }, {
          default: ({ row }) => row.appointmentCertificate
            ? renderPreviewDownloadActions(
              () => previewAppointmentCertificate(row.appointmentCertificate),
              () => downloadAppointmentCertificate(row.appointmentCertificate)
            )
            : h("span", "-"),
        })
        : null,
      h(ElTableColumn, { prop: "submitTime", label: "提交时间", width: 165 }),
      h(ElTableColumn, { prop: "status", label: "状态", width: 110 }, {
        default: ({ row }) => h(ElTag, { type: getAdminStatusType(row) }, () => getAdminStatusLabel(row)),
      }),
      h(ElTableColumn, { label: "审核意见/驳回原因", minWidth: 220, showOverflowTooltip: true }, {
        default: ({ row }) => row.rejectReason || row.opinion || "-",
      }),
      h(ElTableColumn, { label: "操作", width: 340, fixed: "right" }, {
        default: ({ row }) => h("div", { class: "table-actions" }, [
          h(ElButton, { size: "small", plain: true, onClick: () => openDetail(row) }, () => "详情"),
          h(ElButton, { size: "small", plain: true, onClick: () => previewApplicationMaterials(row) }, () => "预览附件"),
          h(ElButton, { size: "small", plain: true, onClick: () => downloadRowMaterials(row) }, () => "下载附件"),
          row.status === "待审核" ? h(ElButton, { size: "small", type: "success", plain: true, onClick: () => markAudit(row, "已通过") }, () => "通过") : null,
          row.status === "待审核" ? h(ElButton, { size: "small", type: "danger", plain: true, onClick: () => markAudit(row, "已驳回") }, () => "驳回") : null,
        ].filter(Boolean)),
      }),
    ].filter(Boolean);
    const renderBidColumns = () => [
      h(ElTableColumn, { prop: "bidNo", label: "提交编号", width: 150 }),
      h(ElTableColumn, { prop: "supplierName", label: "供应商", minWidth: 220 }),
      h(ElTableColumn, { prop: "tenderTitle", label: "关联公告", minWidth: 280, showOverflowTooltip: true }),
      h(ElTableColumn, { prop: "deadline", label: "公告截止", width: 125 }),
      h(ElTableColumn, { prop: "contact", label: "联系人", width: 110 }),
      h(ElTableColumn, { prop: "phone", label: "电话", width: 125 }),
      h(ElTableColumn, { prop: "materialsCount", label: "附件", width: 110 }),
      h(ElTableColumn, { prop: "submitTime", label: "提交时间", width: 160 }),
      h(ElTableColumn, { prop: "status", label: "状态", width: 110 }, {
        default: ({ row }) => h(ElTag, { type: getAdminStatusType(row) }, () => getAdminStatusLabel(row)),
      }),
      h(ElTableColumn, { label: "审核意见/驳回原因", minWidth: 220, showOverflowTooltip: true }, {
        default: ({ row }) => row.rejectReason || row.auditOpinion || "-",
      }),
      h(ElTableColumn, { label: "操作", width: 340, fixed: "right" }, {
        default: ({ row }) => h("div", { class: "table-actions" }, [
          h(ElButton, { size: "small", plain: true, onClick: () => openDetail(row) }, () => "详情"),
          h(ElButton, { size: "small", plain: true, onClick: () => previewApplicationMaterials(row) }, () => "预览附件"),
          h(ElButton, { size: "small", plain: true, onClick: () => downloadRowMaterials(row) }, () => "下载附件"),
          row.status === "待审核" ? h(ElButton, { size: "small", type: "success", plain: true, onClick: () => markAudit(row, "已通过") }, () => "通过") : null,
          row.status === "待审核" ? h(ElButton, { size: "small", type: "danger", plain: true, onClick: () => markAudit(row, "已驳回") }, () => "驳回") : null,
        ].filter(Boolean)),
      }),
    ];
    const renderDetail = () => {
      const row = selectedRecord.value;
      if (!row) return null;
      const isBid = props.type === "bid";
      return h("div", { class: "audit-snapshot-dialog" }, [
        h("section", { class: "snapshot-section" }, [
          h("div", { class: "snapshot-title" }, isBid ? "投标提交信息" : "申请审核信息"),
          h(ElDescriptions, { column: 3, border: true, class: "audit-detail" }, () => isBid
            ? [
              h(ElDescriptionsItem, { label: "提交编号" }, () => row.bidNo || "-"),
              h(ElDescriptionsItem, { label: "供应商" }, () => row.supplierName || "-"),
              h(ElDescriptionsItem, { label: "状态" }, () => h(ElTag, { type: getAdminStatusType(row) }, () => getAdminStatusLabel(row))),
              h(ElDescriptionsItem, { label: "公告标题", span: 3 }, () => row.tenderTitle || "-"),
              h(ElDescriptionsItem, { label: "公告截止" }, () => row.deadline || "-"),
              h(ElDescriptionsItem, { label: "联系人" }, () => row.contact || "-"),
              h(ElDescriptionsItem, { label: "联系电话" }, () => row.phone || "-"),
              h(ElDescriptionsItem, { label: "审核意见", span: 3 }, () => row.auditOpinion || "-"),
              row.status === "已驳回"
                ? h(ElDescriptionsItem, { label: "驳回原因", span: 3 }, () => row.rejectReason || row.auditOpinion || "-")
                : null,
              row.status === "已驳回"
                ? h(ElDescriptionsItem, { label: "驳回批注", span: 3 }, () => row.rejectComment || "-")
                : null,
            ]
            : [
              h(ElDescriptionsItem, { label: "申请编号" }, () => row.applicationNo || "-"),
              h(ElDescriptionsItem, { label: "申请对象" }, () => row.name || "-"),
              h(ElDescriptionsItem, { label: "状态" }, () => h(ElTag, { type: getAdminStatusType(row) }, () => getAdminStatusLabel(row))),
              h(ElDescriptionsItem, { label: "类别/专业" }, () => row.category || "-"),
              h(ElDescriptionsItem, { label: props.type === "expert" ? "职称" : "业务方向" }, () => row.title || row.business || "-"),
              h(ElDescriptionsItem, { label: "提交时间" }, () => row.submitTime || "-"),
              h(ElDescriptionsItem, { label: "手机号" }, () => row.phone || "-"),
              h(ElDescriptionsItem, { label: "所在省市区" }, () => row.provinceCity || "-"),
              h(ElDescriptionsItem, { label: "附件数量" }, () => row.materialsCount || "-"),
              props.type === "expert"
                ? h(ElDescriptionsItem, { label: "返聘证书" }, () =>
                  row.appointmentCertificate
                    ? h("div", { class: "certificate-action-cell" }, [
                      h("span", row.appointmentCertificate.name),
                      renderPreviewDownloadActions(
                        () => previewAppointmentCertificate(row.appointmentCertificate),
                        () => downloadAppointmentCertificate(row.appointmentCertificate)
                      ),
                    ])
                    : "-"
                )
                : null,
              h(ElDescriptionsItem, { label: "审核意见", span: 3 }, () => row.opinion || "-"),
              row.status === "已驳回"
                ? h(ElDescriptionsItem, { label: "驳回原因", span: 3 }, () => row.rejectReason || (row.rejectReasons || []).join("；") || "-")
                : null,
              row.status === "已驳回"
                ? h(ElDescriptionsItem, { label: "驳回批注", span: 3 }, () => row.rejectComment || "-")
                : null,
            ].filter(Boolean)),
        ]),
        !isBid
          ? h("section", { class: "snapshot-section" }, [
            h("div", { class: "snapshot-title" }, "基础资料快照"),
            h(ElDescriptions, { column: 3, border: true, class: "audit-detail" }, () =>
              (row.snapshot || []).map((item) => h(ElDescriptionsItem, { label: item.label }, () => item.value || "-"))
            ),
          ])
          : null,
        h("section", { class: "snapshot-section" }, [
          h("div", { class: "snapshot-title" }, "附件材料"),
          h(ElTable, { data: row.materialSnapshot || [], border: true, class: "snapshot-material-table" }, () => [
            h(ElTableColumn, { type: "index", label: "序号", width: 70 }),
            h(ElTableColumn, { prop: "name", label: "附件名称", minWidth: 220 }),
            h(ElTableColumn, { prop: "required", label: "要求", width: 90 }, {
              default: ({ row: material }) => h(ElTag, { type: material.required === "必传" ? "danger" : "info" }, () => material.required || "-"),
            }),
            h(ElTableColumn, { prop: "fileName", label: "提交文件", minWidth: 240 }),
            h(ElTableColumn, { prop: "uploadTime", label: "上传时间", width: 170 }),
            h(ElTableColumn, { prop: "status", label: "状态", width: 100 }, {
              default: ({ row: material }) => h(ElTag, { type: material.status === "已上传" ? "success" : "info" }, () => material.status || "-"),
            }),
            h(ElTableColumn, { label: "操作", width: 140, fixed: "right" }, {
              default: ({ row: material }) => renderPreviewDownloadActions(
                () => previewSnapshotMaterial(row, material),
                () => downloadSnapshotMaterial(row, material)
              ),
            }),
          ]),
        ]),
      ].filter(Boolean));
    };
    return () =>
      h("div", { class: "panel-stack" }, [
        h(ElCard, { shadow: "never", class: "content-card" }, {
          header: () => h("div", { class: "card-header" }, [
            h("div", [h("strong", props.title), h("p", { class: "card-subtitle" }, "可按关键字、状态和类别筛选，并查看资料快照。")]),
            h(ElButton, { type: "primary", plain: true }, () => "导出列表"),
          ]),
          default: () => h("div", [
            renderFilters(),
            h(ElTable, { data: pagedRows.value, border: true }, () => props.type === "bid" ? renderBidColumns() : renderAppColumns()),
            h("div", { class: "table-pagination" }, [
              h(ElPagination, {
                currentPage: currentPage.value,
                pageSize: pageSize.value,
                total: filteredRows.value.length,
                layout: "total, prev, pager, next",
                background: true,
                "onUpdate:currentPage": (value) => (currentPage.value = value),
              }),
            ]),
          ]),
        }),
        h(ElDialog, {
          modelValue: detailVisible.value,
          "onUpdate:modelValue": (value) => (detailVisible.value = value),
          title: `${props.title}详情`,
          width: "1040px",
        }, {
          default: renderDetail,
          footer: () => h("div", { class: "form-footer-actions" }, [
            selectedRecord.value?.status === "待审核" ? h(ElButton, { type: "success", plain: true, onClick: () => markAudit(selectedRecord.value, "已通过") }, () => "审核通过") : null,
            selectedRecord.value?.status === "待审核" ? h(ElButton, { type: "danger", plain: true, onClick: () => markAudit(selectedRecord.value, "已驳回") }, () => "审核驳回") : null,
            h(ElButton, { type: "primary", onClick: () => (detailVisible.value = false) }, () => "关闭"),
          ].filter(Boolean)),
        }),
        h(ElDialog, {
          modelValue: certificateDialog.visible,
          "onUpdate:modelValue": (value) => (certificateDialog.visible = value),
          title: "上传返聘证书",
          width: "640px",
          class: "appointment-cert-dialog",
        }, {
          default: () => h("div", { class: "certificate-upload-box" }, [
            h("input", {
              id: "expert-appointment-certificate-file",
              type: "file",
              class: "material-file-input",
              accept: ".pdf,.doc,.docx,.jpg,.jpeg,.png",
              onChange: handleCertificateUpload,
            }),
            h("div", { class: "certificate-tip" }, [
              h(ElIcon, () => h(Document)),
              h("div", [
                h("strong", "审核通过附件"),
                h("p", "专家审核通过前需上传返聘证书，证书会同步展示在专家端审核记录中。"),
              ]),
            ]),
            h("div", { class: ["certificate-picker", certificateDialog.file ? "is-selected" : ""] }, [
              h("div", { class: "certificate-file-icon" }, [
                h(ElIcon, () => h(Document)),
              ]),
              h("div", { class: "certificate-file-main" }, [
                h("strong", certificateDialog.file?.name || "请选择返聘证书附件"),
                h("span", certificateDialog.file ? `已选择，文件大小 ${certificateDialog.file.size || "-"}` : "支持 PDF、Word、JPG、PNG 格式"),
              ]),
              h(ElButton, { type: "primary", plain: true, onClick: chooseCertificateFile }, () => certificateDialog.file ? "重新选择" : "选择文件"),
            ]),
            h("div", { class: "certificate-note" }, [
              h("span", "注意"),
              h("p", "未上传返聘证书时不能确认通过。真实系统中该附件应作为专家入库审核通过后的归档文件。"),
            ]),
          ]),
          footer: () => h("div", { class: "form-footer-actions" }, [
            h(ElButton, {
              onClick: () => {
                certificateDialog.visible = false;
                certificateDialog.row = null;
                certificateDialog.file = null;
              },
            }, () => "取消"),
            h(ElButton, { type: "primary", onClick: confirmExpertApprove }, () => "确认通过"),
          ]),
        }),
        h(ElDialog, {
          modelValue: rejectDialog.visible,
          "onUpdate:modelValue": (value) => (rejectDialog.visible = value),
          title: "填写驳回原因",
          width: "640px",
          class: "reject-reason-dialog",
        }, {
          default: () => h("div", { class: "reject-reason-box" }, [
            h("div", { class: "reject-target" }, [
              h("span", "驳回对象"),
              h("strong", rejectDialog.row?.name || rejectDialog.row?.supplierName || rejectDialog.row?.bidNo || "-"),
            ]),
            h(ElForm, { labelPosition: "top", class: "clean-form" }, () => [
              h(ElFormItem, { label: "驳回原因", required: true }, () =>
                h(ElInput, {
                  modelValue: rejectDialog.reason,
                  "onUpdate:modelValue": (value) => (rejectDialog.reason = value),
                  type: "textarea",
                  rows: 4,
                  maxlength: 300,
                  showWordLimit: true,
                  placeholder: "请填写资料不通过的具体原因，例如：证书缺失、附件不清晰、信息不一致等",
                })
              ),
              h(ElFormItem, { label: "平台批注" }, () =>
                h(ElInput, {
                  modelValue: rejectDialog.comment,
                  "onUpdate:modelValue": (value) => (rejectDialog.comment = value),
                  type: "textarea",
                  rows: 3,
                  maxlength: 200,
                  showWordLimit: true,
                  placeholder: "可补充整改要求或内部说明",
                })
              ),
            ]),
          ]),
          footer: () => h("div", { class: "form-footer-actions" }, [
            h(ElButton, {
              onClick: () => {
                rejectDialog.visible = false;
                rejectDialog.row = null;
                rejectDialog.reason = "";
                rejectDialog.comment = "";
              },
            }, () => "取消"),
            h(ElButton, { type: "danger", onClick: confirmReject }, () => "确认驳回"),
          ]),
        }),
      ]);
  },
});

const AnnouncementPanel = defineComponent({
  setup() {
    const filters = reactive({
      keyword: "",
      type: "",
      status: "",
    });
    const currentPage = ref(1);
    const pageSize = ref(5);
    const formVisible = ref(false);
    const detailVisible = ref(false);
    const selectedAnnouncement = ref(null);
    const announcementForm = reactive({
      title: "",
      type: "招标公告",
      deadline: "",
      status: "上架",
      content: "",
      attachments: [],
    });
    const typeOptions = ["招标公告", "供应商入库公告", "专家入库公告"];
    const statusOptions = ["上架", "下架", "已过期"];
    const filteredRows = computed(() => {
      const keyword = filters.keyword.trim();
      return announcementRows.filter((row) => {
        const displayStatus = isAnnouncementExpired(row) ? "已过期" : row.status;
        const matchKeyword = !keyword || [row.id, row.title, row.publisher].join(" ").includes(keyword);
        const matchType = !filters.type || row.type === filters.type;
        const matchStatus = !filters.status || displayStatus === filters.status;
        return matchKeyword && matchType && matchStatus;
      });
    });
    const pagedRows = computed(() => {
      const start = (currentPage.value - 1) * pageSize.value;
      return filteredRows.value.slice(start, start + pageSize.value);
    });
    const resetFilters = () => {
      Object.assign(filters, { keyword: "", type: "", status: "" });
      currentPage.value = 1;
    };
    const resetForm = () => {
      selectedAnnouncement.value = null;
      Object.assign(announcementForm, {
        title: "",
        type: "招标公告",
        deadline: "",
        status: "上架",
        content: "",
        attachments: [],
      });
    };
    const openCreate = () => {
      resetForm();
      formVisible.value = true;
    };
    const openEdit = (row) => {
      selectedAnnouncement.value = row;
      Object.assign(announcementForm, {
        title: row.title,
        type: row.type,
        deadline: row.deadline,
        status: row.status,
        content: row.content || "",
        attachments: [...(row.attachments || [])],
      });
      formVisible.value = true;
    };
    const openDetail = (row) => {
      selectedAnnouncement.value = row;
      detailVisible.value = true;
    };
    const submitAnnouncement = () => {
      if (!announcementForm.title.trim()) {
        ElMessage.warning("请输入公告标题。");
        return;
      }
      const payload = {
        title: announcementForm.title.trim(),
        type: announcementForm.type,
        deadline: announcementForm.deadline.trim() || "长期有效",
        status: announcementForm.status,
        content: announcementForm.content,
        attachments: [...announcementForm.attachments],
      };
      if (selectedAnnouncement.value) {
        Object.assign(selectedAnnouncement.value, payload);
        ElMessage.success("公告已更新");
      } else {
        announcementRows.unshift({
          id: `GG-202605-${String(announcementRows.length + 1).padStart(3, "0")}`,
          ...payload,
          publishTime: "2026-05-28 10:00",
          publisher: "平台管理员",
          submitCount: 0,
        });
        ElMessage.success("公告已发布");
      }
      formVisible.value = false;
      resetForm();
    };
    const toggleStatus = (row) => {
      row.status = row.status === "上架" ? "下架" : "上架";
      ElMessage.success(row.status === "上架" ? "公告已上架" : "公告已下架");
    };
    const handleAnnouncementUpload = (event) => {
      const files = Array.from(event.target.files || []);
      if (!files.length) return;
      announcementForm.attachments.push(...files.map((file) => ({
        name: file.name,
        size: file.size,
        sizeText: formatFileSize(file.size),
        type: file.type,
        url: URL.createObjectURL(file),
        uploadTime: "2026-05-28 10:10",
      })));
      event.target.value = "";
      ElMessage.success(`已添加 ${files.length} 个附件`);
    };
    const openAnnouncementPicker = () => {
      document.getElementById("announcement-attachment-file")?.click();
    };
    const removeAnnouncementAttachment = (file) => {
      if (file.url) URL.revokeObjectURL(file.url);
      announcementForm.attachments = announcementForm.attachments.filter((item) => item !== file);
      ElMessage.success("已删除附件");
    };
    const previewAnnouncementAttachment = (file) => {
      if (file.url) {
        previewMaterialFile(file);
        return;
      }
      ElMessage.warning("示例附件暂无真实文件地址，请下载查看模拟文件。");
    };
    const downloadAnnouncementAttachment = (file) => {
      if (file.url) {
        downloadMaterialFile(file);
        return;
      }
      const content = [
        file.name,
        `上传时间：${file.uploadTime || "-"}`,
        `文件大小：${file.sizeText || "-"}`,
        "当前为前端原型模拟下载文件，真实开发时替换为后端附件下载接口。",
      ].join("\n");
      const blob = new Blob([content], { type: "text/plain;charset=utf-8" });
      const url = URL.createObjectURL(blob);
      downloadFile(url, file.name);
      setTimeout(() => URL.revokeObjectURL(url), 0);
    };
    const renderAnnouncementAttachments = (files, editable = false) =>
      h("div", { class: "announcement-attachments" }, [
        editable
          ? h("div", { class: "announcement-upload-head" }, [
            h("input", {
              id: "announcement-attachment-file",
              class: "material-file-input",
              type: "file",
              multiple: true,
              accept: ".pdf,.doc,.docx,.xls,.xlsx,.jpg,.jpeg,.png,.zip,.rar",
              onChange: handleAnnouncementUpload,
            }),
            h("div", [
              h("strong", "公告附件"),
              h("p", "可上传多个附件，支持 PDF、Word、Excel、图片、压缩包"),
            ]),
            h(ElButton, { type: "primary", plain: true, onClick: openAnnouncementPicker }, () => "添加附件"),
          ])
          : null,
        files.length
          ? h(ElTable, { data: files, border: true, class: "announcement-attachment-table" }, () => [
            h(ElTableColumn, { type: "index", label: "序号", width: 70 }),
            h(ElTableColumn, { prop: "name", label: "附件名称", minWidth: 260 }),
            h(ElTableColumn, { label: "大小", width: 100 }, { default: ({ row }) => row.sizeText || formatFileSize(row.size) || "-" }),
            h(ElTableColumn, { prop: "uploadTime", label: "上传时间", width: 160 }),
            h(ElTableColumn, { label: "操作", width: editable ? 180 : 130, fixed: "right" }, {
              default: ({ row }) => h("div", { class: "table-actions" }, [
                h(ElButton, { text: true, type: "primary", onClick: () => previewAnnouncementAttachment(row) }, () => "预览"),
                h(ElButton, { text: true, type: "primary", onClick: () => downloadAnnouncementAttachment(row) }, () => "下载"),
                editable ? h(ElButton, { text: true, type: "danger", onClick: () => removeAnnouncementAttachment(row) }, () => "删除") : null,
              ].filter(Boolean)),
            }),
          ])
          : h("div", { class: "announcement-empty-attachment" }, editable ? "暂未添加附件" : "暂无公告附件"),
      ].filter(Boolean));
    return () =>
      h("div", { class: "panel-stack" }, [
        h(ElCard, { shadow: "never", class: "content-card" }, {
          header: () => h("div", { class: "card-header" }, [
            h("div", [h("strong", "公告列表"), h("p", { class: "card-subtitle" }, "管理招标公告、供应商入库公告和专家入库公告。")]),
            h(ElButton, { type: "primary", onClick: openCreate }, () => "发布公告"),
          ]),
          default: () => h("div", [
            h("div", { class: "admin-filter-bar" }, [
              h(ElInput, {
                modelValue: filters.keyword,
                "onUpdate:modelValue": (value) => {
                  filters.keyword = value;
                  currentPage.value = 1;
                },
                placeholder: "搜索公告标题/编号",
                clearable: true,
                class: "admin-filter-keyword",
              }),
              h(ElSelect, {
                modelValue: filters.type,
                "onUpdate:modelValue": (value) => {
                  filters.type = value;
                  currentPage.value = 1;
                },
                placeholder: "公告类型",
                clearable: true,
                class: "admin-filter-select",
              }, () => typeOptions.map((item) => h(ElOption, { key: item, label: item, value: item }))),
              h(ElSelect, {
                modelValue: filters.status,
                "onUpdate:modelValue": (value) => {
                  filters.status = value;
                  currentPage.value = 1;
                },
                placeholder: "公告状态",
                clearable: true,
                class: "admin-filter-select",
              }, () => statusOptions.map((item) => h(ElOption, { key: item, label: item, value: item }))),
              h(ElButton, { onClick: resetFilters }, () => "重置"),
            ]),
            h(ElTable, { data: pagedRows.value, border: true }, () => [
              h(ElTableColumn, { prop: "id", label: "公告编号", width: 150 }),
              h(ElTableColumn, { prop: "title", label: "公告标题", minWidth: 300, showOverflowTooltip: true }),
              h(ElTableColumn, { prop: "type", label: "类型", width: 140 }),
              h(ElTableColumn, { prop: "publishTime", label: "发布时间", width: 165 }),
              h(ElTableColumn, { prop: "deadline", label: "截止时间", width: 130 }),
              h(ElTableColumn, { prop: "submitCount", label: "提交数", width: 90 }),
              h(ElTableColumn, { label: "状态", width: 110 }, {
                default: ({ row }) => {
                  const expired = isAnnouncementExpired(row);
                  return h(ElTag, { type: expired ? "info" : row.status === "上架" ? "success" : "warning" }, () => expired ? "已过期" : row.status);
                },
              }),
              h(ElTableColumn, { label: "操作", width: 260, fixed: "right" }, {
                default: ({ row }) => h("div", { class: "table-actions" }, [
                  h(ElButton, { size: "small", plain: true, onClick: () => openDetail(row) }, () => "详情"),
                  h(ElButton, { size: "small", plain: true, onClick: () => openEdit(row) }, () => "编辑"),
                  h(ElButton, { size: "small", type: row.status === "上架" ? "warning" : "success", plain: true, onClick: () => toggleStatus(row) }, () => row.status === "上架" ? "下架" : "上架"),
                ]),
              }),
            ]),
            h("div", { class: "table-pagination" }, [
              h(ElPagination, {
                currentPage: currentPage.value,
                pageSize: pageSize.value,
                total: filteredRows.value.length,
                layout: "total, prev, pager, next",
                background: true,
                "onUpdate:currentPage": (value) => (currentPage.value = value),
              }),
            ]),
          ]),
        }),
        h(ElDialog, {
          modelValue: formVisible.value,
          "onUpdate:modelValue": (value) => {
            formVisible.value = value;
            if (!value) resetForm();
          },
          title: selectedAnnouncement.value ? "编辑公告" : "发布公告",
          width: "760px",
        }, {
          default: () => h("div", { class: "announcement-form-body" }, [
            h(ElForm, { model: announcementForm, labelPosition: "top", class: "clean-form" }, () =>
              h(ElRow, { gutter: 20 }, () => [
                h(ElCol, { span: 24 }, () =>
                  h(ElFormItem, { label: "公告标题", required: true }, () =>
                    h(ElInput, { modelValue: announcementForm.title, "onUpdate:modelValue": (value) => (announcementForm.title = value), placeholder: "请输入公告标题" })
                  )
                ),
                h(ElCol, { lg: 12, md: 12, sm: 24, xs: 24 }, () =>
                  h(ElFormItem, { label: "公告类型", required: true }, () =>
                    h(ElSelect, { modelValue: announcementForm.type, "onUpdate:modelValue": (value) => (announcementForm.type = value), class: "full" }, () =>
                      typeOptions.map((item) => h(ElOption, { key: item, label: item, value: item }))
                    )
                  )
                ),
                h(ElCol, { lg: 12, md: 12, sm: 24, xs: 24 }, () =>
                  h(ElFormItem, { label: "截止时间" }, () =>
                    h(ElInput, { modelValue: announcementForm.deadline, "onUpdate:modelValue": (value) => (announcementForm.deadline = value), placeholder: "如 2026-06-08，长期有效可留空" })
                  )
                ),
                h(ElCol, { lg: 12, md: 12, sm: 24, xs: 24 }, () =>
                  h(ElFormItem, { label: "发布状态", required: true }, () =>
                    h(ElSelect, { modelValue: announcementForm.status, "onUpdate:modelValue": (value) => (announcementForm.status = value), class: "full" }, () =>
                      ["上架", "下架"].map((item) => h(ElOption, { key: item, label: item, value: item }))
                    )
                  )
                ),
                h(ElCol, { span: 24 }, () =>
                  h(ElFormItem, { label: "公告内容" }, () =>
                    h(ElInput, { modelValue: announcementForm.content, "onUpdate:modelValue": (value) => (announcementForm.content = value), type: "textarea", rows: 5, placeholder: "请输入公告正文摘要或说明" })
                  )
                ),
              ])
            ),
            renderAnnouncementAttachments(announcementForm.attachments, true),
          ]),
          footer: () => h("div", { class: "form-footer-actions" }, [
            h(ElButton, {
              onClick: () => {
                formVisible.value = false;
                resetForm();
              },
            }, () => "取消"),
            h(ElButton, { type: "primary", onClick: submitAnnouncement }, () => selectedAnnouncement.value ? "保存" : "发布"),
          ]),
        }),
        h(ElDialog, {
          modelValue: detailVisible.value,
          "onUpdate:modelValue": (value) => (detailVisible.value = value),
          title: "公告详情",
          width: "760px",
        }, {
          default: () => selectedAnnouncement.value
            ? h("div", { class: "announcement-detail-body" }, [
              h(ElDescriptions, { column: 2, border: true, class: "audit-detail" }, () => [
                h(ElDescriptionsItem, { label: "公告编号" }, () => selectedAnnouncement.value.id),
                h(ElDescriptionsItem, { label: "公告类型" }, () => selectedAnnouncement.value.type),
                h(ElDescriptionsItem, { label: "公告标题", span: 2 }, () => selectedAnnouncement.value.title),
                h(ElDescriptionsItem, { label: "发布状态" }, () => isAnnouncementExpired(selectedAnnouncement.value) ? "已过期" : selectedAnnouncement.value.status),
                h(ElDescriptionsItem, { label: "截止时间" }, () => selectedAnnouncement.value.deadline),
                h(ElDescriptionsItem, { label: "发布时间" }, () => selectedAnnouncement.value.publishTime),
                h(ElDescriptionsItem, { label: "提交数量" }, () => `${selectedAnnouncement.value.submitCount || 0}`),
                h(ElDescriptionsItem, { label: "公告内容", span: 2 }, () => selectedAnnouncement.value.content || "暂无正文内容。"),
              ]),
              h("section", { class: "snapshot-section" }, [
                h("div", { class: "snapshot-title" }, "公告附件"),
                renderAnnouncementAttachments(selectedAnnouncement.value.attachments || [], false),
              ]),
            ])
            : null,
          footer: () => h(ElButton, { type: "primary", onClick: () => (detailVisible.value = false) }, () => "关闭"),
        }),
      ]);
  },
});

function formCol(label, modelKey, placeholder) {
  return h(ElCol, { lg: 12, md: 12, sm: 24, xs: 24 }, () =>
    h(ElFormItem, { label, required: ["name", "code", "phone", "contactName", "provinceCity", "address"].includes(modelKey) }, () =>
      h(ElInput, {
        modelValue: form[modelKey],
        "onUpdate:modelValue": (value) => (form[modelKey] = value),
        placeholder,
        disabled: !canMaintainApplication.value,
      })
    )
  );
}

function selectCol(label, modelKey, options) {
  return h(ElCol, { lg: 12, md: 12, sm: 24, xs: 24 }, () =>
    h(ElFormItem, { label, required: true }, () =>
      h(ElSelect, {
        modelValue: form[modelKey],
        "onUpdate:modelValue": (value) => (form[modelKey] = value),
        placeholder: "请选择",
        class: "full",
        disabled: !canMaintainApplication.value,
      }, () => options.map((item) => h(ElOption, { key: item, label: item, value: item })))
    )
  );
}

function simpleCard(title, value, desc) {
  return h(ElCard, { shadow: "never", class: "content-card simple-card" }, () => [h("span", title), h("b", value), h("p", desc)]);
}

function metaItem(label, value) {
  return h("div", { class: "meta-item" }, [h("span", label), h("strong", value || "-")]);
}

const OperationLogPanel = defineComponent({
  setup() {
    const logs = computed(() => [
      { action: "创建申请", time: "2026-05-26 09:10", user: role.value === "expert" ? "专家申报人" : "供应商申报人", remark: "进入入库申请页面" },
      currentApplicationRecord.value.status !== "待提交"
        ? { action: "提交审核", time: currentApplicationRecord.value.submitTime, user: currentApplicationRecord.value.applicant, remark: "提交入库申请资料" }
        : null,
    ].filter(Boolean));

    return () =>
      h(ElCard, { shadow: "never", class: "content-card" }, {
        header: () => h("div", { class: "card-header" }, [h("strong", "操作记录")]),
        default: () =>
          h(ElTable, { data: logs.value, border: true }, () => [
            h(ElTableColumn, { prop: "action", label: "操作", minWidth: 140 }),
            h(ElTableColumn, { prop: "user", label: "操作人", width: 160 }),
            h(ElTableColumn, { prop: "time", label: "操作时间", width: 180 }),
            h(ElTableColumn, { prop: "remark", label: "说明", minWidth: 220 }),
          ]),
      });
  },
});

function materialCard(materials) {
  return h(ElCard, { shadow: "never", class: "content-card" }, {
    header: () => h("div", { class: "card-header" }, [h("strong", "附件材料")]),
    default: () =>
      h("div", { class: "material-grid" }, materials.map((item) => {
        const materialKey = getMaterialKey(item);
        const files = uploadedFiles[materialKey] || [];

        return h("div", { class: "material-card", key: item.name }, [
          h("input", {
            id: `file-${materialKey}`,
            class: "material-file-input",
            type: "file",
            multiple: true,
            disabled: !canMaintainApplication.value,
            onChange: (event) => handleMaterialUpload(item, event),
          }),
          h("div", { class: "material-top" }, [h(ElIcon, { class: "material-icon" }, () => h(Document)), h(ElTag, { type: item.required ? "danger" : "info", size: "small" }, () => (item.required ? "必传" : "选传"))]),
          h("h3", item.name),
          h("p", item.desc),
          h("div", { class: "material-actions" }, [
            item.template ? h("a", { href: item.templateUrl, download: item.downloadName, class: "template-link" }, "下载模板") : null,
            h(ElButton, { type: "primary", plain: true, disabled: !canMaintainApplication.value, onClick: () => openMaterialPicker(item) }, () => "上传"),
          ].filter(Boolean)),
          files.length
            ? h("div", { class: "uploaded-files" }, files.map((file) =>
              h("div", { class: "uploaded-file", key: file.url || file.name }, [
                h("span", { class: "file-name" }, `${file.name} ${formatFileSize(file.size)}`),
                h("div", { class: "file-actions" }, [
                  h(ElButton, { text: true, type: "primary", onClick: () => previewMaterialFile(file) }, () => "预览"),
                  h(ElButton, { text: true, type: "primary", onClick: () => downloadMaterialFile(file) }, () => "下载"),
                  h(ElButton, { text: true, type: "danger", disabled: !canMaintainApplication.value, onClick: () => removeMaterialFile(item, file) }, () => "删除"),
                ]),
              ])
            ))
            : h("div", { class: "upload-empty" }, "未选择文件"),
        ]);
      })),
  });
}
</script>

<style lang="scss" scoped>
.role-dashboard {
  --el-color-primary: #9b1c1f;
  --el-color-primary-light-3: #b84649;
  --el-color-primary-light-5: #cf797b;
  --el-color-primary-light-7: #e3acad;
  --el-color-primary-light-8: #efd0d0;
  --el-color-primary-light-9: #fbefeb;
  --el-color-primary-dark-2: #751416;
  --el-border-radius-base: 8px;
  min-height: 100vh;
  background: #f5f2ef;
}

.topbar {
  position: sticky;
  top: 0;
  z-index: 10;
  display: flex;
  align-items: center;
  justify-content: space-between;
  height: 72px;
  padding: 0 28px;
  color: #fff;
  background: linear-gradient(90deg, #5a1114, #9b1c1f);
  box-shadow: 0 6px 22px rgba(60, 18, 18, 0.2);
}

.brand {
  display: flex;
  align-items: center;
  gap: 16px;

  img {
    width: 220px;
    filter: brightness(0) invert(1);
  }

  span {
    width: 1px;
    height: 32px;
    background: rgba(255, 255, 255, 0.36);
  }

  b {
    font-size: 20px;
    letter-spacing: 1px;
  }
}

.top-actions {
  display: flex;
  align-items: center;
  gap: 12px;
}

.notice-bell {
  position: relative;
  display: grid;
  width: 38px;
  height: 38px;
  place-items: center;
  color: #fff;
  background: rgba(255, 255, 255, 0.12);
  border: 1px solid rgba(255, 255, 255, 0.28);
  border-radius: 8px;
  cursor: pointer;
  font-size: 18px;
}

.notice-bell:hover {
  background: rgba(255, 255, 255, 0.2);
}

.notice-badge {
  position: absolute;
  top: -6px;
  right: -6px;
  min-width: 18px;
  height: 18px;
  padding: 0 5px;
  color: #fff;
  background: #e03131;
  border: 2px solid #8a1719;
  border-radius: 999px;
  font-size: 12px;
  font-weight: 800;
  line-height: 14px;
  text-align: center;
}

.role-tag {
  --el-tag-bg-color: rgba(200, 161, 90, 0.25);
  --el-tag-border-color: rgba(200, 161, 90, 0.65);
}

.layout {
  display: grid;
  grid-template-columns: 248px minmax(0, 1fr);
  min-height: calc(100vh - 72px);
}

.sidebar {
  position: sticky;
  top: 72px;
  align-self: start;
  height: calc(100vh - 72px);
  background: #fff;
  border-right: 1px solid #eee4dd;
  box-shadow: 6px 0 20px rgba(44, 29, 24, 0.05);
}

.user-card {
  display: flex;
  gap: 12px;
  align-items: center;
  padding: 22px 18px;
  border-bottom: 1px solid #eee4dd;

  strong,
  span {
    display: block;
  }

  span {
    margin-top: 4px;
    color: #8a7f79;
    font-size: 12px;
  }
}

.avatar {
  display: grid;
  width: 48px;
  height: 48px;
  place-items: center;
  color: #fff;
  background: #9b1c1f;
  border-radius: 8px;
  font-weight: 800;
}

.side-menu {
  padding: 10px;
  border-right: 0;

  :deep(.el-menu-item) {
    height: 46px;
    margin-bottom: 6px;
    border-radius: 8px;
  }

  :deep(.el-menu-item.is-active) {
    color: #9b1c1f;
    background: #fbefeb;
    font-weight: 800;
  }
}

.main {
  min-width: 0;
  padding: 24px;
}

.hero-panel {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 20px;
  padding: 26px;
  margin-bottom: 18px;
  color: #fff;
  background:
    linear-gradient(90deg, rgba(90, 17, 20, 0.95), rgba(155, 28, 31, 0.78)),
    url("@/assets/guohong/banner-1.jpg") center / cover;
  border-radius: 8px;

  h1 {
    margin: 14px 0 8px;
    font-size: 28px;
  }

  p {
    max-width: 760px;
    margin: 0;
    color: rgba(255, 255, 255, 0.82);
  }
}

.stat-row {
  display: grid;
  grid-template-columns: repeat(4, minmax(0, 1fr));
  gap: 16px;
  margin-bottom: 18px;
}

.stat-card,
.content-card {
  background: #fff;
  border: 1px solid #eee4dd;
  border-radius: 8px;
  box-shadow: 0 10px 30px rgba(44, 29, 24, 0.06);
}

.stat-card {
  display: flex;
  gap: 14px;
  align-items: center;
  padding: 18px;

  .el-icon {
    display: grid;
    width: 44px;
    height: 44px;
    place-items: center;
    color: #9b1c1f;
    background: #fbefeb;
    border-radius: 8px;
    font-size: 24px;
  }

  b,
  span {
    display: block;
  }

  b {
    color: #9b1c1f;
    font-size: 28px;
    line-height: 1;
  }

  span {
    margin-top: 6px;
    color: #7d716b;
  }
}

.content-card {
  margin-bottom: 18px;

  :deep(.el-card__header) {
    border-bottom-color: #eee4dd;
  }
}

.table-pagination {
  display: flex;
  justify-content: flex-end;
  padding-top: 16px;
}

.table-actions {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;

  .el-button {
    margin-left: 0;
  }
}

.file-action-group {
  display: inline-flex;
  gap: 6px;
  align-items: center;

  .el-button {
    margin-left: 0;
  }
}

.certificate-action-cell {
  display: grid;
  gap: 6px;
  align-items: start;

  span {
    color: #3e3531;
    line-height: 1.5;
    word-break: break-all;
  }
}

.card-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 16px;

  strong {
    color: #322624;
    font-size: 17px;
  }
}

.card-subtitle {
  margin: 6px 0 0;
  color: #7d716b;
  font-size: 13px;
  font-weight: 400;
}

.admin-workbench {
  display: grid;
  gap: 18px;
}

.admin-overview-grid {
  display: grid;
  grid-template-columns: repeat(4, minmax(180px, 1fr));
  gap: 16px;
  overflow-x: auto;
}

.admin-stat-card {
  display: grid;
  grid-template-columns: 38px minmax(0, 1fr);
  gap: 8px 12px;
  align-items: center;
  min-height: 88px;
  padding: 14px;
  text-align: left;
  cursor: pointer;
  background: #fff;
  border: 1px solid #eee4dd;
  border-radius: 8px;
  box-shadow: 0 10px 30px rgba(44, 29, 24, 0.06);
  transition: border-color 0.16s ease, box-shadow 0.16s ease, transform 0.16s ease;

  &:hover {
    border-color: #d8aaa1;
    box-shadow: 0 14px 34px rgba(91, 38, 31, 0.1);
    transform: translateY(-1px);
  }

  .el-icon {
    flex: 0 0 auto;
    display: grid;
    width: 46px;
    height: 46px;
    place-items: center;
    color: #9b1c1f;
    background: #fbefeb;
    border-radius: 8px;
    font-size: 24px;
  }

  .admin-stat-main {
    min-width: 0;
    flex: 1;
  }

  span,
  b,
  em {
    display: block;
    font-style: normal;
  }

  span {
    color: #675b55;
    font-size: 14px;
  }

  b {
    margin-top: 8px;
    color: #9b1c1f;
    font-size: 30px;
    line-height: 1;
  }

  em {
    grid-column: 1 / -1;
    padding-top: 4px;
    color: #9b1c1f;
    font-size: 13px;
    white-space: nowrap;
  }
}

.admin-filter-bar {
  display: grid;
  grid-template-columns: minmax(260px, 1fr) 170px minmax(220px, 280px) auto;
  gap: 12px;
  align-items: center;
  padding: 14px;
  margin-bottom: 14px;
  background: #fbf7f4;
  border: 1px solid #eee4dd;
  border-radius: 8px;
}

.admin-filter-keyword {
  width: 100%;
}

.admin-filter-select {
  width: 100%;

  &.is-wide {
    width: 100%;
  }
}

.bid-list-filter-bar {
  display: grid;
  grid-template-columns: minmax(280px, 480px) 180px minmax(220px, 360px) 110px;
  gap: 16px;
  align-items: center;
  padding: 24px 28px;
  margin-bottom: 18px;
  background: #fbf7f4;
  border: 1px solid #efe1d8;
  border-radius: 8px;
}

.bid-filter-keyword,
.bid-filter-select {
  width: 100%;
}

.bid-filter-reset {
  width: 100%;
  height: 40px;
  font-weight: 700;
}

.bid-list-filter-bar {
  :deep(.el-input__wrapper) {
    min-height: 40px;
    background: #fff;
    border-radius: 8px;
    box-shadow: 0 0 0 1px #d7dfe8 inset;
  }

  :deep(.el-input__inner) {
    color: #3e3531;
    font-size: 15px;
  }

  :deep(.el-input__inner::placeholder) {
    color: #a7adb7;
  }
}

.clean-form {
  :deep(.el-form-item__label) {
    color: #433533;
    font-weight: 700;
  }
}

.announcement-form-body,
.announcement-detail-body {
  display: grid;
  gap: 18px;
}

.announcement-attachments {
  display: grid;
  gap: 12px;
}

.announcement-upload-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 16px;
  padding: 14px 16px;
  background: #fbf7f4;
  border: 1px solid #eee4dd;
  border-radius: 8px;

  strong,
  p {
    display: block;
    margin: 0;
  }

  strong {
    color: #2f2624;
    font-size: 16px;
  }

  p {
    margin-top: 4px;
    color: #7d716b;
    font-size: 13px;
  }
}

.announcement-empty-attachment {
  padding: 18px;
  color: #8a7a74;
  text-align: center;
  background: #fbf7f4;
  border: 1px dashed #e3d4cc;
  border-radius: 8px;
}

.announcement-attachment-table {
  :deep(.el-button) {
    padding: 0 4px;
  }
}

.full {
  width: 100%;
}

.panel-stack {
  display: grid;
  gap: 18px;
}

.form-footer-actions {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
  padding: 4px 0 0;
}

.bid-submit-dialog {
  :deep(.el-dialog__header) {
    padding: 24px 30px 20px;
    margin: 0;
    border-bottom: 1px solid #e7edf6;
  }

  :deep(.el-dialog__body) {
    padding: 20px 30px;
  }

  :deep(.el-dialog__footer) {
    padding: 16px 30px 20px;
    border-top: 1px solid #e7edf6;
  }
}

.bid-dialog-header,
.bid-dialog-title {
  display: flex;
  align-items: center;
}

.bid-dialog-header {
  justify-content: space-between;
  gap: 16px;
}

.bid-dialog-title {
  gap: 14px;

  strong {
    display: block;
    color: #1f1715;
    font-size: 22px;
    line-height: 1.2;
  }

  p {
    margin: 8px 0 0;
    color: #7d716b;
    font-size: 14px;
  }
}

.bid-title-icon {
  display: grid;
  width: 48px;
  height: 48px;
  place-items: center;
  color: #fff;
  background: linear-gradient(135deg, #2d80ff, #1769f4);
  border-radius: 8px;
  font-size: 26px;
}

.dialog-close-btn {
  color: #7d716b;
  font-size: 28px;
  line-height: 1;
}

.bid-dialog-body {
  display: grid;
  gap: 20px;
  max-height: 68vh;
  overflow: auto;
  padding-right: 4px;
}

.bid-content-grid {
  display: grid;
  grid-template-columns: minmax(0, 1fr) 310px;
  gap: 24px;
}

.bid-dialog-main,
.bid-dialog-aside {
  display: grid;
  align-content: start;
  gap: 16px;
}

.tender-template-box {
  display: grid;
  grid-template-columns: minmax(0, 1fr) 520px;
  gap: 22px;
  padding: 18px;
  border: 1px solid #bcd6ff;
  border-radius: 8px;
  background: #f8fbff;
}

.tender-select-field,
.template-block {
  label {
    display: block;
    margin-bottom: 10px;
    color: #2f2624;
    font-weight: 800;
  }

  label span {
    margin-right: 6px;
    color: #c21d22;
  }
}

.template-download-field {
  display: flex;
  align-items: center;
  gap: 16px;

  .el-button {
    --el-button-text-color: #1677ff;
    --el-button-border-color: #8bbcff;
    --el-button-hover-text-color: #1677ff;
    --el-button-hover-border-color: #1677ff;
    height: 40px;
    padding: 0 18px;
  }

  span {
    color: #7d716b;
    font-size: 13px;
  }
}

.selected-tender-card {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 14px 16px;

  strong {
    flex: 1;
    min-width: 0;
    color: #322624;
  }

  span {
    color: #7d716b;
    white-space: nowrap;
  }
}

.side-box,
.selected-tender-card {
  border-radius: 8px;
  background: #fff;
  border: 1px solid #e1e8f2;
}

.side-box {
  padding: 18px;

  strong {
    display: block;
    margin-bottom: 14px;
    color: #322624;
    font-size: 16px;
  }

  ul {
    display: grid;
    gap: 14px;
    margin: 0;
    padding: 0;
    color: #675b55;
    list-style: none;
  }

  li::before {
    margin-right: 8px;
    color: #64748b;
    content: "✓";
  }

  dl,
  dd {
    margin: 0;
  }

  dl {
    display: grid;
    gap: 14px;
  }

  dl div {
    display: grid;
    grid-template-columns: 100px minmax(0, 1fr);
    gap: 10px;
    color: #675b55;
  }

  dt {
    color: #8a7f79;
  }

  dd {
    color: #322624;
  }
}

.bid-material-panel {
  display: grid;
  gap: 12px;
}

.bid-upload-head {
  display: flex;
  align-items: flex-end;
  justify-content: space-between;
  gap: 16px;

  p {
    margin: 6px 0 0;
    color: #8a7f79;
  }
}

.bid-upload-actions {
  display: flex;
  gap: 12px;

  .el-button {
    height: 38px;
  }
}

.bid-material-grid {
  grid-template-columns: repeat(2, minmax(0, 1fr));

  .material-card {
    min-height: 166px;
    padding: 22px;
    background: #fff;
    border: 1px solid #dfe7f2;
    border-radius: 8px;
  }

  .material-card:first-child .material-icon {
    color: #ef4444;
  }

  .material-card:nth-child(2) .material-icon {
    color: #f59e0b;
  }

  .material-icon {
    width: 40px;
    height: 40px;
    font-size: 40px;
  }

  .material-actions .el-button {
    --el-button-text-color: #1677ff;
    --el-button-border-color: #8bbcff;
    --el-button-hover-text-color: #1677ff;
    --el-button-hover-border-color: #1677ff;
    height: 34px;
  }
}

.bid-section-title {
  color: #322624;
  font-size: 16px;
  font-weight: 800;
}

:global(.bid-submit-dialog) {
  max-width: calc(100vw - 72px);
  margin-top: 4vh;
}

:global(.bid-submit-dialog .el-dialog__header) {
  padding: 24px 30px 20px;
  margin: 0;
  border-bottom: 1px solid #e7edf6;
}

:global(.bid-submit-dialog .el-dialog__body) {
  padding: 20px 30px;
}

:global(.bid-submit-dialog .el-dialog__footer) {
  padding: 16px 30px 20px;
  border-top: 1px solid #e7edf6;
}

:global(.bid-submit-dialog .bid-dialog-header),
:global(.bid-submit-dialog .bid-dialog-title) {
  display: flex;
  align-items: center;
}

:global(.bid-submit-dialog .bid-dialog-header) {
  justify-content: space-between;
  gap: 16px;
}

:global(.bid-submit-dialog .bid-dialog-title) {
  gap: 14px;
}

:global(.bid-submit-dialog .bid-dialog-title strong) {
  display: block;
  color: #111827;
  font-size: 22px;
  line-height: 1.2;
}

:global(.bid-submit-dialog .bid-dialog-title p) {
  margin: 8px 0 0;
  color: #6b7280;
  font-size: 14px;
}

:global(.bid-submit-dialog .bid-title-icon) {
  display: grid;
  width: 48px;
  height: 48px;
  place-items: center;
  color: #fff;
  background: linear-gradient(135deg, #2d80ff, #1769f4);
  border-radius: 8px;
  font-size: 26px;
}

:global(.bid-submit-dialog .dialog-close-btn) {
  width: 36px;
  height: 36px;
  color: #6b7280;
  font-size: 28px;
  line-height: 1;
}

:global(.bid-submit-dialog .bid-dialog-body) {
  display: grid;
  gap: 20px;
  max-height: 68vh;
  overflow: auto;
  padding-right: 4px;
}

:global(.bid-submit-dialog .tender-template-box) {
  display: grid;
  grid-template-columns: minmax(260px, 1fr) minmax(220px, 34%);
  gap: 22px;
  padding: 18px;
  border: 1px solid #bcd6ff;
  border-radius: 8px;
  background: #f8fbff;
}

:global(.bid-submit-dialog .tender-select-field label),
:global(.bid-submit-dialog .template-block label) {
  display: block;
  margin-bottom: 10px;
  color: #111827;
  font-weight: 800;
}

:global(.bid-submit-dialog .tender-select-field label span) {
  margin-right: 6px;
  color: #ef4444;
}

:global(.bid-submit-dialog .template-download-field) {
  display: flex;
  align-items: center;
  gap: 16px;
}

:global(.bid-submit-dialog .template-download-field .el-button) {
  --el-button-text-color: #1677ff;
  --el-button-border-color: #8bbcff;
  --el-button-hover-text-color: #1677ff;
  --el-button-hover-border-color: #1677ff;
  height: 40px;
  padding: 0 18px;
}

:global(.bid-submit-dialog .template-download-field span) {
  color: #6b7280;
  font-size: 13px;
}

:global(.bid-submit-dialog .bid-content-grid) {
  display: grid;
  grid-template-columns: minmax(280px, 1fr) minmax(220px, 30%);
  gap: 24px;
}

:global(.bid-submit-dialog .bid-dialog-main),
:global(.bid-submit-dialog .bid-dialog-aside) {
  display: grid;
  align-content: start;
  gap: 16px;
}

:global(.bid-submit-dialog .selected-tender-card) {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 14px 16px;
  border: 1px solid #e1e8f2;
  border-radius: 8px;
  background: #fbfdff;
}

:global(.bid-submit-dialog .selected-tender-card span) {
  color: #6b7280;
  white-space: nowrap;
}

:global(.bid-submit-dialog .side-box) {
  padding: 18px;
  border: 1px solid #e1e8f2;
  border-radius: 8px;
  background: #fff;
}

:global(.bid-submit-dialog .side-box strong) {
  display: block;
  margin-bottom: 14px;
  color: #111827;
  font-size: 16px;
}

:global(.bid-submit-dialog .side-box ul) {
  display: grid;
  gap: 14px;
  margin: 0;
  padding: 0;
  color: #6b7280;
  list-style: none;
}

:global(.bid-submit-dialog .side-box li::before) {
  margin-right: 8px;
  color: #64748b;
  content: "✓";
}

:global(.bid-submit-dialog .side-box dl),
:global(.bid-submit-dialog .side-box dd) {
  margin: 0;
}

:global(.bid-submit-dialog .side-box dl) {
  display: grid;
  gap: 14px;
}

:global(.bid-submit-dialog .side-box dl div) {
  display: grid;
  grid-template-columns: 100px minmax(0, 1fr);
  gap: 10px;
  color: #6b7280;
}

:global(.bid-submit-dialog .side-box dt) {
  color: #8a94a6;
}

:global(.bid-submit-dialog .side-box dd) {
  color: #111827;
}

:global(.bid-submit-dialog .bid-upload-head) {
  display: flex;
  align-items: flex-end;
  justify-content: space-between;
  gap: 16px;
}

:global(.bid-submit-dialog .bid-upload-head p) {
  margin: 6px 0 0;
  color: #8a94a6;
}

:global(.bid-submit-dialog .bid-upload-actions) {
  display: flex;
  gap: 12px;
}

:global(.bid-submit-dialog .bid-material-grid) {
  display: grid;
  grid-template-columns: repeat(2, minmax(220px, 1fr));
  gap: 16px;
}

:global(.bid-submit-dialog .bid-material-grid .material-card) {
  min-height: 166px;
  padding: 22px;
  background: #fff;
  border: 1px solid #dfe7f2;
  border-radius: 8px;
}

:global(.bid-submit-dialog .bid-material-grid .material-card:first-child .material-icon) {
  color: #ef4444;
}

:global(.bid-submit-dialog .bid-material-grid .material-card:nth-child(2) .material-icon) {
  color: #f59e0b;
}

:global(.bid-submit-dialog .bid-material-grid .material-icon) {
  width: 40px;
  height: 40px;
  font-size: 40px;
}

:global(.bid-submit-dialog .bid-material-grid .material-actions .el-button) {
  --el-button-text-color: #1677ff;
  --el-button-border-color: #8bbcff;
  --el-button-hover-text-color: #1677ff;
  --el-button-hover-border-color: #1677ff;
  height: 34px;
}

:global(.bid-submit-dialog .form-footer-actions) {
  display: flex;
  justify-content: flex-end;
  gap: 18px;
}

:global(.bid-submit-dialog .form-footer-actions .el-button) {
  min-width: 108px;
  height: 40px;
}

:global(.bid-submit-dialog .form-footer-actions .el-button--primary) {
  --el-button-bg-color: #1677ff;
  --el-button-border-color: #1677ff;
  --el-button-hover-bg-color: #0f66e8;
  --el-button-hover-border-color: #0f66e8;
}

:global(.appointment-cert-dialog) {
  border-radius: 10px;
  overflow: hidden;
}

:global(.appointment-cert-dialog .el-dialog__header) {
  padding: 24px 28px 18px;
  margin: 0;
  border-bottom: 1px solid #eee4dd;
}

:global(.appointment-cert-dialog .el-dialog__title) {
  color: #2f2624;
  font-size: 22px;
  font-weight: 700;
}

:global(.appointment-cert-dialog .el-dialog__body) {
  padding: 24px 28px;
}

:global(.appointment-cert-dialog .el-dialog__footer) {
  padding: 16px 28px 24px;
  background: #fbf7f4;
  border-top: 1px solid #eee4dd;
}

:global(.appointment-cert-dialog .certificate-upload-box) {
  display: grid;
  gap: 16px;
}

:global(.appointment-cert-dialog .certificate-tip) {
  display: flex;
  gap: 14px;
  align-items: flex-start;
  padding: 16px;
  background: #fff8f6;
  border: 1px solid #f0d4cc;
  border-radius: 8px;
}

:global(.appointment-cert-dialog .certificate-tip .el-icon) {
  flex: 0 0 auto;
  width: 34px;
  height: 34px;
  display: grid;
  place-items: center;
  color: #9b1c1f;
  background: #fbefeb;
  border-radius: 8px;
  font-size: 20px;
}

:global(.appointment-cert-dialog .certificate-tip strong) {
  display: block;
  color: #2f2624;
  font-size: 16px;
}

:global(.appointment-cert-dialog .certificate-tip p),
:global(.appointment-cert-dialog .certificate-note p) {
  margin: 6px 0 0;
  color: #675b55;
  line-height: 1.7;
}

:global(.appointment-cert-dialog .certificate-picker) {
  display: grid;
  grid-template-columns: 44px minmax(0, 1fr) 112px;
  gap: 14px;
  align-items: center;
  min-height: 92px;
  padding: 16px;
  background: #fff;
  border: 1px dashed #d8aaa1;
  border-radius: 8px;
}

:global(.appointment-cert-dialog .certificate-picker.is-selected) {
  border-style: solid;
  border-color: #9b1c1f;
  background: #fffafa;
}

:global(.appointment-cert-dialog .certificate-file-icon) {
  display: grid;
  width: 44px;
  height: 44px;
  place-items: center;
  color: #9b1c1f;
  background: #fbefeb;
  border-radius: 8px;
  font-size: 22px;
}

:global(.appointment-cert-dialog .certificate-file-main strong),
:global(.appointment-cert-dialog .certificate-file-main span) {
  display: block;
}

:global(.appointment-cert-dialog .certificate-file-main strong) {
  overflow: hidden;
  color: #2f2624;
  font-size: 16px;
  text-overflow: ellipsis;
  white-space: nowrap;
}

:global(.appointment-cert-dialog .certificate-file-main span) {
  margin-top: 6px;
  color: #8a7a74;
  font-size: 13px;
}

:global(.appointment-cert-dialog .certificate-picker .el-button) {
  width: 112px;
  margin: 0;
}

:global(.appointment-cert-dialog .certificate-note) {
  display: grid;
  grid-template-columns: 42px minmax(0, 1fr);
  gap: 10px;
  padding: 12px 14px;
  background: #fbf7f4;
  border-radius: 8px;
}

:global(.appointment-cert-dialog .certificate-note span) {
  height: 24px;
  color: #9b1c1f;
  background: #fbefeb;
  border-radius: 999px;
  font-size: 13px;
  font-weight: 700;
  line-height: 24px;
  text-align: center;
}

:global(.appointment-cert-dialog .form-footer-actions .el-button) {
  min-width: 96px;
  height: 40px;
}

:global(.appointment-cert-dialog .form-footer-actions .el-button--primary) {
  --el-button-bg-color: #9b1c1f;
  --el-button-border-color: #9b1c1f;
  --el-button-hover-bg-color: #7f1518;
  --el-button-hover-border-color: #7f1518;
}

:global(.reject-reason-dialog) {
  border-radius: 10px;
  overflow: hidden;
}

:global(.reject-reason-dialog .el-dialog__header) {
  padding: 24px 28px 18px;
  margin: 0;
  border-bottom: 1px solid #eee4dd;
}

:global(.reject-reason-dialog .el-dialog__title) {
  color: #2f2624;
  font-size: 22px;
  font-weight: 700;
}

:global(.reject-reason-dialog .el-dialog__body) {
  padding: 24px 28px 10px;
}

:global(.reject-reason-dialog .el-dialog__footer) {
  padding: 16px 28px 24px;
  background: #fbf7f4;
  border-top: 1px solid #eee4dd;
}

:global(.reject-reason-dialog .reject-reason-box) {
  display: grid;
  gap: 18px;
}

:global(.reject-reason-dialog .reject-target) {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 14px 16px;
  background: #fff8f6;
  border: 1px solid #f0d4cc;
  border-radius: 8px;
}

:global(.reject-reason-dialog .reject-target span) {
  color: #8a7a74;
}

:global(.reject-reason-dialog .reject-target strong) {
  color: #2f2624;
}

:global(.reject-reason-dialog .form-footer-actions .el-button) {
  min-width: 96px;
  height: 40px;
}

@media (max-width: 900px) {
  :global(.bid-submit-dialog .tender-template-box),
  :global(.bid-submit-dialog .bid-content-grid),
  :global(.bid-submit-dialog .bid-material-grid) {
    grid-template-columns: 1fr;
  }
}

.overview-grid {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 18px;
}

.simple-card {
  span,
  b,
  p {
    display: block;
  }

  span {
    color: #7d716b;
  }

  b {
    margin: 12px 0 8px;
    color: #9b1c1f;
    font-size: 28px;
  }

  p {
    margin: 0;
    color: #675b55;
    line-height: 1.7;
  }
}

.material-grid {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 14px;
}

.material-card {
  min-height: 178px;
  padding: 16px;
  background: #fffaf7;
  border: 1px dashed #d8b9ad;
  border-radius: 8px;

  h3 {
    margin: 14px 0 8px;
    color: #342a28;
    font-size: 16px;
  }

  p {
    min-height: 42px;
    margin: 0;
    color: #7d716b;
    line-height: 1.6;
  }
}

.material-top,
.material-actions {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 10px;
}

.material-icon {
  width: 28px;
  height: 28px;
  color: #9b1c1f;
  font-size: 28px;
}

.material-actions {
  justify-content: flex-start;
  margin-top: 14px;
}

.notice-panel {
  ul {
    margin: 0;
    padding: 0 0 0 18px;
    color: #675b55;
    line-height: 2;
  }
}

.message-center {
  display: grid;
  gap: 18px;
}

.message-summary-row {
  display: grid;
  grid-template-columns: 180px 180px minmax(0, 1fr);
  gap: 14px;
}

.message-summary-card {
  padding: 16px 18px;
  background: #fff;
  border: 1px solid #eee4dd;
  border-radius: 8px;
  box-shadow: 0 10px 30px rgba(44, 29, 24, 0.06);

  span,
  strong {
    display: block;
  }

  span {
    color: #7d716b;
  }

  strong {
    margin-top: 8px;
    color: #9b1c1f;
    font-size: 22px;
  }
}

.message-table {
  margin-top: 10px;
}

.message-title-cell {
  display: flex;
  align-items: center;
  gap: 8px;
  color: #3d332f;

  i {
    width: 8px;
    height: 8px;
    background: #c21d22;
    border-radius: 50%;
  }

  &.is-unread span {
    font-weight: 800;
  }
}

.message-detail {
  display: grid;
  gap: 16px;

  p {
    margin: 0;
    color: #4b403b;
    line-height: 1.8;
  }
}

.message-detail-head {
  display: flex;
  align-items: center;
  gap: 10px;

  strong {
    color: #2f2624;
    font-size: 18px;
  }
}

@media (max-width: 1100px) {
  .layout,
  .stat-row,
  .overview-grid,
  .material-grid {
    grid-template-columns: 1fr;
  }

  .admin-overview-grid {
    grid-template-columns: repeat(4, minmax(180px, 1fr));
  }

  .admin-filter-bar {
    grid-template-columns: 240px 140px 180px 70px;
  }

  .sidebar {
    position: static;
    height: auto;
  }

  .hero-panel {
    display: grid;
  }
}

@media (max-width: 720px) {
  .admin-overview-grid {
    grid-template-columns: repeat(4, minmax(180px, 1fr));
  }

  .admin-filter-bar {
    grid-template-columns: 240px 140px 180px 70px;
  }

  .topbar {
    height: auto;
    align-items: flex-start;
    flex-direction: column;
    padding: 16px;
  }

  .brand {
    flex-wrap: wrap;

    img {
      width: 190px;
    }
  }

  .main {
    padding: 14px;
  }
}
</style>

<style lang="scss">
.role-dashboard {
  .bid-list-filter-bar {
    display: grid;
    grid-template-columns: minmax(260px, 480px) 180px minmax(220px, 360px) 110px;
    gap: 16px;
    align-items: center;
    padding: 24px 28px;
    margin-bottom: 18px;
    background: #fbf7f4;
    border: 1px solid #efe1d8;
    border-radius: 8px;
  }

  .bid-filter-keyword,
  .bid-filter-select {
    width: 100%;
  }

  .bid-filter-reset {
    width: 100%;
    height: 40px;
    font-weight: 700;
  }

  .bid-list-filter-bar .el-input__wrapper {
    min-height: 40px;
    background: #fff;
    border-radius: 8px;
    box-shadow: 0 0 0 1px #d7dfe8 inset;
  }

  .bid-list-filter-bar .el-select__wrapper {
    min-height: 40px;
    background: #fff;
    border-radius: 8px;
    box-shadow: 0 0 0 1px #d7dfe8 inset;
  }

  .bid-list-filter-bar .el-input__inner {
    color: #3e3531;
    font-size: 15px;
  }

  .bid-list-filter-bar .el-input__inner::placeholder {
    color: #a7adb7;
  }

  .file-action-group {
    display: inline-flex;
    gap: 6px;
    align-items: center;

    .el-button {
      margin-left: 0;
    }
  }

  .certificate-action-cell {
    display: grid;
    gap: 6px;
    align-items: start;

    span {
      color: #3e3531;
      line-height: 1.5;
      word-break: break-all;
    }
  }

  .admin-workbench {
    display: grid;
    gap: 18px;
  }

  .admin-overview-grid {
    display: grid;
    grid-template-columns: repeat(4, minmax(0, 1fr));
    gap: 16px;
  }

  .admin-stat-card {
    display: grid;
    grid-template-columns: 38px minmax(0, 1fr);
    gap: 8px 12px;
    align-items: center;
    min-height: 108px;
    padding: 20px;
    text-align: left;
    cursor: pointer;
    background: #fff;
    border: 1px solid #eee4dd;
    border-radius: 8px;
    box-shadow: 0 10px 30px rgba(44, 29, 24, 0.06);
    transition: border-color 0.16s ease, box-shadow 0.16s ease, transform 0.16s ease;

    &:hover {
      border-color: #d8aaa1;
      box-shadow: 0 14px 34px rgba(91, 38, 31, 0.1);
      transform: translateY(-1px);
    }

    .el-icon {
      flex: 0 0 auto;
      display: grid;
      width: 38px;
      height: 38px;
      place-items: center;
      color: #9b1c1f;
      background: #fbefeb;
      border-radius: 8px;
      font-size: 20px;
    }

    .admin-stat-main {
      min-width: 0;
      flex: 1;
    }

    span,
    b,
    em {
      display: block;
      font-style: normal;
    }

    span {
      color: #675b55;
      font-size: 14px;
    }

    b {
      margin-top: 8px;
      color: #9b1c1f;
      font-size: 24px;
      line-height: 1;
    }

    em {
      grid-column: 1 / -1;
      padding-top: 4px;
      color: #9b1c1f;
      font-size: 13px;
      white-space: nowrap;
    }
  }

.admin-filter-bar {
  display: grid;
  grid-template-columns: 240px 140px 180px 70px;
  gap: 12px;
    align-items: center;
    padding: 14px;
    margin-bottom: 14px;
    background: #fbf7f4;
  border: 1px solid #eee4dd;
  border-radius: 8px;
  overflow-x: auto;
}

  .admin-filter-keyword,
  .admin-filter-select,
  .admin-filter-select.is-wide {
    width: 100%;
  }

  .application-detail-head {
    padding: 24px 28px;
    margin-bottom: 18px;
    background: #fff;
    border: 1px solid #eee4dd;
    border-radius: 8px;
    box-shadow: 0 10px 30px rgba(44, 29, 24, 0.05);
  }

  .application-title-row {
    display: flex;
    align-items: flex-start;
    justify-content: space-between;
    gap: 20px;

    h1 {
      margin: 8px 0 0;
      color: #2f2724;
      font-size: 26px;
      letter-spacing: 0;
    }
  }

  .detail-back {
    color: #8a7f79;
    font-size: 14px;
    font-weight: 700;
  }

  .head-actions {
    display: flex;
    align-items: center;
    gap: 10px;
    white-space: nowrap;
  }

  .mock-review-select {
    width: 150px;
  }

  .application-meta {
    display: grid;
    grid-template-columns: repeat(4, minmax(0, 1fr));
    gap: 18px;
    padding: 18px 0 20px;
    margin-top: 14px;
    border-top: 1px solid #f0e2dc;
    border-bottom: 1px solid #f0e2dc;
  }

  .meta-item {
    span,
    strong {
      display: block;
    }

    span {
      color: #8a7f79;
      font-size: 13px;
    }

    strong {
      margin-top: 6px;
      color: #3c302d;
      font-size: 15px;
      font-weight: 700;
      word-break: break-word;
    }
  }

  .audit-flow {
    display: grid;
    grid-template-columns: repeat(4, minmax(0, 1fr));
    gap: 0;
    padding-top: 22px;
  }

  .flow-item {
    position: relative;
    display: grid;
    justify-items: center;
    gap: 6px;
    min-width: 0;
    color: #9a918c;
    text-align: center;

    &::after {
      position: absolute;
      top: 15px;
      left: calc(50% + 22px);
      width: calc(100% - 44px);
      height: 2px;
      content: "";
      background: #e8ddd8;
    }

    &:last-child::after {
      display: none;
    }

    strong {
      color: #5d5450;
      font-size: 14px;
    }

    p {
      margin: 0;
      font-size: 12px;
    }
  }

  .flow-item.is-done,
  .flow-item.is-current {
    color: #9b1c1f;

    .flow-dot {
      color: #fff;
      background: #9b1c1f;
      border-color: #9b1c1f;
    }

    strong {
      color: #332824;
    }
  }

  .flow-item.is-reject {
    color: #c0392b;

    .flow-dot {
      color: #fff;
      background: #c0392b;
      border-color: #c0392b;
    }
  }

  .flow-item.is-violation {
    color: #d97706;

    .flow-dot {
      color: #fff;
      background: #d97706;
      border-color: #d97706;
    }

    strong {
      color: #3b2a1b;
    }
  }

  .flow-dot {
    z-index: 1;
    display: grid;
    width: 32px;
    height: 32px;
    place-items: center;
    background: #fff;
    border: 2px solid #dad0cb;
    border-radius: 50%;
    font-size: 14px;
    font-weight: 800;
  }

  .application-detail-grid {
    display: grid;
    grid-template-columns: minmax(0, 1fr) 320px;
    gap: 18px;
    align-items: start;
  }

  .application-tabs-card {
    min-width: 0;
    background: #fff;
    border: 1px solid #eee4dd;
    border-radius: 8px;
    box-shadow: 0 10px 30px rgba(44, 29, 24, 0.06);

    > .el-card__body {
      padding: 0;
    }
  }

  .application-tabs {
    .el-tabs__header {
      padding: 0 22px;
      margin: 0;
      background: #fff;
      border-bottom: 1px solid #eee4dd;
    }

    .el-tabs__content {
      padding: 22px;
      background: #fdfaf8;
    }
  }

  .application-body {
    display: grid;
    grid-template-columns: minmax(0, 1fr) 340px;
    gap: 18px;
    align-items: start;
  }

  .application-main {
    min-width: 0;
  }

  .application-status {
    position: sticky;
    top: 96px;
    display: grid;
    gap: 14px;
  }

  .status-card,
  .opinion-card {
    padding: 20px;
    background: #fff;
    border: 1px solid #eee4dd;
    border-radius: 8px;
    box-shadow: 0 10px 30px rgba(44, 29, 24, 0.06);
  }

  .status-head {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 12px;
    color: #7d716b;
    font-weight: 700;
  }

  .status-card {
    h3 {
      margin: 16px 0 8px;
      color: #322624;
      font-size: 20px;
    }

    p {
      margin: 0;
      color: #7d716b;
      line-height: 1.7;
    }

    dl {
      display: grid;
      gap: 10px;
      margin: 18px 0;
    }

    dl div {
      display: grid;
      grid-template-columns: 86px minmax(0, 1fr);
      gap: 10px;
    }

    dt {
      color: #9a918c;
    }

    dd {
      min-width: 0;
      margin: 0;
      color: #3d332f;
      word-break: break-word;
    }
  }

  .status-actions {
    display: grid;
    gap: 10px;

    .el-button {
      width: 100%;
      margin-left: 0;
    }
  }

  .opinion-card {
    strong {
      display: block;
      color: #322624;
      font-size: 16px;
    }

    p {
      margin: 10px 0 0;
      color: #7d716b;
      line-height: 1.7;
    }
  }

  .reason-list {
    margin: 10px 0 0;
    padding-left: 18px;
    color: #7d3c34;
    line-height: 1.8;
  }

  .violation-summary {
    display: grid;
    gap: 10px;
    margin-top: 10px;

    p {
      margin: 0;
    }

    div {
      display: flex;
      align-items: center;
      gap: 10px;
      color: #8a5a17;
      font-weight: 700;
    }
  }

  .audit-reason-card {
    padding: 16px 18px;
    margin-bottom: 16px;
    color: #5f5450;
    background: #fff;
    border: 1px solid #eee4dd;
    border-radius: 8px;

    strong {
      display: block;
      color: #322624;
      font-size: 16px;
    }

    p {
      margin: 10px 0 0;
      line-height: 1.7;
    }

    ol {
      margin: 10px 0 0;
      padding-left: 18px;
      line-height: 1.8;
    }
  }

  .audit-reason-card.is-reject {
    color: #8f2f29;
    background: #fff3f1;
    border-color: #f3c6c0;
  }

  .audit-reason-card.is-violation {
    color: #8a5a17;
    background: #fff8ed;
    border-color: #f1cf9a;
  }

  .audit-reason-card.is-approved {
    color: #17633a;
    background: #effaf3;
    border-color: #bce7c8;
  }

  .violation-fields {
    display: flex;
    align-items: center;
    gap: 10px;
    margin-top: 10px;
    font-weight: 700;
  }

  .application-steps {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 20px;
    padding: 22px 26px;
    margin-bottom: 18px;
    background: #fff;
    border: 1px solid #eee4dd;
    border-radius: 8px;
    box-shadow: 0 10px 30px rgba(44, 29, 24, 0.05);
  }

  .steps-left {
    display: grid;
    grid-template-columns: repeat(3, minmax(0, 1fr));
    gap: 26px;
    width: 100%;
  }

  .step-item {
    display: flex;
    gap: 14px;
    align-items: center;
    min-width: 0;
    color: #8c827d;

    strong {
      display: block;
      color: #5d5450;
      font-size: 16px;
    }

    p {
      margin: 6px 0 0;
      color: #9a918c;
      line-height: 1.5;
    }
  }

  .step-item.is-active {
    strong {
      color: #9b1c1f;
    }

    .step-no {
      color: #fff;
      background: #9b1c1f;
      border-color: #9b1c1f;
    }
  }

  .step-no {
    display: grid;
    flex: 0 0 48px;
    width: 48px;
    height: 48px;
    place-items: center;
    color: #9a918c;
    border: 2px solid #d9d0cb;
    border-radius: 50%;
    font-size: 22px;
    font-weight: 800;
  }

  .steps-action {
    display: flex;
    flex: 0 0 auto;
    align-items: center;
    gap: 12px;
  }

  .content-card {
    margin-bottom: 18px;
    background: #fff;
    border: 1px solid #eee4dd;
    border-radius: 8px;
    box-shadow: 0 10px 30px rgba(44, 29, 24, 0.06);

    .el-card__header {
      border-bottom-color: #eee4dd;
    }
  }

  .card-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 16px;

    strong {
      color: #322624;
      font-size: 17px;
    }
  }

  .clean-form {
    .el-form-item__label {
      color: #433533;
      font-weight: 700;
    }
  }

  .lock-tip {
    padding: 12px 14px;
    margin-bottom: 18px;
    color: #8f5b10;
    background: #fff7e8;
    border: 1px solid #f3d8a8;
    border-radius: 8px;
    font-weight: 700;
  }

  .full {
    width: 100%;
  }

  .panel-stack {
    display: grid;
    gap: 18px;
  }

  .overview-grid {
    display: grid;
    grid-template-columns: repeat(3, minmax(0, 1fr));
    gap: 18px;
  }

  .simple-card {
    span,
    b,
    p {
      display: block;
    }

    span {
      color: #7d716b;
    }

    b {
      margin: 12px 0 8px;
      color: #9b1c1f;
      font-size: 28px;
    }

    p {
      margin: 0;
      color: #675b55;
      line-height: 1.7;
    }
  }

  .material-grid {
    display: grid;
    grid-template-columns: repeat(2, minmax(280px, 1fr));
    gap: 18px;
  }

  .material-card {
    position: relative;
    min-height: 210px;
    padding: 24px 26px;
    background: #fffaf7;
    border: 1px dashed #d6a79a;
    border-radius: 8px;

    h3 {
      margin: 18px 0 8px;
      color: #342a28;
      font-size: 18px;
    }

    p {
      min-height: 48px;
      margin: 0;
      color: #7d716b;
      font-size: 15px;
      line-height: 1.6;
    }
  }

  .material-file-input {
    display: none;
  }

  .material-top,
  .material-actions {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 10px;
  }

  .material-icon {
    width: 36px;
    height: 36px;
    color: #9b1c1f;
    font-size: 36px;
  }

  .material-actions {
    justify-content: flex-start;
    margin-top: 18px;
  }

  .template-link {
    display: inline-flex;
    align-items: center;
    height: 32px;
    padding: 0 8px;
    color: #9b1c1f;
    font-size: 14px;
    font-weight: 700;
    text-decoration: none;
  }

  .uploaded-files,
  .upload-empty {
    display: grid;
    gap: 6px;
    min-height: 24px;
    margin-top: 14px;
    color: #7d716b;
    font-size: 15px;
  }

  .uploaded-files span {
    padding: 0;
  }

  .uploaded-file {
    display: grid;
    grid-template-columns: minmax(0, 1fr) auto;
    gap: 8px;
    align-items: center;
    padding: 8px 10px;
    color: #3d332f;
    background: #fff;
    border: 1px solid #ead8d0;
    border-radius: 6px;
  }

  .file-name {
    min-width: 0;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
  }

  .file-actions {
    display: flex;
    align-items: center;
    gap: 2px;

    .el-button {
      padding: 0 4px;
    }
  }

  .upload-empty {
    color: #a99b95;
  }

  .audit-detail {
    .el-descriptions__label {
      width: 116px;
      color: #5f5450;
      font-weight: 700;
    }
  }

  .material-count-cell {
    display: inline-flex;
    align-items: center;
    gap: 12px;
  }

  .audit-snapshot-dialog {
    display: grid;
    gap: 18px;
    max-height: 68vh;
    overflow: auto;
    padding-right: 4px;
  }

  .bid-detail-snapshot {
    display: grid;
    gap: 18px;
    max-height: 68vh;
    overflow: auto;
    padding-right: 4px;
  }

  .snapshot-section {
    display: grid;
    gap: 10px;
  }

  .snapshot-title {
    padding-left: 10px;
    color: #2f2624;
    border-left: 4px solid #9b1c1f;
    font-size: 16px;
    font-weight: 800;
    line-height: 1.2;
  }

  .snapshot-material-table {
    :deep(.el-table__cell) {
      padding: 10px 0;
    }
  }

  .notice-panel {
    ul {
      margin: 0;
      padding: 0 0 0 18px;
      color: #675b55;
      line-height: 2;
    }
  }

  .preview-image {
    display: block;
    max-width: 100%;
    max-height: 68vh;
    margin: 0 auto;
    object-fit: contain;
  }

  .preview-frame {
    width: 100%;
    height: 68vh;
    border: 0;
  }
}

@media (max-width: 1100px) {
  .role-dashboard {
    .application-steps,
    .steps-left,
    .application-body,
    .application-detail-grid,
    .application-meta,
    .audit-flow {
      grid-template-columns: 1fr;
    }

    .application-steps {
      display: grid;
    }

    .overview-grid,
    .material-grid {
      grid-template-columns: 1fr;
    }

  .admin-overview-grid {
    grid-template-columns: repeat(4, minmax(180px, 1fr));
  }

    .admin-filter-bar {
      grid-template-columns: 240px 140px 180px 70px;
    }

    .bid-list-filter-bar {
      grid-template-columns: minmax(220px, 1fr) 150px;
    }

    .application-status {
      position: static;
    }

    .application-title-row {
      display: grid;
    }

    .flow-item::after {
      display: none;
    }
  }
}

@media (max-width: 720px) {
  .role-dashboard {
    .admin-overview-grid {
      grid-template-columns: repeat(4, minmax(180px, 1fr));
    }

    .admin-filter-bar {
      grid-template-columns: 240px 140px 180px 70px;
    }

    .bid-list-filter-bar {
      grid-template-columns: minmax(0, 1fr) 130px;
    }
  }
}

@media (max-width: 560px) {
  .role-dashboard {
    .bid-list-filter-bar {
      grid-template-columns: 1fr;
    }
  }
}
</style>
