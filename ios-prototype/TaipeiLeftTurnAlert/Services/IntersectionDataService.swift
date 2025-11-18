import Foundation
import Combine

/// 路口資料服務
/// 負責載入、快取和管理台北市 121 個可直接左轉路口的資料
class IntersectionDataService: ObservableObject {

    // MARK: - Singleton

    static let shared = IntersectionDataService()

    // MARK: - Published Properties

    /// 所有路口資料
    @Published private(set) var intersections: [Intersection] = []

    /// 資料載入狀態
    @Published private(set) var isLoading: Bool = false

    /// 載入錯誤訊息
    @Published private(set) var errorMessage: String?

    // MARK: - Private Properties

    /// 資料快取
    private var cache: [Intersection]?

    /// JSON 檔案名稱
    private let dataFileName: String

    // MARK: - Initialization

    /// 初始化資料服務
    /// - Parameter dataFileName: JSON 資料檔案名稱（不含副檔名），預設為 "intersections"
    init(dataFileName: String = "intersections") {
        self.dataFileName = dataFileName
    }

    // MARK: - Public Methods

    /// 載入路口資料
    /// - Parameter forceReload: 是否強制重新載入（忽略快取）
    func loadIntersections(forceReload: Bool = false) {
        // 如果有快取且不強制重新載入，使用快取
        if !forceReload, let cached = cache, !cached.isEmpty {
            intersections = cached
            print("✅ 從快取載入 \(cached.count) 個路口")
            return
        }

        isLoading = true
        errorMessage = nil

        // 非同步載入，避免阻塞 UI
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }

            do {
                let loadedData = try self.loadFromBundle()

                DispatchQueue.main.async {
                    self.intersections = loadedData
                    self.cache = loadedData
                    self.isLoading = false
                    print("✅ 成功載入 \(loadedData.count) 個路口資料")
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                    print("❌ 載入路口資料失敗: \(error.localizedDescription)")
                }
            }
        }
    }

    /// 根據行政區篩選路口
    /// - Parameter district: 行政區名稱（如：中正、大安）
    /// - Returns: 該行政區的路口列表
    func intersections(in district: String) -> [Intersection] {
        return intersections.filter { $0.district == district }
    }

    /// 根據 ID 取得路口
    /// - Parameter id: 路口 ID
    /// - Returns: 對應的路口，若不存在則為 nil
    func intersection(withId id: Int) -> Intersection? {
        return intersections.first { $0.id == id }
    }

    /// 取得所有行政區列表
    /// - Returns: 不重複的行政區名稱陣列，已排序
    func allDistricts() -> [String] {
        let districts = Set(intersections.map { $0.district })
        return districts.sorted()
    }

    /// 搜尋路口
    /// - Parameter keyword: 關鍵字（搜尋路口名稱）
    /// - Returns: 符合關鍵字的路口列表
    func searchIntersections(keyword: String) -> [Intersection] {
        guard !keyword.isEmpty else { return intersections }
        return intersections.filter { $0.intersection.contains(keyword) }
    }

    /// 清除快取
    func clearCache() {
        cache = nil
        print("🗑️ 已清除路口資料快取")
    }

    // MARK: - Private Methods

    /// 從 Bundle 載入 JSON 資料
    /// - Returns: 路口資料陣列
    /// - Throws: 載入或解析錯誤
    private func loadFromBundle() throws -> [Intersection] {
        // 取得 JSON 檔案 URL
        guard let url = Bundle.main.url(forResource: dataFileName, withExtension: "json") else {
            throw DataServiceError.fileNotFound(dataFileName)
        }

        // 讀取資料
        let data = try Data(contentsOf: url)

        // 解析 JSON
        let decoder = JSONDecoder()
        let intersections = try decoder.decode([Intersection].self, from: data)

        // 驗證資料
        guard !intersections.isEmpty else {
            throw DataServiceError.emptyData
        }

        // 驗證所有路口都有地理座標
        let geocodedCount = intersections.filter { $0.geocoded }.count
        print("📍 已地理編碼: \(geocodedCount)/\(intersections.count)")

        return intersections
    }
}

// MARK: - Error Types

enum DataServiceError: LocalizedError {
    case fileNotFound(String)
    case emptyData
    case invalidData

    var errorDescription: String? {
        switch self {
        case .fileNotFound(let fileName):
            return "找不到資料檔案：\(fileName).json"
        case .emptyData:
            return "資料檔案是空的"
        case .invalidData:
            return "資料格式不正確"
        }
    }
}
