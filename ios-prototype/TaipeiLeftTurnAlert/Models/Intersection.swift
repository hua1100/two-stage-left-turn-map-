import Foundation
import CoreLocation

/// 路口資料模型
struct Intersection: Codable, Identifiable {
    let id: Int
    let district: String           // 行政區
    let intersection: String       // 路口名稱
    let direction: String          // 可直接左轉方向（如：北往東、南北雙向）
    let openedYear: String         // 開放年份
    let latitude: Double           // 緯度
    let longitude: Double          // 經度
    let geocoded: Bool            // 是否已地理編碼
    let geocodeSource: String?    // 地理編碼來源

    enum CodingKeys: String, CodingKey {
        case id, district, intersection, direction, latitude, longitude, geocoded
        case openedYear = "opened_year"
        case geocodeSource = "geocode_source"
    }

    /// 轉換為 CLLocationCoordinate2D
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    /// 產生友善的路口描述（用於語音提示）
    var displayName: String {
        // 移除「路」、「街」等後綴，讓語音更簡潔
        let cleaned = intersection
            .replacingOccurrences(of: "與", with: "和")
        return cleaned
    }

    /// 提取目標道路名稱（「與」後面的道路）
    /// 用於語音提示「前方可以直接左轉到XX路」
    var targetRoadName: String? {
        // 處理格式：「Road A與Road B」→ 提取 Road B
        if let separatorRange = intersection.range(of: "與") {
            let roadB = String(intersection[separatorRange.upperBound...])
            // 移除前後空白
            return roadB.trimmingCharacters(in: .whitespaces)
        }
        return nil
    }
}
