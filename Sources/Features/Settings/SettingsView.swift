import SwiftUI

struct SettingsView: View {
    @Bindable var viewModel: CounterViewModel

    var body: some View {
        Form {
            appearanceSection
            targetSection
            hotkeySection
            placementSection
            privacySection
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
    }

    // MARK: - Sections

    @ViewBuilder
    private var appearanceSection: some View {
        Section {
            Picker("Theme", selection: $viewModel.appTheme) {
                ForEach(AppTheme.allCases) { theme in
                    ThemeRow(theme: theme).tag(theme)
                }
            }
            .pickerStyle(.menu)
            .onChange(of: viewModel.appTheme) { _, _ in viewModel.applySettings() }

            Picker("Show", selection: $viewModel.displayMode) {
                Text("Completed count").tag(DisplayMode.completed)
                Text("Remaining count").tag(DisplayMode.remaining)
            }
            .pickerStyle(.menu)
            .onChange(of: viewModel.displayMode) { _, _ in viewModel.applySettings() }

            Toggle("Show progress ring", isOn: $viewModel.showProgressRing)
                .onChange(of: viewModel.showProgressRing) { _, _ in viewModel.applySettings() }
        } header: {
            Text("Appearance")
        }
    }

    @ViewBuilder
    private var targetSection: some View {
        Section {
            Picker("Target", selection: $viewModel.targetPreset) {
                Text("Off").tag(TargetPreset.off)
                Text("33").tag(TargetPreset.thirtyThree)
                Text("100").tag(TargetPreset.oneHundred)
                Text("Custom").tag(TargetPreset.custom)
            }
            .pickerStyle(.segmented)
            .onChange(of: viewModel.targetPreset) { _, _ in viewModel.applySettings() }

            if viewModel.targetPreset == .custom {
                LabeledContent("Count") {
                    TextField("", text: $viewModel.customTarget, prompt: Text("e.g. 99"))
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: 120)
                        .onSubmit { viewModel.applySettings() }
                        .onChange(of: viewModel.customTarget) { _, _ in viewModel.applySettings() }
                }
            }
        } header: {
            Text("Target")
        } footer: {
            Text("A target adds a quiet progress ring and a completion subtitle. It never interrupts you.")
                .font(DesignTokens.Typography.caption)
                .foregroundStyle(.secondary)
        }
    }

    @ViewBuilder
    private var hotkeySection: some View {
        Section {
            KeyCaptureField(
                binding: $viewModel.hotkey,
                requiresModifier: viewModel.requiresModifier
            )
            .onChange(of: viewModel.hotkey) { _, new in
                viewModel.setHotkey(new)
            }

            HStack(alignment: .center, spacing: DesignTokens.Spacing.s) {
                Toggle(isOn: Binding(
                    get: { viewModel.requiresModifier },
                    set: { viewModel.setRequiresModifier($0) }
                )) {
                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.xxs) {
                        Text("Require modifier key")
                        Text("Prevents the shortcut from interfering with typing.")
                            .font(DesignTokens.Typography.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                RequireModifierInfoButton()
            }

            if !viewModel.requiresModifier, viewModel.hotkey.isPlainKey {
                Label {
                    Text("Plain keys collide with typing everywhere. Use a combo like ⌃⌥= for a true global shortcut.")
                        .font(DesignTokens.Typography.caption)
                } icon: {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundStyle(.orange)
                }
            }
        } header: {
            Text("Increment key")
        } footer: {
            Text("Combos work globally from any app, with no permission prompt.")
                .font(DesignTokens.Typography.caption)
                .foregroundStyle(.secondary)
        }
    }

    @ViewBuilder
    private var placementSection: some View {
        Section {
            Picker("Snap to", selection: $viewModel.widgetAnchor) {
                ForEach(WidgetAnchor.allCases) { anchor in
                    Text(anchor.displayName).tag(anchor)
                }
            }
            .pickerStyle(.menu)
            .onChange(of: viewModel.widgetAnchor) { _, _ in viewModel.applySettings() }
        } header: {
            Text("Window")
        } footer: {
            Text("You can also drag the widget anywhere; the corner snap only applies on change.")
                .font(DesignTokens.Typography.caption)
                .foregroundStyle(.secondary)
        }
    }

    @ViewBuilder
    private var privacySection: some View {
        Section {
            Label {
                Text("No network, no analytics, no accounts.")
                    .font(DesignTokens.Typography.caption)
            } icon: {
                Image(systemName: "lock.shield")
                    .foregroundStyle(.secondary)
            }
        }
    }
}

/// A small themed row for the theme picker. Shows a swatch + display name.
private struct ThemeRow: View {
    let theme: AppTheme

    var body: some View {
        HStack(spacing: DesignTokens.Spacing.m) {
            Circle()
                .fill(theme.palette.accent)
                .frame(width: 10, height: 10)
            Text(theme.displayName)
        }
    }
}

/// Info button that explains the "Require modifier key" setting in more
/// detail, without cluttering the toggle's main caption. Uses a popover so the
/// explanation is one click away but never on-screen by default.
private struct RequireModifierInfoButton: View {
    @State private var isShown: Bool = false

    var body: some View {
        Button {
            isShown.toggle()
        } label: {
            Image(systemName: "info.circle")
                .imageScale(.medium)
                .foregroundStyle(.secondary)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("About the Require modifier key setting")
        .popover(isPresented: $isShown, arrowEdge: .trailing) {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.m) {
                Text("Require modifier key")
                    .font(.headline)

                Text("When this is on, your shortcut must include at least one modifier (⌃, ⌥, ⌘ or ⇧). The default is ⌃⌥= and works globally from any app, with no permission prompt.")
                    .font(DesignTokens.Typography.body)

                Text("When this is off, you can bind a plain key like `=`. The key still registers globally, but macOS will not hide it from the app you are typing in — so pressing `=` in a text field will both type `=` and count. Choose a key you rarely type (for example a function key) to avoid surprises.")
                    .font(DesignTokens.Typography.body)
                    .foregroundStyle(.secondary)
            }
            .padding(DesignTokens.Spacing.xl)
            .frame(width: 320)
        }
    }
}
