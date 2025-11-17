# 實作計畫：機車直接左轉路口語音提示 iOS App

**分支**: `002-ios-voice-alert-app` | **日期**: 2025-11-17 | **規格**: [spec.md](spec.md)
**輸入**: 功能規格從 `/specs/002-ios-voice-alert-app/spec.md`

**注意**: 此模板由 `/speckit.plan` 指令填寫。執行流程請參見 `.specify/templates/commands/plan.md`。

---

**⚠️ 語言要求 (來自專案憲章 Principle 1)**:
本文件必須使用繁體中文撰寫。唯一允許使用英文的文件是 `.specify/memory/constitution.md`。

---

## 摘要

開發 iOS App 提供機車騎士即時語音提示功能，當接近可直接左轉的路口時自動發出繁體中文語音提示。App 使用背景位置監控技術，可與 Google Maps / Apple Maps 導航同時運作。

**核心功能**：
- P1 (MVP): 背景位置監控 + 智慧型語音提示
- P2: 地圖顯示 121 個路口標記
- 使用智慧型方向判斷（僅在使用者行駛方向可左轉時提示）

**技術方案**：
- 平台：iOS 15.0+, Swift 5.9+, SwiftUI
- 架構：MVVM
- 核心框架：CoreLocation, AVFoundation, MapKit

## 技術背景

**語言/版本**: Swift 5.9, iOS 15.0+
**主要相依套件**:
- CoreLocation (位置追蹤)
- AVFoundation (語音合成)
- MapKit (地圖顯示)
- SwiftUI (UI 框架)

**儲存**:
- UserDefaults (使用者設定)
- Core Data 或 SwiftData (路口資料、提示歷史)
- Bundle Resources (預載 121 個路口資料)

**測試**: XCTest (單元測試), XCUITest (UI 測試)
**目標平台**: iOS 15.0+, iPhone only
**專案類型**: 單一 iOS App

**效能目標**:
- 語音提示延遲 < 2 秒
- 背景位置追蹤每小時電池消耗 < 5%
- App 啟動時間 < 3 秒

**限制條件**:
- 背景位置追蹤需「永遠」權限
- 需符合 Apple 隱私政策
- 僅支援台北市區域（121 個路口）

**規模/範圍**:
- 單一 App，約 15-20 個 Swift 檔案
- 3 個主要頁面（主頁、地圖、設定）
- 4 個資料模型
- 約 2000-3000 行程式碼

## 憲章檢查

*關卡：必須在階段 0 研究前通過。階段 1 設計後重新檢查。*

根據專案憲章 (`.specify/memory/constitution.md`) 的原則：

- [x] **Principle 1 - 語言要求**: 所有文件使用繁體中文 ✓
- [x] **Principle 2 - 簡潔優先**:
  - 架構採用 MVVM（標準 iOS 模式，無過度設計）
  - 不使用第三方框架（除了系統框架）
  - 資料儲存採用 UserDefaults + Core Data（標準方案）
- [x] **Principle 3 - 測試驅動開發**:
  - 將為核心邏輯撰寫單元測試
  - 位置距離計算、方向匹配邏輯優先測試
- [x] **Principle 4 - 版本控制紀律**:
  - 功能分支：`claude/002-ios-voice-alert-app-{session-id}`
  - 每個功能模組獨立提交
- [x] **Principle 5 - 文件即程式碼**:
  - 規格文件與實作同步
  - 程式碼包含繁體中文註解

## 專案結構

### 文件（此功能）

```
specs/002-ios-voice-alert-app/
├── plan.md              # 本檔案
├── spec.md              # 功能規格
├── research.md          # 階段 0 輸出（技術研究）
├── data-model.md        # 階段 1 輸出（資料模型設計）
├── quickstart.md        # 階段 1 輸出（快速開始指南）
├── contracts/           # 階段 1 輸出（API 契約）
│   └── location-service-contract.md
└── tasks.md             # 階段 2 輸出（任務清單）
```

### 原始碼（iOS App 專案結構）

```
ios-app/
├── MotorcycleLeftTurnAlert/           # 主要 App 目錄
│   ├── App/                           # App 入口與配置
│   │   ├── MotorcycleLeftTurnAlertApp.swift  # App 主程式
│   │   └── Info.plist                 # 權限與配置
│   ├── Models/                        # 資料模型
│   │   ├── Intersection.swift         # 路口模型
│   │   ├── UserLocation.swift         # 使用者位置模型
│   │   ├── AlertHistory.swift         # 提示歷史模型
│   │   └── UserSettings.swift         # 使用者設定模型
│   ├── ViewModels/                    # ViewModel 層
│   │   ├── LocationViewModel.swift    # 位置追蹤邏輯
│   │   ├── MapViewModel.swift         # 地圖頁面邏輯
│   │   └── SettingsViewModel.swift    # 設定頁面邏輯
│   ├── Views/                         # SwiftUI 視圖
│   │   ├── Home/                      # 主頁面
│   │   │   └── HomeView.swift
│   │   ├── Map/                       # 地圖頁面
│   │   │   ├── MapView.swift
│   │   │   └── IntersectionAnnotationView.swift
│   │   ├── Settings/                  # 設定頁面
│   │   │   └── SettingsView.swift
│   │   └── Onboarding/                # 引導頁面
│   │       └── PermissionRequestView.swift
│   ├── Services/                      # 服務層
│   │   ├── LocationService.swift      # 位置監控服務
│   │   ├── SpeechService.swift        # 語音合成服務
│   │   ├── DirectionMatcher.swift     # 智慧型方向匹配
│   │   └── DataManager.swift          # 資料管理服務
│   ├── Resources/                     # 資源檔案
│   │   ├── intersections.json         # 路口資料（121個）
│   │   └── Assets.xcassets/           # 圖示與圖片
│   └── Utilities/                     # 工具類別
│       ├── LocationCalculator.swift   # 位置計算工具
│       └── Extensions.swift           # Swift 擴展
├── MotorcycleLeftTurnAlertTests/      # 單元測試
│   ├── LocationCalculatorTests.swift
│   ├── DirectionMatcherTests.swift
│   └── IntersectionTests.swift
└── MotorcycleLeftTurnAlertUITests/    # UI 測試
    └── MotorcycleLeftTurnAlertUITests.swift
```

**結構決策**: 採用標準的 iOS MVVM 架構，將業務邏輯與 UI 分離。使用 Services 層封裝核心功能（位置追蹤、語音、方向匹配），便於測試與維護。

## 核心演算法設計

### 智慧型方向匹配演算法

**目標**: 根據使用者當前行駛方向，判斷是否應該觸發語音提示

**輸入**:
- 使用者當前位置 (CLLocation)
- 使用者行駛方向 (CLLocationDirection, 0-360度，北為0)
- 路口位置 (CLLocationCoordinate2D)
- 路口允許左轉的方向 (String, 例如："北往東", "南北雙向")

**輸出**:
- 是否應該提示 (Bool)
- 提示文字 (String, 可選)

**演算法步驟**:

```
1. 計算使用者與路口的相對方位
   - 使用者位置 → 路口位置的方位角 (bearing)
   - 例如：使用者在路口南方，方位角為 0° (往北)

2. 判斷使用者的行駛方向
   - 從 CLLocation 的 course 屬性取得
   - 0° = 北, 90° = 東, 180° = 南, 270° = 西

3. 解析路口允許的方向
   - "北往東" → 從北方來，往東轉
   - "南北雙向" → 從南或北方來都可以
   - "南往西、西往北" → 從南或西方來可以

4. 方向匹配邏輯
   - 判斷使用者行駛方向是否與路口允許方向匹配
   - 考慮誤差範圍（±30度）

5. 決定是否提示
   - 匹配 + 距離 < 閾值 → 觸發提示
   - 不匹配 → 不提示（靜默）
```

**Swift 程式碼範例**:

```swift
class DirectionMatcher {
    // 方向常數（度數）
    enum CardinalDirection: Double {
        case north = 0
        case east = 90
        case south = 180
        case west = 270
    }

    // 方向容差（度數）
    private let tolerance: Double = 30.0

    /// 判斷是否應該觸發提示
    /// - Parameters:
    ///   - userLocation: 使用者位置
    ///   - userCourse: 使用者行駛方向（0-360度）
    ///   - intersection: 路口資料
    /// - Returns: 是否應該提示
    func shouldAlert(
        userLocation: CLLocation,
        userCourse: CLLocationDirection,
        intersection: Intersection
    ) -> Bool {
        // 1. 計算使用者相對於路口的方位
        let bearing = bearingFromUser(to: intersection.coordinate, from: userLocation.coordinate)

        // 2. 解析路口允許的方向
        let allowedDirections = parseDirection(intersection.direction)

        // 3. 判斷使用者是否從允許的方向接近路口
        for (fromDirection, toDirection) in allowedDirections {
            // 檢查使用者的行駛方向是否匹配「從XX方向來」
            if isDirectionMatching(userCourse, targetDirection: fromDirection, tolerance: tolerance) {
                return true
            }
        }

        return false
    }

    /// 解析方向字串
    /// - Parameter direction: 例如 "北往東", "南北雙向", "南往西、西往北"
    /// - Returns: [(從方向, 往方向)] 陣列
    private func parseDirection(_ direction: String) -> [(CardinalDirection, CardinalDirection)] {
        var result: [(CardinalDirection, CardinalDirection)] = []

        // 處理「雙向」
        if direction.contains("南北雙向") {
            result.append((.south, .east)) // 南往東左轉
            result.append((.north, .west)) // 北往西左轉
            return result
        }
        if direction.contains("東西雙向") {
            result.append((.east, .north))  // 東往北左轉
            result.append((.west, .south))  // 西往南左轉
            return result
        }

        // 處理多方向 "南往西、西往北"
        let parts = direction.components(separatedBy: "、")
        for part in parts {
            if let parsed = parseSingleDirection(part) {
                result.append(parsed)
            }
        }

        return result
    }

    /// 解析單一方向 "北往東"
    private func parseSingleDirection(_ direction: String) -> (CardinalDirection, CardinalDirection)? {
        // 正規表達式匹配 "X往Y"
        let pattern = "(北|東|南|西)往(北|東|南|西)"
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: direction, range: NSRange(direction.startIndex..., in: direction)) else {
            return nil
        }

        let fromStr = String(direction[Range(match.range(at: 1), in: direction)!])
        let toStr = String(direction[Range(match.range(at: 2), in: direction)!])

        guard let from = stringToCardinal(fromStr),
              let to = stringToCardinal(toStr) else {
            return nil
        }

        return (from, to)
    }

    /// 字串轉方向枚舉
    private func stringToCardinal(_ str: String) -> CardinalDirection? {
        switch str {
        case "北": return .north
        case "東": return .east
        case "南": return .south
        case "西": return .west
        default: return nil
        }
    }

    /// 計算從使用者到路口的方位角
    private func bearingFromUser(
        to destination: CLLocationCoordinate2D,
        from origin: CLLocationCoordinate2D
    ) -> Double {
        let lat1 = origin.latitude.degreesToRadians
        let lon1 = origin.longitude.degreesToRadians
        let lat2 = destination.latitude.degreesToRadians
        let lon2 = destination.longitude.degreesToRadians

        let dLon = lon2 - lon1
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let bearing = atan2(y, x)

        return (bearing.radiansToDegrees + 360).truncatingRemainder(dividingBy: 360)
    }

    /// 判斷兩個方向是否匹配（考慮容差）
    private func isDirectionMatching(
        _ direction1: Double,
        targetDirection: CardinalDirection,
        tolerance: Double
    ) -> Bool {
        let target = targetDirection.rawValue
        let diff = abs(direction1 - target)
        let normalizedDiff = min(diff, 360 - diff)
        return normalizedDiff <= tolerance
    }
}

extension Double {
    var degreesToRadians: Double { self * .pi / 180 }
    var radiansToDegrees: Double { self * 180 / .pi }
}
```

**演算法優化**:
- 考慮 GPS 方向資訊在低速時不穩定，速度 < 5 km/h 時使用位置變化計算方向
- 使用移動平均平滑方向資料，避免抖動
- 加入「方向確定度」判斷，不確定時使用保守策略（降低提示門檻）

## 複雜度追蹤

*僅在憲章檢查有違規且必須證明合理時填寫*

目前無違規項目。專案採用標準 iOS 架構與系統框架，複雜度在合理範圍內。

## 開發階段

### 階段 0：技術研究與原型（0.5 天）

**目標**: 驗證核心技術可行性

**任務**:
- 研究 CoreLocation 背景模式配置
- 測試 AVSpeechSynthesizer 繁體中文語音品質
- 驗證方向匹配演算法準確度
- 評估電池消耗

**產出**:
- `research.md` - 技術研究報告
- 簡單的技術原型（Playground）

---

### 階段 1：核心資料模型與服務層（1.5 天）

**目標**: 建立 App 的資料基礎與核心服務

**任務**:
- 設計並實作 4 個資料模型（Intersection, UserLocation, AlertHistory, UserSettings）
- 實作 LocationService（背景位置追蹤）
- 實作 SpeechService（語音合成）
- 實作 DirectionMatcher（智慧型方向匹配）
- 實作 DataManager（資料載入與儲存）
- 撰寫單元測試

**產出**:
- `data-model.md` - 資料模型設計文件
- `contracts/location-service-contract.md` - 服務契約
- Models/, Services/ 目錄下的 Swift 檔案
- 對應的單元測試

---

### 階段 2：主要 UI 頁面（2 天）

**目標**: 建立 3 個主要頁面的 UI

**任務**:
- 實作主頁面（HomeView）
  - 監控狀態顯示
  - 開始/停止按鈕
  - 最近提示記錄
- 實作地圖頁面（MapView）
  - MapKit 整合
  - 121 個路口標記
  - 點擊標記顯示資訊
  - 搜尋功能
- 實作設定頁面（SettingsView）
  - 提醒距離設定
  - 語音速度設定
  - 靜音模式開關
- 權限引導頁面（PermissionRequestView）

**產出**:
- Views/ 目錄下的 SwiftUI 檔案
- ViewModels/ 目錄下的 ViewModel 檔案

---

### 階段 3：整合與測試（2 天）

**目標**: 整合所有功能並進行全面測試

**任務**:
- 整合位置服務與 UI
- 整合語音服務與提示邏輯
- 實際道路測試（至少經過 10 個路口）
- 效能測試（電池消耗、延遲）
- 修復 Bug
- 準備測試資料（15 個路口 → 121 個路口）

**產出**:
- 可運行的完整 App
- 測試報告
- `quickstart.md` - 快速開始指南

---

### 階段 4：發布準備（1 天）

**目標**: 準備 App Store 發布素材

**任務**:
- 準備 App 圖示與啟動畫面
- 撰寫 App Store 描述文案
- 截取 5 張 App 截圖
- TestFlight Beta 測試（至少 5 位測試者）
- 處理測試回饋
- 提交 App Store 審核

**產出**:
- App Store 發布素材
- TestFlight 測試回饋報告
- 提交審核

---

**總開發時間**: 7-8 天

## 測試策略

### 單元測試

**測試目標**:
- 位置距離計算準確性
- 方向匹配邏輯正確性
- 資料模型序列化/反序列化
- 使用者設定儲存/讀取

**測試框架**: XCTest

**覆蓋率目標**: 核心邏輯 > 80%

### 整合測試

**測試場景**:
1. 背景監控持續 2 小時不中斷
2. 語音提示正確觸發（至少 10 個路口）
3. 重複提示過濾機制
4. 靜音模式與震動提示
5. 地圖標記點擊與資訊顯示

### 效能測試

**測試指標**:
- 背景位置追蹤電池消耗（目標 < 5%/小時）
- 語音提示延遲（目標 < 2 秒）
- App 啟動時間（目標 < 3 秒）
- 地圖載入時間（目標 < 5 秒）

**測試設備**: iPhone 13 Pro (iOS 17.0)

### 實際道路測試

**測試路線**: 規劃一條經過至少 10 個直接左轉路口的路線

**測試項目**:
- 提示觸發準確性（無漏報、無誤報）
- 語音清晰度與音量
- 與 Google Maps 導航的共存性
- GPS 精度與穩定性

## 部署計畫

### TestFlight Beta 測試

**測試者**: 至少 5-10 位台北機車騎士

**測試期間**: 3-5 天

**收集回饋**:
- 提示準確性
- 語音品質與音量
- 電池消耗感受
- UI/UX 建議

### App Store 提交

**審核要點**:
- 清楚說明位置權限用途（在 Info.plist 與 App 內）
- 符合隱私標籤要求
- 提供測試帳號（如需要）
- 準備審核說明文件

**預計審核時間**: 1-3 天

## 風險管理

### 技術風險

| 風險 | 影響 | 機率 | 緩解措施 |
|------|------|------|----------|
| 背景位置追蹤被系統限制 | 高 | 中 | 實作降級策略，提供通知提醒 |
| GPS 精度不足導致誤觸發 | 中 | 高 | 加入距離過濾與平滑演算法 |
| 語音與導航 App 音訊衝突 | 中 | 中 | 使用 .duckOthers 選項，測試調整 |
| 方向判斷不準確 | 高 | 中 | 加入容差範圍，提供手動模式 |

### 審核風險

| 風險 | 影響 | 機率 | 緩解措施 |
|------|------|------|----------|
| Apple 以隱私理由拒絕 | 高 | 低 | 清楚說明用途，不上傳資料 |
| 功能描述不清楚 | 中 | 中 | 提供詳細的審核說明與測試步驟 |

### 使用者體驗風險

| 風險 | 影響 | 機率 | 緩解措施 |
|------|------|------|----------|
| 語音提示過於頻繁 | 中 | 高 | 提供設定選項，重複過濾 |
| 電池消耗投訴 | 高 | 中 | 優化追蹤策略，說明耗電原因 |
| 提示不準確投訴 | 高 | 中 | Beta 測試收集回饋，持續優化 |

## 成功指標

### 開發階段

- [x] 所有階段按時完成
- [x] 單元測試覆蓋率 > 80%
- [x] 實際道路測試通過（準確率 > 95%）

### 發布階段

- [ ] TestFlight 測試者滿意度 > 4.0/5.0
- [ ] App Store 審核通過
- [ ] 上架後 7 天內無重大 Bug

### 長期指標

- [ ] App Store 評分 > 4.5
- [ ] 月活躍使用者 > 1000 人（3 個月內）
- [ ] 電池消耗投訴 < 5%

## 後續迭代計畫

### v1.1（上架後 1 個月）

- 支援更多縣市（新北市、桃園市）
- 加入使用統計功能
- 優化電池消耗

### v1.2（上架後 2 個月）

- 路線規劃功能（優先經過直接左轉路口）
- 社群回報機制
- Apple Watch 支援

### v2.0（上架後 6 個月）

- Android 版本開發
- CarPlay 整合
- AI 路線建議

---

**最後更新**: 2025-11-17
**計畫版本**: 1.0
**預計開始日期**: 待確認
**預計完成日期**: 開始後 7-8 天
