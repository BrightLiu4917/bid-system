<template>
  <el-dialog
    v-model="visibleModel"
    width="560px"
    class="auth-dialog"
    :show-close="false"
    append-to-body
  >
    <template #header>
      <div class="auth-header">
        <div>
          <strong>{{ activeTab === 'login' ? '平台登录' : '账号注册' }}</strong>
          <span>北京国宏规划院招标与入库管理平台</span>
        </div>
        <button type="button" class="auth-close" @click="visibleModel = false">×</button>
      </div>
    </template>

    <el-tabs v-model="activeTab" stretch class="auth-tabs">
      <el-tab-pane label="登录" name="login">
        <div class="role-row">
          <button
            v-for="item in loginRoles"
            :key="item.value"
            type="button"
            :class="['role-button', role === item.value ? 'is-active' : '']"
            @click="role = item.value"
          >
            {{ item.label }}
          </button>
        </div>
        <el-form :model="loginForm" label-position="top" class="auth-form">
          <el-form-item label="手机号 / 用户名">
            <el-input v-model="loginForm.account" placeholder="请输入手机号或用户名" />
          </el-form-item>
          <el-form-item label="密码">
            <el-input v-model="loginForm.password" type="password" placeholder="请输入密码" show-password />
          </el-form-item>
        </el-form>
        <el-button type="primary" class="wide-button" @click="submitAuth('login')">
          登录并进入后台
        </el-button>
        <el-button class="wide-button" @click="activeTab = 'register'">
          没有账号，立即注册
        </el-button>
      </el-tab-pane>

      <el-tab-pane label="注册" name="register">
        <div class="role-row">
          <button
            v-for="item in registerRoles"
            :key="item.value"
            type="button"
            :class="['role-button', role === item.value ? 'is-active' : '']"
            @click="role = item.value"
          >
            {{ item.label }}
          </button>
        </div>
        <el-form :model="registerForm" label-position="top" class="auth-form">
          <el-form-item label="手机号">
            <el-input v-model="registerForm.phone" placeholder="请输入手机号" />
          </el-form-item>
          <el-form-item label="验证码">
            <div class="code-row">
              <el-input v-model="registerForm.code" placeholder="请输入短信验证码" />
              <el-button class="code-button" plain>获取验证码</el-button>
            </div>
          </el-form-item>
          <el-form-item label="设置密码">
            <el-input v-model="registerForm.password" type="password" placeholder="8-20位字母、数字、特殊符号" show-password />
          </el-form-item>
        </el-form>
        <el-button type="primary" class="wide-button" @click="submitAuth('register')">
          注册并进入后台
        </el-button>
        <el-button class="wide-button" @click="activeTab = 'login'">
          已有账号，去登录
        </el-button>
      </el-tab-pane>
    </el-tabs>
  </el-dialog>
</template>

<script setup>
import { computed, reactive, ref, watch } from "vue";

const props = defineProps({
  modelValue: {
    type: Boolean,
    default: false,
  },
  mode: {
    type: String,
    default: "login",
  },
  defaultRole: {
    type: String,
    default: "supplier",
  },
});

const emit = defineEmits(["update:modelValue", "success"]);

const loginRoles = [
  { label: "供应商", value: "supplier" },
  { label: "专家", value: "expert" },
  { label: "管理员", value: "admin" },
];

const registerRoles = [
  { label: "供应商", value: "supplier" },
  { label: "专家", value: "expert" },
];

const activeTab = ref(props.mode);
const role = ref(props.defaultRole);
const loginForm = reactive({
  account: "13800000000",
  password: "123456",
});
const registerForm = reactive({
  phone: "",
  code: "",
  password: "",
});

const visibleModel = computed({
  get: () => props.modelValue,
  set: (value) => emit("update:modelValue", value),
});

watch(
  () => props.mode,
  (value) => {
    activeTab.value = value;
  }
);

watch(
  () => props.defaultRole,
  (value) => {
    role.value = value;
  }
);

const submitAuth = (type) => {
  emit("success", {
    role: role.value,
    type,
  });
  emit("update:modelValue", false);
};
</script>

<style lang="scss" scoped>
.auth-header {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 20px;
  padding: 2px 2px 0;

  strong,
  span {
    display: block;
  }

  strong {
    color: #321f1f;
    font-size: 26px;
    font-weight: 700;
    line-height: 1.2;
  }

  span {
    margin-top: 8px;
    color: #8a7770;
    font-size: 14px;
  }
}

.auth-close {
  width: 36px;
  height: 36px;
  color: #8d817d;
  cursor: pointer;
  background: #f7f1ee;
  border: 1px solid #eadbd5;
  border-radius: 8px;
  font-size: 28px;
  line-height: 30px;
}

.auth-tabs {
  margin-top: 18px;
}

.role-row {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(120px, 1fr));
  gap: 12px;
  margin: 22px 0 20px;
}

.role-button {
  height: 46px;
  color: #5d4d49;
  cursor: pointer;
  background: #fff;
  border: 1px solid #e1d5d0;
  border-radius: 8px;
  font-size: 16px;
  font-weight: 700;

  &.is-active {
    color: #fff;
    background: #9b1c1f;
    border-color: #9b1c1f;
    box-shadow: 0 8px 18px rgba(155, 28, 31, 0.18);
  }
}

.auth-form {
  :deep(.el-form-item__label) {
    color: #4b3b37;
    font-size: 15px;
    font-weight: 700;
  }

  :deep(.el-input__wrapper) {
    height: 46px;
    border-radius: 8px;
    box-shadow: 0 0 0 1px #ded5d0 inset;
  }
}

.code-row {
  display: grid;
  grid-template-columns: minmax(0, 1fr) 132px;
  gap: 10px;
  width: 100%;
}

.code-button {
  height: 46px;
  color: #9b1c1f;
  background: #fff6f4;
  border-color: #d8aaa1;
  border-radius: 8px;
  font-weight: 700;
}

.wide-button {
  width: 100%;
  height: 46px;
  margin: 10px 0 0;
  border-radius: 8px;
  font-size: 16px;
  font-weight: 700;
}

:global(.auth-dialog) {
  border-radius: 10px;
  overflow: hidden;
}

:global(.auth-dialog .el-dialog__header) {
  padding: 30px 32px 0;
  margin: 0;
}

:global(.auth-dialog .el-dialog__body) {
  padding: 0 32px 32px;
}

:global(.auth-dialog .el-tabs__nav-wrap::after) {
  height: 1px;
  background: #eadfd9;
}

:global(.auth-dialog .el-tabs__active-bar) {
  height: 3px;
  background: #9b1c1f;
}

:global(.auth-dialog .el-tabs__item) {
  height: 52px;
  color: #6a5b56;
  font-size: 17px;
  font-weight: 700;
}

:global(.auth-dialog .el-tabs__item.is-active) {
  color: #9b1c1f;
}

:global(.auth-dialog .el-button--primary) {
  --el-button-bg-color: #9b1c1f;
  --el-button-border-color: #9b1c1f;
  --el-button-hover-bg-color: #7f1518;
  --el-button-hover-border-color: #7f1518;
  --el-button-active-bg-color: #741215;
  --el-button-active-border-color: #741215;
}

@media (max-width: 640px) {
  :global(.auth-dialog) {
    width: calc(100vw - 28px) !important;
  }

  .code-row {
    grid-template-columns: 1fr;
  }
}
</style>
