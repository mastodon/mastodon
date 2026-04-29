# CI Workflow 策略文档

## 概述

本文档描述了 Mastodon 项目的 CI (Continuous Integration) 工作流策略，包括路径过滤规则、轻量/全量测试的触发条件，以及"误跳过"防护机制。

## 核心原则

1. **纯前端改动 → 轻量链路**：只运行前端相关测试（JS 测试、代码检查等）
2. **后端/配置变更 → 全量测试**：运行所有测试（Rails 测试、E2E 测试、搜索集成测试等）
3. **合并队列/main 分支 → 始终全量**：确保代码质量

## Workflow 分类

### 前端相关 Workflows

这些 workflows 只在前端文件变更时运行：

| Workflow 文件 | 触发条件 | 用途 |
|--------------|---------|------|
| `test-js.yml` | JS/TS 文件变更 | JavaScript 单元测试 |
| `lint-js.yml` | JS/TS 文件变更 | ESLint + TypeScript 类型检查 |
| `lint-css.yml` | 样式文件变更 | 样式代码检查 |
| `format-check.yml` | 前端文件变更 | 代码格式检查 |
| `check-i18n.yml` | i18n 文件变更 | 国际化检查 |

### 后端相关 Workflows

这些 workflows 只在后端文件变更时运行：

| Workflow 文件 | 触发条件 | 用途 |
|--------------|---------|------|
| `lint-ruby.yml` | Ruby 文件变更 | RuboCop + Brakeman |
| `lint-haml.yml` | Haml 文件变更 | Haml 模板检查 |
| `test-migrations.yml` | Ruby/DB 文件变更 | 数据库迁移测试 |
| `bundler-audit.yml` | Gemfile 变更 | 依赖安全审计 |
| `test-ruby.yml` | **见下文** | 全量 Rails 测试 |

## `test-ruby.yml` 路径过滤规则

`test-ruby.yml` 是项目中最耗时的 workflow，包含：
- `build`：编译 assets
- `test`：Rails 单元测试（多 Ruby 版本）
- `test-e2e`：端到端测试
- `test-search`：搜索集成测试

### 触发条件

| 事件类型 | 触发规则 |
|---------|---------|
| `merge_group` | 始终运行（合并队列全量测试） |
| `push`（main/stable-*） | 始终运行 |
| `pull_request` | **非纯前端改动时运行** |

### `pull_request` 事件的 `paths-ignore` 规则

**仅当 PR 中所有变更文件都匹配以下模式时，跳过此 workflow**：

```yaml
paths-ignore:
  # 前端代码目录
  - 'app/javascript/**/*'

  # JavaScript/TypeScript 文件
  - '**/*.js'
  - '**/*.jsx'
  - '**/*.ts'
  - '**/*.tsx'

  # 样式文件
  - '**/*.css'
  - '**/*.scss'
  - '**/*.sass'

  # Jest 快照文件
  - '**/*.snap'

  # 前端配置文件
  - 'package.json'
  - 'yarn.lock'
  - '.nvmrc'
  - 'tsconfig.json'
  - 'eslint.config.mjs'
  - 'vite.config.ts'
  - 'jsconfig.json'
  - '.browserslistrc'

  # Storybook 配置
  - '.storybook/**/*'

  # 文档文件（不影响代码逻辑）
  - '*.md'
  - 'docs/**/*'
  - 'AUTHORS'
  - 'CHANGELOG.md'
  - 'CODE_OF_CONDUCT.md'
  - 'CONTRIBUTING.md'
  - 'LICENSE'
  - 'README.md'
  - 'SECURITY.md'
```

### 始终触发全量测试的场景

以下变更**不会被跳过**，始终触发 `test-ruby.yml`：

| 场景 | 原因 |
|------|------|
| 任何 Ruby 文件变更 | 后端逻辑变更 |
| 任何视图模板变更（`.erb`, `.haml`, `.slim`） | 后端模板变更 |
| `config/**/*` | 配置变更 |
| `db/**/*` | 数据库迁移/配置 |
| `lib/**/*` | 库代码变更 |
| `app/controllers/**/*` | 控制器变更 |
| `app/models/**/*` | 模型变更 |
| `app/lib/**/*` | 后端库代码 |
| `app/policies/**/*` | 授权策略变更 |
| `app/chewy/**/*` | 搜索索引变更 |
| 本 workflow 文件自身变更 | CI 配置变更 |
| 同时包含前后端变更的 PR | 确保充分测试 |

## "误跳过"防护机制

### 为什么使用 `paths-ignore` 而非 `paths`？

**`paths` 配置的问题**：
```yaml
paths:  # 不推荐！
  - '**/*.rb'
  - '**/*.rake'
  - 'config/**/*'
  - 'db/**/*'
  # ... 可能遗漏某些文件类型
```

如果新增了一种后端文件类型（如 `*.builder` 模板），但忘记添加到 `paths` 列表中，**会被误跳过**！

**`paths-ignore` 配置的优势**：
```yaml
paths-ignore:  # 推荐！
  - 'app/javascript/**/*'
  - '**/*.js'
  - '**/*.jsx'
  # ... 只列出"纯前端"文件
```

- 新添加的文件类型**默认会触发测试**（不会被意外跳过）
- 只有明确被归类为"纯前端"的文件才会被跳过
- 任何不在 ignore 列表中的变更都会触发全量测试

### 多重防护

| 防护层 | 说明 |
|--------|------|
| `paths-ignore` 而非 `paths` | 新文件类型默认触发测试 |
| 仅 `pull_request` 事件过滤 | `merge_group` 和 `push` 始终全量 |
| 混合变更不跳过 | 同时改动前后端 → 全量测试 |
| 配置文件不跳过 | 改动 workflow 自身 → 全量测试 |

## 实际场景示例

### 场景 1：纯前端 PR

**变更文件**：
- `app/javascript/mastodon/components/button.tsx`
- `app/javascript/styles/application.scss`

**触发的 Workflows**：
| Workflow | 状态 |
|----------|------|
| `test-js.yml` | ✅ 运行 |
| `lint-js.yml` | ✅ 运行 |
| `lint-css.yml` | ✅ 运行 |
| `format-check.yml` | ✅ 运行 |
| `test-ruby.yml` | ⏭️ 跳过 |
| `lint-ruby.yml` | ⏭️ 跳过 |

**预期反馈时间**：数分钟（快速）

### 场景 2：纯后端 PR

**变更文件**：
- `app/models/status.rb`
- `app/controllers/api/v1/statuses_controller.rb`

**触发的 Workflows**：
| Workflow | 状态 |
|----------|------|
| `test-ruby.yml` | ✅ 运行（全量） |
| `lint-ruby.yml` | ✅ 运行 |
| `test-migrations.yml` | ✅ 运行 |
| `test-js.yml` | ⏭️ 跳过（`paths` 配置） |

**预期反馈时间**：数十分钟（全量测试）

### 场景 3：混合 PR

**变更文件**：
- `app/models/status.rb`（后端）
- `app/javascript/mastodon/components/status.tsx`（前端）

**触发的 Workflows**：
| Workflow | 状态 |
|----------|------|
| `test-ruby.yml` | ✅ 运行（全量） |
| `lint-ruby.yml` | ✅ 运行 |
| `test-js.yml` | ✅ 运行 |
| `lint-js.yml` | ✅ 运行 |
| `test-migrations.yml` | ✅ 运行 |

**预期反馈时间**：数十分钟（全量测试）

### 场景 4：文档 PR

**变更文件**：
- `README.md`
- `docs/DEVELOPMENT.md`

**触发的 Workflows**：
| Workflow | 状态 |
|----------|------|
| `test-ruby.yml` | ⏭️ 跳过 |
| `lint-ruby.yml` | ⏭️ 跳过 |
| `test-js.yml` | ⏭️ 跳过 |
| `lint-js.yml` | ⏭️ 跳过 |

**预期反馈时间**：几乎无等待

### 场景 5：CI 配置变更

**变更文件**：
- `.github/workflows/test-ruby.yml`

**触发的 Workflows**：
| Workflow | 状态 |
|----------|------|
| `test-ruby.yml` | ✅ 运行（全量） |
| 其他 | 视情况而定 |

**原因**：确保 CI 配置变更经过充分测试

## 强制运行全量测试

如果希望强制运行 `test-ruby.yml`（即使是纯前端 PR），可以在 PR 中同时修改：
- 任意后端文件
- 或者添加一个临时的后端变更（测试后可移除）

或者，在 `merge_group` 中合并时会自动运行全量测试。

## Workflow 文件位置

所有 workflow 文件位于：
```
.github/workflows/
├── test-ruby.yml          # 全量 Rails 测试（带路径过滤）
├── test-js.yml            # JavaScript 测试
├── test-migrations.yml    # 数据库迁移测试
├── lint-ruby.yml          # Ruby 代码检查
├── lint-js.yml            # JavaScript 代码检查
├── lint-css.yml           # CSS 代码检查
└── ...
```

## 维护指南

### 新增前端文件类型

如果新增了一种前端文件类型（如 `*.vue`），需要：
1. 在 `test-ruby.yml` 的 `paths-ignore` 中添加相应模式
2. 在相关前端 workflow（如 `test-js.yml`、`lint-js.yml`）的 `paths` 中添加

### 新增后端文件类型

不需要任何操作！`paths-ignore` 策略会自动处理：
- 新文件类型**不在 ignore 列表中**
- 因此会触发全量测试

这是"误跳过"防护的核心设计。

### 调整过滤规则

修改 `.github/workflows/test-ruby.yml` 中的 `paths-ignore` 配置，并更新本文档。

## 常见问题

### Q: 我的 PR 是纯前端改动，为什么 `test-ruby.yml` 还在运行？

检查是否有以下情况：
1. PR 同时包含后端文件变更
2. 修改了 workflow 配置文件
3. 修改了配置文件（`config/**/*`, `db/**/*` 等）

如果以上都不是，可能是 `paths-ignore` 规则需要调整。

### Q: 如何验证我的 PR 会触发哪些 workflows？

可以通过以下方式：
1. 观察 GitHub Actions 界面
2. 查看 `paths-ignore` 规则，确认所有变更文件都匹配 ignore 模式
3. 如果不确定，可以将 PR 加入 merge queue，会自动运行全量测试

### Q: 为什么 `merge_group` 不使用路径过滤？

合并队列是代码合并到 main 分支前的最后一道防线，必须确保：
1. 所有测试通过
2. 代码质量符合标准
3. 与其他变更兼容

因此 `merge_group` 事件始终运行全量测试。

### Q: 为什么不跳过 `test-e2e` 测试？

端到端测试 (`test-e2e`) 依赖于完整的 Rails 环境，并且与 `build` job 有依赖关系。考虑到：
1. 纯前端改动已经有 `test-js.yml` 覆盖
2. `test-e2e` 是全量测试的一部分
3. 简化 CI 配置复杂度

因此采用"全跳过或全运行"的策略：
- 纯前端 PR → 跳过 `test-ruby.yml` 全部（包括 `test-e2e`）
- 非纯前端 PR → 运行全部

如果未来需要，可以考虑将 `test-e2e` 拆分为独立的 workflow。

---

**最后更新**：2026-04-29
