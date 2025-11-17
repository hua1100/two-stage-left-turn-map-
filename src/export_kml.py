#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
KML匯出腳本：產生Google Maps / Apple Maps相容的KML檔案
"""

import json
import simplekml
from typing import List, Dict


def create_description_html(intersection: Dict) -> str:
    """
    建立路口標記的HTML描述

    Args:
        intersection: 路口資料

    Returns:
        HTML格式的描述文字
    """
    html = f"""
    <![CDATA[
    <div style="font-family: Arial, sans-serif;">
        <h3 style="color: #1976D2; margin-top: 0;">{intersection['intersection']}</h3>
        <table style="border-collapse: collapse; width: 100%;">
            <tr>
                <td style="padding: 5px; font-weight: bold; width: 80px;">編號:</td>
                <td style="padding: 5px;">#{intersection['id']}</td>
            </tr>
            <tr style="background-color: #f5f5f5;">
                <td style="padding: 5px; font-weight: bold;">分區:</td>
                <td style="padding: 5px;">{intersection['district']}區</td>
            </tr>
            <tr>
                <td style="padding: 5px; font-weight: bold;">方向:</td>
                <td style="padding: 5px; color: #D32F2F;">{intersection['direction']}</td>
            </tr>
            <tr style="background-color: #f5f5f5;">
                <td style="padding: 5px; font-weight: bold;">開放時間:</td>
                <td style="padding: 5px;">{intersection['opened_year']}</td>
            </tr>
        </table>
        <p style="margin-top: 10px; padding: 8px; background-color: #E8F5E9; border-left: 4px solid #4CAF50; font-size: 12px;">
            ✓ 此路口機車可直接左轉，不需兩段式左轉
        </p>
    </div>
    ]]>
    """
    return html


def export_to_kml(intersections: List[Dict], output_file: str) -> Dict[str, int]:
    """
    匯出路口資料為KML格式

    Args:
        intersections: 包含經緯度的路口資料列表
        output_file: 輸出檔案路徑

    Returns:
        統計資訊字典
    """
    # 建立KML物件
    kml = simplekml.Kml()
    kml.document.name = "台北市機車直接左轉路口"
    kml.document.description = (
        "台北市三車道以上例外開放機車直接左轉路口列表\\n"
        "資料來源：台北市政府交通局\\n"
        "製表日期：114年4月"
    )

    # 統計
    stats = {
        'total': len(intersections),
        'geocoded': 0,
        'not_geocoded': 0,
        'by_district': {}
    }

    # 按分區建立資料夾
    folders = {}

    for intersection in intersections:
        district = intersection['district']

        # 統計分區
        if district not in stats['by_district']:
            stats['by_district'][district] = 0
        stats['by_district'][district] += 1

        # 建立分區資料夾
        if district not in folders:
            folder = kml.newfolder(name=f"{district}區")
            folders[district] = folder
        else:
            folder = folders[district]

        # 檢查是否已地理編碼
        if intersection.get('geocoded') and intersection.get('latitude') and intersection.get('longitude'):
            # 建立地標
            pnt = folder.newpoint(
                name=f"#{intersection['id']} {intersection['intersection']}",
                coords=[(intersection['longitude'], intersection['latitude'])]
            )

            # 設定描述
            pnt.description = create_description_html(intersection)

            # 設定樣式
            pnt.style.iconstyle.icon.href = "http://maps.google.com/mapfiles/kml/paddle/grn-circle.png"
            pnt.style.iconstyle.scale = 1.0

            # 設定標籤樣式
            pnt.style.labelstyle.scale = 0.8

            stats['geocoded'] += 1
        else:
            # 未地理編碼的路口
            stats['not_geocoded'] += 1

    # 儲存KML
    kml.save(output_file)

    return stats


def main():
    """主函數"""
    input_file = 'data/intersections_geocoded.json'
    output_kml = 'output/taipei_motorcycle_left_turn.kml'
    output_kmz = 'output/taipei_motorcycle_left_turn.kmz'

    print("KML 匯出工具 - 台北市機車直接左轉路口")
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

    # 匯出KML
    print(f"\n正在產生 KML 檔案...")
    stats = export_to_kml(intersections, output_kml)

    # 顯示統計
    print(f"\n✓ 已產生 KML 檔案: {output_kml}")
    print(f"\n統計資訊：")
    print(f"  總路口數: {stats['total']}")
    print(f"  已地理編碼: {stats['geocoded']}")
    print(f"  未地理編碼: {stats['not_geocoded']}")

    if stats['geocoded'] > 0:
        print(f"\n分區分布：")
        for district, count in sorted(stats['by_district'].items()):
            print(f"  {district}區: {count} 個路口")

    # 產生KMZ（壓縮版）
    print(f"\n正在產生 KMZ 檔案（壓縮版）...")
    import zipfile
    with zipfile.ZipFile(output_kmz, 'w', zipfile.ZIP_DEFLATED) as kmz:
        kmz.write(output_kml, 'doc.kml')

    print(f"✓ 已產生 KMZ 檔案: {output_kmz}")

    print(f"\n使用說明：")
    print(f"  1. 將 {output_kml} 或 {output_kmz} 上傳到您的雲端儲存")
    print(f"  2. 在 Google Maps 中：")
    print(f"     - 開啟 Google Maps")
    print(f"     - 點擊左上角選單 → 「您的地點」 → 「地圖」")
    print(f"     - 點擊「建立地圖」")
    print(f"     - 點擊「匯入」，選擇 KML/KMZ 檔案")
    print(f"  3. 在 Apple Maps (macOS) 中：")
    print(f"     - 直接雙擊 KML 檔案即可開啟")
    print(f"\n完成！")


if __name__ == '__main__':
    main()
