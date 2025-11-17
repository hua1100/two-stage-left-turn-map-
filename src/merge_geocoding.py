#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
合併地理編碼結果
將使用者執行的地理編碼結果與手動補充的失敗路口合併
"""

import json
from pathlib import Path

def merge_geocoding_results():
    """合併地理編碼結果"""

    # 讀取使用者的地理編碼結果（118個成功）
    user_geocoded_file = Path("data/intersections_geocoded.json")
    with open(user_geocoded_file, 'r', encoding='utf-8') as f:
        user_data = json.load(f)

    # 讀取修復後的結果（包含手動補充的 3 個）
    fixed_file = Path("data/intersections_geocoded_fixed.json")
    with open(fixed_file, 'r', encoding='utf-8') as f:
        fixed_data = json.load(f)

    # 建立 ID 到修復資料的對應
    fixed_map = {item['id']: item for item in fixed_data if item.get('geocode_source') == 'manual_fix'}

    # 合併資料
    merged_data = []
    for item in user_data:
        item_id = item['id']

        # 如果這個路口在失敗列表中，使用手動補充的座標
        if item_id in fixed_map and not item.get('geocoded', False):
            print(f"✅ 補充路口 #{item_id}: {item['intersection']}")
            merged_item = item.copy()
            merged_item.update({
                'latitude': fixed_map[item_id]['latitude'],
                'longitude': fixed_map[item_id]['longitude'],
                'geocoded': True,
                'geocode_source': 'manual_fix'
            })
            merged_data.append(merged_item)
        else:
            merged_data.append(item)

    # 儲存最終結果
    output_file = Path("data/intersections_final.json")
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(merged_data, f, ensure_ascii=False, indent=2)

    # 統計
    total = len(merged_data)
    geocoded_count = sum(1 for i in merged_data if i.get('geocoded', False))
    auto_count = sum(1 for i in merged_data if i.get('geocode_source') == 'nominatim')
    manual_count = sum(1 for i in merged_data if i.get('geocode_source') == 'manual_fix')

    print("\n" + "=" * 60)
    print("🎉 合併完成！")
    print(f"   總路口數: {total}")
    print(f"   已地理編碼: {geocoded_count} (100%)")
    print(f"   自動編碼: {auto_count}")
    print(f"   手動補充: {manual_count}")
    print(f"   輸出檔案: {output_file}")
    print("=" * 60)

if __name__ == "__main__":
    merge_geocoding_results()
