import Foundation
import AVFoundation

/// 語音警示服務測試
///
/// 此測試驗證：
/// 1. AVSpeechSynthesizer 繁體中文語音品質
/// 2. 語音播放不會中斷導航語音
/// 3. 語音延遲時間
///
/// 執行方式：在實體 iOS 裝置上執行（模擬器語音品質較差）

class VoiceAlertServiceTests {

    let voiceService = VoiceAlertService()

    // MARK: - 測試案例

    /// 測試 1：繁體中文語音品質
    func testChineseVoiceQuality() {
        print("\n=== 測試 1：繁體中文語音品質 ===")

        let testIntersections = [
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
            Intersection(
                id: 3, district: "大安", intersection: "復興南路與和平東路",
                direction: "東西雙向", openedYear: "98年以前",
                latitude: 25.025678, longitude: 121.543456,
                geocoded: true, geocodeSource: "manual"
            )
        ]

        let distances: [Double] = [50, 100, 150]

        print("📝 請在實體裝置上執行並評估以下項目：")
        print("   1. 語音是否清晰可聽")
        print("   2. 發音是否正確（特別是路名）")
        print("   3. 語速是否適中")
        print("   4. 音量是否適當")
        print("")

        for (index, intersection) in testIntersections.enumerated() {
            let distance = distances[index % distances.count]
            print("🔊 測試 \(index + 1): \(intersection.displayName) (\(Int(distance))m)")

            voiceService.alert(for: intersection, distance: distance)

            // 等待語音播放完成（實際測試時需要）
            print("   ⏳ 等待 3 秒...")
            Thread.sleep(forTimeInterval: 3.0)
        }

        print("✅ 語音品質測試完成")
    }

    /// 測試 2：語音延遲測試
    func testSpeechLatency() {
        print("\n=== 測試 2：語音延遲測試 ===")

        let intersection = Intersection(
            id: 1, district: "大同", intersection: "承德路與市民大道",
            direction: "北往東", openedYear: "98年以前",
            latitude: 25.052856, longitude: 121.516831,
            geocoded: true, geocodeSource: "manual"
        )

        print("📊 測量從觸發到語音開始播放的延遲時間")
        print("   目標：< 2 秒")
        print("")

        for i in 1...5 {
            voiceService.resetAlertState()

            let startTime = Date()
            voiceService.alert(for: intersection, distance: 100)

            // 實際測試時需要監聽 AVSpeechSynthesizerDelegate 的 didStart 回調
            // 這裡僅示意
            let endTime = Date()
            let latency = endTime.timeIntervalSince(startTime)

            print("🔊 測試 \(i): 延遲 \(String(format: "%.3f", latency)) 秒")

            Thread.sleep(forTimeInterval: 3.0)
        }

        print("✅ 延遲測試完成")
        print("📝 實際延遲需在實體裝置上透過 delegate 回調測量")
    }

    /// 測試 3：重複警示防護
    func testDuplicateAlertPrevention() {
        print("\n=== 測試 3：重複警示防護 ===")

        let intersection = Intersection(
            id: 1, district: "大同", intersection: "承德路與市民大道",
            direction: "北往東", openedYear: "98年以前",
            latitude: 25.052856, longitude: 121.516831,
            geocoded: true, geocodeSource: "manual"
        )

        print("📝 測試同一路口在短時間內不會重複警示")
        print("")

        // 第一次警示 - 應該成功
        print("🔊 第 1 次警示（應成功）")
        voiceService.alert(for: intersection, distance: 100)
        Thread.sleep(forTimeInterval: 2.0)

        // 第二次警示（10秒後）- 應該被跳過
        print("🔊 第 2 次警示 - 10秒後（應被跳過）")
        Thread.sleep(forTimeInterval: 10.0)
        voiceService.alert(for: intersection, distance: 100)

        // 第三次警示（35秒後）- 應該成功
        print("🔊 第 3 次警示 - 35秒後（應成功）")
        Thread.sleep(forTimeInterval: 25.0)
        voiceService.alert(for: intersection, distance: 100)

        print("✅ 重複警示防護測試完成")
    }

    /// 測試 4：音訊會話配置（不會中斷導航）
    func testAudioSessionConfiguration() {
        print("\n=== 測試 4：音訊會話配置測試 ===")

        print("📝 此測試需要手動驗證：")
        print("   1. 開啟 Google Maps 或 Apple Maps 導航")
        print("   2. 執行此 App 並觸發語音警示")
        print("   3. 確認以下項目：")
        print("      - 導航語音音量降低但未中斷")
        print("      - 警示語音播放完成後導航語音恢復正常")
        print("      - 兩個語音不會互相覆蓋")
        print("")

        let intersection = Intersection(
            id: 1, district: "大同", intersection: "承德路與市民大道",
            direction: "北往東", openedYear: "98年以前",
            latitude: 25.052856, longitude: 121.516831,
            geocoded: true, geocodeSource: "manual"
        )

        print("🔊 播放測試語音...")
        voiceService.alert(for: intersection, distance: 100)

        Thread.sleep(forTimeInterval: 3.0)

        print("✅ 音訊會話測試完成")
        print("📝 請手動確認導航語音是否正常")
    }

    /// 執行所有測試
    func runAllTests() {
        print("🧪 開始執行 VoiceAlertService 測試")
        print("================================")
        print("⚠️  注意：此測試需要在實體 iOS 裝置上執行")
        print("⚠️  建議在安靜環境中進行")
        print("")

        testChineseVoiceQuality()
        testSpeechLatency()
        testDuplicateAlertPrevention()
        testAudioSessionConfiguration()

        print("\n================================")
        print("✅ 測試完成")
    }
}

// MARK: - 執行測試

// 在實體裝置上執行：
// let tests = VoiceAlertServiceTests()
// tests.runAllTests()
