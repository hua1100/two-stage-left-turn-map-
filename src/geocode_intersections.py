#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
地理編碼腳本：將路口地址轉換為經緯度座標

使用 OpenStreetMap Nominatim API 進行地理編碼
"""

import json
import time
from typing import List, Dict, Optional, Tuple
from geopy.geocoders import Nominatim
from geopy.exc import GeocoderTimedOut, GeocoderServiceError


class IntersectionGeocoder:
    """路口地理編碼器"""

    def __init__(self, user_agent: str = "taipei-motorcycle-left-turn-map"):
        """
        初始化地理編碼器

        Args:
            user_agent: Nominatim 要求的 user agent 字串
        """
        self.geolocator = Nominatim(user_agent=user_agent, timeout=10)
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
                location = self.geolocator.geocode(address)
                if location:
                    return (location.latitude, location.longitude)
                else:
                    print(f"   警告：找不到地址「{address}」")
                    return None
            except GeocoderTimedOut:
                if attempt < retry - 1:
                    print(f"   逾時，重試中... ({attempt + 1}/{retry})")
                    time.sleep(2)
                else:
                    print(f"   錯誤：逾時（已重試 {retry} 次）")
                    return None
            except GeocoderServiceError as e:
                print(f"   錯誤：地理編碼服務錯誤 - {e}")
                return None
        return None

    def build_search_address(self, intersection: Dict[str, str]) -> str:
        """
        建立搜尋用的地址字串

        Args:
            intersection: 路口資料

        Returns:
            完整的搜尋地址
        """
        # 格式：台北市[分區][路口名稱]
        district = intersection['district']
        intersection_name = intersection['intersection']

        # 處理特殊情況：取路口名稱的第一段作為主要道路
        # 例如：「承德路與市民大道」→「承德路市民大道」或直接用「承德路」
        if '與' in intersection_name:
            roads = intersection_name.split('與')
            main_road = roads[0].strip()
        else:
            main_road = intersection_name

        # 建立多個可能的搜尋字串
        addresses = [
            f"台北市{district}區{intersection_name}",  # 完整路口
            f"台北市{district}區{main_road}",  # 主要道路
            f"{intersection_name},台北市{district}區",  # 逗號分隔
            f"{main_road},台北市",  # 簡化版
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
        search_addresses = self.build_search_address(intersection)

        print(f"處理路口 #{intersection['id']}: {intersection['intersection']}")

        # 嘗試多個搜尋地址
        coords = None
        used_address = None

        for address in search_addresses:
            print(f"   嘗試：{address}")
            coords = self.geocode_address(address)
            if coords:
                used_address = address
                break
            time.sleep(1)  # 避免API速率限制

        # 建立結果
        result = intersection.copy()

        if coords:
            result['latitude'] = coords[0]
            result['longitude'] = coords[1]
            result['geocoded'] = True
            result['geocode_address'] = used_address
            self.success_count += 1
            print(f"   ✓ 成功：{coords[0]:.6f}, {coords[1]:.6f}")
        else:
            result['latitude'] = None
            result['longitude'] = None
            result['geocoded'] = False
            result['geocode_address'] = None
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

        for i, intersection in enumerate(intersections, 1):
            print(f"\n[{i}/{total}]")
            result = self.geocode_intersection(intersection)
            results.append(result)

            # 每處理5個路口休息一下，避免API速率限制
            if i % 5 == 0:
                print("\n--- 休息 2 秒以避免速率限制 ---")
                time.sleep(2)

        print("\n" + "=" * 60)
        print(f"\n地理編碼完成！")
        print(f"  成功: {self.success_count} 個路口")
        print(f"  失敗: {self.failure_count} 個路口")
        print(f"  成功率: {self.success_count/total*100:.1f}%")

        if self.failed_intersections:
            print(f"\n失敗的路口：")
            for intersection in self.failed_intersections:
                print(f"  - #{intersection['id']}: {intersection['intersection']}")

        return results


def main():
    """主函數"""
    # 讀取原始路口資料
    input_file = 'data/intersections_raw.json'
    output_file = 'data/intersections_geocoded.json'
    report_file = 'data/geocoding_report.txt'

    print("台北市機車直接左轉路口地理編碼工具")
    print("=" * 60)

    with open(input_file, 'r', encoding='utf-8') as f:
        intersections = json.load(f)

    print(f"\n已載入 {len(intersections)} 個路口資料")

    # 建立地理編碼器
    geocoder = IntersectionGeocoder()

    # 執行地理編碼
    geocoded_results = geocoder.geocode_all(intersections)

    # 儲存結果
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(geocoded_results, f, ensure_ascii=False, indent=2)

    print(f"\n✓ 已儲存地理編碼結果: {output_file}")

    # 產生報告
    with open(report_file, 'w', encoding='utf-8') as f:
        f.write("台北市機車直接左轉路口地理編碼報告\n")
        f.write("=" * 60 + "\n\n")
        f.write(f"總路口數: {len(intersections)}\n")
        f.write(f"成功: {geocoder.success_count}\n")
        f.write(f"失敗: {geocoder.failure_count}\n")
        f.write(f"成功率: {geocoder.success_count/len(intersections)*100:.1f}%\n\n")

        if geocoder.failed_intersections:
            f.write("失敗的路口列表：\n")
            f.write("-" * 60 + "\n")
            for intersection in geocoder.failed_intersections:
                f.write(f"#{intersection['id']:3d} | {intersection['district']:4s} | "
                       f"{intersection['intersection']}\n")

    print(f"✓ 已產生地理編碼報告: {report_file}")
    print("\n完成！")


if __name__ == '__main__':
    main()
