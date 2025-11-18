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
                    // 位置權限請求按鈕
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

                    // 測試語音按鈕
                    Button(action: {
                        testVoice()
                    }) {
                        Label("測試語音", systemImage: "speaker.wave.2")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }

                    // 開始/停止監控按鈕
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

    // MARK: - 輔助屬性

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

    // MARK: - 功能函數

    /// 測試語音功能
    private func testVoice() {
        // 建立測試路口
        let testIntersection = Intersection(
            id: 1,
            district: "大同",
            intersection: "承德路與市民大道",
            direction: "北往東",
            openedYear: "98年以前",
            latitude: 25.052856,
            longitude: 121.516831,
            geocoded: true,
            geocodeSource: "test"
        )

        // 發出測試語音
        let voiceService = VoiceAlertService()
        voiceService.alert(for: testIntersection, distance: 100)

        print("🔊 測試語音：前方一百公尺承德路與市民大道可直接左轉")
    }

    /// 載入測試資料
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

// MARK: - 狀態列元件

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

// MARK: - 預覽

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
