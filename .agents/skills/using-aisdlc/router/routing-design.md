## using-aisdlc Router：设计链路路由细则（D0–D2）

> 本文件只定义“Router 如何判定下一步”的口径，不复制设计侧 SOP 的模板与长文本。

### 设计链路产物（用于路由判定）

以 `{FEATURE_DIR}` 为根：

- D1：`design/research.md`（可选）
- D2：`design/design.md`（未跳过 design 时必做）

### D0：是否跳过 design（Router 唯一判定）

Router 在以下场景执行 D0 判定：

- R1（或 R2/R3/R4）已产出可追溯的需求输入（至少 `requirements/solution.md` 存在且含 `#impact-analysis`）。
- 用户意图包含“进入开发闭环/开始实现/做实现计划/需要 RFC 评审”等任一信号。

可考虑跳过 design 的安全条件（满足其一即可考虑）：

- 范围单一、边界清晰，跨模块协作与系统性风险很低。
- 无对外承诺变化（API/事件/权限/数据口径），且无数据迁移/回滚需求。
- 无关键技术不确定性，不需要先 research 验证。
- 验收口径已足够可追溯（在 `solution.md` 或 `prd.md` 中可写清楚、可测试、可验证）。

默认不跳过（任一命中即倾向不跳过）：

- 触及对外契约/权限/口径变更，或需要数据迁移/回滚。
- 高风险不确定性、多方案缺证据取舍、跨系统/上下游影响面大。
- 团队明确要求出 RFC 评审。

### D1：是否需要 research（Router 唯一判定）

命中任一则需要 D1（路由到 `spec-design-research`）：

- 方案正确性依赖未知事实（若 X 不成立会推倒重来）。
- 存在多条合理路径但缺证据支撑取舍。
- 对外契约/迁移/安全/性能/一致性存在高风险点需先验证。

否则：直接进入 D2（路由到 `spec-design`）。

### D2：进入 RFC（未跳过时必做）

当 D0 判定“不跳过 design”时：

- 需要 D1 → D1 完成后进入 D2
- 不需要 D1 → 直接进入 D2

Router 侧门禁提示（不替代 worker 门禁）：

- D2 的输入必须包含 `requirements/solution.md#impact-analysis`，用于强制读取受影响模块与 ADR；缺失则应回到 R1 补齐。

### 跳过 design 时的实现侧补齐要求（Router 约束）

当 D0 判定“跳过 design”并进入实现链路（I1）时，Router 必须要求：

- 在 `{FEATURE_DIR}/implementation/plan.md` 补齐“最小决策信息”（目标/范围与边界/关键约束/验收口径/验证清单），不得脑补。
