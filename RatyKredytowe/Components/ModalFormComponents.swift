import SwiftUI

// MARK: - Sheet shell

struct ModalFormShell<Content: View>: View {
    let title: String
    var saveDisabled: Bool = false
    var saveLabel: String = "Zapisz"
    let onSave: () -> Void
    @ViewBuilder let content: () -> Content

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                content()
                    .padding(.horizontal, AppTheme.spacingXL)
                    .padding(.vertical, AppTheme.spacingL)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .scrollIndicators(.hidden)
            .appScreenBackground()
            .navigationTitle(title)
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Anuluj") { dismiss() }
                        .foregroundStyle(AppTheme.textSecondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(saveLabel) {
                        onSave()
                        dismiss()
                    }
                    .disabled(saveDisabled)
                }
            }
        }
        .formSheetFrame()
    }
}

// MARK: - Form blocks

struct FormSectionCard<Content: View>: View {
    let title: String?
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingM) {
            if let title {
                Text(title.uppercased())
                    .font(AppFont.labelUppercase)
                    .foregroundStyle(AppTheme.textTertiary)
                    .tracking(0.5)
            }
            content()
        }
        .appCard()
    }
}

struct FormSegmentedPicker<T: Hashable & CaseIterable & Identifiable>: View where T.AllCases: RandomAccessCollection, T: RawRepresentable, T.RawValue == String {
    let label: String
    @Binding var selection: T
    let options: [T]

    init(label: String, selection: Binding<T>, options: [T] = Array(T.allCases)) {
        self.label = label
        _selection = selection
        self.options = options
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingS) {
            Text(label.uppercased())
                .font(AppFont.labelUppercase)
                .foregroundStyle(AppTheme.textTertiary)
                .tracking(0.5)

            Picker("", selection: $selection) {
                ForEach(options) { option in
                    Text(option.rawValue).tag(option)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
        }
    }
}

struct FormTextEditor: View {
    let placeholder: String
    @Binding var text: String
    var minHeight: CGFloat = 120

    var body: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text(placeholder)
                    .font(AppFont.body())
                    .foregroundStyle(AppTheme.textTertiary)
                    .padding(.horizontal, AppTheme.spacingM + 2)
                    .padding(.vertical, AppTheme.spacingM + 4)
            }

            TextField("", text: $text, axis: .vertical)
                .font(AppFont.body())
                .lineLimit(5...12)
                .padding(AppTheme.spacingM)
                #if os(iOS)
                .textInputAutocapitalization(.sentences)
                #endif
        }
        .frame(minHeight: minHeight, alignment: .topLeading)
        .background(AppTheme.appBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                .strokeBorder(AppTheme.border, lineWidth: 1)
        }
    }
}

struct FormToggleRow: View {
    let title: String
    @Binding var isOn: Bool
    var isVisible: Bool = true

    var body: some View {
        Toggle(isOn: $isOn) {
            Text(title)
                .font(AppFont.body())
        }
        .tint(AppTheme.primary)
        .frame(height: 44, alignment: .leading)
        .opacity(isVisible ? 1 : 0)
        .disabled(!isVisible)
        .accessibilityHidden(!isVisible)
    }
}

struct FormInfoRow: View {
    let icon: String
    let text: String
    var isVisible: Bool = true

    var body: some View {
        HStack(alignment: .top, spacing: AppTheme.spacingS) {
            Image(systemName: icon)
                .font(.caption.weight(.semibold))
                .foregroundStyle(AppTheme.textTertiary)
                .frame(width: 18)
            Text(text)
                .font(AppFont.caption())
                .foregroundStyle(AppTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(minHeight: 40, alignment: .topLeading)
        .opacity(isVisible ? 1 : 0)
        .accessibilityHidden(!isVisible)
    }
}

// MARK: - Sizing

extension View {
    func formSheetFrame() -> some View {
        #if os(macOS)
        self
            .frame(minWidth: 540, idealWidth: 580, minHeight: 520, idealHeight: 560)
        #else
        self
        #endif
    }
}
