import Foundation
import Combine

/// 設定視圖模型
/// 管理使用者偏好設定與 UI 綁定
class SettingsViewModel: ObservableObject {

    // MARK: - Published Properties

    /// 語音警示開關
    @Published var voiceEnabled: Bool {
        didSet {
            preferences.voiceEnabled = voiceEnabled
        }
    }

    /// 語速（0.3 - 0.7）
    @Published var speechRate: Float {
        didSet {
            preferences.speechRate = speechRate
        }
    }

    /// 音量（0.5 - 1.0）
    @Published var volume: Float {
        didSet {
            preferences.volume = volume
        }
    }

    /// 警示距離（100 - 200m）
    @Published var alertDistance: Double {
        didSet {
            preferences.alertDistance = alertDistance
        }
    }

    /// 方向容許誤差（20 - 45°）
    @Published var directionTolerance: Double {
        didSet {
            preferences.directionTolerance = directionTolerance
        }
    }

    /// 最小警示間隔（15 - 60 秒）
    @Published var minimumAlertInterval: Double {
        didSet {
            preferences.minimumAlertInterval = minimumAlertInterval
        }
    }

    /// 顯示進階設定
    @Published var showAdvancedSettings = false

    /// 顯示關於頁面
    @Published var showAboutPage = false

    /// 測試語音訊息
    @Published var testMessage: String?

    // MARK: - Services

    private let preferences = UserPreferences.shared
    private let voiceService = VoiceAlertService()

    // MARK: - Computed Properties

    /// 語速描述文字
    var speechRateDescription: String {
        switch speechRate {
        case 0.3..<0.4:
            return "慢速"
        case 0.4..<0.6:
            return "正常"
        case 0.6...0.7:
            return "快速"
        default:
            return "正常"
        }
    }

    /// 音量百分比
    var volumePercentage: Int {
        Int(volume * 100)
    }

    /// 警示距離描述
    var alertDistanceDescription: String {
        "\(Int(alertDistance)) 公尺"
    }

    /// 方向容許誤差描述
    var directionToleranceDescription: String {
        "\(Int(directionTolerance))°"
    }

    /// 最小警示間隔描述
    var minimumAlertIntervalDescription: String {
        "\(Int(minimumAlertInterval)) 秒"
    }

    // MARK: - Initialization

    init() {
        // 從 UserPreferences 載入當前設定
        self.voiceEnabled = preferences.voiceEnabled
        self.speechRate = preferences.speechRate
        self.volume = preferences.volume
        self.alertDistance = preferences.alertDistance
        self.directionTolerance = preferences.directionTolerance
        self.minimumAlertInterval = preferences.minimumAlertInterval
    }

    // MARK: - Actions

    /// 測試語音
    func testVoice() {
        // 建立測試用路口
        let testIntersection = Intersection(
            id: 45,
            district: "中正",
            intersection: "公園路與襄陽路",
            direction: "南往西、西往北",
            openedYear: "104年",
            latitude: 25.046696,
            longitude: 121.5177415,
            geocoded: true,
            geocodeSource: "manual"
        )

        // 發出測試語音
        voiceService.alert(for: testIntersection, distance: 100)

        // 顯示測試訊息
        testMessage = "已發出測試語音"

        // 3 秒後清除訊息
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.testMessage = nil
        }
    }

    /// 重設為預設值
    func resetToDefaults() {
        preferences.resetToDefaults()

        // 更新 UI
        voiceEnabled = preferences.voiceEnabled
        speechRate = preferences.speechRate
        volume = preferences.volume
        alertDistance = preferences.alertDistance
        directionTolerance = preferences.directionTolerance
        minimumAlertInterval = preferences.minimumAlertInterval

        testMessage = "已重設為預設值"

        // 3 秒後清除訊息
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.testMessage = nil
        }
    }

    /// 套用預設配置
    func applyPreset(_ preset: UserPreferences.Preset) {
        preferences.applyPreset(preset)

        // 更新 UI（只更新會變動的參數）
        alertDistance = preferences.alertDistance
        directionTolerance = preferences.directionTolerance

        testMessage = "已套用：\(preset.description)"

        // 3 秒後清除訊息
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.testMessage = nil
        }
    }

    /// 驗證設定值
    func validateSettings() -> Bool {
        return preferences.validateSettings()
    }
}
