import Foundation
import CoreLocation

/// 方向匹配服務：判斷使用者當前行駛方向是否符合路口的可左轉方向
class DirectionMatcher {

    /// 基本方位枚舉
    enum CardinalDirection: Double, CaseIterable {
        case north = 0      // 北
        case east = 90      // 東
        case south = 180    // 南
        case west = 270     // 西

        var displayName: String {
            switch self {
            case .north: return "北"
            case .east: return "東"
            case .south: return "南"
            case .west: return "西"
            }
        }

        /// 從中文方位轉換
        static func from(chinese: String) -> CardinalDirection? {
            switch chinese {
            case "北": return .north
            case "東": return .east
            case "南": return .south
            case "西": return .west
            default: return nil
            }
        }
    }

    /// 方向配對：從哪個方向往哪個方向
    typealias DirectionPair = (from: CardinalDirection, to: CardinalDirection)

    // MARK: - 配置參數

    /// 方向匹配容許誤差（度）
    private let tolerance: Double

    /// 觸發警示的距離（公尺）
    private let alertDistance: Double

    init(tolerance: Double = 30.0, alertDistance: Double = 150.0) {
        self.tolerance = tolerance
        self.alertDistance = alertDistance
    }

    // MARK: - 主要判斷邏輯

    /// 判斷是否應該發出警示
    /// - Parameters:
    ///   - userLocation: 使用者當前位置
    ///   - userCourse: 使用者當前行駛方向（0-360度，北為0度順時針）
    ///   - intersection: 路口資料
    /// - Returns: 是否應該警示
    func shouldAlert(
        userLocation: CLLocation,
        userCourse: CLLocationDirection,
        intersection: Intersection
    ) -> Bool {
        // 1. 檢查距離
        let distance = userLocation.distance(from: CLLocation(
            latitude: intersection.latitude,
            longitude: intersection.longitude
        ))

        guard distance <= alertDistance else {
            return false
        }

        // 2. 計算從使用者到路口的方位角
        let bearing = calculateBearing(
            from: userLocation.coordinate,
            to: intersection.coordinate
        )

        // 3. 解析路口的允許方向
        let allowedDirections = parseDirection(intersection.direction)

        // 4. 檢查使用者行駛方向是否匹配任一允許方向
        for (fromDirection, _) in allowedDirections {
            if isDirectionMatching(userCourse, targetDirection: fromDirection.rawValue) {
                // 額外確認：使用者正在朝向路口前進
                if isHeadingTowards(userCourse: userCourse, bearing: bearing) {
                    return true
                }
            }
        }

        return false
    }

    // MARK: - 方向解析

    /// 解析方向描述字串（如：「北往東」、「南北雙向」）
    /// - Parameter direction: 方向描述
    /// - Returns: 方向配對陣列
    func parseDirection(_ direction: String) -> [DirectionPair] {
        var result: [DirectionPair] = []

        // 處理雙向情況
        if direction.contains("南北雙向") {
            // 南北雙向 = 南往東 + 北往西
            result.append((.south, .east))
            result.append((.north, .west))
            return result
        }

        if direction.contains("東西雙向") {
            // 東西雙向 = 東往北 + 西往南
            result.append((.east, .north))
            result.append((.west, .south))
            return result
        }

        // 處理多個方向（用「、」分隔）
        let parts = direction.components(separatedBy: "、")
        for part in parts {
            if let parsed = parseSingleDirection(part.trimmingCharacters(in: .whitespaces)) {
                result.append(parsed)
            }
        }

        return result
    }

    /// 解析單一方向描述（如：「北往東」）
    private func parseSingleDirection(_ direction: String) -> DirectionPair? {
        // 預期格式：X往Y（如：北往東）
        if direction.contains("往") {
            let parts = direction.components(separatedBy: "往")
            guard parts.count == 2 else { return nil }

            guard let from = CardinalDirection.from(chinese: parts[0]),
                  let to = CardinalDirection.from(chinese: parts[1]) else {
                return nil
            }

            return (from, to)
        }

        return nil
    }

    // MARK: - 方位計算

    /// 計算兩點間的方位角（北為0度，順時針）
    private func calculateBearing(
        from: CLLocationCoordinate2D,
        to: CLLocationCoordinate2D
    ) -> Double {
        let lat1 = from.latitude.toRadians()
        let lon1 = from.longitude.toRadians()
        let lat2 = to.latitude.toRadians()
        let lon2 = to.longitude.toRadians()

        let dLon = lon2 - lon1

        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)

        let bearing = atan2(y, x).toDegrees()

        // 轉換為 0-360 度
        return (bearing + 360).truncatingRemainder(dividingBy: 360)
    }

    /// 判斷方向是否匹配（考慮容許誤差）
    private func isDirectionMatching(
        _ actualDirection: Double,
        targetDirection: Double
    ) -> Bool {
        let diff = abs(normalizeAngle(actualDirection - targetDirection))
        return diff <= tolerance
    }

    /// 判斷使用者是否正朝向目標前進
    /// - Parameters:
    ///   - userCourse: 使用者行駛方向
    ///   - bearing: 從使用者到目標的方位角
    /// - Returns: 是否朝向目標
    private func isHeadingTowards(userCourse: Double, bearing: Double) -> Bool {
        let diff = abs(normalizeAngle(userCourse - bearing))
        // 容許 ±45 度的偏差
        return diff <= 45.0
    }

    /// 將角度標準化到 -180 到 180 度之間
    private func normalizeAngle(_ angle: Double) -> Double {
        var normalized = angle
        while normalized > 180 {
            normalized -= 360
        }
        while normalized < -180 {
            normalized += 360
        }
        return normalized
    }
}

// MARK: - 擴充功能

extension Double {
    func toRadians() -> Double {
        return self * .pi / 180.0
    }

    func toDegrees() -> Double {
        return self * 180.0 / .pi
    }
}
