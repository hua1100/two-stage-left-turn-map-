import Foundation
import CoreLocation
import Combine

/// 位置服務：管理背景位置追蹤與路口監控
class LocationService: NSObject, ObservableObject {

    // MARK: - Published Properties

    @Published var currentLocation: CLLocation?
    @Published var currentCourse: CLLocationDirection = 0
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var isMonitoring: Bool = false

    // MARK: - Private Properties

    private let locationManager = CLLocationManager()
    private var intersections: [Intersection] = []

    /// 方向匹配器
    private let directionMatcher: DirectionMatcher

    /// 語音警示服務
    private let voiceAlertService: VoiceAlertService

    /// 已警示的路口 ID 集合（用於避免重複警示）
    private var alertedIntersections: Set<Int> = []

    /// 上次清除警示記錄的時間
    private var lastClearTime: Date = Date()

    // MARK: - Configuration

    /// 位置更新距離閾值（公尺）
    private let distanceFilter: Double = 20.0

    /// 位置精度
    private let desiredAccuracy: CLLocationAccuracy = kCLLocationAccuracyBest

    /// 清除警示記錄的時間間隔（秒）- 避免長時間累積過多記錄
    private let clearAlertInterval: TimeInterval = 300.0 // 5 分鐘

    // MARK: - Initialization

    init(
        directionMatcher: DirectionMatcher = DirectionMatcher(),
        voiceAlertService: VoiceAlertService = VoiceAlertService()
    ) {
        self.directionMatcher = directionMatcher
        self.voiceAlertService = voiceAlertService
        super.init()

        setupLocationManager()
    }

    // MARK: - Setup

    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = desiredAccuracy
        locationManager.distanceFilter = distanceFilter

        // 背景位置更新配置
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.showsBackgroundLocationIndicator = true

        // 更新授權狀態
        authorizationStatus = locationManager.authorizationStatus
    }

    // MARK: - Public Methods

    /// 請求位置權限
    func requestAuthorization() {
        // 請求「使用期間」和「始終」權限
        locationManager.requestAlwaysAuthorization()
    }

    /// 載入路口資料
    func loadIntersections(_ intersections: [Intersection]) {
        self.intersections = intersections
        print("✅ 已載入 \(intersections.count) 個路口資料")
    }

    /// 開始監控
    func startMonitoring() {
        guard authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse else {
            print("❌ 位置權限不足，無法開始監控")
            return
        }

        locationManager.startUpdatingLocation()
        isMonitoring = true
        print("🚀 開始背景位置監控")
    }

    /// 停止監控
    func stopMonitoring() {
        locationManager.stopUpdatingLocation()
        isMonitoring = false
        alertedIntersections.removeAll()
        print("⏸️ 停止背景位置監控")
    }

    // MARK: - Private Methods

    /// 檢查並警示附近的路口
    private func checkNearbyIntersections(location: CLLocation, course: CLLocationDirection) {
        // 定期清除警示記錄
        if Date().timeIntervalSince(lastClearTime) > clearAlertInterval {
            alertedIntersections.removeAll()
            lastClearTime = Date()
            print("🧹 清除警示記錄")
        }

        for intersection in intersections {
            // 跳過已警示的路口
            guard !alertedIntersections.contains(intersection.id) else {
                continue
            }

            // 計算距離
            let intersectionLocation = CLLocation(
                latitude: intersection.latitude,
                longitude: intersection.longitude
            )
            let distance = location.distance(from: intersectionLocation)

            // 使用方向匹配器判斷是否應該警示
            if directionMatcher.shouldAlert(
                userLocation: location,
                userCourse: course,
                intersection: intersection
            ) {
                // 發出警示
                voiceAlertService.alert(for: intersection, distance: distance)

                // 記錄已警示
                alertedIntersections.insert(intersection.id)

                print("📍 觸發警示 - 路口: \(intersection.displayName), 距離: \(Int(distance))m, 方向: \(Int(course))°")
            }
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationService: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        // 更新當前位置
        currentLocation = location

        // 更新當前方向（course）
        if location.course >= 0 {
            currentCourse = location.course
        }

        // 檢查附近路口
        if isMonitoring {
            checkNearbyIntersections(location: location, course: currentCourse)
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus

        print("🔐 位置權限狀態變更: \(authorizationStatusString)")

        // 如果權限被撤銷，停止監控
        if authorizationStatus == .denied || authorizationStatus == .restricted {
            stopMonitoring()
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❌ 位置更新錯誤: \(error.localizedDescription)")
    }

    // MARK: - Helper

    private var authorizationStatusString: String {
        switch authorizationStatus {
        case .notDetermined: return "未決定"
        case .restricted: return "受限"
        case .denied: return "拒絕"
        case .authorizedAlways: return "始終允許"
        case .authorizedWhenInUse: return "使用期間允許"
        @unknown default: return "未知"
        }
    }
}
