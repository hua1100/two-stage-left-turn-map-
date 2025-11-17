# 功能規格：機車直接左轉路口語音提示 iOS App

**功能分支**: `002-ios-voice-alert-app`
**建立日期**: 2025-11-17
**狀態**: 草稿
**平台**: iOS 15.0+
**語言**: Swift 5.9+, SwiftUI

---

**⚠️ 語言要求 (來自專案憲章 Principle 1)**:
本文件必須使用繁體中文撰寫。唯一允許使用英文的文件是 `.specify/memory/constitution.md`。

---

## 專案背景

擴展「機車直接左轉路口地圖工具」，開發 iOS App 提供即時語音提示功能。當機車騎士接近可直接左轉的路口時，App 會主動發出語音提示，解決現有地圖圖層僅能「被動查看」的限制。

### 核心價值主張

**問題**: Google Maps / Apple Maps 的 KML 圖層只能顯示標記，無法在導航時主動提醒
**解決方案**: 背景監控位置，接近路口時自動語音提示
**使用場景**: 騎士使用 Google Maps 導航時，本 App 在背景執行並提供語音輔助

## 使用者情境與測試 *（必填）*

### 使用者故事 1 - 背景位置監控與語音提示 (優先級：P1) 🎯 MVP

身為一位機車騎士，我希望在使用 Google Maps 導航時，當接近可直接左轉的路口，手機能自動發出語音提示「前方 XXX 路口可直接左轉」，讓我不需要分心查看地圖就能知道路口資訊。

**此優先級的原因**: 這是 App 的核心價值，解決「KML 圖層無法主動提示」的核心問題。沒有此功能，App 就失去存在意義。

**獨立測試**: 可透過實際騎車測試，或在開發環境中模擬位置移動，驗證當距離路口 500 公尺時是否正確觸發語音提示。

**驗收情境**:

1. **Given** 使用者啟動 App 並授予位置權限，**When** 將 App 切換到背景並開始騎車，**Then** App 應持續在背景監控位置
2. **Given** 使用者距離「承德路與市民大道」路口 500 公尺，**When** 騎車接近該路口，**Then** 手機應發出語音：「前方承德路與市民大道路口可直接左轉，方向：北往東」
3. **Given** 使用者已經過該路口，**When** 繼續前進超過路口 100 公尺，**Then** 不應再次提示同一路口
4. **Given** 使用者在 5 分鐘內靠近同一路口兩次，**When** 第二次接近，**Then** 不應重複提示（避免打擾）
5. **Given** 使用者開啟靜音模式，**When** 接近路口，**Then** 應只震動提示，不發出語音
6. **Given** 使用者在設定中調整提醒距離為 300 公尺，**When** 距離路口 300 公尺時，**Then** 應觸發提示

---

### 使用者故事 2 - 地圖顯示與路口資訊 (優先級：P2)

身為一位機車騎士，我希望能在 App 中看到地圖上所有可直接左轉的路口標記，並能點擊查看詳細資訊（路口名稱、方向、開放時間），以便在出發前規劃路線。

**此優先級的原因**: 提供視覺化資訊，輔助語音提示功能，讓使用者能主動查詢路口位置。

**獨立測試**: 可在 App 中開啟地圖頁面，驗證是否顯示所有 121 個路口標記，並點擊標記查看詳細資訊。

**驗收情境**:

1. **Given** 使用者開啟 App 的地圖頁面，**When** 地圖載入完成，**Then** 應在台北市顯示 121 個路口的標記點
2. **Given** 使用者點擊地圖上的某個路口標記，**When** 彈出資訊卡片，**Then** 應顯示路口名稱、可左轉方向、開放時間、所屬分區
3. **Given** 使用者當前位置在台北市，**When** 開啟地圖頁面，**Then** 地圖應自動定位到使用者當前位置並顯示附近路口
4. **Given** 使用者搜尋「承德路」，**When** 輸入搜尋關鍵字，**Then** 應篩選並顯示包含「承德路」的路口
5. **Given** 使用者點擊路口資訊卡片中的「導航」按鈕，**When** 點擊後，**Then** 應開啟 Apple Maps 並導航到該路口

---

### 使用者故事 3 - 提示設定與個人化 (優先級：P3)

身為一位機車騎士，我希望能自訂提示的觸發距離、音量、語音速度等設定，以符合我的個人偏好和不同的騎乘情境。

**此優先級的原因**: 個人化設定提升使用體驗，但非核心功能，可在 MVP 後迭代加入。

**獨立測試**: 在設定頁面調整各項參數，驗證變更是否正確儲存並在下次提示時生效。

**驗收情境**:

1. **Given** 使用者在設定頁面，**When** 調整提醒距離為 300/500/700 公尺，**Then** 下次提示應在新設定的距離觸發
2. **Given** 使用者開啟「僅在導航時提示」選項，**When** 未使用導航騎車，**Then** 不應發出語音提示
3. **Given** 使用者調整語音速度為「快速」，**When** 觸發語音提示，**Then** 語音播放速度應加快
4. **Given** 使用者設定「安靜時段」為晚上 10 點至早上 7 點，**When** 在此時段接近路口，**Then** 應只震動不發出語音

---

### 邊界情況

- 當使用者位置訊號不穩定（GPS 漂移）時，如何避免誤觸發提示？
  - 建議：設定最小移動距離閾值（例如：10 公尺），過濾 GPS 雜訊

- 當使用者快速經過路口（例如：搭公車、搭捷運）時，如何避免不必要的提示？
  - 建議：偵測移動速度，超過 50 km/h 時暫停提示

- 當手機處於省電模式時，背景位置追蹤可能被限制，如何處理？
  - 建議：在 App 啟動時檢測省電模式，顯示警告提示使用者

- 當使用者在同一路口附近來回移動時，如何避免重複提示？
  - 建議：記錄已提示的路口 ID 與時間戳記，5 分鐘內不重複提示

- 當使用者未授予位置權限時，App 如何引導？
  - 建議：顯示友善的引導畫面，說明為何需要權限，並提供前往設定的快捷按鈕

## 需求 *（必填）*

### 功能需求

#### 核心功能（P1 - MVP）

- **FR-001**: App 必須能在背景持續監控使用者的位置（即使 App 被切換到背景）
- **FR-002**: App 必須能計算使用者與每個路口的距離，並在距離低於閾值時觸發提示
- **FR-003**: 系統必須支援可設定的提醒距離（預設 500 公尺，可調整為 300/500/700 公尺）
- **FR-004**: 系統必須在觸發提示時發出繁體中文語音，內容包含：
  - 路口名稱（例如：「承德路與市民大道」）
  - 可左轉方向（例如：「北往東」）
  - 完整語音範例：「前方承德路與市民大道路口可直接左轉，方向：北往東」
- **FR-005**: 系統必須支援靜音模式，在此模式下僅震動提示，不發出語音
- **FR-006**: 系統必須記錄已提示的路口，避免在短時間內（5 分鐘）重複提示同一路口
- **FR-007**: 系統必須在省電模式或位置權限受限時，向使用者顯示警告訊息
- **FR-008**: App 必須能在 iOS 背景模式下執行，使用 `Location Updates` 背景模式

#### 地圖顯示功能（P2）

- **FR-101**: App 必須提供地圖頁面，使用 MapKit 顯示台北市地圖
- **FR-102**: 地圖必須在載入時顯示所有 121 個直接左轉路口的標記（使用自訂圖示）
- **FR-103**: 使用者點擊地圖上的標記時，必須彈出資訊卡片顯示：
  - 路口名稱
  - 可左轉方向
  - 開放時間
  - 所屬分區
  - 「導航至此」按鈕
- **FR-104**: 地圖必須支援搜尋功能，使用者可透過路口名稱關鍵字搜尋
- **FR-105**: 地圖必須能定位到使用者當前位置（需位置權限）
- **FR-106**: 點擊「導航至此」按鈕時，必須開啟 Apple Maps 並設定該路口為目的地

#### 個人化設定（P3 - 可選）

- **FR-201**: App 必須提供設定頁面，允許使用者調整：
  - 提醒距離（300/500/700 公尺）
  - 語音速度（慢速/正常/快速）
  - 震動強度（關閉/弱/強）
- **FR-202**: 系統必須支援「僅在導航時提示」選項（偵測是否有其他導航 App 在執行）
- **FR-203**: 系統必須支援「安靜時段」設定，在指定時段僅震動不語音

### 非功能需求

- **NFR-001**: 背景位置追蹤必須節能，避免過度消耗電池
  - 目標：每小時電池消耗 < 5%
  - 實作：使用 `Significant Location Changes` 或 `Deferred Location Updates`

- **NFR-002**: 語音提示的延遲必須低於 2 秒（從觸發條件到語音播放）

- **NFR-003**: App 啟動時間必須 < 3 秒（從點擊圖示到主畫面顯示）

- **NFR-004**: 地圖載入與標記顯示必須 < 5 秒

- **NFR-005**: App 必須支援 iOS 15.0 或以上版本

- **NFR-006**: App 必須支援淺色與深色模式

- **NFR-007**: App 必須遵守 Apple 的隱私政策，明確說明位置資料的使用目的

- **NFR-008**: App 必須支援 iPhone SE（第二代）及以上機型的螢幕尺寸

### 關鍵實體 *（如功能涉及資料則包含）*

- **路口 (Intersection)**: 代表一個可直接左轉的路口
  - 屬性：id, 路口名稱, 經度, 緯度, 分區, 可左轉方向, 開放時間
  - 方法：計算與使用者的距離, 產生語音文字

- **使用者位置 (UserLocation)**: 使用者的當前位置與移動狀態
  - 屬性：經度, 緯度, 精度, 速度, 時間戳記
  - 方法：計算與路口的距離, 判斷是否在移動

- **提示記錄 (AlertHistory)**: 記錄已發出的提示
  - 屬性：路口 ID, 提示時間, 使用者位置
  - 方法：檢查是否已在 N 分鐘內提示過

- **使用者設定 (UserSettings)**: 使用者的個人化設定
  - 屬性：提醒距離, 語音速度, 震動強度, 靜音模式, 安靜時段
  - 方法：載入設定, 儲存設定

## 技術規格

### 開發環境

- **IDE**: Xcode 15.0+
- **語言**: Swift 5.9+
- **UI 框架**: SwiftUI
- **最低支援版本**: iOS 15.0
- **目標設備**: iPhone（不含 iPad）

### 技術棧

#### 核心框架

- **CoreLocation**: 位置追蹤與地理計算
  - `CLLocationManager`: 位置管理器
  - `CLLocationManagerDelegate`: 位置更新代理
  - 背景模式：`Location Updates`

- **AVFoundation**: 語音合成
  - `AVSpeechSynthesizer`: 文字轉語音
  - `AVSpeechUtterance`: 語音內容設定
  - 語言設定：`zh-TW`（繁體中文）

- **MapKit**: 地圖顯示
  - `MKMapView`: 地圖視圖
  - `MKAnnotation`: 路口標記
  - `MKUserLocation`: 使用者位置

- **UserNotifications**: 本地通知（當 App 在背景時）
  - `UNUserNotificationCenter`: 通知管理
  - `UNMutableNotificationContent`: 通知內容

#### 資料儲存

- **UserDefaults**: 使用者設定儲存
  - 提醒距離、語音速度等設定

- **Core Data** 或 **SwiftData**: 路口資料與提示歷史
  - 路口清單（121 個路口）
  - 提示歷史記錄

- **Bundle Resources**: 預載路口資料
  - 將 `intersections_geocoded.json` 打包進 App Bundle

#### 架構模式

- **MVVM (Model-View-ViewModel)**:
  - Model: Intersection, UserLocation, AlertHistory, UserSettings
  - View: SwiftUI Views
  - ViewModel: LocationViewModel, MapViewModel, SettingsViewModel

- **依賴注入**: 使用 `@EnvironmentObject` 或 `@StateObject`

### 資料模型

#### Intersection Model

```swift
struct Intersection: Identifiable, Codable {
    let id: Int
    let district: String
    let intersection: String
    let direction: String
    let openedYear: String
    let latitude: Double
    let longitude: Double

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    func distance(from location: CLLocation) -> CLLocationDistance {
        let intersectionLocation = CLLocation(
            latitude: latitude,
            longitude: longitude
        )
        return location.distance(from: intersectionLocation)
    }

    func speechText() -> String {
        "前方\(intersection)路口可直接左轉，方向：\(direction)"
    }
}
```

#### UserSettings Model

```swift
struct UserSettings: Codable {
    var alertDistance: Double = 500.0  // 提醒距離（公尺）
    var speechRate: Float = 0.5        // 語音速度（0.0-1.0）
    var vibrationEnabled: Bool = true  // 震動開關
    var silentMode: Bool = false       // 靜音模式
    var quietHoursEnabled: Bool = false
    var quietHoursStart: Date = Date()
    var quietHoursEnd: Date = Date()
}
```

#### AlertHistory Model

```swift
struct AlertHistory: Identifiable, Codable {
    let id: UUID
    let intersectionId: Int
    let timestamp: Date
    let userLatitude: Double
    let userLongitude: Double

    func shouldSkip(for intersectionId: Int, cooldownMinutes: Int = 5) -> Bool {
        guard self.intersectionId == intersectionId else { return false }
        let elapsed = Date().timeIntervalSince(timestamp)
        return elapsed < Double(cooldownMinutes * 60)
    }
}
```

### 背景位置追蹤策略

#### 權限要求

```xml
<!-- Info.plist -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>我們需要您的位置以提示附近的直接左轉路口</string>

<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>即使 App 在背景執行，我們也需要持續追蹤位置以即時提示路口資訊</string>

<key>UIBackgroundModes</key>
<array>
    <string>location</string>
</array>
```

#### 位置管理器配置

```swift
class LocationViewModel: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()

    override init() {
        super.init()
        locationManager.delegate = self

        // 精度設定（平衡精度與省電）
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters

        // 最小更新距離（移動至少 10 公尺才更新）
        locationManager.distanceFilter = 10

        // 背景模式
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false

        // 請求權限
        locationManager.requestAlwaysAuthorization()
    }

    func startMonitoring() {
        locationManager.startUpdatingLocation()
    }
}
```

#### 省電策略

1. **使用 Deferred Location Updates**（在直路上延遲更新）
2. **動態調整精度**（靠近路口時提高精度）
3. **速度過濾**（高速移動時降低更新頻率）

### 語音提示系統

#### 語音合成配置

```swift
class SpeechService {
    private let synthesizer = AVSpeechSynthesizer()

    func speak(_ text: String, rate: Float = 0.5) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "zh-TW")
        utterance.rate = rate  // 0.0 (慢) to 1.0 (快)
        utterance.volume = 1.0

        // 設定音訊 session（確保語音不被其他音訊打斷）
        try? AVAudioSession.sharedInstance().setCategory(
            .playback,
            mode: .voicePrompt,
            options: [.duckOthers]  // 降低其他音訊音量
        )
        try? AVAudioSession.sharedInstance().setActive(true)

        synthesizer.speak(utterance)
    }
}
```

#### 觸發邏輯

```swift
func checkAndAlert(userLocation: CLLocation) {
    let settings = UserSettings.load()

    for intersection in intersections {
        let distance = intersection.distance(from: userLocation)

        // 檢查距離
        guard distance <= settings.alertDistance else { continue }

        // 檢查是否已提示過
        if alertHistory.contains(where: { $0.shouldSkip(for: intersection.id) }) {
            continue
        }

        // 觸發提示
        triggerAlert(for: intersection, at: userLocation)
    }
}

func triggerAlert(for intersection: Intersection, at location: CLLocation) {
    // 記錄提示歷史
    let history = AlertHistory(
        id: UUID(),
        intersectionId: intersection.id,
        timestamp: Date(),
        userLatitude: location.coordinate.latitude,
        userLongitude: location.coordinate.longitude
    )
    alertHistory.append(history)

    // 發出語音
    if !settings.silentMode {
        speechService.speak(intersection.speechText(), rate: settings.speechRate)
    }

    // 震動
    if settings.vibrationEnabled {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    // 發送通知（如果 App 在背景）
    if UIApplication.shared.applicationState == .background {
        sendLocalNotification(for: intersection)
    }
}
```

## UI/UX 設計

### 頁面結構

#### 1. 主頁面（Home）

**佈局**:
```
┌─────────────────────────┐
│    [機車直左通]         │
│                         │
│   ┌─────────────────┐   │
│   │   🚦 監控中      │   │
│   │                 │   │
│   │   附近有 3 個   │   │
│   │   可左轉路口    │   │
│   └─────────────────┘   │
│                         │
│   [開始監控] 按鈕       │
│   [停止監控] 按鈕       │
│                         │
│   最近提示:            │
│   • 承德路與市民大道    │
│     (5 分鐘前)         │
│                         │
│   [地圖] [設定] 按鈕   │
└─────────────────────────┘
```

**功能**:
- 顯示監控狀態（監控中/已停止）
- 顯示附近路口數量
- 顯示最近的提示記錄
- 快速開始/停止監控

#### 2. 地圖頁面（Map）

**佈局**:
```
┌─────────────────────────┐
│  [< 返回]    [搜尋 🔍] │
├─────────────────────────┤
│                         │
│      🗺️ 地圖視圖       │
│                         │
│   📍 路口標記 x 121     │
│   📱 使用者位置         │
│                         │
│  ┌───────────────────┐  │
│  │ 路口資訊卡片       │  │
│  │ 承德路與市民大道   │  │
│  │ 方向: 北往東       │  │
│  │ [導航至此]        │  │
│  └───────────────────┘  │
└─────────────────────────┘
```

**功能**:
- 顯示所有 121 個路口標記
- 點擊標記顯示詳細資訊
- 搜尋路口
- 定位到使用者當前位置
- 導航至選定路口

#### 3. 設定頁面（Settings）

**佈局**:
```
┌─────────────────────────┐
│  [< 返回]    設定        │
├─────────────────────────┤
│                         │
│  提醒距離               │
│  ○ 300公尺              │
│  ● 500公尺 (預設)       │
│  ○ 700公尺              │
│                         │
│  語音設定               │
│  語音速度: [滑桿]       │
│  ☑ 靜音模式             │
│  ☑ 震動提示             │
│                         │
│  進階設定               │
│  ☐ 僅在導航時提示       │
│  ☐ 安靜時段             │
│     22:00 - 07:00       │
│                         │
│  關於                   │
│  App 版本: 1.0.0        │
│  資料版本: 114.04       │
│  [隱私政策]             │
└─────────────────────────┘
```

### 配色方案

- **主色**: #4CAF50（綠色，代表「可通行」）
- **輔色**: #2196F3（藍色，地圖與導航）
- **警示色**: #FF9800（橘色，提示通知）
- **背景色**:
  - 淺色模式: #FFFFFF
  - 深色模式: #121212

### 圖示設計

- **路口標記**: 綠色圓形圖示，內有左轉箭頭
- **使用者位置**: 藍色脈衝圓點
- **App 圖示**: 綠底白色左轉箭頭 + 機車剪影

## 隱私與權限

### 位置權限說明

**首次啟動時的引導流程**:

1. **歡迎頁面**:
   ```
   歡迎使用機車直左通！

   本 App 幫助您在騎車時
   即時提醒可直接左轉的路口

   [開始使用]
   ```

2. **權限說明頁面**:
   ```
   為什麼需要位置權限？

   🚦 即時提醒
   當您接近可左轉路口時發出語音提示

   🗺️ 顯示附近路口
   在地圖上查看所有直接左轉路口

   📍 背景監控
   即使切換到其他 App 也能持續提醒

   您的位置資料僅儲存在本機
   不會上傳到任何伺服器

   [授予位置權限]
   ```

3. **系統權限彈窗**:
   ```
   "機車直左通" 想要使用您的位置

   ○ 僅在使用 App 時
   ● 永遠 (建議)
   ○ 不允許
   ```

### 隱私政策要點

- ✅ **本地處理**: 所有位置計算在本機完成
- ✅ **不上傳資料**: 不將使用者位置傳送到任何伺服器
- ✅ **最小化收集**: 僅收集位置座標，不收集其他個人資訊
- ✅ **透明化**: 在 App 中清楚說明位置資料的使用目的
- ✅ **使用者控制**: 使用者可隨時關閉監控或撤銷權限

## 成功標準 *（必填）*

### 可衡量結果

- **SC-001**: App 能在背景持續執行至少 2 小時而不被系統終止
- **SC-002**: 從接近路口（500公尺）到發出語音提示的延遲 < 2 秒
- **SC-003**: 語音提示的文字轉語音品質清晰，至少 90% 的路口名稱能正確發音
- **SC-004**: 背景模式下每小時電池消耗 < 5%（在 iPhone 13 Pro 上測試）
- **SC-005**: 地圖載入時間 < 5 秒，所有 121 個標記正確顯示
- **SC-006**: 實際道路測試中，至少 95% 的路口提示觸發正確（無漏報、無誤報）
- **SC-007**: App 通過 TestFlight Beta 測試，至少 10 位測試者給予正面回饋
- **SC-008**: App 通過 Apple App Review 審核，成功上架 App Store

### 測試場景

**場景 1: 背景監控測試**
- 啟動 App 並開始監控
- 切換到 Google Maps 進行導航
- 騎車經過至少 5 個直接左轉路口
- 驗證每個路口都正確觸發提示

**場景 2: 省電測試**
- 充滿電後啟動 App
- 背景監控 2 小時
- 記錄電池消耗百分比

**場景 3: 重複提示過濾**
- 在同一路口附近來回移動
- 驗證 5 分鐘內不重複提示

**場景 4: 地圖功能測試**
- 開啟地圖頁面
- 點擊 10 個隨機路口標記
- 驗證資訊正確顯示
- 測試導航功能是否正確開啟 Apple Maps

## 開發里程碑

### Sprint 1: 核心功能開發（3-4 天）

- [ ] 專案初始化與架構設定
- [ ] 資料模型建立（Intersection, UserSettings, AlertHistory）
- [ ] 位置追蹤服務實作（LocationViewModel）
- [ ] 語音提示服務實作（SpeechService）
- [ ] 距離計算與觸發邏輯
- [ ] 主頁面 UI（開始/停止監控）

### Sprint 2: 地圖功能開發（2 天）

- [ ] MapKit 整合
- [ ] 路口標記顯示
- [ ] 點擊標記顯示資訊卡片
- [ ] 搜尋功能
- [ ] 導航整合（開啟 Apple Maps）

### Sprint 3: 設定與優化（1-2 天）

- [ ] 設定頁面 UI
- [ ] UserDefaults 儲存與讀取
- [ ] 權限引導流程
- [ ] 省電優化
- [ ] 錯誤處理與邊界情況

### Sprint 4: 測試與發布（2-3 天）

- [ ] 單元測試
- [ ] 實際道路測試
- [ ] 效能測試（電池、延遲）
- [ ] TestFlight Beta 測試
- [ ] 準備 App Store 素材（截圖、描述、圖示）
- [ ] 提交審核

**總開發時間**: 8-11 天

## App Store 發布資訊

### App 名稱

**主要名稱**: 機車直左通
**副標題**: 台北市直接左轉路口即時提醒

### App 描述

**簡短描述**:
```
在台北騎車不再煩惱兩段式左轉！
自動提醒可直接左轉的路口，讓您騎得更順暢。
```

**完整描述**:
```
【機車直左通】是專為台北機車騎士設計的智慧提醒工具

🚦 即時語音提醒
當您接近可直接左轉的路口時，App 會自動發出語音：
「前方 XXX 路口可直接左轉，方向：北往東」

🗺️ 完整路口地圖
收錄台北市 121 個開放直接左轉的路口
一目了然，出發前輕鬆規劃路線

⚡ 背景運作
即使切換到 Google Maps 導航，也能持續提醒
不影響您使用其他 App

🔋 省電設計
優化的位置追蹤技術，不會大量消耗電池

📍 資料來源
台北市政府交通局官方資料（114年4月更新）

【主要功能】
✓ 背景位置監控
✓ 繁體中文語音提示
✓ 可自訂提醒距離（300/500/700公尺）
✓ 靜音模式與震動提示
✓ 互動式地圖查看所有路口
✓ 一鍵導航至路口
✓ 隱私保護：所有計算在本機進行

【適用對象】
• 經常在台北騎機車的通勤族
• 不熟悉台北路況的騎士
• 想要提升騎乘效率的您

【注意事項】
• 需要授予「永遠」位置權限以啟用背景提醒
• 僅適用於台北市區域
• 建議搭配 Google Maps 或 Apple Maps 導航使用
```

### 關鍵字

```
機車, 左轉, 導航, 台北, 路口, 提醒, 語音, 交通, 騎車, 通勤
```

### 分類

- **主要分類**: 導航 (Navigation)
- **次要分類**: 工具程式 (Utilities)

### 截圖需求

1. **主頁面** - 顯示監控狀態
2. **地圖頁面** - 顯示路口標記
3. **路口詳細資訊** - 點擊標記後的卡片
4. **設定頁面** - 各種設定選項
5. **權限引導** - 說明為何需要位置權限

## 風險與挑戰

### 技術風險

1. **背景位置追蹤的穩定性**
   - 風險：iOS 系統可能在省電模式下限制背景位置更新
   - 緩解：實作多種追蹤模式，在限制時降級到通知提醒

2. **語音與導航 App 的音訊衝突**
   - 風險：語音提示可能被 Google Maps 導航語音打斷或覆蓋
   - 緩解：使用 `.duckOthers` 選項降低背景音訊，並測試最佳播放時機

3. **GPS 精度問題**
   - 風險：在高樓大廈區域 GPS 訊號可能不準確
   - 緩解：設定距離過濾閾值，避免 GPS 漂移造成誤觸發

### 法規風險

1. **App Store 審核**
   - 風險：Apple 可能以「背景位置追蹤」理由拒絕審核
   - 緩解：清楚說明位置資料使用目的，強調不上傳資料

2. **隱私政策合規**
   - 風險：需符合 Apple 隱私標籤要求
   - 緩解：僅收集必要資料，提供清楚的隱私說明

### 使用者體驗風險

1. **語音提示干擾**
   - 風險：頻繁的語音可能造成使用者困擾
   - 緩解：提供靜音模式、重複提示過濾、安靜時段設定

2. **電池消耗**
   - 風險：背景位置追蹤可能導致使用者投訴耗電
   - 緩解：優化追蹤策略，提供省電說明

## 未來擴展可能性

### 短期（1-3 個月）

- 支援新北市、桃園市等其他縣市
- 加入路線規劃功能（優先經過直接左轉路口的路線）
- 提供統計功能（省下的時間、經過的路口數）

### 中期（3-6 個月）

- 開發 Android 版本
- 社群功能：使用者回報路口狀態變更
- 整合即時路況資訊

### 長期（6-12 個月）

- Apple Watch 支援
- CarPlay 整合
- AI 路線建議（學習使用者習慣）

---

**最後更新**: 2025-11-17
**版本**: 1.0（草稿）
