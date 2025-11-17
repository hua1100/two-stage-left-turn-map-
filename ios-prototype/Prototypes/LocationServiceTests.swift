import Foundation
import CoreLocation

/// 位置服務測試
///
/// 此測試驗證：
/// 1. 背景位置追蹤功能
/// 2. 電池消耗（目標 <5%/小時）
/// 3. 位置更新頻率與精度
/// 4. Google Maps 導航期間是否正常運作
///
/// 執行方式：在實體 iOS 裝置上執行並進行實地測試

class LocationServiceTests {

    let locationService: LocationService
    var testStartTime: Date?
    var batteryLevelAtStart: Float?

    // 測試統計
    var locationUpdateCount: Int = 0
    var alertCount: Int = 0

    init() {
        self.locationService = LocationService()

        // 載入測試資料
        loadTestIntersections()
    }

    // MARK: - 資料載入

    func loadTestIntersections() {
        // 使用測試資料集（15 個路口）
        let testIntersections: [Intersection] = [
            Intersection(
                id: 1, district: "大同", intersection: "承德路與市民大道",
                direction: "北往東", openedYear: "98年以前",
                latitude: 25.052856, longitude: 121.516831,
                geocoded: true, geocodeSource: "manual"
            ),
            Intersection(
                id: 2, district: "南港", intersection: "研究院路與南港路二段",
                direction: "南北雙向", openedYear: "98年以前",
                latitude: 25.041234, longitude: 121.612345,
                geocoded: true, geocodeSource: "manual"
            ),
            // ... 可加入更多測試路口
        ]

        locationService.loadIntersections(testIntersections)
    }

    // MARK: - 測試案例

    /// 測試 1：背景位置追蹤權限
    func testLocationAuthorization() {
        print("\n=== 測試 1：背景位置追蹤權限 ===")

        print("📝 當前權限狀態: \(locationService.authorizationStatus)")

        if locationService.authorizationStatus == .notDetermined {
            print("🔐 請求位置權限...")
            locationService.requestAuthorization()

            print("📝 請在彈出視窗中選擇「使用 App 期間允許」或「始終允許」")
            print("   建議選擇「始終允許」以支援背景監控")
        } else if locationService.authorizationStatus == .authorizedAlways {
            print("✅ 已授權「始終允許」- 可進行背景監控")
        } else if locationService.authorizationStatus == .authorizedWhenInUse {
            print("⚠️  已授權「使用期間」- 背景監控可能受限")
            print("   建議前往設定變更為「始終允許」")
        } else {
            print("❌ 權限不足 - 無法進行位置追蹤")
        }
    }

    /// 測試 2：背景位置更新測試
    func testBackgroundLocationUpdates() {
        print("\n=== 測試 2：背景位置更新測試 ===")

        guard locationService.authorizationStatus == .authorizedAlways ||
              locationService.authorizationStatus == .authorizedWhenInUse else {
            print("❌ 權限不足，無法執行測試")
            return
        }

        print("📝 測試步驟：")
        print("   1. 啟動位置監控")
        print("   2. 切換到 Google Maps 並開始導航")
        print("   3. 行駛 10-15 分鐘")
        print("   4. 返回 App 查看統計資料")
        print("")

        testStartTime = Date()
        batteryLevelAtStart = UIDevice.current.batteryLevel

        UIDevice.current.isBatteryMonitoringEnabled = true

        print("🚀 開始位置監控...")
        locationService.startMonitoring()

        print("📊 監控已啟動，請開始測試")
        print("   - 開始時間: \(formatDate(testStartTime!))")
        print("   - 初始電量: \(String(format: "%.0f", batteryLevelAtStart! * 100))%")
    }

    /// 測試 3：統計資料顯示
    func testShowStatistics() {
        print("\n=== 測試 3：統計資料 ===")

        guard let startTime = testStartTime else {
            print("❌ 請先執行測試 2")
            return
        }

        let duration = Date().timeIntervalSince(startTime)
        let currentBattery = UIDevice.current.batteryLevel
        let batteryUsed = (batteryLevelAtStart ?? 0) - currentBattery

        print("📊 測試結果：")
        print("   - 測試時長: \(formatDuration(duration))")
        print("   - 位置更新次數: \(locationUpdateCount)")
        print("   - 觸發警示次數: \(alertCount)")
        print("   - 電池消耗: \(String(format: "%.1f", batteryUsed * 100))%")

        if duration > 0 {
            let batteryPerHour = (batteryUsed / duration) * 3600
            print("   - 每小時電池消耗: \(String(format: "%.1f", batteryPerHour * 100))%")

            if batteryPerHour * 100 <= 5 {
                print("   ✅ 電池消耗符合目標（<5%/小時）")
            } else {
                print("   ⚠️  電池消耗超過目標（目標: <5%/小時）")
            }
        }

        if let location = locationService.currentLocation {
            print("   - 當前位置: \(location.coordinate.latitude), \(location.coordinate.longitude)")
            print("   - 當前方向: \(Int(locationService.currentCourse))°")
            print("   - 位置精度: \(String(format: "%.1f", location.horizontalAccuracy))m")
        }
    }

    /// 測試 4：導航期間並行測試
    func testWithGoogleMapsNavigation() {
        print("\n=== 測試 4：Google Maps 導航並行測試 ===")

        print("📝 手動測試步驟：")
        print("   1. 確保此 App 的位置監控已啟動")
        print("   2. 開啟 Google Maps")
        print("   3. 設定導航目的地並開始導航")
        print("   4. 行駛經過測試路口")
        print("   5. 驗證以下項目：")
        print("")
        print("   驗證清單：")
        print("   □ Google Maps 導航正常運作")
        print("   □ 導航語音正常播放")
        print("   □ 經過測試路口時觸發語音警示")
        print("   □ 警示語音不會中斷導航語音")
        print("   □ 警示語音播放時導航語音降低音量")
        print("   □ 警示結束後導航語音恢復正常")
        print("   □ App 在背景時仍正常監控位置")
        print("")

        print("📍 測試路口建議：")
        print("   - 承德路與市民大道（大同區）")
        print("   - 研究院路與南港路二段（南港區）")
        print("")

        print("⚠️  注意事項：")
        print("   - 請在允許測試的安全道路上進行")
        print("   - 建議由副駕駛或乘客操作裝置")
        print("   - 遵守交通規則，安全第一")
    }

    /// 測試 5：地理圍欄限制測試
    func testGeofencingLimits() {
        print("\n=== 測試 5：地理圍欄限制測試 ===")

        print("📝 iOS 地理圍欄限制：")
        print("   - 每個 App 最多監控 20 個地理圍欄")
        print("   - 系統最多監控 400 個地理圍欄（所有 App 共用）")
        print("")

        print("🔍 當前專案需求：")
        print("   - 需監控 121 個路口")
        print("   - 超過 iOS 單一 App 限制（20 個）")
        print("")

        print("💡 解決方案：")
        print("   - ✅ 採用距離計算方式（當前實作）")
        print("   - 動態計算使用者與所有路口的距離")
        print("   - 不使用 CLLocationManager 的 startMonitoring(for:)")
        print("   - 優點：無數量限制、可自訂警示距離")
        print("   - 缺點：需持續運算（但影響微小）")
        print("")

        print("⚡️ 效能測試：")
        let intersectionCount = 121
        let iterations = 1000

        let startTime = Date()

        for _ in 0..<iterations {
            // 模擬距離計算
            let userLocation = CLLocation(latitude: 25.052856, longitude: 121.516831)

            for _ in 0..<intersectionCount {
                let intersectionLocation = CLLocation(latitude: 25.051856, longitude: 121.516831)
                _ = userLocation.distance(from: intersectionLocation)
            }
        }

        let endTime = Date()
        let duration = endTime.timeIntervalSince(startTime)
        let avgTime = (duration / Double(iterations)) * 1000 // 轉換為毫秒

        print("   - 計算 121 個路口距離的平均時間: \(String(format: "%.2f", avgTime))ms")
        print("   - 每秒可執行: \(Int(1000 / avgTime)) 次")

        if avgTime < 50 {
            print("   ✅ 效能表現良好（<50ms）")
        } else {
            print("   ⚠️  效能需要優化")
        }
    }

    /// 執行所有測試
    func runAllTests() {
        print("🧪 開始執行 LocationService 測試")
        print("================================")
        print("⚠️  注意：此測試需要在實體 iOS 裝置上執行")
        print("⚠️  建議在實際道路環境中測試")
        print("")

        testLocationAuthorization()

        print("\n📝 請按照以下順序執行測試：")
        print("   1. testBackgroundLocationUpdates() - 開始監控")
        print("   2. testWithGoogleMapsNavigation() - 導航測試")
        print("   3. testShowStatistics() - 查看結果")
        print("   4. testGeofencingLimits() - 效能測試")

        print("\n================================")
        print("✅ 測試說明完成")
    }

    // MARK: - Helper Methods

    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: date)
    }

    func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return "\(minutes) 分 \(seconds) 秒"
    }
}

// MARK: - 執行測試

// 在實體裝置上的 SwiftUI View 中執行：
/*
struct LocationTestView: View {
    let tests = LocationServiceTests()

    var body: some View {
        VStack(spacing: 20) {
            Button("開始測試") {
                tests.runAllTests()
            }

            Button("啟動監控") {
                tests.testBackgroundLocationUpdates()
            }

            Button("查看統計") {
                tests.testShowStatistics()
            }
        }
    }
}
*/
