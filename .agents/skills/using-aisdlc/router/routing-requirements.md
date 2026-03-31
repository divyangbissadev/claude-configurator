## using-aisdlc Router：需求链路路由细则（R0–R4）

> 本文件只定义“Router 如何判定下一步”的口径，不复制需求侧 SOP 的模板与长文本。

### R 链路 SSOT 产物（用于路由判定）

以 `{FEATURE_DIR}` 为根：

- R0：`requirements/raw.md`
- R1：`requirements/solution.md`（必须包含 `## Impact Analysis`，锚点 `#impact-analysis`）
- R2：`requirements/prd.md`
- R3：`requirements/prototype.md`
- R4：Demo 产物默认落在 `{REPO_ROOT}/demo/prototypes/{CURRENT_BRANCH}/`

### R0 入口预检（强制路由到 `spec-init`）

满足任一条件，Router 必须优先进入 R0（`spec-init`）：

- 当前分支不满足 `{num}-{short-name}`（三位数字 + kebab-case）。
- 分支合规但 `{FEATURE_DIR}/requirements/raw.md` 不存在或为空。

> 说明：分支不合规时无需先跑 `spec-context`；分支合规时必须先 `spec-context` 得到 `FEATURE_DIR` 再检查 `raw.md`。

### R1（raw → solution）路由条件

当满足以下条件时，下一步默认进入 R1（`spec-product-clarify`）：

- 已通过 `spec-context` 得到 `FEATURE_DIR`
- `{FEATURE_DIR}/requirements/raw.md` 存在且非空
- `{FEATURE_DIR}/requirements/solution.md` 不存在，或存在但需更新（以用户意图“出方案/澄清/更新 solution”为信号）

### R1.5（Impact Analysis）在 Router 侧的口径

本仓库约束：`solution.md` 必须包含 `#impact-analysis`，作为 D2/I1/I2 的约束输入。

- 若 worker 产出的 `solution.md` 已包含 `#impact-analysis`：Router 继续路由下一步。
- 若 `solution.md` 缺少 `#impact-analysis`：Router 应把“补齐 Impact Analysis”视为 **阻断进入 D2/I1 的门禁缺口**，并优先路由回 R1（更新 `solution.md`），直到补齐为止。

> Router 只负责“缺口必须补齐”的判定；具体如何从项目知识库提取影响面，由对应 worker skill 负责（以仓库内约束为准）。

### R2（solution → PRD）是否需要的路由口径（可选）

默认：如果用户意图是“出 PRD/冻结交付规格”，且 `{FEATURE_DIR}/requirements/solution.md` 已存在，则进入 R2（`spec-product-prd`）。

可跳过 R2 的安全条件（满足其一即可考虑跳过）：

- 纯规则/配置/文案类变更，基本不改变任务流/页面结构。
- 变更范围极小且无歧义（通常 1–2 处改动）。
- 在 `solution.md` 中已补齐“最小可交付规格（Mini-PRD）”（例如 MVP In/Out + AC + 交互变化结论 + 影响面入口）。

若不满足以上条件：Router 应优先路由到 R2，避免实现阶段出现理解偏差。

### R3（PRD → prototype）是否需要的路由口径（可选）

当存在新增/变更交互、状态分支复杂、或需要消除交互歧义时，进入 R3（`spec-product-prototype`）。

可跳过 R3 的安全条件（满足其一即可考虑跳过）：

- 无交互变化，或交互简单且明确（PRD/solution 的 AC 已足够无歧义指导实现与测试）。

### R4（prototype → demo）是否需要的路由口径（可选）

当需要更高保真走查验证（干系人对齐/可用性验证/研发测试理解一致性）时，进入 R4（`spec-product-demo`）。

R4 的硬阻断：

- 找不到可运行 Demo 工程根目录，且用户未提供 `DEMO_PROJECT_ROOT`。此时 Router 必须硬中断并索取该输入；禁止自创工程位置。
