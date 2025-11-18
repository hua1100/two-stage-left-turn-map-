# 方向匹配邏輯說明

## 概念說明

### 方向描述的含義

資料中的方向描述（如「北往東」、「西往南」）表示：

- **「X往Y」** = 使用者正在往 **X** 方向騎，可以左轉到往 **Y** 方向的路

### 範例：承德路與市民大道（北往東）

```
         市民大道（往東）
              ↓
              ↓
      ┌───────┼───────┐
      │       │       │
承德路 │   使用者路口   │ 承德路
(往北)│   ↑   ✓   ↓   │ (往南)
      │   │       │   │
      │   │       │   │
      └───┴───────┴───┘
          │
      使用者位置
      (往北騎)
```

**情境**：
- 使用者在承德路上，從南往北騎
- 前方路口是承德路與市民大道
- 資料標示「北往東」
- 表示：使用者可以左轉進入市民大道往東

## DirectionMatcher 判斷邏輯

### shouldAlert() 函式的四個檢查步驟：

#### 1. 距離檢查
```swift
let distance = userLocation.distance(from: 路口座標)
guard distance <= alertDistance else { return false }
```
- 預設 200 公尺內才觸發
- 可在設定中調整

#### 2. 解析允許方向
```swift
let allowedDirections = parseDirection("北往東")
// 結果: [(from: 北(0°), to: 東(90°))]
```
- 支援多方向：「北往東、南往西」
- 支援雙向：「南北雙向」、「東西雙向」

#### 3. 方向匹配檢查
```swift
for (fromDirection, _) in allowedDirections {
    if isDirectionMatching(userCourse, fromDirection.rawValue) {
        // userCourse ≈ 0° ± 45° (往北騎)
    }
}
```
- 檢查使用者的行駛方向（userCourse）是否符合「from」方向
- 預設容許誤差 ±45°

#### 4. 朝向路口檢查
```swift
let bearing = calculateBearing(使用者位置, 路口座標)
if isHeadingTowards(userCourse, bearing) {
    return true
}
```
- 計算從使用者到路口的方位角（bearing）
- 確認 userCourse 與 bearing 的差異 ≤ 45°
- 確保使用者真的在「往路口前進」

## 為什麼不需要額外判斷「在哪條路上」？

### 步驟 3 + 步驟 4 已經隱含確認了道路位置

以「承德路與市民大道，北往東」為例：

| 條件 | 確認內容 | 結論 |
|------|----------|------|
| **步驟 3**: userCourse ≈ 0° (北) | 使用者往北騎 | ✓ 在南北向道路（承德路） |
| **步驟 4**: 朝向路口前進 | 使用者在路口南側 | ✓ 從南往北接近路口 |
| **組合結果** | - | ✓ 在承德路上往北騎 |

### 反例：如果使用者在市民大道上

假設使用者在市民大道上往東騎：

| 檢查 | 數值 | 結果 |
|------|------|------|
| userCourse | 90° (東) | - |
| 步驟 3: 比對「北(0°)」 | 90° - 0° = 90° > 45° | ❌ **不匹配** |
| shouldAlert() | - | ❌ **不會觸發警示** |

### 反例：如果使用者往南騎（背向路口）

假設使用者在承德路上往南騎（遠離路口）：

| 檢查 | 數值 | 結果 |
|------|------|------|
| userCourse | 180° (南) | - |
| 步驟 3: 比對「北(0°)」 | 180° - 0° = 180° > 45° | ❌ **不匹配** |
| shouldAlert() | - | ❌ **不會觸發警示** |

或者即使勉強通過步驟 3（容許範圍邊緣），步驟 4 也會阻擋：

| 檢查 | 數值 | 結果 |
|------|------|------|
| bearing (使用者→路口) | ≈ 0° (北方) | - |
| userCourse | 180° (南) | - |
| 步驟 4: isHeadingTowards | 180° - 0° = 180° > 45° | ❌ **不匹配** |

## 結論

**目前的 DirectionMatcher 邏輯已經完整且正確**：

1. ✓ 透過 **方向匹配**（步驟 3）確認使用者的行駛方向
2. ✓ 透過 **朝向檢查**（步驟 4）確認使用者正在接近路口
3. ✓ 這兩個條件組合已經隱含確認使用者在正確的道路上

**不需要額外的「判斷哪條路在西邊」的邏輯**，因為：

- 方向描述「X往Y」的「X」就是使用者當前的行駛方向
- 只要 userCourse 符合「X」，就表示在正確的道路上
- 再加上「朝向路口」的確認，就能完全排除錯誤觸發

## 程式碼位置

- 主要邏輯：`DirectionMatcher.swift:65-100` (shouldAlert 函式)
- 方向解析：`DirectionMatcher.swift:107-134` (parseDirection 函式)
- 方位計算：`DirectionMatcher.swift:157-175` (calculateBearing 函式)
- 匹配判斷：`DirectionMatcher.swift:178-195` (isDirectionMatching, isHeadingTowards)
