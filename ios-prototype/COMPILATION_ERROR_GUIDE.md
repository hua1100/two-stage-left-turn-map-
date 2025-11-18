# 編譯錯誤解決指南

**最後更新**: 2025-11-18
**適用於**: Xcode 專案建置錯誤

---

## 🔧 常見編譯錯誤與解決方案

### 錯誤 1: "Multiple commands produce..."

**完整錯誤訊息**:
```
Multiple commands produce '/Users/.../DerivedData/TaipeiLeftTurnAlert-xxx/Build/Products/Debug-iphoneos/TaipeiLeftTurnAlert.app/...'
```

**原因**: 檔案被重複加入到建置目標（Build Phases）中。

**解決方案**:

#### 方法 1：檢查並移除重複檔案（推薦）

1. 在 Xcode 中，點擊專案根目錄（藍色圖示）
2. 選擇 **TARGETS** → **TaipeiLeftTurnAlert**
3. 點擊 **Build Phases** 標籤頁
4. 展開「**Compile Sources**」
5. 查看列表中是否有重複的檔案（同一檔案出現兩次）
6. 選擇重複的項目，按 **Delete** 鍵移除
7. 只保留一份即可

#### 方法 2：清理建置（快速嘗試）

1. 選擇選單：**Product > Clean Build Folder**（⌘+Shift+K）
2. 重新建置：**Product > Build**（⌘+B）

#### 方法 3：重新加入檔案

如果上述方法無效：

1. 在專案導航器中，找到出現問題的檔案
2. 右鍵點擊檔案 → **Delete**
3. 選擇「**Remove Reference**」（不要選 Move to Trash）
4. 從 Finder 中重新拖放該檔案到專案中
5. 確認勾選「**Copy items if needed**」和「**TaipeiLeftTurnAlert** target」

---

### 錯誤 2: "Type does not conform to protocol..."

**完整錯誤訊息**:
```
Type 'IntersectionDataService' does not conform to protocol 'ObservableObject'
```

**原因**: 缺少 `import Combine` 或 `@Published` 使用不當。

**解決方案**:

✅ **已修復**: 在最新的 commit 中，已加入 `import Combine` 到：
- `IntersectionDataService.swift`
- `UserPreferences.swift`

請確保您的程式碼是最新版本：

```bash
git pull origin claude/init-constitution-chinese-01GvKm9dHe9ToHFQi1d44rKb
```

如果問題仍然存在，檢查檔案開頭是否有：

```swift
import Foundation
import Combine  // ← 必須包含此行

class YourClass: ObservableObject {
    @Published var yourProperty: Type
}
```

---

### 錯誤 3: "Cannot find 'XXX' in scope"

**完整錯誤訊息**:
```
Cannot find 'IntersectionDataService' in scope
```

**原因**: 檔案未正確加入專案或 Target Membership 未勾選。

**解決方案**:

1. 在專案導航器中找到該檔案
2. 點擊檔案
3. 在右側面板（Inspector）中，找到「**Target Membership**」區域
4. 確認 ✅ **TaipeiLeftTurnAlert** 已勾選
5. 如果未勾選，請勾選它

如果檔案不在專案中：

1. 確認檔案存在於 `ios-prototype/TaipeiLeftTurnAlert/` 目錄
2. 拖放檔案到 Xcode 的對應群組中
3. 確認「Copy items if needed」和「Add to targets」已勾選

---

### 錯誤 4: "No such module 'MapKit'" 或其他系統框架

**原因**: 極少發生，通常是 Xcode 暫時性問題。

**解決方案**:

1. 清理建置：**Product > Clean Build Folder**（⌘+Shift+K）
2. 關閉並重新開啟 Xcode
3. 重新建置專案

---

### 錯誤 5: "Command CompileSwift failed with a nonzero exit code"

**原因**: Swift 程式碼有語法錯誤。

**解決方案**:

1. 查看錯誤訊息前面的詳細錯誤
2. 點擊錯誤訊息會跳轉到出錯的程式碼行
3. 修正語法錯誤
4. 常見問題：
   - 缺少 `import` 語句
   - 拼字錯誤
   - 缺少括號或大括號

---

### 錯誤 6: "Value of type 'XXX' has no member 'YYY'"

**範例**:
```
Value of type 'LocationService' has no member 'currentLocation'
```

**原因**:
- 檔案版本不一致
- 屬性名稱錯誤
- 缺少檔案

**解決方案**:

1. 確認您使用的是最新版本的程式碼：
   ```bash
   git pull origin claude/init-constitution-chinese-01GvKm9dHe9ToHFQi1d44rKb
   ```

2. 檢查該類別的定義，確認屬性名稱正確

3. 如果是自訂類別，確認該檔案已加入專案

---

## 🛠️ 通用除錯步驟

遇到任何編譯錯誤時，按照以下步驟操作：

### 步驟 1: 閱讀錯誤訊息

- 點擊錯誤會跳轉到出錯的檔案和行號
- 仔細閱讀錯誤描述

### 步驟 2: 清理建置

```
Product > Clean Build Folder (⌘+Shift+K)
```

### 步驟 3: 確認檔案正確加入

1. 所有 `.swift` 檔案都在專案導航器中
2. 每個檔案的 Target Membership 都勾選了 **TaipeiLeftTurnAlert**

### 步驟 4: 確認專案設定

1. **General** 標籤頁：
   - iOS Deployment Target = 15.0
   - Supported Destinations = iPhone only

2. **Signing & Capabilities**：
   - Automatically manage signing 已勾選
   - Background Modes 已加入（Location updates + Audio）

3. **Build Settings**：
   - Swift Language Version = Swift 5

### 步驟 5: 重新啟動 Xcode

有時候 Xcode 需要重新啟動才能正確識別更改。

### 步驟 6: 更新程式碼

確認使用最新版本：

```bash
cd /path/to/two-stage-left-turn-map-
git pull origin claude/init-constitution-chinese-01GvKm9dHe9ToHFQi1d44rKb
```

---

## 📋 檢查清單

在提交錯誤報告前，請確認：

- [ ] 已執行 Clean Build Folder
- [ ] 所有檔案都有正確的 Target Membership
- [ ] 沒有重複的檔案在 Compile Sources 中
- [ ] 使用最新版本的程式碼（git pull）
- [ ] Xcode 版本為 15.0 或更新
- [ ] 專案設定正確（參考 XCODE_PROJECT_SETUP.md）

---

## 🆘 仍然無法解決？

如果上述方法都無法解決您的問題，請提供以下資訊：

1. **完整的錯誤訊息**（截圖或複製文字）
2. **出錯的檔案名稱與行號**
3. **Xcode 版本**（Xcode > About Xcode）
4. **macOS 版本**
5. **您已嘗試的解決方法**

**提示**: 在 Xcode 的 Report Navigator（⌘+9）中可以看到完整的建置日誌。

---

**最後更新**: 2025-11-18
