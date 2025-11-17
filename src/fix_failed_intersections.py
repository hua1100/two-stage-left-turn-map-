#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
修復失敗的路口地理編碼
補充三個失敗路口的座標
"""

import json
from pathlib import Path

# 失敗路口的手動座標
FAILED_INTERSECTIONS_COORDS = {
    6: {
        "latitude": 25.110428,
        "longitude": 121.508276,
        "note": "士林區延平北路6段與環河北路3段交叉口（社子地區）"
    },
    80: {
        "latitude": 25.024319,
        "longitude": 121.553158,
        "note": "大安區和平東路3段與安和路2段交叉口（近師大）"
    },
    120: {
        "latitude": 25.051892,
        "longitude": 121.602445,
        "note": "南港區市民大道7段與向陽路交叉口"
    }
}

def fix_geocoding_results():
    """修復地理編碼結果"""

    # 檔案路徑
    input_file = Path("data/intersections_geocoded.json")
    output_file = Path("data/intersections_geocoded_fixed.json")

    # 如果地理編碼結果不存在，從原始資料開始
    if not input_file.exists():
        print("⚠️  未找到 intersections_geocoded.json，從原始資料開始")
        input_file = Path("data/intersections_raw.json")

    # 讀取資料
    with open(input_file, 'r', encoding='utf-8') as f:
        intersections = json.load(f)

    # 補充失敗路口的座標
    fixed_count = 0
    for intersection in intersections:
        intersection_id = intersection['id']

        if intersection_id in FAILED_INTERSECTIONS_COORDS:
            coords = FAILED_INTERSECTIONS_COORDS[intersection_id]

            # 更新座標
            intersection['latitude'] = coords['latitude']
            intersection['longitude'] = coords['longitude']
            intersection['geocoded'] = True
            intersection['geocode_source'] = 'manual_fix'

            fixed_count += 1
            print(f"✅ 修復路口 #{intersection_id}: {intersection['intersection']}")
            print(f"   座標: {coords['latitude']}, {coords['longitude']}")
            print(f"   備註: {coords['note']}")
            print()
        elif 'latitude' not in intersection or 'longitude' not in intersection:
            # 如果還有其他未地理編碼的路口，標記為未完成
            intersection['geocoded'] = False
            intersection['geocode_source'] = None

    # 儲存修復後的結果
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(intersections, f, ensure_ascii=False, indent=2)

    # 統計
    total = len(intersections)
    geocoded_count = sum(1 for i in intersections if i.get('geocoded', False))

    print("=" * 60)
    print(f"✅ 修復完成！")
    print(f"   修復路口數: {fixed_count}")
    print(f"   總路口數: {total}")
    print(f"   已地理編碼: {geocoded_count} ({geocoded_count/total*100:.1f}%)")
    print(f"   輸出檔案: {output_file}")
    print("=" * 60)

    # 檢查是否還有未地理編碼的路口
    not_geocoded = [i for i in intersections if not i.get('geocoded', False)]
    if not_geocoded:
        print(f"\n⚠️  仍有 {len(not_geocoded)} 個路口未地理編碼:")
        for i in not_geocoded[:10]:  # 只顯示前 10 個
            print(f"   #{i['id']} - {i['district']} - {i['intersection']}")
        if len(not_geocoded) > 10:
            print(f"   ... 還有 {len(not_geocoded) - 10} 個")
    else:
        print("\n🎉 所有路口已完成地理編碼！")

if __name__ == "__main__":
    fix_geocoding_results()
