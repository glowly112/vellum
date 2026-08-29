import SwiftUI

struct StyleSheetView: View {
    @Binding var style: PageStyle
    var onDelete: () -> Void
    @State private var confirmDelete = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    paperSection
                    typeSection
                    sizeSection
                    inkSection
                    deleteSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 28)
            }
            .background((style.paper.isDark ? VellumPalette.night : VellumPalette.paper).ignoresSafeArea())
            .navigationTitle("Page")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Delete this page?", isPresented: $confirmDelete) {
                Button("Delete page", role: .destructive, action: onDelete)
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This page will be removed from this device. It cannot be undone.")
            }
        }
        .tint(style.paper.isDark ? VellumPalette.creamInk : VellumPalette.ink)
    }

    private var paperSection: some View {
        section("Paper") {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(Paper.allCases) { paper in
                        Button {
                            style = PageStyle(
                                typeface: style.typeface,
                                paper: paper,
                                ink: style.ink,
                                size: style.size
                            )
                        } label: {
                            VStack(spacing: 8) {
                                ZStack(alignment: .topLeading) {
                                    PaperBackdrop(paper: paper, compact: true)
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Aa")
                                            .font(VellumFonts.page(.book, size: 16, relativeTo: .caption))
                                            .foregroundStyle(Ink.resolve(paper.defaultInk, on: paper).color)
                                        Capsule().fill(paper.defaultInk.color.opacity(0.30)).frame(width: 28, height: 1)
                                        Capsule().fill(paper.defaultInk.color.opacity(0.20)).frame(width: 36, height: 1)
                                        Capsule().fill(paper.defaultInk.color.opacity(0.15)).frame(width: 22, height: 1)
                                    }
                                    .padding(10)
                                }
                                .frame(width: 74, height: 74)
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .strokeBorder(
                                            style.paper == paper
                                                ? (style.paper.isDark ? VellumPalette.creamInk : VellumPalette.ink)
                                                : Color.clear,
                                            lineWidth: 2
                                        )
                                }
                                .shadow(color: VellumPalette.ink.opacity(0.08), radius: 4, y: 2)

                                Text(paper.name)
                                    .font(VellumFonts.ui(.caption2))
                                    .foregroundStyle(labelColor.opacity(style.paper == paper ? 1 : 0.55))
                            }
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(paper.name)
                        .accessibilityAddTraits(style.paper == paper ? .isSelected : [])
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }

    private var typeSection: some View {
        section("Type") {
            VStack(spacing: 0) {
                ForEach(Typeface.allCases) { face in
                    Button {
                        style.typeface = face
                    } label: {
                        HStack(alignment: .center, spacing: 12) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(face.name.uppercased())
                                    .font(VellumFonts.ui(.caption2, weight: .medium))
                                    .tracking(1.2)
                                    .foregroundStyle(labelColor.opacity(0.45))
                                Text(face.sample)
                                    .font(VellumFonts.sample(face))
                                    .foregroundStyle(labelColor)
                                    .lineLimit(1)
                            }
                            Spacer(minLength: 8)
                            if style.typeface == face {
                                Image(systemName: "checkmark")
                                    .font(.body.weight(.semibold))
                                    .foregroundStyle(labelColor)
                            }
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(style.typeface == face ? labelColor.opacity(0.06) : Color.clear)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(face.name)
                    .accessibilityAddTraits(style.typeface == face ? .isSelected : [])
                }
            }
            .background(labelColor.opacity(style.paper.isDark ? 0.16 : 0.05))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }

    private var sizeSection: some View {
        section("Size") {
            Picker("Size", selection: $style.size) {
                ForEach(TypeSize.allCases) { size in
                    Text(size.name).tag(size)
                }
            }
            .pickerStyle(.segmented)
            .accessibilityLabel("Size")
        }
    }

    private var inkSection: some View {
        section("Ink") {
            HStack(spacing: 14) {
                ForEach(Ink.allowed(on: style.paper)) { ink in
                    Button {
                        style.ink = ink
                    } label: {
                        Circle()
                            .fill(ink.color)
                            .frame(width: 44, height: 44)
                            .overlay {
                                Circle()
                                    .strokeBorder(
                                        style.resolvedInk == ink
                                            ? (style.paper.isDark ? VellumPalette.creamInk : VellumPalette.ink)
                                            : VellumPalette.ink.opacity(0.18),
                                        lineWidth: style.resolvedInk == ink ? 2 : 1
                                    )
                            }
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(ink.name)
                    .accessibilityAddTraits(style.resolvedInk == ink ? .isSelected : [])
                }
            }
        }
    }

    private var deleteSection: some View {
        Button("Delete page", role: .destructive) {
            confirmDelete = true
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
    }

    private var labelColor: Color {
        style.paper.isDark ? VellumPalette.creamInk : VellumPalette.ink
    }

    private func section<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(VellumFonts.ui(.caption, weight: .semibold))
                .tracking(1.4)
                .foregroundStyle(labelColor.opacity(0.45))
                .textCase(.uppercase)
            content()
        }
    }
}
