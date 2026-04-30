import MarkerDesignSystem
import SwiftUI

struct PlaceholderFeatureView: View {
    let title: String
    let subtitle: String
    let highlights: [String]
    let systemImage: String

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: CGFloat(MarkerSpacing.screenPadding)) {
                Label(title, systemImage: systemImage)
                    .font(.largeTitle.bold())

                Text(subtitle)
                    .font(.body)
                    .foregroundStyle(.secondary)

                VStack(alignment: .leading, spacing: 12) {
                    ForEach(highlights, id: \.self) { highlight in
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "circle.fill")
                                .font(.system(size: 8))
                                .padding(.top, 7)

                            Text(highlight)
                                .font(.body)
                        }
                    }
                }
                .padding(CGFloat(MarkerSpacing.screenPadding))
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.thinMaterial)
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: CGFloat(MarkerCornerRadius.card),
                        style: .continuous
                    )
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(CGFloat(MarkerSpacing.screenPadding))
        }
        .navigationTitle(title)
    }
}
