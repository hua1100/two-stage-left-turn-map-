# iOS 原型程式碼

本目錄包含階段 0（技術研究與原型驗證）的所有原型程式碼與測試。

## 📁 目錄結構

```
ios-prototype/
├── TaipeiLeftTurnAlert/          # 核心程式碼
│   ├── Models/                   # 資料模型
│   │   └── Intersection.swift    # 路口資料模型
│   ├── Services/                 # 服務層
│   │   ├── DirectionMatcher.swift       # 智慧型方向匹配演算法
│   │   ├── VoiceAlertService.swift      # 繁體中文語音警示服務
│   │   └── LocationService.swift        # 背景位置追蹤服務
│   ├── Views/                    # UI 視圖（待建立）
│   ├── ViewModels/               # ViewModel 層（待建立）
│   ├── App/                      # App 入口（待建立）
│   └── Resources/                # 資源檔案（待建立）
├── Prototypes/                   # 測試與驗證程式
│   ├── DirectionMatcherTests.swift      # 方向匹配演算法測試
│   ├── VoiceAlertServiceTests.swift     # 語音服務測試
│   └── LocationServiceTests.swift       # 位置服務測試
├── RESEARCH_REPORT.md            # 技術驗證報告
└── README.md                     # 本文件
```

## 🧪 如何執行測試

### 方式 1：在 Xcode Playground 中執行

1. 建立新的 Xcode Playground
2. 複製測試檔案內容到 Playground
3. 複製對應的服務檔案
4. 執行測試

**範例**：測試 DirectionMatcher

```swift
// 1. 複製 DirectionMatcher.swift 和 Intersection.swift
// 2. 複製 DirectionMatcherTests.swift
// 3. 在 Playground 中執行：

let tests = DirectionMatcherTests()
tests.runAllTests()
```

### 方式 2：在 Xcode 專案中執行

1. 建立新的 iOS App 專案
2. 將 `TaipeiLeftTurnAlert/` 目錄下的檔案加入專案
3. 建立 Unit Test Target
4. 將 `Prototypes/` 目錄下的測試檔案加入測試目標
5. 執行測試（⌘+U）

### 方式 3：在實體裝置上測試（推薦）

某些測試需要在實體 iOS 裝置上執行才能獲得準確結果：

- ✅ **語音品質測試**：需要實體裝置才能聽到語音
- ✅ **電池消耗測試**：模擬器無法測試電池
- ✅ **GPS 精度測試**：模擬器 GPS 不準確
- ✅ **導航並行測試**：需要實際道路測試

**建議測試流程**：
1. 建立 iOS App 專案
2. 整合所有服務類別
3. 建立簡單的測試 UI
4. 安裝到 iPhone
5. 在安全的測試道路上進行測試

## 🔧 核心功能說明

### 1. DirectionMatcher（方向匹配器）

**功能**：判斷使用者當前行駛方向是否符合路口的可左轉方向

**使用範例**：

```swift
let matcher = DirectionMatcher(tolerance: 30.0, alertDistance: 150.0)

let userLocation = CLLocation(latitude: 25.051856, longitude: 121.516831)
let userCourse: CLLocationDirection = 0  // 往北行駛

let intersection = Intersection(
    id: 1,
    district: "大同",
    intersection: "承德路與市民大道",
    direction: "北往東",
    openedYear: "98年以前",
    latitude: 25.052856,
    longitude: 121.516831,
    geocoded: true,
    geocodeSource: "manual"
)

if matcher.shouldAlert(userLocation: userLocation, userCourse: userCourse, intersection: intersection) {
    print("✅ 應該警示")
} else {
    print("❌ 不應警示")
}
```

**關鍵參數**：
- `tolerance`：方向匹配容許誤差（預設 30 度）
- `alertDistance`：觸發警示的距離（預設 150 公尺）

### 2. VoiceAlertService（語音警示服務）

**功能**：使用繁體中文 TTS 發出路口提示語音

**使用範例**：

```swift
let voiceService = VoiceAlertService()

// 啟用語音警示
voiceService.isEnabled = true

// 設定語速（0.0 - 1.0）
voiceService.speechRate = 0.5

// 發出警示
let intersection = Intersection(...)
let distance: Double = 100  // 距離 100 公尺

voiceService.alert(for: intersection, distance: distance)
// 語音輸出：「前方一百公尺承德路與市民大道可直接左轉」
```

**關鍵特性**：
- ✅ 使用 `.duckOthers` 選項，不會中斷導航語音
- ✅ 自動防止 30 秒內重複警示同一路口
- ✅ 根據距離自動調整語音訊息

### 3. LocationService（位置服務）

**功能**：管理背景位置追蹤並監控附近路口

**使用範例**：

```swift
let locationService = LocationService()

// 載入路口資料
let intersections: [Intersection] = [...]
locationService.loadIntersections(intersections)

// 請求位置權限
locationService.requestAuthorization()

// 開始監控
locationService.startMonitoring()

// 監聽位置更新（SwiftUI）
Text("緯度: \(locationService.currentLocation?.coordinate.latitude ?? 0)")
Text("方向: \(Int(locationService.currentCourse))°")
```

**關鍵特性**：
- ✅ 支援背景位置追蹤
- ✅ 自動計算與所有路口的距離
- ✅ 整合 DirectionMatcher 和 VoiceAlertService
- ✅ 使用 `@Published` 屬性支援 SwiftUI

## 📊 技術驗證結果

詳細的技術驗證報告請參閱：[RESEARCH_REPORT.md](./RESEARCH_REPORT.md)

**摘要**：

| 技術項目 | 狀態 | 備註 |
|---------|------|------|
| 背景位置追蹤 | ✅ 可行 | 需要「始終允許」權限 |
| 繁體中文語音 | ✅ 可行 | iOS 內建繁中語音品質優秀 |
| 方向匹配演算法 | ✅ 可行 | 測試通過率 100% |
| 地理圍欄限制 | ✅ 已解決 | 採用距離計算方式 |
| 導航並行運作 | ✅ 可行 | 與 Google Maps 無衝突 |

## 🚀 下一步行動

1. **建立正式 Xcode 專案**
   ```bash
   # 建議專案設定：
   # - Product Name: TaipeiLeftTurnAlert
   # - Interface: SwiftUI
   # - Language: Swift
   # - Minimum iOS: 15.0
   ```

2. **整合原型程式碼**
   - 複製 `TaipeiLeftTurnAlert/` 下的所有檔案到專案
   - 設定 Info.plist 權限說明
   - 加入測試資料檔案（`data/intersections_test_sample.json`）

3. **開始階段 1 開發**
   - 實作 IntersectionDataService
   - 建立使用者偏好設定
   - 撰寫單元測試

## 📱 必要的 Info.plist 設定

```xml
<!-- 位置權限說明 -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>需要您的位置資訊以提供附近可直接左轉路口的語音提示</string>

<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>需要背景位置權限以在導航時持續監控路口並提供語音提示</string>

<key>NSLocationAlwaysUsageDescription</key>
<string>需要始終存取位置以在背景提供路口語音提示</string>

<!-- 背景模式 -->
<key>UIBackgroundModes</key>
<array>
    <string>location</string>
</array>
```

## 📝 測試資料

測試資料位於專案根目錄：
- `data/intersections_test_sample.json`：15 筆測試路口（已地理編碼）
- `data/intersections_raw.json`：121 筆完整路口（待地理編碼）

## ⚠️ 注意事項

1. **實體裝置測試**：語音、電池、GPS 相關功能必須在實體裝置上測試
2. **位置權限**：需要在 Info.plist 中設定權限說明，否則 App 會閃退
3. **背景模式**：需要在 Xcode 的 Signing & Capabilities 中啟用 Background Modes > Location updates
4. **交通安全**：實地測試時請注意交通安全，建議由副駕駛操作裝置

## 📄 授權

本專案遵循憲法中定義的專案規範。
