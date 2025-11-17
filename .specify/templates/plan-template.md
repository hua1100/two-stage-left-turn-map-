# 實作計畫：[功能名稱]

**分支**: `[###-功能名稱]` | **日期**: [日期] | **規格**: [連結]
**輸入**: 來自 `/specs/[###-功能名稱]/spec.md` 的功能規格

**注意**: 此模板由 `/speckit.plan` 指令填寫。執行流程請參見 `.specify/templates/commands/plan.md`。

---

**⚠️ 語言要求 (來自專案憲章 Principle 1)**:
本文件必須使用繁體中文撰寫。唯一允許使用英文的文件是 `.specify/memory/constitution.md`。

---

## 摘要

[從功能規格中提取：主要需求 + 研究得出的技術方法]

## 技術背景

<!--
  需採取行動：請將此節中的內容替換為專案的技術細節。
  此處的結構僅供參考，以引導迭代過程。
-->

**語言/版本**: [例如：Python 3.11、Swift 5.9、Rust 1.75 或 需要釐清]
**主要相依套件**: [例如：FastAPI、UIKit、LLVM 或 需要釐清]
**儲存**: [如適用，例如：PostgreSQL、CoreData、檔案系統 或 不適用]
**測試**: [例如：pytest、XCTest、cargo test 或 需要釐清]
**目標平台**: [例如：Linux 伺服器、iOS 15+、WASM 或 需要釐清]
**專案類型**: [單一/網頁/行動應用 - 決定原始碼結構]
**效能目標**: [領域特定，例如：1000 req/s、10k lines/sec、60 fps 或 需要釐清]
**限制條件**: [領域特定，例如：<200ms p95、<100MB 記憶體、離線可用 或 需要釐清]
**規模/範圍**: [領域特定，例如：10k 使用者、1M LOC、50 個畫面 或 需要釐清]

## 憲章檢查

*關卡：必須在階段 0 研究前通過。階段 1 設計後重新檢查。*

根據專案憲章 (`.specify/memory/constitution.md`) 的原則：

- [ ] **Principle 1 - 語言要求**: 所有文件使用繁體中文 ✓
- [ ] **Principle 2 - 簡潔優先**: 架構決策已記錄複雜度理由（如需要）
- [ ] **Principle 3 - 測試驅動開發**: 測試將先於實作撰寫
- [ ] **Principle 4 - 版本控制紀律**: 功能分支已建立，遵循命名規範
- [ ] **Principle 5 - 文件即程式碼**: 規格文件與實作同步更新

## 專案結構

### 文件（此功能）

```
specs/[###-功能]/
├── plan.md              # 本檔案 (/speckit.plan 指令輸出)
├── research.md          # 階段 0 輸出 (/speckit.plan 指令)
├── data-model.md        # 階段 1 輸出 (/speckit.plan 指令)
├── quickstart.md        # 階段 1 輸出 (/speckit.plan 指令)
├── contracts/           # 階段 1 輸出 (/speckit.plan 指令)
└── tasks.md             # 階段 2 輸出 (/speckit.tasks 指令 - 不由 /speckit.plan 建立)
```

### 原始碼（程式庫根目錄）
<!--
  需採取行動：請將下方的佔位樹狀結構替換為此功能的實際配置。
  刪除未使用的選項，並使用真實路徑擴展選定的結構（例如：apps/admin、packages/something）。
  交付的計畫不得包含「選項」標籤。
-->

```
# [未使用則刪除] 選項 1：單一專案（預設）
src/
├── models/
├── services/
├── cli/
└── lib/

tests/
├── contract/
├── integration/
└── unit/

# [未使用則刪除] 選項 2：網頁應用程式（偵測到「前端」+「後端」時）
backend/
├── src/
│   ├── models/
│   ├── services/
│   └── api/
└── tests/

frontend/
├── src/
│   ├── components/
│   ├── pages/
│   └── services/
└── tests/

# [未使用則刪除] 選項 3：行動應用 + API（偵測到「iOS/Android」時）
api/
└── [同上方 backend]

ios/ 或 android/
└── [平台特定結構：功能模組、UI 流程、平台測試]
```

**結構決策**: [記錄選定的結構並參照上方擷取的實際目錄]

## 複雜度追蹤

*僅在憲章檢查有違規且必須證明合理時填寫*

| 違規項目 | 需要原因 | 拒絕較簡單替代方案的理由 |
|---------|---------|------------------------|
| [例如：第 4 個專案] | [目前需求] | [為何 3 個專案不足] |
| [例如：Repository 模式] | [特定問題] | [為何直接 DB 存取不足] |
