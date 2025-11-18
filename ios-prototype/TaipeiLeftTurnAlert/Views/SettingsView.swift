import SwiftUI

/// 設定頁面
/// 提供使用者個人化設定介面
struct SettingsView: View {

    // MARK: - Properties

    @StateObject private var viewModel = SettingsViewModel()
    @State private var showPresetPicker = false

    // MARK: - Body

    var body: some View {
        NavigationView {
            Form {
                // 基本設定
                Section {
                    // 語音開關
                    Toggle(isOn: $viewModel.voiceEnabled) {
                        HStack {
                            Image(systemName: "speaker.wave.2.fill")
                                .foregroundColor(.blue)
                            Text("語音警示")
                        }
                    }

                    // 測試語音按鈕
                    Button(action: {
                        viewModel.testVoice()
                    }) {
                        HStack {
                            Image(systemName: "play.circle.fill")
                                .foregroundColor(.green)
                            Text("測試語音")
                            Spacer()
                            if viewModel.testMessage != nil {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            }
                        }
                    }
                    .disabled(!viewModel.voiceEnabled)

                } header: {
                    Text("語音設定")
                } footer: {
                    Text("語音警示將在接近路口時自動播放")
                }

                // 語音參數
                if viewModel.voiceEnabled {
                    Section {
                        // 語速
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("語速")
                                Spacer()
                                Text(viewModel.speechRateDescription)
                                    .foregroundColor(.secondary)
                            }
                            Slider(value: $viewModel.speechRate, in: 0.3...0.7, step: 0.1)
                        }

                        // 音量
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("音量")
                                Spacer()
                                Text("\(viewModel.volumePercentage)%")
                                    .foregroundColor(.secondary)
                            }
                            Slider(value: $viewModel.volume, in: 0.5...1.0, step: 0.1)
                        }

                    } header: {
                        Text("語音參數")
                    }
                }

                // 進階設定
                Section {
                    // 切換進階設定顯示
                    Button {
                        withAnimation {
                            viewModel.showAdvancedSettings.toggle()
                        }
                    } label: {
                        HStack {
                            Image(systemName: "gearshape.2.fill")
                                .foregroundColor(.orange)
                            Text("進階設定")
                            Spacer()
                            Image(systemName: viewModel.showAdvancedSettings ? "chevron.up" : "chevron.down")
                                .foregroundColor(.secondary)
                        }
                    }

                    if viewModel.showAdvancedSettings {
                        // 警示距離
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("警示距離")
                                Spacer()
                                Text(viewModel.alertDistanceDescription)
                                    .foregroundColor(.secondary)
                            }
                            Slider(value: $viewModel.alertDistance, in: 100...200, step: 10)
                        }

                        // 方向容許誤差
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("方向容許誤差")
                                Spacer()
                                Text(viewModel.directionToleranceDescription)
                                    .foregroundColor(.secondary)
                            }
                            Slider(value: $viewModel.directionTolerance, in: 20...45, step: 5)
                        }

                        // 最小警示間隔
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("最小警示間隔")
                                Spacer()
                                Text(viewModel.minimumAlertIntervalDescription)
                                    .foregroundColor(.secondary)
                            }
                            Slider(value: $viewModel.minimumAlertInterval, in: 15...60, step: 5)
                        }
                    }

                } header: {
                    Text("進階選項")
                } footer: {
                    if viewModel.showAdvancedSettings {
                        Text("警示距離：接近路口多少公尺時開始警示\n方向容許誤差：行駛方向的匹配精準度\n最小警示間隔：避免重複警示的時間間隔")
                    }
                }

                // 預設配置
                if viewModel.showAdvancedSettings {
                    Section {
                        Button {
                            showPresetPicker = true
                        } label: {
                            HStack {
                                Image(systemName: "slider.horizontal.3")
                                    .foregroundColor(.purple)
                                Text("快速套用預設配置")
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                            }
                        }

                        Button(action: {
                            viewModel.resetToDefaults()
                        }) {
                            HStack {
                                Image(systemName: "arrow.counterclockwise")
                                    .foregroundColor(.red)
                                Text("重設為預設值")
                                    .foregroundColor(.red)
                            }
                        }

                    } header: {
                        Text("配置管理")
                    }
                }

                // 關於
                Section {
                    Button {
                        viewModel.showAboutPage = true
                    } label: {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(.blue)
                            Text("關於此 App")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                    }

                } header: {
                    Text("資訊")
                }

                // 版本資訊
                Section {
                    HStack {
                        Text("版本")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("路口總數")
                        Spacer()
                        Text("121 個")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("設定")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showPresetPicker) {
                PresetPickerView { preset in
                    viewModel.applyPreset(preset)
                    showPresetPicker = false
                }
            }
            .sheet(isPresented: $viewModel.showAboutPage) {
                AboutView()
            }
            .overlay(alignment: .bottom) {
                if let message = viewModel.testMessage {
                    ToastView(message: message)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .animation(.easeInOut, value: viewModel.testMessage)
                }
            }
        }
    }
}

// MARK: - PresetPickerView

/// 預設配置選擇器
struct PresetPickerView: View {
    let onSelect: (UserPreferences.Preset) -> Void

    var body: some View {
        NavigationView {
            List {
                ForEach([UserPreferences.Preset.conservative, .standard, .aggressive], id: \.self) { preset in
                    Button {
                        onSelect(preset)
                    } label: {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(presetTitle(preset))
                                .font(.headline)
                                .foregroundColor(.primary)

                            Text(preset.description)
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            HStack {
                                Text("警示距離：\(Int(preset.settings.alertDistance))m")
                                Text("方向誤差：\(Int(preset.settings.directionTolerance))°")
                            }
                            .font(.caption)
                            .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("選擇預設配置")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func presetTitle(_ preset: UserPreferences.Preset) -> String {
        switch preset {
        case .conservative:
            return "保守模式"
        case .standard:
            return "標準模式"
        case .aggressive:
            return "積極模式"
        }
    }
}

// MARK: - AboutView

/// 關於頁面
struct AboutView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // App 圖示
                    VStack {
                        Image(systemName: "arrow.triangle.turn.up.right.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.green)

                        Text("台北市左轉提示")
                            .font(.title)
                            .fontWeight(.bold)

                        Text("版本 1.0.0")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()

                    Divider()

                    // 功能說明
                    VStack(alignment: .leading, spacing: 12) {
                        Text("功能特色")
                            .font(.headline)

                        FeatureRow(icon: "map.fill", title: "路口地圖", description: "顯示台北市 121 個可直接左轉路口")
                        FeatureRow(icon: "speaker.wave.2.fill", title: "語音警示", description: "接近路口時自動語音提醒")
                        FeatureRow(icon: "location.fill", title: "智慧方向", description: "只在正確行駛方向時提醒")
                        FeatureRow(icon: "arrow.triangle.swap", title: "導航整合", description: "支援 Apple 地圖與 Google 地圖")
                    }
                    .padding()

                    Divider()

                    // 使用說明
                    VStack(alignment: .leading, spacing: 12) {
                        Text("使用說明")
                            .font(.headline)

                        Text("1. 開啟定位權限：允許 App 使用您的位置資訊")
                        Text("2. 啟用語音警示：在設定中開啟語音功能")
                        Text("3. 開始騎乘：App 會在接近路口時自動提醒")
                        Text("4. 查看地圖：可隨時查看所有可直接左轉路口")
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding()

                    Divider()

                    // 注意事項
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                            Text("重要提醒")
                                .font(.headline)
                        }

                        Text("• 請遵守交通規則與號誌指示")
                        Text("• 僅在指定方向行駛時可直接左轉")
                        Text("• 請注意路況與其他用路人安全")
                        Text("• 建議搭配導航 App 使用")
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding()
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(12)

                    Divider()

                    // 資料來源
                    VStack(alignment: .leading, spacing: 8) {
                        Text("資料來源")
                            .font(.headline)

                        Text("台北市政府交通局")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Text("路口資料更新日期：2024年")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                }
                .padding()
            }
            .navigationTitle("關於")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("關閉") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - FeatureRow

/// 功能特色列
struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - ToastView

/// 提示訊息視圖
struct ToastView: View {
    let message: String

    var body: some View {
        Text(message)
            .font(.subheadline)
            .foregroundColor(.white)
            .padding()
            .background(Color.black.opacity(0.8))
            .cornerRadius(12)
            .padding(.bottom, 20)
    }
}

// MARK: - Preview

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
