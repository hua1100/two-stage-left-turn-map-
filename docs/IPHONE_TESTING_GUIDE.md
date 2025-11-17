# iPhone 測試原型程式碼完整指南

**適用對象**：沒有 iOS 開發經驗的使用者
**目標**：在實體 iPhone 上測試台北市機車直接左轉語音提示原型程式碼
**預估時間**：首次設定約 30-45 分鐘，之後每次測試約 5-10 分鐘

---

## 📋 目錄

1. [準備工作](#準備工作)
2. [安裝 Xcode](#安裝-xcode)
3. [建立 iOS 專案](#建立-ios-專案)
4. [加入原型程式碼](#加入原型程式碼)
5. [設定權限與功能](#設定權限與功能)
6. [連接 iPhone 並安裝](#連接-iphone-並安裝)
7. [執行測試](#執行測試)
8. [常見問題](#常見問題)

---

## 準備工作

### 必要設備與軟體

| 項目 | 需求 | 備註 |
|------|------|------|
| **Mac 電腦** | macOS 13.0+ | 必須是 Mac，Windows 無法開發 iOS |
| **iPhone** | iOS 15.0+ | 實體裝置，模擬器測試效果不佳 |
| **Lightning/USB-C 傳輸線** | - | 用於連接 iPhone 到 Mac |
| **Apple ID** | 免費帳號即可 | 用於開發者簽章 |
| **硬碟空間** | 至少 15GB | Xcode 檔案較大 |

### 檢查清單

- [ ] Mac 電腦已更新到最新版本
- [ ] 有可用的 Apple ID
- [ ] iPhone 已充電且開啟
- [ ] 傳輸線可正常使用

---

## 安裝 Xcode

### 步驟 1：從 App Store 安裝

1. 開啟 Mac 上的 **App Store**
2. 搜尋「**Xcode**」
3. 點擊「**取得**」或「**下載**」按鈕
4. 等待下載完成（檔案約 12-15GB，需時 10-60 分鐘視網速而定）

![Xcode App Store](https://developer.apple.com/assets/elements/icons/xcode-12/xcode-12-96x96_2x.png)

### 步驟 2：首次啟動 Xcode

1. 下載完成後，開啟「**應用程式**」資料夾
2. 雙擊「**Xcode**」圖示
3. 同意授權條款
4. 等待安裝額外元件（約 5-10 分鐘）

### 步驟 3：安裝 Command Line Tools

在終端機（Terminal）中執行：

```bash
xcode-select --install
```

點擊「**安裝**」並等待完成。

---

## 建立 iOS 專案

### 步驟 1：建立新專案

1. 開啟 **Xcode**
2. 點擊「**Create a new Xcode project**」或選擇「File > New > Project」
3. 選擇「**iOS**」標籤頁
4. 選擇「**App**」範本
5. 點擊「**Next**」

![新專案範本](https://docs-assets.developer.apple.com/published/2c7e2f4e5c/rendered2x-1646940603.png)

### 步驟 2：設定專案資訊

填寫以下資訊：

| 欄位 | 填入內容 |
|------|---------|
| **Product Name** | `TaipeiLeftTurnAlert` |
| **Team** | 選擇您的 Apple ID（若無，點擊「Add Account」新增） |
| **Organization Identifier** | `com.yourname`（可自訂，例如：`com.john`） |
| **Interface** | `SwiftUI` |
| **Language** | `Swift` |
| **Storage** | `None` |

**取消勾選**：
- [ ] Use Core Data
- [ ] Include Tests

點擊「**Next**」，選擇儲存位置（建議放在「文件」資料夾），點擊「**Create**」。

### 步驟 3：設定專案僅支援 iOS

**重要**：專案預設可能支援多平台，需要限制為僅支援 iOS。

1. 在左側檔案清單中，點擊最上方的「**TaipeiLeftTurnAlert**」（藍色專案圖示）
2. 在「**TARGETS**」區域，選擇「**TaipeiLeftTurnAlert**」
3. 選擇「**General**」標籤頁
4. 在「**Deployment Info**」區域：
   - 確認「**Supported Destinations**」只有「**iPhone**」被勾選
   - 如果有「Mac」或其他選項被勾選，請取消勾選
5. 在「**Minimum Deployments**」設定為「**iOS 15.0**」

---

## 加入原型程式碼

### 步驟 1：了解專案結構

建立完成後，您會看到左側的檔案清單：

```
TaipeiLeftTurnAlert/
├── TaipeiLeftTurnAlertApp.swift   # App 入口
├── ContentView.swift               # 主畫面
└── Assets.xcassets                 # 圖片資源
```

### 步驟 2：建立資料夾結構

在左側檔案清單中：

1. **右鍵點擊** `TaipeiLeftTurnAlert` 資料夾
2. 選擇「**New Group**」
3. 建立以下資料夾：
   - `Models`
   - `Services`
   - `Resources`

### 步驟 3：加入原型程式碼檔案

#### 3.1 加入 Models

1. 在 Finder 中開啟專案目錄：
   ```
   two-stage-left-turn-map-/ios-prototype/TaipeiLeftTurnAlert/Models/
   ```

2. 將 `Intersection.swift` 拖曳到 Xcode 的 `Models` 資料夾中

3. 在彈出視窗中確認：
   - [x] **Copy items if needed**（勾選）
   - [x] **Create groups**（選擇）
   - [x] **Add to targets: TaipeiLeftTurnAlert**（勾選）

4. 點擊「**Finish**」

#### 3.2 加入 Services

重複上述步驟，將以下三個檔案加入 `Services` 資料夾：
- `DirectionMatcher.swift`
- `VoiceAlertService.swift`
- `LocationService.swift`

#### 3.3 加入測試資料

將 `Resources/intersections.json` 加入 `Resources` 資料夾。

### 步驟 4：建立測試介面

1. 開啟 `ContentView.swift`
2. 刪除所有內容，貼上以下程式碼：

```swift
import SwiftUI
import CoreLocation

struct ContentView: View {
    @StateObject private var locationService = LocationService()
    @State private var isMonitoring = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // 標題
                Text("台北市機車直接左轉語音提示")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding()

                // 狀態顯示
                VStack(alignment: .leading, spacing: 10) {
                    StatusRow(title: "監控狀態", value: isMonitoring ? "🟢 運行中" : "⚪️ 已停止")
                    StatusRow(title: "位置權限", value: authorizationStatusText)

                    if let location = locationService.currentLocation {
                        StatusRow(title: "當前位置", value: String(format: "%.6f, %.6f", location.coordinate.latitude, location.coordinate.longitude))
                        StatusRow(title: "當前方向", value: "\(Int(locationService.currentCourse))°")
                        StatusRow(title: "定位精度", value: "\(Int(location.horizontalAccuracy))m")
                    } else {
                        StatusRow(title: "當前位置", value: "等待定位...")
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)

                Spacer()

                // 控制按鈕
                VStack(spacing: 15) {
                    if locationService.authorizationStatus == .notDetermined {
                        Button(action: {
                            locationService.requestAuthorization()
                        }) {
                            Label("請求位置權限", systemImage: "location.circle")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }

                    Button(action: {
                        if isMonitoring {
                            locationService.stopMonitoring()
                            isMonitoring = false
                        } else {
                            loadTestData()
                            locationService.startMonitoring()
                            isMonitoring = true
                        }
                    }) {
                        Label(isMonitoring ? "停止監控" : "開始監控",
                              systemImage: isMonitoring ? "stop.circle" : "play.circle")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isMonitoring ? Color.red : Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(locationService.authorizationStatus != .authorizedAlways &&
                             locationService.authorizationStatus != .authorizedWhenInUse)
                }
                .padding()
            }
            .navigationTitle("左轉提示測試")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var authorizationStatusText: String {
        switch locationService.authorizationStatus {
        case .notDetermined: return "❓ 未決定"
        case .restricted: return "🚫 受限"
        case .denied: return "❌ 拒絕"
        case .authorizedAlways: return "✅ 始終允許"
        case .authorizedWhenInUse: return "⚠️ 使用期間"
        @unknown default: return "❓ 未知"
        }
    }

    private func loadTestData() {
        // 載入測試資料
        guard let url = Bundle.main.url(forResource: "intersections", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let intersections = try? JSONDecoder().decode([Intersection].self, from: data) else {
            print("❌ 無法載入測試資料")
            return
        }

        locationService.loadIntersections(intersections)
        print("✅ 已載入 \(intersections.count) 個路口")
    }
}

struct StatusRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .fontWeight(.medium)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
```

---

## 設定權限與功能

### 步驟 1：設定 Info.plist 權限說明

1. 在左側檔案清單中，點擊最上方的「**TaipeiLeftTurnAlert**」（藍色圖示）
2. 選擇「**Info**」標籤頁
3. 在「**Custom iOS Target Properties**」區域，點擊「**+**」按鈕
4. 加入以下三個權限說明：

| Key | Type | Value |
|-----|------|-------|
| `Privacy - Location When In Use Usage Description` | String | `需要您的位置資訊以提供附近可直接左轉路口的語音提示` |
| `Privacy - Location Always and When In Use Usage Description` | String | `需要背景位置權限以在導航時持續監控路口並提供語音提示` |
| `Privacy - Location Always Usage Description` | String | `需要始終存取位置以在背景提供路口語音提示` |

### 步驟 2：啟用背景模式

1. 選擇「**Signing & Capabilities**」標籤頁
2. 點擊「**+ Capability**」按鈕
3. 搜尋並雙擊「**Background Modes**」
4. 勾選：
   - [x] **Location updates**

### 步驟 3：設定開發者簽章

1. 在「**Signing & Capabilities**」標籤頁
2. 確認「**Automatically manage signing**」已勾選
3. 在「**Team**」下拉選單中選擇您的 Apple ID
4. 如果看到錯誤，點擊「**Add Account**」新增 Apple ID

---

## 連接 iPhone 並安裝

### 步驟 1：準備 iPhone

1. 使用傳輸線連接 iPhone 到 Mac
2. 在 iPhone 上點擊「**信任此電腦**」
3. 輸入 iPhone 密碼

### 步驟 2：在 Xcode 中選擇裝置

1. 在 Xcode 上方工具列，點擊裝置選擇器（預設顯示「Any iOS Device」）
2. 選擇您的 iPhone（例如：「John 的 iPhone」）

### 步驟 3：建置並執行

1. 點擊左上角的「▶️ **Play**」按鈕（或按 ⌘+R）
2. 等待建置完成（首次約 1-2 分鐘）
3. 如果出現「**Developer Mode Required**」：
   - 在 iPhone 上前往「設定 > 隱私權與安全性 > 開發者模式」
   - 開啟「開發者模式」
   - 重新啟動 iPhone
   - 重新執行步驟 3

### 步驟 4：信任開發者憑證

首次安裝會出現錯誤，需要在 iPhone 上信任憑證：

1. 在 iPhone 上前往「**設定 > 一般 > VPN 與裝置管理**」
2. 點擊您的 Apple ID
3. 點擊「**信任 "您的 Apple ID"**」
4. 確認信任

### 步驟 5：重新執行

回到 Xcode，再次點擊「▶️ **Play**」按鈕，App 應該會成功啟動。

---

## 執行測試

### 測試 1：室內基本功能測試

**目的**：驗證 App 基本功能正常

1. **啟動 App**
2. **點擊「請求位置權限」**
   - 選擇「**使用 App 期間允許**」或「**始終允許**」（建議）
3. **等待定位成功**
   - 確認畫面顯示當前位置座標
4. **點擊「開始監控」**
   - 確認狀態變為「🟢 運行中」
5. **切換到其他 App（如 Safari）**
   - App 應該在背景繼續運行
6. **回到 App，點擊「停止監控」**

**預期結果**：
- ✅ 位置權限請求成功
- ✅ 能取得當前位置
- ✅ 監控可正常啟動與停止

### 測試 2：語音功能測試（室內）

**目的**：驗證繁體中文語音合成

1. 開啟 Xcode
2. 開啟 `VoiceAlertServiceTests.swift`
3. 在 `testChineseVoiceQuality()` 函數中加入斷點
4. 執行測試（⌘+U）
5. 聽取語音品質

**預期結果**：
- ✅ 語音清晰可聽
- ✅ 繁體中文發音正確
- ✅ 路名發音自然

### 測試 3：實地路測（需要機車）

**⚠️ 安全警告**：
- 請在允許測試的安全道路上進行
- 建議由副駕駛或乘客操作裝置
- 遵守交通規則，安全第一

**目的**：驗證真實環境下的語音警示

1. **開啟 Google Maps 導航**
   - 設定目的地，經過測試路口
   - 開始導航

2. **切換到測試 App**
   - 點擊「開始監控」
   - 切回 Google Maps

3. **騎車經過測試路口**
   - 測試路口建議：
     - 承德路與市民大道（大同區）- ID: 1
     - 研究院路與南港路二段（南港區）- ID: 2
     - 復興南路與和平東路（大安區）- ID: 3

4. **驗證警示功能**

**預期結果**：
- ✅ 接近路口 150m 內觸發語音
- ✅ 語音內容正確（如：「前方承德路與市民大道可直接左轉」）
- ✅ 語音不會中斷 Google Maps 導航
- ✅ 警示語音播放時，導航語音音量降低
- ✅ 警示結束後，導航語音恢復正常

### 測試 4：電池消耗測試（選用）

**目的**：測量背景監控的電池消耗

1. **充滿電**並記錄電量（100%）
2. **開啟監控**並開始計時
3. **進行 1 小時導航**（建議搭配 Google Maps）
4. **記錄結束電量**

**計算方式**：
```
電池消耗 = 起始電量 - 結束電量
每小時消耗 = 電池消耗 / (測試時長/60)
```

**目標**：每小時消耗 < 5%

---

## 常見問題

### Q0: 編譯錯誤：「XXX is unavailable in macOS」

**問題描述**：
出現多個錯誤訊息如：
- `'AVAudioSession' is unavailable in macOS`
- `'showsBackgroundLocationIndicator' is unavailable in macOS`
- `'authorizedWhenInUse' is unavailable in macOS`

**原因**：
Xcode 專案預設支援多平台（iOS + macOS），但本專案使用了僅限 iOS 的 API。

**解決方案**：
1. 在左側檔案清單，點擊最上方的「**TaipeiLeftTurnAlert**」（藍色專案圖示）
2. 在「**TARGETS**」區域，選擇「**TaipeiLeftTurnAlert**」
3. 選擇「**General**」標籤頁
4. 在「**Deployment Info > Supported Destinations**」：
   - ✅ 確認只勾選「**iPhone**」
   - ❌ 取消勾選「**Mac**」或其他平台
5. 清理專案：Product > Clean Build Folder（⌘+Shift+K）
6. 重新建置：Product > Build（⌘+B）

### Q1: Xcode 無法在 iPhone 上執行，顯示「Developer Mode Required」

**解決方案**：
1. 在 iPhone 上前往「設定 > 隱私權與安全性」
2. 啟用「開發者模式」
3. 重新啟動 iPhone
4. 重新執行 App

### Q2: 顯示「Untrusted Developer」錯誤

**解決方案**：
1. 前往 iPhone 的「設定 > 一般 > VPN 與裝置管理」
2. 找到您的 Apple ID
3. 點擊「信任」

### Q3: App 執行後立即閃退

**可能原因**：
1. 沒有設定 Info.plist 權限說明
2. 程式碼有錯誤

**解決方案**：
1. 檢查是否已加入三個位置權限說明
2. 在 Xcode 查看錯誤訊息（View > Debug Area > Show Debug Area）

### Q4: 沒有聽到語音警示

**檢查項目**：
1. iPhone 是否處於靜音模式？（檢查側邊開關）
2. 音量是否太小？（調高音量）
3. 是否太遠離測試路口？（需在 150m 內）
4. 行駛方向是否正確？（需符合允許方向）

### Q5: 背景監控沒有運作

**檢查項目**：
1. 位置權限是否為「始終允許」？
2. 是否已啟用 Background Modes > Location updates？
3. 是否在 iOS 設定中關閉了背景 App 重新整理？

---

## 測試記錄表

建議在測試時填寫以下記錄表：

| 測試項目 | 日期/時間 | 結果 | 備註 |
|---------|----------|------|------|
| 基本功能 | ____/____ __:__ | ⬜ 通過 ⬜ 失敗 | |
| 語音品質 | ____/____ __:__ | ⬜ 通過 ⬜ 失敗 | |
| 路測 - 路口 1 | ____/____ __:__ | ⬜ 通過 ⬜ 失敗 | |
| 路測 - 路口 2 | ____/____ __:__ | ⬜ 通過 ⬜ 失敗 | |
| 路測 - 路口 3 | ____/____ __:__ | ⬜ 通過 ⬜ 失敗 | |
| 電池消耗 | ____/____ __:__ | ___% / 小時 | |

---

## 進階設定（選用）

### 調整警示參數

如果需要調整警示距離或方向匹配精度，修改 `LocationService.swift`：

```swift
// 在 init 方法中
self.directionMatcher = DirectionMatcher(
    tolerance: 30.0,        // 方向匹配誤差（度）
    alertDistance: 150.0    // 警示距離（公尺）
)
```

### 調整語音參數

修改 `VoiceAlertService.swift`：

```swift
var speechRate: Float = 0.5  // 語速 (0.0-1.0)
var volume: Float = 1.0      // 音量 (0.0-1.0)
```

---

## 取得協助

如果測試過程中遇到問題：

1. **查看 Xcode Console 日誌**
   - View > Debug Area > Activate Console
   - 尋找 ❌ 或 ⚠️ 標記的錯誤訊息

2. **截圖錯誤訊息**
   - 截取 Xcode 錯誤畫面
   - 截取 iPhone 畫面

3. **記錄測試環境**
   - Mac 作業系統版本
   - Xcode 版本
   - iPhone 型號與 iOS 版本
   - 測試時間、地點、路口

---

**祝測試順利！** 🚀

如有任何問題，請隨時提出。
