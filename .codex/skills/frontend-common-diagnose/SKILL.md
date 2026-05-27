---
name: frontend-common-diagnose
description: 前端通用诊断 skill。用于页面报错、交互异常、接口失败、状态不同步、性能卡顿和视觉回归问题，先复现再修复。
---

# 前端诊断

## 必须读取
- `AGENTS.md`
- `docs/FRONTEND_RULES.md`
- `docs/UX_RULES.md`
- `docs/TESTING_RULES.md`

## 流程
1. 建立反馈回路：本地页面、测试、浏览器控制台、网络请求或复现步骤。
2. 确认复现的是用户描述的问题。
3. 定位页面、组件、状态、接口和权限条件。
4. 提出可证伪假设，一次验证一个。
5. 最小修复根因。
6. 补回归验证。

## 输出
- 复现步骤
- 根因分析
- 修复方案
- 验证结果
- 剩余风险
