#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
GeoJSON匯出腳本：產生OpenStreetMap / OrganicMaps相容的GeoJSON檔案
"""

import json
from typing import List, Dict


def create_geojson_feature(intersection: Dict) -> Dict:
    """
    建立單一路口的GeoJSON Feature

    Args:
        intersection: 路口資料

    Returns:
        GeoJSON Feature物件
    """
    return {
        "type": "Feature",
        "geometry": {
            "type": "Point",
            "coordinates": [
                intersection['longitude'],
                intersection['latitude']
            ]
        },
        "properties": {
            "id": intersection['id'],
            "name": intersection['intersection'],
            "district": intersection['district'],
            "direction": intersection['direction'],
            "opened_year": intersection['opened_year'],
            "description": f"編號 {intersection['id']}：{intersection['district']}區 - "
                          f"{intersection['intersection']}（{intersection['direction']}）- "
                          f"{intersection['opened_year']}開放",
            "marker-color": "#4CAF50",
            "marker-size": "medium",
            "marker-symbol": "bicycle"
        }
    }


def export_to_geojson(intersections: List[Dict], output_file: str) -> Dict[str, int]:
    """
    匯出路口資料為GeoJSON格式

    Args:
        intersections: 包含經緯度的路口資料列表
        output_file: 輸出檔案路徑

    Returns:
        統計資訊字典
    """
    # 統計
    stats = {
        'total': len(intersections),
        'geocoded': 0,
        'not_geocoded': 0,
        'by_district': {}
    }

    # 建立GeoJSON FeatureCollection
    features = []

    for intersection in intersections:
        district = intersection['district']

        # 統計分區
        if district not in stats['by_district']:
            stats['by_district'][district] = 0
        stats['by_district'][district] += 1

        # 檢查是否已地理編碼
        if intersection.get('geocoded') and intersection.get('latitude') and intersection.get('longitude'):
            feature = create_geojson_feature(intersection)
            features.append(feature)
            stats['geocoded'] += 1
        else:
            stats['not_geocoded'] += 1

    # 建立完整的GeoJSON物件
    geojson = {
        "type": "FeatureCollection",
        "metadata": {
            "title": "台北市機車直接左轉路口",
            "description": "台北市三車道以上例外開放機車直接左轉路口列表",
            "source": "台北市政府交通局",
            "date": "114年4月",
            "total_intersections": stats['geocoded'],
            "license": "Open Data"
        },
        "features": features
    }

    # 儲存GeoJSON
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(geojson, f, ensure_ascii=False, indent=2)

    return stats


def main():
    """主函數"""
    input_file = 'data/intersections_geocoded.json'
    output_file = 'output/taipei_motorcycle_left_turn.geojson'

    print("GeoJSON 匯出工具 - 台北市機車直接左轉路口")
    print("=" * 60)

    # 建立輸出目錄
    import os
    os.makedirs('output', exist_ok=True)

    # 讀取地理編碼後的資料
    try:
        with open(input_file, 'r', encoding='utf-8') as f:
            intersections = json.load(f)
    except FileNotFoundError:
        print(f"\n錯誤：找不到檔案 {input_file}")
        print("請先執行 geocode_intersections.py 進行地理編碼")
        return

    print(f"\n已載入 {len(intersections)} 個路口資料")

    # 匯出GeoJSON
    print(f"\n正在產生 GeoJSON 檔案...")
    stats = export_to_geojson(intersections, output_file)

    # 顯示統計
    print(f"\n✓ 已產生 GeoJSON 檔案: {output_file}")
    print(f"\n統計資訊：")
    print(f"  總路口數: {stats['total']}")
    print(f"  已地理編碼: {stats['geocoded']}")
    print(f"  未地理編碼: {stats['not_geocoded']}")

    if stats['geocoded'] > 0:
        print(f"\n分區分布：")
        for district, count in sorted(stats['by_district'].items()):
            print(f"  {district}區: {count} 個路口")

    print(f"\n使用說明：")
    print(f"  1. 在 OrganicMaps 中使用：")
    print(f"     - 將 {output_file} 傳送到手機")
    print(f"     - 在 OrganicMaps 中開啟檔案")
    print(f"     - 所有路口將顯示為書籤")
    print(f"  2. 在 QGIS 等 GIS 工具中：")
    print(f"     - 直接拖放 GeoJSON 檔案到地圖")
    print(f"  3. 在網頁地圖中：")
    print(f"     - 使用 Leaflet.js 等函式庫載入此檔案")
    print(f"     - 或上傳到 geojson.io 線上檢視")
    print(f"\n完成！")


if __name__ == '__main__':
    main()
