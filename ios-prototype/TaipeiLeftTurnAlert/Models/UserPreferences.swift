import Foundation
import Combine

/// 使用者偏好設定
/// 使用 UserDefaults 持久化儲存使用者的個人化設定
class UserPreferences: ObservableObject {

    // MARK: - Singleton

    static let shared = UserPreferences()

    // MARK: - UserDefaults Keys

    private enum Keys {
        static let voiceEnabled = "voiceEnabled"
        static let speechRate = "speechRate"
        static let volume = "volume"
        static let alertDistance = "alertDistance"
        static let directionTolerance = "directionTolerance"
        static let minimumAlertInterval = "minimumAlertInterval"
    }

    // MARK: - Published Properties

    /// 語音警示開關
    @Published var voiceEnabled: Bool {
        didSet {
            UserDefaults.standard.set(voiceEnabled, forKey: Keys.voiceEnabled)
            print("💾 語音開關: \(voiceEnabled ? "開啟" : "關閉")")
        }
    }

    /// 語速（0.3 - 0.7）
    /// 0.3 = 慢速，0.5 = 正常，0.7 = 快速
    @Published var speechRate: Float {
        didSet {
            let clamped = clamp(speechRate, min: 0.3, max: 0.7)
            if clamped != speechRate {
                speechRate = clamped
                return
            }
            UserDefaults.standard.set(speechRate, forKey: Keys.speechRate)
            print("💾 語速: \(speechRate)")
        }
    }

    /// 音量（0.5 - 1.0）
    @Published var volume: Float {
        didSet {
            let clamped = clamp(volume, min: 0.5, max: 1.0)
            if clamped != volume {
                volume = clamped
                return
            }
            UserDefaults.standard.set(volume, forKey: Keys.volume)
            print("💾 音量: \(volume)")
        }
    }

    /// 警示距離（100 - 200 公尺）
    @Published var alertDistance: Double {
        didSet {
            let clamped = clamp(alertDistance, min: 100.0, max: 200.0)
            if clamped != alertDistance {
                alertDistance = clamped
                return
            }
            UserDefaults.standard.set(alertDistance, forKey: Keys.alertDistance)
            print("💾 警示距離: \(Int(alertDistance))m")
        }
    }

    /// 方向匹配容許誤差（20 - 45 度）
    @Published var directionTolerance: Double {
        didSet {
            let clamped = clamp(directionTolerance, min: 20.0, max: 45.0)
            if clamped != directionTolerance {
                directionTolerance = clamped
                return
            }
            UserDefaults.standard.set(directionTolerance, forKey: Keys.directionTolerance)
            print("💾 方向容許誤差: \(Int(directionTolerance))°")
        }
    }

    /// 最小警示間隔（15 - 60 秒）
    @Published var minimumAlertInterval: Double {
        didSet {
            let clamped = clamp(minimumAlertInterval, min: 15.0, max: 60.0)
            if clamped != minimumAlertInterval {
                minimumAlertInterval = clamped
                return
            }
            UserDefaults.standard.set(minimumAlertInterval, forKey: Keys.minimumAlertInterval)
            print("💾 最小警示間隔: \(Int(minimumAlertInterval))秒")
        }
    }

    // MARK: - Initialization

    private init() {
        // 從 UserDefaults 載入設定，若無則使用預設值
        self.voiceEnabled = UserDefaults.standard.object(forKey: Keys.voiceEnabled) as? Bool ?? true

        self.speechRate = UserDefaults.standard.object(forKey: Keys.speechRate) as? Float ?? 0.5

        self.volume = UserDefaults.standard.object(forKey: Keys.volume) as? Float ?? 1.0

        self.alertDistance = UserDefaults.standard.object(forKey: Keys.alertDistance) as? Double ?? 150.0

        self.directionTolerance = UserDefaults.standard.object(forKey: Keys.directionTolerance) as? Double ?? 30.0

        self.minimumAlertInterval = UserDefaults.standard.object(forKey: Keys.minimumAlertInterval) as? Double ?? 30.0

        print("✅ 使用者偏好設定已載入")
        printCurrentSettings()
    }

    // MARK: - Public Methods

    /// 重設為預設值
    func resetToDefaults() {
        voiceEnabled = true
        speechRate = 0.5
        volume = 1.0
        alertDistance = 150.0
        directionTolerance = 30.0
        minimumAlertInterval = 30.0

        print("🔄 已重設為預設值")
        printCurrentSettings()
    }

    /// 列印當前設定
    func printCurrentSettings() {
        print("""
        📱 當前設定：
           - 語音開關: \(voiceEnabled ? "✅ 開啟" : "❌ 關閉")
           - 語速: \(speechRate) (0.3慢 - 0.7快)
           - 音量: \(volume) (0.5 - 1.0)
           - 警示距離: \(Int(alertDistance))m (100-200)
           - 方向容許誤差: \(Int(directionTolerance))° (20-45)
           - 最小警示間隔: \(Int(minimumAlertInterval))秒 (15-60)
        """)
    }

    /// 驗證所有設定值是否在有效範圍內
    func validateSettings() -> Bool {
        let validations = [
            (speechRate >= 0.3 && speechRate <= 0.7, "語速"),
            (volume >= 0.5 && volume <= 1.0, "音量"),
            (alertDistance >= 100.0 && alertDistance <= 200.0, "警示距離"),
            (directionTolerance >= 20.0 && directionTolerance <= 45.0, "方向容許誤差"),
            (minimumAlertInterval >= 15.0 && minimumAlertInterval <= 60.0, "最小警示間隔")
        ]

        for (isValid, name) in validations {
            if !isValid {
                print("⚠️ 設定值超出範圍: \(name)")
                return false
            }
        }

        return true
    }

    // MARK: - Helper Methods

    /// 限制數值範圍
    private func clamp<T: Comparable>(_ value: T, min: T, max: T) -> T {
        return Swift.max(min, Swift.min(max, value))
    }
}

// MARK: - Preset Configurations

extension UserPreferences {

    /// 預設配置
    enum Preset {
        case conservative  // 保守（距離遠、容許誤差大）
        case standard      // 標準（預設值）
        case aggressive    // 積極（距離近、容許誤差小）

        var settings: (alertDistance: Double, directionTolerance: Double) {
            switch self {
            case .conservative:
                return (200.0, 45.0)
            case .standard:
                return (150.0, 30.0)
            case .aggressive:
                return (100.0, 20.0)
            }
        }

        var description: String {
            switch self {
            case .conservative:
                return "保守模式：提早警示，方向容許度高"
            case .standard:
                return "標準模式：平衡的警示時機與準確度"
            case .aggressive:
                return "積極模式：接近時警示，方向要求精準"
            }
        }
    }

    /// 套用預設配置
    func applyPreset(_ preset: Preset) {
        let settings = preset.settings
        alertDistance = settings.alertDistance
        directionTolerance = settings.directionTolerance

        print("🎯 已套用預設配置: \(preset.description)")
    }
}
