import SwiftUI
import MapKit

/// 地圖主頁面
/// 顯示台北市 121 個可直接左轉路口
struct MapView: View {

    // MARK: - Properties

    @StateObject private var viewModel = MapViewModel()
    @State private var showSearchBar = false

    // MARK: - Body

    var body: some View {
        ZStack(alignment: .top) {
            // 地圖
            Map(coordinateRegion: $viewModel.region,
                showsUserLocation: true,
                annotationItems: viewModel.intersectionAnnotations) { annotation in
                MapAnnotation(coordinate: annotation.coordinate) {
                    IntersectionMarker(annotation: annotation) {
                        viewModel.selectIntersection(annotation.intersection)
                    }
                }
            }
            .ignoresSafeArea()

            // 頂部工具列與搜尋
            VStack(spacing: 0) {
                topToolbar

                if showSearchBar {
                    searchBar

                    // 搜尋結果列表
                    if !viewModel.searchKeyword.isEmpty && !viewModel.filteredIntersections.isEmpty {
                        searchResultsList
                    }
                }
            }
            .background(Color(UIColor.systemBackground).opacity(0.95))
            .cornerRadius(12)
            .shadow(radius: 5)
            .padding(.horizontal)
            .padding(.top, 8)

            // 底部按鈕組
            VStack {
                Spacer()

                HStack(spacing: 16) {
                    // 顯示所有路口
                    FloatingButton(icon: "map") {
                        viewModel.showAllIntersections()
                    }

                    // 移動到使用者位置
                    FloatingButton(icon: "location.fill") {
                        viewModel.centerOnUserLocation()
                    }
                }
                .padding(.bottom, 16)
            }
        }
        .sheet(isPresented: $viewModel.showIntersectionDetail) {
            if let intersection = viewModel.selectedIntersection {
                IntersectionDetailView(
                    intersection: intersection,
                    onNavigateAppleMaps: {
                        viewModel.openInAppleMaps(intersection)
                    },
                    onNavigateGoogleMaps: {
                        viewModel.openInGoogleMaps(intersection)
                    },
                    onClose: {
                        viewModel.deselectIntersection()
                    }
                )
            }
        }
        .alert("錯誤", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("確定") {
                viewModel.errorMessage = nil
            }
        } message: {
            if let error = viewModel.errorMessage {
                Text(error)
            }
        }
    }

    // MARK: - Subviews

    /// 頂部工具列
    private var topToolbar: some View {
        HStack {
            Text("台北市可直接左轉路口")
                .font(.headline)
                .foregroundColor(.primary)

            Spacer()

            // 搜尋按鈕
            Button {
                withAnimation {
                    showSearchBar.toggle()
                }
            } label: {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.blue)
                    .font(.title3)
            }

            // 路口計數
            Text("\(viewModel.filteredIntersections.count)")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
        }
        .padding()
    }

    /// 搜尋列
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)

            TextField("搜尋路口名稱", text: $viewModel.searchKeyword)
                .textFieldStyle(PlainTextFieldStyle())
                .foregroundColor(.primary)

            if !viewModel.searchKeyword.isEmpty {
                Button {
                    viewModel.searchKeyword = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(8)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(8)
        .padding(.horizontal)
        .padding(.bottom, 8)
    }

    /// 搜尋結果列表
    private var searchResultsList: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(viewModel.filteredIntersections.prefix(10), id: \.id) { intersection in
                    Button(action: {
                        // 選擇路口並跳轉
                        viewModel.selectIntersection(intersection)
                        // 關閉搜尋欄
                        showSearchBar = false
                        viewModel.searchKeyword = ""
                    }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(intersection.displayName)
                                    .font(.body)
                                    .foregroundColor(.primary)

                                HStack {
                                    Text(intersection.district)
                                        .font(.caption)
                                        .foregroundColor(.secondary)

                                    Text("•")
                                        .foregroundColor(.secondary)

                                    Text(intersection.direction)
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                }
                            }

                            Spacer()

                            Image(systemName: "arrow.right.circle.fill")
                                .foregroundColor(.blue)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 12)
                    }

                    if intersection.id != viewModel.filteredIntersections.prefix(10).last?.id {
                        Divider()
                            .padding(.leading)
                    }
                }
            }
        }
        .frame(maxHeight: 300)
        .padding(.bottom, 8)
    }
}

// MARK: - IntersectionMarker

/// 路口標記
struct IntersectionMarker: View {
    let annotation: IntersectionAnnotation
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack {
                Circle()
                    .fill(Color.green)
                    .frame(width: 30, height: 30)
                    .shadow(radius: 3)

                Image(systemName: "arrow.turn.up.left")
                    .foregroundColor(.white)
                    .font(.system(size: 14, weight: .bold))
            }
        }
    }
}

// MARK: - FloatingButton

/// 浮動按鈕
struct FloatingButton: View {
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(Color.blue)
                .clipShape(Circle())
                .shadow(radius: 5)
        }
    }
}

// MARK: - IntersectionDetailView

/// 路口詳情視圖
struct IntersectionDetailView: View {
    let intersection: Intersection
    let onNavigateAppleMaps: () -> Void
    let onNavigateGoogleMaps: () -> Void
    let onClose: () -> Void

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // 路口資訊
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "mappin.circle.fill")
                                .foregroundColor(.green)
                                .font(.title2)

                            VStack(alignment: .leading) {
                                Text(intersection.displayName)
                                    .font(.title2)
                                    .fontWeight(.bold)

                                Text(intersection.district)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }

                        Divider()

                        // 可左轉方向
                        HStack {
                            Text("可左轉方向：")
                                .font(.headline)
                            Text(intersection.direction)
                                .foregroundColor(.secondary)
                        }

                        // 開放年份
                        HStack {
                            Text("開放年份：")
                                .font(.headline)
                            Text(intersection.openedYear)
                                .foregroundColor(.secondary)
                        }

                        // 座標資訊
                        VStack(alignment: .leading, spacing: 4) {
                            Text("座標資訊：")
                                .font(.headline)
                            Text("緯度：\(intersection.latitude, specifier: "%.6f")")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("經度：\(intersection.longitude, specifier: "%.6f")")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)

                    // 導航按鈕
                    VStack(spacing: 12) {
                        Text("導航至路口")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Button(action: onNavigateAppleMaps) {
                            HStack {
                                Image(systemName: "map.fill")
                                Text("使用 Apple 地圖導航")
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }

                        Button(action: onNavigateGoogleMaps) {
                            HStack {
                                Image(systemName: "map.fill")
                                Text("使用 Google 地圖導航")
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)

                    // 使用提示
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.blue)
                            Text("使用提示")
                                .font(.headline)
                        }

                        Text("• 此路口允許機車直接左轉，無需兩段式左轉")
                        Text("• 請注意：僅在指定方向行駛時可直接左轉")
                        Text("• 行駛前請確認當前交通號誌與規則")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle("路口詳情")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("關閉") {
                        onClose()
                    }
                }
            }
        }
    }
}

// MARK: - Preview

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}
