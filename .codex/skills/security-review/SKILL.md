---
name: security-review
description: 审查认证、授权、租户隔离、越权、敏感字段、日志、SQL 注入、XSS、文件上传和密钥泄露等安全风险。
---

# 安全审查

## 必须读取
- `AGENTS.md`
- `docs/SECURITY_RULES.md`
- 相关 OpenSpec specs/changes

## 流程
1. 识别认证和权限边界。
2. 检查租户隔离和越权访问。
3. 检查敏感字段、日志、异常和导出。
4. 检查 SQL 注入、XSS、文件上传和密钥。
5. 输出阻塞风险和修复建议。

## 输出
- 安全边界
- 风险列表
- 修复建议
- 残余风险
