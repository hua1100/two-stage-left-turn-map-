import Foundation
import AVFoundation

/// 語音警示服務：使用繁體中文 TTS 發出路口提示
class VoiceAlertService: NSObject {

    // MARK: - Properties

    private let synthesizer = AVSpeechSynthesizer()
    private var audioSession: AVAudioSession?

    /// 使用者偏好設定
    private let preferences = UserPreferences.shared

    /// 上次警示的路口 ID
    private var lastAlertedIntersectionId: Int?

    /// 上次警示時間
    private var lastAlertTime: Date?

    // MARK: - Initialization

    override init() {
        super.init()
        synthesizer.delegate = self
        setupAudioSession()
    }

    // MARK: - Audio Session Setup

    /// 設定音訊會話，確保不會中斷導航語音
    private func setupAudioSession() {
        audioSession = AVAudioSession.sharedInstance()

        do {
            // 使用 .duckOthers 選項：播放時將其他音訊（如導航）降低音量，而非完全中斷
            try audioSession?.setCategory(
                .playback,
                mode: .voicePrompt,
                options: [.duckOthers, .interruptSpokenAudioAndMixWithOthers]
            )
            try audioSession?.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("❌ 音訊會話設定失敗: \(error.localizedDescription)")
        }
    }

    // MARK: - Alert Methods

    /// 發出路口警示
    /// - Parameters:
    ///   - intersection: 路口資料
    ///   - distance: 距離路口的距離（公尺）
    func alert(for intersection: Intersection, distance: Double) {
        // 檢查是否啟用
        guard preferences.voiceEnabled else { return }

        // 檢查是否在最小間隔時間內重複警示同一路口
        if let lastId = lastAlertedIntersectionId,
           lastId == intersection.id,
           let lastTime = lastAlertTime,
           Date().timeIntervalSince(lastTime) < preferences.minimumAlertInterval {
            print("⏭️ 跳過重複警示: \(intersection.displayName)")
            return
        }

        // 產生語音文本
        let message = generateAlertMessage(for: intersection, distance: distance)

        // 發出語音
        speak(message)

        // 記錄警示
        lastAlertedIntersectionId = intersection.id
        lastAlertTime = Date()

        print("🔊 語音警示: \(message)")
    }

    /// 產生警示訊息文本
    private func generateAlertMessage(for intersection: Intersection, distance: Double) -> String {
        let roundedDistance = Int(distance)

        if roundedDistance <= 50 {
            return "前方\(intersection.displayName)可直接左轉"
        } else if roundedDistance <= 100 {
            return "前方一百公尺\(intersection.displayName)可直接左轉"
        } else {
            return "前方\(roundedDistance)公尺\(intersection.displayName)可直接左轉"
        }
    }

    /// 發出語音
    private func speak(_ text: String) {
        // 停止當前正在播放的語音
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }

        let utterance = AVSpeechUtterance(string: text)

        // 設定繁體中文語音
        utterance.voice = AVSpeechSynthesisVoice(language: "zh-TW")

        // 設定語速和音量（從使用者偏好讀取）
        utterance.rate = preferences.speechRate
        utterance.volume = preferences.volume

        // 稍微降低音調，讓聲音更穩重
        utterance.pitchMultiplier = 0.9

        // 發音
        synthesizer.speak(utterance)
    }

    /// 停止所有語音
    func stopSpeaking() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
    }

    /// 重設警示狀態（用於測試或手動重置）
    func resetAlertState() {
        lastAlertedIntersectionId = nil
        lastAlertTime = nil
    }
}

// MARK: - AVSpeechSynthesizerDelegate

extension VoiceAlertService: AVSpeechSynthesizerDelegate {

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        print("🎤 開始語音播放")
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        print("✅ 語音播放完成")

        // 恢復音訊會話（讓其他 app 的音訊恢復正常音量）
        do {
            try audioSession?.setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            print("⚠️ 音訊會話恢復失敗: \(error.localizedDescription)")
        }
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        print("⏹️ 語音播放已取消")
    }
}
