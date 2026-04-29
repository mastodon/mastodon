# CI Workflow 策略文档

## 概述

本文档描述了 Mastodon 项目的 CI (Continuous Integration) 工作流策略，包括路径过滤规则、轻量/全量测试的触发条件，以及"误跳过"防护机制。

## 核心原则

1. **纯前端改动 → 轻量链路**：只运行前端相关测试（JS 测试、代码检查等）
2. **后端/配置变更 → 全量测试**：运行所有测试（Rails 测试、E2E 测试、搜索集成测试等）
3. **合并队列/main 分支 → 始终全量**：确保代码质量
4. **零误跳过原则**：宁可不优化，也不误跳过后端代码

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

**重要：不使用扩展名模式！**

为了防止误跳过后端代码（如 streaming 服务、Node.js 工具等），本配置**不使用** `**/*.ts`、`**/*.js` 这类扩展名模式。

取而代之的是：**明确列出可以安全忽略的纯前端目录**。

**仅当 PR 中所有变更文件都匹配以下模式时，跳过此 workflow**：

```yaml
paths-ignore:
  # ======================================================================
  # 纯前端代码目录（核心规则）
  # ======================================================================
  #
  # 所有 React/TypeScript 前端代码都在这个目录下。
  # 这个规则已经覆盖了该目录下的所有文件：
  # - *.ts, *.tsx, *.js, *.jsx
  # - *.css, *.scss, *.sass
  # - *.snap
  #
  # 不使用 `**/*.ts` 等扩展名模式，防止误跳过后端代码。
  # ----------------------------------------------------------------------
  - 'app/javascript/**/*'

  # ======================================================================
  # 前端构建工具配置
  # ======================================================================
  #
  # Vite 构建插件和配置。这些是前端构建相关的，不影响后端逻辑。
  # ----------------------------------------------------------------------
  - 'config/vite/**/*'
  - 'vite.config.ts'

  # ======================================================================
  # 开发工具配置
  # ======================================================================
  #
  # Storybook 组件文档工具、Husky Git hooks。
  # 这些不影响代码逻辑。
  # ----------------------------------------------------------------------
  - '.storybook/**/*'
  - '.husky/**/*'

  # ======================================================================
  # 前端配置文件
  # ======================================================================
  #
  # 这些是明确的文件路径，不会误匹配其他文件。
  # ----------------------------------------------------------------------
  - 'package.json'
  - 'yarn.lock'
  - '.nvmrc'
  - 'tsconfig.json'
  - 'eslint.config.mjs'
  - 'jsconfig.json'
  - '.browserslistrc'

  # ======================================================================
  # 文档文件（不影响代码逻辑）
  # ======================================================================
  #
  # 文档变更不需要运行后端测试。
  # ----------------------------------------------------------------------
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
| 任何不在 `app/javascript` 的 JS/TS 文件 | 可能是后端服务代码 |
| 任何 Ruby 文件变更 | 后端逻辑变更 |
| 任何视图模板变更（`.erb`, `.haml`, `.slim`） | 后端模板变更 |
| `config/**/*`（除了 `config/vite/**/*`） | 配置变更 |
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

### 为什么不使用扩展名模式？

**❌ 不推荐的做法**：
```yaml
paths-ignore:
  - '**/*.js'
  - '**/*.ts'
  - '**/*.tsx'
  - '**/*.css'
```

**风险**：这些模式会匹配所有目录中的文件，包括：
- streaming 服务代码
- 后端 Node.js 工具
- 其他非前端 JS/TS 代码

**示例**：
- `streaming/server.ts` → ❌ 会被错误跳过（后端代码）
- `lib/tasks/export.js` → ❌ 会被错误跳过（后端脚本）
- `app/javascript/components/button.tsx` → ✅ 应该跳过（前端代码）

**✅ 推荐的做法**：
```yaml
paths-ignore:
  - 'app/javascript/**/*'
```

**优势**：
1. 只匹配明确的前端目录
2. **不会误跳过任何后端代码**
3. 任何新增的后端 JS/TS 文件都会触发测试

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
  # ... 只列出"纯前端"目录
```

- 新添加的文件类型**默认会触发测试**（不会被意外跳过）
- 只有明确被归类为"纯前端"的目录才会被跳过
- 任何不在 ignore 列表中的变更都会触发全量测试

### 多重防护

| 防护层 | 说明 |
|--------|------|
| 使用目录路径而非扩展名模式 | 不会误跳过后端 JS/TS 代码 |
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

### 场景 3：后端 TS 代码（关键：不会被跳过！）

**变更文件**：
- `streaming/server.ts`（假设的 streaming 服务）
- `lib/scripts/export.js`（后端脚本）

**触发的 Workflows**：
| Workflow | 状态 |
|----------|------|
| `test-ruby.yml` | ✅ 运行（全量） |
| `test-js.yml` | ✅ 运行（`paths` 配置） |

**关键**：这些文件**不在** `app/javascript/**/*` 目录下，因此**不会被跳过**！

**预期反馈时间**：数十分钟（全量测试）

### 场景 4：混合 PR

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

### 场景 5：文档 PR

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

### 场景 6：CI 配置变更

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

### 新增前端目录

如果新增了一个纯前端目录（如 `app/frontend/`），需要：
1. 在 `test-ruby.yml` 的 `paths-ignore` 中添加相应目录路径
2. 更新本文档

**注意**：使用目录路径，**不要**使用扩展名模式。

### 新增后端文件类型

不需要任何操作！`paths-ignore` 策略会自动处理：
- 新文件类型**不在 ignore 列表中**
- 因此会触发全量测试

这是"零误跳过"防护的核心设计。

### 调整过滤规则

修改 `.github/workflows/test-ruby.yml` 中的 `paths-ignore` 配置，并更新本文档。

**重要**：始终优先使用目录路径，而非扩展名模式。

## 常见问题

### Q: 我的 PR 是纯前端改动，为什么 `test-ruby.yml` 还在运行？

检查是否有以下情况：
1. PR 同时包含后端文件变更
2. 修改了 workflow 配置文件
3. 修改了配置文件（`config/**/*`（除了 `config/vite/`）, `db/**/*` 等）
4. 变更文件在 `app/javascript/**/*` 之外（即使是 JS/TS 文件）

如果以上都不是，可能是 `paths-ignore` 规则需要调整。

### Q: 为什么 `streaming/server.ts` 不会被跳过？

因为我们使用的是**目录路径**而非**扩展名模式**：

| 文件路径 | 模式匹配 | 结果 |
|---------|---------|------|
| `app/javascript/components/button.tsx` | `app/javascript/**/*` | ✅ 跳过 |
| `streaming/server.ts` | 不匹配任何 ignore 模式 | ✅ 触发测试 |
| `lib/scripts/export.js` | 不匹配任何 ignore 模式 | ✅ 触发测试 |

这正是"零误跳过"设计的核心。

### Q: 如何验证我的 PR 会触发哪些 workflows？

可以通过以下方式：
1. 观察 GitHub Actions 界面
2. 查看 `paths-ignore` 规则，确认所有变更文件都在 `app/javascript/**/*` 或其他明确的前端目录下
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
