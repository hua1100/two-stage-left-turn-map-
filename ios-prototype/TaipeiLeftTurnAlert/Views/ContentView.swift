import SwiftUI
import CoreLocation

/// 主視圖
/// 使用 TabView 整合地圖、監控與設定頁面
struct ContentView: View {

    // MARK: - Properties

    @StateObject private var locationService = LocationService.shared
    @State private var selectedTab = 1  // 預設顯示騎行頁面（騎車時最重要）
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

            // 騎行頁面
            RideView()
                .tabItem {
                    Label("騎行", systemImage: "bicycle")
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

// MARK: - RideView

/// 騎行頁面
/// 顯示兩段式左轉路牌與騎行狀態
struct RideView: View {

    // MARK: - Properties

    @StateObject private var locationService = LocationService.shared
    @State private var isRiding = false

    // MARK: - Body

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 兩段式左轉路牌
                if !isRiding {
                    VStack(spacing: 20) {
                        Spacer()

                        // 路牌圖示
                        twoStageLeftTurnSign

                        Text("台北市兩段式左轉導航")
                            .font(.title2)
                            .fontWeight(.bold)

                        Text("開始騎行後，接近可直接左轉路口時會自動語音提示")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)

                        Spacer()
                    }
                }

                // 騎行中的狀態顯示
                if isRiding {
                    ScrollView {
                        VStack(spacing: 20) {
                            // 狀態資訊
                            statusInfoSection

                            // 附近路口
                            nearbyIntersectionsSection
                        }
                        .padding(.vertical)
                    }
                }

                // 底部按鈕
                VStack(spacing: 12) {
                    Button(action: {
                        toggleRiding()
                    }) {
                        Label(isRiding ? "停止騎行" : "開始騎行",
                              systemImage: isRiding ? "stop.circle.fill" : "play.circle.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isRiding ? Color.red : Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                }
                .padding()
                .background(Color(UIColor.systemBackground))
                .shadow(radius: 3)
            }
            .navigationTitle("騎行")
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: locationService.authorizationStatus) { newStatus in
                // 當權限狀態改變時，如果剛授予權限且不在騎行中，自動開始
                // 使用 async 避免在視圖更新中發布變更
                if !isRiding && isAuthorized {
                    DispatchQueue.main.async {
                        startRiding()
                    }
                }
            }
        }
    }

    // MARK: - Subviews

    /// 兩段式左轉路牌圖示
    private var twoStageLeftTurnSign: some View {
        ZStack {
            // 路牌背景
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.green)
                .frame(width: 200, height: 200)
                .shadow(radius: 10)

            VStack(spacing: 8) {
                // 左轉箭頭
                Image(systemName: "arrow.turn.up.left")
                    .font(.system(size: 60, weight: .bold))
                    .foregroundColor(.white)

                // 文字說明
                VStack(spacing: 4) {
                    Text("兩段式")
                        .font(.title3)
                        .fontWeight(.bold)
                    Text("左轉")
                        .font(.title2)
                        .fontWeight(.heavy)
                }
                .foregroundColor(.white)
            }
        }
    }

    /// 狀態資訊區塊
    private var statusInfoSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let location = locationService.currentLocation {
                StatusRow(title: "當前方向", value: "\(Int(locationService.currentCourse))°")
                StatusRow(title: "定位精度", value: "\(Int(location.horizontalAccuracy))m")

                // 速度處理：負值表示無效，顯示為 0
                let speed = max(0, location.speed) * 3.6
                StatusRow(title: "速度", value: String(format: "%.1f km/h", speed))
            } else {
                StatusRow(title: "定位狀態", value: "等待定位...")
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
        .padding(.horizontal)
    }

    /// 附近路口區塊
    private var nearbyIntersectionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("附近可直接左轉路口")
                .font(.headline)
                .padding(.horizontal)

            if let userLocation = locationService.currentLocation {
                let nearby = findNearbyIntersections(userLocation: userLocation)

                if nearby.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "checkmark.circle")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                        Text("附近沒有可直接左轉的路口")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                } else {
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

    // MARK: - Helper Methods

    /// 切換騎行狀態
    private func toggleRiding() {
        if isRiding {
            // 停止騎行
            locationService.stopMonitoring()
            isRiding = false
            print("🛑 停止騎行")
        } else {
            // 開始騎行
            // 先檢查權限狀態
            if locationService.authorizationStatus == .notDetermined {
                // 沒有權限，先請求
                locationService.requestAuthorization()
                // 等待使用者回應後再啟動（透過 LocationService 的 delegate）
                // 暫時標記為等待中
                print("📍 請求位置權限...")
            } else if isAuthorized {
                // 已有權限，直接開始
                startRiding()
            } else {
                // 權限被拒絕
                print("❌ 位置權限被拒絕，無法開始騎行")
            }
        }
    }

    /// 開始騎行
    private func startRiding() {
        // 載入路口資料
        let intersections = IntersectionDataService.shared.intersections
        locationService.loadIntersections(intersections)

        // 開始定位
        locationService.startMonitoring()
        isRiding = true

        print("✅ 已載入 \(intersections.count) 個路口，開始騎行")
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
