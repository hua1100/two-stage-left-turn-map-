# 台北市機車直接左轉路口地圖工具

> 將台北市開放機車直接左轉的路口資料轉換為可在 Google Maps、Apple Maps、OpenStreetMap、OrganicMaps 等地圖應用中使用的格式。

## 📋 專案簡介

在台灣，機車在三車道以上道路的路口原則上需要進行「兩段式左轉」，但台北市政府針對部分路口開放機車可以直接左轉。本專案將這些路口資料（共 121 個）整理並轉換為地圖標記格式，方便機車騎士查詢。

**資料來源**: 台北市政府交通局
**資料日期**: 114年4月
**路口總數**: 121 個

## 🎯 功能特色

- ✅ 匯出 **KML/KMZ** 格式（Google Maps、Apple Maps 相容）
- ✅ 匯出 **GeoJSON** 格式（OpenStreetMap、OrganicMaps、QGIS 相容）
- ✅ 自動地理編碼（路口地址 → 經緯度）
- ✅ 按行政分區分類
- ✅ 包含路口詳細資訊（方向、開放時間）
- ✅ 資料品質報告

## 📁 專案結構

```
.
├── data/                          # 資料目錄
│   ├── intersections_raw.json     # 原始路口資料
│   ├── intersections_geocoded.json  # 地理編碼後的資料
│   └── geocoding_report.txt       # 地理編碼報告
├── src/                           # 程式碼目錄
│   ├── geocode_intersections.py   # 地理編碼腳本
│   ├── export_kml.py              # KML 匯出腳本
│   └── export_geojson.py          # GeoJSON 匯出腳本
├── output/                        # 輸出目錄
│   ├── taipei_motorcycle_left_turn.kml     # KML 格式
│   ├── taipei_motorcycle_left_turn.kmz     # KMZ 格式（壓縮版）
│   └── taipei_motorcycle_left_turn.geojson # GeoJSON 格式
├── specs/                         # 規格文件
│   └── 001-motorcycle-direct-left-turn-map/
│       └── spec.md                # 功能規格
├── requirements.txt               # Python 相依套件
└── README.md                      # 本文件
```

## 🚀 快速開始

### 1. 環境準備

需要 Python 3.7 或以上版本。

```bash
# 安裝相依套件
pip install -r requirements.txt
```

### 2. 執行流程

#### 步驟 1：地理編碼

將路口地址轉換為經緯度座標：

```bash
cd src
python geocode_intersections.py
```

這個步驟會：
- 讀取 `data/intersections_raw.json`
- 使用 OpenStreetMap Nominatim API 進行地理編碼
- 產生 `data/intersections_geocoded.json`
- 產生 `data/geocoding_report.txt` 報告

**注意**: 地理編碼過程約需 10-15 分鐘（為避免 API 速率限制）

#### 步驟 2：匯出 KML 格式

產生 Google Maps / Apple Maps 相容的 KML 檔案：

```bash
python export_kml.py
```

產生的檔案：
- `output/taipei_motorcycle_left_turn.kml`
- `output/taipei_motorcycle_left_turn.kmz`（壓縮版，建議使用）

#### 步驟 3：匯出 GeoJSON 格式

產生 OpenStreetMap / OrganicMaps 相容的 GeoJSON 檔案：

```bash
python export_geojson.py
```

產生的檔案：
- `output/taipei_motorcycle_left_turn.geojson`

## 📱 如何在手機地圖 App 中使用

### Google Maps

1. **將 KMZ 檔案上傳到雲端**
   - 將 `taipei_motorcycle_left_turn.kmz` 上傳到 Google Drive 或其他雲端儲存

2. **在 Google Maps 中匯入**
   - 在電腦上開啟 [Google My Maps](https://www.google.com/mymaps)
   - 點擊「建立新地圖」
   - 點擊「匯入」，選擇 KMZ 檔案
   - 地圖建立後，會自動同步到手機的 Google Maps app

3. **在手機上查看**
   - 開啟 Google Maps app
   - 點擊左上角選單 → 「您的地點」 → 「地圖」
   - 找到剛才建立的地圖

### Apple Maps（iOS/macOS）

1. **macOS 上**：
   - 直接雙擊 KML 檔案，會自動在 Apple Maps 中開啟

2. **iOS 上**：
   - 透過 AirDrop 或 iCloud Drive 將 KML 檔案傳送到 iPhone
   - 點擊 KML 檔案，選擇「在 Apple Maps 中開啟」

### OrganicMaps

1. **傳送檔案到手機**
   - 將 `taipei_motorcycle_left_turn.geojson` 透過 AirDrop、Email 或雲端傳送到手機

2. **在 OrganicMaps 中開啟**
   - 點擊 GeoJSON 檔案
   - 選擇「在 OrganicMaps 中開啟」
   - 所有路口會自動加入書籤

### OpenStreetMap / uMap

1. **上傳到 uMap**：
   - 前往 [uMap](https://umap.openstreetmap.fr/)
   - 建立新地圖
   - 點擊「匯入資料」，選擇 GeoJSON 檔案

2. **分享地圖**：
   - 儲存後取得分享連結
   - 在手機瀏覽器開啟連結即可查看

## 📊 資料欄位說明

### intersections_raw.json

原始路口資料，包含以下欄位：

```json
{
  "id": 1,                    // 編號
  "district": "大同",          // 分區
  "intersection": "承德路與市民大道",  // 路口名稱
  "direction": "北往東",       // 可直接左轉的方向
  "opened_year": "98年以前"    // 開放時間
}
```

### intersections_geocoded.json

地理編碼後的資料，額外包含：

```json
{
  "latitude": 25.0528,       // 緯度
  "longitude": 121.5168,     // 經度
  "geocoded": true,          // 是否成功地理編碼
  "geocode_address": "台北市大同區承德路與市民大道"  // 用於地理編碼的地址
}
```

## 🎨 地圖標記說明

### 標記資訊

每個路口標記包含：
- **編號**: 對應台北市政府公告的編號
- **路口名稱**: 完整的路口描述
- **分區**: 所屬行政區
- **方向**: 允許直接左轉的方向（例如：北往東、南北雙向）
- **開放時間**: 開放直接左轉的時間

### 方向說明

- **單一方向**: 例如「北往東」，表示只有從北往東轉時可直接左轉
- **雙向**: 例如「南北雙向」，表示南往北和北往南都可直接左轉
- **多方向**: 例如「南往西、西往北」，表示這兩個方向都可直接左轉

## 🛠️ 技術細節

### 地理編碼策略

由於路口地址可能有多種表達方式，腳本會嘗試以下策略：

1. 完整路口名稱：`台北市{分區}區{完整路口名稱}`
2. 主要道路：`台北市{分區}區{主要道路}`
3. 逗號分隔：`{路口名稱},台北市{分區}區`
4. 簡化版：`{主要道路},台北市`

### API 速率限制

使用 OpenStreetMap Nominatim API 時需遵守以下限制：
- 每秒最多 1 個請求
- 本腳本已內建延遲機制（每 5 個路口休息 2 秒）

### 資料準確度

- **目標準確度**: 經緯度誤差 < 50 公尺
- **成功率目標**: ≥ 95%（即 121 個路口中至少 115 個成功地理編碼）

## 📝 授權

- **程式碼**: MIT License
- **路口資料**: 來自台北市政府交通局，屬於政府開放資料

## 🤝 貢獻

歡迎提交 Issue 或 Pull Request！

### 資料更新流程

當台北市政府更新路口清冊時：

1. 更新 `data/intersections_raw.json`
2. 重新執行地理編碼：`python src/geocode_intersections.py`
3. 重新產生地圖檔案：
   ```bash
   python src/export_kml.py
   python src/export_geojson.py
   ```

## ❓ 常見問題

### Q: 為什麼有些路口找不到經緯度？

A: 可能的原因：
- 路口名稱描述不夠明確
- OpenStreetMap 資料庫中沒有該路口資訊
- 路口名稱有誤或已更名

解決方式：查看 `data/geocoding_report.txt`，對於失敗的路口可手動校正。

### Q: Google Maps 無法匯入 KML 檔案？

A: 建議使用 KMZ 格式（壓縮版），檔案較小且相容性較好。

### Q: 如何在 OrganicMaps 中一次顯示所有路口？

A: OrganicMaps 會將 GeoJSON 中的所有路口加入書籤。開啟書籤清單即可瀏覽所有路口。

### Q: 資料多久更新一次？

A: 依據台北市政府交通局公告為準。建議定期檢查[台北市政府交通局網站](https://www.dot.gov.taipei/)取得最新資料。

## 📧 聯絡資訊

如有問題或建議，請透過 GitHub Issues 回報。

---

**最後更新**: 2025-11-17
**資料版本**: 114年4月（121個路口）
