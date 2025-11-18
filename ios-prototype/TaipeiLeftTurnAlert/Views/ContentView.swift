import SwiftUI
import CoreLocation

/// 主視圖
/// 使用 TabView 整合地圖、監控與設定頁面
struct ContentView: View {

    // MARK: - Properties

    @StateObject private var locationService = LocationService.shared
    @State private var selectedTab = 0
    @State private var showDebugView = false

    // MARK: - Body

    var body: some View {
        TabView(selection: $selectedTab) {
            // 地圖頁面
            MapView()
                .tabItem {
                    Label("地圖", systemImage: "map.fill")
                }
                .tag(0)

            // 監控頁面
            MonitorView()
                .tabItem {
                    Label("監控", systemImage: "antenna.radiowaves.left.and.right")
                }
                .tag(1)

            // 設定頁面
            SettingsView()
                .tabItem {
                    Label("設定", systemImage: "gearshape.fill")
                }
                .tag(2)
        }
        .onAppear {
            // 啟動時載入路口資料（使用 async 避免在 View 更新期間修改 @Published）
            DispatchQueue.main.async {
                IntersectionDataService.shared.loadIntersections()
            }
        }
    }
}

// MARK: - MonitorView

/// 監控頁面
/// 顯示即時定位狀態與監控控制
struct MonitorView: View {

    // MARK: - Properties

    @StateObject private var locationService = LocationService.shared
    @State private var isMonitoring = false

    // MARK: - Body

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // 標題
                Text("即時監控")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top)

                // 狀態顯示
                VStack(alignment: .leading, spacing: 10) {
                    StatusRow(title: "監控狀態", value: isMonitoring ? "🟢 運行中" : "⚪️ 已停止")
                    StatusRow(title: "位置權限", value: authorizationStatusText)

                    if let location = locationService.currentLocation {
                        StatusRow(title: "當前位置",
                                  value: String(format: "%.6f, %.6f",
                                                location.coordinate.latitude,
                                                location.coordinate.longitude))
                        StatusRow(title: "當前方向", value: "\(Int(locationService.currentCourse))°")
                        StatusRow(title: "定位精度", value: "\(Int(location.horizontalAccuracy))m")
                        StatusRow(title: "速度", value: String(format: "%.1f km/h", location.speed * 3.6))
                    } else {
                        StatusRow(title: "當前位置", value: "等待定位...")
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .padding(.horizontal)

                // 附近路口
                if isMonitoring {
                    nearbyIntersectionsSection
                }

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
                        toggleMonitoring()
                    }) {
                        Label(isMonitoring ? "停止監控" : "開始監控",
                              systemImage: isMonitoring ? "stop.circle" : "play.circle")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isMonitoring ? Color.red : Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(!isAuthorized)
                }
                .padding()
            }
            .navigationTitle("路口監控")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Subviews

    /// 附近路口區塊
    private var nearbyIntersectionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("附近路口")
                .font(.headline)
                .padding(.horizontal)

            if let userLocation = locationService.currentLocation {
                let nearby = findNearbyIntersections(userLocation: userLocation)

                if nearby.isEmpty {
                    Text("附近沒有可直接左轉的路口")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                } else {
                    ScrollView {
                        VStack(spacing: 8) {
                            ForEach(nearby, id: \.id) { intersection in
                                NearbyIntersectionRow(
                                    intersection: intersection,
                                    userLocation: userLocation
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
        .padding(.vertical)
        .background(Color.blue.opacity(0.05))
        .cornerRadius(12)
        .padding(.horizontal)
    }

    // MARK: - Helper Properties

    private var isAuthorized: Bool {
        locationService.authorizationStatus == CLAuthorizationStatus.authorizedAlways ||
        locationService.authorizationStatus == CLAuthorizationStatus.authorizedWhenInUse
    }

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

    // MARK: - Helper Methods

    /// 測試語音功能
    private func testVoice() {
        let testIntersection = Intersection(
            id: 45,
            district: "中正",
            intersection: "公園路與襄陽路",
            direction: "南往西、西往北",
            openedYear: "104年",
            latitude: 25.046696,
            longitude: 121.5177415,
            geocoded: true,
            geocodeSource: "test"
        )

        let voiceService = VoiceAlertService()
        voiceService.alert(for: testIntersection, distance: 100)

        print("🔊 測試語音：前方一百公尺公園路與襄陽路可直接左轉")
    }

    /// 切換監控狀態
    private func toggleMonitoring() {
        if isMonitoring {
            locationService.stopMonitoring()
            isMonitoring = false
        } else {
            // 載入路口資料
            let intersections = IntersectionDataService.shared.intersections
            locationService.loadIntersections(intersections)

            locationService.startMonitoring()
            isMonitoring = true

            print("✅ 已載入 \(intersections.count) 個路口，開始監控")
        }
    }

    /// 尋找附近路口
    private func findNearbyIntersections(userLocation: CLLocation, radius: Double = 1000) -> [Intersection] {
        let allIntersections = IntersectionDataService.shared.intersections

        return allIntersections.filter { intersection in
            let distance = userLocation.distance(from: CLLocation(
                latitude: intersection.latitude,
                longitude: intersection.longitude
            ))
            return distance <= radius
        }.sorted { a, b in
            let distanceA = userLocation.distance(from: CLLocation(latitude: a.latitude, longitude: a.longitude))
            let distanceB = userLocation.distance(from: CLLocation(latitude: b.latitude, longitude: b.longitude))
            return distanceA < distanceB
        }.prefix(5).map { $0 }
    }
}

// MARK: - NearbyIntersectionRow

/// 附近路口列元件
struct NearbyIntersectionRow: View {
    let intersection: Intersection
    let userLocation: CLLocation

    private var distance: Double {
        userLocation.distance(from: CLLocation(
            latitude: intersection.latitude,
            longitude: intersection.longitude
        ))
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(intersection.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)  // 加入明確的顏色

                Text(intersection.direction)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text("\(Int(distance))m")
                .font(.caption)
                .foregroundColor(.blue)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
        }
        .padding()
        .background(Color(UIColor.systemBackground))  // 使用系統背景色
        .cornerRadius(8)
        .shadow(radius: 2)
    }
}

// MARK: - StatusRow

/// 狀態列元件
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

// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewDevice("iPhone 15")
    }
}
