# Xcode 專案設定指南

**版本**: 1.0.0
**最後更新**: 2025-11-18
**適用對象**: 需要建立完整 Xcode 專案的開發者

---

## 📋 概述

本指南將協助您建立完整的 Xcode 專案，並正確整合所有原始碼檔案。

## 🎯 前置需求

- **macOS**: 13.0 (Ventura) 或更新版本
- **Xcode**: 15.0 或更新版本
- **Apple 開發者帳號**: 免費或付費帳號皆可

---

## 📦 步驟 1：建立新專案

### 1.1 開啟 Xcode

1. 啟動 Xcode
2. 選擇「Create a new Xcode project」

### 1.2 選擇專案範本

1. 選擇 **iOS** 平台
2. 選擇 **App** 範本
3. 點擊「Next」

### 1.3 設定專案資訊

填入以下資訊：

| 欄位 | 值 |
|------|-----|
| **Product Name** | `TaipeiLeftTurnAlert` |
| **Team** | （選擇您的開發團隊） |
| **Organization Identifier** | `com.yourname` 或 `tw.taipei` |
| **Bundle Identifier** | 自動生成（例如：`com.yourname.TaipeiLeftTurnAlert`） |
| **Interface** | **SwiftUI** ✅ |
| **Language** | **Swift** ✅ |
| **Storage** | None |
| **Include Tests** | ✅ 勾選 |

點擊「Next」並選擇儲存位置。

---

## 📁 步驟 2：整理專案結構

### 2.1 刪除預設檔案

Xcode 會自動建立一些檔案，請先刪除以下檔案（移至垃圾桶）：

- `ContentView.swift`（我們會用自己的版本）
- `TaipeiLeftTurnAlertApp.swift`（我們會用自己的版本）

### 2.2 建立資料夾結構

在專案導航器中，右鍵點擊 `TaipeiLeftTurnAlert` 群組，選擇「New Group」，建立以下資料夾：

```
TaipeiLeftTurnAlert/
├── App/
├── Models/
├── Views/
├── ViewModels/
├── Services/
└── Resources/
```

---

## 📄 步驟 3：加入原始碼檔案

### 3.1 複製檔案到專案

將以下檔案從 `ios-prototype/TaipeiLeftTurnAlert/` 目錄複製到對應的 Xcode 群組中：

#### App/
- `TaipeiLeftTurnAlertApp.swift`

#### Models/
- `Intersection.swift`
- `UserPreferences.swift`

#### Views/
- `ContentView.swift`
- `MapView.swift`
- `SettingsView.swift`

#### ViewModels/
- `MapViewModel.swift`
- `SettingsViewModel.swift`

#### Services/
- `LocationService.swift`
- `VoiceAlertService.swift`
- `DirectionMatcher.swift`
- `IntersectionDataService.swift`

#### Resources/
- `intersections.json`（從 `Resources/` 目錄）
- `Info.plist`（替換 Xcode 自動生成的）

### 3.2 加入檔案的方式

**方法 1：拖放**（推薦）
1. 在 Finder 中開啟 `ios-prototype/TaipeiLeftTurnAlert/` 目錄
2. 選取檔案，拖放到 Xcode 對應的群組中
3. 在彈出視窗中，確認：
   - ✅ **Copy items if needed**
   - ✅ **Create groups**
   - ✅ **Add to targets: TaipeiLeftTurnAlert**

**方法 2：File > Add Files**
1. 右鍵點擊群組
2. 選擇「Add Files to "TaipeiLeftTurnAlert"...」
3. 選取檔案並加入

---

## ⚙️ 步驟 4：配置專案設定

### 4.1 General 設定

點擊專案根目錄 → **TARGETS** → **TaipeiLeftTurnAlert** → **General**：

| 設定項目 | 值 |
|---------|-----|
| **Display Name** | 台北市左轉提示 |
| **Bundle Identifier** | com.yourname.TaipeiLeftTurnAlert |
| **Version** | 1.0.0 |
| **Build** | 1 |
| **Minimum Deployments** | iOS 15.0 |
| **Supported Destinations** | iPhone（取消勾選 iPad 和 Mac） |
| **Supported Device Orientations** | Portrait（僅直向） |

### 4.2 Signing & Capabilities

#### 4.2.1 Signing

- **Automatically manage signing**: ✅ 勾選
- **Team**: 選擇您的開發團隊
- **Provisioning Profile**: Xcode Managed Profile

#### 4.2.2 加入 Capabilities

點擊「+ Capability」，加入以下功能：

1. **Background Modes**
   - ✅ Location updates
   - ✅ Audio, AirPlay, and Picture in Picture

這樣 App 就能在背景持續追蹤位置並播放語音。

### 4.3 Info 設定

點擊 **Info** 標籤，確認以下項目：

#### 必要的隱私權說明

| Key | Value |
|-----|-------|
| **Privacy - Location Always and When In Use Usage Description** | 需要持續存取您的位置，以便在接近可直接左轉路口時提供即時語音提示。 |
| **Privacy - Location Always Usage Description** | 需要持續存取您的位置，以便在接近可直接左轉路口時提供即時語音提示。 |
| **Privacy - Location When In Use Usage Description** | 需要存取您的位置，以便在地圖上顯示您的當前位置。 |

**注意**: 如果您使用了 `Info.plist` 檔案，這些設定應該已經包含在內。

### 4.4 Build Settings

點擊 **Build Settings** 標籤：

1. 搜尋「Swift Language Version」
   - 設定為 **Swift 5** 或更新版本

2. 搜尋「iOS Deployment Target」
   - 設定為 **15.0**

---

## 🗂️ 步驟 5：驗證資源檔案

### 5.1 確認 intersections.json

1. 在專案導航器中找到 `intersections.json`
2. 點擊檔案
3. 在右側面板的「Target Membership」中
4. 確認 ✅ **TaipeiLeftTurnAlert** 已勾選

### 5.2 確認檔案內容

點擊 `intersections.json`，確認內容為 121 個路口的 JSON 陣列：

```json
[
  {
    "id": 1,
    "district": "中正",
    "intersection": "...",
    "direction": "...",
    ...
  },
  ...
]
```

---

## 🔨 步驟 6：建置專案

### 6.1 選擇模擬器

1. 點擊頂部工具列的裝置選擇器
2. 選擇 **iPhone 15** 或任何 iPhone 模擬器

### 6.2 建置

1. 按 **⌘+B**（Command + B）進行建置
2. 等待建置完成
3. 檢查是否有錯誤

### 6.3 常見建置錯誤與解決方法

#### 錯誤 1: "No such module 'MapKit'"
**解決**: MapKit 是系統框架，不需手動加入。如果出現此錯誤，請清理建置（⌘+Shift+K）後重新建置。

#### 錯誤 2: "Cannot find 'IntersectionDataService' in scope"
**解決**: 確認所有 Swift 檔案都已正確加入專案，且在「Target Membership」中有勾選 TaipeiLeftTurnAlert。

#### 錯誤 3: "Value of type 'some View' has no member 'foregroundColor'"
**解決**: 請確認您的 Xcode 版本為 15.0 或更新版本。

---

## 📱 步驟 7：在模擬器上測試

### 7.1 執行 App

1. 按 **⌘+R**（Command + R）執行
2. 等待模擬器啟動
3. App 應該會顯示三個 Tab：地圖、監控、設定

### 7.2 測試功能

#### 測試 1：地圖頁面
- ✅ 地圖正常顯示
- ✅ 可以看到台北市區域
- ⚠️ 路口標記可能不會顯示（需要資料載入）

#### 測試 2：監控頁面
- ✅ 顯示「位置權限：未決定」
- ✅ 可以點擊「請求位置權限」
- ✅ 點擊後會彈出權限請求對話框

#### 測試 3：設定頁面
- ✅ 可以開關語音
- ✅ 可以調整滑桿
- ✅ 點擊「測試語音」會輸出 console 訊息
- ⚠️ 模擬器可能無法播放語音（正常現象）

---

## 📲 步驟 8：在真機上測試

### 8.1 連接 iPhone

1. 使用 USB 線連接 iPhone 到 Mac
2. 在 iPhone 上信任此電腦

### 8.2 選擇裝置

1. 在 Xcode 頂部工具列
2. 點擊裝置選擇器
3. 選擇您的 iPhone

### 8.3 執行

1. 按 **⌘+R** 執行
2. 首次執行可能需要在 iPhone 上信任開發者：
   - 前往 **設定 > 一般 > VPN 與裝置管理**
   - 點擊您的開發者帳號
   - 點擊「信任」

### 8.4 完整測試

參考 [IPHONE_TESTING_GUIDE.md](../docs/IPHONE_TESTING_GUIDE.md) 進行完整測試。

---

## 🐛 疑難排解

### 問題 1：編譯錯誤 "Cycle in dependencies"

**原因**: 檔案重複加入或循環依賴

**解決**:
1. 點擊專案根目錄
2. 選擇 **TARGETS** → **Build Phases**
3. 展開「Compile Sources」
4. 檢查是否有重複的檔案，移除重複項

### 問題 2：App 閃退

**原因**: 可能是 `intersections.json` 未正確載入

**解決**:
1. 確認 `intersections.json` 在專案中
2. 確認檔案的「Target Membership」已勾選
3. 檢查 console 輸出是否有「找不到資料檔案」的錯誤

### 問題 3：位置權限無法請求

**原因**: Info.plist 缺少必要的隱私權說明

**解決**:
1. 檢查 Info.plist 是否包含所有位置權限說明
2. 如果遺漏，手動加入（參考步驟 4.3）

---

## ✅ 檢查清單

建立專案前，請確認以下項目：

- [ ] Xcode 15.0 或更新版本已安裝
- [ ] 已準備好 Apple 開發者帳號
- [ ] 已下載所有原始碼檔案

建立專案後，請確認：

- [ ] 所有 Swift 檔案已加入專案
- [ ] `intersections.json` 已正確加入
- [ ] Info.plist 包含所有必要的權限說明
- [ ] Background Modes 已啟用（Location updates + Audio）
- [ ] 專案可以成功建置（⌘+B）
- [ ] 在模擬器上可以執行
- [ ] 三個 Tab 都可以正常切換

準備真機測試：

- [ ] iPhone 已連接並信任
- [ ] 在真機上成功執行
- [ ] 位置權限可以正常請求
- [ ] 語音測試可以播放聲音

---

## 📚 相關文件

- [iPhone 測試指南](../docs/IPHONE_TESTING_GUIDE.md)
- [整合測試檢查清單](./INTEGRATION_CHECKLIST.md)
- [技術研究報告](./RESEARCH_REPORT.md)

---

## 💡 小提示

### 提示 1：使用 Git 版本控制

建議將專案加入 Git 版本控制：

```bash
cd /path/to/TaipeiLeftTurnAlert
git init
git add .
git commit -m "初始化 Xcode 專案"
```

### 提示 2：定期備份

定期備份您的專案，特別是在進行重大變更前。

### 提示 3：使用 Xcode 的 Organizer

**Window > Organizer** 可以管理您的 Archives 和 App 版本。

---

**完成！** 🎉

您的 Xcode 專案已經設定完成，可以開始進行開發和測試了！

如有任何問題，請參考：
- [Apple Developer Documentation](https://developer.apple.com/documentation/)
- [SwiftUI Tutorials](https://developer.apple.com/tutorials/swiftui)
