import SwiftUI

/// 台北市左轉提示 App 入口
@main
struct TaipeiLeftTurnAlertApp: App {

    // MARK: - Properties

    /// 初始化時設定服務
    init() {
        // 預載入路口資料
        IntersectionDataService.shared.loadIntersections()

        // 初始化使用者偏好設定
        _ = UserPreferences.shared

        print("✅ 台北市左轉提示 App 啟動")
        print("📍 路口資料：\(IntersectionDataService.shared.intersections.count) 個")
        UserPreferences.shared.printCurrentSettings()
    }

    // MARK: - Scene

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
