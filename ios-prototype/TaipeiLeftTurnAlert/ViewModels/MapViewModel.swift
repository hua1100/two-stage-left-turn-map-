import Foundation
import MapKit
import CoreLocation
import Combine

/// 地圖視圖模型
/// 管理地圖狀態、路口標記、使用者位置等
class MapViewModel: NSObject, ObservableObject {

    // MARK: - Published Properties

    /// 地圖區域
    @Published var region: MKCoordinateRegion

    /// 路口標記
    @Published var intersectionAnnotations: [IntersectionAnnotation] = []

    /// 選中的路口
    @Published var selectedIntersection: Intersection?

    /// 顯示路口詳情
    @Published var showIntersectionDetail = false

    /// 使用者當前位置
    @Published var userLocation: CLLocationCoordinate2D?

    /// 錯誤訊息
    @Published var errorMessage: String?

    /// 搜尋關鍵字
    @Published var searchKeyword: String = ""

    /// 篩選後的路口
    @Published var filteredIntersections: [Intersection] = []

    // MARK: - Services

    private let dataService = IntersectionDataService.shared
    private let locationService = LocationService.shared

    // MARK: - Private Properties

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    override init() {
        // 預設顯示台北市中心區域
        self.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 25.0330, longitude: 121.5654),
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )

        super.init()

        setupBindings()
        loadIntersections()
        observeUserLocation()
    }

    // MARK: - Setup

    /// 設定資料綁定
    private func setupBindings() {
        // 監聽資料服務的路口資料變化
        dataService.$intersections
            .sink { [weak self] intersections in
                self?.updateAnnotations(with: intersections)
                self?.filteredIntersections = intersections
            }
            .store(in: &cancellables)

        // 監聽搜尋關鍵字變化
        $searchKeyword
            .debounce(for: 0.3, scheduler: DispatchQueue.main)
            .sink { [weak self] keyword in
                self?.filterIntersections(keyword: keyword)
            }
            .store(in: &cancellables)
    }

    /// 監聽使用者位置
    private func observeUserLocation() {
        locationService.$currentLocation
            .compactMap { $0?.coordinate }
            .sink { [weak self] coordinate in
                self?.userLocation = coordinate
            }
            .store(in: &cancellables)
    }

    // MARK: - Data Loading

    /// 載入路口資料
    func loadIntersections() {
        dataService.loadIntersections()
    }

    /// 更新地圖標記
    private func updateAnnotations(with intersections: [Intersection]) {
        self.intersectionAnnotations = intersections.map { intersection in
            IntersectionAnnotation(intersection: intersection)
        }
    }

    /// 篩選路口
    private func filterIntersections(keyword: String) {
        if keyword.isEmpty {
            filteredIntersections = dataService.intersections
        } else {
            filteredIntersections = dataService.searchIntersections(keyword: keyword)
        }
        updateAnnotations(with: filteredIntersections)
    }

    // MARK: - User Actions

    /// 選擇路口
    func selectIntersection(_ intersection: Intersection) {
        selectedIntersection = intersection
        showIntersectionDetail = true

        // 將地圖中心移動到選中的路口
        centerMap(on: intersection.coordinate)
    }

    /// 取消選擇
    func deselectIntersection() {
        selectedIntersection = nil
        showIntersectionDetail = false
    }

    /// 將地圖中心移動到指定座標
    func centerMap(on coordinate: CLLocationCoordinate2D, span: MKCoordinateSpan? = nil) {
        withAnimation {
            region = MKCoordinateRegion(
                center: coordinate,
                span: span ?? MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        }
    }

    /// 顯示所有路口
    func showAllIntersections() {
        guard !dataService.intersections.isEmpty else { return }

        // 計算包含所有路口的區域
        let coordinates = dataService.intersections.map { $0.coordinate }
        let mapRect = coordinates.reduce(MKMapRect.null) { rect, coordinate in
            let point = MKMapPoint(coordinate)
            let pointRect = MKMapRect(x: point.x, y: point.y, width: 0, height: 0)
            return rect.union(pointRect)
        }

        // 加上邊距
        let insetRect = mapRect.insetBy(dx: -mapRect.size.width * 0.1, dy: -mapRect.size.height * 0.1)

        withAnimation {
            region = MKCoordinateRegion(insetRect)
        }
    }

    /// 移動到使用者位置
    func centerOnUserLocation() {
        guard let userLocation = userLocation else {
            errorMessage = "無法取得您的位置"
            return
        }

        centerMap(on: userLocation, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
    }

    /// 尋找附近的路口
    func findNearbyIntersections(radius: Double = 500) -> [Intersection] {
        guard let userLocation = userLocation else { return [] }

        let userCLLocation = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)

        return dataService.intersections.filter { intersection in
            let distance = userCLLocation.distance(from: CLLocation(
                latitude: intersection.latitude,
                longitude: intersection.longitude
            ))
            return distance <= radius
        }.sorted { a, b in
            let distanceA = userCLLocation.distance(from: CLLocation(latitude: a.latitude, longitude: a.longitude))
            let distanceB = userCLLocation.distance(from: CLLocation(latitude: b.latitude, longitude: b.longitude))
            return distanceA < distanceB
        }
    }

    // MARK: - Navigation

    /// 在 Apple Maps 中開啟
    func openInAppleMaps(_ intersection: Intersection) {
        let placemark = MKPlacemark(coordinate: intersection.coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = intersection.displayName
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDefault
        ])
    }

    /// 在 Google Maps 中開啟
    func openInGoogleMaps(_ intersection: Intersection) {
        let urlString = "comgooglemaps://?daddr=\(intersection.latitude),\(intersection.longitude)&directionsmode=driving"

        if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            // 如果沒安裝 Google Maps，使用網頁版
            let webUrlString = "https://www.google.com/maps/dir/?api=1&destination=\(intersection.latitude),\(intersection.longitude)&travelmode=driving"
            if let webUrl = URL(string: webUrlString) {
                UIApplication.shared.open(webUrl)
            }
        }
    }
}

// MARK: - IntersectionAnnotation

/// 路口標記（用於地圖顯示）
class IntersectionAnnotation: NSObject, Identifiable {
    let id: Int
    let coordinate: CLLocationCoordinate2D
    let title: String?
    let subtitle: String?
    let intersection: Intersection

    init(intersection: Intersection) {
        self.id = intersection.id
        self.coordinate = intersection.coordinate
        self.title = intersection.displayName
        self.subtitle = intersection.direction
        self.intersection = intersection
        super.init()
    }
}

// MARK: - Extensions

extension MKCoordinateRegion {
    init(_ rect: MKMapRect) {
        let topLeft = MKMapPoint(x: rect.minX, y: rect.minY)
        let bottomRight = MKMapPoint(x: rect.maxX, y: rect.maxY)

        let center = CLLocationCoordinate2D(
            latitude: (topLeft.coordinate.latitude + bottomRight.coordinate.latitude) / 2,
            longitude: (topLeft.coordinate.longitude + bottomRight.coordinate.longitude) / 2
        )

        let span = MKCoordinateSpan(
            latitudeDelta: abs(topLeft.coordinate.latitude - bottomRight.coordinate.latitude),
            longitudeDelta: abs(topLeft.coordinate.longitude - bottomRight.coordinate.longitude)
        )

        self.init(center: center, span: span)
    }
}
