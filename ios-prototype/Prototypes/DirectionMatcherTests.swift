import Foundation
import CoreLocation

/// 方向匹配演算法測試
///
/// 此測試驗證 DirectionMatcher 能否正確：
/// 1. 解析方向描述（北往東、南北雙向等）
/// 2. 計算方位角
/// 3. 判斷使用者方向是否匹配
///
/// 執行方式：在 Xcode Playground 或單元測試中執行

class DirectionMatcherTests {

    let matcher = DirectionMatcher(tolerance: 30.0, alertDistance: 150.0)

    // MARK: - 測試案例

    /// 測試 1：方向解析 - 單一方向
    func testParseSingleDirection() {
        print("\n=== 測試 1：方向解析 - 單一方向 ===")

        let testCases: [(String, Int)] = [
            ("北往東", 1),  // 應解析出 1 個方向配對
            ("南往西", 1),
            ("東往南", 1),
            ("西往北", 1)
        ]

        for (direction, expectedCount) in testCases {
            let result = matcher.parseDirection(direction)
            let passed = result.count == expectedCount
            print("\(passed ? "✅" : "❌") \(direction) -> \(result.count) 個配對 (預期: \(expectedCount))")
        }
    }

    /// 測試 2：方向解析 - 雙向
    func testParseDoubleDirection() {
        print("\n=== 測試 2：方向解析 - 雙向 ===")

        let testCases: [(String, Int)] = [
            ("南北雙向", 2),  // 應解析出 2 個方向配對
            ("東西雙向", 2)
        ]

        for (direction, expectedCount) in testCases {
            let result = matcher.parseDirection(direction)
            let passed = result.count == expectedCount
            print("\(passed ? "✅" : "❌") \(direction) -> \(result.count) 個配對 (預期: \(expectedCount))")

            // 顯示詳細內容
            for (from, to) in result {
                print("   - \(from.displayName)往\(to.displayName)")
            }
        }
    }

    /// 測試 3：方向解析 - 多方向
    func testParseMultipleDirections() {
        print("\n=== 測試 3：方向解析 - 多方向 ===")

        let testCases: [(String, Int)] = [
            ("北往東、北往西", 2),
            ("南往東、南往西", 2),
            ("東往北、西往南", 2)
        ]

        for (direction, expectedCount) in testCases {
            let result = matcher.parseDirection(direction)
            let passed = result.count == expectedCount
            print("\(passed ? "✅" : "❌") \(direction) -> \(result.count) 個配對 (預期: \(expectedCount))")

            for (from, to) in result {
                print("   - \(from.displayName)往\(to.displayName)")
            }
        }
    }

    /// 測試 4：方向匹配 - 使用真實路口資料
    func testRealIntersectionMatching() {
        print("\n=== 測試 4：方向匹配 - 使用真實路口資料 ===")

        // 測試路口：承德路與市民大道（北往東）
        let intersection = Intersection(
            id: 1,
            district: "大同",
            intersection: "承德路與市民大道",
            direction: "北往東",
            openedYear: "98年以前",
            latitude: 25.052856,
            longitude: 121.516831,
            geocoded: true,
            geocodeSource: "manual"
        )

        // 測試情境：使用者位於路口南方 100 公尺，往北行駛
        let testCases: [(userLat: Double, userLon: Double, userCourse: Double, expectedAlert: Bool, description: String)] = [
            // 情境 1：在路口南方，往北行駛 -> 應警示（匹配「北往東」的「北」）
            (25.051856, 121.516831, 0, true, "南方往北行駛"),

            // 情境 2：在路口南方，往南行駛 -> 不應警示（方向不匹配）
            (25.051856, 121.516831, 180, false, "南方往南行駛"),

            // 情境 3：在路口北方，往北行駛 -> 不應警示（雖然方向匹配，但正在遠離路口）
            (25.053856, 121.516831, 0, false, "北方往北行駛（遠離）"),

            // 情境 4：在路口東方，往西行駛 -> 不應警示（方向不匹配）
            (25.052856, 121.517831, 270, false, "東方往西行駛"),

            // 情境 5：距離過遠 -> 不應警示
            (25.050856, 121.516831, 0, false, "距離過遠（200m）")
        ]

        for testCase in testCases {
            let userLocation = CLLocation(
                latitude: testCase.userLat,
                longitude: testCase.userLon
            )

            let shouldAlert = matcher.shouldAlert(
                userLocation: userLocation,
                userCourse: testCase.userCourse,
                intersection: intersection
            )

            let passed = shouldAlert == testCase.expectedAlert
            print("\(passed ? "✅" : "❌") \(testCase.description): \(shouldAlert ? "警示" : "不警示") (預期: \(testCase.expectedAlert ? "警示" : "不警示"))")
        }
    }

    /// 測試 5：方向匹配 - 雙向路口
    func testBidirectionalIntersection() {
        print("\n=== 測試 5：方向匹配 - 雙向路口 ===")

        // 測試路口：南北雙向
        let intersection = Intersection(
            id: 2,
            district: "南港",
            intersection: "研究院路與南港路",
            direction: "南北雙向",
            openedYear: "98年以前",
            latitude: 25.041234,
            longitude: 121.612345,
            geocoded: true,
            geocodeSource: "manual"
        )

        let testCases: [(userCourse: Double, expectedAlert: Bool, description: String)] = [
            (0, true, "往北行駛"),      // 匹配「北往西」
            (180, true, "往南行駛"),    // 匹配「南往東」
            (90, false, "往東行駛"),    // 不匹配
            (270, false, "往西行駛")    // 不匹配
        ]

        // 使用者位於路口南方 100 公尺
        let userLocation = CLLocation(latitude: 25.040234, longitude: 121.612345)

        for testCase in testCases {
            let shouldAlert = matcher.shouldAlert(
                userLocation: userLocation,
                userCourse: testCase.userCourse,
                intersection: intersection
            )

            let passed = shouldAlert == testCase.expectedAlert
            print("\(passed ? "✅" : "❌") \(testCase.description): \(shouldAlert ? "警示" : "不警示") (預期: \(testCase.expectedAlert ? "警示" : "不警示"))")
        }
    }

    /// 執行所有測試
    func runAllTests() {
        print("🧪 開始執行 DirectionMatcher 測試")
        print("================================")

        testParseSingleDirection()
        testParseDoubleDirection()
        testParseMultipleDirections()
        testRealIntersectionMatching()
        testBidirectionalIntersection()

        print("\n================================")
        print("✅ 測試完成")
    }
}

// MARK: - 執行測試

// 在 Playground 或測試環境中執行：
// let tests = DirectionMatcherTests()
// tests.runAllTests()
