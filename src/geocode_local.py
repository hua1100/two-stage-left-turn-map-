#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
地理編碼腳本（本地執行版本）
將台北市 121 個路口地址轉換為經緯度座標

使用方式：
    python geocode_local.py

注意事項：
    - 此腳本使用 OpenStreetMap Nominatim API
    - 執行時間約 10-15 分鐘（避免 API 速率限制）
    - 請確保網路連線正常
    - 如果遇到 403 錯誤，請稍後再試或使用 VPN
"""

import json
import time
from typing import List, Dict, Optional, Tuple
import urllib.request
import urllib.parse
import urllib.error


class SimpleGeocoder:
    """簡單的地理編碼器（使用 Nominatim API）"""

    def __init__(self, user_agent: str = "TaipeiMotorcycleLeftTurnMap/1.0"):
        """
        初始化地理編碼器

        Args:
            user_agent: Nominatim 要求的 user agent 字串
        """
        self.base_url = "https://nominatim.openstreetmap.org/search"
        self.user_agent = user_agent
        self.success_count = 0
        self.failure_count = 0
        self.failed_intersections = []

    def geocode_address(self, address: str, retry=3) -> Optional[Tuple[float, float]]:
        """
        將地址轉換為經緯度

        Args:
            address: 要編碼的地址
            retry: 失敗重試次數

        Returns:
            (緯度, 經度) 或 None（如果失敗）
        """
        for attempt in range(retry):
            try:
                # 建立請求 URL
                params = {
                    'q': address,
                    'format': 'json',
                    'limit': 1,
                    'addressdetails': 1
                }
                url = f"{self.base_url}?{urllib.parse.urlencode(params)}"

                # 建立請求
                req = urllib.request.Request(url)
                req.add_header('User-Agent', self.user_agent)

                # 發送請求
                with urllib.request.urlopen(req, timeout=10) as response:
                    data = json.loads(response.read().decode('utf-8'))

                    if data and len(data) > 0:
                        result = data[0]
                        lat = float(result['lat'])
                        lon = float(result['lon'])
                        return (lat, lon)
                    else:
                        print(f"   警告：找不到地址「{address}」")
                        return None

            except urllib.error.HTTPError as e:
                if e.code == 403:
                    print(f"   錯誤：API 拒絕存取 (403) - 可能需要更換 IP 或稍後再試")
                    return None
                elif e.code == 429:
                    print(f"   警告：達到速率限制，等待 5 秒...")
                    time.sleep(5)
                    if attempt < retry - 1:
                        continue
                else:
                    print(f"   錯誤：HTTP {e.code}")
                    return None

            except Exception as e:
                if attempt < retry - 1:
                    print(f"   逾時，重試中... ({attempt + 1}/{retry})")
                    time.sleep(2)
                else:
                    print(f"   錯誤：{e}")
                    return None

        return None

    def build_search_addresses(self, intersection: Dict[str, str]) -> List[str]:
        """
        建立多個搜尋用的地址字串（依優先級排序）

        Args:
            intersection: 路口資料

        Returns:
            地址列表
        """
        district = intersection['district']
        intersection_name = intersection['intersection']

        # 取主要道路
        if '與' in intersection_name:
            roads = intersection_name.split('與')
            main_road = roads[0].strip()
        else:
            main_road = intersection_name

        # 建立多個可能的搜尋字串（依成功率排序）
        addresses = [
            f"{main_road}, {district}區, 台北市, 台灣",  # 最可能成功
            f"{intersection_name}, {district}區, 台北市",
            f"{main_road}, 台北市",
            f"{intersection_name}, 台北",
        ]

        return addresses

    def geocode_intersection(self, intersection: Dict[str, str]) -> Dict[str, any]:
        """
        為單一路口進行地理編碼

        Args:
            intersection: 路口資料字典

        Returns:
            包含經緯度的路口資料
        """
        search_addresses = self.build_search_addresses(intersection)

        print(f"處理路口 #{intersection['id']}: {intersection['intersection']}")

        # 嘗試多個搜尋地址
        coords = None
        used_address = None

        for i, address in enumerate(search_addresses):
            print(f"   嘗試 {i+1}/{len(search_addresses)}: {address}")
            coords = self.geocode_address(address)
            if coords:
                used_address = address
                break
            time.sleep(1.5)  # 避免 API 速率限制（Nominatim 要求 1 req/sec）

        # 建立結果
        result = intersection.copy()

        if coords:
            result['latitude'] = coords[0]
            result['longitude'] = coords[1]
            result['geocoded'] = True
            result['geocode_address'] = used_address
            result['geocode_source'] = 'nominatim'
            self.success_count += 1
            print(f"   ✓ 成功：{coords[0]:.6f}, {coords[1]:.6f}")
        else:
            result['latitude'] = None
            result['longitude'] = None
            result['geocoded'] = False
            result['geocode_address'] = None
            result['geocode_source'] = None
            self.failure_count += 1
            self.failed_intersections.append(intersection)
            print(f"   ✗ 失敗：無法找到座標")

        return result

    def geocode_all(self, intersections: List[Dict[str, str]]) -> List[Dict[str, any]]:
        """
        為所有路口進行地理編碼

        Args:
            intersections: 路口資料列表

        Returns:
            包含經緯度的路口資料列表
        """
        results = []
        total = len(intersections)

        print(f"\n開始地理編碼，共 {total} 個路口\n")
        print("=" * 60)
        print(f"預估時間：約 {total * 2 / 60:.0f} 分鐘\n")

        for i, intersection in enumerate(intersections, 1):
            print(f"\n[{i}/{total}]")
            result = self.geocode_intersection(intersection)
            results.append(result)

            # 每處理 5 個路口休息一下，避免 API 速率限制
            if i % 5 == 0 and i < total:
                print(f"\n--- 休息 3 秒以避免速率限制 ---")
                time.sleep(3)

        print("\n" + "=" * 60)
        print(f"\n地理編碼完成！")
        print(f"  成功: {self.success_count} 個路口")
        print(f"  失敗: {self.failure_count} 個路口")
        if total > 0:
            print(f"  成功率: {self.success_count/total*100:.1f}%")

        if self.failed_intersections:
            print(f"\n失敗的路口：")
            for intersection in self.failed_intersections:
                print(f"  - #{intersection['id']}: {intersection['intersection']}")

        return results


def main():
    """主函數"""
    # 輸入輸出檔案路徑
    input_file = 'data/intersections_raw.json'
    output_file = 'data/intersections_geocoded.json'
    report_file = 'data/geocoding_report.txt'

    print("=" * 60)
    print("台北市機車直接左轉路口地理編碼工具（本地執行版）")
    print("=" * 60)
    print("\n使用 OpenStreetMap Nominatim API")
    print("請確保網路連線正常\n")

    # 讀取原始路口資料
    try:
        with open(input_file, 'r', encoding='utf-8') as f:
            intersections = json.load(f)
        print(f"✓ 已載入 {len(intersections)} 個路口資料\n")
    except FileNotFoundError:
        print(f"✗ 錯誤：找不到檔案 {input_file}")
        print(f"  請確認檔案路徑正確")
        return
    except Exception as e:
        print(f"✗ 錯誤：{e}")
        return

    # 詢問使用者是否繼續
    print(f"即將開始地理編碼 {len(intersections)} 個路口")
    print(f"預估時間：約 {len(intersections) * 2 / 60:.0f} 分鐘")
    response = input("\n是否繼續？(y/n): ")

    if response.lower() != 'y':
        print("已取消")
        return

    # 建立地理編碼器
    geocoder = SimpleGeocoder()

    # 執行地理編碼
    geocoded_results = geocoder.geocode_all(intersections)

    # 儲存結果
    try:
        with open(output_file, 'w', encoding='utf-8') as f:
            json.dump(geocoded_results, f, ensure_ascii=False, indent=2)
        print(f"\n✓ 已儲存地理編碼結果: {output_file}")
    except Exception as e:
        print(f"\n✗ 儲存失敗：{e}")

    # 產生報告
    try:
        with open(report_file, 'w', encoding='utf-8') as f:
            f.write("台北市機車直接左轉路口地理編碼報告\n")
            f.write("=" * 60 + "\n\n")
            f.write(f"執行時間: {time.strftime('%Y-%m-%d %H:%M:%S')}\n")
            f.write(f"總路口數: {len(intersections)}\n")
            f.write(f"成功: {geocoder.success_count}\n")
            f.write(f"失敗: {geocoder.failure_count}\n")
            if len(intersections) > 0:
                f.write(f"成功率: {geocoder.success_count/len(intersections)*100:.1f}%\n\n")

            if geocoder.failed_intersections:
                f.write("失敗的路口列表：\n")
                f.write("-" * 60 + "\n")
                for intersection in geocoder.failed_intersections:
                    f.write(f"#{intersection['id']:3d} | {intersection['district']:4s} | "
                           f"{intersection['intersection']}\n")
        print(f"✓ 已產生地理編碼報告: {report_file}")
    except Exception as e:
        print(f"✗ 產生報告失敗：{e}")

    print("\n完成！")
    print("\n提示：如果有失敗的路口，可能需要：")
    print("  1. 手動使用 Google Maps 查詢座標")
    print("  2. 使用 VPN 更換 IP 後重試")
    print("  3. 使用 Google Geocoding API（需要 API Key）")


if __name__ == '__main__':
    main()
